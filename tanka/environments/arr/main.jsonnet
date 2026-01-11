local versions = import '../versions.json';
local sonarr = import 'arr/sonarr.libsonnet';
local deluge = import 'arr/deluge.libsonnet';

{
  sonarr: sonarr.new(
    version=versions.sonarr.version,
  ),
  deluge: deluge.new(
    version=versions.deluge.version,
  ),
}
