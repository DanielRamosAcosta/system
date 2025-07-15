{ config, lib, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    btrfs-progs
    git
    cmatrix
    bottom
  ];

  system.stateVersion = "25.05";
}
