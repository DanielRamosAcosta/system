local immich = import 'media/immich.libsonnet';
local sftpgo = import 'media/sftpgo.libsonnet';
local versions = import '../versions.jsonnet';

{
  immich: immich.new(
    version=versions.immich.version,
  ),
  sftpgo: sftpgo.new(
    version=versions.sftpgo.version + '-alpine',
  ),
}
