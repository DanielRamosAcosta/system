---
id: doc-12
title: "Hardware: HDD Seagate Exos X10 10TB (x2)"
type: other
created_date: '2026-03-29 15:20'
updated_date: '2026-03-29 15:20'
---
# Hardware: HDD Seagate Exos X10 10TB (x2)

Documentación de los dos discos duros instalados en el NAS.

- Fabricante: Seagate
- Familia: Exos X10 (Enterprise Capacity 3.5 HDD)
- Modelo: ST10000NM0156-2AA111
- Variante: SED (Self-Encrypting Drive), sector 512e
- Cantidad: 2 unidades
- Origen: Amazon (ASIN: B0DT9QW4L6)

## Especificaciones del fabricante

| Spec | Valor |
|---|---|
| Capacidad | 10 TB (10,000,831,348,736 bytes) |
| Form factor | 3.5" |
| Interfaz | SATA 6.0 Gb/s (compatible 3.0 y 1.5) |
| RPM | 7200 |
| Caché | 256 MB (multisegmentada) |
| Velocidad transferencia secuencial máx. | 249 MB/s |
| IOPS aleatorios 4K QD16 (lectura/escritura) | 170 / 370 |
| Latencia promedio | 4.16 ms |
| Sectores | 512 bytes lógico / 4096 bytes físico (512e) |
| MTBF | 2,500,000 horas |
| AFR (tasa fallo anual) | 0.35% |
| Errores lectura no recuperables | 1 sector por 10^15 bits leídos |
| Diseño 24/7 | 8,760 horas/año |
| Garantía | 5 años |

## Diseño

- Sellado con **helio** (base forjada en aluminio, soldadura ancha, interconexión hermética)
- **Sensores ambientales digitales** internos (humedad, presión, temperatura)
- **SED** (Self-Encrypting Drive) — cifrado automático compatible TCG
- SuperParity
- PowerChoice / PowerBalance
- Hot-swap compatible (SATA 2.6)
- Bajo contenido de halógenos

## Consumo de energía

| Estado | Consumo |
|---|---|
| Reposo | 5 W |
| Operación máx. (escritura aleatoria) | 8.0 W |
| Operación máx. (lectura aleatoria 4K/16Q) | 8.4 W |
| Alimentación requerida | +12V y +5V |

## Datos físicos

| Spec | Valor |
|---|---|
| Dimensiones | 147 x 101.85 x 26.11 mm |
| Peso | 650 g |

## Ambiental

| Spec | Valor |
|---|---|
| Temp. operación | 5°C - 60°C |
| Vibración (no operación) | 2.27 Grms (10-500 Hz) |
| Tolerancia golpes (operación, lectura/escritura) | 70/40 G (2ms) |
| Tolerancia golpes (no operación) | 250 G (1ms/2ms) |
| Vibración giratoria (1500 Hz) | 12.5 rad/s² |

## Configuración instalada

| Dato | sda | sdb |
|---|---|---|
| Serial | ZA2AX6PX | ZA29F100 |
| Firmware | SS05 | SS05 |
| Velocidad SATA actual | 6.0 Gb/s | 6.0 Gb/s |
| Horas encendido | 5,574 | 5,575 |
| Ciclos encendido | 56 | 60 |
| Sectores reasignados | 0 | 0 |
| Errores no corregidos | 0 | 0 |
| Total LBAs escritos | 16,865,526,287 (~7.9 TB) | 16,866,331,963 (~7.9 TB) |
| Total LBAs leídos | 7,192,589,746 (~3.4 TB) | 5,973,389,365 (~2.8 TB) |
| Temp. actual | 38°C (min 27, max 40) | 39°C (min 28, max 41) |
| Temp. mínima histórica | 20°C | 20°C |
| Start/Stop Count | 67 | 713 |
| Load Cycle Count | 280 | 284 |
| G-Sense Error Rate | 1,479 | 880 |
| High Fly Writes | 22 | 41 |
| UDMA CRC Errors | 0 | 0 |
| End-to-End Errors | 0 | 0 |

Estado de salud (2026-03-29): ambos discos sanos. 0 sectores reasignados, 0 errores no corregidos, ~5,575 horas de uso (~232 días).
