{ config, lib, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;  

  environment.systemPackages = with pkgs; [
    btrfs-progs
    git
  ];

  system.stateVersion = "25.05";
}
