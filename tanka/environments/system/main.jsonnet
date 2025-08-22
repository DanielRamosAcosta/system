local cloudflare = import 'system/cloudflare.libsonnet';
local heartbeat = import 'system/heartbeat.libsonnet';

{
  cloudflare: cloudflare.new(
    version='1.15.1'
  ),
  heartbeat: heartbeat.new(),
}
