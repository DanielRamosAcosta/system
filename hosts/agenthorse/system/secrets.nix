{
  age.identityPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];

  age.secrets = {
    dani-hashed-password.file = ../../../secrets/dani-hashed-password.age;

    context7-api-key = {
      file = ../../../secrets/context7-api-key.age;
      owner = "dani";
    };

    grafana-self-hosted-token = {
      file = ../../../secrets/grafana-self-hosted-token.age;
      owner = "dani";
    };

    gpg-signing-key = {
      file = ../../../secrets/gpg-signing-key.age;
      owner = "dani";
    };
  };
}
