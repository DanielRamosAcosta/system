{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.liquidctl;

  # Generate liquidctl command for a single fan
  makeFanCommand = fan:
    if fan.percentage != null then
      # Fixed percentage mode
      "${pkgs.liquidctl}/bin/liquidctl set ${fan.name} speed ${toString fan.percentage}"
    else if fan.curve != null then
      # Curve mode
      let
        curvePoints = concatMapStringsSep " " (point: "${toString point.temp} ${toString point.speed}") fan.curve;
      in
      "${pkgs.liquidctl}/bin/liquidctl set ${fan.name} speed ${curvePoints}"
    else
      throw "Fan ${fan.name} must have either 'percentage' or 'curve' set";

  # Script to apply all fan configurations
  applyFanConfigScript = pkgs.writeShellScript "apply-fan-config" ''
    set -e
    ${concatMapStringsSep "\n" makeFanCommand cfg.fans}
  '';

in
{
  options.services.liquidctl = {
    enable = mkEnableOption "fan control with liquidctl";

    fans = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Fan channel name (e.g., 'fan1', 'fan2', 'fan3', 'fan4')";
            example = "fan1";
          };

          percentage = mkOption {
            type = types.nullOr (types.ints.between 0 100);
            default = null;
            description = "Fixed fan speed percentage (0-100). Mutually exclusive with curve.";
            example = 85;
          };

          curve = mkOption {
            type = types.nullOr (types.listOf (types.submodule {
              options = {
                temp = mkOption {
                  type = types.int;
                  description = "Temperature in degrees Celsius";
                };
                speed = mkOption {
                  type = types.ints.between 0 100;
                  description = "Fan speed percentage (0-100)";
                };
              };
            }));
            default = null;
            description = "Temperature-speed curve points. Mutually exclusive with percentage.";
            example = literalExpression ''
              [
                { temp = 20; speed = 30; }
                { temp = 40; speed = 50; }
                { temp = 60; speed = 100; }
              ]
            '';
          };
        };
      });
      default = [];
      description = "List of fans with either fixed percentage or temperature curves";
    };

    interval = mkOption {
      type = types.str;
      default = "30s";
      description = "How often to reapply fan curves (systemd time format)";
    };
  };

  config = mkIf cfg.enable {
    # Validate that each fan has exactly one of percentage or curve set
    assertions = map (fan: {
      assertion = (fan.percentage != null) != (fan.curve != null);
      message = "Fan '${fan.name}' must have exactly one of 'percentage' or 'curve' set, not both or neither.";
    }) cfg.fans;

    # Ensure liquidctl is available
    environment.systemPackages = [ pkgs.liquidctl ];

    # Systemd service to apply fan curves
    systemd.services.liquidctl = {
      description = "Apply fan curves with liquidctl";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = applyFanConfigScript;
        # Run as root to access USB devices
        User = "root";
      };
    };

    # Timer to periodically reapply curves
    systemd.timers.liquidctl = {
      description = "Timer for fan curve application";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = cfg.interval;
        Unit = "liquidctl.service";
      };
    };
  };
}
