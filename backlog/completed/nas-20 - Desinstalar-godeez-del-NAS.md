---
id: NAS-20
title: Desinstalar godeez del NAS
status: Done
assignee: []
created_date: '2026-03-23 15:09'
updated_date: '2026-03-29 13:30'
labels: []
dependencies: []
references:
  - hosts/nas/base.nix
priority: low
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Eliminar el paquete `godeez` de `hosts/nas/base.nix` ya que no se necesita.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Eliminado `godeez` completamente del repositorio: removido de `hosts/nas/base.nix` (paquete del sistema), de `flake.nix` (packages y overlay), y borrado `packages/godeez.nix`.
<!-- SECTION:FINAL_SUMMARY:END -->
