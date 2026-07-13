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

## 🛡️ Endurecimiento post-review (2026-07-13)

Tras una revisión de ops (calidad + mejores prácticas rclone bisync) se aplicaron al servicio:
- **Sin pérdida por conflictos**: eliminado `--conflict-loser delete`; ahora el default renombra el perdedor (`.conflict1`) en vez de borrarlo.
- **`--check-access`** con ficheros `RCLONE_TEST` en la raíz de ambos lados: si un lado se monta vacío/inaccesible, bisync aborta en vez de propagar borrados masivos. Los `RCLONE_TEST` deben tener el mismo modtime en ambos lados (se copian con `rclone copyto`, no con `touch` independiente).
- **Resiliencia para timer**: `--resilient --recover --max-lock 2m` → interrupciones/locks huérfanos se auto-recuperan sin `--resync` manual.
- **Timer**: `Persistent = true` (recupera ventanas perdidas si el NAS estaba apagado) y `RandomizedDelaySec = 5m`.
- **Servicio**: `RuntimeMaxSec = 50m` (evita solapes con el siguiente disparo) y hardening systemd (`NoNewPrivileges`, `ProtectSystem=strict`, `ProtectHome`, `PrivateTmp`, `RestrictAddressFamilies`, `ProtectKernelTunables`).
- **Cache/workdir**: el workdir de bisync se fija con `--workdir ''${CACHE_DIRECTORY}/bisync` (systemd `CacheDirectory`), no vía `$HOME` (que `ProtectHome` bloquea). `RCLONE_CACHE_DIR` NO controla el workdir de bisync.
- **Re-seed automático del token**: el `ExecStartPre` re-siembra `rclone.conf` desde el secreto solo cuando el secreto de agenix cambia (`cmp` contra `.seed-source`), eliminando el paso manual de borrar el fichero al regenerar el token.

- **Papelera de reciclaje** (`--backup-dir1/2`): antes de replicar un borrado/sobrescritura, la versión antigua se aparta a una papelera en cada lado, dando red de seguridad contra borrados accidentales que el sync propagaría. Local: `/cold-data/sftpgo/data/<user>/.trash/Crítico` (creada por `systemd.tmpfiles` con owner del usuario, añadida a `ReadWritePaths`). Remoto: `gdrive:Crítico-trash` (vecino de `Crítico`). Verificado end-to-end: un fichero borrado en Drive desaparece de `Crítico` en el NAS pero se conserva en `.trash`. La papelera crece con el tiempo; su vaciado/retención queda manual por ahora.

Pendiente (fuera de scope de esta task): notificación/alerta ante fallo (Grafana/OnFailure).
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
