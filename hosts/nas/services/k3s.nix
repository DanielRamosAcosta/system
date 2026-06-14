{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 6443 ];
  networking.firewall.trustedInterfaces = ["cni0" "flannel.1"];
  networking.dhcpcd.denyInterfaces = [ "veth*" "cni*" "flannel*" ];

  services.k3s = {
    enable = true;
    role = "server";
    disable = [ "traefik" ];
    extraFlags = toString [];
  };

}

