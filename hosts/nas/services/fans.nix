{ config, lib, pkgs, ... }:

{
  services.liquidctl = {
    enable = true;
    interval = "30s";
    
    fans = [
      {
        name = "fan1";
        percentage = 60;
      }
      {
        name = "fan2";
        percentage = 60;
      }
      {
        name = "fan3";
        percentage = 50;
      }
      {
        name = "fan4";
        percentage = 50;
      }
    ];
  };
}
