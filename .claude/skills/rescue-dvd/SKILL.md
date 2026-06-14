---
name: rescue-dvd
description: Rescatar datos de DVDs rayados desde un portátil con LiveCD de Lubuntu conectado a la red local del NAS. Detecta, copia, rescata sectores dañados con ddrescue y registra progreso en backlog/docs/doc-21.
---

Eres un operador de rescate de DVDs. El usuario tiene un portátil con lector de CDs corriendo un LiveCD de Lubuntu, conectado a la red local del NAS. Todas las operaciones se ejecutan por SSH en ese portátil.

## Pre-checks

### 0. Detección automática de ubicación

Antes de empezar, detecta de forma **autónoma** si la máquina donde corre Claude Code está en la misma LAN que el NAS (y por tanto que el portátil) haciendo ping al NAS:

```bash
ping -c 2 -W 2 192.168.1.200 && echo "DENTRO" || echo "FUERA"
```

Lo que importa no es dónde esté el usuario físicamente, sino si esta máquina alcanza directamente al portátil. Según el resultado, todos los comandos SSH posteriores deben usar el patrón correspondiente:

- **Dentro** (ping OK): `ssh lubuntu@192.168.1.32 '<comando>'`
- **Fuera** (ping falla): `ssh nas "ssh lubuntu@192.168.1.32 '<comando>'"` (puente por el NAS)

Informa al usuario del modo detectado en una línea y continúa — no preguntes para confirmar.

En el modo "fuera", ten cuidado con el escapado de comillas: los `'` internos pueden necesitar ser sustituidos por `'\''` o reestructurados. Si la primera vez por ssh pide contraseña, copia la clave pública del NAS con `ssh-copy-id` (usando `sshpass -p lubuntu` desde `nix-shell -p sshpass` en el NAS).

En el resto del documento, los bloques de comandos muestran solo el comando a ejecutar en el portátil — envuélvelo en el transporte SSH adecuado según la ubicación.

### 1. Paquetes necesarios

Verifica que estos paquetes están instalados en el portátil (ejecuta `dpkg -l <paquete>` para cada uno):

- `openssh-server`
- `gddrescue`
- `dvd+rw-tools`
- `smbclient`
- `screen`

Si alguno falta, instálalo con `sudo apt-get install -y <paquete>`.

### 2. Share Samba montado

Comprueba que `/mnt/nas` existe y tiene contenido montado (`mount | grep /mnt/nas`).

Si no está montado:

1. Pregunta al usuario la contraseña del share Samba
2. Ejecuta:
```bash
sudo mkdir -p /mnt/nas
sudo mount -t cifs -o username=dani,password="<CONTRASEÑA>",vers=3.0,uid=$(id -u),gid=$(id -g) //192.168.1.200/downloads /mnt/nas
```

Verifica que el montaje fue exitoso.

## Flujo de trabajo

Ejecuta cada paso secuencialmente. Informa al usuario del progreso tras cada paso.

## Monitorización de procesos largos

Para operaciones que pueden tardar bastante (cp inicial del DVD al ramdisk, ddrescue), lanza dentro de `screen` y usa **polling proactivo** con `ScheduleWakeup`. La copia final del ramdisk al NAS por Samba es rápida (pocos minutos) — hazla **síncrona** (ver Paso 8), sin screen ni wakeups.

1. Lanza el proceso en `screen` (sobrevive a caídas de SSH).
2. Revisa una vez: si sigue activo, programa un `ScheduleWakeup` con `delaySeconds: 600` (10 min) para volver a revisar automáticamente.
3. Al despertar: si el screen sigue vivo, vuelve a programar otro wakeup. Si ha terminado, continúa con el siguiente paso.

NO uses `while ... sleep` en background dentro de `ssh` — si el SSH se corta por timeout, pierdes el aviso. ScheduleWakeup te despierta desde el cliente sin depender del SSH.

Si el usuario pregunta "¿cómo va?" entremedias, revisa igualmente, pero no canceles el wakeup programado.

### Paso 0: Identificar DVD

Asume que el DVD **ya está insertado** en el lector (el usuario lo metió antes de invocar la skill). No pidas que lo inserte.

La **Etiqueta** (nombre escrito con rotulador en el DVD, usada en DVDS.md en el Paso 9) normalmente viene como argumento de la skill. Si no hay argumento, pregúntala. Guárdala para usarla más adelante.

Si en el Paso 1 la detección del disco falla, entonces sí pregunta al usuario que confirme que ha insertado el DVD.

### Paso 1: Detectar DVD

```bash
blkid /dev/sr0
dvd+rw-mediainfo /dev/sr0
```

Extrae: tipo de disco, label del filesystem y tamaño total. Muestra un resumen al usuario.
Si no se detecta disco, pide al usuario que confirme que ha insertado el DVD y reintenta.

### Paso 2: Montar DVD

```bash
sudo mkdir -p /mnt/dvd
sudo mount -o ro /dev/sr0 /mnt/dvd
ls -lhR /mnt/dvd/VIDEO_TS/
```

Lista el contenido y calcula el tamaño total de VIDEO_TS.

### Paso 3: Preparar directorio de trabajo en RAM

El rescate se hace en RAM para no machacar el share Samba con I/O de ddrescue. Solo se copia al NAS cuando el rescate esté completo.

Comprueba la RAM disponible y verifica que el DVD cabe:

```bash
dvd_bytes=$(du -sb /mnt/dvd/VIDEO_TS/ | cut -f1)
ram_avail=$(awk '/MemAvailable/ {print $2 * 1024}' /proc/meminfo)
echo "DVD: $dvd_bytes bytes | RAM disponible: $ram_avail bytes"
```

Si `dvd_bytes` supera el 80% de `ram_avail`, ABORTA e informa al usuario de que no hay suficiente RAM. Pregunta si quiere continuar escribiendo directamente en el share Samba (fallback al flujo antiguo con `/mnt/nas/<LABEL>/` como destino en pasos 4-6).

Si cabe, crea un tmpfs y el directorio de trabajo:

```bash
sudo mkdir -p /mnt/ramdisk
sudo mount -t tmpfs -o size=$(echo "$dvd_bytes * 120 / 100" | bc) tmpfs /mnt/ramdisk
mkdir -p "/mnt/ramdisk/<LABEL>/"
```

El tmpfs se dimensiona al 120% del tamaño del DVD para dejar margen a los logs de ddrescue.

A partir de aquí, **todos los pasos usan `/mnt/ramdisk/<LABEL>/`** como directorio destino.

### Paso 4: Copia inicial con cp

Ejecuta la copia dentro de `screen` para que sobreviva a caídas de SSH:

```bash
screen -dmS cp-dvd bash -c 'cp -v /mnt/dvd/VIDEO_TS/* "/mnt/ramdisk/<LABEL>/" > /tmp/cp-dvd.log 2>&1'
```

Monitoriza usando el patrón de "Monitorización de procesos largos" (ScheduleWakeup cada 10 min). Para revisar:

```bash
screen -ls | grep cp-dvd
cat /tmp/cp-dvd.log
```

Cuando la sesión screen desaparezca de `screen -ls`, la copia ha terminado. Lee `/tmp/cp-dvd.log` para ver el resultado.

Esto copia rápido todo lo que puede. Los archivos con sectores dañados fallarán o quedarán incompletos.

### Paso 5: Analizar daños

Compara el tamaño de cada archivo copiado vs el original:

```bash
for f in /mnt/dvd/VIDEO_TS/*; do
  name=$(basename "$f")
  orig=$(stat -c%s "$f")
  copy=$(stat -c%s "/mnt/ramdisk/<LABEL>/$name" 2>/dev/null || echo 0)
  if [ "$orig" != "$copy" ]; then
    echo "DAÑADO: $name (original: $orig, copia: $copy)"
  fi
done
```

Muestra la lista de archivos dañados/incompletos al usuario.

### Paso 6: Rescate con ddrescue

Lanza todos los archivos dañados **secuencialmente** dentro de un único `screen`, con un **timeout de 600 segundos (10 min) por archivo** para evitar quedarnos atascados en zonas irrecuperables:

```bash
screen -dmS ddrescue bash -c "
  sudo timeout 600 ddrescue -d -r 3 -b 2048 /mnt/dvd/VIDEO_TS/<ARCHIVO1> /mnt/ramdisk/<LABEL>/<ARCHIVO1> /mnt/ramdisk/<LABEL>/<ARCHIVO1>.log > /tmp/ddr1.log 2>&1;
  sudo timeout 600 ddrescue -d -r 3 -b 2048 /mnt/dvd/VIDEO_TS/<ARCHIVO2> /mnt/ramdisk/<LABEL>/<ARCHIVO2> /mnt/ramdisk/<LABEL>/<ARCHIVO2>.log > /tmp/ddr2.log 2>&1;
  ...
"
```

Usa `;` entre comandos (no `&&`) para que un timeout no aborte la cadena: cada archivo tiene sus 10 minutos garantizados.

Flags:
- `timeout 600` — máximo 10 minutos por archivo
- `-d` — acceso directo al dispositivo (bypass cache del kernel)
- `-r 3` — 3 reintentos por sector dañado
- `-b 2048` — tamaño de bloque DVD (2048 bytes)

Monitoriza usando el patrón de "Monitorización de procesos largos" (ScheduleWakeup cada 10 min). Cuando el screen desaparezca, todos los archivos han terminado.

Para ver el progreso de cada archivo:
```bash
for log in /tmp/ddr*.log; do
  echo "=== $(basename $log) ==="
  tail -c 400 $log | tr -d "\033" | grep -E "rescued|pct" | tail -1
done
```

### Paso 7: Calcular % final

```bash
orig_total=$(du -sb /mnt/dvd/VIDEO_TS/ | cut -f1)
copy_total=$(find "/mnt/ramdisk/<LABEL>/" -not -name "*.log" -type f -exec stat -c%s {} + | paste -sd+ | bc)
echo "Rescatado: $copy_total / $orig_total bytes"
echo "Porcentaje: $(echo "scale=1; $copy_total * 100 / $orig_total" | bc)%"
```

### Paso 8: Copiar al NAS por Samba

Ahora que el rescate está completo en RAM, copia los datos al share Samba. Hazlo **síncrono** (no screen, no ScheduleWakeup) — la copia de ~4-5 GB por red local tarda pocos minutos:

```bash
mkdir -p "/mnt/nas/<LABEL>/" && cp -v "/mnt/ramdisk/<LABEL>/"* "/mnt/nas/<LABEL>/"
```

Si estás en modo "fuera" (puente por el NAS), usa un timeout del lado cliente generoso (p. ej. `timeout: 600000` en la tool Bash) porque el comando bloquea hasta que termina.

Cuando termine, verifica que todos los archivos se copiaron correctamente comparando tamaños:

```bash
for f in "/mnt/ramdisk/<LABEL>/"*; do
  name=$(basename "$f")
  src=$(stat -c%s "$f")
  dst=$(stat -c%s "/mnt/nas/<LABEL>/$name" 2>/dev/null || echo 0)
  if [ "$src" != "$dst" ]; then
    echo "ERROR COPIA: $name (ramdisk: $src, nas: $dst)"
  fi
done
```

Si hay errores de copia, informa al usuario antes de continuar.

### Paso 9: Actualizar registro de DVDs

Lee el archivo `backlog/docs/doc-21 - Rescate-de-DVDs-familiares.md` del repositorio y actualiza la tabla:
- Si la etiqueta ya existe, actualiza el nombre real (label) y el % copiado
- Si no existe, añade una nueva fila

El formato es:

```
| Etiqueta | Nombre real | % copiado |
```

- **Etiqueta**: nombre escrito con rotulador en el DVD (recogido en el Paso 0)
- **Nombre real**: la LABEL del filesystem del DVD
- **% copiado**: porcentaje calculado en el paso 7 (redondeado, con ~)

### Paso 10: Limpiar y expulsar

Desmonta el ramdisk, el DVD y expulsa:

```bash
sudo umount /mnt/ramdisk
sudo umount /mnt/dvd
eject /dev/sr0
```

Confirma al usuario que puede retirar el DVD e insertar el siguiente.

## Notas

- Si el usuario quiere continuar con otro DVD, vuelve al Paso 0
- Los archivos `.log` de ddrescue se guardan junto a los VOBs para poder reanudar rescates en el futuro
- Siempre muestra resúmenes claros y concisos del estado tras cada paso
