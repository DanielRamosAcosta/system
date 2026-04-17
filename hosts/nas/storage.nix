{ ... }:

{
  fileSystems."/cold-data/immich" = {
    device = "/dev/disk/by-label/cold-data";
    fsType = "btrfs";
    options = [ "compress=zstd" "subvol=@immich" ];
  };

  fileSystems."/cold-data/sftpgo" = {
    device = "/dev/disk/by-label/cold-data";
    fsType = "btrfs";
    options = [ "compress=zstd" "subvol=@sftpgo" ];
  };

  fileSystems."/cold-data/booklore" = {
    device = "/dev/disk/by-label/cold-data";
    fsType = "btrfs";
    options = [ "compress=zstd" "subvol=@booklore" ];
  };

  fileSystems."/cold-data/media" = {
    device = "/dev/disk/by-label/cold-data";
    fsType = "btrfs";
    options = [ "compress=zstd" "subvol=@media" ];
  };

  fileSystems."/cold-data/downloads" = {
    device = "/dev/disk/by-label/cold-data";
    fsType = "btrfs";
    options = [ "compress=zstd" "subvol=@downloads" ];
  };

  fileSystems."/cold-data/postgres-backups" = {
    device = "/dev/disk/by-label/cold-data";
    fsType = "btrfs";
    options = [ "compress=zstd" "subvol=@postgres-backups" ];
  };

  fileSystems."/cold-data/git" = {
    device = "/dev/disk/by-label/cold-data";
    fsType = "btrfs";
    options = [ "compress=zstd" "subvol=@git" ];
  };

  fileSystems."/cold-data/contabilidad" = {
    device = "/dev/disk/by-label/cold-data";
    fsType = "btrfs";
    options = [ "compress=zstd" "subvol=@contabilidad" ];
  };
}
