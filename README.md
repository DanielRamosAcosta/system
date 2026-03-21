# Personal NAS Server

A personal NixOS-based Network Attached Storage (NAS) server configuration.

## Overview

This project provides a declarative, reproducible configuration for a home NAS server using:

- **NixOS** for immutable system configuration
- **Agenix** for secure secrets management
- **Disko** for declarative disk partitioning

Kubernetes application deployments are managed separately in the [nas-k3s](https://github.com/DanielRamosAcosta/nas-k3s) repository via GitOps.

## Features

- **Declarative Infrastructure**: Entire system defined in code
- **Secrets Management**: Encrypted secrets using age/agenix
- **Automated Deployment**: Single-command deployment to NAS hardware
- **Hardware Monitoring**: SMART disk monitoring and fan control via liquidctl
- **UPS Integration**: Power monitoring and graceful shutdown support
- **Snapshot Management**: Automated Btrfs snapshots via snapper
- **File Sharing**: Samba network shares for home network access
- **Networking**: Cloudflare tunnel, dnsmasq, StrongSwan VPN

## Architecture

### NixOS Hosts

- `nas` - Production NAS server (x86_64-linux)
- `iso` - Installation media generator

### Directory Structure

```
.
├── flake.nix              # NixOS flake definition
├── hosts/
│   ├── nas/               # NAS configuration (all modules)
│   └── iso/               # Installation media
├── utilities/             # Pure Nix utility functions
├── secrets/               # Encrypted secrets (.age files)
└── justfile               # Task automation
```

### System Services

- **K3s** - Kubernetes (applications managed via GitOps in nas-k3s repo)
- **Samba** - File sharing
- **SSH** - Remote access
- **Cloudflared** - Cloudflare tunnel
- **dnsmasq** - DNS
- **StrongSwan** - VPN
- **SMART monitoring** - Disk health
- **Fan control** - liquidctl-based cooling management
- **Network monitor** - Link monitoring
- **UPS watchdog** - UPS monitoring and safe shutdown

## Quick Start

### Prerequisites

- Nix with flakes enabled
- SSH access to target NAS hardware
- Private SSH key for secrets decryption (if managing secrets)

### Commands

```bash
# Deploy NixOS configuration to NAS
just deploy-nas

# Install NixOS on new hardware
just install

# Build installation ISO
just iso

# Build documentation PDF
just docs

# Enter development shell
nix develop

# Run utility tests
just test
```

## Secrets

Secrets are encrypted with agenix using age encryption:
- Public keys defined in `secrets/secrets.nix`
- Encrypted files stored in `secrets/*.age`
- Requires SSH private key for decryption

## Hardware

The NAS configuration includes:
- Custom fan control via liquidctl
- it87 kernel module for hardware sensors
- UPS monitoring and management
- SMART monitoring for disk health

## Development

This repository is developed on aarch64-linux (development machine) but targets x86_64-linux (NAS hardware). Cross-compilation is handled automatically via remote builds on the NAS host.
