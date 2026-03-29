---
id: doc-13
title: "Hardware: HDD Seagate Exos 26TB (x2, pendiente de instalar)"
type: other
created_date: '2026-03-29 15:30'
updated_date: '2026-03-29 15:30'
---
# Hardware: HDD Seagate Exos 26TB (x2, pendiente de instalar)

Documentación de los dos discos duros adquiridos, pendientes de instalar en el NAS.

- Fabricante: Seagate
- Familia: Exos (basado en plataforma X24)
- Modelo: ST26000NM000C
- Condición: Recertificado de fábrica
- Cantidad: 2 unidades
- Origen: Amazon (ASIN: B0DHLFXSTZ)

## Especificaciones

Basadas en la ficha de producto de Amazon y la ficha técnica de la plataforma Exos X24 de Seagate.

| Spec | Valor |
|---|---|
| Capacidad | 26 TB |
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

## Notas

- Son discos **recertificados de fábrica** (refurbished). Seagate los ha limpiado, testeado e incluyen firmware y piezas actualizadas.
- El modelo ST26000NM000C (26TB) no aparece en la ficha oficial del Exos X24 (que lista hasta 24TB). Probablemente es una variante de capacidad extendida de la misma plataforma.
- Pendientes de instalar. Una vez instalados, actualizar este documento con los seriales y datos SMART.
