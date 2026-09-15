---
id: NAS-25.9
title: >-
  Eliminar StrongSwan del NAS (VPN cubierta por Tailscale) y borrar DNS
  vpn.danielramos.me
status: To Do
assignee: []
created_date: '2026-09-12 17:09'
labels:
  - vpn
  - networking
  - tech-debt
dependencies: []
references:
  - hosts/nas/services/strongswan.nix
  - hosts/nas/services/scripts/generate-strongswan-client.sh
  - secrets/secrets.nix
parent_task_id: NAS-25
priority: medium
type: chore
ordinal: 14000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Tailscale ya proporciona acceso remoto suficiente a la red del NAS, por lo que mantener StrongSwan (IKEv2/IPSec/EAP-TLS) es complejidad y superficie de ataque innecesarias: certificados propios (CA + server), secretos agenix, reglas NAT/firewall específicas y un script de generación de clientes. El objetivo es retirar por completo StrongSwan y limpiar todo lo asociado, incluido el registro DNS público `vpn.danielramos.me`.

Esto supersede la decisión de NAS-25.8 (mantener StrongSwan) a la luz de que Tailscale cubre el caso de uso, y deja sin sentido NAS-25.1 (migrar cripto de la VPN a ECDSA P-384) y NAS-25.2 (eliminar modp2048), que deberían cerrarse como no-aplica al completar esta tarea.

El borrado del registro DNS `vpn.danielramos.me` es una acción manual en el proveedor de DNS (Cloudflare), fuera de este repo.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 El módulo StrongSwan queda eliminado de la config del NAS (import en hosts/nas y el fichero hosts/nas/services/strongswan.nix, más el script generate-strongswan-client.sh)
- [ ] #2 Los secretos agenix de StrongSwan (CA cert/key, server cert/key) se eliminan de secrets/secrets.nix y sus ficheros .age
- [ ] #3 Se retiran las reglas NAT/firewall y cualquier apertura de puertos (500/4500 UDP) específicas de la VPN IPSec
- [ ] #4 El registro DNS vpn.danielramos.me se borra en el proveedor de DNS
- [ ] #5 Se verifica que el acceso remoto a la red local del NAS sigue funcionando vía Tailscale tras la eliminación
- [ ] #6 make dry-activate-nas evalúa sin errores y no quedan referencias colgantes a strongswan/age.secrets eliminados
- [ ] #7 Se actualizan las referencias a StrongSwan en la documentación del repo (CLAUDE.md y docs del backlog que lo mencionen)
- [ ] #8 NAS-25.1 y NAS-25.2 se cierran como no-aplica al retirarse la VPN StrongSwan
<!-- AC:END -->
