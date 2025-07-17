local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local s = import 'secrets.json';
local u = import 'utils.libsonnet';

{
  local statefulSet = k.apps.v1.statefulSet,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local secret = k.core.v1.secret,
  local volume = k.core.v1.volume,
  local volumeMount = k.core.v1.volumeMount,
  local configMap = k.core.v1.configMap,

  local secretsName = 'postgres-secret',
  local dataVolumeName = 'data',
  local dataPv = 'postgres-pv',
  local dataPvc = 'postgres-pvc',
  local dataStorage = '20Gi',

  local initScriptVolumeName = 'init-script',
  local initScriptConfigMapName = initScriptVolumeName,
  local initScriptData = importstr './postgres.init.sh',

  new(image='ghcr.io/immich-app/postgres', version):: {
    statefulSet: statefulSet.new('postgres', replicas=1, containers=[
      container.new('postgres', u.image(image, version)) +
      container.withPorts(
        [containerPort.new('postgres', 5432)]
      ) +
      container.withEnv(
        u.joinedEnv('DATABASE_USERS', [
          'immich',
          'authelia',
        ]) +
        u.extractSecrets(secretsName, [
          'POSTGRES_PASSWORD',
          'USER_PASSWORD_IMMICH',
          'USER_PASSWORD_AUTHELIA',
        ]),
      ) +
      container.withVolumeMounts([
        volumeMount.new(dataVolumeName, '/var/lib/postgresql/data'),
        volumeMount.new(initScriptVolumeName, '/docker-entrypoint-initdb.d/postgres.init.sh') + volumeMount.withSubPath('postgres.init.sh'),
      ]),
    ]) + statefulSet.spec.template.spec.withVolumes([
      volume.fromPersistentVolumeClaim(dataVolumeName, dataPvc),
      volume.fromConfigMap(initScriptVolumeName, initScriptConfigMapName) + volume.configMap.withDefaultMode(std.parseOctal('755')),
    ]),

    service: k.util.serviceFor(self.statefulSet),

    secrets: secret.new(secretsName, u.base64Keys({
      POSTGRES_PASSWORD: s.POSTGRES_PASSWORD,
      USER_PASSWORD_IMMICH: s.POSTGRES_PASSWORD_IMMICH,
      USER_PASSWORD_AUTHELIA: s.POSTGRES_PASSWORD_AUTHELIA,
    })),

    configMap: configMap.new(initScriptConfigMapName, {
      'postgres.init.sh': initScriptData,
    }),

    pv: u.localPv(dataPv, dataStorage, '/mnt/data/services/postgres'),
    pvc: u.localPvc(dataPvc, dataPv, dataStorage),
  },
}
