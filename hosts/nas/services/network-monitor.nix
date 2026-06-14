{ pkgs, ... }:

{
  networking.dhcpcd = {
    persistent = true;
    extraConfig = ''
      timeout 30

      interface enp4s0
      ipv4only
      nolink

      option domain_name_servers, domain_name, domain_search
      option classless_static_routes
      option ntp_servers
    '';
  };
}
