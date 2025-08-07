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

  local dataVolumeName = 'data',

  local createUserMigration = importstr './postgres.create-user.sh',

  new(image='ghcr.io/immich-app/postgres', version):: {
    statefulSet: statefulSet.new('postgres', replicas=1, containers=[
      container.new('postgres', u.image(image, version)) +
      container.withPorts(
        [containerPort.new('postgres', 5432)]
      ) +
      container.withEnv(
        u.envVars.fromSecret(self.secretsEnv)
      ) +
      container.withVolumeMounts([
        volumeMount.new(dataVolumeName, '/var/lib/postgresql/data')
      ]),
    ]) + statefulSet.spec.template.spec.withVolumes([
      volume.fromPersistentVolumeClaim(dataVolumeName, self.pvc.metadata.name),
    ]),

    service: k.util.serviceFor(self.statefulSet),

    secretsEnv: u.secret.forEnv(self.statefulSet, {
      POSTGRES_PASSWORD: s.POSTGRES_PASSWORD,
    }),

    userImmich: self.createUser("immich", s.POSTGRES_PASSWORD_IMMICH, self.createUserMigration, self.secretsEnv),
    userAuthelia: self.createUser("authelia", s.POSTGRES_PASSWORD_AUTHELIA, self.createUserMigration, self.secretsEnv),

    createUserMigration: u.configMap.forFile('postgres.create-user.sh', createUserMigration),

    pv: u.pv.localPathFor(self.statefulSet, '40Gi', '/data/postgres/data'),
    pvc: u.pvc.from(self.pv),

    createUser(name, password, configMap, secret):: {
      migrationJob: k.batch.v1.job.new('postgres-create-user-' + name) +
      k.batch.v1.job.spec.template.spec.withRestartPolicy('OnFailure') +
      k.batch.v1.job.spec.template.spec.withContainers([
        container.new('create-user', u.image(image, version)) +
        container.withCommand(['/bin/bash', '/mnt/scripts/postgres.create-user.sh']) +
        container.withEnv(
          [k.core.v1.envVar.new("USER_NAME", name)] + 
          u.envVars.fromSecret(self.userSecret) + 
          u.envVars.fromSecret(secret)
        ) +
        container.withVolumeMounts([
          u.volumeMount.fromFile(configMap, '/mnt/scripts'),
        ]),
      ]) +
      k.batch.v1.job.spec.template.spec.withVolumes([
        u.volume.fromConfigMap(configMap),
      ]),

      userSecret: u.secret.forEnv(self.migrationJob, {
        USER_PASSWORD: password,
      })
    }
  },
}
