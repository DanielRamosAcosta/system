{
  deployment: {
    new(name, containers):: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: name,
      },
      spec: {
        selector: { matchLabels: {
          name: name,
        } },
        template: {
          metadata: { labels: {
            name: name,
          } },
          spec: { containers: containers },
        },
      },
    },
  },
}
