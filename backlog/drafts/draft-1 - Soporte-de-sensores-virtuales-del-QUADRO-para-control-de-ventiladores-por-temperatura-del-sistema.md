---
id: DRAFT-1
title: >-
  Soporte de sensores virtuales del QUADRO para control de ventiladores por
  temperatura del sistema
status: Draft
assignee: []
created_date: '2026-03-23 10:31'
labels:
  - hardware
  - driver
  - nixos
dependencies:
  - NAS-19
references:
  - hosts/nas/kernel-modules/aquacomputer-d5next.nix
  - >-
    /Users/danielramos/Documents/repos/others/aquacomputer_d5next-hwmon/aquacomputer_d5next.c
documentation:
  - 'doc-4 - Hardware: Aqua Computer QUADRO - Controlador de ventiladores PWM'
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Permitir que las curvas de ventiladores del QUADRO se gobiernen por temperaturas del sistema (CPU, NVMe, discos SMART) en lugar de solo por los 4 sensores físicos del QUADRO.

## Contexto

El QUADRO tiene 4 sensores físicos de temperatura (temp1-4) y 16 sensores virtuales (temp5-20 en sysfs, etiquetados "Virtual sensor 1-16"). Los sensores virtuales están diseñados para recibir temperaturas inyectadas desde el SO via USB, permitiendo que el firmware del QUADRO ejecute curvas basadas en temperaturas del sistema.

Actualmente el driver out-of-tree `aquacomputer_d5next` expone los sensores virtuales como **solo lectura** (perms `444`). No hay un `store` function para escribir valores. El software de Aqua Computer en Windows sí puede inyectar temperaturas via USB HID directamente.

## Investigación realizada (2026-03-23)

- Sensores virtuales confirmados en sysfs: `temp5_input` a `temp8_input` (label "Virtual sensor 1-4"), perms read-only
- El driver define `QUADRO_NUM_VIRTUAL_SENSORS = 16` y `QUADRO_VIRTUAL_SENSORS_START = 0x3c`
- Los valores se leen del control report con `get_unaligned_be16` pero no hay path de escritura
- `pwmN_auto_channels_temp` acepta bitmask — si se amplía el rango de sensores, las curvas del firmware podrían usar sensores virtuales

## Enfoque propuesto

Contribuir escritura de sensores virtuales al driver out-of-tree (PR a aleksamagicka/aquacomputer_d5next-hwmon):
- Añadir `store` function para `temp_input` en el rango de sensores virtuales
- Escribir via `aqc_set_ctrl_val` al offset `QUADRO_VIRTUAL_SENSORS_START + j * AQC_SENSOR_SIZE`
- Resultado: `echo 45000 > /sys/class/hwmon/hwmonX/temp5_input` inyecta 45°C como sensor virtual 1

Luego en NixOS:
- Crear un servicio/timer que periódicamente lea temperaturas del sistema (coretemp, nvme, smartctl) y las escriba en los sensores virtuales del QUADRO
- Ampliar el campo `sensor` de `services.quadro-fans` para aceptar sensores virtuales (>4)

## Ventaja sobre control PWM directo por daemon

Las curvas se ejecutan en el **firmware del QUADRO** de forma autónoma. Si el daemon de inyección de temperaturas muere, el QUADRO retiene la última temperatura y sigue controlando los fans según la curva. Con control PWM directo, si el daemon muere los fans se quedan al último PWM estático.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 El driver out-of-tree soporta escritura en sensores virtuales via sysfs
- [ ] #2 Un servicio NixOS inyecta periódicamente temperaturas del sistema en los sensores virtuales del QUADRO
- [ ] #3 El campo sensor de services.quadro-fans acepta sensores virtuales además de físicos
- [ ] #4 Las curvas del firmware del QUADRO funcionan correctamente con sensores virtuales
<!-- AC:END -->
