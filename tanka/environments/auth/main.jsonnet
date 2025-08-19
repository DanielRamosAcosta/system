local authelia = import 'auth/authelia.libsonnet';
local satph = import 'auth/satph.libsonnet';

{
  authelia: authelia.new(
    version='4.39.5'
  ),
  satph: satph.new(
    version='main-d35382b'
  )
}
