local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local s = import 'secrets.json';
local u = import 'utils.libsonnet';

local configuration = importstr './promtail.config.yml';

{
  local daemonSet = k.apps.v1.daemonSet,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local volume = k.core.v1.volume,
  local clusterRole = k.rbac.v1.clusterRole,
  local policyRule = k.rbac.v1.policyRule,

  new(image='docker.io/grafana/promtail', version):: {
    daemonSet: daemonSet.new('promtail', containers=[
                 container.new('promtail', u.image(image, version)) +
                 container.withEnv([
                   k.core.v1.envVar.fromFieldPath('HOSTNAME', 'spec.nodeName'),
                 ]) +
                 container.withArgs([
                   '-config.file=/etc/promtail/promtail.yaml',
                 ]) +
                 container.withVolumeMounts([
                   u.volumeMount.fromFile(self.configuration, '/etc/promtail'),
                   k.core.v1.volumeMount.new('logs', '/var/log'),
                 ]),
               ]) +
               daemonSet.spec.template.spec.withServiceAccount('promtail') +
               daemonSet.spec.template.spec.withVolumes([
                 u.volume.fromConfigMap(self.configuration),
                 volume.fromHostPath('logs', '/var/log'),
               ]),

    configuration: u.configMap.forFile('promtail.yaml', configuration),

    rbac: u.rbac('promtail', 'monitoring', rules=[
      policyRule.withApiGroups(['']) +
      policyRule.withResources(['nodes', 'services', 'pods']) +
      policyRule.withVerbs(['get', 'watch', 'list']),
    ]),
  },
}
