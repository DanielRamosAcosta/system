{
  networking.useNetworkd = true;

  systemd.network.networks."10-eth" = {
    matchConfig.MACAddress = "02:00:00:00:a6:e0";
    networkConfig.DHCP = "ipv4";
  };
}
