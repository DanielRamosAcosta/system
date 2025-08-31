{ config, ... }:
{
  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval  = "1d";
    persistentTimer  = true;

    configs = {
      immich = {
        SUBVOLUME          = "/cold-data/immich";
        TIMELINE_CREATE    = true;
        TIMELINE_CLEANUP   = true;
        ALLOW_USERS        = [ "dani" ];

        TIMELINE_LIMIT_HOURLY = 8;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 6;
        TIMELINE_LIMIT_YEARLY = 0;
      };

      sftpgo = {
        SUBVOLUME          = "/cold-data/sftpgo";
        TIMELINE_CREATE    = true;
        TIMELINE_CLEANUP   = true;
        ALLOW_USERS        = [ "dani" ];

        TIMELINE_LIMIT_HOURLY = 8;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        TIMELINE_LIMIT_MONTHLY = 6;
        TIMELINE_LIMIT_YEARLY = 0;
      };
    };
  };
}
