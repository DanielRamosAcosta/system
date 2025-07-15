{
  imports = [
    ../shared/configuration.nix
    ../shared/secrets.nix
    ../shared/users.nix
    ../shared/services
    ./disk-config.nix
    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
