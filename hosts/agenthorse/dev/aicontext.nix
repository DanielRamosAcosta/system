{ aicontext, pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.callPackage ../../../packages/aicontext.nix { src = aicontext; })
  ];
}
