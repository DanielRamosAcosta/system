{ lib, ... }:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            type = "EF00";
            size = "512M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          swap = {
            size = "8G";
            content = {
              type = "swap";
            };
          };

          root = {
            size = "256G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };

          cache = {
            size = "100%";
            content = {
              type = "empty";
            };
          };
        };
      };
    };
  };
}
