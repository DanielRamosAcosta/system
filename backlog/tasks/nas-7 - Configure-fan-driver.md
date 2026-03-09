---
id: NAS-7
title: Configure fan driver
status: To Do
assignee: []
created_date: '2026-03-09 16:54'
updated_date: '2026-03-09 17:12'
labels:
  - hardware
  - config
  - nixos
dependencies: []
references:
  - 'https://github.com/liquidctl/liquidctl/issues/824'
  - utilities/liquidctl.nix
  - hosts/shared/services/fans.nix
priority: medium
ordinal: 8000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Configurar correctamente el driver de los ventiladores del NAS. Actualmente se usa liquidctl para el control de ventiladores — hay que revisar la configuración actual y resolver los problemas pendientes con el driver.
<!-- SECTION:DESCRIPTION:END -->
