local versions = import '../versions.json';
local booklore = import 'media/booklore.libsonnet';
local gitea = import 'media/gitea.libsonnet';
local immich = import 'media/immich.libsonnet';
local jellyfin = import 'media/jellyfin.libsonnet';
local sftpgo = import 'media/sftpgo.libsonnet';

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
  booklore: booklore.new(
    version=versions.booklore.version,
  ),
  jellyfin: jellyfin.new(
    version=versions.jellyfin.version,
  ),
}
