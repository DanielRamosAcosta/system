local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local s = import 'secrets.json';
local u = import 'utils.libsonnet';

local immichConfig = importstr './immich.config.json';

{
  local statefulSet = k.apps.v1.statefulSet,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local secret = k.core.v1.secret,
  local volume = k.core.v1.volume,
  local volumeMount = k.core.v1.volumeMount,
  local configMap = k.core.v1.configMap,

  new(image='ghcr.io/immich-app/immich-server', version):: {
    statefulSet: statefulSet.new('immich', replicas=1, containers=[
                   container.new('immich', u.image(image, version)) + 
                   container.withPorts(
                     [containerPort.new('server', 2283)]
                   ) +
                   container.withEnv(
                     u.extractConfig(self.configMap.metadata.name, std.objectFieldsAll(self.configMap.data)) +
                     u.extractSecrets(self.secrets.metadata.name, std.objectFieldsAll(self.secrets.data)),
                   ) +
                   container.withVolumeMounts([
                     volumeMount.new('upload', '/usr/src/app/upload'),
                     volumeMount.new('merged-config', '/app/config') + volumeMount.withReadOnly(true),
                   ]),
                 ]) +
                 statefulSet.spec.template.spec.withInitContainers(
                   container.new('merge-config', u.image('ghcr.io/danielramosacosta/jq', 'main-5231ab6')) +
                   container.withCommand([
                     'sh',
                     '-c',
                     "jq -s '.[0] * .[1]' /data/config.json /data/secret.json > /output/immich.json",
                   ]) +
                   container.withVolumeMounts([
                     volumeMount.new('public-config', '/data/config.json') + volumeMount.withSubPath('config.json'),
                     volumeMount.new('private-secret', '/data/secret.json') + volumeMount.withSubPath('secret.json'),
                     volumeMount.new('merged-config', '/output'),
                   ])
                 ) +
                 statefulSet.spec.template.spec.withVolumes([
                   volume.fromPersistentVolumeClaim('upload', self.pvc.metadata.name),
                   volume.fromConfigMap('public-config', 'immich-config-public'),
                   volume.fromSecret('private-secret', 'immich-config-secret'),
                   volume.fromEmptyDir('merged-config'),
                 ]),

    service: k.util.serviceFor(self.statefulSet),

    configMap: configMap.new("immich-config", {
      DB_HOSTNAME: 'postgres.databases.svc.cluster.local',
      DB_USERNAME: 'immich',
      REDIS_HOSTNAME: 'valkey.databases.svc.cluster.local',
      IMMICH_CONFIG_FILE: '/app/config/immich.json',
      IMMICH_PORT: '2283',
    }),

    secrets: secret.new("immich-secret", u.base64Keys({
      DB_PASSWORD: s.POSTGRES_PASSWORD_IMMICH,
    })),

    immichConfigPublic: configMap.new('immich-config-public', {
      'config.json': immichConfig,
    }),

    immichConfigSecret: secret.new('immich-config-secret', {
      'secret.json': std.base64(u.jsonStringify({
        oauth: {
          clientId: 'example',
          clientSecret: 'something',
        },
      })),
    }),

    pv: u.localPv(self.statefulSet.metadata.name + '-pv', '40Gi', '/mnt/data/services/immich/upload'),
    pvc: u.fromPv(self.pv),

    ingressRoute: u.ingressRoute(
      name='immich-ingressroute',
      host='pphotos.danielramos.me',
      serviceName='immich',
      port=2283
    ),
  },
}
