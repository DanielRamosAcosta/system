{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
      userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
        "nix.serverSettings".nixd = {
          formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
        };
      };
    };
  };
}
