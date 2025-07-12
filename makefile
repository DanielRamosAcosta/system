TYPST = typst
DOC_SRC = docs/NAS\ DIY.typ
DOC_PDF = docs/NAS\ DIY.pdf

AGE_PUBLIC_KEY = age1g6uakqgvlp0jhw2hst0w0sja60rcpqffknx3vr5cds37pfv3l5zsd4c6ky
SECRETS_SRC = hosts/nas-vm/secrets/secrets.priv.yaml
SECRETS_ENC = hosts/nas-vm/secrets/secrets.yaml

.PHONY: docs encrypt-secrets deploy dashboard

docs: $(DOC_PDF)

$(DOC_PDF): $(DOC_SRC)
	$(TYPST) compile "$<"

encrypt-secrets: $(SECRETS_SRC)
	sops --encrypt --age $(AGE_PUBLIC_KEY) "$<" > $(SECRETS_ENC)

deploy:
	nixos-rebuild switch \
	  --fast \
	  --flake .#nas-vm \
	  --use-remote-sudo \
	  --build-host ccpdanielramosacosta@nas.danielramos.me \
	  --target-host ccpdanielramosacosta@nas.danielramos.me

dashboard:
	kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

copy-users:
	kubectl cp ./k8s/secrets/users_database.yml authelia/authelia-8vkv6:/config/users_database.yml

install:
	nix run github:nix-community/nixos-anywhere -- \
	--flake .#nas \
	--generate-hardware-config nixos-generate-config ./hosts/nas/hardware-configuration.nix \
	--target-host ccpdanielramosacosta@nas.danielramos.me
