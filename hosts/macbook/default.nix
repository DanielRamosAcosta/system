{ config, lib, pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = 6;
  system.primaryUser = "danielramos";

  nix.enable = false;

  users.users.danielramos = {
    name = "danielramos";
    home = "/Users/danielramos";
  };

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    git
    imagemagick
  ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    casks = [
      "google-chrome"
      "obsidian"
      "visual-studio-code"
    ];
  };

  system.defaults = {
    dock.autohide = true;
    dock.show-recents = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "Nlsv";
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 15;
    NSGlobalDomain.KeyRepeat = 2;
  };
}
