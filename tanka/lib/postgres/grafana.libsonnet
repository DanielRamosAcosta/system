local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  new(name, portNum):: {
    deployment: k.apps.v1.deployment.new(name, replicas=1, containers=[
      k.core.v1.container.new('grafana', 'grafana/grafana') +
      k.core.v1.container.withPorts(
        [k.core.v1.containerPort.newNamed('ui', portNum)]
      ),
    ]),

    service: k.util.serviceFor(self.deployment) + k.core.v1.service.mixin.spec.withType('NodePort'),
  },
}
