{ config, lib, pkgs, ... }:

{
  services.strongswan-swanctl = {
    enable = true;

    swanctl = {
      connections = {
        nas-vpn = {
          version = 2;
          local_addrs = [ "192.168.1.200" ];

          local.vpn-server = {
            auth = "eap";
            certs = [ "vpn.danielramos.me.pem" ];
            id = "vpn.danielramos.me";
            aaa_id = "vpn.danielramos.me";
          };

          remote.vpn-client = {
            id = "%any";
            auth = "eap-tls";
            eap_id = "%any";
            cacerts = [ "ca.pem" ];
          };

          children.nas-vpn = {
            local_ts = [ "10.10.20.0/24" ];
            remote_ts = [ "10.10.10.0/24" ];
            esp_proposals = [
              "aes256gcm16-ecp384"
            ];
            dpd_action = "clear";
            start_action = "none";
          };

          pools = [ "nas-pool" ];

          proposals = [
            "aes256gcm16-prfsha256-ecp256"
            "aes256gcm16-prfsha256-modp2048"
            "aes256-sha256-prfsha256-ecp256"
            "aes256-sha256-prfsha256-modp2048"
          ];

          dpd_delay = "300s";
          dpd_timeout = "35s";
        };
      };

      pools = {
        nas-pool = {
          addrs = "10.10.10.0/24";
          dns = [ "192.168.1.200" ];
        };
      };
    };
  };

  networking.firewall = {
    allowedUDPPorts = [
      500
      4500
    ];

    extraInputRules = ''
      ip protocol esp accept
    '';

    extraForwardRules = ''
      ip saddr 10.10.10.0/24 ip daddr 10.10.20.0/24 accept
      ip saddr 10.10.20.0/24 ip daddr 10.10.10.0/24 accept
    '';
  };

  networking.nftables.enable = true;

  networking.nftables.tables.vpn_nat = {
    name = "vpn_nat";
    family = "inet";
    content = ''
      chain prerouting {
        type nat hook prerouting priority -100; policy accept;
        ip saddr 10.10.10.0/24 ip daddr 10.10.20.200 tcp dport { 445, 139 } dnat to 192.168.1.200
      }
    '';
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
  };

  networking.nat = {
    enable = true;
    externalInterface = "enp4s0";
    internalInterfaces = [ "ipsec0" ];
    internalIPs = [ "10.10.10.0/24" ];
  };

  environment.etc = {
    "swanctl/private/vpn.danielramos.me.pem" = {
      source = config.age.secrets.strongswan-server-key-pem.path;
      mode = "0600";
    };
    "swanctl/x509/vpn.danielramos.me.pem" = {
      source = config.age.secrets.strongswan-server-cert-pem.path;
      mode = "0644";
    };
    "swanctl/x509ca/ca.pem" = {
      source = config.age.secrets.strongswan-ca-cert-pem.path;
      mode = "0644";
    };
  };

  environment.etc."scripts/generate-strongswan-client.sh" = {
    source = pkgs.substitute {
      src = ./scripts/generate-strongswan-client.sh;
      substitutions = [
        "--replace" "#!/@/bin/bash@" "#!${pkgs.bash}/bin/bash"
        "--replace" "@openssl@" "${pkgs.openssl}/bin/openssl"
        "--replace" "@uuidgen@" "${pkgs.util-linux}/bin/uuidgen"
        "--replace" "@ca_cert@" "${config.age.secrets.strongswan-ca-cert-pem.path}"
        "--replace" "@ca_key@" "${config.age.secrets.strongswan-ca-key-pem.path}"
      ];
    };
    mode = "0755";
  };
}
