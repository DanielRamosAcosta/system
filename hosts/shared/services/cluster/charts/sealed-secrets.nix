{ config, ... }:
{
  services.k3s.autoDeployCharts.sealed-secrets = {
    name = "sealed-secrets";
    repo = "https://bitnami-labs.github.io/sealed-secrets";
    hash = "sha256-QZg09UNyUtaZ+wbY6EF5mhNhefejftJpvgI3jN1z+TY=";
    targetNamespace = "kube-system";
    version = "2.17.3";
  };
}
