---
id: NAS-37
title: >-
  workhorse: Elden Ring (y juegos Proton) se quedan tras el splash de Steam en
  gamescope
status: Done
assignee: []
created_date: '2026-10-16 21:00'
labels: []
dependencies: []
references:
  - 'https://github.com/ValveSoftware/gamescope/issues/2457'
  - 'https://github.com/ValveSoftware/gamescope/issues/1365'
  - >-
    https://github.com/ValveSoftware/gamescope/commit/38293404f89aa20b9d9c58a97aca5ce7b1e56e30
modified_files:
  - hosts/workhorse/gamescope-patch.nix
  - hosts/workhorse/default.nix
priority: medium
type: bug
ordinal: 18000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Al lanzar Elden Ring en workhorse, el juego arrancaba (se oía el audio) pero nunca se veía: la pantalla se quedaba en la UI de carga de Steam (logo girando + barra "menu / cancelar partida"). Afectaba a Elden Ring; otros juegos como Cyberpunk sí se veían. No era HDR ni render en negro.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Elden Ring entra a pantalla completa al lanzarlo desde la sesión gamescope, sin quedarse en el splash de Steam
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
CAUSA RAÍZ (bug de gamescope #2457/#1365, afecta a 3.16.30, la versión de workhorse): Wine/Proton crea la ventana del juego como override-redirect y la pasa a managed mientras está sin mapear (sin generar evento X). gamescope cachea ese atributo al crear la ventana y no lo refresca, así que la deja como override-redirect → se excluye de GAMESCOPE_FOCUSABLE_WINDOWS → Steam no ve ventana de juego y se queda en el splash de carga, con el juego corriendo por debajo (audio). Confirmado en logs: eldenring.exe corría y gamescope nunca emitía evento de foco del juego. Cyberpunk no lo dispara (mapea la ventana distinto).

FIX (commit 9f485cd): overlay en hosts/workhorse/gamescope-patch.nix que aplica a gamescope el commit upstream 38293404 "steamcompmgr: take override-redirect from MapNotify" (4 líneas en src/steamcompmgr.cpp). El commit NO está en ningún tag publicado: 3.16.31 solo trae un commit distinto de Wayland, así que subir de versión no vale; hay que parchear. Verificado: tras reiniciar la sesión para cargar el gamescope parcheado, Elden Ring entra a pantalla completa (confirmado visualmente por el usuario).

Descartado durante el diagnóstico: HDR forzado (se apagó y seguía igual), opciones de lanzamiento (no tiene), Proton forzado/GE-Proton (no era Proton), escritorio virtual. Cuando gamescope suba a una versión que ya incluya 38293404, este overlay se puede quitar.
<!-- SECTION:FINAL_SUMMARY:END -->
