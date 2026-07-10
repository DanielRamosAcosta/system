{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.gdrive-sync;
  enabledUsers = lib.filterAttrs (name: userCfg: userCfg.enable) cfg.users;

  userService = name: userCfg: {
    description = "Bidirectional rclone bisync of Crítico for ${name}";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = name;
      Environment = "HOME=/home/${name}";
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.rclone}/bin/rclone bisync"
        "/cold-data/sftpgo/data/${name}/Crítico"
        "gdrive:Crítico"
        "--config ${userCfg.rcloneConfigFile}"
        "--conflict-resolve newer"
        "--conflict-loser delete"
        "--max-delete 50"
        "--create-empty-src-dirs"
      ];
    };
  };

  userTimer = name: userCfg: {
    description = "Schedule rclone bisync of Crítico for ${name}";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10min";
      OnUnitActiveSec = userCfg.interval;
      Unit = "gdrive-sync-${name}.service";
    };
  };
in
{
  options.services.gdrive-sync.users = lib.mkOption {
    default = { };
    description = "Per-user bidirectional Google Drive sync of the Crítico directory.";
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "Google Drive sync for this user";
          rcloneConfigFile = lib.mkOption {
            type = lib.types.path;
            description = "Path to the rclone config file containing the gdrive remote.";
          };
          interval = lib.mkOption {
            type = lib.types.str;
            default = "1h";
            description = "How often to run the sync after the last activation.";
          };
        };
      }
    );
  };

  config = lib.mkMerge [
    {
      services.gdrive-sync.users.dani = {
        enable = true;
        rcloneConfigFile = config.age.secrets.dani-rclone-gdrive.path;
      };
    }

    (lib.mkIf (enabledUsers != { }) {
      environment.systemPackages = [ pkgs.rclone ];

      systemd.services = lib.mapAttrs' (
        name: userCfg: lib.nameValuePair "gdrive-sync-${name}" (userService name userCfg)
      ) enabledUsers;

      systemd.timers = lib.mapAttrs' (
        name: userCfg: lib.nameValuePair "gdrive-sync-${name}" (userTimer name userCfg)
      ) enabledUsers;
    })
  ];
}
