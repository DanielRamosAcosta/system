{ config, lib, pkgs, ... }:

{
  systemd.services.network-link-monitor = {
    description = "Monitor and recover from network link failures on enp4s0";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "5s";
      ExecStart = "${pkgs.bash}/bin/bash ${./scripts/network-link-monitor.sh}";
    };
  };

  networking.dhcpcd = {
    persistent = true;
    extraConfig = ''
      timeout 30
      retry 60

      interface enp4s0
      ipv4only

      option domain_name_servers, domain_name, domain_search
      option classless_static_routes
      option ntp_servers
    '';
  };
}
