{ pkgs, ... }:
let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [ opencv4 numpy onnxruntime pillow ]);
in
{
  systemd.services.scan-server = {
    description = "Photo scan web server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pythonEnv "/run/current-system/sw" ];

    environment = {
      LD_LIBRARY_PATH = "/etc/sane-libs";
      SANE_CONFIG_DIR = "/etc/sane-config";
    };

    serviceConfig = {
      ExecStart = "${pythonEnv}/bin/python3 /home/dani/scan_server.py";
      User = "dani";
      Restart = "on-failure";
      RestartSec = 5;
      SupplementaryGroups = [ "scanner" "lp" ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 7777 ];
}
