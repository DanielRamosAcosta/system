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
    remotePlay.openFirewall = true;
  };

  hardware.steam-hardware.enable = true;

  programs.gamemode.enable = true;

  powerManagement.cpuFreqGovernor = "performance";

  security.rtkit.enable = true;

  services.pipewire.wireplumber.extraConfig."51-bluez-aac" = {
    "monitor.bluez.properties" = {
      "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" ];
      "bluez5.enable-sbc-xq" = true;
    };
    "monitor.bluez.rules" = [
      {
        matches = [ { "node.name" = "~bluez_output.*"; } ];
        actions.update-props."node.force-quantum" = 2048;
      }
    ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.initrd.kernelModules = [ "amdgpu" ];
}
