{ config, utilities, lib, ... }:
{
  services.k3s = {
    autoDeployCharts.postgres = {
      name = "oci://registry-1.docker.io/bitnamicharts/postgresql";
      targetNamespace = "databases";
      version = "7.13.0";
      values = {
        image = {
          registry = "ghcr.io";
          repository = "danielramosacosta/bitnami-postgresql-vectorchord-pgvectors";
          tag = "main-65311a2";
        };
        global = {
          security = {
            allowInsecureImages = true;
          };
        };
        auth = {
          postgresPassword = "mysupersecurepassword";
        };
        postgresqlSharedPreloadLibraries = "pgaudit,vchord";
        primary = {
          persistence = {
            enabled = true;
            existingClaim = "postgres-pvc";
          };
          resources = {
            requests = {
              memory = "512Mi";
              cpu = "250m";
            };
            limits = {
              memory = "1Gi";
              cpu = "500m";
            };
          };
          extraEnvVars = [
            { name = "DATABASE_USERS"; value = "immich,authelia"; }
            { name = "USER_PASSWORD_IMMICH"; value = "c0aec791-f4a4-4873-aed7-1e343daee907"; }
            { name = "USER_PASSWORD_AUTHELIA"; value = "d9a14e19-2495-4598-820e-21a50c0f5f10"; }
          ];
          initdb = {
            scripts = {
              "01_create_users.sh" = lib.readFile ./01_create_users.sh;
            };
          };
        };
        readReplicas = {
          resources = {
            requests = {
              memory = "512Mi";
              cpu = "250m";
            };
            limits = {
              memory = "1Gi";
              cpu = "500m";
            };
          };
        };
        volumePermissions = {
          enabled = true;
          resources = {
            requests = {
              memory = "512Mi";
              cpu = "250m";
            };
            limits = {
              memory = "1Gi";
              cpu = "500m";
            };
          };
        };
      };
    };
  
    manifests.postgres-pv.content = {
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
    };

    manifests.postgres-pvc.content = {
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
    };

    manifests.postgres-secrets.content = utilities.createSealedSecret {
      name = "postgres-secrets";
      namespace = "databases";
      encryptedData = {
        POSTGRES_PASSWORD = "AgCcFkh1axqWWEgmnVk6vEoSPuNkjxKxx6+j55QK1NsA/sqcPLXKIx0Ki4HyqZSOQpYdl63BVYnFK/IkpfVZEICexy0WadDfvYfN36TI39og6olEi2nPxKZ4bxJwcUc3AOPgrYWOGPPUqY59ermjgvGPO3Ow+53VHpn/fMFjdoGjVqHeMi4KdhWgnhiWMeW1bAcOETIpYGbdSvPuQKonq9sXuLRsI605JtZ3Rk7bKTwq1+V4px6P9sbMO3Z1IMk58FOSI5NTAepOxYsaHENXA/NssbDEPXBk2TfJGRSGoXb5KAJvb1l6dyGoBDVZ2z25B/ScjSss/rbCiY487hQMGwBYMOEQQn+5vGiZIaI7aw/jRXdembr+A7crqGHYLwPFK95Wgp8Ysogtp1QAtsca9XeCLMbiv3CMnoIDHDJQBkftjbn6uJPdzIkdx/Iizw2howyilAr+syZlde5AzjFY71LeI4sPszzf4Rz0KTq5GJSfQx0FF0oz5FXWOSSq50hXNKUtJp2BSwRSPRKiU/Z4SUMPDFlhxBMBcnoMjO4CgQBNsoos7weu6Ohdm9psCGsTtsYvf5YxDxotR9LzNKrUv9UgS1193qpD5tI2kR8091sdd5RFrfPejoEykdW+MXG9gkzuV0QdbDXzzsXJ/AnLFQcWlMdpdNMNtBZwskHyB40vGzjVxydIs30QFSMbJWGQlo+ltiTQ+49xYAQqOW/KfHW9j5awcBMuptt7904OXNW6Y3QWb5g=";
        AUTHELIA_PASSWORD = "AgAYBMIy/Nhm5ucWjmbqroKyAdhy0SFJqM+3aUXNoakoP4fZpduB7UDmR0IlTpGhu2BkmymBrvr3crGae7LlJVic9SrNZkvk9eLVRMEAwRFzez9QEJyOih2xsXPgWunpFhKAGAdfT5AbCupmUUJ0FFzXgSsBVY9QRr2GJxMam06Rr5mHm7+gugG/MbajRlxcuZ2zCChcqlqaa+EKrJOJOUQErZ1YjmLxnB7MVesOuo4riVn9wUqnOX4A9wId4nhElybO8C1C3DAM0zblphmdinoAAA0lPBdcOwsc5oerurCbkPEeaxyFMY6BVsaRa2uuBCw/J2uCRosbv88+4wWqWjjKb8KbjfqCebNIBDtZ0pNaMkWWKKkShp9bfht4ej/avxHsE7CdEyfP9lh0bMWKrb6DwzPMjxAKYrl5dvLmW/h1eYSYjNtqzKiS6cR5qBlvcUuFV6Dal2j+lfRZRkd/7XyPzSFML7ZzFZLJBp6GGrug+R8Mqse7XSuGW6bkyWAfUnUH2PIhgfEPJU4uwVburZzdbr7Og3vw7VOGZW35a3z2pxoFOw/7vGyC0JgyWahOPl+oHGYSlVnQZmDAIYmv4q761BSYo+k6Y68Rz6Gf4rZwPWjK3pXB82nRIFiyRC9E8OnkGSW46maDh4MJvYHGuZyw0DoR0QNKfGtvMTohOIx9dGNaP8EnJWj1fE3SP13n4QHdogdYkdhu4epcnxylC3kN6z5GBcWPBZYTI+n/coqPylIr7eY=";
        IMMICH_PASSWORD = "AgCV+Lt1yns+hXYH1VWDlHwKPmqfjoKv71L/abA6kIX2wuapEp7IyNoNj2NZwVaQKSKnPGfAKbTftcwvgUJc5ex4sDohH7lyCbr4EXV3Ij+sI67nn1hL9Qgga+Jx7NV0RG43rr0NP+7reUCDoaagRYcwHLrsExIf2JLwAADZfS+n5PsSbtTrv0LDKUCweU6whE+iosjpcIRG0OGKJjcxk1T3kYyPdGpNeruczo7jdh5ZEsLN0mLLKRUZ4Q+z4Byytm7LBZrlK0+wpyg73Ac+JH2r5rgrxW7/6wj15N5CASrDtJec1tUb9joEOne+0qwaJXALzYf4f1kR4FCB93q4sbySiRmi4NnrNuyfTLnSHjc74R4pC2QTuwpL3bDaT5i1wPrAzHKF35+tBhiJAWmFK7ZtUqIH1iwKRttjwO61AiUiLGf5SwdcogVTQP8r6bfUhKuztfYeq6nifpjaxz8n414aDUoJngf//nDYVzQHkWNinh/U8yihmTwd6TLptyHRtNPIkIANxfNf0ZV8gFFIzURb8zcol3avdqcdKd+jdiKOlOS25mn01uKj/CzLmE81NcpqvPfVqFgnRdCLU5Z8uM+8qyHqYaynQqqNZwyfSIdneJNoVOdGsZt6VIb2a2dr1ILihF1K/XHrFA8bW7XtoiucVXI2f1Bac6jCnfQMHWpk0xAajp4XTH88akt7qSJRhCbGE2R/2NQlEJf2SDYUMnA8fSRg5CP4plA04LXZLr92AhPYtsk=";
      };
    };

    manifests.default-secrets.content = utilities.createSealedSecret {
      name = "postgres-secrets";
      namespace = "default";
      encryptedData = {
        IMMICH_PASSWORD = config.services.k3s.manifests.postgres-secrets.content.spec.encryptedData.IMMICH_PASSWORD;
      };
    };
  };
}
