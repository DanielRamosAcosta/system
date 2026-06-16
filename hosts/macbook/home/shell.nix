{ config, ... }:

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
        if test -r ${config.age.secrets.grafana-self-hosted-token.path}
          set -gx GRAFANA_SELF_HOSTED_TOKEN (cat ${config.age.secrets.grafana-self-hosted-token.path})
        end
        if test -r ${config.age.secrets.context7-api-key.path}
          set -gx CONTEXT7_API_KEY (cat ${config.age.secrets.context7-api-key.path})
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
