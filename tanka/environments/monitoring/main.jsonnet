local grafana = import 'monitoring/grafana.libsonnet';

{
  grafana: grafana.new(
    version='12.1.1'
  ),
}
