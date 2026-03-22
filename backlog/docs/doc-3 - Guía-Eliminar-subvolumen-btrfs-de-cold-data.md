---
id: doc-3
title: 'Guía: Eliminar subvolumen btrfs de cold-data'
type: other
created_date: '2026-03-22 00:44'
---
Guía paso a paso para eliminar un subvolumen btrfs de cold-data que ya no se necesita. Incluye limpieza de snapper, NixOS config y el subvolumen en sí. Basada en la eliminación de @gitea.

## Contexto

Proceso inverso a doc-1 (crear subvolumen) y doc-2 (configurar snapper). Aplica cuando un servicio se ha migrado, eliminado, o ya no necesita almacenamiento en cold-data.

## Riesgo principal

Si se borra el subvolumen btrfs ANTES de quitar la config de NixOS, el sistema **no arranca** en el siguiente reboot (fstab referencia un subvolumen inexistente). Por eso primero se quita la config y se despliega, y DESPUÉS se borran los subvolúmenes.

## Pre-flight

```bash
# Verificar que el subvolumen está vacío o que los datos ya no se necesitan
ssh nas ls -la /cold-data/NOMBRE

# Verificar snapshots activos
ssh nas sudo snapper -c NOMBRE list
```

⚠️ **Si hay datos importantes, migrarlos ANTES de continuar.** Ver doc-1 sección "Variante: con migración de datos".

## Phase 1: Quitar config NixOS + deploy

### 1a. Quitar snapper config

En `hosts/nas/snapper.nix`, eliminar la línea del bloque `configs`:

```nix
configs = {
  # Eliminar esta línea:
  NOMBRE = snapshotConfig "/cold-data/NOMBRE";
};
```

### 1b. Quitar fileSystems

En `hosts/nas/hardware-configuration.nix`, eliminar el bloque entero:

```nix
# Eliminar este bloque:
fileSystems."/cold-data/NOMBRE" = {
  device = "/dev/disk/by-label/cold-data";
  fsType = "btrfs";
  options = [ "compress=zstd" "subvol=@NOMBRE" ];
};
```

### 1c. Deploy

```bash
# Dry-activate para verificar que solo cambian fstab y snapper
./scripts/inside-devcontainer.sh just dry-activate

# Deploy
./scripts/inside-devcontainer.sh just deploy-nas
```

### 1d. Verificar post-deploy

```bash
# El mount ya no debe existir
ssh nas df -h /cold-data/NOMBRE
# Debe mostrar el root filesystem, NO /dev/sda o /dev/sdb

ssh nas systemctl status cold\\x2ddata-NOMBRE.mount
# Debe estar inactive o no encontrado
```

## Phase 2: Limpieza btrfs (SSH into NAS)

### 2a. Borrar snapshots de snapper

```bash
# Si snapper aún tiene snapshots, borrarlos primero
sudo snapper -c NOMBRE delete-all
```

### 2b. Borrar subvolumen .snapshots

```bash
# Montar root del filesystem
sudo mount -o subvolid=5 /dev/disk/by-label/cold-data /mnt

# Verificar subvolúmenes de NOMBRE
sudo btrfs subvolume list /mnt | grep NOMBRE

# Borrar snapshots individuales primero (si quedan)
# Cada snapshot es un subvolumen — btrfs no borra un subvolumen que contiene otros
for snap in $(sudo btrfs subvolume list /mnt | grep "@NOMBRE/.snapshots/.*/snapshot" | awk '{print $NF}'); do
  sudo btrfs subvolume delete /mnt/$snap
done

# Borrar subvolumen .snapshots
sudo btrfs subvolume delete /mnt/@NOMBRE/.snapshots

# Borrar subvolumen principal
sudo btrfs subvolume delete /mnt/@NOMBRE

# Verificar que ya no existe
sudo btrfs subvolume list /mnt | grep NOMBRE

# Desmontar
sudo umount /mnt
```

### 2c. Limpiar mount point

```bash
# Borrar directorio vacío
sudo rmdir /cold-data/NOMBRE
```

## Phase 3: Reboot y verificar

⚠️ El reboot causa downtime global de todos los servicios del NAS.

```bash
ssh nas sudo reboot

# Tras reconexión (~1-2 min), verificar que no hay errores de mount
ssh nas systemctl --failed
ssh nas df -h | grep cold-data
```

## Lecciones aprendidas

- Orden crítico: **primero quitar config NixOS → deploy → luego borrar subvolúmenes**. Nunca al revés.
- btrfs no permite borrar un subvolumen que contiene otros subvolúmenes — borrar de dentro hacia fuera (snapshots → .snapshots → @NOMBRE).
- `snapper delete-all` no borra el subvolumen `.snapshots` en sí, solo los snapshots que contiene.
- Verificar con `df -h` que el mount ya no apunta a HDD antes de borrar el subvolumen.
