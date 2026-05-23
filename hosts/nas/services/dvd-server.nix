{ pkgs, ... }:

let
  dvdServerScript = pkgs.writeText "dvd_server.py" (builtins.readFile ./scripts/dvd_server.py);
in
{
  systemd.services.dvd-server = {
    description = "DVD rescue web server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [
      python3
      ddrescue
      util-linux
      coreutils
      (pkgs.runCommand "sudo-wrapper" {} ''
        mkdir -p $out/bin
        ln -s /run/wrappers/bin/sudo $out/bin/sudo
      '')
    ];

    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 ${dvdServerScript}";
      User = "dani";
      SupplementaryGroups = [ "cdrom" ];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
