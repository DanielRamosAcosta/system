local immich = import 'media/immich.libsonnet';
local navidrome = import 'media/navidrome.libsonnet';
local sftpgo = import 'media/sftpgo.libsonnet';

{
  immich: immich.new(
    version='v1.139.3'
  ),
  sftpgo: sftpgo.new(
    version='v2.6.6-alpine'
  ),
  navidrome: navidrome.new(
    version='0.58.0'
  ),
}
