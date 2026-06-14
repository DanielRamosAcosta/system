{ config, ... }:
{

  users = {
    mutableUsers = false;

    users = {
      dani = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.age.secrets.dani-hashed-password.path;
        openssh.authorizedKeys.keys = [
          (builtins.readFile ../../keys/id_dani.pub)
          (builtins.readFile ../../keys/id_dani_work.pub)
        ];
      };

      alex = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.age.secrets.alex-hashed-password.path;
        openssh.authorizedKeys.keys = [
          (builtins.readFile ../../keys/id_alex.pub)
        ];
      };

      ana.isNormalUser = true;
      gabriel.isNormalUser = true;
      cris.isNormalUser = true;

    };
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
