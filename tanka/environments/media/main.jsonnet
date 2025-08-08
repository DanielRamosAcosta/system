local immich = import 'media/immich.libsonnet';
local sftpgo = import 'media/sftpgo.libsonnet';

{
  immich: immich.new(
    version='v1.137.3'
  ),
  sftpgo: sftpgo.new(
    version='v2.6.6-alpine'
  )
}
