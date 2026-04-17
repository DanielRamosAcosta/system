# Fan Temperature Analysis (2026-04-16)

Objetivo: medir el impacto de cada fan en las temperaturas de los HDDs tras cambiar la disposicion de los discos (mejor airflow).

## Hardware

- fan1, fan2: acoplados a SSDs/NVMe (fijos al 100% durante las pruebas)
- fan3: parte superior del case (exhaust)
- fan4: parte inferior del case (directamente sobre HDDs)
- sensor1 QUADRO: entre los HDDs

## Discos

| Disco | Modelo |
|---|---|
| sda | Seagate Exos 26TB (ST26000NM) |
| sdb | Seagate Exos 10TB (ST10000NM) |
| sdc | Seagate Exos 10TB (ST10000NM) |
| sdd | Seagate Exos 26TB (ST26000NM) |

## Run 1: fan4 variable, fan3=100%, fan1=100%, fan2=100%

| fan4 % | sda | sdb | sdc | sdd | max |
|---|---|---|---|---|---|
| 100 | 28 | 29 | 31 | 31 | 31 |
| 90 | 28 | 29 | 31 | 31 | 31 |
| 80 | 28 | 29 | 31 | 32 | 32 |
| 70 | 29 | 29 | 32 | 32 | 32 |
| 60 | 29 | 30 | 32 | 33 | 33 |
| 50 | 30 | 31 | 33 | 34 | 34 |
| 40 | 32 | 31 | 34 | 35 | 35 |
| 30 | 33 | 32 | 35 | 35 | 35 |
| 20 | 33 | 32 | 35 | 35 | 35 |
| 10 | 33 | 31 | 35 | 35 | 35 |
| 0 | 33 | 31 | 35 | 35 | 35 |

**Conclusiones Run 1**: fan4 tiene impacto directo pero moderado. De 100% a 30% las temperaturas suben ~4°C (31→35). Por debajo del 30% el fan alcanza su suelo de RPM y no tiene mas efecto. Relacion: ~1°C por cada 15-20% de reduccion.

## Run 2: fan3 variable, fan4=40%, fan1=100%, fan2=100%

| fan3 % | sda | sdb | sdc | sdd | max |
|---|---|---|---|---|---|
| 100 | 33 | 32 | 35 | 35 | 35 |
| 80 | 33 | 33 | 36 | 36 | 36 |
| 60 | 33 | 33 | 36 | 36 | 36 |
| 40 | 33 | 34 | 37 | 37 | 37 |
| 20 | 33 | 34 | 37 | 37 | 37 |
| 0 | 33 | 34 | 37 | 37 | 37 |

**Conclusiones Run 2**: fan3 (exhaust superior) tiene impacto leve pero real: 2°C de rango entre 100% y el suelo. Rango util: 100%→40%, por debajo no baja mas RPM. Afecta mas a sdb/sdc/sdd que a sda.

## Conclusiones generales

- **Objetivo**: mantener HDDs por debajo de 40°C en todo momento
- **Peor caso medido**: fan3=0%, fan4=40%, fan1/2=100% → max 37°C (3°C de margen)
- **Mejora de airflow**: con la nueva disposicion de discos, las temperaturas baseline (todos al 100%) bajaron de 38/36/32/34 a 28/29/31/31 — mejora de ~6°C
- **fan4** es el fan mas relevante para los HDDs, pero su impacto total es de ~4°C (100%→suelo)
- **fan3** aporta ~2°C adicionales
- **Suelo de RPM**: ambos fans (fan3 y fan4) dejan de responder por debajo del ~30% PWM
- Hay margen de sobra para curvas silenciosas sin acercarse al limite de 40°C
