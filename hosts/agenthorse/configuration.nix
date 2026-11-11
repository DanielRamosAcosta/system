{ pkgs, ... }:
{
  networking.hostName = "agenthorse";

  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "es_ES.UTF-8";
  console.keyMap = "es";
  services.xserver.xkb.layout = "es";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  networking.useNetworkd = true;
  systemd.network.networks."10-eth" = {
    matchConfig.MACAddress = "02:00:00:00:a6:e0";
    address = [ "10.0.0.2/32" ];
    routes = [
      { Destination = "10.0.0.1/32"; GatewayOnLink = true; }
      { Destination = "0.0.0.0/0"; Gateway = "10.0.0.1"; GatewayOnLink = true; }
    ];
    networkConfig.DNS = [ "9.9.9.9" "1.1.1.1" ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.getty.autologinUser = "root";

  environment.systemPackages = with pkgs; [
    git
    htop
    tmux
    vim
  ];

  system.stateVersion = "26.05";
}
