{ config, pkgs, ... }:
let
  esp = config.boot.loader.efi.efiSysMountPoint;
  mirrorEspUuid = "427E-AE9A";
in
{
  boot.loader.systemd-boot.extraInstallCommands = ''
    (
      set +e
      mirror=/dev/disk/by-uuid/${mirrorEspUuid}
      mnt=$(${pkgs.coreutils}/bin/mktemp -d)
      if ${pkgs.util-linux}/bin/mount "$mirror" "$mnt"; then
        ${pkgs.rsync}/bin/rsync -a --delete --exclude=/loader/random-seed ${esp}/ "$mnt"/
        ${pkgs.coreutils}/bin/rm -f "$mnt"/loader/random-seed
        ${pkgs.util-linux}/bin/umount "$mnt"
      fi
      ${pkgs.coreutils}/bin/rmdir "$mnt"
    ) || true
  '';
}
