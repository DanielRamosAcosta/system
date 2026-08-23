{ config, ... }:
{
  users = {
    mutableUsers = false;

    users.dani = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "gamemode" "video" "input" ];
      hashedPasswordFile = config.age.secrets.dani-hashed-password.path;
      openssh.authorizedKeys.keys = [
        (builtins.readFile ../../keys/id_dani.pub)
        (builtins.readFile ../../keys/id_dani_work.pub)
      ];
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
