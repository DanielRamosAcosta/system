{ ... }:
{
  boot.initrd.luks.devices.persist = {
    device = "/dev/vda";
    keyFile = "/dev/vdc";
    keyFileSize = 64;
  };

  fileSystems."/persist" = {
    device = "/dev/mapper/persist";
    fsType = "ext4";
  };
}
