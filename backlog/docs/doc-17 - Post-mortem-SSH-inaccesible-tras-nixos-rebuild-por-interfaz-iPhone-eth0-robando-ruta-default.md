---
id: doc-17
title: >-
  Post mortem: SSH inaccesible tras nixos-rebuild por interfaz iPhone (eth0)
  robando ruta default
type: other
created_date: '2026-04-04 19:11'
---
# Post mortem: SSH inaccesible tras nixos-rebuild por interfaz iPhone (eth0) robando ruta default

**Fecha:** 2026-04-04
**Duración del incidente:** ~1 hora (18:03 - 19:03 ACPI shutdown)
**Impacto:** Pérdida total de conectividad SSH al NAS, requirió apagado físico (ACPI power button)

## Resumen

Un `nixos-rebuild switch` que incluía el nuevo servicio `usbmuxd` provocó que el kernel registrara el driver `ipheth` para un iPhone conectado por USB. `dhcpcd` configuró automáticamente la interfaz `eth0` del iPhone con una ruta default vía 172.20.10.1 (hotspot del iPhone), desplazando la ruta default legítima vía 192.168.1.1 (LAN). Todo el tráfico saliente empezó a enrutarse por el iPhone, haciendo inaccesible el NAS desde la red local.

## Timeline

| Hora | Evento |
|------|--------|
| 17:56:00 | iPhone conectado por USB al NAS (detectado como dispositivo USB, sin driver de red aún) |
| 18:02:51 | Usuario conecta por SSH y ejecuta `nixos-rebuild switch` con nueva config que incluye `usbmuxd` |
| 18:03:03 | `switch-to-configuration` comienza la activación |
| 18:03:07 | `systemd-udevd` se reinicia como parte del switch. Al arrancar, detecta el iPhone y carga los drivers `ipheth`, `cdc_ether`, `cdc_ncm` |
| 18:03:07 | Se crea la interfaz de red `eth0` (Apple iPhone USB Ethernet). `usbmuxd` arranca y reconfigura el dispositivo USB (config 1 → 4) |
| 18:03:08 | `dhcpcd` detecta la nueva interfaz `eth0`, StrongSwan (`charon-systemd`) la activa |
| 18:03:08 | `switch-to-configuration` termina exitosamente. Sesión SSH del deploy se desconecta normalmente |
| 18:03:40 | `eth0` adquiere carrier. `dhcpcd` solicita lease DHCP |
| 18:03:42 | `dhcpcd` recibe oferta de IP 172.20.10.6/28 desde "iPhone-de-Ale" (172.20.10.1) |
| 18:03:47 | **`dhcpcd` añade ruta default via 172.20.10.1 por eth0.** Esta ruta desplaza o compite con la ruta default legítima (192.168.1.1 por enp4s0). El NAS deja de ser alcanzable desde la LAN |
| 18:03:47 | `dnsmasq` también empieza a usar el nameserver del iPhone (fe80::...%eth0) |
| 18:04-18:15 | Router Advertisements del iPhone expiran continuamente. La interfaz permanece activa con la ruta default rota |
| 18:15-19:03 | El balance de btrfs sigue corriendo normalmente (el sistema funciona, solo la red está mal enrutada). No hay acceso SSH posible desde 192.168.1.x |
| 19:03:40 | Usuario realiza ACPI shutdown (botón de encendido). systemd inicia shutdown limpio, el balance de btrfs se cancela |
| 19:07 | Sistema arranca correctamente. iPhone ya no está conectado. Ruta default correcta via 192.168.1.1 |

## 5 Whys - Análisis de causa raíz

**1. ¿Por qué se perdió la conectividad SSH?**
Porque la ruta default del NAS cambió de 192.168.1.1 (LAN) a 172.20.10.1 (iPhone hotspot). Los paquetes de respuesta SSH salían por la interfaz equivocada.

**2. ¿Por qué cambió la ruta default?**
Porque `dhcpcd` configuró automáticamente la interfaz `eth0` (iPhone) con IP, rutas y DNS sin restricciones. Al recibir un lease DHCP con gateway, añadió una ruta default.

**3. ¿Por qué dhcpcd configuró eth0?**
Porque `dhcpcd` gestiona todas las interfaces de red por defecto. No hay ninguna regla que le diga que ignore `eth0` o que solo gestione `enp4s0`.

**4. ¿Por qué apareció eth0 durante el switch?**
Porque el `nixos-rebuild switch` añadió `usbmuxd` como servicio nuevo, lo que provocó que `systemd-udevd` (al reiniciarse) cargara los drivers `ipheth`/`cdc_ether`/`cdc_ncm` para el iPhone que ya estaba conectado por USB. Esto creó la interfaz de red `eth0`.

**5. ¿Por qué el iPhone estaba conectado por USB al NAS?**
Porque se estaba usando para transferir fotos a `/cold-data/immich/upload/imports/ale/iphone-dump-1` (evidencia en logs a las 17:57). El iPhone tiene hotspot activo por defecto, lo que lo convierte en un gateway de red cuando se conecta como dispositivo Ethernet.

## Causa raíz

La configuración de red del NAS no restringe qué interfaces gestiona `dhcpcd`. Cuando apareció una interfaz de red inesperada (`eth0` del iPhone vía `ipheth`), `dhcpcd` la configuró automáticamente incluyendo una ruta default que desplazó la ruta legítima de la LAN. El sistema no tiene protección contra interfaces de red que aparecen dinámicamente y alteran la tabla de rutas.

## Factores contribuyentes

1. **`dhcpcd` sin allowlist de interfaces** — gestiona cualquier interfaz que aparezca, sin discriminar
2. **`usbmuxd` activó el modo Ethernet del iPhone** — cambió la configuración USB del dispositivo (1 → 4), exponiendo la interfaz `ipheth`
3. **El iPhone tenía hotspot activo** — sirvió como DHCP server con gateway, lo que provocó que `dhcpcd` añadiera una ruta default
4. **Sin métricas de ruta diferenciadas** — no hay preferencia configurada para que `enp4s0` siempre gane sobre interfaces dinámicas
5. **El deploy fue remoto** — al perder la red, no había forma de corregir la situación sin acceso físico

## Lecciones aprendidas

1. **`dhcpcd` es peligrosamente permisivo por defecto** — cualquier interfaz nueva con un DHCP server puede robar la ruta default del sistema
2. **Conectar un iPhone por USB a un sistema con `usbmuxd` + `ipheth` equivale a conectar un cable de red a otra subred** — el iPhone actúa como gateway
3. **Los `nixos-rebuild switch` que añaden servicios de hardware (usbmuxd, drivers) pueden tener efectos inmediatos sobre dispositivos ya conectados** al reiniciar udevd
4. **Un ACPI shutdown es limpio** — systemd recibió la señal correctamente, canceló el balance de btrfs y apagó los servicios de forma ordenada

## Acciones preventivas

1. **Configurar `dhcpcd` para que solo gestione `enp4s0`** — usar `allowInterfaces` o `denyInterfaces` para ignorar interfaces dinámicas como `eth0`
2. **Asignar métrica alta a interfaces no-primarias** — asegurar que `enp4s0` siempre tenga la ruta default con menor métrica
3. **Considerar reemplazar dhcpcd por networkd o configuración estática** para la interfaz principal del NAS, eliminando el riesgo de que DHCP altere rutas en un servidor
