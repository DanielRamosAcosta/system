{ self, pkgs, ... }:
let
  runner = self.nixosConfigurations.agenthorse.config.microvm.declaredRunner;
in
{
  microvm.vms.agenthorse = {
    flake = self;
    updateFlake = "git+file:///home/dani/infra/system";
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/microvms/agenthorse/current - - - - ${runner}"
  ];

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5900 5922 ];

  systemd.services.agenthorse-inhibit-sleep = {
    description = "Inhibit host sleep while the agenthorse VM is running";
    bindsTo = [ "microvm@agenthorse.service" ];
    after = [ "microvm@agenthorse.service" ];
    wantedBy = [ "microvm@agenthorse.service" ];
    serviceConfig.ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=sleep:idle --who=agenthorse --why='work VM running' --mode=block ${pkgs.coreutils}/bin/sleep infinity";
  };
}
