---
id: NAS-16
title: Create @git btrfs subvolume on cold-data
status: Done
assignee: []
created_date: '2026-03-21 21:16'
updated_date: '2026-03-29 13:28'
labels:
  - infrastructure
  - storage
dependencies: []
references:
  - >-
    backlog/tasks/nas-14 -
    Move-postgres-backups-from-SSD-to-cold-data-btrfs-disk.md
  - hosts/nas/hardware-configuration.nix
priority: medium
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Crear un nuevo subvolumen btrfs `@git` en el disco `cold-data` montado en `/cold-data/git`. No hay migración de datos — es un volumen nuevo vacío.

**Basado en NAS-14** y sus lecciones aprendidas.

**Estado actual:**
- `cold-data` = btrfs RAID1 across `sda` + `sdb` (2x 9.1TB HDD)
- Subvolúmenes existentes: @immich, @sftpgo, @gitea, @booklore, @media, @downloads, @postgres-backups
- `/cold-data` no es un mount point — es un directorio en root SSD. Solo subdirs con mounts explícitos van a HDD

**Riesgo principal (de NAS-14):** Si se despliega una config NixOS que referencia un subvolumen que no existe, el sistema no arranca y necesita rescue desde una generación anterior. Por eso se crea el subvolumen ANTES de desplegar.

## Plan de ejecución

### Phase 0: Pre-flight (SSH into NAS) — sin downtime

1. **Verificar espacio en cold-data**
   ```
   sudo btrfs fi usage /cold-data/immich
   ```
   ⚠️ Lección NAS-14: `btrfs subvolume list` sin sudo falla por permisos. Usar sudo siempre.

2. **Verificar que /mnt no está en uso**
   ```
   mountpoint /mnt || echo "free"
   ```

### Phase 1: Crear subvolume (SSH into NAS) — sin downtime

3. **Mount cold-data filesystem root** (subvolid=5 explícito por seguridad)
   ```
   sudo mount -o subvolid=5 /dev/disk/by-label/cold-data /mnt
   ```

4. **Crear subvolume**
   ```
   sudo btrfs subvolume create /mnt/@git
   ```

5. **Verificar que existe**
   ```
   sudo btrfs subvolume list /mnt | grep git
   ```

6. **Unmount**
   ```
   sudo umount /mnt
   ```

### Phase 2: Test mount manual (SSH into NAS) — sin downtime

7. **Crear directorio y montar**
   ```
   sudo mkdir -p /cold-data/git
   sudo mount -o compress=zstd,subvol=@git /dev/disk/by-label/cold-data /cold-data/git
   ```

8. **Verificar que está en HDD, no SSD**
   ```
   df -h /cold-data/git
   ```
   Debe mostrar `/dev/sda` o `/dev/sdb`, NO `/dev/nvme*`.

9. **Si el mount falla → STOP. No continuar con el deploy.**

10. **Unmount** (el deploy de NixOS se encargará de montarlo definitivamente)
    ```
    sudo umount /cold-data/git
    ```

### Phase 3: NixOS config + deploy — sin downtime

11. **Añadir mount entry** en `hosts/nas/hardware-configuration.nix` con `nofail`:
    ```nix
    fileSystems."/cold-data/git" = {
      device = "/dev/disk/by-label/cold-data";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=@git" "nofail" ];
    };
    ```

12. **Dry-activate** para verificar cambios
    ```
    ./scripts/inside-devcontainer.sh just dry-activate
    ```

13. **Deploy**
    ```
    ./scripts/inside-devcontainer.sh just deploy-nas
    ```

14. **Verificar post-deploy** (SSH into NAS)
    ```
    df -h /cold-data/git
    mount | grep git
    systemctl status cold\\x2ddata-git.mount
    ```

### Phase 4: Reboot y verificar — downtime breve (todos los servicios)

15. **Reboot**
    ```
    sudo reboot
    ```

16. **Verificar post-reboot**
    ```
    df -h /cold-data/git
    mount | grep git
    ```

### Phase 5: Quitar nofail — sin downtime

Lección NAS-14: se puede hacer en la misma sesión, no hace falta esperar.

17. **Quitar `nofail`** del mount entry en `hardware-configuration.nix`
18. **Deploy**: `./scripts/inside-devcontainer.sh just deploy-nas`
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 @git subvolume exists on cold-data btrfs filesystem
- [x] #2 Mount entry in hardware-configuration.nix with compress=zstd and subvol=@git
- [x] #3 /cold-data/git is mounted on HDD (not SSD) and survives reboot
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Subvolumen `@git` (ID 15057) creado en cold-data y montado en `/cold-data/git` con `compress=zstd`. Verificado en HDD, sobrevivió reboot, `nofail` eliminado en deploy final. Cero downtime de servicios.
<!-- SECTION:FINAL_SUMMARY:END -->
