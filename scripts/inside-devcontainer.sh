#!/bin/bash
set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <command> [args...]"
    exit 1
fi

CONTAINER_ID=$(docker ps --format "{{.ID}}\t{{.Image}}" | grep "vsc-nas" | awk '{print $1}' | head -1)

if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No dev container found. Make sure the VSCode dev container is running."
    exit 1
fi

docker exec "$CONTAINER_ID" bash -c "
export USER=vscode
. /home/vscode/.nix-profile/etc/profile.d/nix.sh
cd /workspace
$(printf '%q ' "$@")
"
