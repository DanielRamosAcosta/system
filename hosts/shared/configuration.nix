{ config, lib, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    btrfs-progs
    git
    cmatrix
    bottom
    usbutils
    tree
    tmux
    zip
    unzip
  ];

  system.stateVersion = "25.05";
}
