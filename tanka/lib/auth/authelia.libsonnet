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
                  container.withEnv(
                    u.envVars.fromSecret(self.secrets) +
                    u.envVars.fromConfigMap(self.configEnv)
                  ) +
                  container.withVolumeMounts([
                    u.volumeMount.fromFile(self.configuration, '/config'),
                    u.volumeMount.fromFile(self.usersDatabase, '/config'),
                    u.volumeMount.fromFile(self.secretJwksKey, '/config/secrets/oidc/jwks'),
                  ]),
                ]) +
                u.injectFiles([self.configuration, self.usersDatabase, self.secretJwksKey]) +
                deployment.spec.template.spec.withEnableServiceLinks(false),

    service: k.util.serviceFor(self.deployment),

    configuration: u.configMap.forFile('configuration.yml', std.manifestYamlDoc(u.withoutSchema(autheliaConfig))),

    usersDatabase: u.secret.forFile('users_database.yml', std.manifestYamlDoc({
      users: {
        dani: {
          disabled: false,
          displayname: 'Dani',
          given_name: 'Daniel',
          family_name: 'Ramos Acosta',
          picture: 'https://2.gravatar.com/avatar/bd9cf3cfa5c4875128bdd435d7f304403c6c883442670a1cd201abf85d3858d1?size=512&d=initials',
          locale: 'es-ES',
          zoneinfo: 'Europe/Madrid',
          password: s.AUTHELIA_PASSWORD_DANI,
          email: 'danielramosacosta1@gmail.com',
          groups: [
            'admins',
            'dev',
          ],
        },
        cris: {
          disabled: false,
          displayname: 'Cris',
          given_name: 'Cristina',
          family_name: 'Guardia Trujillo',
          picture: 'https://2.gravatar.com/avatar/3780877d4745ddac6f733933240f62fddc3c4ded1a78571ac710b36d6dd96673?size=512&d=initials',
          locale: 'es-ES',
          zoneinfo: 'Europe/Madrid',
          password: s.AUTHELIA_PASSWORD_CRIS,
          email: 'ivhcristinaguardia@gmail.com',
          groups: [],
        },
      },
    })),

    configEnv: u.configMap.forEnv(self.deployment, {
      X_AUTHELIA_CONFIG_FILTERS: 'template',
    }),

    secretJwksKey: u.secret.forFile('rsa.2048.key', s.AUTHELIA_IDENTITY_PROVIDERS_OIDC_JWKS_0_KEY),

    secrets: u.secret.forEnv(self.deployment, {
      AUTHELIA_STORAGE_ENCRYPTION_KEY: s.AUTHELIA_STORAGE_ENCRYPTION_KEY,
      AUTHELIA_STORAGE_POSTGRES_PASSWORD: s.POSTGRES_PASSWORD_AUTHELIA,
      AUTHELIA_SESSION_SECRET: s.AUTHELIA_SESSION_SECRET,
      IDENTITY_PROVIDERS_OIDC_CLIENTS_IMMICH_CLIENT_ID: s.AUTHELIA_OIDC_IMMICH_CLIENT_ID,
      IDENTITY_PROVIDERS_OIDC_CLIENTS_IMMICH_CLIENT_SECRET_DIGEST: s.AUTHELIA_OIDC_IMMICH_CLIENT_SECRET_DIGEST,
    }),

    ingressRoute: u.ingressRoute.from(self.service, 'pauth.danielramos.me'),
  },
}
