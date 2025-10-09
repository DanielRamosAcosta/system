local authelia = import 'auth/authelia.libsonnet';
local satph = import 'auth/satph.libsonnet';
local versions = import '../versions.jsonnet';

{
  authelia: authelia.new(
    version=versions.authelia.version
  ),
  satph: satph.new(
    version='main-d35382b'
  ),
}
