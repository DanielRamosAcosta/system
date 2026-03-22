---
id: doc-2
title: 'Guía: Configurar snapper en un subvolumen btrfs'
type: other
created_date: '2026-03-22 00:13'
---
Guía para añadir snapshots automáticos con snapper a un subvolumen btrfs en cold-data. Basada en la configuración de NAS-16 (@git) y los errores encontrados.

## Requisito previo

El subvolumen btrfs debe estar creado y montado (ver doc-1: "Guía: Crear subvolumen btrfs en cold-data").

## Paso 1: Crear el subvolumen .snapshots (SSH into NAS)

⚠️ **CRÍTICO**: `.snapshots` debe ser un **subvolumen btrfs**, NO un directorio normal. Si se crea como directorio, snapper falla con `IO Error (.snapshots is not a btrfs subvolume)`.

```bash
sudo btrfs subvolume create /cold-data/NOMBRE/.snapshots
```

Verificar:

```bash
sudo btrfs subvolume show /cold-data/NOMBRE/.snapshots
```

**Hacer esto ANTES de desplegar la config de snapper.** Si no, el timer de snapper fallará silenciosamente en la primera ejecución.

## Paso 2: Añadir config en snapper.nix

En `hosts/nas/snapper.nix`, añadir una línea al bloque `configs`:

```nix
configs = {
  # ... configs existentes ...
  NOMBRE = snapshotConfig "/cold-data/NOMBRE";
};
```

La función `snapshotConfig` ya incluye la política de retención estándar:
- 8 snapshots horarios
- 7 diarios
- 4 semanales
- 6 mensuales
- 0 anuales

Timer: cada hora. Cleanup: cada 24h.

## Paso 3: Deploy

```bash
./scripts/inside-devcontainer.sh just deploy-nas
```

## Paso 4: Verificar

```bash
# Crear snapshot manual para verificar que funciona
ssh nas sudo snapper -c NOMBRE create -d "test snapshot"

# Listar snapshots
ssh nas sudo snapper -c NOMBRE list

# Verificar timer de systemd
ssh nas systemctl status snapper-timeline.timer
```

⚠️ **No asumir que funciona** — verificar siempre tras la primera ejecución del timer:

```bash
ssh nas sudo journalctl -u snapper-timeline.service --since "1 hour ago" --no-pager
```

Buscar errores como `IO Error` o `timeline for 'NOMBRE' failed`.

## Lecciones aprendidas (NAS-16)

- `mkdir .snapshots` → falla. Siempre `btrfs subvolume create`.
- Si snapper falla para una config, el servicio entero sale con exit code 1 (afecta a TODAS las configs de esa ejecución, aunque las demás hayan funcionado).
- Crear `.snapshots` ANTES de desplegar la config de snapper evita fallos silenciosos en el primer timer.

## Referencia

- Config actual: `hosts/nas/snapper.nix`
- Subvolúmenes con snapper activo: immich, sftpgo, gitea, booklore, media, git
