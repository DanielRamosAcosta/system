{ config, ... }:
{
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0665", ATTRS{idProduct}=="5161", ATTR{power/control}="on", ATTR{power/autosuspend_delay_ms}="0"
  '';

  power.ups = {
    enable = true;

    ups.salicru = {
      description = "Salicru UPS";
      driver = "blazer_usb";
      port = "auto";
      directives = [ "pollinterval = 15" ];
    };

    users.monuser = {
      passwordFile = config.age.secrets.dani-hashed-password.path;
      upsmon = "primary";
    };

    upsd = {
      enable = true;
      listen = [
        {
          address = "127.0.0.1";
          port = 3493;
        }
      ];
    };

    upsmon = {
      enable = true;
      
      monitor.salicru = {
        user = "monuser";
        passwordFile = config.age.secrets.monuser-password.path;
      };
    };
  };
}
