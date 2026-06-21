{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = (with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "vscode-jsonnet";
          publisher = "Grafana";
          version = "0.7.4";
          sha256 = "0g2i4ayxcppdvvn6qn80g2504wwqbms3kvzici1zdnws6x3ahgx3";
        }
      ];
      userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
        "nix.serverSettings".nixd = {
          formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
        };
        "jsonnet.languageServer" = {
          pathToBinary = "${pkgs.jsonnet-language-server}/bin/jsonnet-language-server";
          enableAutoUpdate = false;
          tankaMode = true;
        };
      };
    };
  };
}
