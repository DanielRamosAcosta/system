{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      argocd
      deno
      gh
      git-lfs
      gnupg
      jsonnet-bundler
      kubectl
      kubernetes-helm
      kubeseal
      pinentry_mac
      nodejs_26
      (python3.withPackages (ps: [ ps.pymupdf ps.pymupdf4llm ]))
      qrencode
      tanka
      uv
      unzip
      zip
    ];

    sessionVariables = {
      DISABLE_AUTOUPDATER = "1";
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.npm-global/bin"
    ];
  };
}
