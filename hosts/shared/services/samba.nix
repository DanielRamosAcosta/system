{ config, lib, pkgs, ... }:
let
  sambaShare = user: path: {
    "path" = path;
    "browseable" = "yes";
    "read only" = "no";
    "guest ok" = "no";
    "create mask" = "0644";
    "directory mask" = "0755";
    "force user" = user;
    "force group" = "users";
    "valid users" = user;
    "vfs objects" = "recycle";
    "recycle:repository" = ".recycle";
    "recycle:keeptree" = "yes";
    "recycle:versions" = "yes";
    "recycle:touch" = "yes";
    "recycle:touch_mtime" = "yes"; 
    "recycle:maxsize" = "0";
    "recycle:exclude" = "*.tmp, *.temp, ~$*, *.bak, .DS_Store, desktop.ini, Thumbs.db";
    "recycle:exclude_dir" = "tmp, cache, .cache, .recycle";
    "recycle:directory_mode" = "0755";
    "recycle:subdir_mode" = "0755";
  };
in
{
  services.samba = {
    enable = true;
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
        "log level" = "3";
      };
      
      alex = sambaShare "alex" "/cold-data/sftpgo/data/alex";
      ana = sambaShare "ana" "/cold-data/sftpgo/data/ana";
      gabriel = sambaShare "gabriel" "/cold-data/sftpgo/data/gabriel";
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
}
