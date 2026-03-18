#!/usr/bin/env bash
set -uo pipefail

UPS_NAME="salicru"
DRIVER_NAME="nutdrv_qx"
USB_VENDOR="0665"
STATE_FILE="/tmp/ups-watchdog-failures"
MAX_FAILURES=3

log() {
  echo "[ups-watchdog] $1"
}

get_failure_count() {
  if [[ -f "$STATE_FILE" ]]; then
    cat "$STATE_FILE"
  else
    echo 0
  fi
}

set_failure_count() {
  echo "$1" > "$STATE_FILE"
}

kill_driver() {
  local pid
  pid=$(pgrep -x "$DRIVER_NAME" 2>/dev/null || true)
  if [[ -n "$pid" ]]; then
    log "Killing driver process $pid"
    kill "$pid" 2>/dev/null || true
    sleep 2
    if pgrep -x "$DRIVER_NAME" >/dev/null 2>&1; then
      log "Driver still alive, sending SIGKILL"
      kill -9 "$pid" 2>/dev/null || true
      sleep 1
    fi
  else
    log "No driver process found"
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

recover() {
  log "Starting recovery: kill driver → USB re-enumerate → restart driver"
  kill_driver
  reset_usb_device || true
  systemctl restart upsdrv
  sleep 3

  if upsc "$UPS_NAME@localhost" ups.status 2>/dev/null; then
    log "Recovery successful"
    set_failure_count 0
  else
    log "Recovery failed, will retry in $MAX_FAILURES minutes"
    set_failure_count 0
  fi
}

if upsc "$UPS_NAME@localhost" ups.status 2>/dev/null; then
  failures=$(get_failure_count)
  if [[ "$failures" -gt 0 ]]; then
    log "Communication restored after $failures failures"
    set_failure_count 0
  fi
  exit 0
fi

failures=$(get_failure_count)
failures=$((failures + 1))
set_failure_count "$failures"
log "Communication check failed (failure $failures/$MAX_FAILURES)"

if [[ "$failures" -ge "$MAX_FAILURES" ]]; then
  recover
fi
