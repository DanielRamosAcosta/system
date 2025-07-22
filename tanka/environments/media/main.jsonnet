local immich = import 'media/immich.libsonnet';
local nextcloud = import 'media/nextcloud.libsonnet';

{
  immich: immich.new(
    version='v1.135.3'
  ),
  nextcloud: nextcloud.new(
    version='31.0.7-fpm-alpine'
  ),
}
