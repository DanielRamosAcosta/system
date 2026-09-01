---
id: NAS-32
title: Probar failover de arranque del nas quitando el NVMe primario
status: To Do
assignee: []
created_date: '2026-09-01 19:22'
labels:
  - nas
  - boot
  - resiliencia
dependencies: []
priority: medium
type: task
ordinal: 12000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Se implementó el espejo del ESP en el nas (hosts/nas/boot-esp-mirror.nix): un hook boot.loader.systemd-boot.extraInstallCommands replica /boot (nvme1n1p1, ESP1) al segundo ESP (nvme0n1p1, by-uuid 427E-AE9A) en cada activate, con rsync -a --delete, excluyendo/borrando el random-seed. Verificado que ESP2 queda al día (mismas 319 entradas, 15 kernels, BOOTX64.EFI presente).

Falta la prueba definitiva, que requiere acceso físico: confirmar que la UEFI arranca desde ESP2 cuando el disco primario (nvme1n1) no está. Depende de que el firmware honre el fallback removible EFI/BOOT/BOOTX64.EFI.</description>
<parameter name="acceptanceCriteria">["Con acceso físico al nas, deshabilitar/quitar temporalmente nvme1n1 (o cambiar orden de arranque en la BIOS) y verificar que el sistema arranca desde nvme0n1 (ESP2)", "Comprobar que btrfs monta / degradado con un solo NVMe y el sistema queda operativo", "Si el firmware NO arranca solo del fallback removible, añadir una entrada UEFI explícita para ESP2 (efibootmgr) al módulo boot-esp-mirror.nix", "Volver a conectar nvme1n1 y confirmar que btrfs re-sincroniza el mirror (btrfs balance/scrub si hace falta)"]
<!-- SECTION:DESCRIPTION:END -->
