from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import datetime as dt
import fcntl
import json
import os
import queue
import re
import shutil
import subprocess
import threading
import time
from pathlib import Path

CDROM_DRIVE_STATUS = 0x5326
CDS_NO_INFO = 0
CDS_NO_DISC = 1
CDS_TRAY_OPEN = 2
CDS_DRIVE_NOT_READY = 3
CDS_DISC_OK = 4

PORT = 7779
DEVICE = "/dev/sr0"
SUDO = "/run/wrappers/bin/sudo"
MOUNT_POINT = "/mnt/dvd-rescue"
DEST_ROOT = Path("/cold-data/downloads")
JSON_PATH = DEST_ROOT / "_dvds.json"
DDRESCUE_TIMEOUT_S = 600
SUCCESS_THRESHOLD = 50.0
MAX_BUFFER_LINES = 10000
BLKID_TIMEOUT_S = 3
DEVICE_STATE_CACHE_TTL_S = 2.0

state_lock = threading.Lock()
current_scan = None
subscribers = []
subscribers_lock = threading.Lock()

device_probe_lock = threading.Lock()
device_state_cache = {"value": None, "ts": 0.0}


def now_iso():
    return dt.datetime.now().replace(microsecond=0).isoformat()


def log(line):
    line = line.rstrip("\n")
    if not line:
        return
    stamped = f"[{dt.datetime.now().strftime('%H:%M:%S')}] {line}"
    with state_lock:
        if current_scan is None:
            return
        buf = current_scan["log_buffer"]
        buf.append(stamped)
        if len(buf) > MAX_BUFFER_LINES:
            del buf[: len(buf) - MAX_BUFFER_LINES]
    with subscribers_lock:
        dead = []
        for q in subscribers:
            try:
                q.put_nowait(stamped)
            except queue.Full:
                dead.append(q)
        for q in dead:
            subscribers.remove(q)


def stream_command(cmd, cwd=None):
    log(f"$ {' '.join(cmd)}")
    p = subprocess.Popen(
        cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, bufsize=0
    )
    pending = b""
    while True:
        chunk = p.stdout.read(256)
        if not chunk:
            break
        pending += chunk
        parts = re.split(rb"[\r\n]", pending)
        pending = parts[-1]
        for part in parts[:-1]:
            try:
                log(part.decode("utf-8", errors="replace"))
            except Exception:
                pass
    if pending:
        log(pending.decode("utf-8", errors="replace"))
    return p.wait()


def load_dvds():
    if not JSON_PATH.exists():
        return []
    try:
        return json.loads(JSON_PATH.read_text())
    except Exception:
        return []


def save_dvds(data):
    tmp = JSON_PATH.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(data, ensure_ascii=False, indent=2))
    os.replace(tmp, JSON_PATH)


def safe_label(s):
    s = s.strip()
    if not s:
        return None
    if "/" in s or ".." in s:
        return None
    return s


def pick_carpeta(etiqueta):
    base = etiqueta
    if not (DEST_ROOT / base).exists():
        return base, False
    n = 2
    while (DEST_ROOT / f"{base}{n}").exists():
        n += 1
    return f"{base}{n}", True


def cdrom_drive_status():
    """ioctl CDROM_DRIVE_STATUS — devuelve uno de los CDS_* o None si falla."""
    try:
        fd = os.open(DEVICE, os.O_RDONLY | os.O_NONBLOCK)
    except OSError:
        return None
    try:
        return fcntl.ioctl(fd, CDROM_DRIVE_STATUS)
    except OSError:
        return None
    finally:
        os.close(fd)


def probe_blkid():
    """Devuelve ('ready', label) | ('no_medium', None) | ('unknown', None).
    label puede ser '' si hay TYPE pero sin LABEL.
    Aplica timeout para no bloquear indefinidamente cuando el lector
    está enfermo (Python desbloquea el wait, aunque el subprocess pueda
    quedar en D-state hasta que el kernel libere el I/O)."""
    try:
        r = subprocess.run(
            [SUDO, "-n", "blkid", "-p", "-o", "export", DEVICE],
            capture_output=True,
            text=True,
            timeout=BLKID_TIMEOUT_S,
        )
    except subprocess.TimeoutExpired:
        return ("unknown", None)
    if r.returncode == 0 and "TYPE=" in r.stdout:
        for line in r.stdout.splitlines():
            if line.startswith("LABEL="):
                return ("ready", line.split("=", 1)[1])
        return ("ready", "")
    if "No medium" in r.stderr:
        return ("no_medium", None)
    return ("unknown", None)


def _device_state_uncached():
    s = cdrom_drive_status()
    if s == CDS_TRAY_OPEN:
        return {"kind": "tray_open"}
    if s == CDS_NO_DISC:
        return {"kind": "no_disc"}
    status, label = probe_blkid()
    if status == "ready":
        return {"kind": "ready", "label": label or None}
    if status == "no_medium":
        return {"kind": "no_disc"}
    return {"kind": "spinning_up"}


def device_state():
    """Single-flight + TTL cache sobre _device_state_uncached.

    Una sola sonda en vuelo a la vez; las peticiones concurrentes leen
    el resultado cacheado. Crítico cuando el lector se cuelga: evita
    que cada poll del frontend dispare un blkid nuevo y se acumulen
    procesos en D-state."""
    now = time.monotonic()
    with state_lock:
        cached = device_state_cache["value"]
        ts = device_state_cache["ts"]
        if cached is not None and (now - ts) < DEVICE_STATE_CACHE_TTL_S:
            return cached
    with device_probe_lock:
        now = time.monotonic()
        with state_lock:
            cached = device_state_cache["value"]
            ts = device_state_cache["ts"]
            if cached is not None and (now - ts) < DEVICE_STATE_CACHE_TTL_S:
                return cached
        result = _device_state_uncached()
        with state_lock:
            device_state_cache["value"] = result
            device_state_cache["ts"] = time.monotonic()
        return result


def mount_dvd():
    Path(MOUNT_POINT).mkdir(parents=True, exist_ok=True)
    subprocess.run([SUDO, "-n", "umount", MOUNT_POINT], capture_output=True)
    r = subprocess.run(
        [SUDO, "-n", "mount", "-o", "ro", DEVICE, MOUNT_POINT],
        capture_output=True,
        text=True,
    )
    if r.returncode != 0:
        raise RuntimeError(f"mount falló: {r.stderr.strip()}")


def umount_dvd():
    subprocess.run([SUDO, "-n", "umount", MOUNT_POINT], capture_output=True)


def eject_dvd():
    subprocess.run([SUDO, "-n", "eject", DEVICE], capture_output=True)


def dir_size_bytes(p):
    total = 0
    for f in p.iterdir():
        if f.is_file() and not f.name.endswith(".log"):
            total += f.stat().st_size
    return total


def run_scan(etiqueta, carpeta, nombre_real_at_start):
    global current_scan
    try:
        log(f"=== Iniciando escaneo de '{etiqueta}' ===")
        log(f"Carpeta destino: {carpeta}")
        dest = DEST_ROOT / carpeta
        dest.mkdir(parents=True, exist_ok=True)

        log("Montando DVD...")
        mount_dvd()

        videots = Path(MOUNT_POINT) / "VIDEO_TS"
        if not videots.exists():
            raise RuntimeError("El DVD no tiene VIDEO_TS")
        archivos = sorted([p for p in videots.iterdir() if p.is_file()])
        log(f"Archivos en VIDEO_TS: {len(archivos)}")

        bytes_origen_total = sum(p.stat().st_size for p in archivos)
        log(f"Tamaño total origen: {bytes_origen_total // (1024*1024)} MB")

        log("--- Paso 1/3: copia inicial con cp ---")
        for src in archivos:
            stream_command(["cp", "-v", str(src), str(dest / src.name)])

        log("--- Paso 2/3: análisis de daños ---")
        danados = []
        for src in archivos:
            dst = dest / src.name
            sz_src = src.stat().st_size
            sz_dst = dst.stat().st_size if dst.exists() else 0
            if sz_src != sz_dst:
                log(f"DAÑADO: {src.name} (origen: {sz_src}, copia: {sz_dst})")
                danados.append(src)
        log(f"Archivos dañados: {len(danados)}")

        if danados:
            log("--- Paso 3/3: rescate con ddrescue ---")
            for src in danados:
                dst = dest / src.name
                logf = dest / f"{src.name}.log"
                stream_command(
                    [
                        SUDO,
                        "-n",
                        "timeout",
                        str(DDRESCUE_TIMEOUT_S),
                        "ddrescue",
                        "-d",
                        "-r",
                        "3",
                        "-b",
                        "2048",
                        str(src),
                        str(dst),
                        str(logf),
                    ]
                )

        bytes_rescatados = dir_size_bytes(dest)
        pct = (
            (bytes_rescatados * 100.0 / bytes_origen_total)
            if bytes_origen_total
            else 0.0
        )
        log(f"Rescatado: {bytes_rescatados} / {bytes_origen_total} bytes ({pct:.1f}%)")

        estado = "ok" if pct >= SUCCESS_THRESHOLD else "fallo"

        entry = {
            "etiqueta": etiqueta,
            "nombre_real": nombre_real_at_start,
            "carpeta": carpeta,
            "porcentaje": round(pct, 1),
            "estado": estado,
            "fecha": now_iso(),
            "bytes_origen": bytes_origen_total,
            "bytes_rescatados": bytes_rescatados,
        }
        data = load_dvds()
        data.append(entry)
        save_dvds(data)
        log(f"Entrada añadida al índice. Estado: {estado.upper()}")

        log("--- Limpieza: umount + eject ---")
        umount_dvd()
        eject_dvd()

        with state_lock:
            current_scan["status"] = estado
            current_scan["porcentaje"] = round(pct, 1)
        log(f"=== Escaneo terminado: {estado.upper()} ({pct:.1f}%) ===")
    except Exception as e:
        log(f"ERROR: {e}")
        try:
            umount_dvd()
        except Exception:
            pass
        with state_lock:
            current_scan["status"] = "fallo"
            current_scan["porcentaje"] = 0.0


HTML_INDEX = r"""<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Digitalizar DVDs</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:system-ui,sans-serif;background:#111;color:#eee;min-height:100vh;padding:20px}
.wrap{max-width:900px;margin:0 auto}
h1{font-size:1.8rem;margin-bottom:1rem}
.row{display:flex;gap:10px;margin-bottom:1rem;flex-wrap:wrap}
input[type=text]{flex:1;min-width:200px;font-size:1.3rem;padding:14px;border-radius:8px;border:1px solid #333;background:#1a1a1a;color:#eee}
button{font-size:1.2rem;padding:14px 24px;border:none;border-radius:8px;background:#2563eb;color:white;cursor:pointer}
button:hover{background:#1d4ed8}
button.secondary{background:#333}
button.secondary:hover{background:#444}
button:disabled{opacity:.5;cursor:not-allowed}
#banner{padding:22px;border-radius:8px;margin-bottom:1rem;font-size:1.3rem;font-weight:bold;text-align:center;display:none}
#banner.ok{display:block;background:#16a34a}
#banner.fallo{display:block;background:#dc2626}
#banner.running{display:block;background:#f59e0b;color:#000}
#banner.pending{display:block;background:#374151;color:#fff}
#banner.info{display:block;background:#1f2937;color:#e5e7eb;border:1px solid #374151}
#banner.prep{display:block;background:#f59e0b;color:#000}
#banner.ready{display:block;background:#0891b2;color:white}
#banner small{display:block;font-size:.95rem;font-weight:normal;margin-top:8px;opacity:.85}
@keyframes pulse{0%,100%{opacity:1}50%{opacity:.55}}
#banner.pending,#banner.running,#banner.prep{animation:pulse 1.5s ease-in-out infinite}
#logs{background:#000;border:1px solid #333;border-radius:8px;padding:12px;font-family:ui-monospace,monospace;font-size:.85rem;height:60vh;overflow-y:auto;white-space:pre-wrap;word-break:break-all;display:none}
#logs.show{display:block}
.modal-bg{position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,.7);display:none;align-items:center;justify-content:center;z-index:10}
.modal-bg.show{display:flex}
.modal{background:#1a1a1a;border:1px solid #333;border-radius:12px;padding:24px;max-width:500px;width:90%}
.modal h2{margin-bottom:1rem}
.modal p{margin-bottom:1rem;line-height:1.5}
.modal .row{margin-top:1rem;margin-bottom:0;justify-content:flex-end}
a.link{color:#60a5fa;text-decoration:none}
</style></head><body>
<div class="wrap">
  <h1>Digitalizar DVD</h1>
  <p style="margin-bottom:1rem"><a class="link" href="/list">📀 Ver películas escaneadas</a></p>
  <div id="banner"></div>
  <div id="form" class="row">
    <input type="text" id="etiqueta" placeholder="Nombre de la película" autocomplete="off">
    <button id="btn">DIGITALIZAR</button>
  </div>
  <div id="actions" class="row" style="display:none">
    <button id="reset" class="secondary">Nuevo escaneo</button>
  </div>
  <pre id="logs"></pre>
</div>
<div class="modal-bg" id="modal">
  <div class="modal">
    <h2>Ya existe</h2>
    <p id="modal-text"></p>
    <div class="row">
      <button class="secondary" onclick="closeModal()">Cancelar</button>
      <button onclick="confirmModal()">OK, escanear</button>
    </div>
  </div>
</div>
<script>
const initial = __INITIAL__;
const banner = document.getElementById('banner');
const logs = document.getElementById('logs');
const form = document.getElementById('form');
const actions = document.getElementById('actions');
const btn = document.getElementById('btn');
const inp = document.getElementById('etiqueta');
const modal = document.getElementById('modal');
const modalText = document.getElementById('modal-text');
let pendingCarpeta = null;

let pollTimer = null;
let lastDeviceKind = null;

function setBanner(cls, html){banner.className=cls;banner.innerHTML=html;}
function hideForm(){form.style.display='none';}
function showForm(){form.style.display='flex';btn.disabled=false;}
function hideActions(){actions.style.display='none';}
function showActions(){actions.style.display='flex';}
function hideLogs(){logs.className='';logs.textContent='';}
function showLogs(){logs.className='show';}

function showRunning(etiqueta){
  setBanner('running','Escaneando: '+etiqueta+'...');
  hideForm();hideActions();showLogs();
  if(!logs.textContent) logs.textContent='';
}
function showResult(status, etiqueta, pct){
  if(status==='ok') setBanner('ok','✅ '+etiqueta+' escaneado correctamente ('+pct+'%)');
  else setBanner('fallo','❌ '+etiqueta+' falló ('+pct+'%)');
  hideForm();showActions();showLogs();
}
function showError(text){
  setBanner('fallo','❌ '+text);
  hideActions();hideLogs();
  // Volvemos a pollear el estado del lector tras 2s
  setTimeout(()=>{ if(!pollTimer) startPolling(); }, 2000);
}
function renderDeviceState(s){
  if(s.kind === lastDeviceKind) return;
  lastDeviceKind = s.kind;
  if(s.kind === 'tray_open'){
    setBanner('info','🔓 Bandeja abierta<small>Cierra el lector con el DVD dentro.</small>');
    hideForm();hideActions();hideLogs();
  } else if(s.kind === 'no_disc'){
    setBanner('info','💿 Inserta un DVD en el lector<small>La pantalla cambiará automáticamente cuando el lector lo detecte.</small>');
    hideForm();hideActions();hideLogs();
  } else if(s.kind === 'spinning_up'){
    setBanner('prep','⏳ Preparando DVD...<small>El lector está leyendo el disco. Espera unos segundos.</small>');
    hideForm();hideActions();hideLogs();
  } else if(s.kind === 'ready'){
    const lab = s.label ? ' — <span style="opacity:.85">'+s.label+'</span>' : '';
    setBanner('ready','✅ DVD listo'+lab+'<small>Escribe el nombre de la película y pulsa DIGITALIZAR.</small>');
    showForm();hideActions();hideLogs();
    if(s.label && !inp.value) inp.value = s.label;
    inp.focus();
  } else if(s.kind === 'scanning'){
    // Lo gestionará el SSE / restauración inicial; nada que hacer aquí.
  }
}
async function pollState(){
  try{
    const r = await fetch('/state');
    if(!r.ok) return;
    renderDeviceState(await r.json());
  }catch(e){}
}
function startPolling(){
  if(pollTimer) return;
  lastDeviceKind = null;
  pollState();
  pollTimer = setInterval(pollState, 4000);
}
function stopPolling(){
  if(pollTimer){clearInterval(pollTimer);pollTimer=null;}
}
function subscribeSSE(){
  const es = new EventSource('/events');
  es.onmessage = (e)=>{logs.textContent += e.data + '\n'; logs.scrollTop = logs.scrollHeight;};
  es.addEventListener('done', (e)=>{
    const d = JSON.parse(e.data);
    showResult(d.status, d.etiqueta, d.porcentaje);
    es.close();
  });
  es.onerror = ()=>{};
}
btn.onclick = async ()=>{
  const etiqueta = inp.value.trim();
  if(!etiqueta){return;}
  btn.disabled = true;
  stopPolling();
  setBanner('pending','⏳ Comprobando...');
  hideForm();
  try{
    const r = await fetch('/preflight',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({etiqueta})});
    const j = await r.json();
    if(!j.ok){showError(j.error);return;}
    if(j.collision){
      pendingCarpeta = j.carpeta_final;
      modalText.textContent = 'Ya existe una carpeta "'+etiqueta+'". Se guardará como "'+j.carpeta_final+'". ¿Continuar?';
      modal.classList.add('show');
      return;
    }
    startScan(etiqueta, j.carpeta_final);
  }catch(e){showError(e.message);}
};
function closeModal(){modal.classList.remove('show');pendingCarpeta=null;startPolling();}
function confirmModal(){
  const etiqueta = inp.value.trim();
  const carpeta = pendingCarpeta;
  modal.classList.remove('show');pendingCarpeta=null;
  startScan(etiqueta, carpeta);
}
async function startScan(etiqueta, carpeta){
  setBanner('pending','⏳ Iniciando escaneo de '+etiqueta+'...');
  hideForm();
  const r = await fetch('/scan',{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({etiqueta,carpeta_final:carpeta})});
  if(r.status===409){showError('Ya hay un escaneo en curso');return;}
  if(!r.ok){showError('Error iniciando escaneo');return;}
  showRunning(etiqueta);
  subscribeSSE();
}
document.getElementById('reset').onclick = async ()=>{
  await fetch('/reset',{method:'POST'});
  inp.value='';
  hideForm();hideActions();hideLogs();
  setBanner('','');banner.style.display='none';
  startPolling();
};
// Restauración inicial
if(initial.status==='running'){
  showRunning(initial.etiqueta);
  logs.textContent = initial.log_buffer.join('\n') + '\n';
  subscribeSSE();
}else if(initial.status==='ok' || initial.status==='fallo'){
  showResult(initial.status, initial.etiqueta, initial.porcentaje);
  logs.textContent = initial.log_buffer.join('\n') + '\n';
}else{
  hideForm();
  startPolling();
}
</script></body></html>
"""

HTML_LIST = r"""<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Películas escaneadas</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:system-ui,sans-serif;background:#111;color:#eee;min-height:100vh;padding:20px}
.wrap{max-width:1100px;margin:0 auto}
h1{font-size:1.8rem;margin-bottom:1rem}
a.link{color:#60a5fa;text-decoration:none;display:inline-block;margin-bottom:1rem}
table{width:100%;border-collapse:collapse;background:#1a1a1a;border-radius:8px;overflow:hidden}
th,td{padding:10px 12px;text-align:left;border-bottom:1px solid #2a2a2a;font-size:.95rem}
th{background:#222;font-weight:600;position:sticky;top:0}
tr:last-child td{border-bottom:none}
.pill{display:inline-block;padding:3px 10px;border-radius:999px;font-size:.8rem;font-weight:bold}
.pill.ok{background:#16a34a;color:white}
.pill.fallo{background:#dc2626;color:white}
.muted{color:#888}
.count{margin-bottom:1rem;color:#aaa}
</style></head><body>
<div class="wrap">
  <a class="link" href="/">← Volver</a>
  <h1>Películas escaneadas</h1>
  <p class="count">__COUNT__ entradas · __OK__ ok · __FALLO__ con fallo</p>
  <table>
    <thead><tr><th>Etiqueta</th><th>Nombre real</th><th>Carpeta</th><th>%</th><th>Estado</th><th>Fecha</th></tr></thead>
    <tbody>__ROWS__</tbody>
  </table>
</div></body></html>
"""


def render_list_html():
    data = load_dvds()
    data_sorted = sorted(
        data, key=lambda e: e.get("fecha") or "", reverse=True
    )
    rows = []
    ok_count = 0
    fallo_count = 0
    for e in data_sorted:
        estado = e.get("estado", "fallo")
        if estado == "ok":
            ok_count += 1
        else:
            fallo_count += 1
        nombre = e.get("nombre_real") or "—"
        fecha = e.get("fecha") or "—"
        if fecha != "—":
            fecha = fecha.replace("T", " ")
        pct = e.get("porcentaje", 0)
        rows.append(
            f"<tr><td>{escape(e.get('etiqueta', ''))}</td>"
            f"<td class='muted'>{escape(str(nombre))}</td>"
            f"<td class='muted'>{escape(e.get('carpeta', ''))}</td>"
            f"<td>{pct}%</td>"
            f"<td><span class='pill {estado}'>{estado}</span></td>"
            f"<td class='muted'>{escape(str(fecha))}</td></tr>"
        )
    return (
        HTML_LIST.replace("__ROWS__", "".join(rows))
        .replace("__COUNT__", str(len(data_sorted)))
        .replace("__OK__", str(ok_count))
        .replace("__FALLO__", str(fallo_count))
    )


def escape(s):
    return (
        str(s)
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
    )


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def _send_json(self, code, obj):
        body = json.dumps(obj, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _send_html(self, body):
        b = body.encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(b)))
        self.end_headers()
        self.wfile.write(b)

    def _read_json(self):
        n = int(self.headers.get("Content-Length", "0"))
        if not n:
            return {}
        return json.loads(self.rfile.read(n).decode("utf-8"))

    def do_GET(self):
        if self.path == "/" or self.path.startswith("/?"):
            with state_lock:
                if current_scan is None:
                    initial = {"status": "idle"}
                else:
                    initial = {
                        "status": current_scan["status"],
                        "etiqueta": current_scan["etiqueta"],
                        "porcentaje": current_scan.get("porcentaje", 0),
                        "log_buffer": list(current_scan["log_buffer"]),
                    }
            html = HTML_INDEX.replace(
                "__INITIAL__", json.dumps(initial, ensure_ascii=False)
            )
            self._send_html(html)
            return
        if self.path == "/list":
            self._send_html(render_list_html())
            return
        if self.path == "/api/dvds":
            self._send_json(200, load_dvds())
            return
        if self.path == "/events":
            self._serve_sse()
            return
        if self.path == "/state":
            with state_lock:
                scanning = current_scan is not None and current_scan.get("status") == "running"
            if scanning:
                self._send_json(200, {"kind": "scanning"})
            else:
                self._send_json(200, device_state())
            return
        self.send_response(404)
        self.end_headers()

    def do_POST(self):
        if self.path == "/preflight":
            self._handle_preflight()
            return
        if self.path == "/scan":
            self._handle_scan()
            return
        if self.path == "/reset":
            self._handle_reset()
            return
        self.send_response(404)
        self.end_headers()

    def _handle_preflight(self):
        try:
            body = self._read_json()
        except Exception:
            self._send_json(400, {"ok": False, "error": "JSON inválido"})
            return
        etiqueta = safe_label(body.get("etiqueta", ""))
        if not etiqueta:
            self._send_json(200, {"ok": False, "error": "Etiqueta inválida"})
            return
        ds = device_state()
        if ds["kind"] != "ready":
            self._send_json(200, {"ok": False, "error": "El DVD no está listo"})
            return
        carpeta_final, collision = pick_carpeta(etiqueta)
        self._send_json(
            200,
            {
                "ok": True,
                "collision": collision,
                "carpeta_final": carpeta_final,
                "nombre_real": ds.get("label"),
            },
        )

    def _handle_scan(self):
        global current_scan
        try:
            body = self._read_json()
        except Exception:
            self._send_json(400, {"error": "JSON inválido"})
            return
        etiqueta = safe_label(body.get("etiqueta", ""))
        carpeta = safe_label(body.get("carpeta_final", ""))
        if not etiqueta or not carpeta:
            self._send_json(400, {"error": "etiqueta o carpeta inválidas"})
            return
        with state_lock:
            if current_scan is not None and current_scan["status"] == "running":
                self._send_json(409, {"error": "Ya hay un escaneo en curso"})
                return
            ds = device_state()
            if ds["kind"] != "ready":
                self._send_json(400, {"error": "El DVD no está listo"})
                return
            label = ds.get("label")
            current_scan = {
                "etiqueta": etiqueta,
                "carpeta": carpeta,
                "status": "running",
                "log_buffer": [],
                "porcentaje": 0,
                "started_at": now_iso(),
            }
        threading.Thread(
            target=run_scan, args=(etiqueta, carpeta, label), daemon=True
        ).start()
        self._send_json(202, {"ok": True})

    def _handle_reset(self):
        global current_scan
        with state_lock:
            if current_scan and current_scan["status"] == "running":
                self._send_json(409, {"error": "Escaneo en curso"})
                return
            current_scan = None
        self._send_json(200, {"ok": True})

    def _serve_sse(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("X-Accel-Buffering", "no")
        self.end_headers()
        q = queue.Queue(maxsize=10000)
        with subscribers_lock:
            subscribers.append(q)
        try:
            while True:
                with state_lock:
                    status = current_scan["status"] if current_scan else "idle"
                    etiqueta = current_scan["etiqueta"] if current_scan else ""
                    pct = current_scan.get("porcentaje", 0) if current_scan else 0
                if status in ("ok", "fallo"):
                    payload = json.dumps(
                        {"status": status, "etiqueta": etiqueta, "porcentaje": pct}
                    )
                    self.wfile.write(
                        f"event: done\ndata: {payload}\n\n".encode()
                    )
                    self.wfile.flush()
                    return
                try:
                    line = q.get(timeout=15)
                    self.wfile.write(f"data: {line}\n\n".encode())
                    self.wfile.flush()
                except queue.Empty:
                    self.wfile.write(b": keepalive\n\n")
                    self.wfile.flush()
        except (BrokenPipeError, ConnectionResetError):
            pass
        finally:
            with subscribers_lock:
                if q in subscribers:
                    subscribers.remove(q)


def main():
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print(f"DVD server escuchando en :{PORT}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
