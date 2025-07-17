local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  image(name, version):: name + ':' + version,
  secretRef(secretName, key):: k.core.v1.envVar.fromSecretRef(key, secretName, key),
  extractConfig(configMapName, keys):: [
    k.core.v1.envVar.withName(key) +
    k.core.v1.envVar.valueFrom.configMapKeyRef.withKey(key) +
    k.core.v1.envVar.valueFrom.configMapKeyRef.withName(configMapName)
    for key in keys
  ],
  extractSecrets(secretName, keys):: [
    self.secretRef(secretName, key)
    for key in keys
  ],
  base64Keys(object):: {
    [key]: std.base64(object[key])
    for key in std.objectFields(object)
  },
  localPv(name, storage, path):: {
    apiVersion: 'v1',
    kind: 'PersistentVolume',
    metadata: {
      name: name,
    },
    spec: {
      capacity: {
        storage: storage,
      },
      accessModes: [
        'ReadWriteOnce',
      ],
      storageClassName: 'local-path',
      persistentVolumeReclaimPolicy: 'Retain',
      hostPath: {
        path: path,
        type: 'DirectoryOrCreate',
      },
    },
  },
  localPvc(name, pv, storage):: {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: name,
    },
    spec: {
      accessModes: [
        'ReadWriteOnce',
      ],
      storageClassName: 'local-path',
      resources: {
        requests: {
          storage: storage,
        },
      },
      volumeName: pv,
    },
  },
  joinedEnv(name, elements):: [
    k.core.v1.envVar.new(name, std.join(',', elements)),
  ],
}
