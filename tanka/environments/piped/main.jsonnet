local versions = import '../versions.json';
local piped = import 'piped/piped.libsonnet';

{
  piped: piped.new(
    frontendVersion=versions.piped.version,
    backendVersion=versions.pipedBackend.version,
    proxyVersion=versions.pipedProxy.version,
    bgHelperVersion=versions.pipedBgHelper.version,
  ),
}
