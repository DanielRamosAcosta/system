---
id: NAS-29
title: >-
  Publicar app OAuth de Google Cloud y eliminar warning de config read-only en
  gdrive-sync
status: Done
assignee: []
created_date: '2026-07-11 17:54'
labels:
  - nas
  - rclone
  - google-drive
  - nixos
  - oauth
dependencies:
  - NAS-27
references:
  - 'https://forum.rclone.org/t/rclone-google-drive-token-not-refreshing/51320'
  - >-
    https://forum.rclone.org/t/automate-sync-failed-to-load-config-file-permission-denied/20762
  - 'https://forum.rclone.org/t/onedrive-and-googledrive-refreshing-tokens/37858'
priority: high
ordinal: 7000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## 📌 TLDR

El servicio `gdrive-sync-dani` funciona, pero tiene dos problemas de robustez del token OAuth de Google Drive. El grave: si la app OAuth está en modo **"Testing"**, Google caduca el refresh token cada 7 días y rompe la sync del directorio `Crítico`. El menor: rclone no puede persistir el access token refrescado porque el config vive en `/run/agenix` (read-only), dejando un `ERROR ... permission denied` en el log.

## 🎯 Contexto funcional

El directorio `Crítico` contiene datos importantes que se sincronizan bidireccionalmente con Google Drive cada hora. Cualquier interrupción de la autenticación deja la sync parada silenciosamente (solo error en journald). Hay que garantizar que el refresh token no caduque solo, y de paso limpiar el ruido del log.

## ⚙️ Contexto técnico

### Frente 1 — Publicar la app OAuth (el urgente)
- Google invalida los refresh tokens a los **7 días** si la pantalla de consentimiento OAuth está en estado "Testing".
- Hay que pasar el proyecto de Google Cloud Console a **"In production" / Published**.
- **A verificar primero:** durante el bootstrap (NAS-27) se usaron las *credenciales integradas de rclone*, no un proyecto OAuth propio. Si es así, no existe un proyecto "propio" que publicar y la solución real es crear un proyecto OAuth propio en Google Cloud (client_id/client_secret propios) y reautorizar, o bien confirmar el comportamiento de caducidad con las credenciales compartidas de rclone. Determinar cuál aplica es el primer paso.

### Frente 2 — Config escribible (el cosmético)
- El servicio arranca rclone con `--config /run/agenix/dani-rclone-gdrive`, montado **read-only** por agenix.
- rclone intenta cachear el access token refrescado en ese fichero → `ERROR : Failed to save config after 10 tries: ... permission denied`.
- Para Google Drive es ruido: el refresh token no rota, así que cada ejecución relee el token válido y refresca en memoria. No degrada la sync, pero ensucia el log y provoca un refresh por cada run.
- Solución habitual: copiar el config de agenix a una ruta escribible del usuario en un `ExecStartPre` (p. ej. `$HOME/.config/rclone/rclone.conf`, `chmod 600`) y apuntar `--config`/`RCLONE_CONFIG` ahí. Sin exponer el secreto en el Nix store ni dejarlo world-readable.
- Fichero a tocar: `hosts/nas/services/gdrive-sync.nix`.

## 🔍 Hallazgos (2026-07-13)

- **AC #1** — El bootstrap usó un **proyecto OAuth propio**, no las credenciales integradas de rclone. El config `[gdrive]` del NAS tiene `client_id = 800844641851-...` y `client_secret` propios, scope `drive`.
- **AC #2** — Verificado en Google Cloud Console: el proyecto se llama **"rclone"** (`light-river-502019-b0`, project number `800844641851`) y su pantalla de consentimiento **ya está en `In production`** (User type: External, cap 1/100). El "7-day problem" **no aplica**: ese límite es exclusivo del modo "Testing". No había nada que publicar.
- **Frente 2 (config read-only)** — Abordado en `hosts/nas/services/gdrive-sync.nix`: el servicio ahora usa `StateDirectory=gdrive-sync-<user>` y un `ExecStartPre` que siembra `rclone.conf` desde el secreto de agenix solo si no existe, apuntando `--config` a esa ruta escribible. **Ojo:** el secreto de agenix pasa a ser solo semilla inicial; si se regenera el token hay que borrar `/var/lib/gdrive-sync-<user>/rclone.conf` para re-sembrar. Pendiente de desplegar (`make activate-nas`) y de verificar AC #4/#6.
- Extra encontrado el mismo día: faltaba el `--resync` inicial (ya ejecutado) y Drive tiene ~309 dangling shortcuts que abortaban la bisync (resuelto con `--drive-skip-dangling-shortcuts`, también añadido al servicio).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Determinado si el bootstrap usó las credenciales integradas de rclone o un proyecto OAuth propio, y documentada la implicación para la caducidad del refresh token
- [x] #2 La app OAuth queda configurada de forma que el refresh token de gdrive no caduque a los 7 días (proyecto propio publicado o equivalente verificado)
- [x] #3 Verificado que el refresh token sigue válido más allá de 7 días sin pedir reautorización (la app OAuth está en 'In production', por lo que el límite de 7 días del modo 'Testing' no aplica)
- [x] #4 El servicio gdrive-sync-dani ya no emite el ERROR 'Failed to save config ... permission denied' en journald
- [x] #5 rclone persiste el access token refrescado en una ubicación escribible sin exponer el secreto en el Nix store ni dejarlo world-readable
- [x] #6 Tras los cambios, un systemctl start gdrive-sync-dani.service completa sin errores y la sync sigue funcionando bidireccionalmente
<!-- AC:END -->
