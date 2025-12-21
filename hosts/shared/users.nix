{ config, pkgs, ... }:
let
  gitShellScript = pkgs.writeShellScriptBin "git-shell-wrapper" ''
    #!/bin/sh
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

    # Get the Gitea pod name dynamically
    POD_NAME=$(${pkgs.kubectl}/bin/kubectl get pods -n media -l app.kubernetes.io/name=gitea -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

    if [ -z "$POD_NAME" ]; then
      echo "Error: No se pudo encontrar el pod de Gitea"
      exit 1
    fi

    # Execute the SSH command inside the Gitea pod
    exec ${pkgs.kubectl}/bin/kubectl exec -i -n media "$POD_NAME" -- sh -c "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" /usr/local/bin/gitea serv"
  '';
in
{
  environment.systemPackages = [ gitShellScript ];

  users = {
    mutableUsers = false;

    users = {
      dani = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.age.secrets.dani-hashed-password.path;
        openssh.authorizedKeys.keys = [
          (builtins.readFile ../../id_dani.pub)
        ];
      };

      alex = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.age.secrets.alex-hashed-password.path;
        openssh.authorizedKeys.keys = [
          (builtins.readFile ../../id_alex.pub)
        ];
      };

      ana.isNormalUser = true;
      gabriel.isNormalUser = true;
      cris.isNormalUser = true;

      git = {
        isSystemUser = true;
        group = "git";
        shell = "${gitShellScript}/bin/git-shell-wrapper";
        home = "/var/lib/git";
        createHome = true;
      };
    };

    groups.git = {};
  };

  security.sudo.extraRules = [
    {
      users = [ "dani" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
