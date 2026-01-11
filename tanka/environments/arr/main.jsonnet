local versions = import '../versions.json';
local sonarr = import 'arr/sonarr.libsonnet';
local deluge = import 'arr/deluge.libsonnet';
local prowlarr = import 'arr/prowlarr.libsonnet';

{
  sonarr: sonarr.new(
    version=versions.sonarr.version,
  ),
  deluge: deluge.new(
    version=versions.deluge.version,
  ),
  prowlarr: prowlarr.new(
    version=versions.prowlarr.version,
  ),
}
