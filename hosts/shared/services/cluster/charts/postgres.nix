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
        apiVersion = "bitnami.com/v1alpha1";
        kind = "SealedSecret";
        metadata = {
          name = "postgres-secret";
          namespace = "databases";
        };
        spec = {
          encryptedData = {
            AUTHELIA_PASSWORD = "AgBLE6t7SrV5RckR4q0bYQblemQh9Jc+YwUEHUEv8hiqou8aD486O/4ke/iDGOPxmrr0OXii+hKBlocHixFZp8pMIyjFtiK11q0UYzpFWJ6F/3VMQ/EpAt2ztqHcxtHO0jSsbczxMbbjhblZvASR9fW+Nl0tZaiefi9wV6h3ZKxYsupubfzKExrDSS6x5wXRRWQrr9LvIsAUYkpYAEpPX7jlpGQEsZBxIpD9XYYRvPePi+K/+Gq3Cy0QyvdJM+bNsx50TyCL9G1BEz0x7sOT0xOGBW+DmlRQFLBxfn2FWRYyvPtMraCvM/USiqkGYEaIprugpPP5Er3LpWQka7dFKJfh0i5OkP7RTGma82aNGBdYjSQqfDTPNKjtD8D4yFvZAGBHKPCCJW3xfguF/7Su17KDWAKz3b6mc9/XqDGB0aIsBIAqqBLcaVNAYbXQP4UiMdgbVPqxH+CxUdFpgp+1YIIMGggKVH0VDzArEfpm8Q4bSNbVsSDbG+WRTlb5hw2KA/fDJMjXnTo4oeiYKDincFdem9tiYaYHTst5B0JNtbiHHh6Zb9cKOHr8YNtbjtugWE2AldDAiogrPXpcmHgsYOhOHQYpoLNwUlB2tWPWsfI6RfBBYHfoBStLtvEKm9Oy2vpDF8WXmZheF6MCzt2qLl/15aeS7+Wee11L3FGM5oLIzGQQDcOEmjWcEWIPfTVCqpNH5tK2CXqX46ZWa6OMyAnZ79L2wQiswOw+9JAog/Sbd0xHuvQ=";
            IMMICH_PASSWORD = "AgCnPv05aPCCS/FhHKQ6sx52j9358ADjW+8b/8mQJEGlNb+vWNqvRzCDPwAnF0sYuWoThWI5tuJLRmQy4fJ7Uzd/AuzXl9v0vJbCntKKBTUOG/Hktvk4WcSOpkMcmQBpJkHLy3BkoxMNBvt34I8vTtg1czD0SZjvX3TnQlry85Dmu2RKrDeV0gY9rLHcDI/+zgDMLsi28OIzYW6Y2gsP1LYlbRTiVzL2Nr2EziA04f9tXMZTyK0efvkEq4ZeSKlGk6mRpWq/jkX4bKzHv/ZVcNuVlCUAS/aqUSRo5/bNJaMv0PWAtyErIG/+ci+d4uXZKiNsN7+rofLImLdQV8LvBewBdclnZpwf9EYGbesVzO6yHXm1ZLTshnMWL2nyrqwqeOqqudlnbZZPUx76rCmFaVEE3ki6SGYPNkaLlIpMVrUtTrxVgfDBk040tstSIMsXVM41PXxsE9UhrnbJL3iLDFQUGpfV1DLOVSAd2/YIED0zwTQ8N03yf70lE+pXp2EmTNSTJHYOSsiglMigKzjKXtKHIiH4ujlmrOGuJ7z/af6V4IEKIxmKG+CwC5P/3REBpt23OFgBBj/00dnxVmzI0Fz5/P1XLacToMfHdUcW4+lDEkJvzDPT+Cbb0Q6Wuf0A/4IPidHW5fYi35opQ3LoOQ970+9ZaAqsI/y0OP2HEhSbNB0YUM3Ku5o4zaqwWL5FkPpLukHhXxDUzXaWFaFt1d0F+s7rlHYFMq0OnWIj8su6ZYiaiW0=";
          };
          template = {
            metadata = {
              name = "postgres-secret";
              namespace = "databases";
            };
            type = "Opaque";
          };
        };
      }
    ];
  };
}
