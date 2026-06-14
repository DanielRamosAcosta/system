# Nix configs

Personal Nix configuration for all my machines, managed from a single flake.

## Machines

| Host | Platform | Role | Stack |
|------|----------|------|-------|
| `macbook` | aarch64-darwin | Primary dev laptop | nix-darwin + home-manager |
| `siemens` | x86_64-linux | Sway/Wayland workstation | NixOS + home-manager + stylix |
| `nas` | x86_64-linux | Home NAS server | NixOS + disko |
| `iso` | x86_64-linux | Installation media | NixOS |

Kubernetes application deployments for the NAS live in a separate repository, [nas-k3s](https://github.com/DanielRamosAcosta/nas-k3s), via GitOps. This repo only configures the k3s server itself.

## Stack

- **Nix flakes** for all system configuration
- **home-manager** for user-level config (macbook, siemens)
- **nix-darwin** for macOS system config (macbook)
- **agenix** for secrets management
- **disko** for declarative disk partitioning (nas)
- **stylix** for theming (siemens)

## Layout

```
.
├── flake.nix          # Flake: all host configurations + dev shells + packages
├── Makefile           # Task automation (activate / dry-activate per host)
├── hosts/
│   ├── macbook/       # nix-darwin: system/ + home/
│   ├── siemens/       # NixOS workstation: sway + home-manager
│   ├── nas/           # NixOS server: services/, hardware/, storage…
│   └── iso/           # Minimal installer image
├── utilities/         # Pure Nix functions (+ tests) and the quadro fan module
├── packages/          # quadro-ctl package
├── secrets/           # agenix-encrypted .age files
└── docs/              # Typst hardware documentation
```

## Usage

Each host has an `activate` (switch) and a `dry-activate` target:

```bash
make activate-nas          # Build + activate on the NAS over SSH
make dry-activate-nas      # Show what would change on the NAS

make activate-siemens      # Run locally on siemens
make dry-activate-siemens

make activate-macbook      # Run locally on the mac (sudo darwin-rebuild)
make dry-activate-macbook  # Build without activating

make install               # Provision fresh NAS hardware via nixos-anywhere
make iso                   # Build the installation ISO
make docs                  # Compile the hardware docs PDF
make test                  # Run the pure-Nix utility tests
```

The `nas` targets build and activate on the NAS host itself (`--build-host nas --target-host nas`), so they work from the aarch64 macbook without local cross-compilation. The `siemens` targets build locally and are meant to be run from siemens.

The dev shell (`nixos-rebuild-ng`, `agenix`) loads automatically via direnv (`.envrc` is `use flake`), or manually with `nix develop`.

## Secrets

Secrets are encrypted with agenix using age:

- Recipient public keys are defined in `secrets/secrets.nix`
- Encrypted files are stored in `secrets/*.age`
- Decryption requires the matching SSH private key
- Host modules consume them via `age.secrets.<name>`
