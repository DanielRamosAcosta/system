.DEFAULT_GOAL := test

.PHONY: docs test iso install \
	activate-nas dry-activate-nas \
	activate-siemens dry-activate-siemens \
	activate-macbook dry-activate-macbook

activate-nas:
	nixos-rebuild-ng switch \
		--no-reexec \
		--flake .#nas \
		--sudo \
		--build-host nas \
		--target-host nas

dry-activate-nas:
	nixos-rebuild-ng dry-activate \
		--no-reexec \
		--flake .#nas \
		--sudo \
		--build-host nas \
		--target-host nas

activate-siemens:
	nixos-rebuild-ng switch \
		--no-reexec \
		--flake .#siemens \
		--sudo

dry-activate-siemens:
	nixos-rebuild-ng dry-activate \
		--no-reexec \
		--flake .#siemens \
		--sudo

activate-macbook:
	sudo darwin-rebuild switch --flake .#macbook

dry-activate-macbook:
	darwin-rebuild build --flake .#macbook

install:
	nix run github:nix-community/nixos-anywhere -- \
		--flake .#nas \
		--generate-hardware-config nixos-generate-config ./hosts/nas/hardware-configuration.nix \
		--target-host root@192.168.1.41

iso:
	nix build .#nixosConfigurations.iso.config.system.build.isoImage

docs:
	typst compile "docs/NAS DIY.typ"

test:
	nix eval --impure --expr 'import ./utilities/utilities.test.nix {}'
