{ llm-agents, pkgs, ... }:
let
  orca = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.orca;
  port = 6768;
in
{
  environment.systemPackages = [ orca ];

  users.users.dani.linger = true;

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ port ];

  systemd.user.services.orca-serve = {
    description = "Orca headless server";
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${orca}/bin/orca-ide serve --supervise --no-pairing --port ${toString port} --bind 0.0.0.0 --pairing-address 100.118.200.6";
      Environment = [
        "PATH=%h/.local/bin:/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin"
        "NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-bundle.crt"
      ];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
