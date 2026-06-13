{ config, lib, pkgs, ... }:

{
  home.username = "danielramos";
  home.homeDirectory = "/Users/danielramos";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    deno
    gh
    git-lfs
    helix
    himalaya
    nodejs
    (python3.withPackages (ps: [ ps.pymupdf ps.pymupdf4llm ]))
    qrencode
    uv
    unzip
    zip
  ];

  home.sessionVariables = {
    DISABLE_AUTOUPDATER = "1";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat";
      ls = "eza";
      ll = "eza -la";
      la = "eza -a";
      lt = "eza --tree";
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "Dracula";
  };

  programs.eza.enable = true;

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g @dracula-show-fahrenheit false
      run-shell ${pkgs.tmuxPlugins.dracula}/share/tmux-plugins/dracula/dracula.tmux
    '';
  };
}
