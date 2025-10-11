local versions = import '../versions.json';
local immich = import 'media/immich.libsonnet';
local sftpgo = import 'media/sftpgo.libsonnet';
local gitea = import 'media/gitea.libsonnet';

{
  immich: immich.new(
    version=versions.immich.version,
  ),
  sftpgo: sftpgo.new(
    version=versions.sftpgo.version + '-alpine',
  ),
  gitea: gitea.new(
    version=versions.gitea.version,
  ),
}
