---
id: doc-7
title: "Hardware: RAM Crucial DDR5 32GB SO-DIMM"
type: other
created_date: '2026-03-29 14:20'
updated_date: '2026-03-29 14:20'
---
# Hardware: RAM Crucial DDR5 32GB SO-DIMM

Documentación del módulo de RAM instalado en el NAS.

- Fabricante: Crucial
- Capacidad: 32 GB
- Tipo: DDR5 SO-DIMM
- Velocidad nominal: 5200 MHz
- Velocidad operativa: 4800 MHz (limitación de la placa, ver doc-6)
- Origen: AliExpress (enlace ya no disponible: https://es.aliexpress.com/item/1005007513290336.html)

## Configuración detectada

| Dato | Valor | Fuente |
|---|---|---|
| Capacidad total | 32 GB (32.636.060 kB) | /proc/meminfo |
| Slots ocupados | 1 / 1 | kernel DMI: `Memory slots populated: 1/1` |
| Canales internos | 2 (ch0 + ch1, 16384 MB cada uno) | EDAC dimm0 + dimm2 |
| Device type | x8 | EDAC |
| ECC | IBECC (In-Band ECC), modo SECDED | EDAC igen6 |
| Controlador | Intel Client SoC MC#0 (igen6_edac v2.5.1) | kernel |

## Notas

- La placa soporta DDR5 a 4800 MHz por defecto. Es compatible con módulos de 5200 y 5600 MHz, pero los baja automáticamente a 4800 MHz.
- Capacidad máxima soportada por la placa: 48 GB en un solo módulo SO-DIMM.
- IBECC (In-Band ECC) está activo. Es una funcionalidad ECC "lite" integrada en el SoC Intel Twin Lake que funciona con RAM estándar (no requiere módulos ECC). El driver EDAC igen6 reporta erróneamente el tipo como "Unbuffered-DDR3" — es un bug conocido del driver con DDR5.
- El módulo opera en dual-channel interno (2 canales de 16 GB), arquitectura propia de DDR5 donde cada módulo tiene dos canales de 32 bits.
