{ config, ... }:
{
  # age.secrets.dani-hashed-password.file = "${self}/secrets/dani-hashed-password.age";

  users = {
    mutableUsers = false;

    users = {
      dani = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        # hashedPasswordFile = config.age.secrets.dani-hashed-password.path;
        password = "changeme";
        openssh.authorizedKeys.keys = [
          (builtins.readFile ../../id_dani.pub)
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
