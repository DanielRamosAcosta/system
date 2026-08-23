---
id: NAS-25.1
title: Migrar VPN StrongSwan de RSA a ECDSA P-384
status: To Do
assignee: []
created_date: '2026-04-12 01:44'
updated_date: '2026-08-15 20:10'
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
- [ ] #1 Certificados de cliente generados con ECDSA P-384 (Ed25519 DESCARTADO: el Llavero de macOS no importa PKCS#12 con clave Ed25519 para IKEv2/EAP-TLS)
- [ ] #2 Firma de certificados usa SHA-512
- [ ] #3 Password del PKCS#12 es aleatorio y único por bundle (openssl rand), impreso al operador al final; NO hardcodeado ni persistido; eliminar dani123 del script y del log
- [ ] #4 Clientes VPN existentes siguen funcionando o se documenta proceso de migración
<!-- AC:END -->

## Comments

<!-- COMMENTS:BEGIN -->
created: 2026-08-15 20:06
---
Hallazgo (2026-08-15): probada la compatibilidad de tipos de clave con el cliente IKEv2/EAP-TLS de Apple emitiendo certs de cliente firmados por la CA actual y empaquetados en PKCS#12 legacy (pbeWithSHA1And40BitRC2-CBC).

- Ed25519 → el Llavero de macOS falla al importar el .p12 con 'Imposible descodificar los datos proporcionados'. No llega ni a intentar conectar. => Ed25519 NO viable con clientes Apple.
- RSA 2048 → importa OK (control).
- ECDSA P-384 → importa OK.

Decisión: pivotar el objetivo de la tarea de Ed25519 a ECDSA P-384, que además figura en la lista oficial de CertificateType de Apple (RSA/ECDSA256/384/521). SHA-512 en la firma ya validado en las pruebas. Pendiente: adaptar generate-strongswan-client.sh (genpkey EC P-384 en vez de genrsa 4096), quitar el password hardcodeado dani123 (agenix), y confirmar conexión real del túnel con un cert ECDSA.
---
<!-- COMMENTS:END -->
