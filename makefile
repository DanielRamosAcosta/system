TYPST = typst
DOC_SRC = docs/NAS\ DIY.typ
DOC_PDF = docs/NAS\ DIY.pdf

AGE_PUBLIC_KEY = age1g6uakqgvlp0jhw2hst0w0sja60rcpqffknx3vr5cds37pfv3l5zsd4c6ky
SECRETS_SRC = hosts/nas-vm/secrets/secrets.priv.yaml
SECRETS_ENC = hosts/nas-vm/secrets/secrets.yaml

.PHONY: docs encrypt-secrets deploy

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
	  --build-host dani@192.168.65.3 \
	  --target-host dani@192.168.65.3
