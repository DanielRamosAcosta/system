#!/usr/bin/env bash
set -euo pipefail

UPS_NAME="salicru"
STATE_FILE="/tmp/ups-watchdog-failures"
MAX_SOFT_FAILURES=3
MAX_HARD_FAILURES=5

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

reset_usb_device() {
  log "Attempting USB reset for vendor 0665..."
  local device_path
  device_path=$(grep -rl "0665" /sys/bus/usb/devices/*/idVendor 2>/dev/null | head -1 | sed 's|/idVendor||')

  if [[ -z "$device_path" ]]; then
    log "ERROR: Could not find USB device with vendor 0665"
    return 1
  fi

  local devnum busnum usb_dev
  busnum=$(cat "$device_path/busnum")
  devnum=$(cat "$device_path/devnum")
  usb_dev=$(printf "/dev/bus/usb/%03d/%03d" "$busnum" "$devnum")

  log "Resetting USB device at $usb_dev (bus=$busnum dev=$devnum)"
  usbreset "$usb_dev"
  sleep 2
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
log "Communication check failed (failure $failures)"

if [[ "$failures" -ge "$MAX_HARD_FAILURES" ]]; then
  log "Reached $MAX_HARD_FAILURES failures, performing USB reset + driver restart"
  upsdrvctl stop "$UPS_NAME" 2>/dev/null || true
  sleep 2
  reset_usb_device || true
  upsdrvctl start "$UPS_NAME"
  set_failure_count 0

elif [[ "$failures" -ge "$MAX_SOFT_FAILURES" ]]; then
  log "Reached $MAX_SOFT_FAILURES failures, restarting driver"
  upsdrvctl stop "$UPS_NAME" 2>/dev/null || true
  sleep 2
  upsdrvctl start "$UPS_NAME"
fi
