---
id: doc-16
title: 'Post mortem: SSH inaccesible por btrfs scrub lanzado desde sesión de usuario'
type: other
created_date: '2026-04-03 09:45'
---
# Post mortem: SSH inaccesible por btrfs scrub lanzado desde sesión de usuario

**Fecha:** 2026-04-03
**Duración del incidente:** ~6 horas (02:14 - 09:17 reboot)
**Impacto:** Imposibilidad casi total de acceder al NAS por SSH

## Resumen

Un `btrfs scrub` lanzado desde una sesión tmux del usuario causó que `user@1000.service` entrara en estado failed permanente, bloqueando todas las sesiones SSH nuevas.

## Timeline

| Hora | Evento |
|------|--------|
| 00:36 | Usuario conecta por SSH, abre tmux, ejecuta `sudo btrfs scrub start /cold-data/git` |
| 00:36 | El proceso btrfs (PID 39518) queda dentro del cgroup de `user@1000.service` bajo el scope de tmux |
| ~02:12 | La sesión tmux se cierra. systemd inicia el shutdown de `user@1000.service` e intenta matar todos los procesos del cgroup |
| 02:12 | systemd envía SIGKILL al proceso btrfs. El proceso no muere porque está en estado D (uninterruptible sleep, I/O de kernel). Se convierte en zombie |
| 02:14 | Tras 2 minutos esperando, systemd marca `user@1000.service` como failed: `Processes still around after final SIGKILL. Entering failed mode.` |
| 07:44 | Primer intento de reconexión SSH. systemd detecta el zombie: `Found left-over process 39518 (btrfs) in control group while starting unit. Ignoring.` |
| 07:44+ | Todas las conexiones SSH autentican correctamente pero `pam_systemd` no puede registrar sesiones: `user@1000.service: Failed to spawn executor: Device or resource busy` |
| 08:00-09:17 | Sesiones SSH con `-T` (sin TTY) funcionan intermitentemente porque no siempre requieren user manager completo |
| 09:17 | Reboot del sistema resuelve el problema |

## Causa raíz

El scrub se ejecutó con `sudo` desde tmux, pero el proceso btrfs quedó asignado al cgroup del usuario (`user.slice/user-1000.slice/user@1000.service/tmux-spawn-*.scope`). Cuando la sesión tmux se cerró, systemd intentó limpiar el cgroup matando todos sus procesos. El proceso btrfs, en estado D (uninterruptible sleep haciendo I/O de kernel), no pudo morir. Esto dejó `user@1000.service` en estado failed permanente con un proceso zombie imposible de recoger.

A partir de ese momento, cualquier nueva conexión SSH que intentara crear una sesión de usuario vía `pam_systemd` fallaba con "Device or resource busy" porque systemd no podía reiniciar el user manager mientras el zombie ocupara el cgroup.

## Por qué la hipótesis inicial era incorrecta

Inicialmente se sospechó que la presión de I/O del scrub (~4.5%) saturaba el sistema e impedía que SSH abriera shells. Evidencia en contra:

- La presión de I/O era de solo 4.5%, insuficiente para bloquear operaciones de disco de forma consistente
- La presión de CPU y memoria era prácticamente 0
- SSH autenticaba correctamente (handshake completo) pero fallaba al crear la sesión, no al leer del disco
- Los comandos `ssh -T` funcionaban a veces, lo cual no sería posible si el disco estuviera realmente saturado
- Los logs de `journalctl -p err` mostraban claramente `Failed to spawn executor: Device or resource busy` como causa directa

## Lecciones aprendidas

1. Los procesos lanzados con `sudo` desde una sesión de usuario siguen perteneciendo al cgroup del usuario, no al de root
2. Un proceso en estado D (uninterruptible sleep) no puede ser matado ni con SIGKILL — solo desaparece con reboot
3. `pam_systemd` es un punto único de fallo para sesiones SSH: si `user@N.service` está roto, ninguna sesión nueva puede registrarse
4. Que SSH autentique no significa que la sesión vaya a funcionar — el fallo puede estar en la capa de systemd/pam

## Acciones preventivas

1. **Lanzar scrubs como servicio de sistema, nunca desde sesión de usuario.** Usar `systemd-run --scope --slice=system.slice btrfs scrub start /cold-data` o crear un timer/service de NixOS dedicado
2. **Crear un servicio NixOS con timer para scrubs periódicos** con `ionice -c 3` para limitar prioridad de I/O
3. **Revisar el mapeo de sensores del QUADRO** — durante el incidente los HDDs estaban a 52-58°C pero los ventiladores no estaban al 100%, lo que indica que el sensor 1 de la curva de fans no refleja la temperatura de los discos
