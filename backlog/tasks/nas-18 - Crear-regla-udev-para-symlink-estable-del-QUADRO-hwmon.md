---
id: NAS-18
title: Crear regla udev para symlink estable del QUADRO hwmon
status: Done
assignee: []
created_date: '2026-03-23 08:27'
updated_date: '2026-03-23 09:30'
labels:
  - hardware
  - config
  - nixos
  - cancelled
dependencies: []
references:
  - hosts/nas/hardware-configuration.nix
  - hosts/nas/kernel-modules/aquacomputer-d5next.nix
documentation:
  - 'doc-4 - Hardware: Aqua Computer QUADRO - Controlador de ventiladores PWM'
priority: medium
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
**CANCELADA** - No es viable crear un symlink udev estable para hwmon porque los hwmon no tienen device nodes en `/dev/` (viven en sysfs bajo `/sys/class/hwmon/`). La directiva `SYMLINK+=` de udev opera sobre device nodes en devtmpfs, no sobre directorios sysfs.

La solución se absorbe en NAS-19: el servicio de control de ventiladores resolverá el hwmon correcto dinámicamente al arrancar con `grep -l "quadro" /sys/class/hwmon/hwmon*/name | xargs dirname`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Existe una regla udev en la configuración NixOS que crea un symlink estable al hwmon del QUADRO
- [ ] #2 El symlink se crea automáticamente al cargar el driver (boot o recarga del módulo)
- [ ] #3 El symlink apunta correctamente al directorio hwmon cuyo name es 'quadro'
- [ ] #4 El symlink sobrevive reboots y es independiente del número de hwmon asignado
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Cancelada tras investigación. Los hwmon no exponen device nodes en /dev/, solo directorios en sysfs. Udev SYMLINK+= no aplica. La resolución dinámica del hwmon se implementará directamente en NAS-19.
<!-- SECTION:FINAL_SUMMARY:END -->
