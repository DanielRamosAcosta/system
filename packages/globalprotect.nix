{ lib, stdenvNoCC, requireFile, dpkg }:

stdenvNoCC.mkDerivation {
  pname = "globalprotect";
  version = "6.2.1.1-276";

  src = requireFile {
    name = "GlobalProtect_focal_deb-6.2.1.1-276.deb";
    sha256 = "d5f900db9a715c7cecc40c0c8bdb42ad5a7a97c6fcf406770a6367d0bb28cb40";
    message = ''
      Download the GlobalProtect Linux client from your VPN portal, extract
      GlobalProtect_focal_deb-6.2.1.1-276.deb and add it to the store with:

        nix-store --add-fixed sha256 GlobalProtect_focal_deb-6.2.1.1-276.deb
    '';
  };

  nativeBuildInputs = [ dpkg ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p $out
    cp -a opt usr $out/
  '';

  dontFixup = true;

  meta = {
    description = "Palo Alto Networks GlobalProtect VPN client";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
