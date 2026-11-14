{ pkgs, ... }:
{
  networking.hostName = "agenthorse";

  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "es_ES.UTF-8";
  console.keyMap = "es";
  services.xserver.xkb.layout = "es";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.getty.autologinUser = "root";

  environment.localBinInPath = true;

  environment.systemPackages = with pkgs; [
    git
    htop
    tmux
    vim
  ];

  system.stateVersion = "26.05";
}
