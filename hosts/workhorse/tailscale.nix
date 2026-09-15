{ pkgs, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.tailscaled-resume-dns = {
    after = [ "post-resume.target" ];
    wantedBy = [ "post-resume.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart tailscaled.service";
    };
  };
}
