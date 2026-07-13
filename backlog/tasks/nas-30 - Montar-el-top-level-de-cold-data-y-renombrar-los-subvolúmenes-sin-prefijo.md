---
id: NAS-30
title: Montar el top-level de cold-data y renombrar los subvolúmenes sin prefijo @
status: To Do
assignee: []
created_date: '2026-07-12 16:03'
labels:
  - infrastructure
  - nix
  - btrfs
  - storage
dependencies: []
references:
  - hosts/nas/storage.nix
  - hosts/nas/hardware-configuration.nix
priority: medium
ordinal: 8000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## 📌 TLDR

Montar el top-level (`subvolid=5`) del disco `cold-data` en `/cold-data` para que sea el propio disco HDD y no un directorio del SSD raíz. Los subvolúmenes pasan a ser directorios reales dentro del disco, y se renombran para quitarles el prefijo `@` (p. ej. `@immich` → `immich`), quedando accesibles en `/cold-data/immich`, `/cold-data/media`, etc.

## 🎯 Contexto funcional

Hoy cada subvolumen del disco `cold-data` se monta individualmente en su punto exacto (`/cold-data/immich`, `/cold-data/media`, `/cold-data/git`…). El directorio `/cold-data` a secas **no** es el disco: es un directorio dentro del filesystem raíz, que está en el SSD (`nvme0n1p2`, subvol `@` de `nixroot`).

Consecuencia (verificada en vivo): `sudo mkdir /cold-data/foo` crea el directorio en el **SSD**, no en el HDD, aunque parezca que está "dentro del disco de datos". Es una trampa ergonómica: cualquier cosa que se cree como vecina de un subvolumen ocupa espacio del SSD sin avisar.

Comprobación realizada en el NAS:
- `/` → device 29 → `nvme0n1p2` (SSD)
- `/cold-data` → device 29 (mismo que `/`, o sea SSD)
- `/cold-data/media` → device 55 → `/dev/sda` (HDD)
- `sudo mkdir /cold-data/foo` → device 29, `df` reporta `/dev/nvme0n1p2` montado en `/` (SSD)

El objetivo es eliminar esta trampa: que `/cold-data` sea el disco HDD real y que crear cualquier directorio ahí caiga en el HDD.

## ⚙️ Contexto técnico

Enfoque elegido (opción 2, montar el top-level):
- Montar el top-level del disco `cold-data` (`subvolid=5`, o sin opción `subvol`) en `/cold-data` con `compress=zstd`.
- Los subvolúmenes actuales (`@immich`, `@sftpgo`, `@booklore`, `@media`, `@downloads`, `@postgres-backups`, `@git`, `@contabilidad`) aparecerían como `/cold-data/@immich`, etc. con el prefijo `@`. Para evitarlo, **renombrar cada subvolumen quitando el prefijo `@`** (`btrfs`/`mv` a nivel de top-level) para que queden como `/cold-data/immich`, `/cold-data/media`, etc.
- Revisar y ajustar `hosts/nas/storage.nix`: el montaje individual por subvolumen deja de ser necesario (o se replantea) al montar el top-level. Confirmar que las rutas que consumen los servicios (immich, sftpgo, booklore, media, downloads, postgres-backups, git, contabilidad) siguen siendo `/cold-data/<nombre>`.
- Mantener `compress=zstd` en todo el árbol tras el cambio.
- Cuidado con datos activos: coordinar parada de servicios que escriban en el disco durante el renombrado para evitar inconsistencias.
- Validar con `make dry-activate-nas` antes y `make activate-nas` después; comprobar montajes con `findmnt` y que un `mkdir /cold-data/foo` cae ya en el HDD (device de `/dev/sda`).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 El top-level del disco cold-data (subvolid=5) queda montado en /cold-data, de modo que mkdir /cold-data/foo cae en el HDD y no en el SSD
- [ ] #2 Todos los subvolúmenes existentes (immich, sftpgo, booklore, media, downloads, postgres-backups, git, contabilidad) se renombran quitando el prefijo @ y quedan accesibles en /cold-data/<nombre>
- [ ] #3 Los servicios que consumen esos subvolúmenes siguen apuntando a rutas correctas (/cold-data/<nombre>) tras la migración
- [ ] #4 No hay pérdida de datos ni de compresión (compress=zstd) en ningún subvolumen tras el cambio
- [ ] #5 El NAS arranca y monta correctamente con la nueva estructura (make activate-nas sin errores) y findmnt confirma que /cold-data es /dev/sda
<!-- AC:END -->
