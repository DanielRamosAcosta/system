local postgres = import 'databases/postgres.libsonnet';
local valkey = import 'databases/valkey.libsonnet';
local u = import 'utils.libsonnet';

{
  postgres: postgres.new(u.image(
    'ghcr.io/immich-app/postgres',
    '17-vectorchord0.4.3-pgvector0.8.0-pgvectors0.3.0'
  )),
  valkey: valkey.new(u.image(
    'valkey/valkey',
    '7.2.10-alpine'
  )),
}
