{ pkgs, ... }:
{
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "dani";
      desktopSession = "gamescope-wayland";
    };
    devices.steamdeck.enable = false;
  };

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamemode.enable = true;

  security.rtkit.enable = true;

  services.pipewire.wireplumber.extraConfig."51-bluez-aac" = {
    "monitor.bluez.properties" = {
      "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" ];
      "bluez5.enable-sbc-xq" = true;
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.initrd.kernelModules = [ "amdgpu" ];
}
