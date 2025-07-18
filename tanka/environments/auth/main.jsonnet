local authelia = import 'auth/authelia.libsonnet';

{
  authelia: authelia.new(
    version='4.39.5'
  ),
}
