---
id: NAS-18
title: Crear regla udev para symlink estable del QUADRO hwmon
status: In Progress
assignee: []
created_date: '2026-03-23 08:27'
updated_date: '2026-03-23 08:35'
labels:
  - hardware
  - config
  - nixos
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
El número de hwmon del Aqua Computer QUADRO puede cambiar entre reboots (actualmente hwmon4) dependiendo del orden de carga de drivers. Necesitamos un symlink estable para que otros servicios puedan referenciar el dispositivo sin hardcodear el número.

Crear una regla udev en NixOS que genere un symlink tipo `/dev/quadro-hwmon` que apunte siempre al directorio hwmon correcto del QUADRO. La regla debe matchear por vendor/product ID (`0c70:f00d`) o por el nombre del driver (`aquacomputer_d5next`).

Este symlink será consumido por el módulo `services.quadro-fans` (NAS-19) para configurar curvas de temperatura y PWM manual sin depender del número de hwmon.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Existe una regla udev en la configuración NixOS que crea un symlink estable al hwmon del QUADRO
- [ ] #2 El symlink se crea automáticamente al cargar el driver (boot o recarga del módulo)
- [ ] #3 El symlink apunta correctamente al directorio hwmon cuyo name es 'quadro'
- [ ] #4 El symlink sobrevive reboots y es independiente del número de hwmon asignado
<!-- AC:END -->
