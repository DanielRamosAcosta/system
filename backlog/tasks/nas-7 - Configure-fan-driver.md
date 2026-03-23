---
id: NAS-7
title: Configure fan driver
status: Done
assignee: []
created_date: '2026-03-09 16:54'
updated_date: '2026-03-23 08:34'
labels:
  - hardware
  - config
  - nixos
dependencies: []
references:
  - 'https://github.com/aleksamagicka/aquacomputer_d5next-hwmon/issues/108'
  - 'https://github.com/liquidctl/liquidctl/issues/824'
  - utilities/liquidctl.nix
  - hosts/nas/services/fans.nix
documentation:
  - 'doc-4 - Hardware: Aqua Computer QUADRO - Controlador de ventiladores PWM'
priority: medium
ordinal: 250
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Configurar correctamente el driver de los ventiladores del NAS. Actualmente se usa liquidctl para el control del Aqua Computer QUADRO (4 canales PWM). El control por porcentaje fijo funciona vía acceso directo USB (hidraw), pero hay dos problemas abiertos que impiden el uso completo del driver del kernel y las curvas de temperatura.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Los nodos pwmX en sysfs son legibles y escribibles (sin 'No data available')
- [ ] #2 liquidctl puede controlar ventiladores sin el warning de fallback a acceso directo
- [ ] #3 Curvas de temperatura funcionan con liquidctl o vía sysfs/hwmon
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Estado actual (2026-03-22)

### Lo que funciona
- liquidctl detecta el QUADRO y puede leer todos los sensores (RPM, potencia, voltaje, corriente, temperatura)
- Control por porcentaje fijo funciona vía acceso directo USB (hidraw)
- Servicio systemd `liquidctl.service` + timer aplica config cada 30s
- 4 ventiladores configurados: fan1/fan2 al 60%, fan3/fan4 al 50%

### Lo que no funciona
- **PWM vía sysfs roto** (issue #108): Los nodos `pwmX` en `/sys/class/hwmon/hwmon5/` devuelven "No data available" en kernel 6.12. El driver `aquacomputer_d5next` no expone funcionalidad PWM. liquidctl compensa con fallback a hidraw.
- **Curvas de temperatura no soportadas** (issue #824): `liquidctl set fan1 speed 20 30 40 60 60 100` falla con "operation not supported by the driver". Solo porcentaje fijo funciona.

### Posible siguiente paso: fork del driver
Se ha planteado hacer fork de `aquacomputer_d5next-hwmon` para intentar arreglar el soporte PWM del Quadro en kernel 6.12.

**Flujo de desarrollo propuesto:**
1. Clonar repo del driver en Mac (editar con IDE local)
2. `rsync` al NAS
3. Compilar solo el módulo en el NAS con `nix-shell -p linuxPackages.kernel.dev gnumake gcc`
4. `sudo rmmod aquacomputer_d5next && sudo insmod ./aquacomputer_d5next.ko`
5. Testear con `cat /sys/class/hwmon/hwmon5/pwm1`

**Prerequisitos verificados:**
- Kernel en NAS: 6.12.76 (coincide con `linuxPackages.kernel`)
- No hay kernel headers ni gcc por defecto (NixOS), se resuelve con nix-shell
- El módulo actual está cargado y funcional para sensores

## Análisis del código del driver (2026-03-22)

Repo clonado en `/Users/danielramos/Documents/repos/others/aquacomputer_d5next-hwmon`

### Flujo de lectura PWM

```
cat /sys/class/hwmon/hwmon5/pwm1
  → aqc_read_pwm()          (línea ~1459)
    → aqc_get_ctrl_val()
      → aqc_get_ctrl_data()  (línea ~881)
        → hid_hw_raw_request(ctrl_report_id=0x03, HID_FEATURE_REPORT)
        → si falla → return -ENODATA  ← "No data available"
```

### Punto de fallo

`aqc_get_ctrl_data()` (línea 881-896) hace `hid_hw_raw_request()` para obtener el HID feature report del dispositivo. Esa llamada falla y devuelve `-ENODATA`. La inicialización del Quadro (offsets, ctrl_report_id, etc.) está correcta.

### Ubicaciones clave en el código

| Función | Línea | Propósito |
|---------|-------|-----------|
| `aqc_is_visible()` | ~1043-1086 | Gate de visibilidad de atributos PWM |
| `aqc_read_pwm()` | ~1459-1497 | Lectura de PWM (caso default para Quadro) |
| `aqc_write_pwm()` | ~1797-1866 | Escritura de PWM |
| `aqc_get_ctrl_data()` | ~881-896 | Obtención del control report vía HID — aquí falla |
| Quadro device setup | ~3099-3130 | Inicialización del Quadro (offsets, fan_ctrl, etc.) |
| `quadro_ctrl_fan_offsets` | ~312 | Offsets: `{ 0x36, 0x8b, 0xe0, 0x135 }` |

### Por qué liquidctl funciona y el driver no

liquidctl habla directamente por hidraw con su propio protocolo y timing. El driver del kernel usa `hid_hw_raw_request()` que en kernel 6.12 puede tener comportamiento diferente en el manejo de HID feature reports.

### Complejidad estimada: Moderada

El punto de fallo está localizado en una función concreta de ~15 líneas (`aqc_get_ctrl_data`). Posibles causas:

1. **Timing/sincronización** (más probable): Retry logic o ajustar delay del control report (200ms). Esfuerzo: 2-4h.
2. **Cambio en API HID del kernel 6.12**: Trazar changelog HID entre 6.4 y 6.12. Esfuerzo: 4-8h.
3. **Protocolo del dispositivo**: Implementar workaround similar a liquidctl. Esfuerzo: 6-12h.

### Siguiente paso propuesto

Parche de diagnóstico: añadir logs en `aqc_get_ctrl_data()` para ver qué error exacto devuelve `hid_hw_raw_request()`, y comparar con cómo liquidctl hace la misma petición.
<!-- SECTION:NOTES:END -->
