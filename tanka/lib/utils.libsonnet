local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  local u = self,

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
  jsonStringify(object):: std.manifestJsonEx(object, '  '),
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
  keysFromSecret(secret):: std.objectFieldsAll(secret.data),
  fromFile(configMapOrSecret, path):: k.core.v1.volumeMount.new(configMapOrSecret.metadata.name, path + '/' + std.objectFieldsAll(configMapOrSecret.data)[0]) + k.core.v1.volumeMount.withSubPath(std.objectFieldsAll(configMapOrSecret.data)[0]),
  injectFiles(configMapOrSecrets):: k.apps.v1.deployment.spec.template.spec.withVolumes([
    if resource.kind == 'Secret' then
      k.core.v1.volume.fromSecret(resource.metadata.name, resource.metadata.name)
    else
      k.core.v1.volume.fromConfigMap(resource.metadata.name, resource.metadata.name)
    for resource in configMapOrSecrets
  ]),
  withoutSchema(object):: std.prune(std.mergePatch(object, { '$schema': null })),
  normalizeName(name):: std.strReplace(std.strReplace(name, '.', '-'), '_', '-'),
  pv: {
    localPathFor(component, storage, path):: u.localPv(component.metadata.name + '-pv', storage, path),
  },
  pvc: {
    from(pv):: u.localPvc(pv.metadata.name + 'c', pv.metadata.name, pv.spec.capacity.storage),
  },
  volumeMount: {
    fromFile(configMapOrSecret, path):: k.core.v1.volumeMount.new(configMapOrSecret.metadata.name, path + '/' + std.objectFieldsAll(configMapOrSecret.data)[0]) + k.core.v1.volumeMount.withSubPath(std.objectFieldsAll(configMapOrSecret.data)[0]),
  },
  volume: {
    fromConfigMap(configMap):: k.core.v1.volume.fromConfigMap(configMap.metadata.name, configMap.metadata.name),
    fromSecret(secret):: k.core.v1.volume.fromSecret(secret.metadata.name, secret.metadata.name),
  },
  secret: {
    forFile(fileName, content):: k.core.v1.secret.new(u.normalizeName(fileName), {
      [fileName]: std.base64(content),
    }),
    forEnv(component, content):: k.core.v1.secret.new(component.metadata.name + '-secret-env', u.base64Keys(content)),
  },
  configMap: {
    forFile(fileName, content):: k.core.v1.configMap.new(u.normalizeName(fileName), {
      [fileName]: content,
    }),
    forEnv(component, content):: k.core.v1.configMap.new(component.metadata.name + '-config-env', content),
  },
  envVars: {
    fromConfigMap(configMap):: u.extractConfig(configMap.metadata.name, std.objectFieldsAll(configMap.data)),
    fromSecret(secret):: u.extractSecrets(secret.metadata.name, u.keysFromSecret(secret)),
  },
  ingressRoute: {
    from(service, host):: {
      apiVersion: 'traefik.io/v1alpha1',
      kind: 'IngressRoute',
      metadata: {
        name: service.metadata.name + '-ingressroute',
      },
      spec: {
        entryPoints: [
          'websecure',
        ],
        routes: [
          {
            match: 'Host(`' + host + '`)',
            kind: 'Rule',
            services: [
              {
                name: service.metadata.name,
                port: service.spec.ports[0].port,
              },
            ],
          },
        ],
        tls: {
          certResolver: 'le',
        },
      },
    },
  },
}
