{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.fans;

  utilities = import ./utilities.nix { inherit lib; };

  fanNames = [ "fan1" "fan2" "fan3" "fan4" ];

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

in
{
  options.services.fans = {
    enable = mkEnableOption "fan control via quadro-ctl";

    fans = mkOption {
      type = types.attrsOf fanModule;
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
  };
}
