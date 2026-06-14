---
id: NAS-26
title: Diagnóstico negociación SATA errática en backplane Jonsbo N3
status: Done
assignee: []
created_date: '2026-04-15 21:34'
labels:
  - hardware
  - sata
  - backplane
dependencies: []
documentation:
  - doc-18 - Histórico mapa bahías HDD
  - 'doc-19 - ASMedia ASM1164 en CWWK: anatomía de un problema SATA'
  - doc-10 - Hardware Caja Jonsbo N3 Black
  - doc-12 - Hardware HDD Seagate Exos X10 10TB
  - doc-13 - Hardware HDD Seagate Exos 26TB
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Investigación y diagnóstico del problema de negociación SATA donde los discos negocian aleatoriamente a 1.5/3.0 Gb/s en lugar de 6.0 Gb/s a través del backplane del Jonsbo N3 con controladores ASMedia ASM1164.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
## Trabajo realizado

### Instalación de discos nuevos
- Se instalaron 2x Seagate Exos 26TB (ST26000NM000C-3WE103, seriales ZXA0543G y ZXA06CV4) en el NAS junto a los 2x Exos X10 10TB existentes
- Se actualizó doc-13 con datos SMART reales (modelo completo, variante ISE, sector 512e, configuración instalada con seriales, firmware SN02, 295 horas de uso)

### Diagnóstico de velocidad SATA
- Se detectó que los discos negocian aleatoriamente a 1.5/3.0/6.0 Gb/s a través del backplane Jonsbo N3
- Se realizaron 7 configuraciones distintas de bahías (doc-18) variando posiciones, controladores y limpieza de conectores
- Resultados: 75%, 50%, 75%, 25%, 50%, 25%, 100% de discos a 6.0 Gb/s — completamente aleatorio
- Se descartó que el problema sea de un disco, bahía o controlador concreto

### Identificación física de bahías
- Se mapearon los 4 discos a sus bahías físicas mediante lectura con dd y observación de LEDs de actividad
- Se probó standby/wake de discos para identificación por vibración (no funcionó — los Exos mantienen platos girando en standby lógico)
- Se documentó el mapa de bahías en doc-10 con identificadores persistentes (serial, WWN, /dev/disk/by-id/)

### Pruebas de renegociación por software
- Se probó delete + rescan SCSI en caliente (echo 1 > /sys/block/sdX/device/delete + rescan host) — renegoció pero mantuvo 1.5 Gb/s

### Causa raíz identificada (doc-19)
- El ASM1164 anuncia falsamente soporte de Link Power Management (LPM); kernels recientes lo honran, causando inestabilidad
- ASPM en el enlace PCIe puede desestabilizar el controlador
- La cadena de señal (SFF-8643 → cable breakout → backplane pasivo) opera cerca del límite del presupuesto SATA 6G

## Next steps (próximo reinicio si bajan las velocidades)
1. Añadir `libata.force=nolpm` y `pcie_aspm=off` a boot.kernelParams en NixOS
2. Si persiste, añadir `noncq` y `ahci.mobile_lpm_policy=0`
3. Verificar errores CRC via SMART (atributo C7)
4. Verificar estado ASPM y LPM con comandos de diagnóstico de doc-19
5. Como último recurso, forzar 3.0 Gbps con `libata.force=3.0Gbps,nolpm` (impacto nulo para HDDs)
<!-- SECTION:FINAL_SUMMARY:END -->
