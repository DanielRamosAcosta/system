{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # TODO: volver a "uninstall" cuando el fix de nix-darwin (PR #1789, --force-cleanup)
      # llegue a la rama estable 25.11; hoy solo esta en master. Revertir tras el proximo update.
      cleanup = "none";
    };

    brews = [
      "handbrake"
    ];

    casks = [
      "adobe-acrobat-reader"
      "fuse-t"
      "ghostty"
      "google-chrome"
      "obsidian"
      "orbstack"
      "slack"
      "steam"
      "tailscale-app"
      "telegram"
      "vlc"
    ];
  };
}
