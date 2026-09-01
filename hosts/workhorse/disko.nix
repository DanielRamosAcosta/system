{
  disko.devices.disk = {
    main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_4TB_S7DPNJ0WA11128M";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };

    swap = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-Sabrent_Rocket_4.0_1TB_036C0709011188072823";
      content = {
        type = "gpt";
        partitions = {
          hibernate = {
            label = "hibernate";
            size = "68G";
            type = "8200";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
        };
      };
    };
  };
}
