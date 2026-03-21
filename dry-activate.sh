#!/bin/bash
set -e

CONTAINER_ID=$(docker ps --format "{{.ID}}\t{{.Image}}" | grep "vsc-nas" | awk '{print $1}' | head -1)

if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No dev container found. Make sure the VSCode dev container is running."
    exit 1
fi

echo "Found dev container: $CONTAINER_ID"
echo "Running NixOS dry-run build..."
echo ""

docker exec "$CONTAINER_ID" bash -c '
export USER=vscode
. /home/vscode/.nix-profile/etc/profile.d/nix.sh
cd /workspace
nixos-rebuild dry-activate \
  --fast \
  --flake .#nas \
  --use-remote-sudo \
  --build-host nas \
  --target-host nas
'
