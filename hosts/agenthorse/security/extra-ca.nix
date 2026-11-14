{ config, lib, pkgs, ... }:
let
  bundle = "/run/extra-ca/ca-bundle.crt";
in
{
  age.secrets.extra-ca.file = ../../../secrets/extra-ca.age;

  system.activationScripts.extra-ca = {
    deps = [ "agenix" ];
    text = ''
      mkdir -p /run/extra-ca
      {
        cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
        echo
        cat ${config.age.secrets.extra-ca.path}
      } > ${bundle}.tmp
      chmod 0444 ${bundle}.tmp
      mv ${bundle}.tmp ${bundle}
    '';
  };

  environment.etc = {
    "ssl/certs/ca-certificates.crt".source = lib.mkForce bundle;
    "ssl/certs/ca-bundle.crt".source = lib.mkForce bundle;
    "pki/tls/certs/ca-bundle.crt".source = lib.mkForce bundle;
  };
}
