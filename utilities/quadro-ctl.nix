{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.fans;

  utilities = import ./utilities.nix { inherit lib; };

  fanNames = [ "fan1" "fan2" "fan3" "fan4" ];

  # Reference a fan curve uses to pick which QUADRO sensor channel drives it.
  sensorModule = types.submodule {
    options = {
      source = mkOption {
        type = types.enum [ "hardware" "virtual" "flow" ];
      };
      index = mkOption {
        type = types.nullOr types.ints.positive;
        default = null;
      };
    };
  };

  fanModule = types.submodule {
    options = {
      percentage = mkOption {
        type = types.nullOr (types.ints.between 0 100);
        default = null;
      };

      sensor = mkOption {
        type = types.nullOr sensorModule;
        default = null;
      };

      curve = mkOption {
        type = types.nullOr (types.listOf (types.submodule {
          options = {
            temp = mkOption {
              type = types.ints.between 0 100;
            };
            speedPercentage = mkOption {
              type = types.ints.between 0 100;
            };
          };
        }));
        default = null;
      };
    };
  };

  sensorToInt = sensor:
    if sensor.source == "hardware" then sensor.index - 1
    else if sensor.source == "flow" then 4
    else if sensor.source == "virtual" then 4 + sensor.index
    else throw "invalid sensor source";

  fanToJson = fan:
    if fan.percentage != null then {
      mode = "manual";
      percentage = fan.percentage;
    } else
      let
        raw = utilities.interpolateCurve fan.curve;
        # Enforce strict monotonicity: when interpolation produces duplicate
        # integer temps (curve range < 15), nudge by 0.01 °C to satisfy
        # the firmware's "monotonically increasing" constraint.
        dedupe = acc: p:
          let
            prev = if acc == [] then null else (lib.last acc).temp;
            t = if prev != null && p.temp <= prev then prev + 0.01 else p.temp * 1.0;
          in acc ++ [ { inherit (p) speedPercentage; temp = t; } ];
        fixed = lib.foldl' dedupe [] raw;
      in {
        mode = "curve";
        sensor = sensorToInt fan.sensor;
        points = map (p: {
          temp = p.temp;
          percentage = p.speedPercentage;
        }) fixed;
      };

  configJson = pkgs.writeText "fans-config.json" (builtins.toJSON {
    fans = mapAttrs (_: fanToJson) cfg.fans;
  });

  applyScript = pkgs.writeShellScript "apply-fans" ''
    set -e
    ${pkgs.quadro-ctl}/bin/quadro-ctl fans set --config-file ${configJson}
  '';

  validSensor = sensor:
    sensor != null &&
    ((sensor.source == "hardware" && sensor.index != null && sensor.index >= 1 && sensor.index <= 4)
     || (sensor.source == "virtual" && sensor.index != null && sensor.index >= 1 && sensor.index <= 8)
     || (sensor.source == "flow"));

  # Host hwmon sensor description: read a host temperature and feed it into a
  # QUADRO virtual sensor (so fan curves can reference `virtual` channels).
  hwmonSensorModule = types.submodule {
    options = {
      type = mkOption {
        type = types.enum [ "hwmonByDevicePath" "hwmonName" "hwmonMaxByName" ];
      };

      devicePath = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      name = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      label = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  sensorToShellBlock = name: sensor:
    if sensor.type == "hwmonByDevicePath" then ''
      {
        v_milli=""
        hp=$(ls -d ${sensor.devicePath}/hwmon* 2>/dev/null | head -1) || hp=""
      if [ -n "$hp" ]; then
        v_milli=$(read_temp_labeled "$hp" "${optionalString (sensor.label != null) sensor.label}") || v_milli=""
      fi

        if [ -n "$v_milli" ]; then
          v_c=$(awk -v m="$v_milli" 'BEGIN{printf "%.2f", m/1000}')
          json=$(echo "$json" | jq --arg v "$v_c" '."${name}" = ($v | tonumber)')
        fi
      }
    ''
    else if sensor.type == "hwmonName" then ''
      {
        v_milli=""
        hp=$(hwmon_path_by_name "${sensor.name}") || hp=""
      if [ -n "$hp" ]; then
        v_milli=$(read_temp_labeled "$hp" "${optionalString (sensor.label != null) sensor.label}") || v_milli=""
      fi

        if [ -n "$v_milli" ]; then
          v_c=$(awk -v m="$v_milli" 'BEGIN{printf "%.2f", m/1000}')
          json=$(echo "$json" | jq --arg v "$v_c" '."${name}" = ($v | tonumber)')
        fi
      }
    ''
    else ''
      {
        v_milli=""
        v_milli=$(max_temp_across_hwmons "${sensor.name}") || v_milli=""

        if [ -n "$v_milli" ]; then
          v_c=$(awk -v m="$v_milli" 'BEGIN{printf "%.2f", m/1000}')
          json=$(echo "$json" | jq --arg v "$v_c" '."${name}" = ($v | tonumber)')
        fi
      }
    '';

  feederScript = pkgs.writeShellScript "quadro-sensors-feeder" ''
    set -u
    export PATH=${lib.makeBinPath (with pkgs; [ jq coreutils gnugrep gawk findutils quadro-ctl ])}:$PATH

    readonly INTERVAL=2
    readonly STATE_FILE=/run/quadro-sensors/last.json
    mkdir -p /run/quadro-sensors

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
      ${concatStringsSep "\n" (mapAttrsToList sensorToShellBlock cfg.sensors)}

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
  options.services.fans = {
    enable = mkEnableOption "fan control via quadro-ctl";

    fans = mkOption {
      type = types.attrsOf fanModule;
      default = {};
    };

    sensors = mkOption {
      type = types.attrsOf hwmonSensorModule;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    assertions =
      (map (name: {
        assertion = builtins.elem name fanNames;
        message = "Fan '${name}' is not valid. Must be one of: ${concatStringsSep ", " fanNames}";
      }) (attrNames cfg.fans))
      ++
      (mapAttrsToList (name: fan: {
        assertion = (fan.percentage != null) != (fan.curve != null);
        message = "Fan '${name}' must have exactly one of 'percentage' or 'curve', not both or neither.";
      }) cfg.fans)
      ++
      (mapAttrsToList (name: fan: {
        assertion = fan.curve == null || length fan.curve >= 2;
        message = "Fan '${name}' curve must have at least 2 points.";
      }) cfg.fans)
      ++
      (mapAttrsToList (name: fan: {
        assertion = fan.curve == null || validSensor fan.sensor;
        message = "Fan '${name}' curve requires a valid sensor (hardware 1-4, virtual 1-8, or flow).";
      }) cfg.fans)
      ++
      (mapAttrsToList (name: fan:
        let temps = if fan.curve != null then map (p: p.temp) fan.curve else [];
        in {
          assertion = fan.curve == null ||
            (temps == sort lessThan temps && length (unique temps) == length temps);
          message = "Fan '${name}' curve temps must be strictly ascending.";
        }
      ) cfg.fans);

    systemd.services.fans = {
      description = "Apply fan configuration via quadro-ctl";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = applyScript;
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    systemd.services.quadro-sensors = mkIf (cfg.sensors != {}) {
      description = "Feed QUADRO virtual sensors from host hwmon";
      after = [ "fans.service" ];
      wantedBy = [ "multi-user.target" ];

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
