{ config, lib, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    bottom
    btrfs-progs
    cargo
    cmatrix
    dua
    exiftool
    ffmpeg
    gcc
    git
    godeez
    liquidctl
    lm_sensors
    mkvtoolnix
    openssl
    rustc
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
