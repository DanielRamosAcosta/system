{ ... }:

{
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  nix.enable = false;

  system.stateVersion = 6;
}
