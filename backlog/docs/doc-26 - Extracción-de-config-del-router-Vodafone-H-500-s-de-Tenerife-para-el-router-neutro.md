---
id: doc-26
title: >-
  Extracción de config del router Vodafone H-500-s de Tenerife (para el router
  neutro)
type: other
created_date: '2026-08-15 14:18'
---
Datos extraídos en vivo del router Sercomm **Vodafone-H-500-s** de Tenerife (casa de los padres) el 2026-08-15, de cara a sustituirlo por un **router neutro con NixOS**. La extracción se hizo **en remoto desde A Coruña**, sin tocar físicamente el router. Complementa el post-mortem [doc-24](#doc-24) (bug de WAN por DNAT) y la ficha del switch [doc-25](#doc-25).

## Objetivo del proyecto

Quitar el Sercomm de Vodafone (sin modo bridge, DNAT roto por CPU) y poner un router neutro gestionado con NixOS. Topología objetivo: `ONT (fibra) → [WAN] router NixOS [LAN] → switch TL-SG105 → NAS/casa`.

## Método de extracción (reutilizable)

Como estamos en A Coruña y ambas LAN son `192.168.1.0/24`, `192.168.1.1` colisiona con el gateway local. Solución:

1. **SOCKS proxy** contra el NAS (que sí está en la LAN de Tenerife): `ssh -D 1080 -N nas`. Verificado: sale por la IP pública `77.225.118.178`.
2. **Playwright apuntando al SOCKS** (`--proxy-server=socks5://127.0.0.1:1080 --ignore-https-errors` en `.mcp.json`), navegando a `https://192.168.1.1`. Login manual del usuario (no pasa la contraseña por el agente).
3. El panel es un **SPA con login cifrado** (HMAC-SHA256 con salt/`encryption_key` de `./data/user_lang.json`) — no scriptear a mano (hay **bloqueo por intentos**); dejar que el navegador ejecute su `login.js`.
4. La config se lee de los **datasets JSON** que sirve el propio panel: `./data/<pagina>.json?csrf_token=<tok>` (ej. `statussupportstatus.json`, `statussupportvoice.json`, `phone_phone_connections.json`). Se leen con `fetch()` desde la consola de la página autenticada.

> **Gotcha del servidor web:** el HTTP embebido del Sercomm responde `400 Invalid Request` (con línea de estado mutilada `UNKNOWN 400`, curl la ve como HTTP/0.9) a cualquier petición que **no lleve el juego completo de cabeceras de navegador** (`Accept`, `Accept-Language`, `Accept-Encoding`). Con esas cabeceras → `302 /login.html`. Para curl: usar `--http0.9` y las cabeceras de navegador.

## Datos extraídos

### Sistema
| Campo | Valor |
|---|---|
| Modelo / firmware | Sercomm **Vodafone-H-500-s v3.8.00** |
| Hardware / bootloader | `Vodafone-H-500-sv1` / `0.0.4.0` |
| Nº de serie | `E1823BXKA08759` |

### WAN (Internet)
| Campo | Valor |
|---|---|
| Tecnología | **Fibra (FTTH)**, ONT externa |
| Tipo de conexión | **IPoE / DHCP** (no PPPoE) |
| Evidencia | **Gateway público `87.235.0.10` ≠ IP WAN** → conexión enrutada por DHCP, no punto-a-punto PPPoE. Confirma la hipótesis de doc-24 |
| IP pública | `77.225.118.178` (dinámica) |
| DNS Vodafone | `212.166.210.84` / `212.166.132.104` |
| IPv6 | N/A (sin IPv6 en la WAN) |
| **VLAN WAN** | **Desconocida** — Vodafone la oculta en la UI (ver abajo) |

### LAN / router
| Campo | Valor |
|---|---|
| Red | `192.168.1.0/24`, gateway `192.168.1.1` |
| **MAC del router** | `3C:98:72:95:90:20` (base; WiFi 2.4G `…:21`, 5G `…:25`, guest `…:24`) — para **clonar** en el neutro si hace falta |
| Puertos LAN | 4× gigabit (port1/2/4 activos a 1000, port3 caído) |
| WiFi | 2.4G "Router Casa" (canal 13), 5G "Router Casa" (canal 100); guest `vodafone-Guest` en `192.168.5.1/24` |
| NAS | `nixos` @ `192.168.1.200` (MAC enp4s0 `a8:b8:e0:0a:2d:12`), alcanza el router por `enp4s0` |

### Teléfono fijo (a conservar sí o sí)
| Campo | Valor |
|---|---|
| Número | **+34 922 262 830** (línea `*1`, FXS analógico en el router) |
| Estado | Registrado, "Activo (VoIP)" |
| Credenciales SIP | **No expuestas** en la UI (servidor/usuario/clave ocultos) |

## Lo que NO se puede obtener en remoto (firmware capado de Vodafone)

- **VLAN de la WAN:** no aparece en la UI (la sección Internet no tiene pestaña de conexión ni en Modo Experto).
- **Port-mirror para capturar el 802.1Q:** la "Utilidad de diagnóstico" de este firmware **solo trae Ping** (no el port-mirror de los firmwares no-Vodafone).
- **Telnet/SSH del router:** puertos **22 y 23 cerrados** (solo 53/80/443 abiertos).
- **Backup de configuración:** se genera **cifrado con contraseña** (formato propietario Sercomm) → inútil sin romper el cifrado.
- **ONT:** sin IP de gestión accesible desde la LAN (`192.168.100.1`, `192.168.1.251`, etc. cerrados; ruta vía el router).

## Plan derivado

1. **Router neutro (NixOS):** WAN por **DHCP/IPoE** (sin credenciales). El **VLAN se determina empíricamente en el swap**: probar *untagged* primero; si no coge IP, etiquetar **VLAN 100** (consenso Vodafone FTTH directa). NixOS lo hace con una línea (`systemd-networkd`, 802.1q).
2. **Teléfono fijo:** mantener el **H-500-s como ATA** colgado de un puerto LAN del router neutro (WiFi/DHCP del Sercomm apagados), conservando su registro SIP interno. A validar que registra desde detrás del neutro (SIP saliente a la SBC de Vodafone). Alternativa: capturar el SIP con un tap físico entre ONT y router cuando haya alguien en Tenerife.
3. **VLAN/SIP definitivos:** solo obtenibles con **acceso físico** en Tenerife (tap inline ONT↔router + `tcpdump`) o probando en el swap.
