#!/usr/bin/env bash
set -u

PROC="${1:-Cyberpunk2077.exe}"
PID=$(pgrep -f "$PROC" | head -1)
if [ -z "$PID" ]; then
  echo "proceso no encontrado: $PROC"
  exit 1
fi

TS=$(date +%Y%m%d-%H%M%S)
OUT="/home/dani/freeze-captures/${TS}-${PID}"
mkdir -p "$OUT"
echo "capturando PID $PID ($PROC) -> $OUT"

echo "[1/8] eu-stack (backtrace rápido de todos los hilos)..."
eu-stack -p "$PID" >"$OUT/eu-stack.txt" 2>&1 || echo "eu-stack falló (¿sudo?)" >>"$OUT/eu-stack.txt"

echo "[2/8] gdb thread apply all bt full..."
gdb -p "$PID" -batch \
  -ex "set pagination off" \
  -ex "set sysroot /proc/$PID/root" \
  -ex "info threads" \
  -ex "thread apply all bt full" \
  >"$OUT/gdb-bt.txt" 2>&1 || echo "gdb falló (¿sudo?)" >>"$OUT/gdb-bt.txt"

echo "[3/8] estado de hilos (state/comm/wchan)..."
for t in /proc/"$PID"/task/*; do
  tid=$(basename "$t")
  echo "tid=$tid state=$(awk '{print $3}' "$t/stat" 2>/dev/null) comm=$(cat "$t/comm" 2>/dev/null) wchan=$(cat "$t/wchan" 2>/dev/null)"
done >"$OUT/threads.txt"

echo "[4/8] syscall en curso + kernel stack de cada hilo (estado ntsync/wait)..."
{
  for t in /proc/"$PID"/task/*; do
    tid=$(basename "$t")
    echo "=== tid $tid ($(cat "$t/comm" 2>/dev/null)) state=$(awk '{print $3}' "$t/stat" 2>/dev/null) wchan=$(cat "$t/wchan" 2>/dev/null) ==="
    echo "syscall: $(cat "$t/syscall" 2>/dev/null)"
    echo "kernel-stack:"
    cat "$t/stack" 2>/dev/null
    echo
  done
} >"$OUT/kernel-state.txt" 2>&1

echo "[5/8] fds del proceso -> objetos ntsync/eventfd..."
ls -l /proc/"$PID"/fd 2>/dev/null >"$OUT/fds.txt"
ls -l /proc/"$PID"/fd 2>/dev/null | grep -iE "ntsync|anon_inode|eventfd" >"$OUT/ntsync-fds.txt" 2>&1

echo "[6/8] maps de librerías..."
cat "/proc/$PID/maps" >"$OUT/maps.txt" 2>/dev/null

echo "[7/8] estado GPU (busy/temp/power/clocks)..."
{
  for c in /sys/class/drm/card*/device; do
    [ -f "$c/gpu_busy_percent" ] && echo "busy: $(cat "$c/gpu_busy_percent")%"
  done
  for h in /sys/class/drm/card*/device/hwmon/hwmon*; do
    [ -f "$h/temp1_input" ] && echo "temp: $(($(cat "$h/temp1_input") / 1000))C"
    [ -f "$h/power1_average" ] && echo "power: $(($(cat "$h/power1_average") / 1000000))W"
  done
  echo "--- sclk ---"
  cat /sys/class/drm/card*/device/pp_dpm_sclk 2>/dev/null | grep '\*'
} >"$OUT/gpu.txt" 2>&1

echo "[8/8] dmesg..."
dmesg 2>/dev/null | tail -80 >"$OUT/dmesg.txt"

chown -R dani:users /home/dani/freeze-captures 2>/dev/null || true
echo "listo -> $OUT"
ls -la "$OUT"
