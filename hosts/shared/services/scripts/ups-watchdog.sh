#!/usr/bin/env bash
set -uo pipefail

UPS_NAME="salicru"
DRIVER_NAME="nutdrv_qx"
USB_VENDOR="0665"
STATE_FILE="/tmp/ups-watchdog-failures"
ESCALATION_FILE="/tmp/ups-watchdog-escalations"
MAX_SOFT_FAILURES=3
MAX_HARD_FAILURES=5
MAX_ESCALATIONS=3

log() {
  echo "[ups-watchdog] $1"
}

get_count() {
  if [[ -f "$1" ]]; then
    cat "$1"
  else
    echo 0
  fi
}

set_count() {
  echo "$2" > "$1"
}

kill_driver() {
  local pidfile="/var/state/ups/${UPS_NAME}-${DRIVER_NAME}.pid"
  if [[ -f "$pidfile" ]]; then
    local pid
    pid=$(cat "$pidfile")
    log "Killing driver process $pid"
    kill "$pid" 2>/dev/null || true
    sleep 2
  else
    log "No PID file found at $pidfile, skipping kill"
  fi
}

reset_usb_device() {
  log "Attempting USB re-enumerate for vendor $USB_VENDOR..."
  local device_path
  device_path=$(grep -rl "$USB_VENDOR" /sys/bus/usb/devices/*/idVendor 2>/dev/null | head -1 | sed 's|/idVendor||')

  if [[ -z "$device_path" ]]; then
    log "ERROR: Could not find USB device with vendor $USB_VENDOR"
    return 1
  fi

  local auth_path="$device_path/authorized"
  log "De-authorizing USB device at $device_path"
  echo 0 > "$auth_path"
  sleep 1
  log "Re-authorizing USB device at $device_path"
  echo 1 > "$auth_path"
  sleep 2
}

if upsc "$UPS_NAME@localhost" ups.status 2>/dev/null; then
  failures=$(get_count "$STATE_FILE")
  if [[ "$failures" -gt 0 ]]; then
    log "Communication restored after $failures failures"
    set_count "$STATE_FILE" 0
    set_count "$ESCALATION_FILE" 0
  fi
  exit 0
fi

failures=$(get_count "$STATE_FILE")
failures=$((failures + 1))
set_count "$STATE_FILE" "$failures"
log "Communication check failed (failure $failures)"

escalations=$(get_count "$ESCALATION_FILE")

if [[ "$escalations" -ge "$MAX_ESCALATIONS" ]]; then
  log "Escalation limit reached ($escalations), restarting full NUT stack"
  systemctl restart upsdrv upsd
  set_count "$STATE_FILE" 0
  set_count "$ESCALATION_FILE" 0

elif [[ "$failures" -ge "$MAX_HARD_FAILURES" ]]; then
  log "Reached $MAX_HARD_FAILURES failures, performing USB re-enumerate + driver restart"
  kill_driver
  reset_usb_device || true
  systemctl restart upsdrv
  set_count "$STATE_FILE" 0
  escalations=$((escalations + 1))
  set_count "$ESCALATION_FILE" "$escalations"
  log "Escalation counter: $escalations/$MAX_ESCALATIONS"

elif [[ "$failures" -ge "$MAX_SOFT_FAILURES" ]]; then
  log "Reached $MAX_SOFT_FAILURES failures, restarting driver"
  kill_driver
  systemctl restart upsdrv
  set_count "$STATE_FILE" 0
fi
