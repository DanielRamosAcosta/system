local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local s = import 'secrets.json';
local u = import 'utils.libsonnet';

{
  local statefulSet = k.apps.v1.statefulSet,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local volume = k.core.v1.volume,
  local volumeMount = k.core.v1.volumeMount,

  local initScriptData = importstr './mariadb.init.sh',

  new(image='docker.io/library/mariadb', version):: {
    statefulSet: statefulSet.new('mariadb', replicas=1, containers=[
      container.new('mariadb', u.image(image, version)) +
      container.withPorts(
        [containerPort.new('mariadb', 3306)]
      ) +
      container.withEnv(
        u.envVars.fromConfigMap(self.configEnv) +
        u.envVars.fromSecret(self.secretsEnv)
      ) +
      container.withVolumeMounts([
        volumeMount.new('data', '/var/lib/mysql'),
        u.volumeMount.fromFile(self.initScript, '/docker-entrypoint-initdb.d'),
      ]),
    ]) + statefulSet.spec.template.spec.withVolumes([
      volume.fromPersistentVolumeClaim('data', self.pvc.metadata.name),
      u.volume.fromConfigMap(self.initScript),
    ]),

    service: k.util.serviceFor(self.statefulSet),

    secretsEnv: u.secret.forEnv(self.statefulSet, {
      MARIADB_ROOT_PASSWORD: s.MARIADB_ROOT_PASSWORD,
      USER_PASSWORD_SEAFILE: s.MARIADB_USER_PASSWORD_SEAFILE
    }),

    configEnv: u.configMap.forEnv(self.statefulSet, {
      DATABASE_USERS: u.utils.join([ "seafile" ])
    }),

    initScript: u.configMap.forFile('mariadb.init.sh', initScriptData),

    pv: u.pv.localPathFor(self.statefulSet, '40Gi', '/mnt/data/services/mariadb'),
    pvc: u.pvc.from(self.pv),
  },
}
