---
id: NAS-19
title: Crear módulo NixOS services.quadro-fans para control de ventiladores vía sysfs
status: To Do
assignee: []
created_date: '2026-03-23 08:27'
updated_date: '2026-03-23 08:35'
labels:
  - hardware
  - config
  - nixos
dependencies:
  - NAS-18
references:
  - hosts/nas/services/fans.nix
  - utilities/liquidctl.nix
  - hosts/nas/kernel-modules/aquacomputer-d5next.nix
documentation:
  - 'doc-4 - Hardware: Aqua Computer QUADRO - Controlador de ventiladores PWM'
priority: medium
ordinal: 1500
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Crear un módulo NixOS que permita configurar los 4 ventiladores del Aqua Computer QUADRO de forma declarativa. El módulo debe soportar dos modos de operación por fan: manual (porcentaje fijo) y curva de temperatura (programada en el firmware del QUADRO via sysfs).

API diseñada:

```nix
services.quadro-fans = {
  enable = true;
  fans = {
    fan1 = {
      mode = "curve";  # "manual" | "curve"
      curve = [
        { temp = 25; pwm = 30; }
        { temp = 30; pwm = 50; }
        { temp = 35; pwm = 80; }
        { temp = 40; pwm = 100; }
      ];
    };
    fan3 = {
      mode = "manual";
      percentage = 50;
    };
  };
};
```

Comportamiento:
- Temperaturas en °C, PWM en porcentaje (0-100). Se convierte internamente a milicelsius y 0-255.
- Curvas parciales: si se definen menos de 16 puntos, interpolar linealmente entre los dados. Los puntos por encima del último definido se capean al PWM del último punto.
- Fans no declarados: no se tocan (se dejan como estén).
- El servicio usa el symlink `/dev/quadro-hwmon` (creado por NAS-18) para encontrar el hwmon.
- Modo curva: escribe los 16 puntos en `temp1_auto_point{1-16}_{temp,pwm}` y pone `pwm_enable = 2`.
- Modo manual: escribe el PWM fijo en `pwmX` y pone `pwm_enable = 1`.

Reemplaza la configuración actual basada en liquidctl (`fans.nix` + `utilities/liquidctl.nix`) que solo soportaba porcentaje fijo y dependía de un timer de 30s.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 El módulo NixOS se puede importar y configurar con la API descrita
- [ ] #2 Modo manual: el fan se pone al porcentaje indicado (pwm_enable=1)
- [ ] #3 Modo curva: se programan los 16 puntos interpolados en sysfs y se activa pwm_enable=2
- [ ] #4 Curvas parciales se interpolan linealmente y se capean al último valor
- [ ] #5 Fans no declarados no se modifican
- [ ] #6 El servicio arranca después de que el symlink udev esté disponible
- [ ] #7 El servicio funciona tras reboot sin intervención manual
<!-- AC:END -->
