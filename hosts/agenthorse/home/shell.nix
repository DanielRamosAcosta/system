{
  programs = {
    fish = {
      enable = true;
      shellAliases = {
        cat = "bat";
        ls = "eza";
        l = "eza -l";
        ll = "eza -la";
        la = "eza -a";
        lt = "eza --tree";
      };
      shellInit = ''
        fish_add_path "$HOME/.asdf/shims" "$HOME/.opencode/bin"
        if test -r /run/agenix/grafana-self-hosted-token
          set -gx GRAFANA_SELF_HOSTED_TOKEN (cat /run/agenix/grafana-self-hosted-token)
        end
        if test -r /run/agenix/context7-api-key
          set -gx CONTEXT7_API_KEY (cat /run/agenix/context7-api-key)
        end
        if test -d "$HOME/.secrets/environment"
          for f in "$HOME/.secrets/environment"/*
            test -f "$f"; and set -gx (basename "$f") (cat "$f" | string collect)
          end
        end
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
    };

    bat = {
      enable = true;
      config.theme = "Dracula";
    };

    eza.enable = true;

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [ "--cmd cd" ];
    };
  };
}
