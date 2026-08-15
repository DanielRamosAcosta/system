---
id: doc-24
title: >-
  Post mortem: el router Vodafone (Sercomm H-500-s) resetea la WAN bajo tráfico
  entrante por port-forward
type: other
created_date: '2026-08-15 13:17'
---
# Post mortem: el router Vodafone (Sercomm H-500-s) resetea la WAN bajo tráfico entrante por port-forward

**Fecha del diagnóstico:** 2026-08-15
**Ubicación del servicio afectado:** NAS en Tenerife (línea Vodafone, ex-ONO)
**Punto de observación remoto:** macbook en A Coruña
**Impacto:** al mover datos grandes hacia/desde el NAS a través del port-forward, la WAN "se cae" durante minutos y la IP pública cambia; se rompen todas las conexiones entrantes (SSH directo, rsync, servicios expuestos por IP).
**Sustituye/corrige:** `~/Documents/REPORT.md` (2026-07-20), cuya causa raíz resultó ser incorrecta.

## Resumen ejecutivo

Bajo tráfico masivo sostenido que **entra por el port-forward (DNAT)** del router (`vpn.danielramos.me:21873 → NAS:22`), tras ~40 s el **router Sercomm Vodafone H-500-s resetea la sesión WAN y cambia la IP pública**, matando todas las conexiones entrantes. **La conectividad de salida del NAS nunca se interrumpe.**

Mediante una matriz de 4 pruebas controladas se aisló la variable causal: **no es rsync, ni el disco `/cold-data`, ni el ancho de subida, ni el operador**. Es la **dirección de la conexión**: el tráfico entrante forwardeado (DNAT) cae al *slow-path* por CPU del router; el saliente va por el acelerador de hardware (*fast-path*) y aguanta 10× más sin problema.

## Topología

- **NAS** (Tenerife) tras **Sercomm Vodafone H-500-s**, WAN IPoE/DHCP (ex-ONO), IP pública dinámica.
  - Acceso entrante directo: `vpn.danielramos.me:21873` → **port-forward** `WAN:21873 → 192.168.1.200:22` (DNS por DDNS del NAS).
  - Acceso saliente: **cloudflared** (`ssh.danielramos.me` y varios servicios), túnel iniciado por el NAS.
- **macbook / siemens** (A Coruña) tras router Movistar (PPPoE, IP `193.153.15.37`, port-forward `WAN:2299 → siemens:22`).

## Metodología

Monitor local en el NAS (persistente a los cortes, vía `setsid`) registrando con marca de tiempo (epoch):
- **Salida**: `ping -c1 -W1 1.1.1.1` cada 0,3-0,5 s (UP/DOWN + RTT).
- **IP pública**: `curl ifconfig.me` cada 2 s.
- **Throughput de subida**: delta de `/sys/class/net/enp4s0/statistics/tx_bytes` cada 1 s.
Desde el macbook, monitor de acceso entrante (`nc` al puerto 21873) cada 1 s. Cargas con auto-parada (`timeout`).

## Matriz de pruebas (evidencia)

| # | Herramienta | Camino | Establecimiento | Throughput | ¿Cae la WAN? |
|---|---|---|---|---|---|
| 1 | `dd`\|`ssh` (aes128-gcm, /dev/zero) | NAS → siemens:2299 | **saliente** | **455 Mbps** (5 min) | ❌ No |
| 2 | `rsync` (openrsync, peli 79,6 GB de `/cold-data`) | mac ← NAS:21873 | **entrante** (port-forward) | ~45 Mbps | ✅ **Sí** |
| 3 | `dd`\|`ssh` (aes128-gcm, /dev/zero) | mac ← NAS:21873 | **entrante** (port-forward) | ~45 Mbps | ✅ **Sí (~42 s)** |
| 4 | `dd`\|`ssh` (/dev/zero) | mac ← NAS por **cloudflared** | **saliente** | **217 Mbps** avg (max 309) | ❌ No (4 min) |

**Lectura de la matriz:** la prueba 3 usa exactamente el mismo generador y cifrado que la prueba 1 (que aguanta); lo único que cambia es que la conexión **entra por el port-forward**. Al caer igual que rsync (prueba 2), queda demostrado que **rsync y el disco son inocentes**: la variable causal es la **dirección**. La prueba 4 valida la solución: el mismo tráfico por un camino **saliente** (cloudflared) no tira la WAN.

## Timeline del evento (prueba 3, la "pistola humeante")

| epoch | throughput subida | IP pública | salida (ping 1.1.1.1) |
|---|---|---|---|
| 1786791861-900 | ~45 Mbps constante | 194.220.172.169 | UP (0,5-1 ms, **sin fallos**) |
| 1786791901 | 11 → 0 Mbps | deja de resolver | UP |
| 1786791901+ | 0 Mbps | → **77.225.118.178** | UP (**0 DOWN en todo el evento**) |

El throughput entrante se clava en ~45 Mbps (firma del slow-path). A los ~40 s el router **cambia la IP pública** (renegocia la sesión WAN) y rompe las conexiones entrantes, **sin perder ni un ping de salida**.

## Causa raíz

El router **Sercomm Vodafone H-500-s** solo acelera por hardware (*fast-path* / flow offload) el tráfico **saliente** (masquerade). El tráfico que entra por el **port-forward (DNAT)** cae al ***slow-path* por software**, procesado por la **CPU del router**, que topa a ~45 Mbps. Con carga sostenida esa CPU se satura y, a los ~40 s, el router **reinicia la sesión WAN** (con cambio de IP pública), tirando todas las conexiones entrantes. La salida ni se entera.

### Qué corrige del informe previo (REPORT.md, 2026-07-20)

El informe anterior atribuía el corte a *"pérdida de sincronismo del enlace WAN aguas arriba (lado operador), desencadenada por la saturación del canal de subida"* y **descartaba el router**. Las pruebas de hoy lo **refutan**: la subida **saliente** aguanta **455 Mbps** cinco minutos sin caer — si fuera el upstream del operador o el ancho de subida, también caería. El culpable es el **DNAT del propio router**. El informe acertó en la firma (corte + cambio de IP; `--bwlimit` lo evita) pero erró en la causa.

## Estado de exposición actual de los servicios (verificado por DNS)

| Dominio | Resuelve a | Camino | ¿Afectado? |
|---|---|---|---|
| `media.danielramos.me` | Cloudflare (104.21/172.67) | túnel saliente | No |
| `grafana.danielramos.me` | Cloudflare | túnel saliente | No |
| `danielramos.me` (apex) | Cloudflare | túnel saliente | No |
| `photos.danielramos.me` | **77.225.118.178** (IP pública NAS) | **port-forward** | **Sí** |

`photos` (Immich) va por IP directa, probablemente para saltarse el **límite de 100 MB por subida** del túnel de Cloudflare gratis (y su ToS sobre vídeo). Ese es justo el servicio en el camino que satura el router.

## Solución (validada) y mitigaciones

1. **Usar caminos salientes del NAS** (recomendado): cloudflared ya mueve 217 Mbps estables sin tocar la WAN. Para `photos`/Immich con subidas grandes de vídeo, un **WireGuard saliente propio** (p. ej. vía un VPS relay) es lo ideal (conexión saliente, sin límite de tamaño, sin port-forward).
2. **Si hay que usar el port-forward**: `rsync --bwlimit` por debajo de ~40 Mbps evita el reset (confirmado).
3. **Arreglo de raíz**: **router neutro** cogiendo la línea. Ojo: la línea de Tenerife es **IPoE/DHCP ex-ONO** (no PPPoE), así que el método (clonar MAC vs. capturar credenciales PPPoE) hay que verificarlo. El H-500-s **no tiene modo bridge**; el DMZ **no sirve** (sigue siendo DNAT → mismo slow-path).
4. **Reclamar a Vodafone un router mejor: descartado.** El H-500-s es el único gratis; el WiFi 6 (+3 €/mes) lleva el mismo firmware capado. El consenso de la comunidad es poner router neutro, no esperar equipo mejor del operador.

## Lecciones aprendidas

1. **Un corte de conectividad entrante no implica caída de WAN.** La salida del NAS nunca falló; instrumentar *ambos sentidos* por separado fue lo que reveló el mecanismo real.
2. **La aceleración NAT por hardware de los routers de operador suele cubrir solo el saliente.** Cualquier servicio expuesto por port-forward con tráfico intenso es candidato a este fallo.
3. **Aislar variables con una matriz controlada** (herramienta × dirección) fue lo que desmontó la hipótesis equivocada (rsync/operador).
4. El `rsync` de macOS es **openrsync** (protocolo 29): no soporta `-s`/`--info=progress2`/`--no-i-r`; usar GNU rsync (vía nix) o flags básicos (`-P`).

## Acciones recomendadas

1. Migrar `photos`/Immich fuera del port-forward → **WireGuard saliente propio** o **cloudflared**. Cambio principal en el repo `nas-k3s`.
2. Documentar en el runbook que **el acceso remoto al NAS debe ir por cloudflared** (o WireGuard saliente), no por `vpn.danielramos.me:21873`.
3. (Opcional) Evaluar router neutro compatible con IPoE ex-ONO como solución de fondo a largo plazo.
4. Actualizar/retirar `~/Documents/REPORT.md` con la causa raíz corregida.
