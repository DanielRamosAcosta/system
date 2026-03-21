{
  imports = [
    ./k3s.nix
    ./ssh.nix
    ./samba.nix
    ./smart.nix
    ./fans.nix
    ./cloudflared.nix
    ./dnsmasq.nix
    ./strongswan.nix
    ./network-monitor.nix
    ./ups-watchdog.nix
  ];
}
