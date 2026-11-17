import json
import sys

import httpx
from litellm.llms.github_copilot.authenticator import Authenticator
from litellm.llms.github_copilot.common_utils import (
    DEFAULT_GITHUB_COPILOT_API_BASE,
    get_copilot_default_headers,
)


def fetch_models() -> list[dict]:
    authenticator = Authenticator()
    api_key = authenticator.get_api_key()
    api_base = authenticator.get_api_base() or DEFAULT_GITHUB_COPILOT_API_BASE
    response = httpx.get(f"{api_base}/models", headers=get_copilot_default_headers(api_key), timeout=30)
    response.raise_for_status()
    return response.json()["data"]


def is_usable(model: dict) -> bool:
    return (
        model.get("capabilities", {}).get("type") == "chat"
        and model.get("model_picker_enabled", False)
        and (model.get("policy") or {}).get("state") != "disabled"
    )


def describe(model: dict) -> dict:
    capabilities = model.get("capabilities", {})
    limits = capabilities.get("limits", {})
    endpoints = model.get("supported_endpoints") or []
    return {
        "id": model["id"],
        "name": model.get("name") or model["id"],
        "efforts": capabilities.get("supports", {}).get("reasoning_effort") or [],
        "responses": "/responses" in endpoints and "/chat/completions" not in endpoints,
        "vision": bool(capabilities.get("supports", {}).get("vision")),
        "maxInput": limits.get("max_prompt_tokens"),
        "maxOutput": limits.get("max_output_tokens"),
    }


def as_nix(model: dict) -> str:
    fields = [f'id = "{model["id"]}";', f'name = "{model["name"]}";']
    if model["responses"]:
        fields.append("responses = true;")
    if model["efforts"]:
        fields.append("efforts = [ " + " ".join(f'"{e}"' for e in model["efforts"]) + " ];")
    if not model["vision"]:
        fields.append("vision = false;")
    fields += [f"{key} = {model[key]};" for key in ("maxInput", "maxOutput") if model[key]]
    return "  { " + " ".join(fields) + " }"


def main() -> None:
    declared = {model["id"]: model for model in json.load(open(sys.argv[1]))}
    available = {m["id"]: describe(m) for m in fetch_models() if is_usable(m)}

    missing = [available[i] for i in sorted(available.keys() - declared.keys())]
    gone = sorted(declared.keys() - available.keys())
    changed = [available[i] for i in sorted(available.keys() & declared.keys()) if declared[i] != available[i]]

    if not (missing or gone or changed):
        print(f"En sync: {len(declared)} modelos declarados coinciden con Copilot.")
        return

    if missing:
        print("Disponibles en Copilot pero no declarados (añadir a models.nix):")
        print("\n".join(as_nix(m) for m in missing))
    if gone:
        print("Declarados pero ya no disponibles en Copilot (quitar de models.nix):")
        print("\n".join(f"  - {i}" for i in gone))
    if changed:
        print("Declarados con metadatos distintos a Copilot:")
        print("\n".join(as_nix(m) for m in changed))
    sys.exit(1)


if __name__ == "__main__":
    main()
