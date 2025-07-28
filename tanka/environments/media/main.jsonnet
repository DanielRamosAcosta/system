local immich = import 'media/immich.libsonnet';
local stratus = import 'media/stratus.libsonnet';

{
  immich: immich.new(
    version='v1.135.3'
  ),
  stratus: stratus.new(
    version='main-de53414'
  ),
}
