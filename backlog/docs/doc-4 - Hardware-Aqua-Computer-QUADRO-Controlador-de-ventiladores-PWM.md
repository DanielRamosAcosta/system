---
id: doc-4
title: 'Hardware: Aqua Computer QUADRO - Controlador de ventiladores PWM'
type: other
created_date: '2026-03-22 10:03'
updated_date: '2026-03-23 08:16'
---
# Aqua Computer QUADRO - Controlador de ventiladores PWM

## Propósito

Control PWM de los 4 canales de ventilador del NAS mediante USB.

## Identificación

| Campo | Valor |
|-------|-------|
| Dispositivo | Aqua Computer QUADRO |
| Vendor ID | `0c70` |
| Product ID | `f00d` |
| USB | Bus 003 Device 005 |
| HID device | `/dev/hidraw0` |
| Kernel driver | `aquacomputer_d5next` (out-of-tree, aleksamagicka) |
| hwmon | `/sys/class/hwmon/hwmon4` |
| Serial | 32533-07983 |

```
$ lsusb | grep QUADRO
Bus 003 Device 005: ID 0c70:f00d MCT Elektronikladen QUADRO
```

## Capacidades del hardware

- 4 salidas de ventilador PWM (conector 4-pin), 25W por canal
- 4 entradas de sensor de temperatura (solo temp1 conectado actualmente, ~22-23°C ambiente)
- 1 entrada de sensor de flujo (no conectado, marca 0 dL/h)
- 1 salida LED RGBpx (hasta 64 LEDs direccionables)
- Interfaz USB 2.0
- Interfaz aquabus (compatible con aquaero)
- Curvas de temperatura en firmware: 16 puntos por fan, ejecutadas autónomamente por el QUADRO

## Estado actual (2026-03-23)

### Driver del kernel

Se usa el driver **out-of-tree** de [aleksamagicka/aquacomputer_d5next-hwmon](https://github.com/aleksamagicka/aquacomputer_d5next-hwmon) (commit `9ae7fd5`), compilado como `extraModulePackage` en NixOS. Reemplaza al driver built-in del kernel 6.12.76 que no soporta PWM ni curvas.

| Funcionalidad | Estado | Vía |
|---------------|--------|-----|
| Lectura de sensores (RPM, temp, voltaje, corriente, potencia) | Funciona | sysfs (hwmon4) |
| Lectura PWM | Funciona | sysfs (`cat pwm1` → 0-255) |
| Escritura PWM | Funciona | sysfs (`echo 128 > pwm1`) |
| Curvas de temperatura (16 puntos) | Funciona | sysfs (`temp1_auto_point{1-16}_{temp,pwm}`) |
| Selector de sensor por fan | Disponible | sysfs (`pwm{1-4}_auto_channels_temp`) |
| Porcentaje fijo via liquidctl | Funciona | hidraw (acceso directo USB) |
| Curvas via liquidctl | No soportado | Limitación de liquidctl (issue #824) |

### Modos de operación (pwm_enable)

| Valor | Modo | Descripción |
|-------|------|-------------|
| 0 | Off | Ventilador apagado |
| 1 | Manual | PWM fijado por software (estado actual) |
| 2 | Auto | Curva de temperatura ejecutada por el firmware del QUADRO |

Actualmente los 4 fans están en modo 1 (manual).

### Sensores de temperatura

| Sensor | Ubicación | Estado |
|--------|-----------|--------|
| temp1 (QUADRO Sensor 1) | Interno al case | ~22-23°C, funciona |
| temp2-temp4 (QUADRO Sensor 2-4) | No conectados | N/A |
| coretemp (hwmon7) | CPU | ~38°C, funciona |
| it8613 (hwmon2) | Chipset motherboard | ~54°C, funciona |
| nvme (hwmon0, hwmon1) | SSDs NVMe | ~27°C, funciona |

Las curvas en hardware del QUADRO solo pueden usar los sensores del propio QUADRO (temp1-temp4). Para usar sensores del sistema (CPU, NVMe, etc.) haría falta un daemon como `fancontrol`, pero eso implica que si el daemon muere los fans se quedan al último PWM.

### Curva por defecto del firmware (fan1)

| Punto | Temp | PWM | ~% |
|-------|------|-----|-----|
| 1 | 27.0°C | 0 | 0% |
| 2 | 28.1°C | 4 | 2% |
| 3 | 28.9°C | 7 | 3% |
| 4 | 29.8°C | 13 | 5% |
| 5 | 30.6°C | 20 | 8% |
| 6 | 31.5°C | 31 | 12% |
| 7 | 32.3°C | 43 | 17% |
| 8 | 33.2°C | 58 | 23% |
| 9 | 34.0°C | 74 | 29% |
| 10 | 34.9°C | 93 | 36% |
| 11 | 35.7°C | 115 | 45% |
| 12 | 36.6°C | 138 | 54% |
| 13 | 37.4°C | 164 | 64% |
| 14 | 38.3°C | 192 | 75% |
| 15 | 39.1°C | 222 | 87% |
| 16 | 40.0°C | 255 | 100% |

Curva bastante agresiva — 100% a 40°C. Los puntos se pueden reprogramar vía sysfs.

### Lecturas actuales de sensores (2026-03-23)

```
Aquacomputer Quadro
├── Sensor 1          22.8  °C
├── Fan 1 speed       5462  rpm    pwm1: 153 (~60%)
├── Fan 1 power       0.19  W
├── Fan 1 voltage    12.16  V
├── Fan 2 speed       4793  rpm    pwm2: 153 (~60%)
├── Fan 2 power       0.13  W
├── Fan 2 voltage    12.16  V
├── Fan 3 speed       1192  rpm    pwm3: 128 (~50%)
├── Fan 3 power       0.38  W
├── Fan 3 voltage    12.16  V
├── Fan 4 speed       1133  rpm    pwm4: 128 (~50%)
├── Fan 4 power       0.42  W
├── Fan 4 voltage    12.16  V
└── Flow sensor          0  dL/h
```

## Configuración NixOS

### Archivos relevantes

| Archivo | Propósito |
|---------|-----------|
| `hosts/nas/kernel-modules/aquacomputer-d5next.nix` | Paquete nix del driver out-of-tree |
| `hosts/nas/kernel-modules/default.nix` | Carga el driver como extraModulePackage |
| `hosts/nas/services/fans.nix` | Configuración de ventiladores (actualmente deshabilitada) |
| `utilities/liquidctl.nix` | Módulo NixOS genérico para liquidctl |
| `hosts/nas/base.nix` | Incluye `liquidctl` en systemPackages |

### Driver out-of-tree

Definido en `hosts/nas/kernel-modules/aquacomputer-d5next.nix`, compilado desde el repo de aleksamagicka (commit `9ae7fd5`). Se añade a `boot.extraModulePackages` y reemplaza automáticamente al driver built-in del kernel (NixOS coloca los extraModulePackages en `updates/` con prioridad).

## Cómo obtener información

### Ver sensores por sysfs (hwmon)

```bash
ssh nas "cat /sys/class/hwmon/hwmon4/name"          # "quadro"
ssh nas "cat /sys/class/hwmon/hwmon4/fan1_input"     # RPM
ssh nas "cat /sys/class/hwmon/hwmon4/temp1_input"    # Temperatura (milicelsius)
ssh nas "cat /sys/class/hwmon/hwmon4/pwm1"           # PWM (0-255)
ssh nas "cat /sys/class/hwmon/hwmon4/pwm1_enable"    # 0=off, 1=manual, 2=auto
```

### Ver/modificar curva de temperatura

```bash
ssh nas "cat /sys/class/hwmon/hwmon4/temp1_auto_point1_temp"   # milicelsius
ssh nas "cat /sys/class/hwmon/hwmon4/temp1_auto_point1_pwm"    # 0-255
ssh nas "sudo sh -c 'echo 25000 > /sys/class/hwmon/hwmon4/temp1_auto_point1_temp'"
ssh nas "sudo sh -c 'echo 50 > /sys/class/hwmon/hwmon4/temp1_auto_point1_pwm'"
```

### Ver estado de liquidctl (requiere root)

```bash
ssh nas "sudo liquidctl status"
```

### Listar dispositivos USB

```bash
ssh nas "lsusb"
```

## Issues upstream

### aquacomputer_d5next-hwmon#108 — PWM vía sysfs roto en kernel built-in 6.12

- **Repo**: https://github.com/aleksamagicka/aquacomputer_d5next-hwmon/issues/108
- **Estado**: Abierto (pero resuelto para nosotros usando el driver out-of-tree)
- **Problema**: El driver built-in del kernel 6.12 no soporta PWM. `aqc_get_ctrl_data()` falla con `-ENODATA` al hacer `hid_hw_raw_request()`.
- **Nuestra solución**: Usar el driver out-of-tree como `extraModulePackage`, que sí tiene soporte completo de PWM y curvas.

### liquidctl#824 — Curvas de temperatura no soportadas

- **Repo**: https://github.com/liquidctl/liquidctl/issues/824
- **Estado**: Abierto
- **Problema**: liquidctl no implementa `set_speed_profile` para QUADRO. Solo porcentaje fijo funciona.
- **Impacto**: No afecta — podemos configurar curvas directamente vía sysfs con el driver out-of-tree.

## Notas

- `liquidctl status` sin sudo falla por permisos en `/dev/hidraw0` (permisos `crw-------` root:root)
- El sensor de flujo marca 0 dL/h (no hay sensor de flujo conectado)
- El hwmon del QUADRO es `hwmon4` (puede cambiar entre reboots dependiendo del orden de carga de drivers)
- Las curvas programadas en el firmware del QUADRO se ejecutan autónomamente — si el OS se cuelga, el QUADRO sigue controlando los fans según la curva
