{ ... }:

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
