TYPST = typst
DOC_SRC = docs/NAS\ DIY.typ
DOC_PDF = docs/NAS\ DIY.pdf

.PHONY: docs encrypt-secrets deploy dashboard iso

docs: $(DOC_PDF)

$(DOC_PDF): $(DOC_SRC)
	$(TYPST) compile "$<"

deploy-nas:
	nixos-rebuild switch \
	  --fast \
	  --flake .#nas \
	  --use-remote-sudo \
	  --build-host dani@192.168.65.3 \
	  --target-host dani@192.168.65.3

deploy-playground:
	nixos-rebuild switch \
	  --fast \
	  --flake .#playground \
	  --use-remote-sudo \
	  --build-host dani@playground.danielramos.me \
	  --target-host dani@playground.danielramos.me

dashboard:
	kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

install:
	nix run github:nix-community/nixos-anywhere -- \
	--flake .#nas \
	--generate-hardware-config nixos-generate-config ./hosts/nas/hardware-configuration.nix \
	--target-host root@192.168.1.44

iso:
	nix build .#nixosConfigurations.iso.config.system.build.isoImage
