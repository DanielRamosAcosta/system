---
id: doc-31
title: >-
  Post-mortem: reinicios espontáneos del NAS por hard lockup de deep C-state
  (Intel N355)
type: other
created_date: '2026-11-13 16:23'
---
# Post-mortem: reinicios espontáneos del NAS por hard lockup de deep C-state (Intel N355)

**Fecha del incidente:** recurrente (jun–nov 2026); episodio analizado a fondo el 2026-11-12 ~03:00 UTC
**Fecha del diagnóstico y la mitigación:** 2026-11-13
**Host afectado:** `nixos` (NAS) — `192.168.1.200`, gestionado en `infra/system` → `hosts/nas/`
**SoC:** Intel Core 3 **N355** (Alder Lake-N / Twin Lake, 8 cores)
**Estado:** causa raíz identificada · mitigación aplicada (`intel_idle.max_cstate=2`) · **pendiente validación estadística A/B (6–8 semanas desde 2026-11-13)**

---

## Resumen ejecutivo

El NAS se reiniciaba solo de forma irregular (al principio cada varias semanas, luego **cada 4–14 días** y acelerando). Cada caída era un **hard lockup del kernel**: las 8 cores dejaban de contabilizar tiempo simultáneamente y en seco, el sistema quedaba congelado ~30–50 s y un **reset por hardware (watchdog iTCO de 30 s)** lo rearrancaba. Sin `panic`, sin crash dump, sin EDAC, con alimentación de la UPS perfecta.

La causa raíz es el **deep C-state hang** conocido de los SoC Intel N-series (N100/N150/N305/**N355**): al entrar en un estado de reposo profundo (C6/C8/**C10**), la CPU ocasionalmente **no despierta**. Es un fallo de silicio intermitente. El detonante que lo pasó de "marginal pero estable" a "crashea cada pocos días" fue el **salto de kernel 6.12.76 → 6.12.93** (3-sep-2026), que casi con seguridad cambió el comportamiento del gobernador de `intel_idle`.

**Mitigación aplicada:** limitar los C-states a **POLL + C1E** (`intel_idle.max_cstate=2`), bloqueando C6/C8/C10. Coste térmico despreciable (~+2 °C en idle). Queda validar por estadística: antes caía cada 4–14 días, si aguanta 6–8 semanas limpio → demostrado.

---

## 1. Síntoma de cara al usuario

Llega de vez en cuando una alerta **"Pod Not Ready"** (Grafana, regla `Infrastructure/Pod Not Ready`, uid `efg84wo4axnnkf`, severidad `critical`), sobre:

```promql
kube_pod_container_status_waiting_reason{reason=~"CrashLoopBackOff|ImagePullBackOff|ErrImagePull|CreateContainerConfigError"} == 1
```

**Ojo con la etiqueta engañosa:** en la alerta aparece `kube-state-metrics`, pero eso es solo la *fuente* de la métrica, no el pod afectado. En el episodio real los pods que la dispararon fueron `deluge-exporter`, `grafana`, `immich-exporter` y `sftpgo`.

**La alerta es un efecto secundario, no la causa.** Cuando el host se reinicia, arrancan ~100 contenedores a la vez; unos pocos que dependen de otros (Postgres, crowdsec-lapi…) entran en CrashLoopBackOff durante >5 min hasta que sus dependencias levantan → salta la alerta → se recuperan solos. **El problema real son los reinicios del host.**

---

## 2. Cronología del episodio 2026-11-12 (UTC; Madrid = UTC+1)

| Hora UTC | Evento |
|---|---|
| 02:59:01 | Último log del kernel: error rutinario de k3s sobre `crowdsec-agent`. Nada anómalo. |
| **02:59:45** | **Congelación**: los contadores de CPU de las 8 cores dejan de avanzar en seco (todos los modos a 0). |
| 02:59:45 – 03:00:36 | Host congelado / caído (~51 s). Hueco en toda la telemetría. |
| 03:00:36 | `system boot` — el host arranca de nuevo (reset del iTCO). |
| 03:02:30+ | Vuelve la telemetría; `load` alto (17→28) por el arranque masivo de contenedores; se normaliza hacia 04:05–04:10 Madrid. |

---

## 3. Evidencia

### 3.1 Alimentación: descartado corte de luz
UPS Salicru (vía NUT / `nut-exporter`), ventana 02:45–03:10 UTC: `input_voltage` = **243,5 V constante** hasta la caída; `battery_charge` = **100 %**; estado `OL` (nunca pasó a batería `OB`). Si hubiera sido un corte, la tensión caería a 0 y la batería descargaría. No ocurrió.

### 3.2 CPU: la prueba del hard lockup
`rate(node_cpu_seconds_total[1m])` por modo, suma de las 8 cores: a las 02:59:45 **todos los modos (idle, user, system, iowait, irq, softirq) caen a 0 a la vez**. No es "CPU al 100 %" (eso sería `idle→0` con `user`/`system` altos); es el contador **dejando de incrementarse** → kernel congelado. El `load1` venía plano (0,6–1,3): sin escalada previa. Normal → congelación total → reset.

> Cualquier dashboard que calcule el uso como `100 − idle` mostrará un **falso pico al 100 %** en ese instante: artefacto del contador `idle` congelado, no carga real.

### 3.3 Logs del host: muerte silenciosa
- El journal corta en seco a las 02:59:01 **sin secuencia de apagado de systemd**.
- **Sin kernel panic, oops, hung_task, ni soft/hard lockup logueado.**
- **`/sys/fs/pstore` vacío** — ningún crash dump.
- **Sin OOM.**

### 3.4 EDAC / IBECC: falso positivo del driver
El NAS tiene **In-Band ECC (IBECC)** vía driver `igen6`. Aparece `HANDLING IBECC MEMORY ERROR ADDR 0x7fffffffe0` **solo durante el arranque**, siempre pegado a `igen6_probe+0x1a9/0x810 [igen6_edac] mapping multiple BARs`. Es el **falso positivo conocido del probe de `igen6`**, idéntico en cada boot. **No hay ningún error IBECC durante la operación normal** ni cerca del cuelgue.

### 3.5 Validación por SSH (2026-11-13) — hallazgos adicionales
Al revisar el host en vivo aparecieron datos que el informe inicial no tenía:

- **Watchdog hardware iTCO activo (30 s):** `iTCO_wdt: Found a Intel PCH TCO device (Version=6)`, `Timeout: 30 seconds`. **Esto es lo que resetea la placa**: cuando el kernel se congela deja de alimentar el iTCO y a los ~30 s hace un reset hardware silencioso. Explica el hueco de ~51 s y por qué no hay panic.
- **Parámetros de kernel ya presentes:** `nmi_watchdog=1` ya activo, `panic=10` y `panic_on_oops=1` ya puestos (defaults de NixOS). El único que faltaría para convertir el lockup en dump es `hardlockup_panic=1` (hoy a `0`).
- **Microcódigo ya se actualiza:** `0x1a → 0x21` temprano. `hardware.cpu.intel.updateMicrocode` funciona.
- **Journal persistente** (19 boots retenidos, `Storage=persistent`, `/var/log/journal`). `efi_pstore` registrado y **probado funcional** (hay volcados de ago-2025).
- **Sin errores de almacenamiento:** ni AER/PCIe, ni NVMe, ni btrfs, ni ATA I/O cerca de las caídas. Los 4 discos (2×10 TB + 2×26 TB) enumeran limpios. Refuerza que el fallo está en CPU/idle, no en disco.
- **Térmicas descartadas:** paquete 44 °C, SoC 31 °C, SPD 37 °C, ventiladores girando. Cero throttling.

---

## 4. Diagnóstico: deep C-state hang de los Intel N-series

El síntoma coincide **punto por punto** con el fallo documentado de estos SoC de bajo consumo:

| NAS | Bug conocido N-series |
|---|---|
| Congelación en seco, sin SSH ni ping | "hard-freezes at random, usually while idle" |
| Crashes a las 03–04 h con `load` plano | "the CPU tries to drop into a deep idle C-state, it never wakes" |
| Sin panic/oops/MCE, logs cortados | "the logs just stop dead mid-idle — no panic, no oops, no MCE" |
| Cada 1–2 semanas, irregular | "freezes at random" |
| Intel **N355** (Alder Lake-N) | N100 / N150 / N305 / **N355** mini-PCs |

Confirmado en el hardware: el N355 usa `intel_idle` con **C6, C8 y C10** habilitados, y es en **C10 (el más profundo)** donde más tiempo pasa. El cuelgue ocurre al intentar despertar de uno de esos estados profundos.

### Correlación con el update (el detonante)
Histórico de uptime por kernel:

- Kernel **6.12.76**: Abr 15 → Jul 17 (**93 días** sin caídas), Jul 24 → Sep 3 (**40 días**, terminó en apagado **limpio** = el upgrade de kernel).
- Kernel **6.12.93** (desde 3-sep): Sep 3 → Oct 4 (31 d), luego Oct 4 → 18 → 25 → 31 → Nov 8 → Nov 12, **sucio cada 4–14 días y acelerando**.

No es un bug *introducido* por el update: es una **debilidad de silicio** intermitente. El salto 6.12.76 → 6.12.93 (17 releases del LTS) cambió el comportamiento del gobernador / tablas de `intel_idle`, haciendo que esta unidad entre en los estados profundos más a menudo o con otra residencia → pasó de "marginal estable" a "crashea cada pocos días". **El update es el detonante; el deep C-state es el mecanismo.**

---

## 5. Mitigación aplicada (2026-11-13)

En `hosts/nas/configuration.nix`, bloque `boot`:

```nix
boot.kernelParams = [ "intel_idle.max_cstate=2" ];
```

Esto deja activos **POLL + C1E** (reposo real, poco profundo, seguro) y bloquea **C6/C8/C10** (donde vive el cuelgue).

### Semántica del parámetro en esta placa (importante)
El driver conserva los estados con **índice < `max_cstate`**. Orden de la tabla: `POLL(0), C1E(1), C6(2), C8(3), C10(4)`. Por tanto:

- `max_cstate=1` → **solo POLL** (índice 0). La CPU hace *busy-wait* en reposo → **no sirve**, calienta y gasta de más.
- `max_cstate=2` → **POLL + C1E** ✓ (lo que queremos).
- `max_cstate=9` (default) → los 5 estados.

### Impacto térmico
Despreciable. Con C1E-only, el idle **asentado** se queda en **~46 °C** (baseline con estados profundos: 44 °C). El pico de 77–80 °C que se ve justo tras el arranque es la carga de levantar ~100 contenedores (`load` ~23), **no** el C-state — se disipa en 2–3 min.

> Verificación: `cat /proc/cmdline | grep cstate`, `cat /sys/module/intel_idle/parameters/max_cstate` → `2`, y en `/sys/devices/system/cpu/cpu0/cpuidle/` deben quedar solo `state0` (POLL) y `state1` (C1E).

---

## 6. Validación pendiente (experimento A/B)

El reloj arranca en el boot de **2026-11-13 ~16:08 WET**.

- **Antes:** crash cada **4–14 días**.
- **Criterio de éxito:** si aguanta **limpio 6–8 semanas** (≈ finales dic-2026 / principios ene-2027) → confirmado que eran los deep C-states, caso cerrado sin tocar hardware.
- **Si recurre antes:** se descarta C-state → pasar al plan B.

---

## 7. Plan B si recurre: trampa de captura (no aplicado)

Si vuelve a caer con `max_cstate=2`, armar una captura con los C-states profundos reactivados para cazar el próximo evento:

```nix
boot.kernelParams = [
  "hardlockup_panic=1" "softlockup_panic=1"
  "nmi_watchdog=1" "watchdog_thresh=5"          # detecta a ~10 s, antes del iTCO (30 s)
  "rcupdate.rcu_cpu_stall_timeout=8"
  "hardlockup_all_cpu_backtrace=1" "softlockup_all_cpu_backtrace=1"
];
```
Más `hardware.rasdaemon.enable = true;` (histórico persistente de EDAC/MCE) y `dmidecode` en los paquetes (versión de BIOS y part-numbers de DIMM, hoy no instalado). `efi_pstore` ya funciona → un panic se persiste localmente sin colector externo.

**Caveat honesto:** si se cuelga el *paquete entero* en C10, no queda nada corriendo que pueda loguear (ni el NMI del core parado) y solo actúa el iTCO; ese caso es fundamentalmente incapturable desde el propio equipo. La trampa solo rinde si el wedge es parcial (algún core superviviente imprime el stack del colgado apuntando a `intel_idle`/`mwait_idle_with_hints`/`cpuidle_enter_state`).

También existe una **alerta Grafana directa de reinicio** recomendada (hoy se detecta por rebote vía pods):
```promql
(time() - node_boot_time_seconds{instance="192.168.1.200:9100"}) < 300
```

---

## 8. Limpieza (secuela de reinicios)

Tras un reinicio pueden quedar **pods fantasma** sin recoger (inofensivos, pero vuelven a disparar "Pod Not Ready"). Borrables sin riesgo, p. ej.:

```bash
kubectl delete pod -n media <jellyfin-pods-no-Running>
kubectl delete pod -n system <crowdsec-agent-pod>
```

---

## Apéndice: comandos de verificación

```bash
# Arranques del host (limpio vs sucio) y kernel por boot
ssh nas "journalctl --list-boots | tail; last -x reboot shutdown"
for b in -9 -8 -7 -6 -1 0; do ssh nas "journalctl -b $b -k | grep -m1 'Linux version'"; done

# Muerte silenciosa: final del boot anterior + grep de panic/lockup/mce
ssh nas "journalctl -b -1 -n 25 -o short-iso"
ssh nas "journalctl -b -1 -k | grep -iE 'panic|oops|BUG:|lockup|oom-kill|mce|edac'; ls /sys/fs/pstore/"

# Watchdog hardware iTCO
ssh nas "wdctl; journalctl -b -k | grep -i iTCO"

# C-states y temperatura
ssh nas "cat /sys/module/intel_idle/parameters/max_cstate; sensors; for s in /sys/devices/system/cpu/cpu0/cpuidle/state*/; do cat \$s/name; done"

# Telemetría (Grafana/Prometheus, datasource uid P4169E866C3094E38):
#   network_ups_tools_input_voltage / _battery_charge   → alimentación
#   sum by (mode) (rate(node_cpu_seconds_total[1m]))    → CPU por modo (idle→0 todos = lockup)
#   node_load1                                          → carga
```

## Referencias
- Fix del deep C-state en N100/N5105: https://itsjamesbrooks.com/writing/proxmox-n100-random-freeze-cstate/
- Hard freezes del NIC Intel i226-V en N-series (candidato B descartado, va bajo carga de red): https://karubits.com/posts/Intel-i226-Hard-Freezes/
