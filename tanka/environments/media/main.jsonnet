local immich = import 'media/immich.libsonnet';
local seafile = import 'media/seafile.libsonnet';

{
  immich: immich.new(
    version='v1.135.3'
  ),
  seafile: seafile.new(
    version='12.0.14'
  ),
}
