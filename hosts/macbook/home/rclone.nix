{ pkgs, ... }:

let
  remote = "nas:/cold-data/sftpgo/data/dani";

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

  xdg.configFile."rclone/rclone.conf".text = ''
    [nas]
    type = sftp
    host = vpn.danielramos.me
    port = 21873
    user = dani
    key_file = /Users/danielramos/.ssh/id_mac
    known_hosts_file = /Users/danielramos/.ssh/known_hosts
    shell_type = unix
  '';
}
