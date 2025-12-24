{ config, lib, pkgs, ... }:
{
  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 53 ];

  services.dnsmasq = {
    enable = true;
    settings = {
      address = "/photos.danielramos.me/192.168.1.200";
      server = [ "8.8.8.8" "1.1.1.1" ];
      listen-address = "127.0.0.1,::1,192.168.1.200";
      cache-size = 1000;
    };
  };
}
