---
id: NAS-35
title: >-
  workhorse: controlar la Sony KD-55A89 por red (encender/apagar/entrada) al
  arrancar Steam y suspender
status: In Progress
assignee: []
created_date: '2026-09-15 18:32'
updated_date: '2026-09-15 18:33'
labels:
  - workhorse
  - tv
  - networking
  - gaming
dependencies: []
references:
  - hosts/workhorse/tailscale.nix
  - hosts/workhorse/default.nix
  - 'https://github.com/cmos486/Bravia-REST-API'
  - 'https://gist.github.com/kalleth/e10e8f3b8b7cb1bac21463b0073a65fb'
priority: low
type: feature
ordinal: 16000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Automatizar el control de la TV Sony OLED KD-55A89 (serie AF9, Android TV) desde workhorse **por red**, evitando HDMI-CEC.

Motivo de descartar CEC: la GPU AMD (RX 9070 XT, driver amdgpu) no expone HDMI-CEC (verificado por SSH: no hay /dev/cec ni /sys/class/cec, y amdgpu no registra adaptador). La única vía CEC sería un adaptador USB Pulse-Eight, pero su passthrough es HDMI 2.0 pasivo y degrada el 4K@60 4:4:4 (18 Gbps) si se pone en línea, obligando a un montaje de dos cables. La Sony, al ser Android TV, soporta control total por red (API Bravia REST + IRCC-IP + Wake-on-LAN), lo que hace innecesario cualquier hardware y no toca el cable HDMI 2.1 directo.

Se pierde una sola cosa frente a CEC: usar el mando de la tele para navegar por Steam (se asume gamepad/Steam Controller).

Configuración previa en la tele (manual, una vez): Ajustes → Red → Configuración de red doméstica → Control por IP → Autenticación "Normal y Pre-Shared Key" (fijar PSK); y Remote Start (Arranque remoto) → Activado (habilita WoL). Anotar IP y MAC de la tele.

Implementación en NixOS: módulo hosts/workhorse/sony-tv.nix con servicios systemd usando curl (API REST Bravia) + wakeonlan. Un servicio al arrancar/entrar en Steam que hace WoL + selecciona la entrada HDMI de workhorse (setPlayContent extInput:hdmi?port=X), y un hook a systemd-suspend (patrón análogo al tailscaled-resume-dns ya existente) que apaga/pone en standby la tele. La PSK debe guardarse como secreto agenix, no en claro.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 En la tele están activados IP Control con Pre-Shared Key y Remote Start (WoL), y se han anotado su IP y MAC
- [ ] #2 Existe hosts/workhorse/sony-tv.nix importado desde default.nix que usa curl (API Bravia) + wakeonlan
- [ ] #3 Al arrancar/entrar en Steam, workhorse enciende la tele (WoL) y selecciona la entrada HDMI de workhorse automáticamente
- [ ] #4 Al suspender workhorse, la tele pasa a standby/apagado mediante un hook de systemd-suspend
- [ ] #5 La Pre-Shared Key se almacena como secreto agenix y no aparece en texto plano en el repo
- [ ] #6 make dry-activate-workhorse evalua sin errores y make activate-workhorse aplica el cambio, verificado en caliente
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Fase 0 (usuario, en la tele): activar IP Control + Pre-Shared Key y Remote Start (WoL); anotar IP y MAC.
Fase 1 (verificación desde workhorse): reachability, probar API Bravia con PSK (getSystemInfo), listar entradas HDMI para saber el port de workhorse, confirmar WoL.
Fase 2 (implementación): módulo hosts/workhorse/sony-tv.nix (curl + wakeonlan), PSK como secreto agenix, servicio arranque (WoL + setPlayContent) y hook systemd-suspend (standby). dry-activate + activate + verificar en caliente.
<!-- SECTION:PLAN:END -->
