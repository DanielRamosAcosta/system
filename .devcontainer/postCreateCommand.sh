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

# Configure shell to automatically run nix develop
cat >> ~/.bashrc << 'EOF'
# Auto-enter nix develop if not already in one
if [[ ! -f ~/.nix_shell_entered && -t 0 ]]; then
    touch ~/.nix_shell_entered
    nix develop --impure --accept-flake-config
    rm ~/.nix_shell_entered
fi
EOF

echo "Post-create setup completed successfully!"
