---
id: doc-18
title: "Histórico mapa bahías HDD"
type: other
created_date: '2026-04-15 19:30'
updated_date: '2026-04-15 19:30'
---
# Histórico mapa bahías HDD

Registro histórico de la disposición física de los discos duros en las bahías del Jonsbo N3 (doc-10), incluyendo velocidades SATA negociadas en cada configuración.

## Configuración 1 — Bahías contiguas (2026-03-29 → 2026-04-15)

Disposición inicial tras instalar los dos Exos 26TB junto a los X10 existentes. Bahías 1-4 ocupadas, 5-8 vacías.

| Bahía | Puerto | Serial | Modelo | Capacidad | SATA negociada |
|---|---|---|---|---|---|
| 1 | ata1 | ZA29F100 | Exos X10 | 10 TB | 6.0 Gb/s |
| 2 | ata2 | ZA2AX6PX | Exos X10 | 10 TB | 6.0 Gb/s |
| 3 | ata3 | ZXA0543G | Exos 26TB | 26 TB | 1.5 Gb/s ⚠️ |
| 4 | ata4 | ZXA06CV4 | Exos 26TB | 26 TB | 6.0 Gb/s |
| 5 | — | — | — | — | — |
| 6 | — | — | — | — | — |
| 7 | — | — | — | — | — |
| 8 | — | — | — | — | — |

Controlador único: `0x81380000` (ata1-4).

Notas:
- ZXA0543G negoció a 1.5 Gb/s desde la primera instalación (133 MB/s medidos con dd)
- Los demás discos a 6.0 Gb/s sin problemas

## Configuración 2 — Bahías impares, mismo orden (2026-04-15)

Se movieron los discos a bahías impares para mejorar flujo de aire. Se limpiaron los conectores SATA de los discos y del backplane antes de reinsertar.

| Bahía | Puerto | Serial | Modelo | Capacidad | SATA negociada |
|---|---|---|---|---|---|
| 1 | ata1 | ZA29F100 | Exos X10 | 10 TB | 3.0 Gb/s ⚠️ |
| 2 | — | — | — | — | — |
| 3 | ata3 | ZA2AX6PX | Exos X10 | 10 TB | 6.0 Gb/s |
| 4 | — | — | — | — | — |
| 5 | ata5 | ZXA0543G | Exos 26TB | 26 TB | 1.5 Gb/s ⚠️ |
| 6 | — | — | — | — | — |
| 7 | ata7 | ZXA06CV4 | Exos 26TB | 26 TB | 6.0 Gb/s |
| 8 | — | — | — | — | — |

Dos controladores: `0x81380000` (ata1-4, bahías 1,3) y `0x81280000` (ata5-8, bahías 5,7).

Notas:
- ZXA0543G sigue a 1.5 Gb/s tras cambio de bahía, controlador y limpieza de conectores → problema del PHY del disco
- ZA29F100 bajó de 6.0 a 3.0 Gb/s al recolocarlo
- ZXA06CV4 mostró "link is slow to respond" en dmesg pero negoció a 6.0 Gb/s

## Configuración 3 — Bahías impares, intercambio bahía 3↔5 (2026-04-15)

Se intercambiaron los discos de bahía 3 y 5 para mezclar un disco de cada tamaño por controlador SATA y probar si ZXA0543G negocia mejor en otro puerto.

| Bahía | Puerto | Serial | Modelo | Capacidad | SATA negociada |
|---|---|---|---|---|---|
| 1 | ata1 | ZA29F100 | Exos X10 | 10 TB | 1.5 Gb/s ⚠️ |
| 2 | — | — | — | — | — |
| 3 | ata3 | ZXA0543G | Exos 26TB | 26 TB | 6.0 Gb/s |
| 4 | — | — | — | — | — |
| 5 | ata5 | ZA2AX6PX | Exos X10 | 10 TB | 6.0 Gb/s |
| 6 | — | — | — | — | — |
| 7 | ata7 | ZXA06CV4 | Exos 26TB | 26 TB | 6.0 Gb/s |
| 8 | — | — | — | — | — |

Dos controladores: `0x81380000` (ata1,3) y `0x81280000` (ata5,7). Un disco de cada tamaño por controlador.

Notas:
- ZXA0543G ahora negocia a 6.0 Gb/s en bahía 3 (antes 1.5 en bahías 3 y 5) → no era el disco
- ZA29F100 cae a 1.5 Gb/s en bahía 1 (antes 6.0 en config 1, 3.0 en config 2)
- El problema de negociación es intermitente, no atribuible a un disco o bahía concretos

## Configuración 4 — Después de limpiar la bahía 1 (2026-04-15)

Misma disposición que config 3. Se limpió el conector del backplane de la bahía 1.

| Bahía | Puerto | Serial | Modelo | Capacidad | SATA negociada |
|---|---|---|---|---|---|
| 1 | ata1 | ZA29F100 | Exos X10 | 10 TB | 6.0 Gb/s |
| 2 | — | — | — | — | — |
| 3 | ata3 | ZXA0543G | Exos 26TB | 26 TB | 3.0 Gb/s ⚠️ |
| 4 | — | — | — | — | — |
| 5 | ata5 | ZA2AX6PX | Exos X10 | 10 TB | 1.5 Gb/s ⚠️ |
| 6 | — | — | — | — | — |
| 7 | ata7 | ZXA06CV4 | Exos 26TB | 26 TB | 1.5 Gb/s ⚠️ |
| 8 | — | — | — | — | — |

Dos controladores: `0x81380000` (ata1,3) y `0x81280000` (ata5,7).

Notas:
- Bahía 1 recuperó 6.0 Gb/s tras limpieza, pero las bahías 3, 5 y 7 degradaron (3 de 4 discos afectados)
- El patrón es completamente aleatorio entre reinicios: no depende del disco, la bahía ni el controlador
- Apunta a un problema sistémico del backplane o de la alimentación del backplane

## Configuración 5 — Bahías contiguas por pareja (2026-04-15)

Se agrupan los discos en parejas contiguas: X10 en bahías 1+5, 26TB en bahías 2+6.

| Bahía | Puerto | Serial | Modelo | Capacidad | SATA negociada |
|---|---|---|---|---|---|
| 1 | ata1 | ZA29F100 | Exos X10 | 10 TB | 1.5 Gb/s ⚠️ |
| 2 | ata2 | ZXA0543G | Exos 26TB | 26 TB | 6.0 Gb/s |
| 3 | — | — | — | — | — |
| 4 | — | — | — | — | — |
| 5 | ata5 | ZA2AX6PX | Exos X10 | 10 TB | 6.0 Gb/s |
| 6 | ata6 | ZXA06CV4 | Exos 26TB | 26 TB | 1.5 Gb/s ⚠️ |
| 7 | — | — | — | — | — |
| 8 | — | — | — | — | — |

Notas:
- 2 de 4 discos a velocidad completa
- Patrón aleatorio confirmado en 5 configuraciones consecutivas

## Configuración 6 — Vuelta a bahías impares, intercambio 3↔5 (2026-04-15)

Misma disposición que configuraciones 3 y 4.

| Bahía | Puerto | Serial | Modelo | Capacidad | SATA negociada |
|---|---|---|---|---|---|
| 1 | ata1 | ZA29F100 | Exos X10 | 10 TB | 1.5 Gb/s ⚠️ |
| 2 | — | — | — | — | — |
| 3 | ata3 | ZXA0543G | Exos 26TB | 26 TB | 6.0 Gb/s |
| 4 | — | — | — | — | — |
| 5 | ata5 | ZA2AX6PX | Exos X10 | 10 TB | 1.5 Gb/s ⚠️ |
| 6 | — | — | — | — | — |
| 7 | ata7 | ZXA06CV4 | Exos 26TB | 26 TB | 1.5 Gb/s ⚠️ |
| 8 | — | — | — | — | — |

Dos controladores: `0x81380000` (ata1,3) y `0x81280000` (ata5,7).

Notas:
- Peor resultado: solo 1 de 4 a 6.0 Gb/s
- ata7 (ZXA06CV4) tardó 13s en negociar ("link is slow to respond") y acabó a 1.5 Gb/s
- Problema sistémico del backplane confirmado en 6 configuraciones

## Configuración 7 — Reinicio sin cambios (2026-04-15)

Misma disposición que config 6. Solo reinicio.

| Bahía | Puerto | Serial | Modelo | Capacidad | SATA negociada |
|---|---|---|---|---|---|
| 1 | ata1 | ZA29F100 | Exos X10 | 10 TB | 6.0 Gb/s |
| 2 | — | — | — | — | — |
| 3 | ata3 | ZXA0543G | Exos 26TB | 26 TB | 6.0 Gb/s |
| 4 | — | — | — | — | — |
| 5 | ata5 | ZA2AX6PX | Exos X10 | 10 TB | 6.0 Gb/s |
| 6 | — | — | — | — | — |
| 7 | ata7 | ZXA06CV4 | Exos 26TB | 26 TB | 6.0 Gb/s |
| 8 | — | — | — | — | — |

Dos controladores: `0x81380000` (ata1,3) y `0x81280000` (ata5,7).

Notas:
- 4 de 4 a 6.0 Gb/s — primer resultado perfecto
- Confirma que el problema es de timing/lotería en el arranque, no de hardware defectuoso

## Resumen de resultados

| Config | Cambio | Discos a 6.0 Gb/s |
|---|---|---|
| 1 | Instalación inicial, bahías 1-4 | 3/4 (75%) |
| 2 | Bahías impares, limpieza conectores | 2/4 (50%) |
| 3 | Intercambio bahía 3↔5 | 3/4 (75%) |
| 4 | Limpieza bahía 1 | 1/4 (25%) |
| 5 | Bahías 1,2,5,6 contiguas | 2/4 (50%) |
| 6 | Vuelta a bahías impares | 1/4 (25%) |
| 7 | Solo reinicio | 4/4 (100%) |

Conclusión: la velocidad de negociación SATA es aleatoria entre reinicios. No depende del disco, la bahía, el controlador ni la limpieza de conectores. Apunta a un problema de timing o alimentación del backplane Jonsbo N3 durante el arranque.
