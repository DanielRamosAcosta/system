---
id: doc-14
title: "Hardware: Fuente SilverStone SX500-G v1.1"
type: other
created_date: '2026-03-29 15:40'
updated_date: '2026-03-29 15:40'
---
# Hardware: Fuente SilverStone SX500-G v1.1

Documentación de la fuente de alimentación del NAS.

- Fabricante: SilverStone
- Modelo: SST-SX500-G v1.1
- Certificación: 80 PLUS Gold
- Form factor: SFX
- Origen: Amazon (ASIN: B08HNGJCV2)
- Web del fabricante: https://www.silverstonetek.com/es/product/info/power-supplies/SX500-G/

## Especificaciones

| Spec | Valor |
|---|---|
| Potencia máxima DC | 500 W |
| Densidad de potencia | 630 W por litro |
| Factor de forma | SFX |
| Diseño cables | 100% modular, cables planos |
| Certificación | 80 PLUS Gold |
| Eficiencia | 87% - 90% al 20% - 100% de carga |
| PFC | Activo (PF >0.9 en plena carga) |
| Voltaje entrada | 90 - 264 Vrms |
| Frecuencia entrada | 47 - 63 Hz |
| Temp. operación | 0°C - 40°C |
| MTBF | 100,000 horas |
| Garantía | 2 años |

## Raíles de salida

| Raíl | Max. | Regulación | Ripple |
|---|---|---|---|
| +3.3V | 22 A | ±3% | 50 mVp-p |
| +5V | 22 A | ±3% | 50 mVp-p |
| +12V | 41.7 A | ±3% | 120 mVp-p |
| +5VSB | 2.5 A | ±5% | 50 mVp-p |
| -12V | 0.3 A | ±10% | 120 mVp-p |
| Combinado +3.3V y +5V | 110 W | | |
| Combinado +12V | 500 W | | |

Raíl único de +12V (single rail).

## Protecciones

- Protección por exceso de corriente (OCP)
- Protección por exceso de potencia (OPP)
- Protección por exceso de voltaje (OVP)
- Protección por poco voltaje (UVP)
- Protección por cortocircuito (SCP)

## Conectores (v1.1)

| Conector | Cantidad | Longitud cable |
|---|---|---|
| ATX 24/20 pin (placa madre) | 1 | 300 mm |
| EPS 8 pin + ATX12V 4+4 pin | 1 + 1 | 400 mm / 150 mm |
| PCIe 8/6 pin | 1 | 400 mm |
| PCIe 8/6 pin | 1 | 550 mm |
| SATA | 6 | 300/220/100 mm x2 cadenas |
| Periféricos 4 pin (Molex) | 3 | 300/200/200 mm |
| Floppy 4 pin | 1 | 100 mm |

Nota: la v1.1 incluye conectores EPS duales (CPU) en lotes con número de serie desde 2030 en adelante. Incluye cable sensor de 4 pines para mejorar la regulación ~1-2%.

## Refrigeración

- Ventilador FDB (Fluid Dynamic Bearing) de 92 mm
- Ruido mínimo: 18 dBA
- Condensadores 100% japoneses

## Datos físicos

| Spec | Valor |
|---|---|
| Dimensiones | 125 x 63.5 x 100 mm |
| Peso | 1.35 kg |
| Color | Negro (pintura sin plomo) |

## Notas sobre capacidad para el NAS

Con 500W, la fuente tiene margen de sobra para la configuración actual y futura:

| Componente | Consumo estimado |
|---|---|
| CPU Intel N355 (TDP) | ~15 W |
| RAM DDR5 32GB | ~5 W |
| 2x NVMe Kingston NV3 | ~10 W |
| 2x Seagate Exos X10 10TB (reposo/carga) | 10-17 W |
| 2x Seagate Exos 26TB (pendientes, reposo/carga) | 13-18 W |
| Placa base + controladores | ~20 W |
| Ventiladores (6 total) | ~5 W |
| QUADRO + USB | ~2 W |
| **Total estimado** | **~80-92 W** |

Incluso con los 8 bahías llenas de Exos 26TB (pico arranque ~8.9W x 8 = 71W), la fuente de 500W tiene margen suficiente.
