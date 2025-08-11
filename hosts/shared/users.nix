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
