{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Daniel Ramos";
        email = "danielramosacosta1@gmail.com";
      };
      init.defaultBranch = "main";
      gpg.program = "${pkgs.gnupg}/bin/gpg";
    };
    signing = {
      key = "38B726EB6B2B5DF7";
      signByDefault = true;
    };
  };
}
