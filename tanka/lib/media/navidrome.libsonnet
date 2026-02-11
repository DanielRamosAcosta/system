local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local s = import 'secrets.json';
local u = import 'utils.libsonnet';

local immichConfig = importstr './immich.config.json';

{
  local statefulSet = k.apps.v1.statefulSet,
  local service = k.core.v1.service,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local secret = k.core.v1.secret,
  local volume = k.core.v1.volume,
  local volumeMount = k.core.v1.volumeMount,
  local configMap = k.core.v1.configMap,

  new(image='docker.io/deluan/navidrome', version):: {
    statefulSet: statefulSet.new('navidrome', replicas=1, containers=[
                   container.new('navidrome', u.image(image, version)) +
                   container.withPorts(
                     [containerPort.new('server', 4533)]
                   ) +
                   container.withEnv(
                     u.envVars.fromConfigMap(self.configEnv)
                   ) +
                   container.withVolumeMounts([
                     volumeMount.new('music-dani', '/music', true),
                     volumeMount.new('data', '/data'),
                   ]),
                 ]) +
                 statefulSet.spec.template.spec.withVolumes([
                   volume.fromHostPath('music-dani', '/cold-data/media/music/library'),
                   volume.fromHostPath('data', '/data/navidrome/data'),
                 ]),

    service: k.util.serviceFor(self.statefulSet) + u.prometheus(port='8081'),

    configEnv: u.configMap.forEnv(self.statefulSet, {
      ND_BASEURL: 'https://music.danielramos.me',
    }),

    ingressRoute: u.ingressRoute.from(self.service, 'music.danielramos.me'),
  },
}
