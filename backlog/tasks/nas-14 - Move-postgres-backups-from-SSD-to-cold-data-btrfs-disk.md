---
id: NAS-14
title: Move postgres-backups from SSD to cold-data btrfs disk
status: To Do
assignee: []
created_date: '2026-03-09 17:10'
updated_date: '2026-03-09 17:12'
labels:
  - infrastructure
  - storage
dependencies: []
priority: high
ordinal: 1750
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The `/cold-data/postgres-backups/` directory is NOT a btrfs subvolume mount — it's falling through to the root filesystem on the NVMe SSD (`/dev/nvme1n1p2`). This means 299GB of WAL archives are consuming SSD space instead of being on the HDD.

**Current state:**
- `/cold-data/postgres-backups/` lives on `/dev/nvme1n1p2` (SSD, 46% used)
- Contains `wal_archive/` (299GB) and `base/` (~0)
- No btrfs subvolume exists for it
- The Kubernetes PV in `tanka/lib/databases/postgres.libsonnet` points to `/cold-data/postgres-backups` (100Gi)

**Required steps:**
1. Create btrfs subvolume `@postgres-backups` on `/dev/sda` (cold-data disk)
2. Add mount entry in `hosts/nas/hardware-configuration.nix` matching the pattern of existing subvolumes (zstd compression)
3. Optionally add snapper config in `hosts/shared/snapper.nix`
4. Deploy NixOS config
5. Stop postgres/pgbackrest, migrate data from SSD to new mount, restart
6. Verify backups are writing to HDD

**Impact:** Frees ~299GB on the SSD.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 postgres-backups is a btrfs subvolume @postgres-backups on /dev/sda
- [ ] #2 Mount entry exists in hardware-configuration.nix with zstd compression
- [ ] #3 WAL archives and base backups are stored on HDD not SSD
- [ ] #4 Snapper snapshots configured (optional)
<!-- AC:END -->
