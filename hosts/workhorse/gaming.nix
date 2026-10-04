{ pkgs, ... }:
{
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "dani";
      desktopSession = "gamescope-wayland";
      environment = {
        STEAM_GAMESCOPE_FORCE_HDR_DEFAULT = "1";
        STEAM_GAMESCOPE_FORCE_OUTPUT_TO_HDR10PQ_DEFAULT = "1";
      };
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

  chaotic.mesa-git.enable = true;

  systemd.tmpfiles.rules = [
    "d /home/dani/.local/share/Steam/compatibilitytools.d 0755 dani users - -"
    "L+ /home/dani/.local/share/Steam/compatibilitytools.d/GE-Proton - - - - ${pkgs.proton-ge-bin.steamcompattool}"
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];
}
