import json
import re
from pathlib import Path
from typing import Any


DUO_SOURCE = "core/src/mindustry/content/Blocks.java"


def verify_duo_source_parity(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DUO_SOURCE
    registry_path = Path(godot_root) / "src" / "generated" / "content_registry.json"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    expected = _extract_source_duo(source)
    actual = _registry_block(registry, "duo")
    mismatches = _compare_duo(expected, actual)
    return {
        "source": DUO_SOURCE,
        "block": "duo",
        "checked": expected,
        "mismatches": mismatches,
    }


def _extract_source_duo(source: str) -> dict[str, Any]:
    match = re.search(r"\bduo\s*=\s*new\s+ItemTurret\s*\(\s*\"duo\"\s*\)", source)
    if not match:
        raise ValueError("duo ItemTurret initializer not found in Blocks.java")
    body = _double_brace_body(source, match.end())
    properties: dict[str, Any] = {}
    for key in ["reload", "range", "health", "shootY"]:
        value = _numeric_assignment(body, key)
        if value is not None:
            properties[key] = value
    ammo = {}
    ammo_pattern = re.compile(
        r"Items\.([A-Za-z_]\w*)\s*,\s*new\s+BasicBulletType\s*\(\s*"
        r"([0-9_]+(?:\.[0-9_]+)?[fFdD]?)\s*,\s*"
        r"([0-9_]+(?:\.[0-9_]+)?[fFdD]?)"
        r"(?:\s*,\s*\"([^\"]+)\")?",
        re.MULTILINE,
    )
    for ammo_match in ammo_pattern.finditer(body):
        item, speed, damage, sprite = ammo_match.groups()
        bullet_body = _double_brace_body(body, ammo_match.end())
        entry: dict[str, Any] = {
            "speed": _number_literal(speed),
            "damage": _number_literal(damage),
            "sprite": sprite or "bullet",
        }
        for key in ["width", "height", "hitSize", "lifetime", "ammoMultiplier", "reloadMultiplier", "rangeChange"]:
            value = _numeric_assignment(bullet_body, key)
            if value is not None:
                entry[key] = value
        ammo[_camel_to_kebab(item)] = entry
    return {"properties": properties, "ammo": ammo}


def _registry_block(registry: dict[str, Any], block_id: str) -> dict[str, Any]:
    for block in registry.get("blocks", []):
        if block.get("id") == block_id:
            return block
    raise ValueError(f"generated registry block not found: {block_id}")


def _compare_duo(expected: dict[str, Any], actual_block: dict[str, Any]) -> list[dict[str, Any]]:
    mismatches: list[dict[str, Any]] = []
    actual_props = actual_block.get("properties", {})
    for key, expected_value in expected["properties"].items():
        _append_mismatch(mismatches, f"properties.{key}", expected_value, actual_props.get(key))
    actual_ammo = {entry.get("item"): entry for entry in actual_props.get("ammo", [])}
    for item, expected_entry in expected["ammo"].items():
        actual_entry = actual_ammo.get(item, {})
        for key, expected_value in expected_entry.items():
            _append_mismatch(mismatches, f"ammo.{item}.{key}", expected_value, actual_entry.get(key))
    return mismatches


def _append_mismatch(mismatches: list[dict[str, Any]], field: str, expected: Any, actual: Any) -> None:
    if isinstance(expected, float) or isinstance(actual, float):
        if actual is None or abs(float(expected) - float(actual)) > 0.000001:
            mismatches.append({"field": field, "expected": expected, "actual": actual})
    elif expected != actual:
        mismatches.append({"field": field, "expected": expected, "actual": actual})


def _double_brace_body(source: str, start: int) -> str:
    double_brace = source.find("{{", start)
    if double_brace == -1:
        return ""
    depth = 0
    for index in range(double_brace, len(source)):
        char = source[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return source[double_brace:index + 1]
    return ""


def _numeric_assignment(source: str, key: str) -> int | float | None:
    match = re.search(rf"\b{key}\s*=\s*([0-9_]+(?:\.[0-9_]+)?[fFdDlL]?)\s*;", source)
    return _number_literal(match.group(1)) if match else None


def _number_literal(raw: str) -> int | float:
    number = raw.replace("_", "")
    suffix = number[-1:] if number else ""
    if suffix in "fFdDlL":
        number = number[:-1]
    return float(number) if "." in number or suffix in "fFdD" else int(number)


def _camel_to_kebab(name: str) -> str:
    return re.sub(r"(?<!^)([A-Z])", r"-\1", name).lower()
