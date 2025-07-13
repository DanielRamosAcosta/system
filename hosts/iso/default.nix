{ pkgs, modulesPath, ... }: {
  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  environment.systemPackages = with pkgs; [
    git
  ];
  
  users.users.root.openssh.authorizedKeys.keys = [
    (builtins.readFile ../../id_dani.pub)
  ];
}
