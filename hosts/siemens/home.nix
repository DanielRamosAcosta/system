{ config, lib, pkgs, ... }:

let
  mod = "Mod4";
in
{
  home.username = "dani";
  home.homeDirectory = "/home/dani";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    deno
    fresh
    gh
    git-lfs
    google-chrome
    grim
    helix
    himalaya
    nodejs
    obsidian
    (python3.withPackages (ps: [ ps.pymupdf ps.pymupdf4llm ]))
    qrencode
    slurp
    swaylock
    uv
    unzip
    vscode
    zip
    wl-clipboard
  ];

  home.sessionVariables = {
    DISABLE_AUTOUPDATER = "1";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];

  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false;

    config = {
      modifier = mod;
      terminal = "foot";
      menu = "fuzzel";

      input = {
        "type:keyboard" = {
          xkb_layout = "es";
        };
      };

      keybindings = {
        "${mod}+Return" = "exec foot";
        "${mod}+d" = "exec fuzzel";
        "${mod}+Shift+q" = "kill";
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+e" = "exec swaymsg exit";

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";

        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";
        "${mod}+Escape" = "exec swaylock -f -c 282a36";
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";

        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        "${mod}+b" = "splith";
        "${mod}+v" = "splitv";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";
        "${mod}+f" = "fullscreen";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";
        "${mod}+a" = "focus parent";

        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+minus" = "scratchpad show";

        "${mod}+r" = ''mode "resize"'';
      };

      modes = {
        resize = {
          "h" = "resize shrink width 10px";
          "j" = "resize grow height 10px";
          "k" = "resize shrink height 10px";
          "l" = "resize grow width 10px";
          "Left" = "resize shrink width 10px";
          "Down" = "resize grow height 10px";
          "Up" = "resize shrink height 10px";
          "Right" = "resize grow width 10px";
          "Return" = ''mode "default"'';
          "Escape" = ''mode "default"'';
        };
      };

      floating.modifier = mod;

      bars = [{
        position = "top";
        statusCommand = "while date +'%Y-%m-%d %X'; do sleep 1; done";
        colors = {
          statusline = "#ffffff";
          background = "#323232";
          inactiveWorkspace = {
            border = "#32323200";
            background = "#32323200";
            text = "#5c5c5c";
          };
        };
      }];

      assigns = {
        "2" = [
          { class = "Google-chrome"; }
          { app_id = "google-chrome"; }
        ];
      };

      startup = [
        { command = "google-chrome-stable"; }
      ];
    };

    extraConfig = ''
      include /etc/sway/config.d/*
    '';

    extraSessionCommands = ''
      export WLR_RENDERER=pixman
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway
    '';
  };

  programs.foot = {
    enable = true;
    settings = {
      main.font = "monospace:size=10";
      colors = {
        foreground = "f8f8f2";
        background = "282a36";
        regular0 = "21222c";
        regular1 = "ff5555";
        regular2 = "50fa7b";
        regular3 = "f1fa8c";
        regular4 = "bd93f9";
        regular5 = "ff79c6";
        regular6 = "8be9fd";
        regular7 = "f8f8f2";
        bright0 = "6272a4";
        bright1 = "ff6e6e";
        bright2 = "69ff94";
        bright3 = "ffffa5";
        bright4 = "d6acff";
        bright5 = "ff92df";
        bright6 = "a4ffff";
        bright7 = "ffffff";
        selection-foreground = "f8f8f2";
        selection-background = "44475a";
      };
    };
  };

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

  programs.fuzzel.enable = true;
}
