{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gpclient
    gpauth
    openconnect
  ];

  boot.kernelModules = [ "tun" ];
}
