#!/usr/bin/env bash

set -e

INTERFACE="enp4s0"
CARRIER_FILE="/sys/class/net/${INTERFACE}/carrier"
OPERSTATE_FILE="/sys/class/net/${INTERFACE}/operstate"

if [[ -w /var/log ]]; then
    LOG_FILE="/var/log/network-link-monitor.log"
else
    LOG_FILE="/tmp/network-link-monitor.log"
fi

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

has_carrier() {
    if [[ ! -f "$CARRIER_FILE" ]]; then
        return 1
    fi
    [[ $(cat "$CARRIER_FILE" 2>/dev/null) == "1" ]]
}

get_operstate() {
    if [[ ! -f "$OPERSTATE_FILE" ]]; then
        echo "unknown"
        return
    fi
    cat "$OPERSTATE_FILE" 2>/dev/null || echo "unknown"
}

restart_dhcp() {
    log_msg "Attempting DHCP restart on $INTERFACE..."

    ip link set "$INTERFACE" down
    sleep 2
    ip link set "$INTERFACE" up

    dhcpcd -x "$INTERFACE" 2>/dev/null || true
    sleep 1
    dhcpcd "$INTERFACE" 2>/dev/null || true

    log_msg "DHCP restart completed"
}

log_msg "Starting network link monitor for $INTERFACE"

LAST_STATE=""
DOWN_TIME=""
CONSECUTIVE_FAILURES=0

while true; do
    CURRENT_STATE=$(get_operstate)
    CURRENT_CARRIER=$(has_carrier && echo "up" || echo "down")

    if [[ "$CURRENT_STATE" != "$LAST_STATE" ]] || [[ "$CURRENT_CARRIER" != "$LAST_CARRIER" ]]; then
        log_msg "Link state changed: operstate=$CURRENT_STATE carrier=$CURRENT_CARRIER"
        LAST_STATE="$CURRENT_STATE"
        LAST_CARRIER="$CURRENT_CARRIER"
    fi

    if [[ "$CURRENT_STATE" == "down" ]] || [[ "$CURRENT_CARRIER" == "down" ]]; then
        if [[ -z "$DOWN_TIME" ]]; then
            DOWN_TIME=$(date +%s)
            log_msg "WARNING: Link is DOWN on $INTERFACE"
            CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
        fi

        CURRENT_TIME=$(date +%s)
        DOWN_DURATION=$((CURRENT_TIME - DOWN_TIME))

        if [[ $DOWN_DURATION -ge 5 && $CONSECUTIVE_FAILURES -le 3 ]]; then
            log_msg "Link has been down for ${DOWN_DURATION}s, attempting recovery (attempt $CONSECUTIVE_FAILURES/3)"
            restart_dhcp
            DOWN_TIME=""
            sleep 10
            continue
        fi

        if [[ $DOWN_DURATION -ge 30 ]]; then
            log_msg "ERROR: Link has been down for ${DOWN_DURATION}s after recovery attempts"
        fi
    else
        if [[ -n "$DOWN_TIME" ]]; then
            CURRENT_TIME=$(date +%s)
            DOWN_DURATION=$((CURRENT_TIME - DOWN_TIME))
            if [[ $DOWN_DURATION -gt 0 ]]; then
                log_msg "Link recovered after ${DOWN_DURATION}s (was down $CONSECUTIVE_FAILURES times)"
            fi
        fi
        DOWN_TIME=""
        CONSECUTIVE_FAILURES=0
    fi

    sleep 5
done
