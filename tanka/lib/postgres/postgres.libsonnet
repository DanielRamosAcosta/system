local grafana = import 'grafana.libsonnet';

{
  grafana: grafana.new('grafana', 3000),
  prometheus: {
    deployment: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: 'prometheus',
      },
      spec: {
        minReadySeconds: 10,
        replicas: 1,
        revisionHistoryLimit: 10,
        selector: {
          matchLabels: {
            name: 'prometheus',
          },
        },
        template: {
          metadata: {
            labels: {
              name: 'prometheus',
            },
          },
          spec: {
            containers: [
              {
                image: 'prom/prometheus',
                imagePullPolicy: 'IfNotPresent',
                name: 'prometheus',
                ports: [
                  {
                    containerPort: 9090,
                    name: 'api',
                  },
                ],
              },
            ],
          },
        },
      },
    },
    service: {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        labels: {
          name: 'prometheus',
        },
        name: 'prometheus',
      },
      spec: {
        ports: [
          {
            name: 'prometheus-api',
            port: 9090,
            targetPort: 9090,
          },
        ],
        selector: {
          name: 'prometheus',
        },
      },
    },
  },
}
