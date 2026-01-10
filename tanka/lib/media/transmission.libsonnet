local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local u = import 'utils.libsonnet';

{
  local statefulSet = k.apps.v1.statefulSet,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local volumeMount = k.core.v1.volumeMount,
  local volume = k.core.v1.volume,

  new(image='docker.io/linuxserver/transmission', version):: {
    statefulSet: statefulSet.new('transmission', replicas=1, containers=[
      container.new('transmission', u.image(image, version)) +
      container.withPorts([
        containerPort.new('web', 9091),
        containerPort.new('peer-tcp', 51413),
        containerPort.newUDP('peer-udp', 51413),
      ]) +
      container.withEnv(
        u.envVars.fromConfigMap(self.configEnv)
      ) +
      container.withVolumeMounts([
        volumeMount.new('config', '/config'),
        volumeMount.new('downloads', '/downloads'),
      ])
    ]) +
    statefulSet.spec.template.spec.withVolumes([
      u.volume.fromHostPath('config', '/data/transmission/config'),
      u.volume.fromHostPath('downloads', '/cold-data/downloads'),
    ]),

    service: k.util.serviceFor(self.statefulSet),

    configEnv: u.configMap.forEnv(self.statefulSet, {
      PUID: '1000',
      PGID: '100',
      TZ: 'Europe/Madrid',
    }),
  },
}
