---
id: NAS-36
title: 'workhorse: el mando Steam se apaga ~2-3s tras despertar de suspensión S3'
status: Done
assignee: []
created_date: '2026-10-16 20:27'
labels: []
dependencies: []
references:
  - 'https://github.com/ValveSoftware/SteamOS/issues/2906'
  - 'https://github.com/ValveSoftware/steam-for-linux/issues/13631'
  - 'https://steamcontroller.tools/'
priority: low
type: bug
ordinal: 17000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Al encender el Steam Controller para sacar a workhorse de suspensión, el PC despierta correctamente pero el mando se apaga solo ~2-3 segundos después, obligando a volver a pulsar el botón Steam (re-empareja en ~2s). Sucede en cada resume desde S3 (deep). Investigado el 2026-10-16; se decide convivir con el bug manteniendo S3 (suspensión profunda real), porque la única alternativa viable rompe la suspensión profunda.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 El mando sobrevive encendido tras despertar el PC desde suspensión sin re-pulsar (NO cumplido: aceptado como limitación conocida)
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
CAUSA RAÍZ (confirmada por el issue de Valve SteamOS#2906, nuestro caso exacto): al salir de S3, el controlador xHCI pierde alimentación y se reinicia (`xHC error in resume, USBSTS 0x401, Reinit` → `root hub lost power or was reset` → `usb 1-3: reset`, dongle Valve 28de:1142). Eso rompe la comunicación HID con el mando; Steam intenta leer el Chip ID del mando, falla, y Steam manda deliberadamente un power-off (`Failed to ever get Chip ID - shutting down`, steam-for-linux#13631). No hay traza de power-off en kernel ni en controller.txt porque lo decide Steam userspace. El mando ya tiene firmware BLE 2018 (FWTimestamp 0x5B0F21BD) y aun así obedece el power-off en el caso S3-resume.

A/B verificado en vivo el 2026-10-16 (rtcwake + suspend manual despertando con el mando):
- S3 (deep): hay reset USB → mando se apaga a ~3s. BUG.
- s2idle: NO hay reset USB → el mando sobrevive encendido. SIN BUG. Pero s2idle no es suspensión real: ventiladores/RGB siguen encendidos, no parpadea el LED de power, más consumo; además en este AMD la primera vez se comportó como colgado.

Workarounds descartados (probados en SteamOS#2906): cambiar de puerto USB, desactivar USB autosuspend, desactivar PCI power management, ajustes de BIOS (xHCI hand-off, legacy USB). El firmware BLE (steam-for-linux#13631) tampoco sirve aquí: el mando ya lo tiene. El único workaround confirmado para el caso S3 es s2idle (mem_sleep_default=s2idle).

DECISIÓN del usuario: mantener S3 y convivir con el bug (volver a pulsar el botón Steam tras despertar). No se toca la config; nada commiteado para el bug 2. Si algún día molesta lo suficiente, el cambio sería boot.kernelParams = [ "mem_sleep_default=s2idle" ] en hosts/workhorse/configuration.nix, asumiendo que la consola no apague ventiladores al dormir.
<!-- SECTION:FINAL_SUMMARY:END -->
