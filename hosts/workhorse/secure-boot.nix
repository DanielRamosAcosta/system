{ lib, pkgs, ... }:
let
  secureBoot = false;
in
{
  environment.systemPackages = [ pkgs.sbctl ];

  boot.loader.systemd-boot.enable = lib.mkForce (!secureBoot);

  boot.lanzaboote = {
    enable = secureBoot;
    pkiBundle = "/var/lib/sbctl";
  };
}
