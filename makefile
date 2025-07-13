TYPST = typst
DOC_SRC = docs/NAS\ DIY.typ
DOC_PDF = docs/NAS\ DIY.pdf

.PHONY: docs encrypt-secrets deploy dashboard

docs: $(DOC_PDF)

$(DOC_PDF): $(DOC_SRC)
	$(TYPST) compile "$<"

deploy:
	nixos-rebuild switch \
	  --fast \
	  --flake .#nas \
	  --use-remote-sudo \
	  --build-host dani@192.168.65.3 \
	  --target-host dani@192.168.65.3

dashboard:
	kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

copy-users:
	kubectl cp ./k8s/secrets/users_database.yml authelia/authelia-8vkv6:/config/users_database.yml

install:
	nix run github:nix-community/nixos-anywhere -- \
	--flake .#nas \
	--generate-hardware-config nixos-generate-config ./hosts/nas/hardware-configuration.nix \
	--target-host dani@192.168.65.3
