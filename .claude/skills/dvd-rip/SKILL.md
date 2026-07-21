---
name: dvd-rip
description: Ripear a MKV H.265 los DVDs de "Recuperados 100" del NAS, uno a uno, con revisión del usuario. Úsala cuando el usuario quiera convertir/ripear DVDs (VIDEO_TS) a MKV, continuar la tanda de ripeo, o retomar donde se dejó. Invocable desde cualquier ordenador (las deps viven en el NAS).
---

# /dvd-rip

Convierte los DVDs originales del NAS (`VIDEO_TS` con VOBs) a **MKV H.265**, **uno por uno**, con revisión del usuario antes de dar cada uno por bueno. **Tú orquestas** (decides qué DVD y cuándo); el encode y el tracking viven **en el NAS**, así que la skill funciona desde cualquier ordenador con acceso `ssh nas`.

## Dependencias — TODO en el NAS: `/home/dani/dvd-rip/`

| Fichero | Qué es | Dónde corre |
|---|---|---|
| `dvd_rip.sh "<carpeta>"` | Ripea UN DVD con HandBrake. Autodetecta entrelazado. | en el NAS (`ssh nas`) |
| `dvd_rip_ffmpeg.sh "<carpeta>"` | **Fallback** vía ffmpeg cuando HandBrake entra en bucle con un disco. | en el NAS |
| `dvd_rip_update_csv.py <csv> "<carpeta>"` | Marca la fila del CSV: `ya lo tengo` + `ripeado=true`. | en el NAS |
| `dvd_mapping.tsv` | `carpeta⇥tipo(movie\|series)⇥disco⇥nombre` de cada DVD. | en el NAS |
| `dvds_tmdb.csv` | **CSV de tracking canónico** (el usuario también lo edita a mano aquí). | en el NAS |
| `dvd_fetch.sh "<carpeta>" "<mkv>"` | Copia el MKV del NAS a `~/Downloads` del cliente (rate-limited). | en el **cliente** |

Las fuentes de estos scripts están versionadas en el repo (`scripts/`, `dvds_tmdb.csv`). **Para (re)desplegar** o si montas en un NAS nuevo:
```bash
ssh nas 'mkdir -p /home/dani/dvd-rip'
scp scripts/dvd_rip.sh scripts/dvd_rip_ffmpeg.sh scripts/dvd_fetch.sh \
    scripts/dvd_rip_update_csv.py scripts/dvd_mapping.tsv dvds_tmdb.csv \
    nas:/home/dani/dvd-rip/
ssh nas 'chmod +x /home/dani/dvd-rip/*.sh /home/dani/dvd-rip/*.py'
```

## Contexto fijo (rutas en el NAS)

- **Fuente**: `/cold-data/downloads/DVDs/Recuperados 100/<carpeta>/` (cada carpeta es un DVD con `VIDEO_TS`).
- **Staging**: `.../Recuperados 100/__RIPEADOS__/` (salida temporal + `_status/<carpeta>.done|.fail|.log`).
- **Destino pelis**: `/cold-data/media/torrents/__RIPEADO__` (carpeta de importar).
- **Destino series/extras**: `/cold-data/sftpgo/data/dani/Multimedia/Series/<Serie>/`.
- **Herramienta**: HandBrake vía `nix` (sin instalar nada); el script gc-rootea en `/home/dani/dvd-rip/hb-handbrake`.
- **CSV**: se ripea lo que tiene `descargar=no encontrado`; al terminar → `descargar=ya lo tengo` + `ripeado=true`. El usuario puede haber marcado cosas como `ya lo tengo` desde otra fuente — **respétalo**.

## Ajustes de encode (ya en los scripts)

- **Vídeo**: x265, **RF 22**, preset `medium`. **Audio**: todas las pistas (copy AC3). **Subtítulos**: todos (VobSub passthrough).
- **Desentrelazado — autodetección con `idet`** (clave, aprendido a base de errores):
  - **Entrelazado real** = una paridad DOMINA (`maj ≥ 20%` del total) y la otra es minoritaria (`min ≤ maj/4`, p. ej. `TFF=141 BFF=0`) → bob 50p.
  - **Progresivo** (paridad mezclada tipo `TFF=26 BFF=71`, o casi todo `PROG`) → **sin desentrelazar**.
  - **NUNCA desentrelaces cine progresivo**: introduce combing (las rayas finas de la ropa disparan un falso positivo). Verifica con `idet`, no con `comb-detect`. Ver `[[dvd-recuperados-progressive-no-deinterlace]]`.

## Receta paso a paso (por DVD)

### 1. Elegir el siguiente DVD
Lee el CSV canónico del NAS y coge la siguiente fila con `descargar=no encontrado` que tenga carpeta (según `dvd_mapping.tsv`):
```bash
ssh nas 'cat /home/dani/dvd-rip/dvds_tmdb.csv'
```

### 2. ¿Ya está ripeado?
```bash
ssh nas 'ls "/cold-data/downloads/DVDs/Recuperados 100/<carpeta>"/*.mkv 2>/dev/null'
```
Si ya hay un MKV H.265 válido (`ffprobe`), **no re-encodees**: muévelo a `__RIPEADO__` y marca el CSV.

### 3. Lanzar el encode en tmux (en el NAS)
```bash
ssh nas 'tmux kill-session -t ripdvd 2>/dev/null; tmux new-session -d -s ripdvd "bash /home/dani/dvd-rip/dvd_rip.sh \"<carpeta>\""'
```
A los ~12 s comprueba la decisión de desentrelazado:
```bash
ssh nas 'grep -E "idet|ENTRELAZADO|PROGRESIVO" ".../__RIPEADOS__/_status/<carpeta>.log"'
```
- Si una **peli** sale ENTRELAZADO con paridad mezclada (falso positivo) → párala; algo falla en la heurística.
- Si una **serie/TV** sale PROGRESIVO pero se ve con combing → es entrelazada de verdad.
- Si el log se llena de `not a PS packet` y el runtime se dispara (horas, archivo gigante) → **HandBrake está en bucle con el IFO**. Mátalo y usa el fallback:
  ```bash
  ssh nas 'tmux new-session -d -s ripdvd "bash /home/dani/dvd-rip/dvd_rip_ffmpeg.sh \"<carpeta>\""'
  ```

### 4. Copiar a Downloads (en el cliente)
```bash
scp nas:/home/dani/dvd-rip/dvd_fetch.sh /tmp/ && bash /tmp/dvd_fetch.sh "<carpeta>" "<nombre>.mkv"
```
(en background). Espera el `.done`, copia a `~/Downloads` a 3 MB/s, reintenta y verifica tamaño. Avisa por el chat al completar.

### 5. El usuario revisa y confirma
Espera su OK explícito. **No te autoapruebes.**

### 6. Colocar y marcar (en el NAS)
```bash
ssh nas 'python3 /home/dani/dvd-rip/dvd_rip_update_csv.py /home/dani/dvd-rip/dvds_tmdb.csv "<carpeta>"'
ssh nas 'mv -f ".../__RIPEADOS__/<nombre>.mkv" /cold-data/media/torrents/__RIPEADO__/'
```

### 7. Siguiente
Vuelve al paso 1. **Un encode a la vez** (comparten CPU; en serie es lo óptimo en el N355).

## Series (ojo)

- El script saca **1 MKV por título** (`<Serie> - 1x01.mkv`...). Los títulos de DVD **no** mapean 1:1 con episodios: puede haber "reproducir todo", extras, o un título = un episodio de ~24 min con cortes de acto internos (**no cortes por negro**: los fundidos son pausas de acto, no fin de episodio).
- **Identifica cada título** por su carátula/título en pantalla (pregunta al usuario o busca en la wiki de la serie) y **renómbralo** `<Serie> - S01Exx - <Título>.mkv`.
- Los **extras/bonus** (no episodios) van a la carpeta de sftpgo de la serie, no a `__RIPEADO__`.
- Numera episodios de forma continua si la serie ocupa varios discos.

## Reglas de oro (aprendidas a golpes)

- **NUNCA copies del NAS a full velocidad**: satura el uplink de casa y **tira el SSH** a media transferencia. Siempre `scp -l 24000` (~3 MB/s, ya en `dvd_fetch.sh`). `openrsync` de macOS no soporta bien `--bwlimit`. Ver `[[nas-scp-saturates-uplink-ssh-drops]]`.
- **Si el SSH se cae**, el NAS suele seguir vivo: compruébalo por métricas en Grafana/VictoriaMetrics (datasource uid `P4169E866C3094E38`, `node_load1`, `time()-node_time_seconds`), NO por si cargan las webs (van por otra ruta). Los encodes en `tmux` sobreviven.
- **Todo en `tmux` en el NAS** para sobrevivir a los cortes.
- Si `dvd_rip_update_csv.py` no marca una carpeta, es que falta en su mapeo `FOLDER_TO_LINE` (carpeta→nº de línea del CSV); añádela. Si el usuario reordena/inserta filas en el CSV, ese mapeo por línea se desalinea.
- HandBrake comparte stdin con el bucle → las llamadas a `$HB` llevan `</dev/null` (ya en el script).
