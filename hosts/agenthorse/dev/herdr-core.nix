{ pkgs, lib, ... }:
let
  herdr-core = pkgs.stdenv.mkDerivation rec {
    pname = "herdr-core";
    version = "0.1.21";

    src = pkgs.fetchurl {
      url = "https://releases.herdr.dev/core/${version}/herdr-core-linux-x86_64.tar.gz";
      sha256 = "78424755c10a40dde38a0bdb55c20ac19706e9ae05ed68fc2acf1fcff0d941c1";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      bin=$(find . -type f \( -name hc -o -name herdr-core \) -perm -u+x | head -1)
      if [ -z "$bin" ]; then bin=$(find . -maxdepth 2 -type f -perm -u+x | head -1); fi
      install -Dm755 "$bin" $out/bin/herdr-core
      ln -s herdr-core $out/bin/hc
      runHook postInstall
    '';

    meta = {
      description = "herdr-core (hc): terminals for coding agents";
      homepage = "https://github.com/herdrdev/herdr-core";
      license = lib.licenses.asl20;
      platforms = [ "x86_64-linux" ];
      mainProgram = "herdr-core";
    };
  };
in
{
  environment.systemPackages = [ herdr-core ];
}
