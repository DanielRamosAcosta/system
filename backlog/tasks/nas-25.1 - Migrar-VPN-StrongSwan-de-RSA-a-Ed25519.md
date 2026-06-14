---
id: NAS-25.1
title: Migrar VPN StrongSwan de RSA a Ed25519
status: To Do
assignee: []
created_date: '2026-04-12 01:44'
labels:
  - security
  - vpn
dependencies: []
references:
  - hosts/nas/services/scripts/generate-strongswan-client.sh
parent_task_id: NAS-25
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
El script `generate-strongswan-client.sh` usa RSA 4096 (línea 63) con `openssl genrsa`. Ed25519 es más rápido, más seguro y genera claves más cortas. También tiene un password hardcodeado `pass:dani123` en línea 101 que debería gestionarse con agenix o variables de entorno. Además, el certificado se firma con SHA-384 (línea 88) cuando SHA-512 es preferible.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Certificados generados con Ed25519 en lugar de RSA 4096
- [ ] #2 Firma de certificados usa SHA-512
- [ ] #3 Password de PKCS#12 se obtiene de agenix o variable de entorno, no hardcodeado
- [ ] #4 Clientes VPN existentes siguen funcionando o se documenta proceso de migración
<!-- AC:END -->
