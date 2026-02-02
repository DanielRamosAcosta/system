local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local s = import 'secrets.json';
local u = import 'utils.libsonnet';

local pipedConfig = importstr './piped.config.properties';
local pipedEntrypoint = importstr './entrypoint.sh';

{
  local deployment = k.apps.v1.deployment,
  local statefulSet = k.apps.v1.statefulSet,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local volume = k.core.v1.volume,
  local volumeMount = k.core.v1.volumeMount,

  new(
    frontendImage='docker.io/1337kavin/piped-frontend',
    backendImage='ghcr.io/10203/piped-backend-fixes/piped',
    proxyImage='docker.io/1337kavin/piped-proxy',
    bgHelperImage='docker.io/1337kavin/bg-helper-server',
    frontendVersion='latest',
    backendVersion='latest',
    proxyVersion='latest',
    bgHelperVersion='latest'
  ):: {
    local this = self,

    backendStatefulSet: statefulSet.new('piped-backend', replicas=1, containers=[
                          container.new('piped-backend', u.image(backendImage, "fixes")) +
                          container.withPorts([containerPort.new('http', 8080)]) +
                          container.withEnv(
                            u.envVars.fromConfigMap(self.backendConfigEnv) +
                            u.envVars.fromSecret(self.backendSecretsEnv)
                          ),
                        ]),

    backendService: k.util.serviceFor(self.backendStatefulSet),

    backendConfigEnv: u.configMap.forEnv(self.backendStatefulSet, {
      // Database
      HIBERNATE__CONNECTION__URL: "jdbc:postgresql://postgres.databases.svc.cluster.local:5432/piped",
      HIBERNATE__CONNECTION__DRIVER_CLASS: "org.postgresql.Driver",
      HIBERNATE__CONNECTION__USERNAME: "piped",

      // Proxy & Network
      PROXY_PART: "https://pipedproxy.danielramos.me",

      // Public URLs
      API_URL: "https://pipedapi.danielramos.me",
      FRONTEND_URL: "https://piped.danielramos.me",

      // Features & Limits
      DISABLE_REGISTRATION: "true",
      DISABLE_TIMERS: "false",

      // External Services
      BG_HELPER_URL: "http://piped-bg-helper.piped.svc.cluster.local:3000",
    }),

    backendSecretsEnv: u.secret.forEnv(self.backendStatefulSet, {
      HIBERNATE__CONNECTION__PASSWORD: s.POSTGRES_PASSWORD_PIPED,
      SENTRY_DSN: s.PIPED_SENTRY_DSN,
    }),

    frontendDeployment: deployment.new('piped-frontend', replicas=1, containers=[
                          container.new('piped-frontend', u.image(frontendImage, frontendVersion)) +
                          container.withPorts([containerPort.new('http', 80)]) +
                          // container.withCommand(['/custom-entrypoint/entrypoint.sh']) +
                          container.withEnv(
                            u.envVars.fromConfigMap(self.frontendConfigEnv)
                          ),/*  +
                          container.withVolumeMounts([
                            volumeMount.new('custom-entrypoint', '/custom-entrypoint/entrypoint.sh') +
                            volumeMount.withSubPath('entrypoint.sh'),
                          ]), */
                        ]),/* +
                        deployment.spec.template.spec.withVolumes([
                          volume.fromConfigMap('custom-entrypoint', self.frontendEntrypointConfig.metadata.name) +
                          k.core.v1.volume.configMap.withDefaultMode(std.parseOctal('0755')),
                        ]),*/

    frontendConfigEnv: u.configMap.forEnv(self.frontendDeployment, {
      BACKEND_HOSTNAME: 'pipedapi.danielramos.me',
      HTTP_MODE: 'https',
    }),

    frontendEntrypointConfig: k.core.v1.configMap.new('piped-frontend-entrypoint', {
      'entrypoint.sh': pipedEntrypoint,
    }),

    frontendService: k.util.serviceFor(self.frontendDeployment),

    proxyDeployment: deployment.new('piped-proxy', replicas=1, containers=[
      container.new('piped-proxy', u.image(proxyImage, proxyVersion)) +
      container.withPorts([containerPort.new('http', 8080)]),
    ]),

    proxyService: k.util.serviceFor(self.proxyDeployment),

    bgHelperDeployment: deployment.new('piped-bg-helper', replicas=1, containers=[
      container.new('piped-bg-helper', u.image(bgHelperImage, bgHelperVersion)) +
      container.withPorts([containerPort.new('http', 3000)]),
    ]),

    bgHelperService: k.util.serviceFor(self.bgHelperDeployment),

    ingressRoute: {
      apiVersion: 'traefik.io/v1alpha1',
      kind: 'IngressRoute',
      metadata: {
        name: 'piped-ingressroute',
        namespace: 'piped',
      },
      spec: {
        entryPoints: ['websecure'],
        routes: [
          {
            match: 'Host(`pipedapi.danielramos.me`)',
            kind: 'Rule',
            services: [{
              name: this.backendService.metadata.name,
              port: 8080,
            }],
          },
          {
            match: 'Host(`pipedproxy.danielramos.me`)',
            kind: 'Rule',
            services: [{
              name: this.proxyService.metadata.name,
              port: 8080,
            }],
          },
          {
            match: 'Host(`piped.danielramos.me`)',
            kind: 'Rule',
            services: [{
              name: this.frontendService.metadata.name,
              port: 80,
            }],
          },
        ],
        tls: {
          certResolver: 'le',
        },
      },
    },
  },
}
