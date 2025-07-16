local postgres = import 'databases/postgres.libsonnet';
local u = import 'utils.libsonnet';

{
  postgres: postgres.new(u.image(
    'ghcr.io/immich-app/postgres',
    '17-vectorchord0.4.3-pgvector0.8.0-pgvectors0.3.0'
  )),
}
