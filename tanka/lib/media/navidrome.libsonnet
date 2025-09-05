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
                     volumeMount.new('music-dani', '/music-dani', true),
                     volumeMount.new('data', '/data'),
                   ]),
                 ]) +
                 statefulSet.spec.template.spec.withVolumes([
                   volume.fromHostPath('music-dani', '/cold-data/sftpgo/data/dani/Multimedia/Música'),
                   volume.fromPersistentVolumeClaim('data', self.pvcData.metadata.name),
                 ]),

    service: k.util.serviceFor(self.statefulSet) + u.prometheus(port='8081'),

    configEnv: u.configMap.forEnv(self.statefulSet, {
      ND_BASEURL: 'https://music.danielramos.me',
    }),

    pvData: u.pv.atLocal('navidrome-data-pv', '40Gi', '/data/navidrome/data'),
    pvcData: u.pvc.from(self.pvData),

    ingressRoute: u.ingressRoute.from(self.service, 'music.danielramos.me'),
  },
}
