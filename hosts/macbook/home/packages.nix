{ pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      argocd
      cargo
      clippy
      cloudflared
      deno
      gh
      git-lfs
      gnupg
      gping
      jsonnet
      jsonnet-bundler
      kubectl
      kubernetes-helm
      kubeseal
      pinentry_mac
      nodejs_26
      (python3.withPackages (ps: [ ps.pymupdf ps.pymupdf4llm ]))
      qrencode
      rclone
      rust-analyzer
      rustc
      rustfmt
      skopeo
      tanka
      typst
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
      "$HOME/.cargo/bin"
    ];
  };
}
