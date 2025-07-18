local traefik = import 'proxy/traefik.libsonnet';

{
  dashboard: traefik.new(),
}
