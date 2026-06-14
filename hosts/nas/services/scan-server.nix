{ pkgs, ... }:

let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    numpy
    opencv4
    onnxruntime
    pillow
  ]);
in
{
  hardware.sane.enable = true;

  systemd.services.scan-server = {
    description = "Photo scan web server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pythonEnv "/run/current-system/sw" ];

    environment = {
      SANE_CONFIG_DIR = "/etc/sane-config";
      LD_LIBRARY_PATH = "/etc/sane-libs";
    };

    serviceConfig = {
      ExecStart = "${pythonEnv}/bin/python3 /home/dani/scan_server.py";
      User = "dani";
      SupplementaryGroups = [ "scanner" "lp" ];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  networking.firewall.allowedTCPPorts = [ 7777 ];
}
