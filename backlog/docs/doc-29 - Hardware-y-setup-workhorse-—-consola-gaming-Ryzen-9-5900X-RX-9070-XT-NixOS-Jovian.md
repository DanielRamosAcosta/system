---
id: doc-29
title: >-
  Hardware y setup: workhorse — consola gaming Ryzen 9 5900X + RX 9070 XT (NixOS
  + Jovian)
type: other
created_date: '2026-08-23 20:39'
---
Ficha del nuevo host **workhorse**: sobremesa gaming reconvertido en "consola" tipo SteamOS mediante Jovian-NixOS. Gestionado por este flake en `hosts/workhorse/`. Datos leídos en vivo por SSH (`dani@192.168.1.36`, hostname `workhorse`) el 2026-08-23.

- Rol: consola de salón / máquina de juego (Steam Big Picture con Gamescope, arranque directo a Steam)
- Arquitectura: `x86_64-linux`
- OS: NixOS 26.11 (Zokor) sobre `nixpkgs-unstable` (no en 25.11 como el resto de hosts, ver notas)
- Se alcanza por SSH en `192.168.1.36` (DHCP)

## CPU

| Spec | Valor |
|---|---|
| Modelo | AMD Ryzen 9 5900X (Zen 3, Vermeer) |
| Núcleos / hilos | 12 cores / 24 threads (1 socket) |
| Frecuencia | 559 MHz mín. — 5162 MHz máx. medido (boost) |
| Microcódigo | `hardware.cpu.amd.updateMicrocode` activo |
| Virtualización | `kvm-amd` cargado (SVM) |
| ISA destacada | AVX2, AES, SHA-NI, BMI2, `vaes`, `vpclmulqdq` |

## GPU

| Spec | Valor |
|---|---|
| Modelo | AMD Radeon RX 9070 XT (RDNA 4, Navi 48) |
| PCI ID | `1002:7550`, driver `amdgpu` |
| VRAM | 16 GB GDDR6 (`15.92 GiB` reportados) |
| Enlace | PCIe 5.0 x16 (`32.0 GT/s`, width 16) |
| KMS | `amdgpu` forzado en `initrd.kernelModules` (arranque temprano para Plymouth) |
| Aceleración | `hardware.graphics` con `enable32Bit` (Steam/Proton 32-bit) |

## Memoria

| Spec | Valor |
|---|---|
| RAM total | 64 GB DDR4 (62 GiB útiles) |
| Módulos | 2× 32 GB Corsair Vengeance LPX `CMK64GX4M2D3600C18` (kit de 2) |
| Velocidad | 3600 MT/s (configurada, perfil XMP/DOCP) |
| Slots | Poblados `DIMM_A2` y `DIMM_B2` (dual channel) |
| Swap | zram (31 GiB comprimido en RAM), `zramSwap.enable` |

## Placa base

| Spec | Valor |
|---|---|
| Fabricante | ASUSTeK COMPUTER INC. |
| Modelo | ProArt B550-CREATOR (Rev X.0x) |
| Chipset | AMD B550 (socket AM4) |
| BIOS | American Megatrends `2403` (2021-06-16), UEFI 2.70 |
| TPM | TPM 2.0 presente y activo |

## Almacenamiento

| Disco | Modelo | Tamaño | Uso |
|---|---|---|---|
| `nvme0n1` | Samsung SSD 990 PRO 4TB | 3.6 TB | Disco de sistema (NixOS) |
| `nvme1n1` | Sabrent Rocket 4.0 1TB | 931 GB | Partición NTFS (datos/Windows previo), **no montado** |

Particionado del disco de sistema (declarativo con disko, `hosts/workhorse/disko.nix`):

| Partición | Tamaño | FS | Montaje |
|---|---|---|---|
| `nvme0n1p1` (ESP) | 1 GB | vfat (`umask=0077`) | `/boot` |
| `nvme0n1p2` (root) | resto (3.6 TB) | ext4 | `/` (uso 3%, 96 GB usados) |

> El segundo NVMe (Sabrent, NTFS) es del sistema anterior y de momento no forma parte de la config declarativa.

## Red

| Interfaz | Chip / driver | Estado | MAC |
|---|---|---|---|
| `enp60s0` | Intel 2.5GbE (`igc`) | **UP**, negociado a 1000 Mbps | `fc:34:97:a5:ec:dd` |
| `enp59s0` | Intel 2.5GbE (`igc`) | DOWN (sin cable) | `fc:34:97:a5:ec:dc` |
| `wlp58s0` | Intel Wi-Fi 6E AX210 (`iwlwifi`, `8086:2725`) | DOWN | — |

- La ProArt B550-Creator trae **dos NIC Intel 2.5GbE** (ambas `igc`) + Wi-Fi 6E.
- Gestión de red con `NetworkManager`. Actualmente conectada por cable a un enlace de 1 Gbps.

## Software / setup NixOS

Config en `hosts/workhorse/` (agregada en `default.nix`):

| Módulo | Función |
|---|---|
| `configuration.nix` | Boot, red, locale (`es_ES`, `Atlantic/Canary`, teclado `es`), SSH, flakes, kernel `linuxPackages_latest` |
| `hardware-configuration.nix` | Módulos initrd (nvme, ahci, xhci), `kvm-amd`, plataforma x86_64 |
| `disko.nix` | Particionado declarativo del Samsung 990 PRO |
| `gaming.nix` | Jovian Steam + Gamescope, Proton-GE, GameMode, gráficos 32-bit |
| `plymouth-steam.nix` | Tema Plymouth de Steam Deck (arranque animado) |
| `secure-boot.nix` | Secure Boot con lanzaboote + sbctl |
| `users.nix` | Usuario `dani` (inmutable, sudo NOPASSWD, claves SSH) |
| `secrets.nix` | agenix (password hasheada de `dani`) |

### Experiencia tipo consola (Jovian-NixOS)

- `jovian.steam` con `autoStart` y `desktopSession = "gamescope-wayland"`: arranca directo a Steam en Big Picture bajo Gamescope, usuario `dani`.
- `devices.steamdeck.enable = false` (no es una Steam Deck real, solo la UI).
- `programs.steam` con `proton-ge-bin` como capa de compatibilidad extra.
- `programs.gamemode` para optimización durante el juego.

### Arranque instantáneo y splash

- `boot.loader.timeout = 0`, `consoleLogLevel = 0`, `initrd.verbose = false`.
- `kernelParams`: `quiet splash udev.log_level=3 vt.global_cursor_default=0`.
- `amdgpu` en initrd para KMS temprano → la animación Plymouth de Steam Deck aparece desde el primer instante.

### Secure Boot (lanzaboote)

- **Secure Boot habilitado y activo** (`bootctl`: `Secure Boot: enabled (user)`).
- Reemplaza `systemd-boot` por `lanzaboote` (`lib.mkForce (!secureBoot)`), PKI en `/var/lib/sbctl`.
- Claves sbctl generadas e inscritas (`/var/lib/sbctl/keys`).
- ⚠️ Ver post-mortem **doc-28**: firmar el kernel manualmente con `sbctl sign` rompe el arranque con lanzaboote (`SECURITY_VIOLATION`) — lanzaboote ya gestiona la firma, no hay que firmar a mano.

## Estado térmico (lectura en vivo, idle/uso ligero)

| Sensor | Temp |
|---|---|
| CPU (`k10temp` Tctl) | 67 °C |
| GPU (`amdgpu` edge/hotspot/mem) | 40 / 48 / 66 °C |
| NVMe (990 PRO) | 38–44 °C |
| Placa (`asusec`) | 54–55 °C |
| Wi-Fi (`iwlwifi`) | 32 °C |

> Temperaturas de reposo/carga ligera (uptime ~20 min). El Tctl del 5900X ~67 °C en idle es normal (Zen 3 reporta el core más caliente).

## Notas

- **Corre en `nixpkgs-unstable`**, no en la 25.11 estable del resto de hosts, porque el soporte de RDNA 4 (RX 9070 XT / Navi 48) y Jovian necesitan kernel y Mesa recientes (kernel `7.2.0` al momento de la ficha). Ver memoria del proyecto `host-workhorse`.
- El nombre "workhorse" es irónico: es la máquina más potente de la casa pero su trabajo principal es jugar.
- El segundo SSD (Sabrent 1TB NTFS) queda como remanente del sistema anterior; pendiente decidir si se integra en la config declarativa o se reformatea.
