{ config, lib, pkgs, ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };

    extraConfig = ''
      # Gitea SSH Passthrough - Use AuthorizedKeysCommand to fetch keys from Gitea
      Match User git
        AuthorizedKeysCommand /etc/ssh/gitea-authorized-keys.sh %u %t %k
        AuthorizedKeysCommandUser git
    '';
  };

  environment.etc."ssh/gitea-authorized-keys.sh" = {
    source = pkgs.substitute {
      src = ./scripts/gitea-authorized-keys.sh;
      substitutions = [
        "--replace" "#!/@/bin/bash@" "#!${pkgs.bash}/bin/bash"
        "--replace" "@kubectl@" "${pkgs.kubectl}/bin/kubectl"
      ];
    };
    mode = "0755";
  };

  environment.etc."gitea-shell" = {
    source = pkgs.substitute {
      src = ./scripts/gitea-shell.sh;
      substitutions = [
        "--replace" "#!/@/bin/bash@" "#!${pkgs.bash}/bin/bash"
        "--replace" "@kubectl@" "${pkgs.kubectl}/bin/kubectl"
      ];
    };
    mode = "0755";
  };
}
