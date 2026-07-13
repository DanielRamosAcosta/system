{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.gdrive-sync;
  enabledUsers = lib.filterAttrs (name: userCfg: userCfg.enable) cfg.users;

  userService =
    name: userCfg:
    let
      localPath = "/cold-data/sftpgo/data/${name}/Crítico";
      remotePath = "gdrive:Crítico";
      localTrash = "/cold-data/sftpgo/data/${name}/.trash/Crítico";
      remoteTrash = "gdrive:Crítico-trash";
    in
    {
      description = "Bidirectional rclone bisync of Crítico for ${name}";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = name;
        StateDirectory = "gdrive-sync-${name}";
        CacheDirectory = "gdrive-sync-${name}";
        RuntimeMaxSec = "50m";

        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [
          localPath
          localTrash
        ];
        PrivateTmp = true;
        ProtectKernelTunables = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        ExecStartPre = pkgs.writeShellScript "gdrive-sync-${name}-seed-config" ''
          if ! ${pkgs.diffutils}/bin/cmp -s ${userCfg.rcloneConfigFile} "$STATE_DIRECTORY/.seed-source"; then
            install -m600 ${userCfg.rcloneConfigFile} "$STATE_DIRECTORY/rclone.conf"
            install -m600 ${userCfg.rcloneConfigFile} "$STATE_DIRECTORY/.seed-source"
          fi
        '';
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.rclone}/bin/rclone bisync"
          localPath
          remotePath
          "--config \${STATE_DIRECTORY}/rclone.conf"
          "--workdir \${CACHE_DIRECTORY}/bisync"
          "--drive-skip-dangling-shortcuts"
          "--conflict-resolve newer"
          "--backup-dir1 ${localTrash}"
          "--backup-dir2 ${remoteTrash}"
          "--check-access"
          "--max-delete 50"
          "--resilient"
          "--recover"
          "--max-lock 2m"
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
      Persistent = true;
      RandomizedDelaySec = "5m";
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

      systemd.tmpfiles.rules = lib.concatMap (name: [
        "d /cold-data/sftpgo/data/${name}/.trash 0700 ${name} users -"
        "d /cold-data/sftpgo/data/${name}/.trash/Crítico 0700 ${name} users -"
      ]) (lib.attrNames enabledUsers);

      systemd.services = lib.mapAttrs' (
        name: userCfg: lib.nameValuePair "gdrive-sync-${name}" (userService name userCfg)
      ) enabledUsers;

      systemd.timers = lib.mapAttrs' (
        name: userCfg: lib.nameValuePair "gdrive-sync-${name}" (userTimer name userCfg)
      ) enabledUsers;
    })
  ];
}
