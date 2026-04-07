---
name: rescue-dvd
description: Rescatar datos de DVDs rayados desde un portátil con LiveCD de Lubuntu conectado a la red local del NAS. Detecta, copia, rescata sectores dañados con ddrescue y registra progreso en DVDS.md.
---

Eres un operador de rescate de DVDs. El usuario tiene un portátil con lector de CDs corriendo un LiveCD de Lubuntu, conectado a la red local del NAS. Todas las operaciones se ejecutan por SSH en ese portátil.

## Pre-checks

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

### Paso 0: Identificar DVD

Pregunta al usuario:
1. Que inserte el DVD en el lector
2. Qué nombre tiene escrito con rotulador en la cara del disco (esta será la **Etiqueta** en DVDS.md)

Guarda esa etiqueta para usarla en el Paso 7.

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

Monitoriza el progreso comprobando si la sesión screen sigue activa y leyendo el log:

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

Para cada archivo dañado (normalmente VOBs), ejecuta ddrescue dentro de `screen` para que sobreviva a caídas de SSH:

```bash
screen -dmS ddrescue sudo ddrescue -d -r 3 -b 2048 "/mnt/dvd/VIDEO_TS/<ARCHIVO>" "/mnt/ramdisk/<LABEL>/<ARCHIVO>" "/mnt/ramdisk/<LABEL>/<ARCHIVO>.log"
```

Flags:
- `-d` — acceso directo al dispositivo (bypass cache del kernel)
- `-r 3` — 3 reintentos por sector dañado
- `-b 2048` — tamaño de bloque DVD (2048 bytes)

Monitoriza el progreso comprobando si el proceso sigue activo y el tamaño del archivo destino:

```bash
screen -ls | grep ddrescue
stat -c%s "/mnt/ramdisk/<LABEL>/<ARCHIVO>"
head -7 "/mnt/ramdisk/<LABEL>/<ARCHIVO>.log"
```

Cuando la sesión screen desaparezca de `screen -ls`, ddrescue ha terminado. Si ddrescue se estanca (sin progreso en varios minutos), informa al usuario y pregunta si quiere continuar o cortar.

### Paso 7: Calcular % final

```bash
orig_total=$(du -sb /mnt/dvd/VIDEO_TS/ | cut -f1)
copy_total=$(find "/mnt/ramdisk/<LABEL>/" -not -name "*.log" -type f -exec stat -c%s {} + | paste -sd+ | bc)
echo "Rescatado: $copy_total / $orig_total bytes"
echo "Porcentaje: $(echo "scale=1; $copy_total * 100 / $orig_total" | bc)%"
```

### Paso 8: Copiar al NAS por Samba

Ahora que el rescate está completo en RAM, copia los datos al share Samba dentro de `screen`:

```bash
mkdir -p "/mnt/nas/<LABEL>/"
screen -dmS cp-nas bash -c 'cp -v "/mnt/ramdisk/<LABEL>/"* "/mnt/nas/<LABEL>/" > /tmp/cp-nas.log 2>&1'
```

Monitoriza comprobando si la sesión screen sigue activa:

```bash
screen -ls | grep cp-nas
cat /tmp/cp-nas.log
```

Cuando la sesión screen desaparezca, la copia ha terminado. Verifica que todos los archivos se copiaron correctamente comparando tamaños:

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

### Paso 9: Actualizar DVDS.md

Lee el archivo `DVDS.md` del repositorio y actualiza la tabla:
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
