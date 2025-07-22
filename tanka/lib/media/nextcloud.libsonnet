local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local s = import 'secrets.json';
local u = import 'utils.libsonnet';

local nginxConfig = importstr './nextcloud.nginx.conf';

{
  local deployment = k.apps.v1.deployment,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local secret = k.core.v1.secret,
  local volume = k.core.v1.volume,
  local volumeMount = k.core.v1.volumeMount,
  local configMap = k.core.v1.configMap,

  new(image='docker.io/library/nextcloud', version):: {
    deployment: deployment.new('nextcloud', replicas=1, containers=[
                  container.new('php-fpm', u.image(image, version)) +
                  container.withEnv(
                    u.envVars.fromConfigMap(self.configEnv) +
                    u.envVars.fromSecret(self.secretsEnv),
                  ) +
                  container.withVolumeMounts([
                    volumeMount.new('nextcloud-html', '/var/www/html'),
                  ]),
                  container.new('nginx', u.image('nginx', 'alpine')) +
                  container.withPorts(
                    [containerPort.new('server', 80)]
                  ) +
                  container.withVolumeMounts([
                    volumeMount.new('nextcloud-html', '/var/www/html'),
                    u.volumeMount.fromFile(self.nginxConfig, '/etc/nginx/conf.d')
                  ]),
                ]) +
                deployment.spec.template.spec.withVolumes([
                  volume.fromPersistentVolumeClaim('nextcloud-html', self.pvc.metadata.name),
                  u.volume.fromConfigMap(self.nginxConfig),
                ]),

    service: k.util.serviceFor(self.deployment),

    configEnv: u.configMap.forEnv(self.deployment, {
      POSTGRES_DB: 'nextcloud',
      POSTGRES_USER: 'nextcloud',
      POSTGRES_HOST: 'postgres.databases.svc.cluster.local',
      REDIS_HOST: 'valkey.databases.svc.cluster.local',
    }),

    secretsEnv: u.secret.forEnv(self.deployment, {
      POSTGRES_PASSWORD: s.POSTGRES_PASSWORD_NEXTCLOUD,
    }),

    pv: u.pv.localPathFor(self.deployment, '10Gi', '/mnt/data/services/nextcloud'),
    pvc: u.pvc.from(self.pv),

    nginxConfig: u.configMap.forFile('default.conf', nginxConfig),

    ingressRoute: u.ingressRoute.from(self.service, 'pnextcloud.danielramos.me'),
  },
}
