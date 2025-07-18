local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';

local helm = tanka.helm.new(std.thisFile);

{
  new():: helm.template('traefik', '../../charts/traefik', {
    namespace: 'proxy',
  }),
}
