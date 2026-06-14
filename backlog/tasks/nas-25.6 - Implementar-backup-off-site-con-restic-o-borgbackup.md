---
id: NAS-25.6
title: Implementar backup off-site con restic o borgbackup
status: To Do
assignee: []
created_date: '2026-04-12 01:45'
labels:
  - backup
  - reliability
dependencies: []
references:
  - hosts/nas/snapper.nix
parent_task_id: NAS-25
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Actualmente solo hay snapshots locales con snapper (btrfs). Si el disco falla o hay un incidente físico, no hay copia fuera del NAS. Se necesita un sistema de backup cifrado remoto. Opciones: restic (deduplicación, cifrado, múltiples backends: S3, B2, SFTP), borgbackup (similar, más maduro), o kopia (más nuevo, UI web). Evaluar costes de almacenamiento cloud vs disco externo.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Sistema de backup off-site configurado y funcionando
- [ ] #2 Backups cifrados en reposo y en tránsito
- [ ] #3 Política de retención definida (diario/semanal/mensual)
- [ ] #4 Restauración probada al menos una vez
- [ ] #5 Systemd timer ejecuta backups automáticamente
<!-- AC:END -->
