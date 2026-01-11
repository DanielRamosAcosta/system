local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local u = import '../utils.libsonnet';

{
  local statefulSet = k.apps.v1.statefulSet,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local volumeMount = k.core.v1.volumeMount,

  new(image='ghcr.io/hotio/prowlarr', version):: {
    statefulSet: statefulSet.new('prowlarr', replicas=1, containers=[
      container.new('prowlarr', u.image(image, version)) +
      container.withPorts([
        containerPort.new('http', 9696),
      ]) +
      container.withEnv(
        u.envVars.fromConfigMap(self.configEnv)
      ) +
      container.withVolumeMounts([
        volumeMount.new('config', '/config'),
      ])
    ]) +
    statefulSet.spec.template.spec.withVolumes([
      u.volume.fromHostPath('config', '/data/arr/prowlarr'),
    ]),

    service: k.util.serviceFor(self.statefulSet),

    configEnv: u.configMap.forEnv(self.statefulSet, {
      PUID: '1000',
      PGID: '100',
      UMASK: '002',
      TZ: 'Europe/Madrid',
    }),
  },
}
