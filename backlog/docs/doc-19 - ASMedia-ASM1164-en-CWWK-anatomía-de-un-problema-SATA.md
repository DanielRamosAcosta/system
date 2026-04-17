---
id: doc-19
title: 'ASMedia ASM1164 en CWWK: anatomía de un problema SATA'
type: other
created_date: '2026-04-15 20:34'
---

# ASMedia ASM1164 en CWWK: anatomía de un problema SATA

**La causa más probable de la negociación SATA errática (6.0/3.0/1.5 Gbps) en tu configuración es la combinación de Link Power Management (LPM) falsamente anunciado por el ASM1164, ASPM activo en el enlace PCIe, e integridad de señal marginal por la cadena SFF-8643 → backplane.** El kernel Linux trata al ASM1164 como un controlador AHCI genérico sin ningún quirk de velocidad — no existe workaround en el kernel para forzar 6.0 Gbps. Sin embargo, la comunidad ha documentado soluciones efectivas: `libata.force=nolpm` y `pcie_aspm=off` resuelven el problema en la mayoría de los casos reportados con controladores ASM116x. Este informe detalla cada capa del problema, desde el silicio hasta el cable, con commits exactos del kernel, hilos de comunidad y soluciones priorizadas.

---

## 1. El ASM1164 en el kernel Linux: AHCI genérico sin quirks de velocidad

El kernel identifica el ASM1164 con PCI ID **`1b21:1164`** y lo registra en `drivers/ata/ahci.c` como `board_ahci` — la configuración más básica, sin flags especiales:

```c
{ PCI_VDEVICE(ASMEDIA, 0x1164), board_ahci },   /* ASM1164 */
{ PCI_VDEVICE(ASMEDIA, 0x1166), board_ahci },    /* ASM1166 */
```

Esto significa que **no se aplican quirks AHCI_HFLAG ni ATA_FLAG**, no hay inicialización especial del PHY, y no existe workaround de negociación de velocidad. Los device IDs fueron añadidos al kernel aproximadamente en la versión **6.7**. Antes de esto, el ASM1164 se detectaba por la entrada genérica de clase PCI AHCI al final de la tabla `ahci_pci_tbl[]`.

Existen tres commits relevantes que revelan la naturaleza del controlador:

**Commit `0077a504e1a4`** — Limitó los puertos del ASM1166 a 6 (reportaba 32 en el registro AHCI PI). **Commit `9815e3961754`** — Hizo lo mismo para el ASM1064 (reportaba 24, tiene 4). **Commit `6cd8adc3e189`** — **Revirtió ambos parches** en marzo 2024. Autor: Conrad Kostecki (Gentoo). Reviewed-by: Hans de Goede (Red Hat). Razón: el ASM116x maneja Port Multipliers transparentemente reportando puertos "virtuales" en el registro PI (una violación del spec AHCI). Limitar los puertos rompía la detección de discos conectados vía PMP. Este revert confirma un hecho arquitectónico importante: **el ASM1164/1166 implementa PMP de forma interna y transparente**, lo que lo distingue de controladores AHCI Intel puros.

Un quirk PCI adicional fue añadido en enero 2026 — **`quirk_no_bus_reset`** para el ASM1164 — por Alex Williamson (Red Hat):

```c
/* ASM1164 SATA controller does not retrain after bus reset. */
DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_ASMEDIA, 0x1164, quirk_no_bus_reset);
```

Este quirk establece `PCI_DEV_FLAGS_NO_BUS_RESET`, relevante principalmente para passthrough VFIO. El dispositivo soporta PM reset como alternativa. Fue mergeado para kernel 6.19 y backporteado a estables.

### LPM: el bug silencioso que causa la degradación

El hallazgo más crítico proviene de un hilo en el foro de Proxmox (kernel 6.14+): el ASM116x **reporta falsamente soporte de Link Power Management**. Cuando el kernel aplica `lpm-pol 3` (ATA_LPM_MED_POWER_WITH_DIPM), el controlador falla, produce hard resets y degrada la velocidad:

```
ata14: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
ata14: link is slow to respond, please be patient (ready=0)
ata14: limiting SATA link speed to 3.0 Gbps
```

Este es **exactamente el patrón de síntomas del usuario**. La solución confirmada: `libata.force=nolpm`.

El parámetro `libata.force` solo soporta limitar velocidad hacia abajo (`1.5Gbps`, `3.0Gbps`) — **no existe opción para forzar 6.0 Gbps**. Otros parámetros útiles incluyen `nolpm` (deshabilitar LPM), `noncq` (deshabilitar NCQ), y `nohrst`/`nosrst` para controlar tipos de reset.

---

## 2. ASM1164 vs ASM1166: mismo silicio, distinto fusing

| Parámetro | ASM1164 | ASM1166 |
|---|---|---|
| **Puertos SATA** | 4 | 6 |
| **PCIe nativo** | Gen3 x2 | Gen3 x2 |
| **PCI Device ID** | `0x1164` | `0x1166` |
| **Package** | QFN88 10×10mm | QFN88 10×10mm |
| **AHCI Rev** | 1.4 | 1.4 |
| **Cristal** | 25 MHz | 25 MHz |
| **SATA-IO Cert** | Test ID 206042605 | Test ID 206042605 |

La evidencia apunta contundentemente a que **son el mismo dado con diferente binning**: encapsulado idéntico, cristal idéntico, misma interfaz PCIe, mismo firmware tooling (ASM116xMPTool), y comparten una **única entrada de certificación SATA-IO** que agrupa ASM1064, ASM1164, ASM1165 y ASM1166. Existe incluso un ASM1165 (¿5 puertos?) listado en SATA-IO sin página de producto propia en ASMedia, reforzando la hipótesis de binning.

**El ASM1166 no "resuelve" los problemas del ASM1164** — comparten el mismo PHY, el mismo firmware base, y los mismos bugs. El ASM1166 tiene un bug documentado adicional: reporta 32 puertos en el registro AHCI cuando tiene 6, lo que causa tiempos de arranque largos mientras el kernel sondea puertos fantasma.

### Arquitectura confirmada: controlador AHCI real, no port multiplier

El ASM1164 es un **controlador AHCI genuino con PHYs SATA independientes por puerto**. Evidencia:
- Se presenta como `prog-if 01 [AHCI 1.0]` en lspci
- Soporta NCQ independiente en todos los puertos (flags: `64bit ncq sntf stag pm led`)
- Cada puerto negocia su enlace SATA de forma independiente (SStatus separado por puerto en dmesg)
- Soporta Port Multipliers downstream (command-based switching) — fundamentalmente diferente de un JMB575 que comparte un único PHY

Sin embargo, el manejo transparente de PMP por parte del ASM116x (reportando puertos virtuales) lo sitúa en un terreno gris — es AHCI real, pero con comportamiento no estándar en la enumeración de puertos.

---

## 3. La comunidad confirma el patrón: CWWK + ASM1164 = problemas de LPM y ASPM

Los foros de la comunidad revelan un patrón consistente. Estos son los hilos más relevantes, organizados por relevancia directa:

**Proxmox — ASM1166 con kernel 6.14** (forums.proxmox.com/threads/asm1166-issues-with-pve-9-kernel-6-14-11-1-pve.170905/): Síntomas idénticos al usuario. Solución: `libata.force=nolpm`. Un segundo usuario confirmó que también necesitó `pcie_aspm=off` para ASM1064.

**Proxmox — ASM1164 con QNAP TL-D800s** (forums.proxmox.com/threads/pci-passthrough-of-qnap-tl-d800s-asm1164-unreliable-with-sata-ssd.159986/): Configuración con **dos ASM1164** (idéntica al usuario). SSDs fallaban consistentemente a 6.0 Gbps con timeouts y degradación; HDDs funcionaban. El usuario no encontró solución y migró a bare metal.

**Win-Raid / Level1Techs — Firmware ASM116x** (winraid.level1techs.com/t/latest-firmware-for-asm1064-1166-sata-controllers/98543): Un usuario llamado "hallux" (diciembre 2025) pregunta específicamente: *"Compré una placa CWWK con ASM1164 integrado. ¿Alguien ha actualizado el firmware de un controlador integrado?"* — sin respuesta confirmada. Se documentan versiones de firmware desde `200529-000D-02` hasta `221118-0000-00`, con fix para incompatibilidad con chipsets Intel serie 600+.

**TrueNAS Forums** (forums.truenas.com/t/power-efficient-truenas-with-asm1166-sata-controller/21498): Debate sobre confiabilidad. Un usuario operó un ASM1166 en PCIe x1 durante 2 años sin errores. Otro advierte que "tiene un mux, solo soporta 4 discos nativamente" — parcialmente incorrecto pero refleja la desconfianza comunitaria. **El consenso: funcional pero inconsistente**. LSI HBAs recomendados cuando la fiabilidad es prioritaria (+10-15W de consumo).

**ServeTheHome Forums** (forums.servethehome.com/index.php?threads/bios-cwwk-10g-motherboard-cw-at-10g-8p.50958/): Existe un hilo específico para el CW-AT-10G-8P con discusiones sobre BIOS updates — el usuario debería consultarlo directamente.

**Arch Linux Forums** (bbs.archlinux.org/viewtopic.php?id=298150): Un ASM1166 desapareció completamente tras actualizar de kernel 6.9 a 6.10. Causa: cambio en el comportamiento de ASPM. Solución: `pcie_aspm=off`.

---

## 4. Cadena de señal: SFF-8643 + backplane Jonsbo N3 como factor agravante

La negociación SATA ocurre a nivel **PHY** (capa física), completamente independiente del ancho de banda PCIe. La limitación PCIe 3.0 x1 (~985 MB/s) afecta únicamente al throughput agregado, no a la negociación de enlace. **Cada puerto SATA negocia su velocidad independientemente** basándose en la calidad de la señal entre el PHY del ASM1164 y el PHY del disco.

### Análisis del path de señal total

| Segmento | Longitud estimada | Pérdida |
|---|---|---|
| Die ASM1164 → conector SFF-8643 (trazas PCB placa) | 5–10 cm | Baja |
| Conector SFF-8643 (acoplamiento) | — | ~0.5 dB + discontinuidad de impedancia |
| Cable breakout SFF-8643 → SATA | 50 cm (0.5m) ó 100 cm (1m) | Significativa (30 AWG) |
| Conector SATA trasero del backplane | — | ~0.5 dB + discontinuidad |
| Trazas PCB backplane Jonsbo N3 | 7.5–15 cm | Moderada |
| Conector SFF-8482 del disco | — | ~0.5 dB + discontinuidad |
| Trazas PCB del disco al PHY | 5–7.5 cm | Baja |
| **Total con cable 0.5m** | **~70–85 cm + 3 conectores extra** | — |
| **Total con cable 1m** | **~120–135 cm + 3 conectores extra** | — |

La especificación SATA permite **máximo 1 metro de cable** para conexiones internas, y esto no incluye trazas de PCB. **Con un cable de 1m, el path total excede el presupuesto SATA.** Con 0.5m, estás dentro de spec pero con margen reducido — y con **3 conectores adicionales** versus un cable SATA directo (que tiene solo 2).

SATA 6 Gbps **no tiene ecualización ni de-emphasis en la especificación** (a diferencia de SAS). Los niveles de señal son bajos: **500–600 mV en transmisión, 240–600 mV en recepción**. Esto hace a SATA 6G inherentemente más vulnerable a degradación por conectores y cables largos. El ASM1164 soporta "programmable transmitter signal levels" según documentación de productos que lo integran (FebSmart FS-S6-Pro), pero estos ajustes **no son accesibles al usuario** mediante registros PCI estándar o configuración de BIOS.

El backplane Jonsbo N3 es **genuinamente pasivo** — un PCB con trazas directas sin re-drivers ni amplificación. Ha sido verificado funcionando con SAS-3 (12 Gb/s) según usuarios de Level1Techs, lo que sugiere que SATA 6G debería estar dentro de su capacidad. Sin embargo, sigue sumando longitud de traza y conectores a una cadena ya marginal.

### Spread Spectrum Clocking

El ASM1164 soporta SSC en ambas interfaces (PCIe y SATA). SATA usa **5000 ppm down-spread** con modulación de 30-33 kHz. En un sistema con integridad de señal adecuada, SSC no debería causar fallos de negociación. Pero **cuando se combina con señal marginal**, SSC puede empujar el circuito de recuperación de reloj del disco más allá de su ancho de banda de tracking, contribuyendo a fallos de negociación. Si el BIOS CWWK expone la opción (generalmente en Chipset → PCH Configuration o Advanced → Clock Configuration), vale la pena desactivar SSC como prueba.

---

## 5. Intel i3-N355 (Twin Lake): 9 lanes PCIe 3.0 y un ASM1164 operando a la mitad de su diseño

El i3-N355 es **Twin Lake**, un refresh de Alder Lake-N lanzado en Q1 2025. Arquitecturalmente idéntico: 8 E-cores Gracemont, Intel 7, SoC con PCH integrado (sin chipset externo). Dispone de **9 lanes PCIe 3.0** — ninguna Gen4 o Gen5.

### Distribución de lanes en la CW-AT-10G-8P

| Dispositivo | Lanes PCIe |
|---|---|
| AQC113C 10GbE | Gen3 x1 |
| Intel i226-V 2.5GbE #1 | Gen3 x1 |
| Intel i226-V 2.5GbE #2 | Gen3 x1 |
| **ASM1164 SATA #1** (4 puertos, SFF-8643) | **Gen3 x1** |
| **ASM1164 SATA #2** (4 puertos, SFF-8643) | **Gen3 x1** |
| M.2 NVMe #1 | Gen3 x1 |
| M.2 NVMe #2 | Gen3 x1 |
| PCIe x1 slot / M.2 E-Key (compartido) | Gen3 x1 |
| (Reservado/Flex) | 1 lane |

**No se usa PCIe switch** — las 9 lanes se asignan directamente desde los root ports del PCH integrado. Dato crítico: **el ASM1164 está diseñado para PCIe Gen3 x2** (~1970 MB/s), pero en esta placa opera a **Gen3 x1** (~985 MB/s). Esto implica la mitad del ancho de banda de diseño, un ratio de sobresubscripción de **2.4:1** con 4 puertos SATA a velocidad máxima. Para HDDs (~150-200 MB/s cada uno), 4 discos a máximo throughput caben en el presupuesto x1. Para SSDs, incluso 2 saturan el enlace.

Reiterando: **esta limitación de ancho de banda no afecta la negociación de velocidad SATA** — solo limita throughput agregado.

### ASPM como vector de inestabilidad

ASPM es un problema documentado en plataformas Alder Lake-N con dispositivos ASMedia. Usuarios de Hardwareluxx confirmaron que ASM1166/ASM1164 en slot M.2 impiden que el CPU entre en C-states profundos (se queda en C3 en lugar de C8). En Arch Linux, un ASM1166 desapareció completamente cuando ASPM cambió de comportamiento en kernel 6.10. El mecanismo de fallo plausible: ASPM L1 causa latencia excesiva de salida del estado de bajo consumo → el ASM1164 experimenta problemas internos (hang de firmware, corrupción de estado) → emite COMRESET SATA o falla en responder a negociaciones PHY → cascade de resets que degrada la velocidad.

No se localizó un documento de errata PCIe específico para Alder Lake-N/Twin Lake (Intel EDC ID 759603 es el datasheet, pero el specification update con errata requiere acceso directo a Intel EDC).

---

## 6. Soluciones priorizadas: de lo más fácil a lo más drástico

### Paso 1 — Parámetros de kernel (probabilidad alta de éxito)

Añadir a la configuración de boot de NixOS (en `boot.kernelParams`):

```nix
boot.kernelParams = [
  "libata.force=nolpm"
  "pcie_aspm=off"
];
```

`libata.force=nolpm` es la solución con **mayor tasa de éxito documentada** para ASM116x. Desactiva Link Power Management que el controlador anuncia falsamente. `pcie_aspm=off` desactiva ASPM globalmente, eliminando la fuente de inestabilidad PCIe. Si esto resuelve el problema, se puede refinar deshabilitando ASPM solo para los dispositivos ASMedia vía sysfs.

### Paso 2 — Si persiste, agregar más parámetros

```nix
boot.kernelParams = [
  "libata.force=nolpm,noncq"
  "pcie_aspm=off"
  "ahci.mobile_lpm_policy=0"
];
```

Deshabilitar NCQ (Native Command Queuing) elimina otra fuente de timeouts documentada, especialmente con discos WD Gold. `ahci.mobile_lpm_policy=0` previene transiciones de estado de potencia inesperadas.

### Paso 3 — Forzar 3.0 Gbps como workaround

Si el paso 2 no resuelve completamente, forzar la velocidad a 3.0 Gbps elimina la negociación problemática:

```
libata.force=3.0Gbps,nolpm
```

Esto sacrifica throughput máximo por disco (~300 MB/s → ~375 MB/s teórico a 3G, en la práctica HDDs no superan ~200 MB/s, así que el impacto real es nulo para HDDs). Se puede targeting por puerto: `libata.force=5:3.0Gbps,6:3.0Gbps` para afectar solo puertos específicos.

### Paso 4 — Verificar integridad de señal

Usar **cables breakout SFF-8643 de 0.5m** (no 1m). Marcas recomendadas: Cable Matters, 10Gtek. Verificar que son cables **forward breakout** (controlador → discos). Verificar que los conectores están firmemente asentados en ambos extremos. Revisar SMART atributo **C7 (Interface CRC Error Count)** en cada disco: `smartctl -A /dev/sdX | grep -i crc`. Si hay errores CRC, el problema es definitivamente de señal.

### Paso 5 — Configuración de BIOS CWWK

Buscar y modificar en BIOS AMI:
- **SATA Mode**: Confirmar AHCI (no IDE)
- **PCIe ASPM**: Desactivar si está expuesto
- **Spread Spectrum Clocking**: Desactivar si disponible
- **PCIe Link Speed**: Probar forzar Gen2 en lugar de Auto para los slots del ASM1164
- Contactar a CWWK para BIOS actualizado (soporte reportado como lento/inexistente por usuarios)

### Paso 6 — Link Power Management per-host

Establecer manualmente política de máximo rendimiento para cada host SCSI del ASM1164:

```bash
for host in /sys/class/scsi_host/host*; do
  echo max_performance > "$host/link_power_management_policy"
done
```

En NixOS, esto se puede automatizar con un servicio systemd o udev rule.

### Paso 7 — Firmware del ASM1164

El firmware **es actualizable** con **RomUpdWin.exe** (Windows) o **ASM116xMPTool**. Versión más reciente conocida: `221118-0000-00` (noviembre 2022, hot-plug habilitado). **No existe herramienta Linux para flashear**. Para un controlador integrado en placa CWWK, nadie ha confirmado éxito en actualizar firmware todavía. Se necesitaría Windows (baremetal o USB bootable) y el riesgo de brickear el controlador integrado es real.

### Paso 8 — Reemplazo por HBA LSI (solución definitiva)

Un LSI **9207-8i** o **9211-8i** (flasheado a IT mode) resolvería todos los problemas de negociación. Los HBAs LSI usan drivers mpt2sas/mpt3sas (maduros, probados en producción), señalizan a niveles SAS (~1V vs ~600mV SATA), e incluyen ecualización/de-emphasis. El 9211-8i consume **~6-8W** desde el slot PCIe. Requiere un slot PCIe x8 físico (negocia x4 o x1 eléctricamente) — la CW-AT-10G-8P tiene un slot PCIe x1 abierto que podría funcionar con una tarjeta de bajo perfil, pero la compatibilidad física dentro del Jonsbo N3 requiere verificación. El N3 soporta GPUs de hasta 280mm y tiene 2 slots de expansión PCIe.

---

## Diagnóstico recomendado antes de aplicar soluciones

Ejecutar estos comandos para caracterizar el estado actual y facilitar troubleshooting:

```bash
# Estado de negociación SATA de todos los puertos
dmesg | grep -E "(SATA link|SStatus|SControl|limiting)"

# Verificar ASM1164 PCIe link status
lspci -vvs $(lspci | grep 1b21:1164 | awk '{print $1}') | grep -E "(LnkCap|LnkSta|LnkCtl|ASPM)"

# Errores PCIe AER
dmesg | grep -i "aer\|pcie.*error"

# LPM policy actual
for h in /sys/class/scsi_host/host*/link_power_management_policy; do echo "$h: $(cat $h)"; done

# SMART CRC errors en todos los discos
for d in /dev/sd?; do echo "=== $d ==="; smartctl -A "$d" 2>/dev/null | grep -i "crc\|interface"; done

# ASPM status per-device
lspci -vv | grep -A2 "LnkCtl:"
```

Los valores `SStatus` en dmesg revelan la velocidad negociada: **`133` = 6.0 Gbps**, `123` = 3.0 Gbps, `113` = 1.5 Gbps. El campo `SControl 300` indica que no hay limitación de velocidad impuesta por software.

---

## Conclusión: un problema multicapa con solución probable en software

El problema tiene tres capas convergentes. **Primera y más probable**: el ASM1164 anuncia falsamente soporte de LPM, y kernels recientes lo honran, causando inestabilidad de enlace SATA que se manifiesta como degradación de velocidad — solucionable con `libata.force=nolpm`. **Segunda**: ASPM en el enlace PCIe entre el PCH del N355 y el ASM1164 puede causar latencias de salida de L1 que desestabilizan el controlador — solucionable con `pcie_aspm=off`. **Tercera y subyacente**: la cadena de señal (trazas PCB → SFF-8643 → cable breakout → backplane pasivo → disco) opera cerca del límite del presupuesto SATA 6G, especialmente con cables de 1m, reduciendo el margen para tolerar cualquier perturbación.

La investigación no encontró **ningún quirk de negociación de velocidad en el kernel** para ASM116x — el silicio se trata como AHCI genérico. Tampoco se encontró errata PCIe específica de Intel para Alder Lake-N/Twin Lake que explique el problema. El ASM1164 no es un port multiplier, es un controlador AHCI real, pero su implementación tiene idiosincrasias (reporte de 32 puertos, LPM falso, fallo de retrain post-reset) que el kernel ha ido parcheando caso por caso.

La recomendación es **empezar por `libata.force=nolpm pcie_aspm=off`** — esta combinación tiene la tasa de éxito más alta documentada en la comunidad. Si persiste el problema, usar cables de 0.5m, forzar 3.0 Gbps, y verificar errores CRC vía SMART. El reemplazo por HBA LSI es la solución definitiva si las medidas de software no son suficientes.
