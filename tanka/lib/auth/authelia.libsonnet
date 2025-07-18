local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local s = import 'secrets.json';
local u = import 'utils.libsonnet';

local autheliaConfig = import './authelia.config.json';

{
  local deployment = k.apps.v1.deployment,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local secret = k.core.v1.secret,
  local volume = k.core.v1.volume,
  local volumeMount = k.core.v1.volumeMount,
  local configMap = k.core.v1.configMap,

  local secretsName = 'authelia-secret',
  local configMapName = 'authelia-config',
  local dataVolumeName = 'upload',
  local dataPv = 'authelia-pv',
  local dataPvc = 'authelia-pvc',
  local dataStorage = '40Gi',

  new(image='ghcr.io/authelia/authelia', version):: {
    statefulSet: deployment.new('authelia', replicas=1, containers=[
                   container.new('authelia', u.image(image, version)) +
                   container.withPorts(
                     [containerPort.new('http', 9091)]
                   ) +
                   container.withEnv(
                     u.extractSecrets(secretsName, [
                       'AUTHELIA_STORAGE_POSTGRES_PASSWORD',
                     ]),
                   ) +
                   container.withVolumeMounts([
                     volumeMount.new('authelia-config', '/config/configuration.yml') + volumeMount.withSubPath('configuration.yml'),
                     volumeMount.new('authelia-config', '/config/users_database.yml') + volumeMount.withSubPath('users_database.yml'),
                   ]),
                 ]) +
                 deployment.spec.template.spec.withVolumes([
                   volume.fromConfigMap('authelia-config', 'authelia-config'),
                   volume.fromSecret('users-secret', 'users-secret'),
                 ]),

    service: k.util.serviceFor(self.statefulSet),

    configMap: configMap.new('authelia-config', {
      'configuration.yml': std.manifestYamlDoc(autheliaConfig),
    }),

    usersSecret: secret.new('users-secret', {
      'users_database.yml': std.base64(std.manifestYamlDoc({
        users: {
          authelia: {
            disabled: false,
            displayname: 'Test User',
            password: s.AUTHELIA_USER_AUTHELIA_HASHED_PASSWORD,
            email: 'authelia@authelia.com',
            groups: [
              'admins',
              'dev',
            ],
          },
        },
      })),
    }),

    secrets: secret.new(secretsName, u.base64Keys({
      AUTHELIA_STORAGE_POSTGRES_PASSWORD: s.POSTGRES_PASSWORD_AUTHELIA,
    })),

    ingressRoute: u.ingressRoute(
      name = "auth-ingressroute",
      host = "pauth.danielramos.me",
      serviceName = "authelia",
      port = 9091
    ),
  },
}
