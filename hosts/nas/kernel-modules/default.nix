{ config, pkgs, ... }:

let
  kernel = config.boot.kernelPackages.kernel;
in
{
  boot = {
    initrd.availableKernelModules = [ "usb_storage" "usbhid" ];
    kernelModules = [ "it87-custom" "drivetemp" ];
    extraModulePackages = [
      (pkgs.callPackage ./it87.nix { inherit kernel; })
    ];
  };
}
