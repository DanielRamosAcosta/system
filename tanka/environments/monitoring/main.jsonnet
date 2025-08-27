local grafana = import 'monitoring/grafana.libsonnet';
local loki = import 'monitoring/loki.libsonnet';
local nodeExporter = import 'monitoring/node-exporter.libsonnet';
local prometheus = import 'monitoring/prometheus.libsonnet';
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
  prometheus: prometheus.new(
    version='v3.6.0-rc.0'
  ),
  nodeExporter: nodeExporter.new(
    version='v1.9.1'
  ),
}
