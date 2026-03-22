{ config, pkgs, ... }:

{
  boot = {
    initrd.availableKernelModules = [ "usb_storage" "usbhid" ];
    kernelModules = [ "it87-custom" ];
    extraModulePackages = [ (pkgs.callPackage ./it87.nix { kernel = config.boot.kernelPackages.kernel; }) ];
  };
}
