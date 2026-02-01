local versions = import '../versions.json';
local deluge = import 'arr/deluge.libsonnet';
local jdownloader = import 'arr/jdownloader.libsonnet';
local norznab = import 'arr/norznab.libsonnet';
local radarr = import 'arr/radarr.libsonnet';
local sonarr = import 'arr/sonarr.libsonnet';

{
  sonarr: sonarr.new(
    version=versions.sonarr.version,
  ),
  radarr: radarr.new(
    version=versions.radarr.version,
  ),
  deluge: deluge.new(
    version=versions.deluge.version,
  ),
  jdownloader: jdownloader.new(
    version=versions.jdownloader.version,
  ),
  norznab: norznab.new(
    version='main-86d3dad',
  ),
}
