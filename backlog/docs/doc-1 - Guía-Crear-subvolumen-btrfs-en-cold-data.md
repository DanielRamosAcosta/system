---
id: doc-1
title: 'Guía: Crear subvolumen btrfs en cold-data'
type: other
created_date: '2026-03-21 21:32'
---
Guía paso a paso para crear un nuevo subvolumen btrfs en el disco `cold-data` y montarlo en `/cold-data/<nombre>`. Basada en NAS-14 (migración postgres-backups) y NAS-16 (creación de @git).

## Contexto

- `cold-data` = btrfs RAID1 across `sda` + `sdb` (2x 9.1TB HDD)
- `/cold-data` NO es un mount point — es un directorio en el root SSD. Solo subdirs con mounts explícitos van a HDD; el resto cae al SSD
- `by-label` funciona bien para btrfs multi-device
- Default subvolume es ID 5 (FS_TREE)

## Riesgo principal

Si se despliega una config NixOS que referencia un subvolumen que no existe, el sistema **no arranca** y necesita rescue desde una generación anterior. Por eso el subvolumen se crea y se verifica ANTES de desplegar.

## Lecciones aprendidas (NAS-14 / NAS-16)

- `btrfs subvolume list` sin `sudo` falla por permisos — usar sudo siempre con comandos btrfs
- Usar `subvolid=5` explícito al montar el root del filesystem (no confiar en el default)
- `nofail` como red de seguridad en el primer deploy — se puede quitar en la misma sesión tras verificar reboot
- El `grep` de `mount | grep nombre` puede fallar por formato — `df -h /cold-data/<nombre>` es más fiable para verificar
- Verificar que el device es `/dev/sda` o `/dev/sdb` (HDD), NO `/dev/nvme*` (SSD)

## Procedimiento

### Phase 0: Pre-flight (SSH into NAS)

```bash
# Verificar espacio en cold-data
sudo btrfs fi usage /cold-data/immich

# Verificar que /mnt no está en uso
mountpoint /mnt || echo "free"
```

### Phase 1: Crear subvolume (SSH into NAS)

```bash
# Montar root del filesystem
sudo mount -o subvolid=5 /dev/disk/by-label/cold-data /mnt

# Crear subvolume (reemplazar NOMBRE)
sudo btrfs subvolume create /mnt/@NOMBRE

# Verificar
sudo btrfs subvolume list /mnt | grep NOMBRE

# Desmontar
sudo umount /mnt
```

### Phase 2: Test mount manual (SSH into NAS)

```bash
# Montar en path final
sudo mkdir -p /cold-data/NOMBRE
sudo mount -o compress=zstd,subvol=@NOMBRE /dev/disk/by-label/cold-data /cold-data/NOMBRE

# Verificar que está en HDD (debe mostrar /dev/sda o /dev/sdb, NO /dev/nvme*)
df -h /cold-data/NOMBRE
```

**Si el mount falla → STOP. No continuar con el deploy.**

```bash
# Desmontar (NixOS se encargará de montarlo definitivamente)
sudo umount /cold-data/NOMBRE
```

### Phase 3: NixOS config + deploy

Añadir en `hosts/nas/hardware-configuration.nix` (con `nofail` temporal):

```nix
fileSystems."/cold-data/NOMBRE" = {
  device = "/dev/disk/by-label/cold-data";
  fsType = "btrfs";
  options = [ "compress=zstd" "subvol=@NOMBRE" "nofail" ];
};
```

```bash
# Dry-activate para verificar que solo cambia fstab
./scripts/inside-devcontainer.sh just dry-activate

# Deploy
./scripts/inside-devcontainer.sh just deploy-nas

# Verificar post-deploy (SSH into NAS)
df -h /cold-data/NOMBRE
systemctl status cold\\x2ddata-NOMBRE.mount
```

### Phase 4: Reboot y verificar

⚠️ El reboot causa downtime global de todos los servicios del NAS.

```bash
# SSH into NAS
sudo reboot

# Tras reconexión (~1-2 min), verificar
df -h /cold-data/NOMBRE
```

### Phase 5: Quitar nofail

Quitar `"nofail"` de la lista de options en `hardware-configuration.nix` y redesplegar:

```bash
./scripts/inside-devcontainer.sh just deploy-nas
```

## Variante: con migración de datos

Si además hay que migrar datos existentes, ver NAS-14 que añade:

- Pre-sync con rsync antes de parar servicios (reduce downtime de horas a segundos)
- Parada ordenada de servicios k8s (consumidores → productor)
- Desactivar ArgoCD auto-sync (`argocd app set --sync-policy none --self-heal=false --auto-prune=false`)
- Delta sync en frío + verificación
- Restaurar servicios (productor → consumidores)
- Restaurar ArgoCD sync respetando policy original de cada app

Referencia: `backlog/tasks/nas-14 - Move-postgres-backups-from-SSD-to-cold-data-btrfs-disk.md`
