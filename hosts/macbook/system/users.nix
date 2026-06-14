{ pkgs, ... }:

{
  system.primaryUser = "danielramos";

  security.pam.services.sudo_local.touchIdAuth = true;

  users = {
    knownUsers = [ "danielramos" ];

    users.danielramos = {
      uid = 501;
      gid = 20;
      name = "danielramos";
      home = "/Users/danielramos";
      shell = pkgs.fish;
    };
  };

  environment.shells = [ pkgs.fish ];

  programs.fish.enable = true;
}
