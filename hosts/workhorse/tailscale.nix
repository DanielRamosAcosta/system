{ pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "restart-tailscaled-on-link-up" ''
        interface="$1"
        action="$2"
        case "$interface" in
          tailscale0|lo|p2p-dev-*) exit 0 ;;
        esac
        ${pkgs.systemd}/bin/systemd-cat -t tailscaled-resume-hook echo "dispatcher: iface=$interface action=$action"
        case "$action" in
          up|dhcp4-change|dhcp6-change)
            ${pkgs.systemd}/bin/systemctl restart tailscaled.service
            ;;
        esac
      '';
    }
  ];
}
