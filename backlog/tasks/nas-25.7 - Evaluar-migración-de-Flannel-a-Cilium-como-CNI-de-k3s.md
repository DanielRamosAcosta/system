---
id: NAS-25.7
title: Evaluar migración de Flannel a Cilium como CNI de k3s
status: Done
assignee: []
created_date: '2026-04-12 01:45'
updated_date: '2026-08-15 18:54'
labels:
  - kubernetes
dependencies: []
references:
  - hosts/nas/services/k3s.nix
parent_task_id: NAS-25
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
k3s usa Flannel como CNI por defecto. Cilium es más moderno, basado en eBPF, ofrece network policies nativas, observabilidad integrada (Hubble), y mejor rendimiento. Para un NAS single-node puede ser overkill, pero si se necesitan network policies o visibilidad del tráfico entre pods, Cilium es la opción moderna. Evaluar si la complejidad extra vale la pena para el caso de uso.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Decisión documentada de migrar o no migrar, con justificación
- [ ] #2 Si se migra: pods se comunican correctamente con Cilium
- [ ] #3 Si se migra: network policies básicas configuradas
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Decisión: NO migrar. Mantener Flannel como CNI de k3s.

Justificación — el cluster es single-node en el NAS, y en esa topología las ventajas de Cilium no aplican o son marginales:
- Rendimiento eBPF / sin-overlay: irrelevante con un solo nodo (el tráfico pod-a-pod ya es local; el overlay VXLAN de Flannel apenas se usa).
- Coste real de Cilium: mayor consumo de RAM/CPU (agente + operator, cientos de MB) compitiendo con Samba/BTRFS/apps en un NAS con RAM finita.
- Migración con downtime y frágil: requiere arrancar k3s con --flannel-backend=none --disable-network-policy y desplegar Cilium encima; lo limpio sería reprovisionar.
- Más mantenimiento y upgrades más delicados frente a un Flannel que no da guerra.
- Beneficios que sí se notarían (Hubble para observabilidad, NetworkPolicies L7) son opcionales en un homelab.

Conclusión: sobreingeniería para el caso de uso. Solo se reconsideraría como ejercicio de aprendizaje de Cilium/eBPF o si se quisiera Hubble para observar el tráfico entre pods; en ese caso se plantearía como proyecto aparte, no como deuda técnica.

Criterios #2 y #3 no aplican (condicionales a "si se migra").
<!-- SECTION:FINAL_SUMMARY:END -->
