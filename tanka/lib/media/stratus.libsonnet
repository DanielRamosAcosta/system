local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local s = import 'secrets.json';
local u = import 'utils.libsonnet';

{
  local deployment = k.apps.v1.deployment,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local secret = k.core.v1.secret,
  local volume = k.core.v1.volume,
  local volumeMount = k.core.v1.volumeMount,
  local configMap = k.core.v1.configMap,

  new(image='ghcr.io/danielramosacosta/stratus', version):: {
    deployment: deployment.new('stratus', replicas=1, containers=[
                   container.new('stratus', u.image(image, version)) +
                   container.withPorts(
                     [containerPort.new('server', 5173)]
                   ) +
                   container.withEnv(
                     u.envVars.fromConfigMap(self.configEnv) +
                     u.envVars.fromSecret(self.secretsEnv),
                   )
                 ]),

    service: k.util.serviceFor(self.deployment),

    configEnv: u.configMap.forEnv(self.deployment, {
      OAUTH_BUTTON_TEXT: "Sign in",
      OAUTH_ISSUER_URL: "https://pauth.danielramos.me/.well-known/openid-configuration",
      DB_HOSTNAME: "postgres.databases.svc.cluster.local",
    }),

    secretsEnv: u.secret.forEnv(self.deployment, {
      OAUTH_CLIENT_ID: s.AUTHELIA_OIDC_STRATUS_CLIENT_ID,
      OAUTH_CLIENT_SECRET: s.AUTHELIA_OIDC_STRATUS_CLIENT_SECRET,
      DB_PASSWORD: s.POSTGRES_PASSWORD_STRATUS
    }),

    ingressRoute: u.ingressRoute.from(self.service, 'pcloud.danielramos.me'),
  },
}
