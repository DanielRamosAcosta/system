{ config, ... }:
{
  power.ups = {
    enable = true;

    ups.salicru = {
      description = "Salicru UPS";
      driver = "blazer_usb";
      port = "auto";
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
