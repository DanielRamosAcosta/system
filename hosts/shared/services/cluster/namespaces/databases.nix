{ config, ... }:
{
  services.k3s.manifests.databases.content = {
    apiVersion = "v1";
    kind = "Namespace";
    metadata = {
      name = "databases";
      labels = {
        "kubernetes.io/metadata.name" = "databases";
      };
    };
  };
}
