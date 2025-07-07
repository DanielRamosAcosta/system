{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "sym53c8xx" "uhci_hcd" "ehci_pci" "ahci" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  fileSystems."/mnt/data" = {
    device = "UUID=dcb4f9c4-f025-43eb-9a26-c93d770f54b1";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" ];
  };

  fileSystems."/mnt/data/media/library" = {
    device = "UUID=dcb4f9c4-f025-43eb-9a26-c93d770f54b1";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" "subvol=media/library" ];
  };
}
