---
id: NAS-23
title: Restringir dhcpcd para que solo gestione enp4s0 e ignore interfaces dinámicas
status: In Progress
assignee: []
created_date: '2026-04-04 19:11'
updated_date: '2026-04-06 22:24'
labels:
  - networking
  - hardening
dependencies: []
references:
  - >-
    backlog/docs/doc-17 - Post mortem: SSH inaccesible tras nixos-rebuild por
    interfaz iPhone (eth0) robando ruta default.md
priority: high
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Tras el incidente doc-17 (post mortem: iPhone robó ruta default), hay que proteger la tabla de rutas del NAS contra interfaces de red que aparecen dinámicamente.

Actualmente `dhcpcd` gestiona todas las interfaces sin restricción. Cuando se conectó un iPhone por USB y `usbmuxd`/`ipheth` crearon `eth0`, `dhcpcd` le asignó IP y ruta default vía el hotspot del iPhone (172.20.10.1), desplazando la ruta legítima (192.168.1.1) y dejando el NAS inaccesible.

## Solución propuesta

Configurar `networking.dhcpcd.extraConfig` en NixOS con:

1. `allowInterfaces enp4s0` — solo gestionar la interfaz principal de la LAN
2. Opcionalmente, asignar `metric 1000` a la interfaz principal para tener control explícito sobre prioridades de ruta

Alternativa más robusta: migrar de `dhcpcd` a `systemd-networkd` con IP estática para `enp4s0`, ya que un servidor NAS no debería depender de DHCP en absoluto.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 dhcpcd no configura interfaces que no sean enp4s0
- [ ] #2 Conectar un iPhone por USB no altera la tabla de rutas
- [ ] #3 La ruta default siempre apunta a 192.168.1.1 vía enp4s0
<!-- AC:END -->
