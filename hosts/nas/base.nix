{ config, lib, pkgs, ... }:
{
  time.timeZone = "Atlantic/Canary";

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
    flac
    gcc
    git
    id3v2
    ifuse
    libimobiledevice
    lm_sensors
    mkvtoolnix
    nmap
    openssl
    (python3.withPackages (ps: with ps; [ opencv4 numpy onnxruntime pillow ]))
    rustc
shntool
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

  services.usbmuxd.enable = true;

  networking.dhcpcd.extraConfig = ''
    denyinterfaces eth*
  '';

  system.stateVersion = "25.05";
}
