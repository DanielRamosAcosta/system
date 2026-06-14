---
id: NAS-25.5
title: Mover estado del UPS watchdog de /tmp a StateDirectory
status: To Do
assignee: []
created_date: '2026-04-12 01:45'
labels:
  - reliability
dependencies: []
references:
  - hosts/nas/services/scripts/ups-watchdog.sh
  - hosts/nas/services/ups-watchdog.nix
parent_task_id: NAS-25
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
El script `ups-watchdog.sh` (línea 7) guarda estado de fallos en `/tmp/ups-watchdog-failures`. Este archivo se pierde en cada reboot, lo que resetea el contador de fallos. Debería usar `StateDirectory` de systemd (`/var/lib/ups-watchdog/`) para persistir el estado entre reinicios.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Servicio systemd declara StateDirectory
- [ ] #2 Script usa /var/lib/ups-watchdog/ para archivos de estado
- [ ] #3 Estado persiste entre reinicios del sistema
<!-- AC:END -->
