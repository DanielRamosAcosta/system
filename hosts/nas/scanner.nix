{ pkgs, ... }:
let
  sane-airscan-configured = pkgs.sane-airscan.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      cat > $out/etc/sane.d/airscan.conf << EOF
      [devices]
      "HP MFP M479dw" = https://192.168.1.12/eSCL

      [options]
      discovery = disable
      EOF
    '';
  });
in
{
  hardware.sane = {
    enable = true;
    extraBackends = [ sane-airscan-configured ];
  };

  services.udev.packages = [ sane-airscan-configured ];
}
