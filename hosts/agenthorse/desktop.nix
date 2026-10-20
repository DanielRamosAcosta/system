{ pkgs, ... }:
{
  users.users.dani.linger = true;

  security.pam.services.weston-remote-access = {};

  environment.systemPackages = with pkgs; [
    weston
    firefox
  ];

  environment.etc."weston.ini".text = ''
    [core]
    xwayland=true
    idle-time=0

    [shell]
    panel-position=top
    locking=false
    background-image=${pkgs.weston}/share/weston/background.png
    background-type=scale

    [launcher]
    icon=${pkgs.weston}/share/weston/icon_terminal.png
    path=${pkgs.weston}/bin/weston-terminal

    [launcher]
    icon=${pkgs.weston}/share/weston/icon_window.png
    path=${pkgs.firefox}/bin/firefox
  '';

  networking.firewall.allowedTCPPorts = [ 5900 ];

  systemd.services.weston-vnc = {
    description = "Weston VNC headless Wayland desktop";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-user-sessions.service" ];
    serviceConfig = {
      User = "dani";
      PAMName = "login";
      Environment = [ "XDG_RUNTIME_DIR=/run/user/1000" ];
      ExecStart = "${pkgs.weston}/bin/weston --backend=vnc --vnc-tls-cert=/var/lib/weston/rdp-tls.crt --vnc-tls-key=/var/lib/weston/rdp-tls.key --width=1920 --height=1080 --config=/etc/weston.ini";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
