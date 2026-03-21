{ pkgs, ... }:

{
  systemd.timers.ups-watchdog = {
    description = "Run UPS watchdog every 60 seconds";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "60s";
      Unit = "ups-watchdog.service";
    };
  };

  systemd.services.ups-watchdog = {
    description = "Monitor UPS communication and recover from driver failures";
    after = [ "upsd.service" ];

    path = with pkgs; [
      nut
      coreutils
      gnugrep
      gnused
      systemd
      procps
    ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${./scripts/ups-watchdog.sh}";
    };
  };
}
