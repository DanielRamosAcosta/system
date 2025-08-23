local grafana = import 'monitoring/grafana.libsonnet';
local loki = import 'monitoring/loki.libsonnet';
local promtail = import 'monitoring/promtail.libsonnet';

{
  grafana: grafana.new(
    version='12.1.1'
  ),
  loki: loki.new(
    version='3.5.3'
  ),
  promtail: promtail.new(
    version='3.5.3'
  ),
}
