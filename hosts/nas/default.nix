{
  imports = [
    ../shared/configuration.nix
    ../shared/secrets.nix
    ../shared/users.nix
    ../shared/ups.nix
    ../shared/snapper.nix
    ../shared/services
    ./configuration.nix
    ./hardware-configuration.nix
  ];
}
