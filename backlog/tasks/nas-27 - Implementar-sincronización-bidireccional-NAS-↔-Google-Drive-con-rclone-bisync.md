---
id: NAS-27
title: Implementar sincronización bidireccional NAS ↔ Google Drive con rclone bisync
status: To Do
assignee: []
created_date: '2026-06-19 19:11'
updated_date: '2026-06-21 09:57'
labels:
  - nas
  - rclone
  - google-drive
  - nixos
dependencies: []
priority: medium
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## TLDR

Módulo NixOS genérico `services.gdrive-sync` que sincroniza `/cold-data/sftpgo/data/<user>/Crítico` con `gdrive:Crítico` cada hora usando `rclone bisync`. Instanciado inicialmente solo para `dani`. Token OAuth gestionado con agenix.

---

## Descripción funcional

El usuario podrá depositar ficheros en un directorio llamado `Crítico` dentro de su espacio en el NAS y estos se sincronizarán automáticamente con una carpeta homónima en su Google Drive personal. La sincronización es bidireccional: cambios en el NAS suben a Drive, cambios en Drive bajan al NAS.

- Frecuencia: cada hora (systemd timer)
- En conflicto (mismo fichero modificado en ambos lados): gana el más reciente, el otro se borra
- Si se detecta borrado masivo (>50% de ficheros): la sync se aborta y queda error en el log
- Red de seguridad ante pérdida accidental: snapper (snapshots btrfs locales) + historial de versiones de Google Drive

---

## Contexto técnico

### Módulo NixOS
- Fichero: `hosts/nas/services/gdrive-sync.nix`
- Define opciones `services.gdrive-sync.users.<name>` con `lib.types.attrsOf`
- Genera un par `systemd.services.gdrive-sync-<name>` + `systemd.timers.gdrive-sync-<name>` por cada usuario habilitado
- El servicio corre como el propio usuario (`serviceConfig.User = name`)

### Interfaz del módulo
```nix
services.gdrive-sync.users.dani = {
  enable = true;
  rcloneConfigFile = config.age.secrets.dani-rclone-gdrive.path;
  # interval = "1h";  # opcional
};
```

### Convenciones fijas (no configurables por diseño)
- Path local: `/cold-data/sftpgo/data/<user>/Crítico`
- Path remoto: `gdrive:Crítico`
- Nombre del remote en rclone.conf: `gdrive`

### Flags de rclone bisync
```
rclone bisync <local> gdrive:Crítico \
  --config <rcloneConfigFile> \
  --conflict-resolve newer \
  --conflict-loser delete \
  --max-delete 50 \
  --create-empty-src-dirs
```

### Secreto OAuth
- Fichero cifrado: `secrets/dani-rclone-gdrive.age`
- Receptores en `secrets/secrets.nix`: `[nas, dani]`
- Declarado en `hosts/nas/secrets.nix` con `owner = "dani"` para que el servicio pueda leerlo
- Contenido: rclone.conf con sección `[gdrive]` incluyendo `access_token` y `refresh_token`

### Integración con la config existente
- Import añadido en `hosts/nas/services/default.nix`
- Instanciación del módulo + declaración del secret en `hosts/nas/secrets.nix`
- El primer `--resync` se hace manualmente por SSH tras el primer deploy
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 El módulo acepta múltiples usuarios vía `users.<name>` y genera un timer/service por cada uno habilitado
- [ ] #2 El directorio /cold-data/sftpgo/data/dani/Crítico se sincroniza con gdrive:Crítico cada hora
- [ ] #3 En conflicto gana el fichero más reciente; el otro se borra
- [ ] #4 Un borrado de más del 50% aborta la sync y deja error en journald
- [ ] #5 El token OAuth está cifrado con agenix, owner=dani, y no aparece en el Nix store
- [ ] #6 El servicio corre como usuario dani, no como root
- [ ] #7 Un fichero creado en el NAS aparece en Google Drive tras la siguiente sync
- [ ] #8 Un fichero creado en Google Drive aparece en el NAS tras la siguiente sync
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Fase 0 — Bootstrap del token OAuth

**Paso 1.** Conectarse al NAS y lanzar rclone config:
```bash
ssh nas
nix run nixpkgs#rclone -- config
```
Crear un nuevo remote llamado `gdrive`, tipo `drive`. Usar las credenciales integradas de rclone (opción por defecto). Rclone detecta que no hay navegador y genera una URL.

**Paso 2.** Abrir la URL en cualquier navegador (macbook, móvil...), autorizar con la cuenta de Google de dani, y pegar el código de vuelta en el terminal del NAS.

**Test 1.** Verificar que el remote funciona:
```bash
nix run nixpkgs#rclone -- lsd gdrive:
```
Debe listar las carpetas del Google Drive sin errores.

**Paso 3.** Copiar el contenido del config generado y cifrarlo con agenix (desde el macbook, donde está el repo):
```bash
# En el NAS: cat /root/.config/rclone/rclone.conf  → copiar contenido
# En el macbook:
agenix -e secrets/dani-rclone-gdrive.age  # pegar contenido y guardar
```

**Test 2.** Verificar que el fichero cifrado es legible:
```bash
agenix -d secrets/dani-rclone-gdrive.age
```
Debe mostrar el rclone.conf con la sección `[gdrive]` y el token.

---

## Fase 1 — Código NixOS

**Paso 4.** Añadir en `secrets/secrets.nix`:
```nix
"dani-rclone-gdrive.age".publicKeys = [ nas dani ];
```

**Paso 5.** Añadir en `hosts/nas/secrets.nix`:
```nix
age.secrets.dani-rclone-gdrive = {
  file = ../../secrets/dani-rclone-gdrive.age;
  owner = "dani";
};
```

**Paso 6.** Escribir `hosts/nas/services/gdrive-sync.nix` con:
- Módulo genérico `options.services.gdrive-sync.users` usando `lib.types.attrsOf (lib.types.submodule {...})`
- Instanciación de dani dentro del mismo fichero, referenciando `config.age.secrets.dani-rclone-gdrive.path`
- Por cada usuario habilitado, generar `systemd.services.gdrive-sync-<name>` con:
  - `serviceConfig.User = name`
  - `serviceConfig.Environment = "HOME=/home/${name}"` ← systemd no hereda HOME automáticamente
  - `after = [ "network-online.target" ]` + `wants = [ "network-online.target" ]`
- Por cada usuario, generar `systemd.timers.gdrive-sync-<name>` con:
  - `OnBootSec = "10min"` ← margen para que dhcpcd asigne IP antes del primer disparo
  - `OnUnitActiveSec = userCfg.interval`
- Añadir `pkgs.rclone` en `environment.systemPackages`

**Flags de rclone bisync en ExecStart:**
```
${pkgs.rclone}/bin/rclone bisync
  /cold-data/sftpgo/data/<user>/Crítico
  gdrive:Crítico
  --config <rcloneConfigFile>
  --conflict-resolve newer
  --conflict-loser delete
  --max-delete 50
  --create-empty-src-dirs
```

**Paso 7.** Añadir `./gdrive-sync.nix` en `hosts/nas/services/default.nix`.

**Test 3.** Dry-run:
```bash
make dry-activate-nas
```
Debe evaluar sin errores y mostrar en el diff `gdrive-sync-dani.service` y `gdrive-sync-dani.timer`.

---

## Fase 2 — Deploy

**Paso 8.** Deploy:
```bash
make activate-nas
```

**Test 4.** Verificar units registrados:
```bash
ssh nas systemctl list-timers | grep gdrive
```
Debe aparecer `gdrive-sync-dani.timer`.

**Test 5.** Verificar estado:
```bash
ssh nas systemctl status gdrive-sync-dani.service
ssh nas systemctl status gdrive-sync-dani.timer
```

---

## Fase 3 — Resync inicial y prueba end-to-end

**Paso 9.** Crear el directorio Crítico en el NAS y en Drive:
```bash
ssh nas sudo -u dani mkdir -p "/cold-data/sftpgo/data/dani/Crítico"
ssh nas sudo -u dani rclone mkdir gdrive:Crítico --config /run/agenix/dani-rclone-gdrive
```
El segundo comando crea la carpeta en Drive si no existe (bisync no la crea automáticamente).

**Paso 10.** Resync inicial (solo la primera vez):
```bash
ssh nas sudo -u dani rclone bisync \
  "/cold-data/sftpgo/data/dani/Crítico" \
  gdrive:Crítico \
  --config /run/agenix/dani-rclone-gdrive \
  --resync
```

**Test 6.** Arrancar el servicio manualmente y revisar logs:
```bash
ssh nas systemctl start gdrive-sync-dani.service
ssh nas journalctl -u gdrive-sync-dani -n 50
```
Debe completar sin errores.

**Test 7 (NAS → Drive).** Verificar sync ascendente:
```bash
ssh nas sudo -u dani touch "/cold-data/sftpgo/data/dani/Crítico/test-desde-nas.txt"
ssh nas systemctl start gdrive-sync-dani.service
# Verificar en drive.google.com que aparece Crítico/test-desde-nas.txt
```

**Test 8 (Drive → NAS).** Verificar sync descendente:
```bash
# Crear un fichero en drive.google.com dentro de Crítico/ desde el navegador
ssh nas systemctl start gdrive-sync-dani.service
ssh nas ls "/cold-data/sftpgo/data/dani/Crítico/"
# Debe aparecer el fichero creado en Drive
```
<!-- SECTION:PLAN:END -->

## Comments

<!-- COMMENTS:BEGIN -->
created: 2026-06-19 19:21
---
## Dry-run analysis (subagente)

Análisis previo a la implementación. Issues encontrados:

### Bloqueantes

**[B1] `secrets.nix` no tiene `config` en scope**
El fichero actual es un atributo set sin argumentos. Instanciar `services.gdrive-sync.users.dani.rcloneConfigFile = config.age.secrets...` ahí fallaría. Solución: poner la instanciación del módulo en el propio `gdrive-sync.nix` (que sí recibe `config`), y dejar en `secrets.nix` solo la declaración del secret.

**[B2] `HOME` no se hereda en servicios systemd con `User =`**
`rclone bisync` escribe su estado en `$HOME/.cache/rclone/bisync/`. systemd no establece HOME automáticamente al correr con `User = dani`. Sin `Environment = "HOME=/home/dani"` en el serviceConfig, rclone escribiría en `/root/.cache/` o fallaría. Solución: añadir `Environment = "HOME=/home/${name}"` en el módulo.

**[B3] Dependencia `network-online.target` ausente**
El timer puede dispararse en boot antes de que dhcpcd asigne IP. Solución: añadir `after = ["network-online.target"]` y `wants = ["network-online.target"]` al service, y subir `OnBootSec` a `"10min"`.

### Advertencias

**[A1] `gdrive:Crítico` debe crearse antes del `--resync`**
`rclone bisync --resync` falla si el directorio remoto no existe. Solución: ejecutar `rclone mkdir gdrive:Crítico` antes del resync inicial.

**[A2] `rclone` no está en el PATH global del sistema**
Después del deploy, `sudo -u dani rclone ...` en SSH fallará con "command not found". Solución: añadir `pkgs.rclone` a `environment.systemPackages` en el módulo gdrive-sync.

**[A3] `OnBootSec = "2min"` demasiado agresivo**
Dhcpcd puede tardar más de 2 minutos si el switch tarda en levantar el link. Cambiado a `"10min"`.

### Sugerencias

**[S1] No mezclar dominios en `secrets.nix`**
El patrón del repo es un fichero por dominio. La instanciación del módulo va en `gdrive-sync.nix`, no en `secrets.nix`.

### No problemático
- UTF-8 en path `Crítico`: NixOS, systemd y rclone manejan paths UTF-8 sin problema.
- `path = [...]` vs path completo en ExecStart: ambos correctos, se usa path completo por consistencia con el repo.
---
<!-- COMMENTS:END -->
