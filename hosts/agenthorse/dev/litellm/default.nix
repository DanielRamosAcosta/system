{ config, lib, pkgs, ... }:
let
  cfg = config.services.litellm;

  models = map (model: { responses = false; vision = true; efforts = [ ]; } // model) (import ./models.nix);

  codexAutoReviewModel = lib.findFirst (model: model.id == "gpt-6-luna") (builtins.head models) models;

  deployments = [ { slug = "codex-auto-review"; model = codexAutoReviewModel; } ]
    ++ map (model: { slug = model.id; inherit model; }) models;

  deployment = { slug, model }: {
    model_name = slug;
    litellm_params = {
      model = "github_copilot/${model.id}";
    } // lib.optionalAttrs (!model.responses) { use_chat_completions_api = true; };
    model_info = {
      supports_vision = model.vision;
      max_input_tokens = model.maxInput;
      max_output_tokens = model.maxOutput;
    } // lib.optionalAttrs model.responses { mode = "responses"; };
  };

  tokenDir = "${cfg.stateDir}/github_copilot";
  masterKeyFile = config.age.secrets.litellm-master-key.path;
  baseUrl = "http://127.0.0.1:${toString cfg.port}";

  copilotModels = pkgs.writeShellApplication {
    name = "litellm-copilot-models";
    text = ''
      exec sudo -u litellm env GITHUB_COPILOT_TOKEN_DIR=${tokenDir} \
        ${pkgs.python3.withPackages (ps: [ ps.litellm ])}/bin/python ${./copilot-models.py} \
        ${pkgs.writeText "litellm-declared-models.json" (builtins.toJSON models)}
    '';
  };

  codexCatalog = "/home/dani/.codex/litellm-models.json";

  codexCatalogScript = pkgs.writeShellScript "codex-litellm-catalog" ''
    codex="$HOME/.local/bin/codex"
    [ -x "$codex" ] || exit 0
    bundled=$(mktemp)
    trap 'rm -f "$bundled"' EXIT
    "$codex" debug models --bundled > "$bundled"
    mkdir -p "$HOME/.codex"
    ${pkgs.python3}/bin/python3 ${./codex-catalog.py} "$bundled" \
      ${pkgs.writeText "codex-litellm-deployments.json" (builtins.toJSON deployments)} \
      "${codexCatalog}"
  '';

  codexConfig = (pkgs.formats.toml { }).generate "codex-config.toml" {
    model = codexAutoReviewModel.id;
    model_provider = "litellm";
    model_catalog_json = codexCatalog;
    approval_policy = "on-request";
    approvals_reviewer = "auto_review";
    sandbox_mode = "workspace-write";
    model_providers.litellm = {
      name = "LiteLLM local";
      base_url = "${baseUrl}/v1";
      wire_api = "responses";
      auth = {
        command = "${pkgs.gnused}/bin/sed";
        args = [ "-n" "s/^LITELLM_MASTER_KEY=//p" masterKeyFile ];
      };
    };
  };
in
{
  age.secrets.litellm-master-key = {
    file = ../../../../secrets/litellm-master-key.age;
    owner = "dani";
  };

  services.litellm = {
    enable = true;
    package = pkgs.litellm.overridePythonAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./responses-bridge.patch ];
    });
    host = "127.0.0.1";
    port = 4000;
    environmentFile = masterKeyFile;
    environment.GITHUB_COPILOT_TOKEN_DIR = tokenDir;
    settings = {
      model_list = map deployment deployments;
      litellm_settings.drop_params = true;
      general_settings.master_key = "os.environ/LITELLM_MASTER_KEY";
    };
  };

  systemd.services.litellm.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "litellm";
    Group = "litellm";
  };

  users = {
    users.litellm = {
      isSystemUser = true;
      group = "litellm";
      home = cfg.stateDir;
    };
    groups.litellm = { };
  };

  environment = {
    systemPackages = [ copilotModels ];
    etc."codex/config.toml".source = codexConfig;
    persistence."/persist".directories = [
      {
        directory = cfg.stateDir;
        user = "litellm";
        group = "litellm";
        mode = "0700";
      }
    ];
  };

  home-manager.users.dani = { lib, ... }: {
    home.activation.codexLitellmCatalog = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${codexCatalogScript}
    '';

    programs.fish.shellInit = ''
      if test -r ${masterKeyFile}
        set -gx LITELLM_MASTER_KEY (string replace -r '^LITELLM_MASTER_KEY=' "" < ${masterKeyFile})
      end
    '';
  };
}
