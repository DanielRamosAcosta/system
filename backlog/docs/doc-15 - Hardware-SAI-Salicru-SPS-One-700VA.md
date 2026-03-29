---
id: doc-15
title: "Hardware: SAI Salicru SPS One 700VA"
type: other
created_date: '2026-03-29 16:00'
updated_date: '2026-03-29 16:00'
---
# Hardware: SAI Salicru SPS One 700VA

Documentación del SAI (UPS) del NAS.

- Fabricante: Salicru
- Modelo: SPS One 700VA
- Topología: Line-Interactive
- Origen: PCComponentes
- Fecha lanzamiento: 16/01/2020

## Especificaciones

| Spec | Valor |
|---|---|
| Potencia aparente | 700 VA |
| Potencia activa | 360 W |
| Topología | Line-Interactive |
| Formato | Minitorre |
| Forma de onda (batería) | Pseudosenoidal |
| Eficiencia (modo ECO) | 95% |

## Entrada

| Spec | Valor |
|---|---|
| Tensión nominal | 220 / 230 / 240 V AC |
| Margen tensión entrada | 162 - 290 V |
| Frecuencia | 50 / 60 Hz (autodetección) |
| Protección entrada | Térmico rearmable o fusible |

## Salida

| Spec | Valor |
|---|---|
| Tensión nominal | 220 / 230 / 240 V AC |
| Precisión tensión (modo batería) | ±10% |
| Frecuencia salida | 50 / 60 Hz ±1 Hz |
| Tiempo de transferencia | 2 / 6 ms |
| Salidas AC | 4x IEC C13 |
| AVR (estabilización) | Sí (Buck/Boost) |

## Batería

| Spec | Valor |
|---|---|
| Tipo | Plomo-Calcio (Pb-Ca), hermética, sellada, sin mantenimiento |
| Autonomía | Hasta 20 minutos |
| Vida útil diseño | 3-5 años |
| Recarga | 4-6 horas hasta 90% |
| Reemplazable por usuario | Sí |
| Aviso reemplazo | Sí |
| Cold-start (arranque desde batería) | Sí |
| Rearranque automático | Sí, tras fin de autonomía |
| Test automático | Sí |

## Comunicación

| Spec | Valor |
|---|---|
| Puerto | USB Tipo B (protocolo HID) |
| USB Vendor ID | 0665 (Cypress Semiconductor) |
| USB Product ID | 5161 |
| Protocolo | Voltronic-QS (via Cypress USB to Serial) |
| Software | Descargable desde support.salicru.com |
| Compatibilidad | Windows, Linux, Unix, Mac |

## Datos físicos

| Spec | Valor |
|---|---|
| Dimensiones | 101 mm (W) x 300 mm (D) x 142 mm (H) |
| Peso | 4.45 kg |
| Color | Rojo / Blanco |

## Ambiental

| Spec | Valor |
|---|---|
| Temp. operación | 0°C - 40°C |
| Humedad relativa | 0 - 90% sin condensar |
| Altitud máx. | 2,400 m.s.n.m. (spec Salicru) / 5,000 m (spec PCComponentes) |
| Ruido acústico (1m) | <40 dB |

## Protecciones

- Sobretensiones
- Sobrecargas
- Cortocircuitos
- Transitorios

## Certificaciones

- EMC: EN IEC 62040-2
- Funcionamiento: EN IEC 62040-3
- Seguridad: EN IEC 62040-1
- Corporativas: ISO 9001, ISO 14001, ISO 45001
- Garantía: 3 años

## Alarmas acústicas

| Intervalo | Significado |
|---|---|
| Cada 10 s | Funcionamiento en batería |
| Cada 1 s | Batería baja |
| Cada 0.5 s | Sobrecarga |
| Continuo | Fallo |
| Cada 2 s | Sustitución de batería |

## Estado actual detectado por NUT (2026-03-29)

```
battery.charge: 100
battery.voltage: 13.5
battery.voltage.high: 13.00
battery.voltage.low: 10.40
battery.voltage.nominal: 12.0
input.voltage: 239.2
output.voltage: 239.2
output.frequency: 50.1
output.current.nominal: 2.0
ups.status: OL (Online)
ups.load: 0
ups.temperature: 0.1
ups.type: offline / line interactive
ups.firmware.aux: PM-H
```

Nota: `ups.load: 0` y `ups.temperature: 0.1` sugieren que el SAI no reporta estos valores con precisión (limitación del protocolo Voltronic-QS).

## Configuración NixOS

| Archivo | Propósito |
|---|---|
| `hosts/nas/ups.nix` | Config principal NUT: driver nutdrv_qx, upsd, upsmon, usuario monuser |
| `hosts/nas/services/ups-watchdog.nix` | Systemd timer (cada 60s) que monitoriza salud del driver |
| `hosts/nas/services/scripts/ups-watchdog.sh` | Script de recuperación: mata driver, resetea USB, reinicia servicio |
| `secrets/dani-hashed-password.age` | Password de monuser para upsd |
| `secrets/monuser-password.age` | Password de upsmon para conectar a upsd |

Driver NUT: `nutdrv_qx` (protocolo Voltronic-QS 0.09), polling cada 10s, upsd en 127.0.0.1:3493.

El watchdog existe porque el driver pierde comunicación USB ocasionalmente y necesita reset automático.

## Notas sobre capacidad

Con ~80-92W de consumo estimado del NAS (ver doc-14), los 360W activos del SAI dan margen de sobra. La autonomía de ~20 minutos es más que suficiente para un apagado ordenado (que tarda segundos).

## Issues conocidos

- **FSD ACCESS-DENIED** (backlog nas-9, resuelto): upsmon fallaba al enviar FSD durante cortes de corriente. El NAS se apaga correctamente igualmente, pero el SAI no recibía la orden de apagarse completamente para auto-restaurar al volver la corriente.
- **Driver pierde comunicación USB**: Resuelto con el ups-watchdog que resetea el dispositivo USB y reinicia el driver automáticamente.
