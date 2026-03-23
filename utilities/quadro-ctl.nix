{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.fans;

  utilities = import ./utilities.nix { inherit lib; };

  fanNames = [ "fan1" "fan2" "fan3" "fan4" ];

  fanModule = types.submodule {
    options = {
      percentage = mkOption {
        type = types.nullOr (types.ints.between 0 100);
        default = null;
      };

      sensor = mkOption {
        type = types.ints.between 1 4;
        default = 1;
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

  fanToJson = fan:
    if fan.percentage != null then {
      mode = "manual";
      percentage = fan.percentage;
    } else {
      mode = "curve";
      sensor = fan.sensor - 1;
      points = map (p: {
        temp = p.temp * 1000;
        percentage = p.speedPercentage;
      }) (utilities.interpolateCurve fan.curve);
    };

  configJson = pkgs.writeText "fans-config.json" (builtins.toJSON {
    fans = mapAttrs (_: fanToJson) cfg.fans;
  });

  applyScript = pkgs.writeShellScript "apply-fans" ''
    set -e
    ${pkgs.quadro-ctl}/bin/quadro-ctl apply --config-file ${configJson}
  '';

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
