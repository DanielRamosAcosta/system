---
id: doc-28
title: >-
  Post-Mortem workhorse: sbctl sign del kernel rompe el arranque con lanzaboote
  (SECURITY_VIOLATION)
type: other
created_date: '2026-08-23 20:14'
tags:
  - workhorse
  - secure-boot
  - lanzaboote
  - post-mortem
---
## Resumen

Durante la activación de Secure Boot en `workhorse` (lanzaboote + sbctl), tras firmar manualmente el fichero del kernel de `/EFI/nixos/` con `sbctl sign`, **el equipo dejó de arrancar**: el stub de lanzaboote entraba en panic con `Kernel hash does not match!` → `SECURITY_VIOLATION`. Ninguna generación arrancaba.

## Síntoma (pantalla)

```
[WARN]  stub/src/thin.rs@071: Secure Boot is not active!
[ERROR] stub/src/thin.rs@091: Kernel hash does not match!
[PANIC] panicked at stub/src/main.rs:52:10:
Failed to extract configuration from binary and load kernel/initrd from disk.
Did you run lzbt?: Error { status: SECURITY_VIOLATION, data: () }
```

## Causa raíz

lanzaboote usa **"thin stubs"**: el UKI firmado (`/EFI/Linux/nixos-generation-N-*.efi`) lleva **embebido el hash** del kernel e initrd, y los carga desde `/EFI/nixos/` verificándolos por ese hash. **El kernel y el initrd de `/EFI/nixos/` van SIN firmar a propósito** — su integridad la garantiza el hash dentro del stub, que sí está firmado.

`sbctl sign` **añade una firma PE al binario**, lo que **cambia sus bytes** → el hash deja de coincidir con el que el stub espera → `SECURITY_VIOLATION`. Como ambas generaciones eran el mismo kernel 7.2 (mismo `nixpkgs`, fichero compartido y nombrado por hash), al firmar ese único fichero **se rompieron todas**.

### Por qué se cometió el error

`sbctl verify` marca el kernel de `/EFI/nixos/` como `✗ not signed`. **Eso es CORRECTO y esperado** bajo lanzaboote. Se interpretó erróneamente como algo a "arreglar" firmándolo. Lo único que debe salir firmado (`✓`) es:
- `/EFI/BOOT/BOOTX64.EFI`
- `/EFI/systemd/systemd-bootx64.efi`
- Los UKI `/EFI/Linux/nixos-generation-*.efi`

## Recuperación

Como no arrancaba ninguna generación, se recuperó desde un LiveCD:

1. Arrancar el **USB de Ubuntu** (menú de arranque F8 → USB en modo UEFI).
2. Habilitar SSH en el live (o trabajar en local).
3. Montar los discos (labels estables de disko):
   ```bash
   mount /dev/disk/by-partlabel/disk-main-root /mnt
   mount /dev/disk/by-partlabel/disk-main-ESP  /mnt/boot
   ```
4. Restaurar el kernel original desde el nix store (el symlink `<toplevel>/kernel` apunta al `bzImage` correcto):
   ```bash
   cp /mnt/nix/store/<hash>-linux-7.2/bzImage \
      /mnt/boot/EFI/nixos/kernel-7.2-<hash>.efi
   ```
   Verificar que `sha256sum` del fichero del ESP coincide con el `bzImage` del store.
5. `umount /mnt/boot /mnt` y reiniciar.

Tras esto el arranque volvió a la normalidad y Secure Boot se completó **sin volver a firmar el kernel** (`sbctl enroll-keys --microsoft` + activar SB en BIOS).

## Lecciones / Prevención

- **NUNCA hacer `sbctl sign` a los ficheros de `/EFI/nixos/` (kernel/initrd) bajo lanzaboote.** Van sin firmar por diseño.
- Que `sbctl verify` los liste como `not signed` **no es un fallo**; es lo correcto.
- lanzaboote ya firma automáticamente lo que debe (stubs UKI + systemd-boot + BOOTX64) en cada `nixos-rebuild`/activación.
- **Red de seguridad de Secure Boot**: si un arranque con SB falla, basta con **desactivar Secure Boot en la BIOS** para volver a arrancar (todo funciona con SB off). Solo este caso concreto (kernel corrupto) exigió LiveCD, porque rompía el arranque **también con SB desactivado**.
