---
id: NAS-21
title: Añadir discos Exos X26 26TB al pool cold-data
status: Done
assignee: []
created_date: '2026-04-03 00:04'
labels:
  - hardware
  - storage
  - btrfs
dependencies: []
references:
  - hosts/nas/storage.nix
  - hosts/nas/hardware-configuration.nix
  - hosts/nas/snapper.nix
  - docs/NAS DIY.typ
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Añadir los dos nuevos discos Seagate Exos X26 de 26TB (sdb y sdd) al pool btrfs RAID 1 `cold-data`, que actualmente funciona con dos Exos X10 de 10TB (sda y sdc) al 78.5% de capacidad.

Estado actual:
- Pool `cold-data`: 2x Exos X10 10TB en RAID 1, 7.14 TiB usados de 9.10 TiB
- Discos nuevos: sdb (ZXA06CV4) y sdd (ZXA0543G), 23.6 TiB cada uno, sin filesystem
- Los discos ya están pinchados en caliente y detectados por el kernel

Decisiones:
- Mantener los 4 discos (no retirar los de 10TB por ahora, quizás en un par de años). Los Exos X10 tienen ~1 año de uso, SMART monitoring activo con alertas
- Usar /dev/disk/by-id/ para los device add
- Lanzar scrub completo antes de empezar
- Balance entero de golpe (sin --limit)
- Servicios K3s corriendo durante el balance. Ejecución a la 1am con uso mínimo, la degradación de I/O es despreciable. Escalar pods a 0 introduce más riesgo (pods que no levantan, volúmenes que no montan) que beneficio
- Snapper sigue corriendo durante el balance. Los snapshots btrfs son CoW y capturan estado lógico, no distribución física de chunks
- No se necesitan cambios en NixOS. storage.nix monta por label `cold-data`, no por device-id. Snapper apunta a subvolúmenes, no a discos. El paso 6 es solo verificación
- No hay backup externo ni espacio para hacerlo. Riesgo mitigado por: RAID 1 (datos duplicados), UPS con 45 min de autonomía y shutdown limpio probado en producción, y btrfs CoW (un shutdown sucio no corrompe el filesystem). El balance es resumible si se interrumpe

Con 4 discos en RAID 1 (2x10TB + 2x26TB), la capacidad útil será ~32 TiB. btrfs RAID 1 duplica cada chunk en 2 de los 4 discos: los 10TB aportan ~10 TiB útiles y los 26TB ~23.6 TiB útiles cuando los pequeños se llenen.

Dispositivos por ID:
- sdb → /dev/disk/by-id/ata-ST26000NM000C-3WE103_ZXA06CV4
- sdd → /dev/disk/by-id/ata-ST26000NM000C-3WE103_ZXA0543G

## Plan de ejecución

### Paso 1: Verificar salud del pool actual y lanzar scrub
```bash
sudo btrfs device stats /cold-data/git
sudo btrfs scrub start /cold-data/git
sudo btrfs scrub status /cold-data/git
```
**Feedback:** contadores de error a 0 en stats. Esperar a que el scrub termine sin errores antes de continuar.

### Paso 2: Verificar salud de los discos nuevos (SMART)
```bash
sudo smartctl -a /dev/disk/by-id/ata-ST26000NM000C-3WE103_ZXA06CV4
sudo smartctl -a /dev/disk/by-id/ata-ST26000NM000C-3WE103_ZXA0543G
```
**Feedback:** SMART overall-health "PASSED", 0 sectores reasignados, 0 errores pendientes, temperatura normal.

### Paso 3: Añadir los dos discos nuevos al pool
```bash
sudo btrfs device add /dev/disk/by-id/ata-ST26000NM000C-3WE103_ZXA06CV4 /cold-data/git
sudo btrfs filesystem show cold-data
```
Verificar que aparecen 3 dispositivos antes de continuar. Si falla, no añadir el segundo.
```bash
sudo btrfs device add /dev/disk/by-id/ata-ST26000NM000C-3WE103_ZXA0543G /cold-data/git
sudo btrfs filesystem show cold-data
```
**Feedback:** Deben aparecer 4 dispositivos, ~55 TiB raw total.

Nota: cualquier mount point del filesystem sirve para estos comandos (`/cold-data/git`, `/cold-data/immich`, etc.) — todos operan sobre el mismo btrfs subyacente.

### Paso 4: Rebalancear datos en RAID 1 sobre los 4 discos
```bash
sudo btrfs balance start -dconvert=raid1 -mconvert=raid1 /cold-data/git
```
Operación larga (~horas con 7 TiB). Los datos siguen accesibles durante el proceso.

**Feedback durante el balance:**
```bash
sudo btrfs balance status /cold-data/git
```

**Feedback al terminar:**
```bash
sudo btrfs device usage /cold-data/git
```
Los 4 discos deben tener datos asignados.

### Paso 5: Verificar integridad post-balance
```bash
sudo btrfs device stats /cold-data/git
sudo btrfs scrub start /cold-data/git
sudo btrfs scrub status /cold-data/git
```
**Feedback:** 0 errores en stats, scrub completo sin errores.

### Paso 6: Actualizar configuración NixOS
- Verificar que `storage.nix` sigue funcionando (usa label `cold-data`, no debería cambiar)
- Verificar snapper
- Hacer deploy si hay cambios necesarios

### Paso 7: Verificación final
```bash
sudo btrfs filesystem show cold-data
sudo btrfs filesystem df /cold-data/git
ls /cold-data/immich /cold-data/sftpgo /cold-data/media /cold-data/git /cold-data/booklore /cold-data/downloads /cold-data/postgres-backups
```
**Feedback:** todos los subvolúmenes accesibles, ~32 TiB de capacidad útil, servicios funcionando.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Los 4 discos forman parte del pool cold-data en RAID 1
- [x] #2 Los datos existentes están íntegros y accesibles
- [x] #3 La configuración NixOS (storage.nix, hardware-configuration.nix) refleja el nuevo estado
- [x] #4 Snapper sigue funcionando correctamente con los snapshots
- [x] #5 El pool tiene ~32 TiB de capacidad útil (4 discos en RAID 1)
<!-- AC:END -->
