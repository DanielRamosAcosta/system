{
  imports = [
    ./packages.nix
    ./git.nix
    ./gpg.nix
    ./shell.nix
  ];

  home = {
    username = "dani";
    homeDirectory = "/home/dani";
    stateVersion = "25.11";
    enableNixpkgsReleaseCheck = false;
  };
}
