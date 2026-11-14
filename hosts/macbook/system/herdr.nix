{ herdr, pkgs, ... }:
{
  environment.systemPackages = [
    herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
