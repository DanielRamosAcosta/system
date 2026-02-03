local versions = import '../versions.json';
local invidious = import 'piped/invidious.libsonnet';

{
  invidious: invidious.new(
    invidiousVersion='2026.01.30-b521e3b',
    invidiousCompanionVersion='master-05cd859'
  ),
}
