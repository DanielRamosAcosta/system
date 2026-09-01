{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "table";
      format = "msdos";
      partitions = [
        {
          name = "root";
          part-type = "primary";
          fs-type = "ext4";
          bootable = true;
          start = "1MiB";
          end = "-8GiB";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        }
        {
          name = "swap";
          part-type = "primary";
          fs-type = "linux-swap";
          start = "-8GiB";
          end = "100%";
          content = {
            type = "swap";
          };
        }
      ];
    };
  };
}
