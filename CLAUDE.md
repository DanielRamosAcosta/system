# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS configuration repository for a home NAS server with K3s (Kubernetes) running containerized applications. The project uses:
- **NixOS flakes** for system configuration
- **Tanka (jsonnet)** for Kubernetes application deployment
- **agenix** for secrets management
- **disko** for disk partitioning (on the main NAS)

## Common Commands

### NixOS System Management

```bash
# Deploy configuration to NAS
just deploy-nas

# Install NixOS on new hardware (uses nixos-anywhere)
just install

# Build ISO image
just iso

# Build documentation PDF from Typst source
just docs

# Run Nix utility tests
just test
# Or directly: nix eval --impure --expr 'import ./utilities/utilities.test.nix {}'
```

### Kubernetes Application Deployment (Tanka)

All tanka commands are in `tanka/justfile`:

```bash
# Build manifests for specific environment
just tanka::build-databases
just tanka::build-media
just tanka::build-auth
just tanka::build-monitoring
# Available environments: databases, media, auth, monitoring, dashboard, system

# Deploy to cluster
just tanka::deploy
# Note: Currently configured to deploy databases environment

# Manage secrets
just tanka::encrypt-secrets  # Encrypts lib/secrets.json -> lib/secrets.json.age
just tanka::decrypt-secrets  # Requires private key at ~/.ssh/id_ed25519
```

### Development Environment

```bash
# Enter dev shell with nixos-rebuild and agenix
nix develop
```

### Deploying NixOS Configuration

#### Quick Deploy (from outside dev container)

```bash
# THIS IS THE FASTEST WAY - Automatically finds and uses the dev container
./deploy.sh
```

This script:
- Automatically finds the VSCode dev container
- Sources the nix environment
- Executes the deployment with all required setup
- Works with or without VPN

#### Deploy from Inside Dev Container

When working inside the VSCode dev container, SSH keys are automatically mounted from `.hostssh/` to `.ssh/`.

**Deploy Command (from inside dev container):**
```bash
# Quick method using justfile
just --unstable deploy-nas
```

Or directly:
```bash
/home/vscode/.nix-profile/bin/nixos-rebuild switch --no-reexec --flake '.#nas' --sudo --build-host nas --target-host nas
```

### Kubernetes Access

```bash
# Port-forward to dashboard
just dashboard
# Access at https://localhost:8443
```

## Architecture

### NixOS Structure

The repository defines three NixOS configurations in `flake.nix`:

1. **nas** (`hosts/nas/`) - Main production NAS server (x86_64-linux)
2. **playground** (`hosts/playground/`) - Testing environment (x86_64-linux)
3. **iso** (`hosts/iso/`) - Installation media

**Module Organization:**
- `hosts/shared/` - Common configuration imported by both nas and playground
  - `configuration.nix` - Base system packages and nix settings
  - `users.nix` - User account definitions
  - `secrets.nix` - agenix secret definitions
  - `services/` - Service modules (k3s, samba, ssh, smart, fans)
  - `ups.nix` - UPS monitoring configuration
  - `snapper.nix` - Btrfs snapshot management
- `hosts/nas/` - NAS-specific configuration
  - Imports liquidctl for fan control
  - Hardware-specific settings (it87 kernel module)
- `utilities/` - Pure Nix utility functions
  - `utilities.nix` - Reusable functions (e.g., `toBase64`)
  - `utilities.test.nix` - Unit tests for utilities
  - `liquidctl.nix` - Fan control service module

**Secrets Management:**
- Secrets are encrypted with agenix
- Public keys defined in `secrets/secrets.nix`
- Encrypted `.age` files stored in `secrets/`
- Decrypt requires SSH key access

### Kubernetes (K3s) Structure

K3s runs on the NAS host via `hosts/shared/services/k3s.nix`. Applications are deployed using Tanka.

**Tanka Organization:**
- `tanka/environments/` - Each subdirectory is a k8s namespace:
  - `auth/` - Authentication services (Authelia)
  - `databases/` - Database services
  - `dashboard/` - Kubernetes dashboard
  - `media/` - Media services (Immich, SFTPGo)
  - `monitoring/` - Monitoring stack
  - `system/` - System services
  - `versions.json` - Centralized version management for all services
- `tanka/lib/` - Shared jsonnet libraries and application definitions
  - `k.libsonnet` - Kubernetes helpers from grafana/jsonnet-libs
  - `utils.libsonnet` - Custom utilities (volumes, ingress, secrets helpers)
  - `auth/`, `media/`, etc. - Application-specific libsonnet files
  - `secrets.json.age` - Encrypted secrets (decrypt before using)

**Tanka Environment Pattern:**
Each environment has:
- `main.jsonnet` - Imports and instantiates applications from lib/
- `spec.json` - Defines namespace and apiServer (https://localhost:6443)

**Key Jsonnet Utilities** (`tanka/lib/utils.libsonnet`):
- `image(name, version)` - Construct image strings
- `ingressRoute.from(service, host)` - Create Traefik IngressRoutes
- `pv.atLocal(name, storage, path)` - Local PersistentVolumes
- `secret.forEnv(component, content)` - Environment variable secrets
- `envVars.fromConfigMap/fromSecret` - Extract env vars from resources

### Version Management

The `versions.json` file in `tanka/environments/` centralizes version management for all Kubernetes applications.

**Structure:**
Each application has a `repo` (GitHub org/name) and `version` (tag or version string):
```jsonnet
{
  "immich": {
    "repo": "immich-app/immich",
    "version": "v2.2.1"
  }
}
```

**Usage Pattern:**
1. Update the version in `versions.json`
2. Import it in the environment's `main.jsonnet`
3. Pass the version to the application constructor

Example from `media/main.jsonnet`:
```jsonnet
local versions = import '../versions.json';
immich.new(version=versions.immich.version)
```

Applications currently tracked: immich, sftpgo, gitea, authelia, valkey, grafana, loki, promtail, prometheus, nodeExporter, smartctlExporter, nutExporter, cloudflare.

### System Services

**K3s Configuration:**
- Server role (single-node)
- Ports: 6443 (API server)
- Trusted interfaces: cni0, flannel.1

**Other Services:**
- Samba - File sharing
- SSH - Remote access
- SMART monitoring - Disk health
- Fan control - liquidctl-based cooling management

### Cross-Platform Considerations

The flake is developed on `aarch64-linux` (dev shell) but targets `x86_64-linux` (NAS hardware). The `nixos-rebuild` command in `just deploy-nas` handles cross-compilation by building on the NAS host itself (`--build-host nas`).

## Testing

Run utility function tests:
```bash
just test
```

This evaluates `utilities/utilities.test.nix` which uses `lib.runTests` to validate utility functions like `toBase64`.

## Code Guidelines for Claude

- **Never add comments to code** - Code should be self-explanatory through clear naming and structure
- **Commits must be single-line** - No multi-line messages, no co-authors. Example: `git commit -m "Add network link monitoring service"`
