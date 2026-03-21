# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS configuration repository for a home NAS server. The project uses:
- **NixOS flakes** for system configuration
- **agenix** for secrets management
- **disko** for disk partitioning (on the main NAS)

Kubernetes application deployments are managed separately in the `nas-k3s` repository via GitOps.

## Common Commands

### Commands that require the dev container (NixOS builds/deploys)

These must run inside the dev container because the flake targets `x86_64-linux` and requires nix tooling. From outside the container, use `./scripts/inside-devcontainer.sh`:

```bash
./scripts/inside-devcontainer.sh just deploy-nas
./scripts/inside-devcontainer.sh just dry-activate
./scripts/inside-devcontainer.sh just install
./scripts/inside-devcontainer.sh just iso
./scripts/inside-devcontainer.sh just test
```

From inside the dev container, run `just` commands directly.

### Commands that run locally (no dev container needed)

```bash
just docs
```

## Architecture

### NixOS Structure

The repository defines two NixOS configurations in `flake.nix`:

1. **nas** (`hosts/nas/`) - Main production NAS server (x86_64-linux)
2. **iso** (`hosts/iso/`) - Installation media

**Module Organization:**
- `hosts/nas/` - All NAS configuration
  - `default.nix` - Import aggregator
  - `base.nix` - Base system packages and nix settings
  - `configuration.nix` - Boot loader and hardware-specific settings (it87 kernel module)
  - `hardware-configuration.nix` - Disk layout, kernel modules, udev rules
  - `users.nix` - User account definitions
  - `secrets.nix` - agenix secret definitions
  - `ups.nix` - UPS monitoring configuration
  - `snapper.nix` - Btrfs snapshot management
  - `services/` - Service modules (k3s, samba, ssh, smart, fans, cloudflared, dnsmasq, strongswan, network-monitor, ups-watchdog)
- `utilities/` - Pure Nix utility functions
  - `utilities.nix` - Reusable functions (e.g., `toBase64`)
  - `utilities.test.nix` - Unit tests for utilities
  - `liquidctl.nix` - Fan control service module

**Secrets Management:**
- Secrets are encrypted with agenix
- Public keys defined in `secrets/secrets.nix`
- Encrypted `.age` files stored in `secrets/`
- Decrypt requires SSH key access

### System Services

- K3s - Kubernetes (single-node server, applications managed via GitOps in `nas-k3s` repo)
- Samba - File sharing
- SSH - Remote access
- SMART monitoring - Disk health
- Fan control - liquidctl-based cooling management
- Cloudflared - Cloudflare tunnel
- dnsmasq - DNS
- StrongSwan - VPN
- Network monitor - Link monitoring
- UPS watchdog - UPS monitoring and safe shutdown

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

<!-- BACKLOG.MD MCP GUIDELINES START -->

<CRITICAL_INSTRUCTION>

## BACKLOG WORKFLOW INSTRUCTIONS

This project uses Backlog.md MCP for all task and project management activities.

**CRITICAL GUIDANCE**

- If your client supports MCP resources, read `backlog://workflow/overview` to understand when and how to use Backlog for this project.
- If your client only supports tools or the above request fails, call `backlog.get_workflow_overview()` tool to load the tool-oriented overview (it lists the matching guide tools).

- **First time working here?** Read the overview resource IMMEDIATELY to learn the workflow
- **Already familiar?** You should have the overview cached ("## Backlog.md Overview (MCP)")
- **When to read it**: BEFORE creating tasks, or when you're unsure whether to track work

These guides cover:
- Decision framework for when to create tasks
- Search-first workflow to avoid duplicates
- Links to detailed guides for task creation, execution, and finalization
- MCP tools reference

You MUST read the overview resource to understand the complete workflow. The information is NOT summarized here.

</CRITICAL_INSTRUCTION>

<!-- BACKLOG.MD MCP GUIDELINES END -->
