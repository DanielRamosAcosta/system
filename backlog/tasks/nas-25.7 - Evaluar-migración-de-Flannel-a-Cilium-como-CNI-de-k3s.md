---
id: NAS-25.7
title: Evaluar migración de Flannel a Cilium como CNI de k3s
status: To Do
assignee: []
created_date: '2026-04-12 01:45'
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
- [ ] #1 Decisión documentada de migrar o no migrar, con justificación
- [ ] #2 Si se migra: pods se comunican correctamente con Cilium
- [ ] #3 Si se migra: network policies básicas configuradas
<!-- AC:END -->
