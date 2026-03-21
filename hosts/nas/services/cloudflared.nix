{ config, lib, pkgs, ... }:

{
  services.cloudflared = {
    enable = true;
    tunnels = {
      "nas" = {
        credentialsFile = config.age.secrets.nas-tunnel-credentials-json.path;
        ingress = {
          "ssh.danielramos.me" = "ssh://localhost:22";
        };
        default = "http_status:404";
      };
    };
  };
}
