{ config, lib, pkgs, ... }:
let
  bundle = "/run/corporate-ca/ca-bundle.crt";
in
{
  age.secrets.corporate-certificate.file = ../../secrets/corporate-certificate.age;

  system.activationScripts.corporate-ca = {
    deps = [ "agenix" ];
    text = ''
      mkdir -p /run/corporate-ca
      {
        cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
        echo
        cat ${config.age.secrets.corporate-certificate.path}
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
