---
id: NAS-24
title: 'Post Mortem: dhcpcd carrier loss causa cascada de fallos en K3s'
status: Done
assignee: []
created_date: '2026-04-12 01:32'
labels:
  - post-mortem
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## Resumen

Fecha: 2026-03-09 (incidente original), investigado y resuelto 2026-04-12
Severidad: Moderada
TTD: ~33 días (incidente 09/03 → investigación 12/04)
TTM: ~2h (inicio investigación → fix validado)
TTR: ~2h

## Timeline

| Fecha | Evento |
|-------|--------|
| 2026-01-11 | Se crea `network-link-monitor.sh` (commit 7fca41a) como intento de recuperación ante fallos de red |
| 2026-03-09 09:43 | Corte de luz, UPS activo |
| 2026-03-09 10:51 | UPS agotado, NAS se apaga |
| 2026-03-09 11:16 | Luz restaurada, NAS arranca sin IP |
| 2026-03-09 11:29-11:34 | SFTPGo en CrashLoopBackOff ~15 min |
| 2026-03-09 17:02 | Se crea NASKS-11 con diagnóstico incorrecto (se asume `node-ip` en K3s) |
| 2026-04-12 01:38 | Test 1: cable desconectado, fallo reproducido. dhcpcd elimina IP, kubelet probes fallan, pods mueren |
| 2026-04-12 02:04 | Test 2: se prueba `nocarrier` — opción inválida en dhcpcd 10.2.4, fallo idéntico |
| 2026-04-12 02:11 | Despliegue con `nolink` + eliminación del network-link-monitor |
| 2026-04-12 02:12 | Test 3: cable desconectado 2 min, zero impacto. Fix validado |

## Impacto

- Pérdida de métricas de VictoriaMetrics durante cada corte de red (~2.5 min de gap por incidente)
- Pods con hostNetwork (node-exporter, nut-exporter) reiniciados
- CoreDNS crasheado, cascada de reinicios (Authelia, ArgoCD)
- CPU spike al 100% durante recuperación
- Sin pérdida de datos ni impacto a usuarios

## Root Cause Analysis

### 5 Whys

1. **¿Por qué se perdían métricas?** Porque VictoriaMetrics no podía escrapear node-exporter — los pods se reiniciaban
2. **¿Por qué se reiniciaban los pods?** Porque kubelet hacía liveness probes a `192.168.1.200:9100` y recibía `network is unreachable`
3. **¿Por qué la IP era unreachable en el propio host?** Porque dhcpcd eliminaba la IP de `enp4s0` al detectar carrier loss, y `network-link-monitor` además hacía `ip link set down` + `dhcpcd -x` hasta 3 veces
4. **¿Por qué dhcpcd eliminaba la IP con lease vigente?** Porque su comportamiento por defecto es de-configurar la interfaz al perder carrier. `persistent` solo aplica al exit del daemon
5. **¿Por qué no se resolvió antes?** Diagnóstico incorrecto en NASKS-11 (se asumió `node-ip` en K3s sin verificar), y el `network-link-monitor` se creó como parche sin validar que empeoraba el problema

### Causa raíz
dhcpcd elimina la IP de la interfaz al perder carrier (comportamiento por defecto)

### Factores contribuyentes
- `network-link-monitor.sh` amplificaba el daño destruyendo la config de red activamente (ip link down + dhcpcd -x, 3 intentos)
- Diagnóstico incorrecto en NASKS-11: se asumió que K3s tenía `node-ip` hardcodeado, pero `extraFlags` estaba vacío
- La tarea se bloqueó 1 mes esperando acceso físico, sin verificar las premisas contra el código

## Qué funcionó bien

- Stack de observabilidad (Loki + VictoriaMetrics) permitió reconstruir exactamente qué pasó
- Los logs de dhcpcd fueron la pistola humeante: `carrier lost` → `deleting route` → `removing interface`
- Acceso SSH al NAS permitió consultar journalctl y kubectl para diagnóstico directo

## Qué faltaba

- El diagnóstico original de NASKS-11 nunca se verificó contra el código real
- No había logs de kernel sobre link events (dmesg vacío)
- El `network-link-monitor` no tenía observabilidad sobre sí mismo — nadie sabía que empeoraba las cosas
- No existía un runbook de "cómo probar resiliencia de red"

## Action items

| Acción | Prioridad | Categoría |
|--------|-----------|-----------|
| ~~Añadir `nolink` a dhcpcd config~~ (hecho) | Alta | Preventivo |
| ~~Eliminar `network-link-monitor` service y script~~ (hecho) | Alta | Preventivo |
| Verificar que no hay otros scripts "parche" sin validar en el NAS | Media | Detectivo |
| Considerar añadir alerta cuando kubelet liveness probes fallan sostenidamente | Baja | Detectivo |

## Aprendizajes

- Un script de "recuperación" que no se prueba contra el escenario real puede ser peor que no tener nada
- Antes de crear una tarea con un diagnóstico, verificar las premisas contra el código (`git grep`, leer la config)
- `persistent` en dhcpcd no significa lo que parece — solo aplica al shutdown del daemon, no a carrier loss
- El comportamiento de dhcpcd ante carrier loss no es intuitivo: lease vigente ≠ IP mantenida
<!-- SECTION:DESCRIPTION:END -->
