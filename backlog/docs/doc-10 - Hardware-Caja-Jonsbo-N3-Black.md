---
id: doc-10
title: "Hardware: Caja Jonsbo N3 Black"
type: other
created_date: '2026-03-29 14:40'
updated_date: '2026-04-15 19:10'
---
# Hardware: Caja Jonsbo N3 Black

Documentación de la caja del NAS.

- Fabricante: Jonsbo
- Modelo: N3 Black
- Web del fabricante: https://www.jonsbo.com/en/products/N3.html
- Ficha de producto detallada: ver doc-9

## Especificaciones

| Spec | Valor |
|---|---|
| Dimensiones | 233mm (W) x 262mm (D) x 298mm (H) |
| Material exterior | Aluminio-magnesio 2.0mm (sandblasting) |
| Material interior | Acero 1mm |
| Peso | 3.9 kg (neto) |
| Form factor placa | Mini-ITX |
| Fuente de alimentación | SFX ≤ 105mm |
| Altura máx. disipador CPU | ≤ 130mm |
| Longitud máx. GPU | ≤ 250mm (alto ≤ 130mm, grosor ≤ 50mm) |
| Slots PCIe | 2 (full-height) |

## Almacenamiento

| Bahía | Tipo | Nota |
|---|---|---|
| 8x 3.5" HDD | Hot-swap frontal | Backplane server-grade con interfaz SAS 10μm gold-plated |
| 1x 2.5" SSD | Fijo | Montaje interno |

## Backplane hot-swap

- Interfaz SAS hot-swap 10μm gold-plated
- Capacitores sólidos para estabilidad de alimentación
- Alimentación: dual D-type + SATA auxiliar
- LEDs indicadores de actividad para los 8 HDDs (conector en panel frontal)
- Estructura pull-out con PCB adaptador por bahía

## Estructura dual

La caja tiene dos compartimentos independientes con canales de refrigeración separados:

- **Compartimento superior (motherboard)**: placa ITX, PSU, slots PCIe
- **Compartimento inferior (HDD)**: 8 bahías 3.5" hot-swap con backplane

Tapa superior removible para facilitar la instalación.

## Mapa de bahías HDD

Ver doc-18 para la configuración actual e histórico de cambios.

## Refrigeración

| Ubicación | Tamaño | Estado |
|---|---|---|
| Compartimento HDD (trasero) | 100x25mm x2 | Incluidos de serie (3-pin). También soporta 90x25mm |
| Compartimento motherboard | 80x25mm x2 | Opcionales |

## I/O frontal

- 1x USB 3.2 Gen 2 Type-C (10 Gbps)
- 1x USB 3.0 (5 Gbps)
- 1x Audio + Mic combo (headset 2-in-1)
- Rejilla frontal desmontable
