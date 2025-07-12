{ config, lib, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;  

  environment.systemPackages = with pkgs; [
    btrfs-progs
  ];

  system.stateVersion = "25.05";
}
