{
  imports = [
    ./k3s.nix
    ./ssh.nix
    ./samba.nix
    ./smart.nix
    ./cloudflared.nix
    ./dnsmasq.nix
    ./strongswan.nix
    ./network-monitor.nix
    ./ups-watchdog.nix
    ./scan-server.nix
    ./dvd-server.nix
    ./usbmuxd.nix
  ];
}
