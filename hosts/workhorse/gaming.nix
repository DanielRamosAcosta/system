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

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
