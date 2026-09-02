{ pkgs, ... }:
let
  cyberpunkCover = pkgs.fetchurl {
    url = "https://cdn.cloudflare.steamstatic.com/steam/apps/1091500/library_600x900.jpg";
    hash = "sha256-oVc9oX4d8yNB9fPLmYn/Kc+CgBW0DC4xIYDX9um+Dbo=";
  };
in
{
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
    autoStart = true;
    settings = {
      origin_web_ui_allowed = "lan";
      csrf_allowed_origins = "https://192.168.1.45:47990";
      gamepad = "x360";
    };
    applications = {
      env.PATH = "$(PATH):/run/current-system/sw/bin";
      apps = [
        {
          name = "Desktop";
        }
        {
          name = "Cyberpunk 2077";
          detached = [ "steam steam://rungameid/1091500" ];
          image-path = "${cyberpunkCover}";
          auto-detach = "true";
        }
      ];
    };
  };
}
