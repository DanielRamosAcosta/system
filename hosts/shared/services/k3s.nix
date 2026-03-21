{ config, pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 6443 ];
  networking.firewall.trustedInterfaces = ["cni0" "flannel.1"];

  services.k3s = {
    enable = true;
    role = "server";
    disable = [ "traefik" ];
    extraFlags = toString [];
  };

  # Deploy script for generating git kubeconfig
  environment.etc."scripts/generate-git-kubeconfig.sh" = {
    source = pkgs.substitute {
      src = ./scripts/generate-git-kubeconfig.sh;
      substitutions = [
        "--replace" "#!/@/bin/bash@" "#!${pkgs.bash}/bin/bash"
        "--replace" "@kubectl@" "${pkgs.kubectl}/bin/kubectl"
      ];
    };
    mode = "0755";
  };

  # Systemd service to generate git kubeconfig
  systemd.services.generate-git-kubeconfig = {
    description = "Generate kubeconfig for Gitea git user from ServiceAccount token";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/etc/scripts/generate-git-kubeconfig.sh";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Systemd timer to run the service every 24 hours
  systemd.timers.generate-git-kubeconfig = {
    description = "Run generate-git-kubeconfig service every 24 hours";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "24h";
      Unit = "generate-git-kubeconfig.service";
    };
  };

  # Ensure directory exists and has correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/git/.kube 0700 git git -"
  ];
}

