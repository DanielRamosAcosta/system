{ config, ... }:
let
  vendor = "0665";
  product = "5161";
  HID_QUIRK_IGNORE = "0x0004";
in
{
  boot.kernelParams = [
    "usbhid.quirks=0x${vendor}:0x${product}:${HID_QUIRK_IGNORE}"
  ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="${vendor}", ATTRS{idProduct}=="${product}", ATTR{power/control}="on", ATTR{power/autosuspend}="-1", ATTR{power/autosuspend_delay_ms}="-1"
  '';

  power.ups = {
    enable = true;

    ups.salicru = {
      description = "Salicru UPS";
      driver = "nutdrv_qx";
      port = "auto";
      directives = [
        "pollinterval = 10"
        "maxretry = 3"
      ];
    };

    users.monuser = {
      passwordFile = config.age.secrets.dani-hashed-password.path;
      upsmon = "primary";
      actions = [ "SET" "FSD" ];
      instcmds = [ "ALL" ];
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
