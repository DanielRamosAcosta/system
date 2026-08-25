{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };

    casks = [
      "adobe-acrobat-reader"
      "fuse-t"
      "ghostty"
      "google-chrome"
      "obsidian"
      "orbstack"
      "slack"
      "steam"
      "telegram"
      "vlc"
    ];
  };
}
