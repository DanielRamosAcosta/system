---
id: doc-25
title: 'Hardware: Switch TP-Link TL-SG105 (5 puertos Gigabit)'
type: other
created_date: '2026-08-15 13:40'
---
Documentación del switch de red doméstico. Es el único switch de la LAN de Tenerife: un modelo **no gestionable** (sin VLANs / 802.1Q), de sobremesa, fanless y de 5 puertos Gigabit. Datos de la etiqueta física del equipo (`9V 0.6A`) y de la ficha del fabricante.

- Fabricante: TP-Link
- Modelo: TL-SG105 (5-Port Gigabit Desktop Switch)
- Tipo: switch no gestionado (unmanaged), capa 2
- Alimentación (etiqueta física de esta unidad): **9V 0.6A** (adaptador externo)

> La ficha actual de TP-Link lista **5V/0.6A** para las revisiones recientes; esta unidad trae **9V/0.6A** en la etiqueta, lo que indica una **versión de hardware más antigua** (probablemente V1/V2). El conector de alimentación no es intercambiable con el de un TL-SG105 nuevo: hay que conservar su adaptador original.

## Especificaciones

| Spec | Valor |
|---|---|
| Puertos | 5 × RJ45 10/100/1000 Mbps, Auto-Negotiation, Auto-MDI/MDIX |
| Estándares | IEEE 802.3i / 802.3u / 802.3ab / 802.3x, 802.1p |
| Capacidad de conmutación | 10 Gbps (no bloqueante, 5×1G full-duplex) |
| Tasa de reenvío | 7.4 Mpps |
| Tabla de direcciones MAC | 2K entradas |
| Buffer de paquetes | 1 Mb |
| Jumbo frames | 16 KB |
| Método de conmutación | Store-and-Forward |
| Control de flujo | 802.3x (full-duplex), backpressure (half-duplex) |
| QoS | 802.1p / DSCP (solo hardware V2 en adelante) |
| IGMP Snooping | Sí |
| VLANs / 802.1Q | **No** (switch tonto, sin segmentación) |
| Carcasa | Metálica |
| Refrigeración | Fanless (pasiva, sin ventilador) |
| Consumo máximo | 2.3 W |
| Dimensiones | 100 × 98 × 25 mm |
| Estado del producto | End of Life en el catálogo de TP-Link |

## Rol en la red y limitaciones

- Es un **switch de acceso plano**: reparte la LAN `192.168.1.0/24` a nivel de capa 2, sin ninguna inteligencia de VLAN, routing ni gestión.
- **Techo de 1 Gbps por puerto.** El NAS tiene NICs de 2.5 GbE (`enp4s0`) y 10 GbE (`enp1s0`); cualquier tramo que pase por este switch queda limitado a **1 Gbps**. Para aprovechar el 2.5G/10G del NAS haría falta un switch multigigabit (o conexión directa).
- **Sin 802.1Q**: no sirve para segmentar VLANs ni para montar un router-on-a-stick. Ver implicaciones abajo.

## Implicación para el proyecto de router neutro

En el proyecto de sustituir el router Vodafone Sercomm H-500-s (ver [doc-24](#doc-24)) por un router neutro con NixOS, este switch **condiciona la topología**:

- Al **no soportar VLANs**, no se puede hacer "router-on-a-stick" (WAN y LAN por un solo cable etiquetado). El router neutro necesita **como mínimo 2 NICs físicas**: una para la WAN (hacia la ONT) y otra para la LAN (hacia este switch).
- El etiquetado de la **VLAN 100** de Vodafone (si la ONT entrega el tráfico *tagged*) tendría que hacerlo **el router**, no el switch — con NixOS es trivial vía `systemd-networkd` (802.1q sobre la interfaz WAN).
- Topología objetivo: `ONT → [WAN] router NixOS [LAN] → TL-SG105 → NAS / resto de la casa`.
- Si en el futuro se quiere segmentar (IoT, invitados, DMZ) por VLANs, este switch **habría que reemplazarlo** por uno gestionable (p. ej. TP-Link TL-SG108E, Mikrotik, etc.).

## Notas

- Fanless y 2.3 W: silencioso y despreciable en consumo; buen candidato para dejarlo fijo.
- Al ser EOL y no gestionable, no recibe firmware ni tiene interfaz de administración: es plug-and-play puro.
- Conservar el adaptador original de **9V** de esta unidad (no es el 5V de las revisiones nuevas).
