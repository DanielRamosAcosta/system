---
id: NAS-14
title: Move postgres-backups from SSD to cold-data btrfs disk
status: In Progress
assignee: []
created_date: '2026-03-09 17:10'
updated_date: '2026-03-21 19:24'
labels:
  - infrastructure
  - storage
dependencies: []
priority: high
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The `/cold-data/postgres-backups/` directory is NOT a btrfs subvolume mount — it's falling through to the root filesystem on the NVMe SSD RAID. This means 342GB of WAL archives are consuming SSD space instead of being on the HDD.

**Current state (verified 2026-03-18):**
- `nixroot` = btrfs RAID1 across `nvme0n1p2` + `nvme1n1p2` (2x 931GB SSD), 481GB used (52%)
- `cold-data` = btrfs RAID1 across `sda` + `sdb` (2x 9.1TB HDD), 6.56TiB used (73%)
- `/cold-data/postgres-backups/` confirmed on nixroot SSD (342GB: `wal_archive/` + `base/`)
- No `@postgres-backups` subvolume exists on cold-data
- Existing cold-data subvolumes (all top-level, parent ID 5): @immich, @sftpgo, @gitea, @booklore, @media, @downloads
- Default subvolume is ID 5 (FS_TREE) — bare mount shows top-level
- `/dev/disk/by-label/cold-data` → `/dev/sda` (works fine for multi-device btrfs)
- K8s PV path `/cold-data/postgres-backups` stays the same — no k8s changes needed (managed in `nas-k3s` repo)

**Key risk:** NixOS fstab has no `nofail` on any mount. If we deploy a config referencing a subvolume that doesn't exist, the system fails to boot and needs rescue from a previous NixOS generation.

**Impact:** Frees ~342GB on the SSD RAID.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 postgres-backups is a btrfs subvolume @postgres-backups on /dev/sda (cold-data)
- [ ] #2 Mount entry exists in hardware-configuration.nix with compress=zstd
- [ ] #3 WAL archives and base backups are stored on HDD not SSD
- [ ] #4 Old data removed from root SSD — SSD space reclaimed
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Phase 0: Pre-flight checks (SSH into NAS) — sin downtime

1. **Verificar espacio en cold-data** (data Y metadata)
   ```
   btrfs fi usage /cold-data/immich
   ```
   Confirmar que hay espacio suficiente para 342GB de data + metadata.

2. **Verificar que /mnt no está en uso**
   ```
   mountpoint /mnt || echo "free"
   ```

## Phase 1: Crear subvolume (SSH into NAS) — sin downtime

3. **Mount cold-data filesystem root** (explicitly subvolid=5 for safety)
   ```
   mount -o subvolid=5 /dev/disk/by-label/cold-data /mnt
   ```

4. **Create subvolume**
   ```
   btrfs subvolume create /mnt/@postgres-backups
   ```

5. **Verify it exists**
   ```
   btrfs subvolume list /mnt | grep postgres
   ```

6. **Unmount**
   ```
   umount /mnt
   ```

## Phase 2: Pre-sync — copia gruesa sin downtime (SSH into NAS)

7. **Mount subvolume en path temporal**
   ```
   mkdir -p /mnt/pg-presync
   mount -o compress=zstd,subvol=@postgres-backups /dev/disk/by-label/cold-data /mnt/pg-presync
   ```

8. **Verify** it's on cold-data
   ```
   df -h /mnt/pg-presync
   ```
   Must show `/dev/sdb` (or `/dev/sda`), NOT `/dev/nvme*`

9. **If mount FAILS → STOP. Investigate.**

10. **Clonar permisos del directorio raíz** (el subvolume nuevo viene con root:root 755)
    ```
    chmod --reference=/cold-data/postgres-backups /mnt/pg-presync
    chown --reference=/cold-data/postgres-backups /mnt/pg-presync
    ```

11. **⚠️ HANDOFF AL USUARIO — EJECUTAR MANUALMENTE EN TMUX ⚠️**

    Este rsync tarda ~1 hora (342GB con checksum, SSD→HDD).
    Si la conexión SSH se corta, el proceso muere y hay que empezar de nuevo.

    **El agente debe PARAR aquí y pedir al usuario que ejecute manualmente:**

    ```
    ssh nas
    tmux new -s pg-migration
    rsync -acP /cold-data/postgres-backups/ /mnt/pg-presync/
    ```

    ⚠️ No continuar hasta que el rsync termine.
    ⚠️ Si se corta la conexión: `ssh nas` → `tmux attach -t pg-migration`
    ⚠️ **Exit code 24 ("file vanished") es ACEPTABLE** — postgres sigue escribiendo WAL durante el pre-sync. El delta sync en Phase 6 corregirá cualquier discrepancia en frío.
    ⚠️ Solo preocuparse si el exit code es distinto de 0 o 24.

12. **Unmount** (puede hacerlo el agente tras confirmación del usuario)
    ```
    umount /mnt/pg-presync
    rmdir /mnt/pg-presync
    ```

## Phase 3: Preparar NixOS config y dry-activate — sin downtime

13. **Add mount entry** in `hosts/nas/hardware-configuration.nix` con `nofail` temporal:
    ```nix
    fileSystems."/cold-data/postgres-backups" = {
      device = "/dev/disk/by-label/cold-data";
      fsType = "btrfs";
      options = [ "compress=zstd" "subvol=@postgres-backups" "nofail" ];
    };
    ```

14. **Dry-activate** para verificar qué cambiaría el deploy
    ```
    nixos-rebuild dry-activate --flake '.#nas'
    ```
    Revisar output. Si aparecen restarts de k3s u otros servicios inesperados, investigar ANTES de continuar. Decidir si el deploy se hace durante o después del downtime.

## Phase 4: Desactivar ArgoCD auto-sync (desde local)

15. **Desactivar auto-sync** en todas las apps afectadas
    ```
    argocd app set postgres --sync-policy none
    argocd app set authelia --sync-policy none
    argocd app set grafana --sync-policy none
    argocd app set gitea --sync-policy none
    argocd app set immich --sync-policy none
    argocd app set invidious --sync-policy none
    argocd app set sftpgo --sync-policy none
    ```

16. **Verificar que sync está desactivado** antes de continuar
    ```
    argocd app get postgres -o json | jq '.spec.syncPolicy'
    ```
    Debe mostrar `null` o sin `automated`.

## Phase 5: Parar servicios (SSH into NAS) — EMPIEZA DOWNTIME

17. **Scale down servicios dependientes de postgres** (consumidores primero)
    ```
    kubectl scale deploy/authelia -n auth --replicas=0
    kubectl scale deploy/grafana -n monitoring --replicas=0
    kubectl scale statefulset/gitea -n media --replicas=0
    kubectl scale statefulset/immich -n media --replicas=0
    kubectl scale deploy/immich-machine-learning -n media --replicas=0
    kubectl scale statefulset/invidious -n media --replicas=0
    kubectl scale deploy/invidious-companion -n media --replicas=0
    kubectl scale statefulset/sftpgo -n media --replicas=0
    ```

18. **Suspender cronjobs de backup**
    ```
    kubectl patch cronjob/postgres-base-backup -n databases -p '{"spec":{"suspend":true}}'
    kubectl patch cronjob/postgres-backup-cleanup -n databases -p '{"spec":{"suspend":true}}'
    ```

19. **Verificar que no hay Jobs de backup activos** (suspender cronjobs no mata jobs ya lanzados)
    ```
    kubectl get jobs -n databases | grep -v Completed
    ```
    Si hay jobs Running, esperar a que terminen antes de continuar.

20. **Scale down postgres** (productor último)
    ```
    kubectl scale statefulset/postgres -n databases --replicas=0
    ```

21. **Esperar a que el pod de postgres termine completamente** (checkpoint + shutdown limpio)
    ```
    kubectl wait --for=delete pod -l app=postgres -n databases --timeout=120s
    ```
    No tocar ficheros hasta que el pod haya desaparecido.

## Phase 6: Delta sync y montar (SSH into NAS)

22. **Rename existing directory** to free the mount point
    ```
    mv /cold-data/postgres-backups /cold-data/postgres-backups-old
    mkdir -p /cold-data/postgres-backups
    ```

23. **Mount the subvolume** at the final path
    ```
    mount -o compress=zstd,subvol=@postgres-backups /dev/disk/by-label/cold-data /cold-data/postgres-backups
    ```
    **Si falla → rollback:**
    ```
    rmdir /cold-data/postgres-backups
    mv /cold-data/postgres-backups-old /cold-data/postgres-backups
    ```
    Y restaurar servicios.

24. **Sync solo el delta sin checksum** (velocidad, solo size+mtime — segundos)
    ```
    rsync -aP --delete /cold-data/postgres-backups-old/ /cold-data/postgres-backups/
    ```

25. **Verificar integridad** (size + mtime)
    ```
    rsync -a --dry-run /cold-data/postgres-backups-old/ /cold-data/postgres-backups/
    ```
    No debe reportar diferencias.

26. **Verificar ownership/permisos**
    ```
    ls -la /cold-data/postgres-backups/
    ls -la /cold-data/postgres-backups-old/
    ```
    Deben coincidir. Si no coinciden, rescue:
    ```
    chmod --reference=/cold-data/postgres-backups-old /cold-data/postgres-backups
    chown --reference=/cold-data/postgres-backups-old /cold-data/postgres-backups
    ```

## Phase 7: Restaurar servicios (SSH into NAS)

27. **Scale up postgres** (productor primero)
    ```
    kubectl scale statefulset/postgres -n databases --replicas=1
    ```
    Wait for pod to be Ready.

28. **Reactivar cronjobs**
    ```
    kubectl patch cronjob/postgres-base-backup -n databases -p '{"spec":{"suspend":false}}'
    kubectl patch cronjob/postgres-backup-cleanup -n databases -p '{"spec":{"suspend":false}}'
    ```

29. **Scale up servicios dependientes** (consumidores último)
    ```
    kubectl scale deploy/authelia -n auth --replicas=1
    kubectl scale deploy/grafana -n monitoring --replicas=1
    kubectl scale statefulset/gitea -n media --replicas=1
    kubectl scale statefulset/immich -n media --replicas=1
    kubectl scale deploy/immich-machine-learning -n media --replicas=1
    kubectl scale statefulset/invidious -n media --replicas=1
    kubectl scale deploy/invidious-companion -n media --replicas=1
    kubectl scale statefulset/sftpgo -n media --replicas=1
    ```

30. **Verify** all pods are Running/Ready — FIN DOWNTIME
    ```
    kubectl get pods -A | grep -v Running
    ```

## Phase 8: Deploy NixOS config — sin downtime

31. **Deploy**: `just deploy-nas`

32. **Verificar que systemd adoptó el mount correctamente**
    ```
    findmnt --verify
    systemctl status cold\\x2ddata-postgres\\x2dbackups.mount
    ```
    Verificar que no aparece failed/changed. systemd debe adoptar el mount manual.

33. **Verify mount survived deploy**
    ```
    df -h /cold-data/postgres-backups
    mount | grep postgres
    ```

## Phase 9: Reboot y verificar (SSH into NAS)

34. **Reboot** para validar que el fstab sobrevive un arranque frío
    ```
    reboot
    ```
    ⚠️ Esto causa downtime global de TODOS los servicios del NAS (Samba, VPN, DNS, etc.), no solo postgres. El `nofail` mitiga el riesgo de rescue shell, pero el reboot en sí afecta a todo.

35. **Verificar post-reboot**
    ```
    df -h /cold-data/postgres-backups
    mount | grep postgres
    kubectl get pods -A | grep -v Running
    ```
    Todo debe estar montado y los pods Running.

## Phase 10: Restaurar ArgoCD auto-sync (desde local)

36. **Re-enable auto-sync** (respetando policy original de cada app)
    ```
    argocd app set postgres --sync-policy automated --auto-prune
    argocd app set authelia --sync-policy automated --self-heal --auto-prune
    argocd app set grafana --sync-policy automated --self-heal --auto-prune
    argocd app set gitea --sync-policy automated --self-heal --auto-prune
    argocd app set immich --sync-policy automated --self-heal --auto-prune
    argocd app set invidious --sync-policy automated --self-heal --auto-prune
    argocd app set sftpgo --sync-policy automated --self-heal --auto-prune
    ```

## Phase 11: Limpieza SSD (SSH into NAS)

37. **Verificar que `-old` NO es un mount point** (precaución antes de rm -rf)
    ```
    mountpoint /cold-data/postgres-backups-old && echo "⚠️ ES UN MOUNT POINT - NO BORRAR" || echo "OK - safe to delete"
    ```

38. **Delete old data** from SSD
    ```
    rm -rf /cold-data/postgres-backups-old
    ```

39. **Verify** SSD usage dropped
    ```
    df -h /
    ```

## Phase 12: Quitar nofail (siguiente sesión)

40. **Quitar `nofail`** del mount entry en `hardware-configuration.nix` para igualar al resto de mounts
41. **Deploy**: `just deploy-nas`
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Insights (verified 2026-03-18 via SSH inspection)

- **No snapper needed** — postgres backups are already backups
- **No k8s changes needed** — PV path stays the same, managed in `nas-k3s` repo
- **RAID1 on both filesystems** — nixroot (2x NVMe), cold-data (2x HDD). `by-label` references work fine for multi-device btrfs
- **`/cold-data` is not a mount point** — it's a directory on root SSD. Only subdirs with explicit mounts go to HDD; the rest falls through to SSD
- **Default subvolume is ID 5 (FS_TREE)** — bare mount shows top-level, but use `subvolid=5` explicitly for safety when creating subvolumes
- **No `nofail` on any fstab entry** — a failed mount prevents boot. This is why manual mount testing (Phase 3) is critical before deploying
- **Previous crashes were likely caused by deploying a config that references a non-existent subvolume** — Phase 3 (manual mount test) is the safety gate to prevent this
- **Rename-first approach** — moving to `-old` avoids temp mounts and simplifies SSD cleanup (just `rm -rf`)
- **342GB actual size** (not 299GB as originally estimated)

- **Postgres dependientes (verified via create-user init jobs):** authelia, gitea, grafana, immich (+immich-machine-learning), invidious (+invidious-companion), sftpgo. Piped tiene user creado pero no está desplegado actualmente

- **Cronjobs a suspender:** `postgres-base-backup` (02:00 daily), `postgres-backup-cleanup` (03:00 daily)

- **Orden crítico:** consumidores down → productor down → migración → productor up → consumidores up

- **ArgoCD sync policies:** todos los consumidores tienen `selfHeal:true` (ArgoCD revierte cambios manuales). `postgres` solo tiene `prune:true` (no selfHeal). Hay que desactivar auto-sync antes de escalar y restaurarlo al final

- **Al restaurar sync:** respetar la policy original de cada app. Postgres solo tiene `prune:true`, los demás tienen `prune:true` + `selfHeal:true`

- **Downtime minimizado:** crear subvolume + safety gate se hacen antes de parar nada. El deploy de NixOS (que es lento) se hace después de restaurar servicios, ya que solo persiste el mount para reboots. El downtime real es solo: parar servicios → rsync 342GB → levantar servicios

- **ArgoCD CLI disponible en local** (contexto: `argocd.danielramos.me`). Mucho más limpio que patches de kubectl: `argocd app set --sync-policy none` para desactivar, `argocd app set --sync-policy automated --self-heal --auto-prune` para restaurar

- **Pre-sync reduce downtime de ~1h a segundos:** la copia gruesa (342GB, ~40-60min a 100-150MB/s de SSD→HDD) se hace en Phase 2 con servicios corriendo. En Phase 5 solo se sincroniza el delta (WAL segments escritos entre pre-sync y parada de postgres). Con `--delete` para que el destino sea réplica exacta

- **Verificación con size+mtime (no checksum):** `rsync -c` re-leería los 342GB de ambos lados, duplicando el tiempo. La verificación por defecto de rsync (size+mtime) es suficiente para detectar copias incompletas

- **Permisos del mount point raíz:** un subvolume btrfs nuevo viene con `root:root 755`. Hay que clonar permisos del directorio original con `chmod/chown --reference` ANTES del rsync, para que el mount point raíz tenga los permisos correctos (rsync -a copia contenido pero no siempre ajusta el directorio raíz del destino)

- **Estrategia de checksum dual:** pre-sync (Phase 2) usa `rsync -c` porque no hay prisa y garantiza integridad bit a bit. Delta sync (Phase 5) usa size+mtime porque está en ventana de downtime y el delta es pequeño — los ficheros nuevos de WAL son ficheros completos, no parciales

- **kubectl wait --for=delete** tras escalar postgres a 0: garantiza que el pod ha hecho shutdown limpio (checkpoint + WAL final) antes de tocar ficheros. Sin esto, mover el directorio mientras postgres escribe puede corromper el último backup

- **rsync exit code 24 es aceptable en pre-sync:** significa "file vanished" — normal cuando postgres rota WAL durante la copia. El delta sync en frío corrige esto

- **findmnt --verify + systemctl status** post-deploy como verificación sin reboot. El reboot sigue siendo recomendable para máxima seguridad, pero con advertencia de que afecta a todos los servicios del NAS

- **Réplicas al restaurar:** actualmente todos los servicios tienen 1 réplica, pero si alguno cambiara a >1 en GitOps, el scale manual a 1 en Phase 7 sería temporal — ArgoCD lo corregirá al restaurar auto-sync en Phase 10

- **systemd adopta mounts manuales:** al hacer deploy-nas en Phase 8, NixOS crea el `.mount` unit y systemd normalmente adopta el mount manual si las opciones coinciden. Verificar con `systemctl status` que no queda marcado como failed/changed

- **Precaución con rm -rf:** verificar que el directorio `-old` NO es un mount point antes de borrarlo
<!-- SECTION:NOTES:END -->
