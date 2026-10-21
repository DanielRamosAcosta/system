{
  fileSystems."/persist".neededForBoot = true;

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/home/dani"
      "/var/lib/nixos"
      "/var/lib/docker"
      "/var/lib/clamav"
      "/opt/paloaltonetworks"
      "/var/lib/weston"
    ];

    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}
