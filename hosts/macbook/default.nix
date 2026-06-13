{ config, lib, pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = 6;
  system.primaryUser = "danielramos";

  nix.enable = false;

  users.knownUsers = [ "danielramos" ];

  users.users.danielramos = {
    uid = 501;
    gid = 20;
    name = "danielramos";
    home = "/Users/danielramos";
    shell = pkgs.fish;
  };

  environment.shells = [ pkgs.fish ];

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
      "ghostty"
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
