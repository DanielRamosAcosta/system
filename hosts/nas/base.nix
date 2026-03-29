{ config, lib, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    bottom
    btrfs-progs
    cargo
    chromaprint
    cmatrix
    dua
    exiftool
    ffmpeg
    gcc
    git
    id3v2
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
