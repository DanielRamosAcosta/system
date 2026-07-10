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
      "ghostty"
      "google-chrome"
      "obsidian"
      "orbstack"
      "slack"
      "telegram"
    ];
  };
}
