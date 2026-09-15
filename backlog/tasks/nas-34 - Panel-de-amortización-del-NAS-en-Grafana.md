---
id: NAS-34
title: Panel de amortización del NAS en Grafana
status: To Do
assignee: []
created_date: '2026-09-13 09:53'
labels: []
dependencies: []
priority: low
type: feature
ordinal: 15000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Añadir a Grafana un panel que muestre la amortización del NAS: cuánto se lleva ahorrado/recuperado de la inversión inicial frente a pagar un servicio en la nube equivalente.

Modelo de cálculo (a refinar):
- Coste inicial del NAS (hardware original, sumar componentes).
- Restar el coste acumulado de electricidad que consume el NAS (medir consumo real, p. ej. vía UPS/NUT o smart plug, y aplicar tarifa €/kWh).
- Restar (o comparar contra) lo que costaría almacenar los mismos TB en un servicio como Google Cloud Storage o Apple iCloud (€/TB/mes), acumulado en el tiempo.
- El panel debe reflejar el punto de break-even: cuándo el NAS se vuelve más barato que la nube.

Pendiente de decidir: fuentes de datos (Prometheus para consumo, capacidad usada del pool), tarifas configurables, y horizonte temporal.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Determinado el coste inicial del NAS (desglose de componentes)
- [ ] #2 Definida la fuente de consumo eléctrico y la tarifa €/kWh usada
- [ ] #3 Definido el precio de referencia €/TB/mes del servicio cloud comparado (Google Cloud / iCloud)
- [ ] #4 Panel en Grafana que muestra la amortización acumulada y el punto de break-even
<!-- AC:END -->
