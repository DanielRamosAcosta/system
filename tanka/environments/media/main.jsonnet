local immich = import 'media/immich.libsonnet';

{
  immich: immich.new(
    version='v1.135.3'
  )
}
