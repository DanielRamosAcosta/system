{
  swapDevices = [
    { device = "/dev/disk/by-id/nvme-Sabrent_Rocket_4.0_1TB_036C0709011188072823-part1"; }
  ];

  boot = {
    resumeDevice = "/dev/disk/by-id/nvme-Sabrent_Rocket_4.0_1TB_036C0709011188072823-part1";
    kernelParams = [ "hibernate.compressor=lz4" ];
  };
}
