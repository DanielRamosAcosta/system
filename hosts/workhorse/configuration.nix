{ pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    hostName = "workhorse";
    networkmanager.enable = true;
  };

  time.timeZone = "Atlantic/Canary";
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

  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    git
    htop
    vim
  ];

  system.stateVersion = "25.11";
}
