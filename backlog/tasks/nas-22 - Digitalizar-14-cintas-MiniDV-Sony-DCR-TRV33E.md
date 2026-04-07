---
id: NAS-22
title: Digitalizar 14 cintas MiniDV (Sony DCR-TRV33E)
status: To Do
assignee: []
created_date: '2026-04-03 16:33'
labels:
  - hardware
  - media
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Digitalizar 14 cintas MiniDV grabadas con una Sony DCR-TRV33E. La cámara tiene puerto i.LINK (FireWire/DV) que permite transferencia digital bit-perfect desde la cinta.

## Hardware necesario

- Tarjeta PCIe FireWire (chipset Texas Instruments, ~15-20€)
- Cable i.LINK 4-pin a 6-pin (~5€)

## Plan de captura

1. Instalar tarjeta PCIe FireWire en el NAS
2. Añadir módulos de kernel FireWire a la configuración NixOS
3. Capturar las 14 cintas con `dvgrab` (formato DV raw)
4. Transcodificar con `ffmpeg` a formato de almacenamiento (H.265 u otro)
5. Organizar archivos en el NAS

## Alternativa (plan B)

Si FireWire no es viable, captura analógica via salida de vídeo compuesto + capturadora USB (con pérdida de calidad por conversión digital→analógico→digital).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Tarjeta PCIe FireWire instalada y reconocida por el NAS
- [ ] #2 Módulos de kernel FireWire configurados en NixOS
- [ ] #3 Las 14 cintas capturadas en formato digital
- [ ] #4 Archivos transcodificados a formato de almacenamiento definitivo
- [ ] #5 Archivos organizados y almacenados en el NAS
<!-- AC:END -->
