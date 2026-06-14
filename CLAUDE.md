# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is Daniel Ramos' personal Nix configuration repository. It declaratively manages every machine he owns from a single flake:

- **macbook** — Apple Silicon laptop, his primary development machine (nix-darwin + home-manager)
- **siemens** — x86_64 Linux workstation running Sway/Wayland (NixOS + home-manager)
- **nas** — x86_64 home NAS server (NixOS)
- **iso** — minimal NixOS installation media generator

The stack uses:
- **Nix flakes** for all system configuration (`flake.nix`)
- **home-manager** for user-level config on macbook and siemens
- **nix-darwin** for macOS system config on macbook
- **agenix** for secrets management
- **disko** for declarative disk partitioning (nas)
- **stylix** for theming (siemens)

Kubernetes application deployments for the NAS are managed separately in the [nas-k3s](https://github.com/DanielRamosAcosta/nas-k3s) repository via GitOps; this repo only configures the k3s server itself.

## Local development

The **macbook is the local development machine** and has native Nix installed. Unless stated otherwise, assume any requested configuration or tweak applies to the macbook (`hosts/macbook/`).

`direnv` loads the flake dev shell automatically on `cd` (`.envrc` is `use flake`). The dev shell provides `nixos-rebuild-ng` and `agenix`. To enter it manually: `nix develop`.

## Common Commands

Task automation lives in the `Makefile`. Each host has an `activate` (switch) and a `dry-activate` target:

```bash
make activate-nas          # Switch the NAS config (builds + activates on the nas host over SSH)
make dry-activate-nas      # Show what would change on the NAS without applying

make activate-siemens      # Switch siemens (run locally on siemens)
make dry-activate-siemens  # Dry-activate siemens (run locally on siemens)

make activate-macbook      # Switch the macbook config (sudo darwin-rebuild, run locally on the mac)
make dry-activate-macbook  # Build the macbook config without activating (darwin-rebuild build)

make install               # Provision a fresh NAS via nixos-anywhere (root@192.168.1.41)
make iso                   # Build the installation ISO image
make docs                  # Compile the Typst hardware docs to PDF (docs/NAS DIY.typ)
make test                  # Evaluate the pure-Nix utility tests (default goal)
```

Host targets reflect how each machine is reached:
- **nas** uses `--build-host nas --target-host nas`, so the x86_64 build happens on the NAS itself — it runs fine from the aarch64 macbook without local cross-compilation.
- **siemens** builds and activates locally (no build/target host); run it from siemens.
- **macbook** uses `darwin-rebuild` locally; there is no native darwin `dry-activate`, so the dry target is `darwin-rebuild build`.

## Architecture

The flake defines `nixosConfigurations` (`nas`, `siemens`, `iso`), `darwinConfigurations` (`macbook`), a `quadro-ctl` package, and dev shells for `aarch64-linux`, `x86_64-linux`, and `aarch64-darwin`.

### Host module organization

Each host lives under `hosts/<name>/` with a `default.nix` that aggregates imports.

- **`hosts/macbook/`** — nix-darwin system + home-manager, split by concern:
  - `system/` — darwin modules: `nix.nix`, `users.nix`, `homebrew.nix`, `defaults.nix`, `packages.nix`
  - `home/` — home-manager modules: `packages.nix`, `git.nix`, `shell.nix`, `terminal.nix`, `editors.nix`
  - Node 26 comes from a pinned `nixpkgs-node26` input via overlay
- **`hosts/siemens/`** — NixOS workstation: `default.nix` (boot, stylix, users), `hardware-configuration.nix`, `sway.nix` (Sway + greetd), `home.nix` (home-manager for user `dani`: Sway WM, foot, fish, etc.)
- **`hosts/nas/`** — NAS server, organized by domain:
  - `base.nix`, `configuration.nix`, `hardware-configuration.nix`, `users.nix`, `secrets.nix`, `storage.nix`, `snapper.nix`, `ups.nix`
  - `hardware/` — fan control; `kernel-modules/` — it87 sensor module
  - `services/` — one module per service: k3s, ssh, samba, smart, cloudflared, dnsmasq, strongswan, network-monitor, ups-watchdog, scan-server, dvd-server, usbmuxd
- **`hosts/iso/`** — minimal installer image with sshd and Dani's authorized key

### Shared code

- `utilities/` — pure Nix functions (`utilities.nix`: `toBase64`, `interpolateCurve`) with `lib.runTests` unit tests in `utilities.test.nix`. The quadro fan-control module lives in `utilities/quadro-ctl.nix`.
- `packages/quadro-ctl.nix` — package for the Aqua Computer QUADRO PWM fan controller, exposed as `packages.x86_64-linux.quadro-ctl` and as an overlay on the NAS.

### Secrets

Secrets are encrypted with agenix using age:
- Recipient public keys are defined in `secrets/secrets.nix` (per-file `publicKeys`)
- Encrypted `.age` files live in `secrets/`
- Decryption requires the corresponding SSH private key
- Host modules reference them via `age.secrets.<name>`

## Testing

```bash
make test
```

Evaluates `utilities/utilities.test.nix` (via `lib.runTests`) to validate the pure utility functions.

## Code Guidelines for Claude

- **Never add comments to code** — code should be self-explanatory through clear naming and structure
- **Group attributes by shared prefix** — prefer a nested block over repeated dotted paths (e.g. `foo.bar = { baz = 1; fii = 2; };` instead of `foo.bar.baz = 1; foo.bar.fii = 2;`). Exception: literal dotted keys such as VSCode setting names (`"nix.serverPath"`) stay as quoted strings.
- **Commits must be single-line** — no multi-line messages, no co-authors. Example: `git commit -m "Add network link monitoring service"`
- **Documentation edits** — when modifying Backlog.md documents (docs), prefer editing the file directly (Read + Edit) instead of using the MCP `document_update` tool, which requires resending the entire content

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
