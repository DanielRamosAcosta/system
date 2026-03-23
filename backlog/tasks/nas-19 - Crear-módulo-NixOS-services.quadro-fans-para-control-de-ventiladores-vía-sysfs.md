---
id: NAS-19
title: Crear módulo NixOS services.quadro-fans para control de ventiladores vía sysfs
status: In Progress
assignee: []
created_date: '2026-03-23 08:27'
updated_date: '2026-03-23 09:30'
labels:
  - hardware
  - config
  - nixos
dependencies: []
references:
  - hosts/nas/services/fans.nix
  - utilities/liquidctl.nix
  - hosts/nas/kernel-modules/aquacomputer-d5next.nix
documentation:
  - 'doc-4 - Hardware: Aqua Computer QUADRO - Controlador de ventiladores PWM'
priority: medium
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Crear un módulo NixOS que permita configurar los 4 ventiladores del Aqua Computer QUADRO de forma declarativa. El módulo soporta dos modos de operación por fan: manual (porcentaje fijo) y curva de temperatura (programada en el firmware del QUADRO via sysfs). El modo se infiere automáticamente del campo definido (`percentage` o `curve`).

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
- `sensor` (`types.ints.between 1 4`, default: 1): sensor de temperatura del QUADRO que gobierna la curva de este fan. Solo aplica en modo curva. Nix convierte el valor a bitmask (`1 << (sensor - 1)`) y lo escribe en `pwmX_auto_channels_temp`. **Un solo sensor por fan** — aunque `auto_channels_temp` es un bitmask en el estándar hwmon (permitiría multi-sensor), el driver out-of-tree solo acepta potencias de 2 individuales (1, 2, 4, 8) y rechaza combinaciones con `-EINVAL` (verificado en código fuente, líneas 1868-1884: `switch(val)` sin caso para valores combinados, y confirmado en vivo: `echo 3 > pwm1_auto_channels_temp` → `write error: Invalid argument`). Por esto la API usa un entero único, no una lista. **Limitación: solo soporta sensores físicos (1-4) por ahora.** El QUADRO también soporta sensores virtuales (temperaturas inyectadas vía USB desde el SO, ej. CPU/GPU/discos), expuestos como temp5-20 en sysfs. Actualmente el driver los expone read-only — requiere un patch upstream para habilitar escritura. Ver DRAFT-1 para el plan de soporte de sensores virtuales a futuro.

Validaciones adicionales via `assertions`:
- Cada fan debe tener exactamente uno de `percentage` o `curve`, no ambos ni ninguno.
- Los puntos de `curve` deben estar ordenados por `temp` ascendente (mínimo 2 puntos).

Comportamiento:
- Temperaturas en °C, velocidad en porcentaje (0-100). Se convierte internamente a milicelsius y 0-255.
- **Interpolación en tiempo de evaluación (Nix puro)**: si se definen menos de 16 puntos, las funciones de interpolación lineal se ejecutan en Nix durante `nix build`/`nixos-rebuild`, no en bash. El script bash resultante contiene solo 16 `echo` planos por fan.
- **Distribución de los 16 puntos**: se generan 16 temperaturas equidistantes entre la temp mínima y máxima de la curva del usuario, con speedPercentage interpolado linealmente entre los puntos dados. Esto aprovecha la resolución completa del hardware.
- **Comportamiento en los extremos**: el firmware del QUADRO capea a los valores del primer y último punto. Por debajo de la temp del punto 1 del usuario → se mantiene su speedPercentage (el fan nunca se apaga inesperadamente). Por encima de la temp del último punto → se mantiene su speedPercentage.
  - Ejemplo: input `[{25°C→30%}, {35°C→80%}, {40°C→100%}]` → 16 puntos equidistantes de 25°C a 40°C (cada 1°C), con % interpolado. A 20°C el fan está al 30%. A 45°C está al 100%.
- **Tests de interpolación**: las funciones puras de interpolación (`interpolateCurve`, conversión °C→milicelsius, %→0-255) se testean en `utilities/utilities.test.nix` con `lib.runTests`.
- **Fans no declarados**: no se tocan. **Decisión**: se valoró añadir un campo `resetUndeclared = true` que pondría los fans no declarados en modo manual al 50% (para evitar estado huérfano en el firmware del QUADRO si se borra un fan de la config). Se descartó porque somos los únicos consumidores del módulo y siempre declararemos los 4 fans — la complejidad extra no se justifica.
- **Ordenamiento de arranque via udev + systemd device unit**: el módulo crea una regla udev `SUBSYSTEM=="hwmon", ATTR{name}=="quadro", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/sys/devices/quadro-fans", ENV{SYSTEMD_WANTS}="quadro-fans.service"`. Esto genera una device unit estable (`sys-devices-quadro\x2dfans.device`) y arranca el servicio automáticamente al detectar el QUADRO (tanto en boot como en hotplug USB). El servicio systemd usa `bindsTo` + `after` sobre esta unit — si el USB se desconecta, el servicio se para; al reconectar, se rearranca. Validado en el NAS (2026-03-23). **Nota: `WantedBy=` no funciona con device units dinámicas** (no hay directorio `.wants` para units que no existen en disco), por eso se usa `SYSTEMD_WANTS` en la udev rule. **No hay race condition entre udev y atributos sysfs**: verificado en el código fuente del driver — `hwmon_device_register_with_info()` (línea 3353) recibe todos los attribute groups (pwm, curvas, etc.) y los crea atómicamente antes de emitir el evento udev. No se necesita retry loop en bash.
- **Resolución dinámica de hwmon**: el script bash sigue resolviendo el path concreto al arrancar con `grep -l "quadro" /sys/class/hwmon/hwmon*/name | xargs dirname` (el SYSTEMD_ALIAS garantiza que existe, pero no da el path sysfs real).
- **Curvas son per-fan**: cada fan tiene su propia curva de 16 puntos en el firmware. Los paths sysfs son `tempN_auto_point{1-16}_{temp,pwm}` donde N es el número de fan (no de sensor). **Nota: nomenclatura no estándar** — el estándar hwmon del kernel usa `pwmN_auto_point` (prefijo `pwm`), pero el driver out-of-tree `aquacomputer_d5next` usa `tempN_auto_point` (prefijo `temp`). Sin embargo, el selector de sensor sí usa el prefijo estándar `pwmN_auto_channels_temp`. Verificado en el código fuente del driver y confirmado en vivo en el NAS (2026-03-23): 128 entries `tempN_auto_point` (4×16×2) + 4 entries `pwmN_auto_channels_temp`.
- **Nombre del dispositivo hwmon**: el driver expone `name` = `quadro` (no `aquacomputer_d5next` ni otra variante). Confirmado en vivo: `cat /sys/class/hwmon/hwmon4/name` → `quadro`. La regla udev `ATTR{name}=="quadro"` es correcta.
- **Atomicidad de escrituras sysfs**: cada `echo` a un archivo sysfs del driver invoca `aqc_set_ctrl_val()`, que internamente hace un ciclo read-modify-write atómico protegido por mutex: (1) `mutex_lock`, (2) `aqc_get_ctrl_data` lee todo el control buffer del firmware via USB, (3) `aqc_set_buffer_val` modifica un valor en el buffer local, (4) `aqc_send_ctrl_data` envía todo el buffer de vuelta al firmware via USB, (5) `mutex_unlock`. Cada punto se escribe atómicamente al firmware — no hay estado parcial ni curva corrupta. Verificado en el código fuente del driver (líneas 983-1010).
- **Escrituras condicionales (skip si no hay cambios)**: cada escritura sysfs hace un round-trip USB completo al firmware. Para evitar escrituras innecesarias (ej. reboot con misma config), el script bash lee el valor actual de cada atributo antes de escribir y solo escribe si difiere del valor deseado. Si todo es igual, no se escribe nada.
- **Sin transición a manual para curvas**: los puntos se escriben directamente mientras el fan sigue en modo curva. **Decisión**: se valoró pasar a manual antes de reprogramar (para evitar que el firmware ejecute una curva "mix" durante la escritura), pero se descartó porque: (1) cada escritura es atómica (mutex + round-trip USB), (2) los puntos interpolados son valores cercanos entre sí — el mix temporal es imperceptible, (3) pasar a manual es **peor** térmicamente — el fan deja de responder a la temperatura durante la transición. Orden de escrituras para modo curva: puntos de curva que difieren → sensor si difiere → `pwmN_enable = 2` al final (si no estaba ya en curva).
- **Modo manual**: lee el valor actual de `pwmN` y `pwmN_enable`, solo escribe si difieren.
- **El script bash usa `set -euo pipefail`**: si cualquier escritura falla, se aborta. El fan se queda en modo manual con su PWM de transición (seguro a corto plazo, pero sin protección térmica).
- **Restart=on-failure en systemd**: si el script falla (exit por `set -e`), systemd reintenta automáticamente. Esto es crítico para la transición segura — si el script aborta con un fan en modo manual estático, el reintento completa la transición y devuelve el fan a modo curva. Se configura con `RestartSec=5` y rate limit por defecto de systemd para evitar loops infinitos.
- **Retry en primera operación sysfs**: aunque el driver valida la comunicación USB durante el probe (`hid_hw_start` + `hid_hw_open`) antes de registrar hwmon, no se puede descartar al 100% que el firmware del QUADRO necesite unos milisegundos extra para estar listo tras el probe. El script hace un pequeño retry con timeout en la primera lectura sysfs (`until cat pwm1_enable; do sleep 0.2; done` con límite de 5 intentos) como safety net. Si falla tras los reintentos, el script aborta por `set -e` y systemd reintenta el servicio.

Reemplaza la configuración actual basada en liquidctl (`fans.nix` + `utilities/liquidctl.nix`) que solo soportaba porcentaje fijo y dependía de un timer de 30s.

## Plan de ejecución por fases

### Fase 1: Udev rule (cimiento)
Crear la regla udev que genera la device unit estable y dispara el arranque del servicio.

**Implementar:**
- Añadir `services.udev.extraRules` con la regla completa: `SUBSYSTEM=="hwmon", ATTR{name}=="quadro", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/sys/devices/quadro-fans", ENV{SYSTEMD_WANTS}="quadro-fans.service"`
- `TAG+="systemd"` + `SYSTEMD_ALIAS` → device unit estable
- `SYSTEMD_WANTS` → auto-arranque del servicio (boot + hotplug USB)

**Deploy:** `./scripts/inside-devcontainer.sh just deploy-nas`
**Verificar:**
```bash
ssh nas "systemctl status sys-devices-quadro\\\\x2dfans.device"
```

**Justificación:** Es independiente de todo lo demás y es el cimiento sobre el que el servicio se va a ordenar. Si falla, lo detectamos antes de escribir el módulo.

### Fase 2: Módulo skeleton + modo manual
Crear el módulo NixOS completo (options, types, assertions) e implementar modo manual con el script bash base.

**Implementar:**
- Módulo NixOS con options (`fans`, `enable`), types estrictos, assertions (percentage/curve mutuamente exclusivos, curva ordenada con mínimo 2 puntos)
- Servicio systemd con `bindsTo` + `after` sobre `sys-devices-quadro\x2dfans.device`, `Restart=on-failure`, `RestartSec=5`
- Script bash con:
  - `set -euo pipefail`
  - Resolución dinámica de hwmon (`grep -l "quadro" /sys/class/hwmon/hwmon*/name | xargs dirname`)
  - Retry en primera operación sysfs (hasta 5 intentos con sleep 0.2, safety net)
  - Escrituras condicionales: lee valor actual, solo escribe si difiere
  - Modo manual: escribe `pwmN` y `pwmN_enable=1` solo si necesario
- Configurar un fan real en manual para validar

**Deploy:** `./scripts/inside-devcontainer.sh just deploy-nas`
**Verificar:**
```bash
ssh nas "cat /sys/class/hwmon/hwmon4/pwm3"          # valor esperado
ssh nas "cat /sys/class/hwmon/hwmon4/pwm3_enable"    # 1
ssh nas "systemctl status quadro-fans"
```

**Justificación:** Valida el pipeline completo módulo → systemd → sysfs sin la complejidad de curvas. Si el `bindsTo`, la resolución de hwmon o las escrituras condicionales fallan, lo vemos aquí.

### Fase 3: Funciones de interpolación + tests
Funciones puras en Nix para generar los 16 puntos de curva.

**Implementar:**
- `interpolateCurve`: recibe lista de puntos del usuario, genera 16 puntos equidistantes con % interpolado
- Conversión °C → milicelsius, % → 0-255
- Tests en `utilities/utilities.test.nix` con `lib.runTests`

**Verificar (sin deploy):** `./scripts/inside-devcontainer.sh just test`

**Justificación:** Código puro sin side effects — se testea en el dev container sin tocar el NAS. Si la interpolación tiene bugs, los cazamos aquí antes de escribir en sysfs.

### Fase 4: Modo curva + sensor
Integrar las funciones de interpolación en el módulo y añadir modo curva.

**Implementar:**
- Nix genera los 16 `echo` planos por fan usando `interpolateCurve`
- Conversión de `sensor` a bitmask (`1 << (sensor - 1)`) en Nix
- Escribir directamente los puntos de curva que difieren (sin pasar por manual)
- Asignar sensor (`pwmN_auto_channels_temp`) si difiere
- Activar `pwmN_enable = 2` al final (si no estaba ya en curva)
- Configurar un fan real en curva para validar

**Deploy:** `./scripts/inside-devcontainer.sh just deploy-nas`
**Verificar:**
```bash
ssh nas "for i in \$(seq 1 16); do echo \"point \$i: temp=\$(cat /sys/class/hwmon/hwmon4/temp1_auto_point\${i}_temp) pwm=\$(cat /sys/class/hwmon/hwmon4/temp1_auto_point\${i}_pwm)\"; done"
ssh nas "cat /sys/class/hwmon/hwmon4/pwm1_enable"              # 2
ssh nas "cat /sys/class/hwmon/hwmon4/pwm1_auto_channels_temp"  # bitmask
```

**Justificación:** La parte más compleja. Al llegar aquí ya sabemos que el servicio arranca, encuentra el hwmon, y escribe en sysfs (fase 2). Solo añadimos la lógica de curva.

### Fase 5: Limpieza
Eliminar el sistema antiguo basado en liquidctl.

**Implementar:**
- Eliminar `utilities/liquidctl.nix`
- Limpiar `hosts/nas/services/fans.nix` (reemplazar contenido comentado por la config real de quadro-fans)
- Quitar `liquidctl` de `systemPackages` si ya no se usa

**Deploy:** `./scripts/inside-devcontainer.sh just deploy-nas`
**Verificar:**
```bash
ssh nas "systemctl status quadro-fans"    # sigue funcionando
ssh nas "systemctl status liquidctl"       # no existe
```

**Justificación:** Se limpia al final cuando todo funciona. Si algo sale mal, el rollback es trivial.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
**Fase 1: Udev rule**
- [ ] #1 Regla udev con TAG+="systemd", SYSTEMD_ALIAS y SYSTEMD_WANTS genera device unit estable y auto-arranca el servicio

**Fase 2: Módulo skeleton + modo manual**
- [ ] #2 El módulo NixOS se puede importar y configurar con la API descrita (percentage o curve, mutuamente exclusivos, tipos estrictos con `types.ints.between`)
- [ ] #3 Modo manual: el fan se pone al porcentaje indicado (pwmN_enable=1, pwmN=valor)
- [ ] #4 El servicio usa bindsTo + after sobre la device unit (sin race condition en arranque)
- [ ] #5 El servicio resuelve dinámicamente el directorio hwmon del QUADRO al arrancar
- [ ] #6 El script bash usa `set -euo pipefail` y retry en primera operación sysfs
- [ ] #7 Escrituras condicionales: no escribe si el valor actual ya es el deseado
- [ ] #8 El servicio systemd usa Restart=on-failure con RestartSec=5 para recuperarse de fallos

**Fase 3: Interpolación + tests**
- [ ] #9 La interpolación de curvas parciales se calcula en Nix puro (tiempo de evaluación), no en bash
- [ ] #10 Las funciones de interpolación y conversión tienen tests en utilities.test.nix

**Fase 4: Modo curva + sensor**
- [ ] #11 Modo curva: se programan los 16 puntos interpolados en sysfs (tempN_auto_point{1-16}_{temp,pwm}) y se activa pwmN_enable=2
- [ ] #12 El campo sensor asigna el sensor de temperatura del QUADRO al fan via pwmN_auto_channels_temp (bitmask)

**Fase 5: Limpieza**
- [ ] #13 Se elimina utilities/liquidctl.nix y se limpia fans.nix
- [ ] #14 El servicio funciona tras reboot sin intervención manual
<!-- AC:END -->
