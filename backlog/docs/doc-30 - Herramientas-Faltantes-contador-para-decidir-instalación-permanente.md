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
| imagemagick | 1 | 2026-09-17 | Recortar/ampliar capturas de workhorse para leer sliders (calibración HDR de Hogwarts) |
| photocraft | 1 | 2026-10-07 | Editor de imágenes en Rust (reimpl. Photoshop); flake temporal envolviendo el .dmg macos-universal firmado. No está en nixpkgs ni brew |
| yt-dlp | 1 | 2026-10-25 | Extraer cookies de Chrome (`--cookies-from-browser`) y listar formatos de un vídeo de Vimeo que exige login; la descarga final va en el nas (donde yt-dlp sí está instalado) |

## Workhorse

| Paquete | Usos | Último uso | Notas |
|---------|------|-----------|-------|
| drm_info | 1 | 2026-09-17 | Inspeccionar propiedades KMS del conector HDMI (Colorspace/HDR_OUTPUT_METADATA) al depurar HDR en la Sony |
| tcpdump | 3 | 2026-11-13 | Capturar en el bridge br0 el ESP UDP 4501 del VM↔gateway de la VPN y contar salida vs retorno (12 datos salen, solo vuelve 1 keepalive → política del gateway). En el VM `nix run tcpdump` NO funciona con la VPN up (sin internet por el túnel); capturar desde workhorse. Umbral superado: instalar declarativo en workhorse |
| strace | 1 | 2026-11-11 | Diagnosticar por qué el cliente HIP de la VPN no detecta ClamAV en agenthorse: ver los execve (/bin/systemctl, clamscan) que fallan por rutas no-FHS |
| conntrack-tools | 1 | 2026-11-11 | Verificar el tracking/DNAT del UDP 4501 (ESP NAT-T) de la VPN entre el tap de agenthorse y la WiFi del host |
| dnsutils (dig) | 1 | 2026-10-20 | Probar DNS internos desde agenthorse con la VPN levantada |
| qemu | 1 | 2026-10-20 | VM Ubuntu 24.04 desechable para probar un cliente VPN oficial |
| cloud-utils | 1 | 2026-10-20 | Generar el seed de cloud-init (cloud-localds) para esa VM |
| openssl | 1 | 2026-10-20 | Verificar en agenthorse cadenas TLS contra el bundle de CAs del sistema |
| age | 1 | 2026-10-20 | Cifrar un secreto agenix desde el Mac del trabajo (sin nix) vía workhorse |

## Siemens

| Paquete | Usos | Último uso | Notas |
|---------|------|-----------|-------|
| ddrescue | 1 | 2026-09-20 | Volcar a ISO el DVD-Video insertado en /dev/sr0 (label DVD_2) para llevarlo al Mac |
| exfatprogs | 1 | 2026-09-20 | Formatear a exFAT un pendrive Toshiba TransMemory (mkfs.exfat); no hay soporte exFAT nativo en siemens |

## Graduados (ya instalados declarativamente)

| Paquete | Host | Fecha instalación |
|---------|------|-------------------|
| _(vacío)_ | | |
