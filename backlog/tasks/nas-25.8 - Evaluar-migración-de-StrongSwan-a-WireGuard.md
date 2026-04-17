---
id: NAS-25.8
title: Evaluar migración de StrongSwan a WireGuard
status: To Do
assignee: []
created_date: '2026-04-12 01:45'
labels:
  - vpn
  - networking
dependencies: []
references:
  - hosts/nas/services/strongswan.nix
  - hosts/nas/services/scripts/generate-strongswan-client.sh
parent_task_id: NAS-25
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
StrongSwan (IKEv2/IPSec) funciona pero es complejo de configurar y mantener. WireGuard es el estándar de facto moderno: está en el kernel Linux, es mucho más simple (configuración mínima), mejor rendimiento, y superficie de ataque menor. Es un cambio grande que requiere reconfigurar todos los clientes VPN. Evaluar si los beneficios justifican la migración, considerando que StrongSwan ya funciona.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Decisión documentada de migrar o no, con pros/contras
- [ ] #2 Si se migra: túnel WireGuard funcional con al menos un cliente
- [ ] #3 Si se migra: acceso a red local y routing a internet verificados
<!-- AC:END -->
