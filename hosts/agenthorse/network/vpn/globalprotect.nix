{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gpclient
    gpauth
    openconnect
    (callPackage ./hip.nix { })
  ];

  boot.kernelModules = [ "tun" ];
}
