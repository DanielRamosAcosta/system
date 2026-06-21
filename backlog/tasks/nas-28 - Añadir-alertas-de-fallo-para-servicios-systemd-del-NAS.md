---
id: NAS-28
title: Añadir alertas de fallo para servicios systemd del NAS
status: To Do
assignee: []
created_date: '2026-06-19 19:12'
labels:
  - nas
  - nixos
  - monitoring
dependencies:
  - NAS-27
priority: low
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## Contexto

Al implementar el servicio `gdrive-sync` (NAS-27) se decidió dejar los fallos solo en journald por ahora, con la intención de implementar alertado activo como feature separada que aplique a todos los servicios del NAS, no solo a gdrive-sync.

## Objetivo

Implementar un mecanismo genérico de notificación cuando un servicio systemd del NAS falla, de forma que no sea necesario monitorizar manualmente los logs.

## Opciones a evaluar

- `OnFailure` en systemd → dispara un servicio de notificación genérico
- Integración con Grafana/Loki (ya existe `grafana-self-hosted-token.age` en el NAS)
- Notificación por email, Telegram, o similar
<!-- SECTION:DESCRIPTION:END -->
