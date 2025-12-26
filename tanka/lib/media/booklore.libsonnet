local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local s = import 'secrets.json';
local u = import 'utils.libsonnet';

{
  local statefulSet = k.apps.v1.statefulSet,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local volume = k.core.v1.volume,
  local volumeMount = k.core.v1.volumeMount,

  new(image='booklore/booklore', version):: {
    statefulSet: statefulSet.new('booklore', replicas=1, containers=[
      container.new('booklore', u.image(image, version)) +
      container.withPorts([containerPort.new('server', 6060)]) +
      container.withEnv(
        u.envVars.fromConfigMap(self.configEnv) +
        u.envVars.fromSecret(self.secretsEnv),
      ) +
      container.withVolumeMounts([
        volumeMount.new('data', '/app/data'),
        volumeMount.new('books', '/books'),
        volumeMount.new('bookdrop', '/bookdrop'),
      ]),
    ]) + statefulSet.spec.template.spec.withVolumes([
      volume.fromPersistentVolumeClaim('data', self.dataPvc.metadata.name),
      volume.fromPersistentVolumeClaim('books', self.booksPvc.metadata.name),
      volume.fromPersistentVolumeClaim('bookdrop', self.bookdropPvc.metadata.name),
    ]),

    service: k.util.serviceFor(self.statefulSet),

    configEnv: u.configMap.forEnv(self.statefulSet, {
      USER_ID: '0',
      GROUP_ID: '0',
      TZ: 'Europe/Madrid',
      BOOKLORE_PORT: '6060',
      DATABASE_URL: 'jdbc:mariadb://mariadb.databases.svc.cluster.local:3306/booklore',
      DATABASE_USERNAME: 'booklore',
    }),

    secretsEnv: u.secret.forEnv(self.statefulSet, {
      DATABASE_PASSWORD: s.MARIADB_PASSWORD_BOOKLORE,
    }),

    dataPv: u.pv.atLocal('booklore-data-pv', '5Gi', '/cold-data/booklore/data'),
    dataPvc: u.pvc.from(self.dataPv),

    booksPv: u.pv.atLocal('booklore-books-pv', '50Gi', '/cold-data/booklore/books'),
    booksPvc: u.pvc.from(self.booksPv),

    bookdropPv: u.pv.atLocal('booklore-bookdrop-pv', '5Gi', '/cold-data/booklore/bookdrop'),
    bookdropPvc: u.pvc.from(self.bookdropPv),

    ingressRoute: u.ingressRoute.from(self.service, 'books.danielramos.me'),
  },
}
