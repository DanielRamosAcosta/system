---
id: doc-22
title: 'Hardware: Raspberry Pi 2 Model B Rev 1.1'
type: other
created_date: '2026-08-15 08:54'
---
# Hardware: Raspberry Pi 2 Model B Rev 1.1

Documentación del hardware de la Raspberry Pi recuperada. Datos leídos en vivo por SSH (`dani@192.168.1.46`, hostname `raspberrypi`).

- Fabricante: Raspberry Pi Foundation
- Modelo: Raspberry Pi 2 Model B Rev 1.1
- Revision code: `a01041` (Sony UK, 1 GB RAM)
- Serial: `00000000949aab5f`

## SoC / CPU

| Spec | Valor |
|---|---|
| SoC | Broadcom BCM2836 (BCM2835 en `/proc/cpuinfo`, normal en Pi 2) |
| CPU | ARM Cortex-A7 (ARMv7-A), 4 cores |
| Arquitectura | ARMv7l (32-bit), rev 5 (v7l) |
| Frecuencia | 900 MHz (medida: 900.09 MHz) |
| BogoMIPS | 57.60 por core |
| Features | half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt vfpd32 lpae evtstrm |
| GPU | Broadcom VideoCore IV |

## Memoria

| Spec | Valor |
|---|---|
| RAM total | 1 GB LPDDR2 (`MemTotal: 942120 kB` ≈ 920 MiB útiles) |
| Reparto ARM/GPU | ARM 948 MB / GPU 76 MB |
| Swap | zram0 (920 MiB, comprimido en RAM) |

## Almacenamiento

| Spec | Valor |
|---|---|
| Tarjeta SD | Samsung 32 GB (manfid `0x1b`, oemid `SM`, serial `0xac6c105f`, fabricación 01/2015) |
| Tamaño | 29.8 GB |
| Partición `mmcblk0p1` | 512 MB vfat → `/boot/firmware` |
| Partición `mmcblk0p2` | 29.3 GB ext4 → `/` (uso 19%, 5.1 GB usados, 23 GB libres) |

## Red

| Spec | Valor |
|---|---|
| Interfaz | `eth0` — Ethernet 10/100 Mbps |
| Chip | SMSC LAN9514 (Ethernet + hub USB 2.0, conectado por USB interno) |
| MAC | `b8:27:eb:9a:ab:5f` |
| IP (DHCP) | 192.168.1.46/24 |
| WiFi | No tiene (el Pi 2 B no lleva WiFi/Bluetooth integrados) |

## USB

Bus 001 (USB 2.0 root hub) → hub SMSC SMC9514:

| Dispositivo | ID | Descripción |
|---|---|---|
| Hub | `0424:9514` | Microchip/SMSC SMC9514 Hub |
| Ethernet | `0424:ec00` | SMSC9512/9514 Fast Ethernet Adapter |
| Teclado | `1a2c:2124` | China Resource Semico — Keyboard |

- 4x puertos USB 2.0 (480 Mbps) expuestos vía el hub SMSC.

## Software

| Spec | Valor |
|---|---|
| OS | Raspbian GNU/Linux 13 (trixie), Debian 13.4 |
| Kernel | `6.18.34+rpt-rpi-v7` (SMP, armv7l), 2026-06-09 |
| Firmware VideoCore | `288930ab...` (May 21 2026 11:21:57) |

## Estado térmico y de alimentación (lectura en vivo)

| Spec | Valor |
|---|---|
| Temperatura SoC (idle) | 43.3 °C |
| Temperatura SoC (tras benchmarks) | 47.1 °C |
| Voltaje core | 1.3125 V (normal para 900 MHz) |
| `get_throttled` | `0x50000` |

Decodificación de `0x50000`:

| Bit | Flag | Estado |
|---|---|---|
| 0 | Under-voltage actual | No |
| 2 | Throttling actual | No |
| 16 | Under-voltage ocurrido desde el arranque | **Sí** |
| 18 | Throttling ocurrido desde el arranque | **Sí** |

> El SoC no está sufriendo problemas en este instante, pero **desde el arranque ha habido al menos un episodio de bajada de tensión** (por debajo de ~4.63 V en el raíl de 5 V), lo que disparó throttling temporal. Indica que el cargador o el cable no entregan tensión estable bajo carga. Ver notas de alimentación abajo.

## Notas de alimentación

- El Raspberry Pi 2 Model B se alimenta por micro-USB, 5 V, con fuente recomendada de **2.0 A** (mínimo real ~1.0 A en idle, sube con USB conectados).
- El flag de under-voltage ya activo con solo 5 min de uptime sugiere fuente/cable insuficientes. Recomendado: cargador oficial de 5 V/2 A y cable micro-USB corto y grueso (buena sección) para minimizar la caída de tensión.

## Benchmarks (2026-08-15)

Pruebas rápidas con las herramientas disponibles en el sistema (`openssl`, `dd`, `curl`); no hay `sysbench`/`stress-ng`. Valores orientativos.

### CPU

| Prueba | Resultado | Nota |
|---|---|---|
| SHA-256 1 core (bloques 16 KiB) | ~31.3 MB/s | `openssl speed sha256` |
| AES-256-CBC 1 core (bloques 16 KiB) | ~16.6 MB/s | Sin AES-NI (ARMv7 no tiene); cifrado por software |
| SHA-256 4 cores en paralelo | ~4× el rendimiento de 1 core | Escala bien (4× el trabajo en ~el mismo tiempo por core) |

### Memoria

| Prueba | Resultado | Nota |
|---|---|---|
| `dd` 1 GiB `/dev/zero` → `/dev/null` (bs=1M) | ~881 MB/s | Indicativo, no ancho de banda real de RAM |

### Tarjeta SD (ext4 en `/`, medido en `~`)

| Prueba | Resultado |
|---|---|
| Escritura secuencial (`conv=fdatasync`) | ~10 MB/s |
| Escritura secuencial (`oflag=direct`) | ~12 MB/s |
| Lectura secuencial (tras `drop_caches`) | ~23 MB/s |

> Ojo: `/tmp` es **tmpfs (RAM)**, así que benchmarks de SD deben hacerse en `~` o `/`, no en `/tmp` (allí daría cifras irreales de cientos de MB/s).

### Red / Internet (single-stream)

La Pi va por Ethernet **100 Mbps sobre USB 2.0**, así que ~94 Mbps (≈11.75 MB/s) es el techo práctico del enlace local.

| Prueba | MB/s | Mbps | Servidor |
|---|---|---|---|
| Descarga | 8.37 MB/s | ~67 Mbps | OVH Roubaix (FR) |
| Descarga | 8.08 MB/s | ~65 Mbps | Hetzner Falkenstein (DE) |
| Descarga | 6.48 MB/s | ~52 Mbps | Hetzner Ashburn (US) |
| Subida | 7.32 MB/s | ~58 Mbps | Cloudflare `__up` |
| Latencia a 1.1.1.1 | — | 13.6 ms avg, 0% pérdida | — |
| Latencia a 8.8.8.8 | — | 11.4 ms avg, 0% pérdida | — |

> Las cifras de descarga son de **un solo flujo TCP**; el límite lo marca la combinación de CPU de la Pi + adaptador Ethernet-por-USB + distancia al servidor, no necesariamente la línea contratada. Cloudflare `__down` devuelve HTTP 403 desde esta IP; usar mirrors de OVH/Hetzner para medir.
