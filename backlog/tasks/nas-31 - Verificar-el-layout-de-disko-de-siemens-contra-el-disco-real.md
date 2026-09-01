---
id: NAS-31
title: Verificar el layout de disko de siemens contra el disco real
status: To Do
assignee: []
created_date: '2026-09-01 18:51'
labels:
  - siemens
  - disko
dependencies: []
priority: high
type: task
ordinal: 11000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Se convirtió siemens a disko (hosts/siemens/disko.nix) ASUMIENDO el layout típico BIOS/MBR con el host apagado y sin poder verificar ni hacer dry-activate: /dev/sda tabla msdos con sda1=root ext4 (/) y sda2=swap. hardware-configuration.nix ya no declara fileSystems/swapDevices (los genera disko) y flake.nix importa disko.nixosModules.disko para siemens.

Cuando siemens esté encendido y accesible por SSH hay que confirmar que el layout real coincide, porque si difiere (orden de particiones, partición extendida/lógica, tamaño de swap, etc.) el próximo activate montaría la partición equivocada como / y rompería el arranque.</description>
<parameter name="acceptanceCriteria">["Leer el layout real: ssh siemens 'lsblk -o NAME,SIZE,FSTYPE,PARTTYPE,MOUNTPOINT /dev/sda; sudo fdisk -l /dev/sda'", "Confirmar que sda1 es root ext4 y sda2 es swap (o corregir hosts/siemens/disko.nix con el orden/tamaños reales)", "Ajustar start/end de las particiones en disko.nix a los tamaños reales (ahora son un placeholder: swap 8GiB asumido)", "make dry-activate-siemens y comprobar que fileSystems./ y swapDevices generados apuntan a las particiones correctas sin cambios inesperados", "make activate-siemens sin errores y el sistema arranca correctamente tras un reboot"]
<!-- SECTION:DESCRIPTION:END -->
