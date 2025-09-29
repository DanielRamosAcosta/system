{ config, lib, pkgs, ... }:

{
  services.liquidctl = {
    enable = true;
    interval = "30s";
    
    fans = [
      {
        name = "fan1";
        percentage = 10;
      }
      {
        name = "fan2";
        percentage = 10;
      }
      {
        name = "fan3";
        percentage = 10;
      }
      {
        name = "fan4";
        percentage = 10;
      }
    ];
  };
}
