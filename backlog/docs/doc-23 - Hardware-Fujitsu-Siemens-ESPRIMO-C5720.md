---
id: doc-23
title: 'Hardware: Fujitsu Siemens ESPRIMO C5720'
type: other
created_date: '2026-08-15 12:10'
---
# Hardware: Fujitsu Siemens ESPRIMO C5720

Documentación del hardware del `siemens`, el workstation x86_64 con NixOS + Sway. Datos leídos en vivo por SSH (`ssh siemens`, hostname `nixos`, IP `192.168.1.47`). Es un PC de oficina de 2008 (small form factor) reutilizado.

- Fabricante: FUJITSU SIEMENS
- Modelo: ESPRIMO C5720
- Número de serie del equipo: `YKCS021172`
- Placa base: `D2764-A1` (versión `S26361-D2764-A1`)
- Chasis: desktop (SFF)

> `dmidecode` no está instalado en el sistema; los datos DMI (RAM, serial, placa) se leyeron con `nix shell nixpkgs#dmidecode`. El resto se obtuvo de `hostnamectl`, `lscpu`, sysfs (`/sys/bus/pci`) y `lsblk`.

## CPU

| Spec | Valor |
|---|---|
| Modelo | Intel Core 2 Duo E8300 @ 2.83 GHz |
| Microarquitectura | Wolfdale (45 nm), family 6, model 23, stepping 6 |
| Socket | LGA 775 |
| Núcleos / hilos | 2 cores / 2 hilos (sin Hyper-Threading) |
| Frecuencia | 2.83 GHz máx, 2.00 GHz mín (EIST/SpeedStep) |
| Caché L1 | 64 KiB datos + 64 KiB instrucciones (2 instancias) |
| Caché L2 | 6 MiB (compartida) |
| BogoMIPS | 5652.66 |
| Features destacadas | vmx (VT-x sin uso: KVM reporta VMX unsupported vía BIOS), ssse3, sse4_1, est, tm2, xd/nx, lm (64-bit) |

> Vulnerabilidades: CPU antigua sin microcódigo actualizado. `Mds: Vulnerable` (no microcode), `Spec store bypass: Vulnerable`, `Mmio stale data: Unknown`. Mitigaciones parciales por software (PTI, retpolines). Aceptable para uso doméstico/LAN, no para exponer a Internet.

## Memoria

| Spec | Valor |
|---|---|
| RAM total | 8 GB (7.7 GiB útiles) — **máximo de la placa** |
| Configuración | 4 × 2 GB DDR2, los **4 slots ocupados** (Slot-1/3 en canal A, Slot-2/4 en canal B → dual channel) |
| Tipo / velocidad | DDR2 **667 MT/s** (PC2-5300), sin ECC, DIMM 64-bit |
| Fabricante módulos | Genéricos/sin marca (SPD sin datos reales: `48spaces`, part number de relleno `0123...`) |
| Swap | 10 GiB en partición `sda2` |
| En uso (idle) | 857 MiB usados, 5.4 GiB libres, 1.8 GiB buff/cache |

> La RAM ya está al máximo que soporta la placa (8 GB, 4 devices según DMI type 16); **no es ampliable**. Los módulos son de marca genérica.

## Chipset y placa

| Componente | ID PCI | Detalle |
|---|---|---|
| Northbridge / DRAM controller | `8086:29d0` | Intel 4 Series Chipset (Q43/Q45) DRAM Controller |
| GPU integrada | `8086:29d2` | Intel 4 Series Integrated Graphics (GMA 4500), driver `i915` |
| Southbridge LPC | `8086:2918` | Intel ICH9, driver `lpc_ich` |
| SATA (IDE mode) | `8086:2921` / `8086:2926` | Intel ICH9 SATA, driver `ata_piix` |
| Audio | `8086:293e` | Intel ICH9 HD Audio, driver `snd_hda_intel` |
| SMBus | `8086:2930` | Intel ICH9 SMBus, driver `i801_smbus` |
| USB | ICH9 UHCI ×6 + EHCI ×2 | `uhci_hcd` + `ehci-pci` |

- Firmware (BIOS): versión `6.00 R1.12.2764.A1`, fecha **2008-06-05** (18+ años).

## Gráficos

| Spec | Valor |
|---|---|
| GPU | Intel GMA 4500 (integrada en el chipset 4 Series) |
| Driver | `i915` |
| Subsystem | `1734:10fc` (Fujitsu Siemens) |
| Salidas | VGA / DVI de la placa (SFF de oficina) |

> Suficiente para el escritorio Sway/Wayland con compositing básico; sin aceleración para cargas 3D modernas.

## Red

| Interfaz | Chip | Driver | Estado |
|---|---|---|---|
| `enp4s0` (Ethernet) | Broadcom NetXtreme BCM5722 (`14e4:167a`) | `tg3` | **UP**, enlace a **1000 Mbps**, MAC `00:19:99:39:fd:60`, IP `192.168.1.47/24` |
| `wlp5s5` (WiFi) | Atheros AR5008/AR5006 (`168c:001b`) | `ath5k` | DOWN (sin uso), MAC `00:17:3f:78:8b:05` |

- La Ethernet **Broadcom BCM5722** es la interfaz principal, PCIe Gigabit, negociada a 1 Gbps.
- La WiFi es una **Atheros** (tarjeta añadida, subsystem Belkin `1799:3000`) por PCI; actualmente sin portadora/desactivada.
- IPv6 ULA activo en `enp4s0` (`fd40:11a1:5fe1:1037::/64`).

## Almacenamiento

| Spec | Valor |
|---|---|
| Disco | Hitachi Travelstar HTS545050A7E380 (5K500.B), 2.5" **5400 rpm**, SATA, 500 GB (465.8 GiB) |
| `sda1` | 455.8 GiB ext4 → `/` (uso 16%, 67 GB usados, 359 GB libres) |
| `sda2` | 10 GiB swap |
| Óptico | `sr0` — HL-DT-ST DVDRAM GSA-T30N (grabadora DVD-RAM slim) |

> Es un HDD mecánico de portátil (rotational=1), no SSD — el cuello de botella de I/O del equipo.

## Software

| Spec | Valor |
|---|---|
| OS | NixOS 25.11 (Xantusia) |
| Kernel | `6.12.76` (SMP PREEMPT_DYNAMIC, x86_64), 2026-03-05 |
| Entorno | Sway/Wayland + greetd, terminal foot, shell fish, theming stylix |
| Gestión | NixOS + home-manager (usuario `dani`), config en `hosts/siemens/` |

## Benchmarks (2026-08-15)

El sistema NixOS viene pelado (sin `openssl`, `sysbench`, `hdparm`); se usó `nix shell nixpkgs#sysbench nixpkgs#openssl` (shell efímero) para las pruebas de CPU/memoria y las herramientas base (`dd`, `curl`, `sha256sum`) para el resto. Valores orientativos.

### CPU (Core 2 Duo E8300 @ 2.83 GHz, 2 cores)

| Prueba | 1 core | 2 cores | Nota |
|---|---|---|---|
| sysbench cpu (primos ≤ 20000) | 400.2 events/s | 795.8 events/s | Escala ~1.99× (2 cores reales sin HT), latencia media 2.50 ms/evento |
| openssl SHA-256 (bloques 16 KiB) | ~212 MB/s | — | 25.7 MB/s en bloques de 16 B |
| openssl AES-256-CBC (bloques 16 KiB) | ~178 MB/s | — | **Sin AES-NI** (Wolfdale es anterior); cifrado por software |
| sha256sum sobre `/dev/zero` | ~164 MiB/s | ~251 MiB/s agregado | Coreutils, menos optimizado que openssl |

> CPU de 2008: rinde bien para escritorio ligero y tareas de un solo hilo, pero sin instrucciones AES-NI el cifrado en disco/red va por software. Escala casi lineal a 2 hilos.

### Memoria (DDR2, ~8 GB)

| Prueba | Resultado |
|---|---|
| sysbench memory lectura secuencial (1 hilo, bloques 1 MiB) | ~11.2 GiB/s |
| sysbench memory escritura secuencial (1 hilo) | ~11.6 GiB/s |
| sysbench memory escritura (2 hilos) | ~17.1 GiB/s |
| `dd` 4 GiB zero → null (bs=1M) | ~11.8 GB/s (indicativo, no ancho de banda real) |

### Disco (Hitachi 5K500.B, 2.5" 5400 rpm SATA, ext4 en `/`)

| Prueba | Resultado |
|---|---|
| Escritura secuencial (`conv=fdatasync`) | ~39 MB/s |
| Escritura secuencial (`oflag=direct`) | ~59 MB/s |
| Lectura secuencial | ~58 MB/s |

> HDD mecánico de portátil: es el gran cuello de botella del equipo. Un SSD SATA multiplicaría por ~5-10 estas cifras.

### Red (Broadcom BCM5722, enlace 1 Gbps, single-stream)

| Prueba | MB/s | Mbps | Servidor / destino |
|---|---|---|---|
| Descarga | 59.97 MB/s | ~480 Mbps | OVH `proof.ovh.net` (FR) |
| Subida | 35.19 MB/s | ~281 Mbps | Cloudflare `__up` |
| Latencia | — | 14.4 ms avg, 0% pérdida | 1.1.1.1 |
| Latencia | — | 11.0 ms avg, 0% pérdida | 8.8.8.8 |
| Latencia LAN | — | 0.45 ms avg, 0% pérdida | gateway 192.168.1.1 |

> Las descargas son de **un solo flujo TCP**; el techo real del enlace Gigabit es mayor con múltiples flujos. Cloudflare `__down` devuelve HTTP 403 desde esta IP (usar OVH para medir descarga). El enlace Ethernet negocia a 1000 Mbps.

## Notas

- Máquina de oficina Fujitsu Siemens de ~2008 reutilizada como workstation ligero.
- El BIOS de 2008 no reporta datos DMI accesibles sin `dmidecode`; no se pudieron leer módulos de RAM ni número de serie por esta vía.
- `sensors` (lm_sensors) no está configurado; sin lectura de temperaturas.
- El sistema es NixOS minimal: para benchmarks o utilidades puntuales usar `nix shell nixpkgs#<paquete>` en vez de instalarlas permanentemente.
