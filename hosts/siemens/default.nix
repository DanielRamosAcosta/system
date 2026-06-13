{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./sway.nix
  ];

  age.secrets.dani-hashed-password.file = ../../secrets/dani-hashed-password.age;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  time.timeZone = "Europe/Madrid";

  console.keyMap = "es";

  stylix.enable = true;
  stylix.autoEnable = false;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
  stylix.targets.console.enable = true;

  services.openssh.enable = true;

  system.stateVersion = "25.11";

  users = {
    mutableUsers = false;

    users.dani = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.fish;
      hashedPasswordFile = config.age.secrets.dani-hashed-password.path;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKq21O6t1Q2QHfp9ypCIeDUqJ0PjauigrMXKKvvVL4I/ dani@mac"
      ];
    };
  };

  programs.fish.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    imagemagick
  ];

  security.sudo.extraRules = [
    {
      users = [ "dani" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
