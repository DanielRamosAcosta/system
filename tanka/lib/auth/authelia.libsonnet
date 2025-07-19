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
  local configMap = k.core.v1.configMap,

  new(image='ghcr.io/authelia/authelia', version):: {
    statefulSet: deployment.new('authelia', replicas=1, containers=[
                   container.new('authelia', u.image(image, version)) +
                   container.withPorts([containerPort.new('http', 9091)]) +
                   container.withEnv(u.fromSecretEnv(self.secrets)) +
                   container.withVolumeMounts([
                     u.fromFile(self.configMap, "/config"),
                     u.fromFile(self.usersSecret, "/config"),
                   ]),
                 ]) +
                 u.injectFiles([self.configMap, self.usersSecret]) +
                 deployment.spec.template.spec.withEnableServiceLinks(false),

    service: k.util.serviceFor(self.statefulSet),

    configMap: configMap.new('authelia-config', {
      'configuration.yml': std.manifestYamlDoc(u.withoutSchema(autheliaConfig)),
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

    secrets: secret.new('authelia-secret', u.base64Keys({
      AUTHELIA_STORAGE_POSTGRES_PASSWORD: s.POSTGRES_PASSWORD_AUTHELIA,
      AUTHELIA_STORAGE_ENCRYPTION_KEY: s.AUTHELIA_STORAGE_ENCRYPTION_KEY,
    })),

    ingressRoute: u.ingressRoute(
      name='auth-ingressroute',
      host='pauth.danielramos.me',
      serviceName='authelia',
      port=9091
    ),
  },
}
