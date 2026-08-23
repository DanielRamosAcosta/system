---
id: NAS-25.8
title: Evaluar migración de StrongSwan a WireGuard
status: Done
assignee: []
created_date: '2026-04-12 01:45'
updated_date: '2026-08-15 18:55'
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
- [x] #1 Decisión documentada de migrar o no, con pros/contras
- [ ] #2 Si se migra: túnel WireGuard funcional con al menos un cliente
- [ ] #3 Si se migra: acceso a red local y routing a internet verificados
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Decisión: NO migrar. Mantener StrongSwan (IKEv2/IPSec).

Justificación — StrongSwan ya funciona y da servicio; la migración a WireGuard obliga a reconfigurar TODOS los clientes VPN (coste alto) para un beneficio que en este caso es sobre todo de "elegancia" (config más simple, menor superficie de ataque). No hay un problema real que WireGuard resuelva aquí y sí un riesgo de romper el acceso remoto durante el swap. Se prioriza "si funciona, no lo toques".

Consecuencia: al quedarnos con StrongSwan, las mejoras de cripto de la misma pila (NAS-25.1 RSA→Ed25519 y NAS-25.2 eliminar modp2048) SÍ tienen sentido y pasan a ser el camino de modernización de la VPN.

Criterios #2 y #3 no aplican (condicionales a "si se migra").
<!-- SECTION:FINAL_SUMMARY:END -->
