{
  imports = [
    ../shared/configuration.nix
    ../shared/users.nix
    ../shared/services
    ./disk-config.nix
    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
