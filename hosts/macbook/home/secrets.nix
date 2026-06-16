{ ... }:

{
  age = {
    identityPaths = [ "/Users/danielramos/.ssh/id_mac" ];
    secrets = {
      grafana-self-hosted-token.file = ../../../secrets/grafana-self-hosted-token.age;
      context7-api-key.file = ../../../secrets/context7-api-key.age;
    };
  };
}
