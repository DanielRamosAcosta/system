{ pkgs, ... }:
{
  programs.fish.enable = true;
  programs.starship.enable = true;

  programs.fish.interactiveShellInit = ''
    fish_add_path "$HOME/.asdf/shims" "$HOME/.opencode/bin"
    for f in (find "$HOME/.secrets/environment" -maxdepth 1 -type f 2>/dev/null)
      set -gx (basename "$f") (cat "$f" | string collect)
    end
  '';

  environment.interactiveShellInit = ''
    export PATH="''${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$HOME/.opencode/bin:$PATH"
    if [ -d "$HOME/.secrets/environment" ]; then
      for f in "$HOME/.secrets/environment"/*; do
        [ -f "$f" ] && export "$(basename "$f")=$(cat "$f")"
      done
    fi
  '';

  environment.systemPackages = with pkgs; [
    eza
    bat
    gh
    jira-cli-go
    snowflake-cli
    asdf-vm
    jq
    unzip
    gnupg
  ];
}
