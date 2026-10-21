{ config, lib, pkgs, ... }:
let
  globalprotect = pkgs.callPackage ../../packages/globalprotect.nix { };
  dir = "/opt/paloaltonetworks/globalprotect";
  systemd = config.systemd.package;
  fhsTools = with pkgs; {
    "/bin/dnsdomainname" = "${nettools}/bin/dnsdomainname";
    "/bin/echo" = "${coreutils}/bin/echo";
    "/bin/egrep" = "${gnugrep}/bin/egrep";
    "/bin/grep" = "${gnugrep}/bin/grep";
    "/bin/loginctl" = "${systemd}/bin/loginctl";
    "/bin/netstat" = "${nettools}/bin/netstat";
    "/bin/ps" = "${procps}/bin/ps";
    "/sbin/ifconfig" = "${nettools}/bin/ifconfig";
    "/sbin/ip" = "${iproute2}/bin/ip";
    "/sbin/ip6tables" = "${iptables}/bin/ip6tables";
    "/sbin/iptables" = "${iptables}/bin/iptables";
    "/sbin/modprobe" = "${kmod}/bin/modprobe";
    "/sbin/resolvconf" = "${systemd}/bin/resolvconf";
    "/sbin/route" = "${nettools}/bin/route";
    "/sbin/runuser" = "${util-linux}/bin/runuser";
    "/usr/bin/grep" = "${gnugrep}/bin/grep";
    "/usr/bin/nslookup" = "${dnsutils}/bin/nslookup";
    "/usr/bin/pgrep" = "${procps}/bin/pgrep";
    "/usr/bin/resolvectl" = "${systemd}/bin/resolvectl";
    "/usr/bin/systemd-resolve" = "${systemd}/bin/resolvectl";
    "/usr/sbin/dmidecode" = "${dmidecode}/bin/dmidecode";
  };
in
{
  programs.nix-ld = {
    enable = true;
    libraries = [ pkgs.stdenv.cc.cc.lib ];
  };

  systemd = {
    tmpfiles.rules = [
      "d ${dir} 0755 root root -"
      "f /etc/iproute2/rt_tables 0644 root root -"
    ] ++ lib.mapAttrsToList (path: target: "L+ ${path} - - - - ${target}") fhsTools;

    services.gpd = {
      description = "GlobalProtect VPN client daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = with pkgs; [
        bash
        coreutils
        gawk
        gnugrep
        gnused
        iproute2
        iptables
        kmod
        net-tools
        procps
        systemd
        util-linux
      ];
      serviceConfig = {
        Type = "simple";
        ExecStartPre = pkgs.writeShellScript "gpd-install" ''
          cp -rf ${globalprotect}/opt/paloaltonetworks/globalprotect/. ${dir}/
          chmod -R u+w ${dir}
          rm -f /run/PanGPS.pid
        '';
        ExecStart = "${dir}/PanGPS";
        Restart = "on-failure";
        RestartSec = 5;
        WorkingDirectory = dir;
      };
    };

    user.services.gpa = {
      description = "GlobalProtect VPN client agent";
      wantedBy = [ "default.target" ];
      path = [ pkgs.xdg-utils ];
      environment.XDG_SESSION_TYPE = "tty";
      serviceConfig = {
        ExecStart = "${dir}/PanGPA start";
        Restart = "on-failure";
        RestartSec = 1;
        WorkingDirectory = dir;
      };
    };
  };

  environment.systemPackages = [
    pkgs.xdg-utils
    (pkgs.writeShellScriptBin "globalprotect" ''exec ${dir}/globalprotect "$@"'')
  ];
}
