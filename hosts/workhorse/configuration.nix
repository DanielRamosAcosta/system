{ pkgs, lib, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };

    kernelPackages = pkgs.linuxPackages_latest;

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "udev.log_level=3"
      "rd.udev.log_level=3"
      "vt.global_cursor_default=0"
      "hibernate.compressor=lz4"
    ];
  };

  networking = {
    hostName = "workhorse";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "es_ES.UTF-8";
  console.keyMap = "es";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  hardware.enableRedistributableFirmware = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  services.logind.settings.Login = {
    HandlePowerKey = lib.mkForce "suspend";
    HandlePowerKeyLongPress = "poweroff";
  };

  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    git
    htop
    vim
  ];

  system.stateVersion = "25.11";
}
