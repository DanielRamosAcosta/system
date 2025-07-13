{ pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
  
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  
  users.users.root.openssh.authorizedKeys.keys = [
    (builtins.readFile ../../id_dani.pub)
  ];
}
