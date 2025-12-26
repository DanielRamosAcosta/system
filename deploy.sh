#!/bin/bash
set -e

# Find the dev container by image containing 'vsc-nas'
CONTAINER_ID=$(docker ps --format "{{.ID}}\t{{.Image}}" | grep "vsc-nas" | awk '{print $1}' | head -1)

if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No dev container found. Make sure the VSCode dev container is running."
    exit 1
fi

echo "Found dev container: $CONTAINER_ID"
echo "Deploying NixOS configuration..."
echo ""

# Execute deployment inside the container
docker exec "$CONTAINER_ID" bash -c '
export USER=vscode
. /home/vscode/.nix-profile/etc/profile.d/nix.sh
cd /workspace
just --unstable deploy-nas
'
