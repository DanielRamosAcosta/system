{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.quadroSensors;

  virtualSlots = [ "virtual1" "virtual2" "virtual3" "virtual4" "virtual5" "virtual6" "virtual7" "virtual8" ];

  sourceModule = types.submodule {
    options = {
      kind = mkOption {
        type = types.enum [ "hwmonName" "hwmonMaxByName" "hwmonByDevicePath" ];
      };
      name = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      label = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      devicePath = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  feederScript = pkgs.writeShellScript "quadro-sensors-feeder" ''
    set -u
    export PATH=${makeBinPath [ pkgs.jq pkgs.coreutils pkgs.gnugrep pkgs.gawk pkgs.findutils pkgs.quadro-ctl ]}:$PATH

    readonly INTERVAL=${toString cfg.intervalSeconds}
    readonly STATE_FILE=/run/quadro-sensors/last.json
    mkdir -p /run/quadro-sensors

    # Resolve hwmon path by name. Echoes path or empty string.
    hwmon_path_by_name() {
      local want="$1"
      for h in /sys/class/hwmon/hwmon*; do
        [ -r "$h/name" ] || continue
        if [ "$(cat "$h/name")" = "$want" ]; then
          echo "$h"
          return 0
        fi
      done
      return 1
    }

    # Read a single temp from a hwmon by label match (or temp1 if no label given).
    # Args: hwmon_path, label ("" for temp1_input)
    read_temp_labeled() {
      local hp="$1" label="$2" f idx
      if [ -z "$label" ]; then
        if [ -r "$hp/temp1_input" ]; then
          cat "$hp/temp1_input"
          return 0
        fi
        return 1
      fi
      for f in "$hp"/temp*_label; do
        [ -r "$f" ] || continue
        if [ "$(cat "$f")" = "$label" ]; then
          idx="''${f##*/temp}"
          idx="''${idx%_label}"
          cat "$hp/temp''${idx}_input"
          return 0
        fi
      done
      return 1
    }

    # Reads all temps from hwmons matching `name`, returns the max (in milli-°C).
    max_temp_across_hwmons() {
      local want="$1" best="" h f val
      for h in /sys/class/hwmon/hwmon*; do
        [ -r "$h/name" ] || continue
        [ "$(cat "$h/name")" = "$want" ] || continue
        for f in "$h"/temp*_input; do
          [ -r "$f" ] || continue
          val=$(cat "$f") || continue
          [ -z "$val" ] && continue
          if [ -z "$best" ] || [ "$val" -gt "$best" ]; then
            best="$val"
          fi
        done
      done
      [ -n "$best" ] && echo "$best"
    }

    tick() {
      local json="{}"
      ${concatStringsSep "\n" (mapAttrsToList (slot: src: ''
        # ${slot}: ${src.kind}${optionalString (src.name != null) " name=${src.name}"}${optionalString (src.label != null) " label=${src.label}"}${optionalString (src.devicePath != null) " devicePath=${src.devicePath}"}
        {
          v_milli=""
          ${if src.kind == "hwmonName" then ''
            hp=$(hwmon_path_by_name "${src.name}") || hp=""
            if [ -n "$hp" ]; then
              v_milli=$(read_temp_labeled "$hp" "${optionalString (src.label != null) src.label}") || v_milli=""
            fi
          '' else if src.kind == "hwmonMaxByName" then ''
            v_milli=$(max_temp_across_hwmons "${src.name}") || v_milli=""
          '' else ''
            hp=$(ls -d ${src.devicePath}/hwmon* 2>/dev/null | head -1) || hp=""
            if [ -n "$hp" ]; then
              v_milli=$(read_temp_labeled "$hp" "${optionalString (src.label != null) src.label}") || v_milli=""
            fi
          ''}
          if [ -n "$v_milli" ]; then
            v_c=$(awk -v m="$v_milli" 'BEGIN{printf "%.2f", m/1000}')
            json=$(echo "$json" | jq --arg v "$v_c" '."${slot}" = ($v | tonumber)')
          fi
        }
      '') cfg.virtualSensors)}

      if [ "$(echo "$json" | jq 'length')" -eq 0 ]; then
        echo "[feeder] no sensor values readable this tick" >&2
        return
      fi

      echo "$json" > "$STATE_FILE.tmp"
      mv "$STATE_FILE.tmp" "$STATE_FILE"
      quadro-ctl sensors set --config-file "$STATE_FILE" >/dev/null 2>&1 || \
        echo "[feeder] quadro-ctl sensors set failed" >&2
    }

    while true; do
      tick
      sleep "$INTERVAL"
    done
  '';

in
{
  options.services.quadroSensors = {
    enable = mkEnableOption "QUADRO virtual sensor feeder";

    intervalSeconds = mkOption {
      type = types.ints.positive;
      default = 2;
    };

    virtualSensors = mkOption {
      type = types.attrsOf sourceModule;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = all (n: elem n virtualSlots) (attrNames cfg.virtualSensors);
        message = "quadroSensors: keys must be one of ${concatStringsSep ", " virtualSlots}";
      }
    ];

    systemd.services.quadro-sensors = {
      description = "Feed QUADRO virtual sensors from host hwmon";
      wantedBy = [ "multi-user.target" ];
      after = [ "fans.service" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = feederScript;
        Restart = "always";
        RestartSec = 2;
        RuntimeDirectory = "quadro-sensors";
      };
    };
  };
}
