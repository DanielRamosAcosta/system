local cloudflare = import 'system/cloudflare.libsonnet';
local heartbeat = import 'system/heartbeat.libsonnet';
local versions = import '../versions.json';

{
  cloudflare: cloudflare.new(
    version=versions.cloudflare.version
  ),
  heartbeat: heartbeat.new(),
}
