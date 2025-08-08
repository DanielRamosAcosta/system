{ config, lib, pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    
    initrd = {
      supportedFilesystems = [ "btrfs" ];
      systemd.emergencyAccess = true;
    };
  };
}
