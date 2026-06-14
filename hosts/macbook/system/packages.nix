{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    imagemagick
  ];
}
