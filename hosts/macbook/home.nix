{ config, lib, pkgs, ... }:

{
  home.username = "danielramos";
  home.homeDirectory = "/Users/danielramos";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    deno
    gh
    git-lfs
    gnupg
    pinentry_mac
    helix
    himalaya
    nodejs_26
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

  programs.git = {
    enable = true;
    settings = {
      user.name = "Daniel Ramos";
      user.email = "danielramosacosta1@gmail.com";
      init.defaultBranch = "main";
      gpg.program = "${pkgs.gnupg}/bin/gpg";
    };
    signing = {
      key = "38B726EB6B2B5DF7";
      signByDefault = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.gpg.enable = true;

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
  '';

  programs.fish = {
    enable = true;
    shellAliases = {
      cat = "bat";
      ls = "eza";
      l = "eza -l";
      ll = "eza -la";
      la = "eza -a";
      lt = "eza --tree";
    };
  };

  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
      userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
        "nix.serverSettings".nixd = {
          formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
        };
      };
    };
  };

  programs.ghostty = {
    enable = true;
    package = null;
    enableFishIntegration = true;
    settings = {
      theme = "Dracula";
      font-size = 13;
      cursor-style = "block";
      mouse-hide-while-typing = true;
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

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g @dracula-show-fahrenheit false
      run-shell ${pkgs.tmuxPlugins.dracula}/share/tmux-plugins/dracula/dracula.tmux
    '';
  };
}
