{ pkgs, lib, ... }:

let
  remote = "nas:/cold-data/sftpgo/data/dani";

  rcloneConf = pkgs.writeText "rclone.conf" ''
    [nas]
    type = sftp
    host = vpn.danielramos.me
    port = 21873
    user = dani
    key_file = /Users/danielramos/.ssh/id_mac
    known_hosts_file = /Users/danielramos/.ssh/known_hosts
    host_key_algorithms = ssh-ed25519
    shell_type = unix
  '';

  nas-mount = pkgs.writeShellScriptBin "nas-mount" ''
    mkdir -p "$HOME/NAS" "$HOME/.cache/rclone"
    exec ${pkgs.rclone}/bin/rclone mount ${remote} "$HOME/NAS" \
      -o backend=fskit \
      --vfs-cache-mode full \
      --vfs-cache-max-size 20G \
      --cache-dir "$HOME/.cache/rclone" \
      --vfs-read-chunk-size 16M \
      --vfs-read-chunk-streams 8 \
      --vfs-read-ahead 128M \
      --buffer-size 32M \
      --dir-cache-time 12h \
      --transfers 8
  '';

  nas-unmount = pkgs.writeShellScriptBin "nas-unmount" ''
    umount "$HOME/NAS" 2>/dev/null || diskutil unmount "$HOME/NAS"
  '';
in
{
  home.packages = [ nas-mount nas-unmount ];

  home.activation.rcloneConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.config/rclone"
    run install -m600 ${rcloneConf} "$HOME/.config/rclone/rclone.conf"
  '';
}
