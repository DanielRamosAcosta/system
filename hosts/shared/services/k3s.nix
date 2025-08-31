{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 6443 ];
  networking.firewall.trustedInterfaces = ["cni0" "flannel.1"];

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [];
  };
}

