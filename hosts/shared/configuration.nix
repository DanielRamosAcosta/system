{ config, lib, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    bottom
    btrfs-progs
    cmatrix
    dua
    exiftool
    ffmpeg
    git
    godeez
    liquidctl
    lm_sensors
    mkvtoolnix
    openssl
    smartmontools
    strongswan
    tcpdump
    tmux
    tree
    unzip
    usbutils
    util-linux
    zip
  ];

  system.stateVersion = "25.05";
}
