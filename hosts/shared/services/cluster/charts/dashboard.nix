{ config, ... }:
{
  services.k3s.autoDeployCharts.kubernetes-dashboard = {
    name = "kubernetes-dashboard";
    repo = "https://kubernetes.github.io/dashboard/";
    hash = "sha256-/3vJZF3pAe1Jo0LGPnXqQQ7bwr3n4wR6kgfuckxvAeQ=";
    targetNamespace = "kubernetes-dashboard";
    createNamespace = true;
    version = "7.13.0";
  };
}
