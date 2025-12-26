{ config, pkgs, ... }:
{

  users = {
    mutableUsers = false;

    users = {
      dani = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.age.secrets.dani-hashed-password.path;
        openssh.authorizedKeys.keys = [
          (builtins.readFile ../../id_dani.pub)
        ];
      };

      alex = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.age.secrets.alex-hashed-password.path;
        openssh.authorizedKeys.keys = [
          (builtins.readFile ../../id_alex.pub)
        ];
      };

      ana.isNormalUser = true;
      gabriel.isNormalUser = true;
      cris.isNormalUser = true;

      git = {
        isSystemUser = true;
        description = "Gitea SSH passthrough user";
        home = "/var/lib/git";
        shell = "/etc/gitea-shell";
        group = "git";
      };
    };

    groups.git = {};
  };

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
