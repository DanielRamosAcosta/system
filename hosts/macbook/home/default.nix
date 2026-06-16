{
  imports = [
    ./packages.nix
    ./secrets.nix
    ./git.nix
    ./shell.nix
    ./terminal.nix
    ./editors.nix
  ];

  home = {
    username = "danielramos";
    homeDirectory = "/Users/danielramos";
    stateVersion = "25.11";
  };
}
