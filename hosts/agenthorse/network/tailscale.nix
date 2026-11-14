{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [ "--accept-dns=false" ];
  };

  systemd.network.networks."10-eth" = {
    routes = [
      {
        Destination = "0.0.0.0/0";
        Gateway = "_dhcp4";
        Table = 1000;
      }
    ];
    routingPolicyRules = [
      {
        FirewallMark = "0x80000/0xff0000";
        Table = 1000;
        Priority = 5205;
      }
    ];
  };
}
