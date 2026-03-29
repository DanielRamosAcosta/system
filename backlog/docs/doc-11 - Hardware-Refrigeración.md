---
id: doc-11
title: "Hardware: Refrigeración"
type: other
created_date: '2026-03-29 14:50'
updated_date: '2026-03-29 14:50'
---
# Hardware: Refrigeración

Documentación del sistema de refrigeración del NAS.

## Resumen del sistema

La refrigeración se gestiona mediante una controladora Aqua Computer QUADRO (ver doc-4) que controla 4 canales PWM. Cada canal va a un componente o grupo de ventiladores mediante splitters Y.

| Canal QUADRO | Componente | Ventilador(es) | RPM típicas | Ubicación |
|---|---|---|---|---|
| Fan 1 | Disipador NVMe #1 | 1x GRAUGEAR G-M2HS03-F (25mm PWM) | ~1977 | Sobre nvme0 |
| Fan 2 | Disipador NVMe #2 | 1x GRAUGEAR G-M2HS03-F (25mm PWM) | ~1922 | Sobre nvme1 |
| Fan 3 | Compartimento superior (motherboard) | 2x Noctua NF-A8 PWM (80mm) vía splitter Y | ~654 | Zona placa base |
| Fan 4 | Compartimento inferior (HDD) | 2x Noctua NF-A9 PWM (92mm) vía splitter Y | ~656 | Zona bahías HDD |

Nota: los ventiladores originales de la caja Jonsbo N3 (2x 100mm, 3-pin) fueron retirados porque no soportaban control PWM.

## Controladora — Aqua Computer QUADRO

Documentación detallada en doc-4.

- 4 canales PWM, 25W por canal, conector 4-pin
- 4 entradas de sensor de temperatura (1 conectado actualmente)
- USB 2.0, driver kernel: aquacomputer_d5next (out-of-tree)
- hwmon: `/sys/class/hwmon/hwmon4` (puede variar entre reboots)
- Web: https://shop.aquacomputer.de/Monitoring-and-Controlling/QUADRO-and-OCTO/QUADRO-fan-controller-for-PWM-fans::3773.html?language=en

## Ventiladores de caja — 2x Noctua NF-A8 PWM (80mm)

| Spec | Valor |
|---|---|
| Modelo | Noctua NF-A8 PWM |
| Tamaño | 80x80x25 mm (81x81x27 mm con pads) |
| Conector | 4-pin PWM (A2543-4PIN) |
| RPM | 0 - 2200 (max 1750 con L.N.A.) |
| RPM @ 20% PWM | 400 |
| Caudal máx. | 55.5 m³/h (32.67 CFM) |
| Caudal con L.N.A. | 43.9 m³/h (25.84 CFM) |
| Presión estática máx. | 2.37 mm H₂O |
| Ruido máx. | 17.7 dB(A) (13.8 con L.N.A.) |
| Potencia típica | 0.75 W |
| Potencia máx. | 0.96 W |
| Corriente típica | 0.06 A |
| Tensión | 12V (arranque: 7V, máx: 13.2V) |
| Rodamiento | SSO2 |
| Material | PBT GF30 (marco e impulsor) |
| Peso | 90 g |
| Cable | 200 mm (500 mm con extensión incluida), 26 AWG |
| Protección ingreso | IP50 |
| Temp. operación | -10°C a +70°C |
| Driver IC | NE-FD1 |
| MTTF | >150.000 horas |
| Garantía | 6 años |
| Web | https://www.noctua.at/en/products/nf-a8-pwm |
| Cantidad | 2 |

Incluye: L.N.A., cable Y NA-YC1 4-pin, extensión NA-EC1 30cm, 4x anti-vibration mounts NA-AV1, tornillos.

## Ventiladores de caja — 2x Noctua NF-A9 PWM (92mm)

| Spec | Valor |
|---|---|
| Modelo | Noctua NF-A9 PWM |
| Tamaño | 92x92x25 mm (93x93x27 mm con pads) |
| Conector | 4-pin PWM (A2543-4PIN) |
| RPM | 0 - 2000 (max 1550 con L.N.A.) |
| RPM @ 20% PWM | 500 |
| Caudal máx. | 78.9 m³/h (46.44 CFM) |
| Caudal con L.N.A. | 62.6 m³/h (36.84 CFM) |
| Presión estática máx. | 2.28 mm H₂O |
| Ruido máx. | 22.8 dB(A) (16.3 con L.N.A.) |
| Potencia típica | 1.12 W |
| Potencia máx. | 1.2 W |
| Corriente típica | 0.09 A |
| Tensión | 12V (arranque: 7V, máx: 13.2V) |
| Rodamiento | SSO2 |
| Material | PBT GF30 (marco e impulsor) |
| Peso | 95 g |
| Cable | 200 mm (500 mm con extensión incluida), 26 AWG |
| Protección ingreso | IP50 |
| Temp. operación | -10°C a +70°C |
| Driver IC | NE-FD1 |
| MTTF | >150.000 horas |
| Garantía | 6 años |
| Web | https://www.noctua.at/en/products/nf-a9-pwm |
| Cantidad | 2 |

Incluye: L.N.A. NA-RC7, cable Y NA-YC1 4-pin, extensión NA-EC1 30cm, 4x anti-vibration mounts NA-AV1, tornillos.

Ubicación: los NF-A8 (80mm) están en el compartimento superior (motherboard) y los NF-A9 (92mm) en el compartimento inferior (HDD).

## Disipadores NVMe — 2x GRAUGEAR G-M2HS03-F

| Spec | Valor |
|---|---|
| Modelo | GRAUGEAR G-M2HS03-F |
| Tipo | Heatpipe activo con ventilador |
| Ventilador | 25mm PWM |
| Conector | 4-pin (conectados a QUADRO Fan 1 y Fan 2) |
| Heatpipes | 2x cobre de 4mm |
| Disipador | Aluminio con aletas |
| Compatibilidad | M.2 2280 NVMe/SATA (single/double sided) |
| Reducción temp. | Hasta 50% según fabricante |
| Dimensiones | 87 x 27 x 34 mm |
| Peso | 210 g (conjunto) |
| Web | https://graugear.de/en/portfolio-item/g-m2hs03-f/ |
| Cantidad | 2 |

Incluye: 4x thermal pads, destornillador, tornillo SSD.

## Disipador RAM — Disipador de cobre DDR5

| Spec | Valor |
|---|---|
| Fabricante | Haojiaho |
| Material | Cobre puro |
| Tamaño | 63 x 23 x 2 mm |
| Peso | 16 g |
| Fijación | Cinta adhesiva térmicamente conductora |
| Compatibilidad | DDR5 SO-DIMM |
| ASIN | B0CWNHY3NK |
| Cantidad | 1 |

Disipador pasivo (sin ventilador). La ranura central protege la protuberancia del módulo SO-DIMM.

## Disipador CPU — Integrado en placa base

La placa CWWK CW-AT-10G-8P (ver doc-6) incluye un disipador CPU de doble rodamiento de bolas ("CPU double ball heatsink") conectado al header CPU_FAN de la placa. Este ventilador es gestionado por el Super I/O IT8613E (hwmon2), no por la QUADRO.

Lecturas del IT8613E:
- `fan2_input`: ~1000 RPM (CPU fan)
- `pwm2`: 26 (~10%), modo automático por temperatura

## Sensores de temperatura

| Sensor | hwmon | Lectura típica | Notas |
|---|---|---|---|
| CPU Package | hwmon7 (coretemp) | ~40°C | 8 cores individuales disponibles |
| Placa base (IT8613E) | hwmon2 | temp1: ~44°C, temp2: ~24°C | Super I/O |
| NVMe #0 (nvme0) | hwmon0 | ~31°C composite | |
| NVMe #1 (nvme1) | hwmon1 | ~32°C composite | |
| QUADRO Sensor 1 | hwmon4 | ~25°C | Temp. ambiente interior caja |
| AQC113C (10GbE) | hwmon5 | ~37°C (PHY y MAC) | Chip de red |
| RAM (SPD5118) | hwmon6 | ~36°C | Sensor DDR5 integrado |
| ACPI | hwmon3 | ~28°C | Zona térmica ACPI |
