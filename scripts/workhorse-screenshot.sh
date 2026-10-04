#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-workhorse}"
DEST_DIR="${HOME}/Downloads"
TS="$(date +%Y%m%d-%H%M%S)"
REMOTE_PATH="/tmp/workhorse-shot-${TS}.png"
LOCAL_PATH="${DEST_DIR}/workhorse-${TS}.png"

echo "Capturando en ${HOST}..."
ssh "$HOST" "WAYLAND_DISPLAY=gamescope-0 XDG_RUNTIME_DIR=/run/user/\$(id -u) gamescopectl screenshot '${REMOTE_PATH}'"

echo "Descargando a ${LOCAL_PATH}..."
scp -q "${HOST}:${REMOTE_PATH}" "${LOCAL_PATH}"

ssh "$HOST" "rm -f '${REMOTE_PATH}'"

echo "Listo: ${LOCAL_PATH}"
