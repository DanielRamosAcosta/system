local versions = import '../versions.json';
local cloudflare = import 'system/cloudflare.libsonnet';
local heartbeat = import 'system/heartbeat.libsonnet';

{
  cloudflare: cloudflare.new(
    version=versions.cloudflare.version
  ),
  heartbeat: heartbeat.new(),
}
