{ config, lib, pkgs, ... }:
{
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "nas";
        "netbios name" = "nas";
        "security" = "user";
        "hosts allow" = "192.168.1. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "alex" = {
        "path" = "/cold-data/sftpgo/data/alex";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "alex";
        "force group" = "users";
        "valid users" = "alex";
      };
      "alex_tm" = {
        "path" = "/cold-data/time-machine/alex";
        "valid users" = "alex";
        "public" = "no";
        "writeable" = "yes";
        "force user" = "alex";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
      "ana" = {
        "path" = "/cold-data/sftpgo/data/ana";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "ana";
        "force group" = "users";
        "valid users" = "ana";
      };
      "gabriel" = {
        "path" = "/cold-data/sftpgo/data/gabriel";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "gabriel";
        "force group" = "users";
        "valid users" = "gabriel";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
}
