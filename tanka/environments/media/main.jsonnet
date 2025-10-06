local immich = import 'media/immich.libsonnet';
local sftpgo = import 'media/sftpgo.libsonnet';

{
  immich: immich.new(
    version='v2.0.1'
  ),
  sftpgo: sftpgo.new(
    version='v2.6.6-alpine'
  ),
}
