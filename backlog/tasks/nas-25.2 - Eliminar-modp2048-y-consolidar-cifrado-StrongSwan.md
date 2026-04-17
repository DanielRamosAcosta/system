---
id: NAS-25.2
title: Eliminar modp2048 y consolidar cifrado StrongSwan
status: To Do
assignee: []
created_date: '2026-04-12 01:44'
labels:
  - security
  - vpn
dependencies: []
references:
  - hosts/nas/services/strongswan.nix
parent_task_id: NAS-25
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
En `strongswan.nix` (líneas 40-44) se usan propuestas de cifrado que incluyen `modp2048` como fallback. Este grupo Diffie-Hellman es considerado legacy. Se debe consolidar a curvas elípticas únicamente (ecp256, ecp384, ecp521). También considerar añadir ChaCha20-Poly1305 como alternativa a AES-GCM.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Propuestas IKE y ESP no incluyen modp2048
- [ ] #2 Solo se usan grupos ECC (ecp256/ecp384/ecp521)
- [ ] #3 VPN sigue conectando desde los clientes existentes (iOS/macOS)
<!-- AC:END -->
