{ config, lib, pkgs, ... }:

{
  # Enable strongswan with swanctl (modern configuration interface)
  services.strongswan-swanctl = {
    enable = true;

    # Main strongswan configuration (minimal)
    strongswan = {};

    # swanctl configuration for IKEv2
    swanctl = {
      connections = {
        nas-vpn = {
          version = 2;  # IKEv2 only
          local_addrs = [ "192.168.1.200" ];

          local.vpn-server = {
            auth = "eap";  # Use EAP authentication (server side of EAP-TLS)
            certs = [ "vpn.danielramos.me.pem" ];  # Relative path from x509 directory
            id = "vpn.danielramos.me";
            aaa_id = "vpn.danielramos.me";  # Identity for EAP-TLS server certificate
          };

          remote.vpn-client = {
            id = "%any";  # Accept any client with valid certificate
            auth = "eap-tls";  # Enable EAP-TLS authentication for macOS/iOS compatibility
            eap_id = "%any";  # Accept any EAP identity format (RFC822 email or FQDN)
            cacerts = [ "ca.pem" ];  # Relative path from x509ca directory
          };

          children.nas-vpn = {
            local_ts = [ "192.168.1.0/24" ];
            remote_ts = [ "10.10.10.0/24" ];
            esp_proposals = [
              "aes256gcm16-ecp384"
            ];
            dpd_action = "clear";
            start_action = "none";
          };

          pools = [ "nas-pool" ];

          # Cipher proposals - Compatible with Apple IKEv2 clients (macOS/iOS)
          proposals = [
            "aes256gcm16-prfsha256-ecp256"
            "aes256gcm16-prfsha256-modp2048"
            "aes256-sha256-prfsha256-ecp256"
            "aes256-sha256-prfsha256-modp2048"
          ];

          # Key exchange and rekey settings
          rekey_time = "0";  # No automatic rekey
          dpd_delay = "300s";  # 5 minutes
          dpd_timeout = "35s";
        };
      };

      pools = {
        nas-pool = {
          addrs = "10.10.10.0/24";
          dns = [ "192.168.1.200" ];  # Point to dnsmasq
        };
      };
    };
  };

  # Firewall rules for IKEv2/IPsec
  networking.firewall = {
    allowedUDPPorts = [
      500   # IKE
      4500  # NAT-T (UDP encapsulation)
    ];

    # Allow ESP protocol (IPsec Encapsulating Security Payload)
    extraCommands = ''
      iptables -A INPUT -p esp -j ACCEPT
      iptables -A OUTPUT -p esp -j ACCEPT
      iptables -A FORWARD -s 10.10.10.0/24 -d 192.168.1.0/24 -j ACCEPT
      iptables -A FORWARD -s 192.168.1.0/24 -d 10.10.10.0/24 -j ACCEPT
    '';

    extraStopCommands = ''
      iptables -D INPUT -p esp -j ACCEPT 2>/dev/null || true
      iptables -D OUTPUT -p esp -j ACCEPT 2>/dev/null || true
      iptables -D FORWARD -s 10.10.10.0/24 -d 192.168.1.0/24 -j ACCEPT 2>/dev/null || true
      iptables -D FORWARD -s 192.168.1.0/24 -d 10.10.10.0/24 -j ACCEPT 2>/dev/null || true
    '';
  };

  # Enable IP forwarding for VPN routing
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
  };

  # NAT configuration for VPN -> LAN routing
  networking.nat = {
    enable = true;
    externalInterface = "enp4s0";
    internalInterfaces = [ "ipsec0" ];
    internalIPs = [ "10.10.10.0/24" ];
  };

  # Copy certificates and keys to /etc/swanctl using NixOS declarative file management
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

  # Ensure strongswan package is available
  environment.systemPackages = with pkgs; [
    strongswan
    openssl
    util-linux  # for uuidgen
  ];

  # Install certificate generation script for clients
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
