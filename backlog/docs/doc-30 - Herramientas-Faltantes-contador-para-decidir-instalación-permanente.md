---
id: doc-30
title: Herramientas Faltantes (contador para decidir instalación permanente)
type: guide
created_date: '2026-09-09 18:01'
---
Registro de paquetes que aún **no** están instalados de forma declarativa y que ejecutamos de forma efímera (`nix run`, `nix shell`, `nix-shell -p`, `comma` / `,`).

## Propósito

Cada vez que necesitemos una herramienta que no está en la configuración del host y la lancemos de forma efímera, incrementamos su contador aquí. Cuando un contador sube lo suficiente, es señal de que merece la pena añadir el paquete a la configuración declarativa del host correspondiente (`hosts/<host>/`) en vez de seguir invocándolo a mano.

**Cómo usarlo:**
- Al ejecutar algo efímero, buscar la fila del paquete en la sección del host. Si existe, sumar 1 y actualizar la fecha. Si no existe, añadir la fila con contador `1`.
- Umbral orientativo: a partir de **3–5 usos** plantear instalarlo declarativamente.
- Al instalar un paquete de forma definitiva, mover la fila a la sección "Graduados" o eliminarla.

## NAS

| Paquete | Usos | Último uso | Notas |
|---------|------|-----------|-------|
| _(vacío)_ | | | |

## Mac

| Paquete | Usos | Último uso | Notas |
|---------|------|-----------|-------|
| sshpass | 1 | 2026-09-13 | Login por contraseña al SystemRescue del rescate de discos (ssh-copy-id inicial) |
| python3 + pydicom/numpy/pillow | 1 | 2026-09-13 | Convertir DICOM (RM columna lumbar) a PNG por series |

## Workhorse

| Paquete | Usos | Último uso | Notas |
|---------|------|-----------|-------|
| _(vacío)_ | | | |

## Graduados (ya instalados declarativamente)

| Paquete | Host | Fecha instalación |
|---------|------|-------------------|
| _(vacío)_ | | |
