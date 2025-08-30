#!/bin/bash
set -e

# Run nix develop command
nix develop --impure --accept-flake-config --command true

# Setup SSH configuration
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Copy SSH config from host mount and set permissions
cp ~/.hostssh/config ~/.ssh/config
chmod 600 ~/.ssh/config

# Comment out line 8 of the SSH config
sed -i '8s/^/# /' ~/.ssh/config

echo "Post-create setup completed successfully!"
