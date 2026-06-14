{ pkgs, ... }:

{
  programs = {
    ghostty = {
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

    tmux = {
      enable = true;
      extraConfig = ''
        set -g @dracula-show-fahrenheit false
        run-shell ${pkgs.tmuxPlugins.dracula}/share/tmux-plugins/dracula/dracula.tmux
      '';
    };
  };
}
