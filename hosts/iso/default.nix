{ pkgs, modulesPath, ... }: {
  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  
  users.users.root.openssh.authorizedKeys.keys = [
    (builtins.readFile ../../id_dani.pub)
  ];
}
