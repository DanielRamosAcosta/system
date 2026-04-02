---
id: NAS-17
title: Documentar componentes del NAS e investigar soporte de hotswapping de HDD
status: Done
assignee: []
created_date: '2026-03-22 22:14'
updated_date: '2026-03-29 18:34'
labels:
  - documentation
  - hardware
dependencies: []
priority: low
ordinal: 62.5
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Crear documentación de los componentes de hardware del NAS (placa base, CPU, RAM, controladora SATA/SAS, fuente, caja, discos, etc.) e investigar si la configuración actual soporta hotswapping de discos duros (tanto a nivel de hardware/controladora como a nivel de sistema operativo/NixOS).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Lista completa de componentes de hardware del NAS documentada
- [ ] #2 Investigación sobre soporte de hotswapping de HDD: hardware (controladora SATA/SAS, backplane/caja) y software (kernel, NixOS)
- [ ] #3 Conclusión clara sobre si el hotswapping es viable y qué pasos serían necesarios para habilitarlo si no lo está
<!-- AC:END -->
