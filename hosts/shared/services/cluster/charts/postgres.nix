{ config, ... }:
{
  services.k3s = {
    # autoDeployCharts.postgres = {
    #   name = "oci://registry-1.docker.io/bitnamicharts/postgresql";
    #   targetNamespace = "database";
    #   version = "7.13.0";
    #   values = ./postgres.values.yaml;
    # };

    manifests.postgres.content = [
      {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata = {
          name = "postgres-pv";
        };
        spec = {
          capacity = {
            storage = "20Gi";
          };
          volumeMode = "Filesystem";
          accessModes = [
            "ReadWriteOnce"
          ];
          persistentVolumeReclaimPolicy = "Retain";
          storageClassName = "local-storage";
          local = {
            path = "/mnt/data/services/postgres";
          };
          nodeAffinity = {
            required = {
              nodeSelectorTerms = [
                {
                  matchExpressions = [
                    {
                      key = "kubernetes.io/hostname";
                      operator = "In";
                      values = [ "nixos" ];
                    }
                  ];
                }
              ];
            };
          };
        };
      }
      {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "postgres-pvc";
        };
        spec = {
          volumeName = "postgres-pv";
          accessModes = [
            "ReadWriteOnce"
          ];
          storageClassName = "local-storage";
          resources = {
            requests = {
              storage = "20Gi";
            };
          };
        };
      }
    ];
  };
}
