---
id: NAS-25.3
title: Consolidar NAT a nftables puro (eliminar services.nat legacy)
status: To Do
assignee: []
created_date: '2026-04-12 01:44'
labels:
  - networking
dependencies: []
references:
  - hosts/nas/services/strongswan.nix
parent_task_id: NAS-25
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
En `strongswan.nix` se mezclan dos enfoques: reglas nftables directas (líneas 88-101) y el módulo legacy `services.nat` (líneas 103-108) que internamente usa iptables. Se debe migrar todo el NAT a reglas nftables puras para consistencia y eliminar la dependencia de iptables.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 services.nat eliminado de la configuración
- [ ] #2 NAT implementado con reglas nftables nativas
- [ ] #3 Tráfico VPN sigue siendo enrutado correctamente hacia internet
- [ ] #4 No quedan dependencias de iptables
<!-- AC:END -->
