{ pkgs, lib, ... }:

let
  pfAnchor = pkgs.writeText "dev.herdr.ssh" ''
    pass in quick on lo0
    pass in quick inet proto tcp from 100.64.0.0/10 to any port 22
    pass in quick inet6 proto tcp from fd7a:115c:a1e0::/48 to any port 22
    block drop in quick proto tcp to any port 22
  '';

  loadSshFirewall = pkgs.writeShellScript "herdr-ssh-firewall" ''
    set -eu
    tmp=$(/usr/bin/mktemp)
    /usr/bin/grep -v 'dev.herdr.ssh' /etc/pf.conf > "$tmp" || true
    {
      printf '\n'
      printf 'anchor "dev.herdr.ssh"\n'
      printf 'load anchor "dev.herdr.ssh" from "%s"\n' ${pfAnchor}
    } >> "$tmp"
    /sbin/pfctl -E -f "$tmp" 2>/dev/null || /sbin/pfctl -f "$tmp" || true
    /bin/rm -f "$tmp"
  '';
in
{
  users.users.danielramos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJQmTiwVNyPaQFM5ZWGOI+RW/i6uGlqcAC8GC1vyBVJQ herdr-mobile"
  ];

  environment.etc."ssh/sshd_config.d/110-herdr.conf".text = ''
    PasswordAuthentication no
    KbdInteractiveAuthentication no
  '';

  launchd.daemons.herdr-ssh-firewall.serviceConfig = {
    Label = "dev.herdr.ssh-firewall";
    ProgramArguments = [ "${loadSshFirewall}" ];
    RunAtLoad = true;
    StandardErrorPath = "/var/log/herdr-ssh-firewall.log";
    StandardOutPath = "/var/log/herdr-ssh-firewall.log";
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "[herdr] habilitando Remote Login (sshd)" >&2
    /bin/launchctl enable system/com.openssh.sshd || true
    /bin/launchctl bootstrap system /System/Library/LaunchDaemons/ssh.plist 2>/dev/null || true
    echo "[herdr] cargando firewall SSH (pf)" >&2
    ${loadSshFirewall} || true
  '';
}
