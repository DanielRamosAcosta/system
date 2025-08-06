{
  imports = [
    ../shared/configuration.nix
    ../shared/secrets.nix
    ../shared/users.nix
    ../shared/services
    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
