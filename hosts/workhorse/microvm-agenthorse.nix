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

  networking.nat = {
    enable = true;
    internalIPs = [ "10.0.0.0/24" ];
    externalInterface = "wlp58s0";
  };

  systemd.services.agenthorse-tap-ip = {
    description = "Assign host-side IP to the agenthorse tap";
    requires = [ "microvm-tap-interfaces@agenthorse.service" ];
    after = [ "microvm-tap-interfaces@agenthorse.service" ];
    before = [ "microvm@agenthorse.service" ];
    wantedBy = [ "microvm@agenthorse.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.iproute2}/bin/ip addr replace 10.0.0.1/32 dev vm-agenthorse
      ${pkgs.iproute2}/bin/ip route replace 10.0.0.2/32 dev vm-agenthorse
      ${pkgs.iproute2}/bin/ip link set vm-agenthorse up
    '';
  };

  systemd.services.agenthorse-inhibit-sleep = {
    description = "Inhibit host sleep while the agenthorse VM is running";
    bindsTo = [ "microvm@agenthorse.service" ];
    after = [ "microvm@agenthorse.service" ];
    wantedBy = [ "microvm@agenthorse.service" ];
    serviceConfig.ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=sleep:idle --who=agenthorse --why='work VM running' --mode=block ${pkgs.coreutils}/bin/sleep infinity";
  };
}
