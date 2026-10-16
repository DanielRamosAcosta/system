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
- [x] #1 El DNS se recupera automáticamente tras salir de suspensión sin intervención manual
- [x] #2 La corrección es declarativa en la configuración Nix del host
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
PRIMER INTENTO (ROTO): se añadió un servicio systemd oneshot `tailscaled-resume-dns` enganchado a `post-resume.target` (after + wantedBy). Resultó inútil: `post-resume.target` NO existe como unidad real en este systemd (`systemctl cat` → "No files found", sin WantedBy/After hacia sleep.target), así que el servicio solo corrió una vez al activar (10-sep) y nunca más en los resumes posteriores. El bug seguía reproduciéndose de forma intermitente.

CAUSA RAÍZ (2026-10-16): workhorse va por WiFi; al salir de suspensión hay una carrera: si tailscaled relee su config DNS ANTES de que el WiFi complete el DHCP, latch-ea upstream vacío (`.:[]`) y devuelve SERVFAIL a todo (internet por IP pero nada resuelve nombres). Si lo hace después, coge bien los resolvers (`.:[80.58.61.250 80.58.61.254]`). Confirmado en el journal: resumes del 17:22, 09-oct y 11-oct quedaron rotos; otros se salvaron por suerte.

FIX REAL (commit e69f2b6): se reemplazó el servicio por un dispatcher de NetworkManager (`networking.networkmanager.dispatcherScripts`) que reinicia `tailscaled` cuando una interfaz física pasa a `up`/`dhcp4-change`/`dhcp6-change`. La acción que NM emite en el resume es `dhcp4-change` (no `up`), que llega DESPUÉS de que el DHCP aplicó los resolvers → el tailscaled reiniciado los lee bien. Determinista, no depende del auto-heal racy. Verificado e2e con rtcwake (suspensión real S3 + auto-wake): 6/6 ciclos con DNS OK, tailscaled reiniciado en 6/6, upstreams siempre correctos.
<!-- SECTION:FINAL_SUMMARY:END -->
