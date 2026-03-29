---
id: doc-6
title: 'Hardware: Placa Base CWWK CW-AT-10G-8P + CPU Intel N355'
type: other
created_date: '2026-03-29 14:07'
---
# Hardware: Placa Base CWWK CW-AT-10G-8P + CPU Intel N355

Documentación del hardware de la placa base y CPU instalados en el NAS.

- Fabricante: CWWK
- Modelo: CW-AT-10G-8P
- Ficha del fabricante: https://cwwk.net/collections/nas/products/cwwk-eight-slot-10g-nas-motherboard-n150-n305-n355-dual-2-5g-network-card-10g-10g-port-single-ddr5-dual-nvme-nas-motherboard
- Ficha de producto detallada: ver doc-5

## CPU

| Spec | Valor |
|---|---|
| Modelo | Intel Core 3 N355 (Twin Lake) |
| Cores / Threads | 8C / 8T (sin Hyper-Threading) |
| Frecuencia base | 800 MHz |
| Frecuencia turbo | 3.9 GHz |
| Cache L1d | 256 KiB (8 instancias) |
| Cache L1i | 512 KiB (8 instancias) |
| Cache L2 | 4 MiB (2 instancias) |
| Cache L3 | 6 MiB |
| GPU integrada | Intel UHD Graphics, 1.35 GHz, 32 EU |
| Virtualización | VT-x |
| Instrucciones relevantes | AVX2, AES-NI, SHA-NI, AVX-VNNI |

## Placa base

| Spec | Valor |
|---|---|
| Form factor | Mini-ITX (17cm x 17cm) |
| PCB | 6 capas, full solid capacitor, color blanco |
| BIOS | AMI (American Megatrends) v5.27, fecha 2025-05-31 |
| Super I/O | IT8613E-Lx (gestión de ventiladores y monitoreo) |
| Boot | Solo EFI |

## Red

| Puerto | Chip | Velocidad | Bus |
|---|---|---|---|
| 1x RJ45 10GbE | Marvell AQC113C-B1-C | 10G/5G/2.5G/1G/100M/10M | PCIe 3.0 x2 |
| 2x RJ45 2.5GbE | Intel i226-V | 2.5G/1G/100M | — |

Interfaces de red detectadas en Linux:
- `enp1s0` — Marvell AQC113C (10GbE)
- `enp4s0` — Intel i226-V (2.5GbE)
- `enp5s0` — Intel i226-V (2.5GbE)

## Almacenamiento (interfaces)

| Interfaz | Chip | Bus | Ancho de banda teórico |
|---|---|---|---|
| 2x M.2 NVMe 2280 | — | PCIe 3.0 x1 cada uno | ~900 MB/s por slot |
| 8x SATA 3.0 (2x SFF-8643) | 2x ASMedia ASM1164 | PCIe 3.0 x1 cada chip | ~900 MB/s por grupo de 4 SATA |
| 1x TF card | vía GL823K | USB 2.0 | — |

## Slots de expansión

| Slot | Señal | Nota |
|---|---|---|
| 1x PCIe x4 físico | PCIe 3.0 x1 | Comparte lane con M.2 E-Key WiFi (usar uno u otro) |
| 1x M.2 E-Key | PCIe + CNVi | Soporta AX210 / WiFi 6E. Comparte lane con slot PCIe |

## USB

| Ubicación | Tipo | Velocidad | Nota |
|---|---|---|---|
| Panel trasero | 1x USB 3.2 (Type-A) | 10 Gbps | — |
| Panel trasero | 1x Type-C | 10 Gbps | Vía hub GL3590 |
| Panel trasero | 2x USB 2.0 | 480 Mbps | — |
| Onboard | 1x USB 2.0 socket (vertical) | 480 Mbps | Para dongles / USB boot |
| Onboard | 1x USB 3.0 female | 5 Gbps | — |
| Onboard | 1x Type-E | 5 Gbps | — |

## Display

- 1x HDMI 2.0 — 4K 4096x2160@60Hz
- 1x DP 1.4 — 4K 4096x2160@60Hz

## Alimentación y ventiladores

- ATX 24-pin + ATX 4-pin
- 1x CPU_FAN (4-pin)
- 1x SYS_FAN (4-pin)

## Otros conectores onboard

- 1x F_PANEL (power on/off, LED)
- 1x Buzzer
- 1x TPM connector
- 1x CMOS recovery key (panel trasero)
- 1x SPI ROM

## PCIe Resource Block Diagram

```
HDMI ──── HDXA ──┐
DP ────── HDXB ──┤
PCIEX1_6609 ─────┤                      DDR5 SODIMM
HVDIN_2 ─────────┤    Alder Lake-N  ──── USB3.0
USB2.0_1 ────────┤    / Twin Lake   ──── M.2 KEY-E
USBKEY ──────────┤                  ──── GL3590 ──────── TYPE-C
                 │                  ──── AQC113C ─────── RJ45 LAN
F_USB1 ──┐       │                  ──── I226V ──────── RJ45 LAN x2
F_USB2 ──┤GL823K │                  ──── ASM1164 ────── SATA*4 ── 8643
SOCKET-TF┘       │                  ──── ASM1164 ────── SATA*4 ── 8643
SPI ROM ─────────┤
TPM CONN ────────┤         ┌──── CPU_FAN
F_PANEL ─────────┤         ├──── SYS_FAN
ATX POWER ───────┘         └──── BW MONITOR
                 │
            IT8613E-Lx
```
