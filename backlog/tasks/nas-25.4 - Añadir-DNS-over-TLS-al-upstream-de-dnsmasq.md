---
id: NAS-25.4
title: Añadir DNS-over-TLS al upstream de dnsmasq
status: To Do
assignee: []
created_date: '2026-04-12 01:44'
labels:
  - networking
  - privacy
dependencies: []
references:
  - hosts/nas/services/dnsmasq.nix
parent_task_id: NAS-25
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
En `dnsmasq.nix` (línea 9) los servidores upstream son DNS plano (`8.8.8.8`, `1.1.1.1`). Las consultas DNS viajan sin cifrar. Opciones: configurar dnsmasq con dnscrypt-proxy2 como upstream local que haga DoT/DoH, o usar stubby como forwarder DoT. También considerar reemplazar Google 8.8.8.8 por Quad9 (9.9.9.9) que incluye bloqueo de amenazas.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Consultas DNS upstream viajan cifradas (DoT o DoH)
- [ ] #2 Se reemplaza 8.8.8.8 por proveedor con mejor privacidad
- [ ] #3 Resolución DNS sigue funcionando para todos los clientes de la red
<!-- AC:END -->
