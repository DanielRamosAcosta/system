{ config, ... }:
{
  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval  = "1d";
    persistentTimer  = true;

    configs.immich = {
      SUBVOLUME          = "/cold-data/immich";
      TIMELINE_CREATE    = true;
      TIMELINE_CLEANUP   = true;
      ALLOW_USERS        = [ "dani" ];
    };
  };
}
