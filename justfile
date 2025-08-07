mod tanka

# Build documentation PDF from Typst source
docs:
  typst compile "docs/NAS DIY.typ"

# Deploy to NAS host
deploy-nas:
  nixos-rebuild switch \
    --fast \
    --flake .#nas \
    --use-remote-sudo \
    --build-host dani@192.168.1.200 \
    --target-host dani@192.168.1.200

# Deploy to playground host
deploy-playground:
  nixos-rebuild switch \
    --fast \
    --flake .#playground \
    --use-remote-sudo \
    --build-host dani@192.168.1.41 \
    --target-host dani@192.168.1.41

# Port-forward to Kubernetes dashboard
dashboard:
  kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

# Install NixOS on target host using nixos-anywhere
install:
  nix run github:nix-community/nixos-anywhere -- \
    --flake .#nas \
    --generate-hardware-config nixos-generate-config ./hosts/nas/hardware-configuration.nix \
    --target-host root@192.168.1.41

# Build ISO image
iso:
  nix build .#nixosConfigurations.iso.config.system.build.isoImage

# Run tests
test:
  nix eval --impure --expr 'import ./utils/utils.test.nix {}'
