---
id: doc-13
title: "Hardware: HDD Seagate Exos 26TB (x2)"
type: other
created_date: '2026-03-29 15:30'
updated_date: '2026-04-15 08:05'
---
# Hardware: HDD Seagate Exos 26TB (x2)

Documentación de los dos discos duros instalados en el NAS.

- Fabricante: Seagate
- Familia: Exos (basado en plataforma X24)
- Modelo: ST26000NM000C-3WE103
- Variante: ISE (Instant Secure Erase), sector 512e
- Condición: Recertificado de fábrica
- Cantidad: 2 unidades
- Origen: Amazon (ASIN: B0DHLFXSTZ)

## Especificaciones

Basadas en la ficha de producto de Amazon y la ficha técnica de la plataforma Exos X24 de Seagate.

| Spec | Valor |
|---|---|
| Capacidad | 26 TB (26,000,658,268,160 bytes) |
| Form factor | 3.5" |
| Interfaz | SATA 6.0 Gb/s |
| RPM | 7200 |
| Caché | 512 MB (multisegmentada) |
| Grabación | CMR (Conventional Magnetic Recording) |
| Velocidad transferencia secuencial máx. | 285 MB/s (272 MiB/s) |
| IOPS aleatorios 4K QD16 (lectura/escritura) | 168 / 550 |
| Latencia promedio | 4.16 ms |
| MTBF | 2,500,000 horas |
| AFR (tasa fallo anual) | 0.35% |
| Errores lectura no recuperables | <1 por 10^15 bits leídos |
| Diseño 24/7 | 8,760 horas/año |
| Garantía (nuevo) | 5 años |
| Garantía (recertificado) | 3 meses de reemplazo |

## Diseño

- Sellado con **helio** (soldadura lateral, tecnología probada)
- Sensores ambientales digitales (humedad, presión, temperatura)
- Seagate Instant Secure Erase (ISE)
- SuperParity
- PowerChoice / PowerBalance
- Hot-plug compatible (SATA 3.5)
- FastFormat (512e ↔ 4Kn)
- RSA 3072 firmware verification
- Verificación firmware RSA 3072 (SD&D)

## Consumo de energía

| Estado | Consumo |
|---|---|
| Reposo | 6.3 W |
| Operación máx. (lectura aleatoria 4K/16Q) | 8.9 W |
| Operación máx. (escritura aleatoria 4K/16Q) | 7.1 W |
| Alimentación requerida | +12V y +5V |

## Datos físicos

| Spec | Valor |
|---|---|
| Dimensiones | 147 x 101.85 x 26.1 mm |
| Peso | 685 g |

## Ambiental

| Spec | Valor |
|---|---|
| Temp. operación | 5°C - 60°C (ambient / drive reported) |
| Vibración (no operación) | 2.27 Grms (2-500 Hz) |
| Tolerancia golpes (operación, lectura/escritura) | 40 G (2ms) |
| Tolerancia golpes (no operación) | 200 G (2ms) |
| Vibración giratoria (20-1500 Hz) | 12.5 rad/s² |

## Comparativa con Exos X10 actuales (doc-12)

| Spec | Exos X10 (10TB) | Exos X24/26 (26TB) |
|---|---|---|
| Capacidad | 10 TB | 26 TB (+160%) |
| Transferencia secuencial | 249 MB/s | 285 MB/s (+14%) |
| IOPS escritura 4K | 370 | 550 (+49%) |
| Caché | 256 MB | 512 MB |
| Reposo | 5 W | 6.3 W |
| Peso | 650 g | 685 g |
| MTBF | 2.5M h | 2.5M h |
| Garantía | 5 años | 5 años (3 meses recertificado) |

## Configuración instalada

| Dato | sda | sdd |
|---|---|---|
| Serial | ZXA0543G | ZXA06CV4 |
| Firmware | SN02 | SN02 |
| Velocidad SATA actual | **1.5 Gb/s** ⚠️ | 6.0 Gb/s |
| Sectores | 512 bytes lógico / 4096 bytes físico (512e) | 512 bytes lógico / 4096 bytes físico (512e) |
| Horas encendido | 295 | 295 |
| Ciclos encendido | 4 | 4 |
| Sectores reasignados | 0 | 0 |
| Errores no corregidos | 0 | 0 |
| Command Timeout | 0 | 0 |
| Total LBAs escritos | 27,202,360,064 (~12.7 TB) | 27,202,360,088 (~12.7 TB) |
| Total LBAs leídos | 17,101,093,894 (~8.0 TB) | 26,103,343,062 (~12.2 TB) |
| Temp. actual | 38°C (min 38, max 58) | 35°C (min 34, max 54) |
| Temp. mínima histórica | 26°C | 25°C |
| Start/Stop Count | 4 | 4 |
| Load Cycle Count | 15 | 15 |
| Power-Off Retract Count | 3 | 3 |
| UDMA CRC Errors | 0 | 0 |
| Multi Zone Error Rate | 0 | 0 |
| Pending Sectors | 0 | 0 |
| Offline Uncorrectable | 0 | 0 |

Estado de salud (2026-04-15): ambos discos sanos. 0 sectores reasignados, 0 errores no corregidos, 295 horas de uso (~12 días).

## Notas

- Son discos **recertificados de fábrica** (refurbished). Seagate los ha limpiado, testeado e incluyen firmware y piezas actualizadas.
- El modelo ST26000NM000C (26TB) no aparece en la ficha oficial del Exos X24 (que lista hasta 24TB). Probablemente es una variante de capacidad extendida de la misma plataforma.
- **sda negocia SATA a 1.5 Gb/s** en lugar de 6.0 Gb/s. Puede deberse al cable SATA o al puerto de la placa base. Investigar y renegociar.
