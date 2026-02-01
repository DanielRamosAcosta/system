local u = import '../utils.libsonnet';
local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local s = import 'secrets.json';

{
  local deployment = k.apps.v1.deployment,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local volumeMount = k.core.v1.volumeMount,

  new(image='ghcr.io/danielramosacosta/norznab', version):: {
    statefulSet: deployment.new('norznab', replicas=1, containers=[
      container.new('norznab', u.image(image, version)) +
      container.withPorts([
        containerPort.new('http', 3000),
      ]) +
      container.withEnv(
        u.envVars.fromSecret(self.secrets) +
        u.envVars.fromConfigMap(self.config)
      ),
    ]),

    service: k.util.serviceFor(self.statefulSet),

    config: u.configMap.forEnv(self.statefulSet, {
      DON_TORRENT_BASE_URL: 'https://dontorrent.promo',
    }),

    secrets: u.secret.forEnv(self.statefulSet, {
      TMDB_API_KEY: s.NORZNAB_TMDB_API_KEY,
    }),
  },
}
