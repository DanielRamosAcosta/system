{ config, utilities, ... }:
{
  services.k3s = {
    # autoDeployCharts.postgres = {
    #   name = "oci://registry-1.docker.io/bitnamicharts/postgresql";
    #   targetNamespace = "databases";
    #   version = "7.13.0";
    #   values = ./postgres.values.yaml;
    # };

    manifests.postgres.content = [
      {
        apiVersion = "v1";
        kind = "PersistentVolume";
        metadata = {
          name = "postgres-pv";
          namespace = "databases";
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
          namespace = "databases";
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
      {
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          name = "user-passwords";
          namespace = "databases";
        };
        type = "Opaque";
        data = {
          USER_PASSWORD_IMMICH = (utilities.toBase64 (builtins.readFile config.age.secrets.immich-password.path));
          USER_PASSWORD_AUTHELIA = (utilities.toBase64 (builtins.readFile config.age.secrets.authelia-password.path));
        };
      }
    ];
  };
}
