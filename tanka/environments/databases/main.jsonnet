local versions = import '../versions.json';
local postgres = import 'databases/postgres.libsonnet';
local valkey = import 'databases/valkey.libsonnet';

{
  postgres: postgres.new(
    version='17-vectorchord0.4.3-pgvector0.8.0-pgvectors0.3.0'
  ),
  valkey: valkey.new(
    version=versions.valkey.version + '-alpine'
  ),
}
