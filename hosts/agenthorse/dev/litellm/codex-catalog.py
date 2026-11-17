import copy
import json
import sys
from pathlib import Path

GENERIC_TEMPLATE_SLUG = "gpt-5.5"


def reasoning_levels(template: dict, efforts: list[str]) -> tuple[list[dict], str | None]:
    levels = [level for level in template.get("supported_reasoning_levels", []) if level["effort"] in efforts]
    offered = [level["effort"] for level in levels]
    default = template.get("default_reasoning_level")
    if default not in offered:
        default = "medium" if "medium" in offered else (offered[0] if offered else None)
    return levels, default


def catalog_entry(deployment: dict, bundled: dict[str, dict], priority: int) -> dict:
    slug = deployment["slug"]
    model = deployment["model"]
    known = slug in bundled
    entry = copy.deepcopy(bundled[slug] if known else bundled[GENERIC_TEMPLATE_SLUG])
    if not known:
        entry |= {
            "slug": slug,
            "display_name": model["name"],
            "description": "GitHub Copilot vía LiteLLM",
            "visibility": "list",
            "priority": priority,
            "input_modalities": ["text", "image"] if model["vision"] else ["text"],
            "supports_search_tool": False,
            "experimental_supported_tools": [],
        }
    entry["supported_reasoning_levels"], entry["default_reasoning_level"] = reasoning_levels(entry, model["efforts"])
    entry["context_window"] = entry["max_context_window"] = model["maxInput"]
    return entry | {
        "service_tiers": [],
        "additional_speed_tiers": [],
        "default_service_tier": None,
        "availability_nux": None,
        "upgrade": None,
    }


def main() -> None:
    bundled = {model["slug"]: model for model in json.loads(Path(sys.argv[1]).read_text())["models"]}
    deployments = json.loads(Path(sys.argv[2]).read_text())
    models = [catalog_entry(d, bundled, priority) for priority, d in enumerate(deployments, start=1)]
    Path(sys.argv[3]).write_text(json.dumps({"models": models}))


if __name__ == "__main__":
    main()
