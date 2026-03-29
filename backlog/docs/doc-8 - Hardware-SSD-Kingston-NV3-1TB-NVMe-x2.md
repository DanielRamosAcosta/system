---
id: doc-8
title: "Hardware: SSD Kingston NV3 1TB NVMe (x2)"
type: other
created_date: '2026-03-29 14:25'
updated_date: '2026-03-29 14:25'
---
# Hardware: SSD Kingston NV3 1TB NVMe (x2)

Documentación de los dos SSDs NVMe instalados en el NAS.

- Fabricante: Kingston
- Modelo: NV3 (SNV3S/1000G)
- Cantidad: 2 unidades
- Ficha del fabricante: https://www.kingston.com/es/ssd/nv3-nvme-pcie-ssd

## Especificaciones del fabricante

| Spec | Valor |
|---|---|
| Capacidad | 1 TB (931.5 GB formateado) |
| Form factor | M.2 2280 (22x80mm) |
| Interfaz | PCIe 4.0 x4 NVMe |
| Controlador | Silicon Motion SM2268XG (DRAM-less, HMB) |
| NAND | 3D QLC |
| Lectura secuencial | hasta 6000 MB/s |
| Escritura secuencial | hasta 4000 MB/s |
| TBW (endurance) | 320 TB |
| MTBF | 2.000.000 horas |
| Temp. operación | 0°C ~ +70°C |
| Temp. almacenamiento | -40°C ~ +85°C |
| Vibración (sin func.) | 20G (10-1000Hz) |
| Dimensiones | 22mm x 80mm x 2.3mm |
| Peso | 7 g |
| Garantía | 5 años (limitada, con asistencia técnica gratuita) |

## Configuración instalada

| Dato | nvme0 (nvme0n1) | nvme1 (nvme1n1) |
|---|---|---|
| Serial | 50026B7687315009 | 50026B7687314F3E |
| Firmware | SDQ00103 | SDQ00103 |
| Link speed | 8.0 GT/s (PCIe 3.0) | 8.0 GT/s (PCIe 3.0) |
| Link width | x1 (de x4 posibles) | x1 (de x4 posibles) |
| Partición 1 | 512M vfat | 512M vfat (/boot) |
| Partición 2 | 931G | 931G (/) |

## Limitaciones por la placa base

Los SSDs soportan PCIe 4.0 x4 (throughput teórico ~7 GB/s), pero los slots M.2 de la placa CWWK CW-AT-10G-8P (ver doc-6) son PCIe 3.0 x1. Esto limita el throughput real a ~900 MB/s por disco, aproximadamente un 15% de la capacidad máxima del SSD.
