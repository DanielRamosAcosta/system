local versions = import '../versions.json';
local immich = import 'media/immich.libsonnet';
local sftpgo = import 'media/sftpgo.libsonnet';
local gitea = import 'media/gitea.libsonnet';
local booklore = import 'media/booklore.libsonnet';
local jellyfin = import 'media/jellyfin.libsonnet';
local jdownloader = import 'media/jdownloader.libsonnet';
local transmission = import 'media/transmission.libsonnet';

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
  jdownloader: jdownloader.new(
    version=versions.jdownloader.version,
  ),
  transmission: transmission.new(
    version=versions.transmission.version,
  ),
}
