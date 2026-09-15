---
id: NAS-33
title: 'workhorse: recuperar DNS tras suspender reiniciando tailscaled en post-resume'
status: Done
assignee: []
created_date: '2026-09-10 18:31'
labels: []
dependencies: []
modified_files:
  - hosts/workhorse/tailscale.nix
priority: medium
type: bug
ordinal: 13000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Al salir de suspensión, workhorse aparentaba quedarse "sin internet". La conectividad IP funcionaba (ping a 1.1.1.1 OK, ruta por defecto y DHCP correctos), pero fallaba toda la resolución de nombres.

Causa raíz: todo el DNS del sistema pasa por el MagicDNS de Tailscale (100.100.100.100), que no tiene resolvers propios y reenvía a los upstream del sistema (80.58.61.250/.254 vía DHCP). Tras el resume, tailscaled se queda sin esos upstream resolvers ("no upstream resolvers set, returning SERVFAIL") y devuelve SERVFAIL a todo lo que no sea *.ts.net. Resultado: hay internet por IP pero nada resuelve dominios.

Confirmado en vivo: reiniciar tailscaled restaura el DNS al instante.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 El DNS se recupera automáticamente tras salir de suspensión sin intervención manual
- [ ] #2 La corrección es declarativa en la configuración Nix del host
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Añadido en hosts/workhorse/tailscale.nix un servicio systemd oneshot `tailscaled-resume-dns` enganchado a post-resume.target (after + wantedBy) que ejecuta `systemctl restart tailscaled.service` al despertar. Validado con `make dry-activate-workhorse`, activado con `make activate-workhorse`, y verificado: symlink creado en post-resume.target.wants/, el servicio corre con Result=success/ExecMainStatus=0 y getent hosts resuelve. El estado de fallo actual también se corrigió en caliente reiniciando tailscaled.
<!-- SECTION:FINAL_SUMMARY:END -->
