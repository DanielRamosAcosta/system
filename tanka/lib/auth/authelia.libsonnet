local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local s = import 'secrets.json';
local u = import 'utils.libsonnet';

local autheliaConfig = import './authelia.config.json';

{
  local deployment = k.apps.v1.deployment,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,

  new(image='ghcr.io/authelia/authelia', version):: {
    deployment: deployment.new('authelia', replicas=1, containers=[
                  container.new('authelia', u.image(image, version)) +
                  container.withPorts([containerPort.new('http', 9091)]) +
                  container.withEnv(u.envVars.fromSecret(self.secrets)) +
                  container.withVolumeMounts([
                    u.volumeMount.fromFile(self.configuration, '/config'),
                    u.volumeMount.fromFile(self.usersDatabase, '/config'),
                  ]),
                ]) +
                u.injectFiles([self.configuration, self.usersDatabase]) +
                deployment.spec.template.spec.withEnableServiceLinks(false),

    service: k.util.serviceFor(self.deployment),

    configuration: u.configMap.forFile('configuration.yml', std.manifestYamlDoc(u.withoutSchema(autheliaConfig))),

    usersDatabase: u.secret.forFile('users_database.yml', std.manifestYamlDoc({
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

    secrets: u.secret.forEnv(self.deployment, {
      AUTHELIA_STORAGE_POSTGRES_PASSWORD: s.POSTGRES_PASSWORD_AUTHELIA,
      AUTHELIA_STORAGE_ENCRYPTION_KEY: s.AUTHELIA_STORAGE_ENCRYPTION_KEY,
    }),

    ingressRoute: u.ingressRoute.from(self.service, 'pauth.danielramos.me'),
  },
}
