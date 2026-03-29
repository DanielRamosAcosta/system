---
id: doc-5
title: Ficha de producto CWWK CW-AT-10G-8P (Eight-bay 10G NAS Motherboard)
type: other
created_date: '2026-03-29 13:56'
updated_date: '2026-03-29 13:59'
---
# Ficha de producto CWWK CW-AT-10G-8P — Eight-bay 10G NAS Motherboard

Esta es la ficha de producto del fabricante CWWK para la placa base modelo CW-AT-10G-8P. La ficha cubre todas las variantes de CPU disponibles para este modelo (N100, N200, i3-N305, N150, N250, i3-N355), no necesariamente la configuración exacta instalada en nuestro NAS.

Fuente: https://cwwk.net/collections/nas/products/cwwk-eight-slot-10g-nas-motherboard-n150-n305-n355-dual-2-5g-network-card-10g-10g-port-single-ddr5-dual-nvme-nas-motherboard

---

## Variantes de CPU disponibles

- Alder Lake-N: N100 / N200 / i3-N305
- Twin Lake: N150 / N250 / i3-N355

## Resumen de características

- 1 AQC113C 10G Ethernet port
- 2 Intel 2.5G Ethernet ports
- 2 SFF-8643 ports with 8 SATA ports
- 2 M.2 NVMe ports
- HDMI+DP dual display

## Motherboard Core Features

The new generation of Twin Lake has a 10-15% improvement in overall performance compared to the previous generation Alder Lake-N.

- 17CM x 17CM standard ITX board type ATX-24Pin+4Pin power supply
- 1 SO-DIMM DDR5 4800MHz slot supports up to 48G
- 1 Marvell AQC113C 10G electrical port + 2 Intel i226-V 2.5G electrical ports
- 2 SFF-8643 terminals, one for four, 8 SATA3.0
- 2 M.2 PCIe3.0x1 NVMe 2280 sockets
- 1 HDMI2.0 + 1 DP1.4 dual display, both support 4K@60Hz
- 1 USB3.2 (USB-A) + 1 Type-C (USB-C) 10Gbps rate
- 1 PCI-E3.0x1 signal breakout slot compatible with x1x4x8 slot application card
- Onboard 1 USB2.0 female socket + 1 USB3.0 female socket + 1 Type-E female socket
- 1 M.2 PCIe & CNVi WiFi slot supports AX210 and WiFi6e modules
- 1 TF card slot supports storage and partial system booting

## Specifications

| Category | Details |
|---|---|
| **Motherboard Features** | White PCB. Full protection (supports all USB, HDMI, DP, RJ45, network interfaces). 6-layer high density moisture-free fiber PCB. All solid capacitor design. |
| **Processor** | Intel 12th generation Alder Lake-N N100/N200/i3-N305. Intel 12th generation Twin Lake N150/N250/i3-N355. |
| **Memory** | Notebook SO-DIMM DDR5. 1 SO-DIMM DDR5 slot. DDR5 supports 4800MHz by default (compatible with 5200 and 5600, will automatically downclock to 4800MHz). Maximum capacity 48GB. |
| **TDP** | Depends on CPU power consumption |
| **Storage** | 2x M.2 NVMe PCIe3.0x1 (2280). 8x SATA3.0 (2 ASM1164 chips). 1x TF card. |
| **Network Card** | 1x Marvell AQC113C-B1-C RJ45 10G. 2x Intel i226-V RJ45 2.5G. |
| **Graphics** | Intel UHD Graphics. N100 750MHz 24EU / i3-N305 1.25GHz 32EU. N150 1GHz 24EU / i3-N355 1.35GHz 32EU. HDMI2.0 4K 4096x2160@60Hz. DP1.4 4K 4096x2160@60Hz. |
| **Power** | ATX-24Pin + ATX-4Pin |
| **Onboard Interface** | 1x CPU_FAN. 1x SYS_FAN. 1x 4Pin_ATX CPU power supply. 1x 24Pin_ATX motherboard power supply. 2x M.2 NVMe PCIe3.0x1 2280. 1x SO-DIMM DDR5 slot. 2x SFF-8643 terminals. 1x F_PANEL pin. 1x Buzzer. 1x PCIex4 breakout slot (PCIe3.0x1 signal). 1x USB2.0 socket (vertical). 1x USB3.0 female connector. 1x Type-E. 1x M.2 E_key PCIe & CNVi WiFi socket. |
| **IO Panel** | 1x USB3.2. 1x Type-C. 1x HDMI2.0. 1x DP1.4. 1x 10G RJ45. 2x 2.5G RJ45. 2x USB2.0. 1x TF port. |
| **Dimensions** | Mini-ITX: 6.7in x 6.7in (17.0cm x 17.0cm) |
| **Operating System** | Microsoft Windows 10/11 64-bit. Linux/open source NAS systems. EFI mode only. |

## I/O Interface Guide

### Rear Panel (left to right)

USB 3.2 (10Gbps) — Type-C (10Gbps) — CMOS recovery key — HDMI 2.0 — DP 1.4 — AQC113C (10Gbps) — i226-V (2.5Gbps) — i226-V (2.5Gbps) — USB2.0 — TF slot

### Onboard Connectors

- F_PANEL switch pin header
- Type-E female connector
- USB3.0 female connector
- ATX-24PIN
- ATX-4PIN
- 4PIN fan power supply socket
- SO-DIMM DDR5
- CPU double ball heatsink
- CPU_FAN

## Board Layout — Physical Component Map

- AQC113C-B1-C 10G chip heat sink
- M.2 NVMe PCIe3.0 x1 (x2 slots)
- M.2E_Key WiFi and PCI-E slot Colay
- PCI-E x4 slot (x1 signal) and M.2E_Key Colay
- M.2 2280 hard drive lock
- SFF-8643 (SATA x4) x2
- Dual ASM1164 chip heat sink

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

## AQC113C — 10G Ethernet Port

Marvell AQC113C 10G chip supports six speeds:

- 10GBASE-T
- 5GBASE-T
- 2.5GBASE-T
- 1000BASE-T
- 100BASE-T
- 10BASE-T

Accessed by PCIe3.0 x2 signal (theoretical rate 15.75Gbps). It is recommended to use Category 7 / 10 Gigabit cables.

## CPU — Alder Lake-N & Twin Lake

Optional Alder Lake-N N100/i3-N305 & Twin Lake N150/i3-N355 processors with dual ball bearing fan radiator.

## M.2 PCIe NVMe

Two M.2 NVMe PCIe 3.0 x1 slots, 2280 specifications. Theoretical speed 900M/s+.

## 2x SFF-8643

Two ASM1164 SATA adapter chips, each connected with PCIe3.0x1 signal. Each SFF-8643 breaks out to 4 SATA3.0, dual SFF-8643 for a total of 8 SATA3.0.

- SFF-8643 to SFF-8643 cable (included)
- SFF-8643 to 4xSATA cable (purchased separately)

## DDR5 — SO-DIMM

Recommended 4800MHz frequency (compatible with 5200/5600MHz, automatically downclocked to 4800MHz). Single stick supports maximum 48G, notebook SO-DIMM DDR5.

## M.2 E_Key WiFi

1 M.2 E-Key supports WiFi modules with PCIe & CNVi signals (such as AX210/AX201). The PCIe signal in the M.2 E_key and the PCI-E slot x1 signal share the same lane — choose one of the two.

## PCI-EX4 Slot — PCIe 3.0 x1 Signal

Supports expansion of multiple SATA ports / array cards / 2.5G network ports / 10G optical ports / M.2 / graphics cards, etc. PCIex1 signal and M.2 E-key WiFi signal share the same lane — choose one from the two.
