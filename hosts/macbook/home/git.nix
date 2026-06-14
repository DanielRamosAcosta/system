{ pkgs, ... }:

{
  programs = {
    git = {
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

    gpg.enable = true;
  };

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '';
}
