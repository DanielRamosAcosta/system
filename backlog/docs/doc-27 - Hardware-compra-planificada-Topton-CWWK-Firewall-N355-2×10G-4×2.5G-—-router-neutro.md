---
id: doc-27
title: >-
  Hardware (compra planificada): Topton/CWWK Firewall N355 2×10G + 4×2.5G —
  router neutro
type: other
created_date: '2026-08-15 15:13'
---
Equipo **elegido para el futuro router neutro** que sustituirá al Vodafone H-500-s (ver [doc-24](#doc-24), [doc-26](#doc-26)). **Aún sin comprar** — se adquirirá cuando arranque el montaje del router. Es el board estándar de router OPNsense de CWWK/Topton (mismo silicio N355 que el NAS).

- Fabricante: Topton / CWWK (mismo OEM; se vende con varios nombres)
- Producto: Topton Firewall Mini PC 2×10G SFP+ · Intel i3-N355 · 4× i226-V 2.5G
- Ficha: https://www.toptonpc.com/product/topton-firewall-mini-pc-2x10g-sfp-intel-i3-n355-n305-n150-n100-4xi226-v-2-5g-lan-ddr5-nvme-proxmox-esxi-pfsense-home-lab-server/
- Config elegida: **N355 / 16GB DDR5 / 256GB NVMe** — **$477.19**
- Canal de compra desde España: AliExpress (tienda oficial Topton/CWWK) o toptonpc.com

## Especificaciones

| Spec | Valor |
|---|---|
| CPU | **Intel Core i3-N355** (Twin Lake): 8 núcleos / 8 hilos, hasta **3.9 GHz**, 6MB caché, **TDP 15W**, iGPU UHD 32EU, **AES-NI** |
| Red 10G | **2× SFP+ 10GbE** con **Intel 82599ES** (driver `ixgbe`) vía slot PCIe x8 |
| Red 2.5G | **4× RJ45 2.5GbE Intel i226-V** (driver `igc`) |
| RAM | 16GB DDR5 4800 (elegido); **1 slot SO-DIMM**, máx **32GB** |
| Almacenamiento | 256GB NVMe (elegido); **1× M.2 NVMe** + **1× SATA 3.0** (2.5") |
| Expansión | 1× PCIe x8 (ocupado por la tarjeta 82599ES dual-10G) |
| Refrigeración | **Con ventilador** (no fanless; el 8 núcleos + 10G calienta) |
| Alimentación | DC 12V |
| SO objetivo | **NixOS** (`hosts/router/`) |

> El mismo chip **N355** que la placa del NAS (CWWK CW-AT-10G-8P, ver [doc-6](#doc-6)) → terreno conocido en NixOS. El **82599ES** es el controlador 10G más maduro de Linux (`ixgbe`), un plus frente a alternativas Marvell.

## Por qué este y no otros

- **4× i226-V (no 2×):** en Fase 1 se necesitan **3 puertos RJ45** (WAN←ONT + NAS 2.5G + switch TL-SG105) y se quieren **reservar los SFP+** para el 10G futuro. Los modelos de 2× i226 (CWWK S6/S8) obligarían a ocupar un SFP+ desde el principio.
- **N355 = N305 pero más nuevo:** mismo tier de 8 núcleos; se elige N355 por disponibilidad y por igualar el NAS. N100/N150 (4 núcleos) valdrían para hoy pero se quedan cortos para enrutar 10G a futuro.
- **Fanless descartado:** las únicas opciones fanless con 8 núcleos + 10G (Topton i5-1235U) costaban ~779€; no compensa para un router.

## Plan de puertos (Fase 1, todo ≤2.5G)

| Puerto | Uso |
|---|---|
| i226 #1 | **WAN** ← ONT |
| i226 #2 | **NAS** directo (2.5G) |
| i226 #3 | **Switch TL-SG105** (resto de la casa, 1G) |
| i226 #4 | reserva |
| SFP+ ×2 (82599ES) | **reservados** para el 10G de Vodafone (Fase 2) |

Fase 2 (10G): WAN pasa a un SFP+; se añade un switch 10G (con al menos 1 puerto RJ45 10GBASE-T para el NAS) unido al router por DAC SFP+↔SFP+.

## Notas para la config NixOS

- **i226-V (`igc`):** añadir boot params `pcie_port_pm=off` e `igc.eee_enable=0` para evitar caídas de enlace por ASPM/EEE (patrón conocido de las guías de router NixOS y de la i226 del NAS).
- **82599ES (`ixgbe`):** soporte nativo, sin quirks conocidos.
- **AES-NI** presente → WireGuard/IPsec a buena velocidad.
- WAN por **DHCP/IPoE** (sin credenciales); **VLAN 100** en toggle por si la ONT entrega etiquetado (a validar en el swap, ver [doc-26](#doc-26)).
