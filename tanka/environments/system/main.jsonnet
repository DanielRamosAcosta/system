local cloudflare = import 'system/cloudflare.libsonnet';

{
  cloudflare: cloudflare.new(
    version='1.15.1'
  ),
}
