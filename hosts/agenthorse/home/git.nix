{ pkgs, ... }:
let
  # Identidad de trabajo para los repos del directorio de trabajo
  work = {
    user = {
      name = "Daniel Ramos Acosta";
      email = "danielrac@inditex.com";
      signingkey = "C82D471510EC6C12B0ED28A693C50C436F0B63B2";
    };
    commit.gpgsign = true;
    core = {
      autocrlf = "input";
      eol = "lf";
    };
  };
in
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
    includes = [
      { condition = "gitdir:~/Documents/repos/inditex/"; contents = work; }
      { condition = "gitdir:~/inditex/"; contents = work; }
    ];
  };
}
