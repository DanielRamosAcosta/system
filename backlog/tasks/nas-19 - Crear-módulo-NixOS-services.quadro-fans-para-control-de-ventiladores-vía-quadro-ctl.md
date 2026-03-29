---
id: NAS-19
title: >-
  Crear módulo NixOS services.quadro-fans para control de ventiladores vía
  quadro-ctl
status: Done
assignee: []
created_date: '2026-03-23 08:27'
updated_date: '2026-03-29 13:28'
labels:
  - hardware
  - config
  - nixos
dependencies: []
references:
  - hosts/nas/services/fans.nix
  - utilities/liquidctl.nix
  - hosts/nas/kernel-modules/aquacomputer-d5next.nix
  - 'https://github.com/DanielRamosAcosta/quadro-ctl'
documentation:
  - 'doc-4 - Hardware: Aqua Computer QUADRO - Controlador de ventiladores PWM'
priority: medium
ordinal: 125
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Crear un módulo NixOS que permita configurar los 4 ventiladores del Aqua Computer QUADRO de forma declarativa. El módulo soporta dos modos de operación por fan: manual (porcentaje fijo) y curva de temperatura (programada en el firmware del QUADRO). El modo se infiere automáticamente del campo definido (`percentage` o `curve`).

El módulo usa `quadro-ctl` (https://github.com/DanielRamosAcosta/quadro-ctl) como backend para comunicarse con el QUADRO via hidraw (`/dev/hidraw*`), en lugar de sysfs.

API diseñada:

```nix
services.quadro-fans = {
  enable = true;
  fans = {
    fan1 = {
      sensor = 1;
      curve = [
        { temp = 25; speedPercentage = 30; }
        { temp = 30; speedPercentage = 50; }
        { temp = 35; speedPercentage = 80; }
        { temp = 40; speedPercentage = 100; }
      ];
    };
    fan3 = {
      percentage = 50;
    };
  };
};
```

Campos por fan (todos con tipos estrictos NixOS — valores fuera de rango fallan en `nixos-rebuild`):
- `percentage` (`types.ints.between 0 100`): porcentaje fijo. Mutuamente exclusivo con `curve`.
- `curve` (list of {temp, speedPercentage}): curva de temperatura. Mutuamente exclusivo con `percentage`.
  - `temp`: `types.ints.between 0 100` — temperatura en °C.
  - `speedPercentage`: `types.ints.between 0 100` — velocidad del fan en porcentaje.
- `sensor` (`types.ints.between 1 4`, default: 1): sensor de temperatura del QUADRO que gobierna la curva de este fan. Solo aplica en modo curva. **Un solo sensor por fan** — el driver solo acepta un sensor individual, no combinaciones (verificado en código fuente y en vivo: bitmask combinado → `-EINVAL`). **Limitación: solo soporta sensores físicos (1-4) por ahora.** Ver DRAFT-1 para el plan de soporte de sensores virtuales a futuro.

Validaciones adicionales via `assertions`:
- Cada fan debe tener exactamente uno de `percentage` o `curve`, no ambos ni ninguno.
- Los puntos de `curve` deben estar ordenados por `temp` ascendente (mínimo 2 puntos).

Comportamiento:
- Temperaturas en °C, velocidad en porcentaje (0-100). `quadro-ctl` se encarga de las conversiones internas al formato del firmware.
- **Interpolación en tiempo de evaluación (Nix puro)**: si se definen menos de 16 puntos, las funciones de interpolación lineal se ejecutan en Nix durante `nix build`/`nixos-rebuild`. El script bash resultante invoca `quadro-ctl` con los 16 puntos ya calculados.
- **Distribución de los 16 puntos**: se generan 16 temperaturas equidistantes entre la temp mínima y máxima de la curva del usuario, con speedPercentage interpolado linealmente entre los puntos dados. Esto aprovecha la resolución completa del hardware.
- **Comportamiento en los extremos**: el firmware del QUADRO capea a los valores del primer y último punto. Por debajo de la temp del punto 1 del usuario → se mantiene su speedPercentage (el fan nunca se apaga inesperadamente). Por encima de la temp del último punto → se mantiene su speedPercentage.
  - Ejemplo: input `[{25°C→30%}, {35°C→80%}, {40°C→100%}]` → 16 puntos equidistantes de 25°C a 40°C (cada 1°C), con % interpolado. A 20°C el fan está al 30%. A 45°C está al 100%.
- **Tests de interpolación**: las funciones puras de interpolación (`interpolateCurve`, conversión de unidades) se testean en `utilities/utilities.test.nix` con `lib.runTests`.
- **Fans no declarados**: no se tocan. **Decisión**: se valoró añadir un campo `resetUndeclared = true` que pondría los fans no declarados en modo manual al 50%. Se descartó porque somos los únicos consumidores del módulo y siempre declararemos los 4 fans — la complejidad extra no se justifica.
- **Curvas son per-fan**: cada fan tiene su propia curva de 16 puntos en el firmware del QUADRO. Verificado en el código fuente del driver y confirmado en vivo en el NAS (2026-03-23).

### Backend: quadro-ctl via hidraw (decisión arquitectural)

**Decisión**: se descartó sysfs como vía de escritura y se adoptó `quadro-ctl` (Rust CLI) que habla directamente con el QUADRO via hidraw.

**Por qué no sysfs**: cada operación sysfs (lectura o escritura) hace un round-trip USB completo al firmware (`aqc_get_ctrl_data` + `aqc_send_ctrl_data`), con un delay obligatorio de ~8.7 segundos por operación (medido en vivo, 2026-03-23: 16 lecturas = 2min 17s). Para configurar 4 fans con curvas (~130 operaciones), sysfs tardaría ~20 minutos. Esto es porque el driver expone `aqc_set_ctrl_val()` (singular, 1 valor por round-trip) via sysfs, no `aqc_set_ctrl_vals()` (plural, N valores en 1 round-trip) que solo está disponible internamente en el kernel.

**Por qué hidraw**: `quadro-ctl` lee el control report completo del firmware (1 USB read), modifica todos los valores en memoria (instantáneo), y escribe el buffer completo de vuelta (1 USB write). Total: ~18 segundos para configurar **todos** los fans, sin importar cuántos valores cambien.

**Sin udev rule**: con `quadro-ctl` y `Restart=on-failure`, no hace falta una regla udev para ordenar el arranque. Si el QUADRO no está listo, `quadro-ctl` falla, systemd reintenta en 5s. El QUADRO siempre está conectado (es un NAS), no necesitamos hotplug. **Decisión**: se implementó y validó una udev rule con `TAG+="systemd"`, `SYSTEMD_ALIAS` y `SYSTEMD_WANTS` (2026-03-23), pero se descartó a favor de la simplicidad de `Restart=on-failure`.

**Sin driver out-of-tree**: al no depender de sysfs para escrituras, ya no necesitamos el driver `aquacomputer_d5next` out-of-tree (que se usaba porque el mainline tiene roto PWM via sysfs, issue #108). Se puede usar el driver mainline del kernel para lecturas de sensores (monitoring).

**Alternativas consideradas y descartadas:**
- **Fork del driver para añadir bulk write sysfs**: el driver tiene `aqc_set_ctrl_vals()` (plural) internamente que agrupa N escrituras en 1 round-trip, pero es `static` y solo accesible desde kernel. Se podría exponer via un nuevo archivo sysfs. Se descartó porque: mantener un fork de un módulo kernel C es costoso (rebases con upstream, riesgo de kernel panic), y hidraw logra lo mismo desde userspace de forma más segura.
- **Escrituras condicionales (leer antes de escribir via sysfs)**: se descartó porque leer cuesta lo mismo que escribir (~8.7s/op) — duplica el tiempo en vez de ahorrarlo.
- **liquidctl para escritura batch**: no soporta curvas en el QUADRO (issue #824).

### Investigación sysfs preservada (referencia)

La siguiente investigación se realizó sobre el driver out-of-tree `aquacomputer_d5next` (2026-03-23). Aunque ya no usamos sysfs para escrituras, se preserva como referencia:

- **Nomenclatura no estándar de curvas sysfs**: el driver usa `tempN_auto_point{1-16}_{temp,pwm}` (prefijo `temp`, donde N = fan) en lugar del estándar hwmon `pwmN_auto_point`. El selector de sensor sí usa el estándar `pwmN_auto_channels_temp`. Verificado en código fuente y en vivo (128 entries = 4×16×2).
- **Nombre hwmon**: `name` = `quadro` (no `aquacomputer_d5next`). Verificado en vivo.
- **Atomicidad de escrituras sysfs**: cada `echo` invoca `aqc_set_ctrl_val()` con mutex + read-modify-write atómico via USB. No hay curva corrupta.
- **Sin race condition udev/sysfs**: `hwmon_device_register_with_info()` crea todos los atributos atómicamente antes del evento udev.
- **Sin transición a manual para curvas**: se valoró pasar a manual antes de reprogramar curvas, pero se descartó porque (1) cada escritura es atómica, (2) los puntos interpolados son valores cercanos, (3) pasar a manual es peor térmicamente.

## Plan de ejecución por fases

### Fase 1: Módulo NixOS + modo manual
Crear el módulo NixOS completo e implementar modo manual via `quadro-ctl`.

**Implementar:**
- Módulo NixOS con options (`fans`, `enable`), types estrictos, assertions (percentage/curve mutuamente exclusivos, curva ordenada con mínimo 2 puntos)
- Servicio systemd con `wantedBy = ["multi-user.target"]`, `Restart=on-failure`, `RestartSec=5`
- Script bash que invoca `quadro-ctl` para configurar fans en modo manual
- `quadro-ctl` busca el QUADRO por vendor/product ID (`0c70:f00d`), no por path hardcodeado

**Deploy:** `./scripts/inside-devcontainer.sh just deploy-nas`
**Verificar:**
```bash
ssh nas "systemctl status quadro-fans"
ssh nas "sudo quadro-ctl status"  # verificar PWM aplicado
```

**Justificación:** Valida el pipeline completo módulo → systemd → quadro-ctl → firmware.

### Fase 2: Funciones de interpolación + tests
Funciones puras en Nix para generar los 16 puntos de curva.

**Implementar:**
- `interpolateCurve`: recibe lista de puntos del usuario, genera 16 puntos equidistantes con % interpolado
- Conversión de unidades según lo que espere `quadro-ctl`
- Tests en `utilities/utilities.test.nix` con `lib.runTests`

**Verificar (sin deploy):** `./scripts/inside-devcontainer.sh just test`

**Justificación:** Código puro sin side effects — se testea en el dev container sin tocar el NAS.

### Fase 3: Modo curva + sensor
Integrar las funciones de interpolación y añadir modo curva.

**Implementar:**
- Nix genera los argumentos de `quadro-ctl` con los 16 puntos ya interpolados
- Selector de sensor por fan
- Configurar un fan real en curva para validar

**Deploy:** `./scripts/inside-devcontainer.sh just deploy-nas`
**Verificar:**
```bash
ssh nas "systemctl status quadro-fans"
ssh nas "sudo quadro-ctl status"  # verificar curva y sensor aplicados
```

**Justificación:** Al llegar aquí ya sabemos que el servicio arranca y quadro-ctl comunica con el QUADRO (fase 1). Solo añadimos la lógica de curva.

### Fase 4: Limpieza
Eliminar el sistema antiguo y el driver out-of-tree.

**Implementar:**
- Eliminar `utilities/liquidctl.nix`
- Limpiar `hosts/nas/services/fans.nix` (reemplazar contenido comentado por la config real de quadro-fans)
- Quitar `liquidctl` de `systemPackages`
- Eliminar `hosts/nas/kernel-modules/aquacomputer-d5next.nix` y su referencia en `hosts/nas/kernel-modules/default.nix`
- Verificar que el driver mainline sigue proporcionando lecturas de sensores

**Deploy:** `./scripts/inside-devcontainer.sh just deploy-nas`
**Verificar:**
```bash
ssh nas "systemctl status quadro-fans"    # sigue funcionando
ssh nas "systemctl status liquidctl"       # no existe
ssh nas "cat /sys/class/hwmon/*/name"      # quadro sigue apareciendo (mainline)
ssh nas "sensors"                          # lecturas de sensores funcionan
```

**Justificación:** Se limpia al final cuando todo funciona. Si algo sale mal, el rollback es trivial.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
**Fase 1: Módulo NixOS + modo manual**
- [ ] #1 El módulo NixOS se puede importar y configurar con la API descrita (percentage o curve, mutuamente exclusivos, tipos estrictos)
- [ ] #2 Modo manual: el fan se pone al porcentaje indicado via quadro-ctl
- [ ] #3 El servicio systemd usa Restart=on-failure con RestartSec=5
- [ ] #4 quadro-ctl encuentra el QUADRO por vendor/product ID

**Fase 2: Interpolación + tests**
- [ ] #5 La interpolación de curvas parciales se calcula en Nix puro (tiempo de evaluación)
- [ ] #6 Las funciones de interpolación y conversión tienen tests en utilities.test.nix

**Fase 3: Modo curva + sensor**
- [ ] #7 Modo curva: se programan los 16 puntos interpolados via quadro-ctl y se activa modo curva en el firmware
- [ ] #8 El campo sensor asigna el sensor de temperatura del QUADRO al fan

**Fase 4: Limpieza**
- [ ] #9 Se elimina utilities/liquidctl.nix, fans.nix viejo, y driver out-of-tree
- [ ] #10 El driver mainline proporciona lecturas de sensores (monitoring)
- [ ] #11 El servicio funciona tras reboot sin intervención manual
<!-- AC:END -->
