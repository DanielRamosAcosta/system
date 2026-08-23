{ pkgs, ... }:
let
  src = pkgs.fetchFromGitHub {
    owner = "vovamod";
    repo = "Plymouth-SteamDeck";
    rev = "03fddb9489783c9f0f88eecb5e163405c5eb460d";
    hash = "sha256-naD0KB0z+rsG/SjDAgxpyjgNkaxCGw2x8lZeB2uvZ80=";
  };
  steamdeckTheme = pkgs.runCommand "plymouth-steamdeck-theme" { } ''
    dir=$out/share/plymouth/themes/steamdeck
    mkdir -p $dir
    cp -r ${src}/images $dir/images
    cp ${src}/steamdeck.script $dir/steamdeck.script
    cat > $dir/steamdeck.plymouth <<EOF
    [Plymouth Theme]
    Name=steamdeck
    Description=SteamDeck boot animation
    ModuleName=script

    [script]
    ImageDir=$dir
    ScriptFile=$dir/steamdeck.script
    EOF
  '';
in
{
  boot.plymouth = {
    enable = true;
    themePackages = [ steamdeckTheme ];
    theme = "steamdeck";
  };
}
