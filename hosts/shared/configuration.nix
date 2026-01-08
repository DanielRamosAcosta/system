{ config, lib, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    bottom
    btrfs-progs
    cmatrix
    dua
    exiftool
    git
    liquidctl
    lm_sensors
    openssl
    smartmontools
    tcpdump
    tmux
    tree
    unzip
    usbutils
    zip
  ];

  system.stateVersion = "25.05";
}
