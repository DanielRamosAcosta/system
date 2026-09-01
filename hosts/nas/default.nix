{
  imports = [
    ../../utilities/quadro-ctl.nix
    ../../utilities/quadro-sensors.nix
    ./base.nix
    ./secrets.nix
    ./users.nix
    ./ups.nix
    ./snapper.nix
    ./services
    ./configuration.nix
    ./boot-esp-mirror.nix
    ./hardware-configuration.nix
    ./kernel-modules
    ./hardware
    ./storage.nix
  ];
}
