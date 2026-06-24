import json
import re
from pathlib import Path
from typing import Any


DUO_SOURCE = "core/src/mindustry/content/Blocks.java"
MEND_PROJECTOR_SOURCE = "core/src/mindustry/world/blocks/defense/MendProjector.java"
OVERDRIVE_PROJECTOR_SOURCE = "core/src/mindustry/world/blocks/defense/OverdriveProjector.java"
BUILDING_COMP_SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
CONVEYOR_SOURCE = "core/src/mindustry/world/blocks/distribution/Conveyor.java"

def verify_overdrive_projector_params_parity(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    blocks_path = Path(upstream_root) / DUO_SOURCE
    overdrive_path = Path(upstream_root) / OVERDRIVE_PROJECTOR_SOURCE
    registry_path = Path(godot_root) / "src" / "generated" / "content_registry.json"
    blocks_source = blocks_path.read_text(encoding="utf-8", errors="replace")
    overdrive_source = overdrive_path.read_text(encoding="utf-8", errors="replace")
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    expected = _extract_overdrive_projector_params(blocks_source, overdrive_source, "overdriveProjector", "OverdriveProjector")
    actual_props = _registry_block(registry, "overdrive-projector").get("properties", {})
    mismatches: list[dict[str, Any]] = []
    for key, expected_value in expected.items():
        _append_mismatch(mismatches, f"properties.{key}", expected_value, actual_props.get(key))
    return {
        "source": DUO_SOURCE,
        "block": "overdrive-projector",
        "checked": expected,
        "mismatches": mismatches,
    }

def verify_overdrive_projector_target_filter_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / OVERDRIVE_PROJECTOR_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    predicate = "other.block.canOverdrive"
    action = "other.applyBoost(realBoost(), reload + 1f)"
    missing = []
    if predicate not in source:
        missing.append(predicate)
    if action not in source:
        missing.append(action)
    return {
        "source": OVERDRIVE_PROJECTOR_SOURCE,
        "checked": {"predicate": predicate, "action": action},
        "missing": missing,
    }

def verify_building_time_scale_decay_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    duration_decay = "if((timeScaleDuration -= Time.delta) <= 0f)"
    reset = "timeScale = 1f;"
    missing = []
    if duration_decay not in source:
        missing.append(duration_decay)
    if reset not in source:
        missing.append(reset)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {"duration_decay": duration_decay, "reset": reset},
        "missing": missing,
    }

def verify_building_delta_edelta_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / BUILDING_COMP_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    delta = "return Time.delta * timeScale;"
    edelta = "return efficiency * delta();"
    missing = []
    if delta not in source:
        missing.append(delta)
    if edelta not in source:
        missing.append(edelta)
    return {
        "source": BUILDING_COMP_SOURCE,
        "checked": {"delta": delta, "edelta": edelta},
        "missing": missing,
    }

def verify_conveyor_edelta_source(upstream_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / CONVEYOR_SOURCE
    source = source_path.read_text(encoding="utf-8", errors="replace")
    movement = "float moved = speed * edelta();"
    missing = []
    if movement not in source:
        missing.append(movement)
    return {
        "source": CONVEYOR_SOURCE,
        "checked": {"movement": movement},
        "missing": missing,
    }

def verify_mend_projector_light_parity(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / MEND_PROJECTOR_SOURCE
    registry_path = Path(godot_root) / "src" / "generated" / "content_registry.json"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    expected = _extract_mend_projector_light(source)
    actual_props = _registry_block(registry, "mend-projector").get("properties", {})
    mismatches: list[dict[str, Any]] = []
    for key, expected_value in expected.items():
        _append_mismatch(mismatches, f"properties.{key}", expected_value, actual_props.get(key))
    return {
        "source": MEND_PROJECTOR_SOURCE,
        "block": "mend-projector",
        "checked": expected,
        "mismatches": mismatches,
    }

def verify_mend_projector_scaled_health_parity(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DUO_SOURCE
    registry_path = Path(godot_root) / "src" / "generated" / "content_registry.json"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    expected = _extract_scaled_health_block(source, "mendProjector", "MendProjector")
    actual = _registry_block(registry, "mend-projector")
    mismatches: list[dict[str, Any]] = []
    actual_props = actual.get("properties", {})
    for key, expected_value in expected.items():
        _append_mismatch(mismatches, f"properties.{key}", expected_value, actual_props.get(key))
    return {
        "source": DUO_SOURCE,
        "block": "mend-projector",
        "checked": expected,
        "mismatches": mismatches,
    }

def verify_mend_projector_repair_parity(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DUO_SOURCE
    registry_path = Path(godot_root) / "src" / "generated" / "content_registry.json"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    expected = _extract_mend_projector_repair(source, "mendProjector", "MendProjector")
    actual = _registry_block(registry, "mend-projector")
    mismatches: list[dict[str, Any]] = []
    actual_props = actual.get("properties", {})
    for key, expected_value in expected.items():
        _append_mismatch(mismatches, f"properties.{key}", expected_value, actual_props.get(key))
    return {
        "source": DUO_SOURCE,
        "block": "mend-projector",
        "checked": expected,
        "mismatches": mismatches,
    }

def verify_mend_projector_repair_amount_parity(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    source_path = Path(upstream_root) / DUO_SOURCE
    registry_path = Path(godot_root) / "src" / "generated" / "content_registry.json"
    source = source_path.read_text(encoding="utf-8", errors="replace")
    registry = json.loads(registry_path.read_text(encoding="utf-8"))
    repair = _extract_mend_projector_repair(source, "mendProjector", "MendProjector")
    health = _extract_scaled_health_block(source, "mendProjector", "MendProjector")["health"]
    expected = _mend_projector_repair_amount(health, repair["healPercent"], repair["phaseBoost"])
    actual_props = _registry_block(registry, "mend-projector").get("properties", {})
    actual = _mend_projector_repair_amount(actual_props.get("health"), actual_props.get("healPercent"), actual_props.get("phaseBoost"))
    mismatches: list[dict[str, Any]] = []
    for key, expected_value in expected.items():
        _append_mismatch(mismatches, key, expected_value, actual.get(key))
    return {
        "source": DUO_SOURCE,
        "block": "mend-projector",
        "checked": expected,
        "mismatches": mismatches,
    }


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
    for key in ["reload", "range", "health", "shootY", "inaccuracy", "rotateSpeed", "shootCone", "recoil", "recoils"]:
        value = _numeric_assignment(body, key)
        if value is not None:
            properties[key] = value
    shoot_pattern = _shoot_alternate_pattern(body)
    if shoot_pattern is not None:
        properties["shootPattern"] = shoot_pattern
    limit_range_margin = _limit_range_margin(body)
    if limit_range_margin is not None:
        properties["limitRangeMargin"] = limit_range_margin
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
        for key in ["width", "height", "hitSize", "lifetime", "ammoMultiplier", "reloadMultiplier", "rangeChange", "extraRangeMargin", "inaccuracy"]:
            value = _numeric_assignment(bullet_body, key)
            if value is not None:
                entry[key] = value
        if limit_range_margin is not None:
            entry["lifetime"] = _limit_range_lifetime(properties, entry, limit_range_margin)
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

def _shoot_alternate_pattern(source: str) -> dict[str, Any] | None:
    match = re.search(r"\bshoot\s*=\s*new\s+ShootAlternate\s*\(\s*([0-9_]+(?:\.[0-9_]+)?[fFdD]?)\s*\)", source)
    if not match:
        return None
    return {"type": "ShootAlternate", "spread": _number_literal(match.group(1))}

def _limit_range_margin(source: str) -> float | None:
    match = re.search(r"\blimitRange\s*\(\s*(-?[0-9_]+(?:\.[0-9_]+)?[fFdD]?)?\s*\)\s*;", source)
    if not match:
        return None
    raw = match.group(1)
    return 9.0 if raw is None else float(_number_literal(raw))

def _limit_range_lifetime(properties: dict[str, Any], bullet: dict[str, Any], margin: float) -> float:
    speed = float(bullet.get("speed", 0.0))
    if speed == 0.0:
        return float(bullet.get("lifetime", 40.0))
    real_range = float(properties.get("range", 0.0)) + float(bullet.get("rangeChange", 0.0))
    return (real_range + margin + float(bullet.get("extraRangeMargin", 0.0)) + 10.0) / speed


def _number_literal(raw: str) -> int | float:
    number = raw.replace("_", "")
    suffix = number[-1:] if number else ""
    if suffix in "fFdDlL":
        number = number[:-1]
    return float(number) if "." in number or suffix in "fFdD" else int(number)


def _camel_to_kebab(name: str) -> str:
    return re.sub(r"(?<!^)([A-Z])", r"-\1", name).lower()

def _extract_scaled_health_block(source: str, field: str, implementation: str) -> dict[str, Any]:
    match = re.search(rf'\b{field}\s*=\s*new\s+{implementation}\s*\(\s*"[^"]+"\s*\)', source)
    if not match:
        raise ValueError(f"{field} {implementation} initializer not found in Blocks.java")
    body = _double_brace_body(source, match.end())
    size = int(_numeric_assignment(body, "size") or 1)
    scaled_health = _numeric_assignment(body, "scaledHealth")
    if scaled_health is None:
        raise ValueError(f"{field} scaledHealth assignment not found in Blocks.java")
    return {"size": size, "scaledHealth": scaled_health, "health": int(size * size * float(scaled_health))}

def _extract_mend_projector_repair(source: str, field: str, implementation: str) -> dict[str, Any]:
    match = re.search(rf'\b{field}\s*=\s*new\s+{implementation}\s*\(\s*"[^"]+"\s*\)', source)
    if not match:
        raise ValueError(f"{field} {implementation} initializer not found in Blocks.java")
    body = _double_brace_body(source, match.end())
    expected: dict[str, Any] = {}
    for key, default in {"healPercent": 12.0, "phaseBoost": 12.0, "phaseRangeBoost": 50.0}.items():
        value = _numeric_assignment(body, key)
        expected[key] = float(value) if value is not None else default
    booster_item = _boost_item(body)
    if booster_item is not None:
        expected["boosterItem"] = booster_item
        expected["boosterUseTime"] = float(_numeric_assignment(body, "useTime") or 400.0)
    return expected

def _extract_overdrive_projector_params(blocks_source: str, overdrive_source: str, field: str, implementation: str) -> dict[str, Any]:
    match = re.search(rf'\b{field}\s*=\s*new\s+{implementation}\s*\(\s*"[^"]+"\s*\)', blocks_source)
    if not match:
        raise ValueError(f"{field} {implementation} initializer not found in Blocks.java")
    body = _double_brace_body(blocks_source, match.end())
    expected: dict[str, Any] = {}
    for key in ["range", "reload", "speedBoost", "speedBoostPhase", "phaseRangeBoost"]:
        value = _numeric_assignment(body, key)
        if value is None:
            value = _numeric_assignment(overdrive_source, key)
        if value is None:
            raise ValueError(f"OverdriveProjector {key} default not found")
        expected[key] = float(value)
    booster_item = _boost_item(body)
    if booster_item is not None:
        expected["boosterItem"] = booster_item
        expected["boosterUseTime"] = float(_numeric_assignment(body, "useTime") or _numeric_assignment(overdrive_source, "useTime") or 400.0)
    for key in ["baseColor", "phaseColor"]:
        value = _color_value_assignment(body, key)
        if value is None:
            value = _color_value_assignment(overdrive_source, key)
        if value is None:
            raise ValueError(f"OverdriveProjector {key} default not found")
        expected[key] = value
    emit_light = _boolean_assignment(body, "emitLight")
    if emit_light is None:
        emit_light = _boolean_assignment(overdrive_source, "emitLight")
    if emit_light is None:
        raise ValueError("OverdriveProjector emitLight assignment not found")
    expected["emitLight"] = emit_light
    light_radius = _numeric_assignment(body, "lightRadius")
    if light_radius is None:
        light_radius = _numeric_assignment(overdrive_source, "lightRadius")
    if light_radius is None:
        raise ValueError("OverdriveProjector lightRadius assignment not found")
    expected["lightRadius"] = float(light_radius)
    has_boost = _boolean_assignment(body, "hasBoost")
    if has_boost is None:
        has_boost = _boolean_assignment(overdrive_source, "hasBoost")
    if has_boost is None:
        raise ValueError("OverdriveProjector hasBoost assignment not found")
    expected["hasBoost"] = has_boost
    can_overdrive = _boolean_assignment(body, "canOverdrive")
    if can_overdrive is None:
        can_overdrive = _boolean_assignment(overdrive_source, "canOverdrive")
    if can_overdrive is None:
        raise ValueError("OverdriveProjector canOverdrive assignment not found")
    expected["canOverdrive"] = can_overdrive
    return expected
def _mend_projector_repair_amount(health: Any, heal_percent: Any, phase_boost: Any, phase_heat: float = 0.0, efficiency: float = 1.0) -> dict[str, Any]:
    health_value = float(health)
    heal_value = float(heal_percent)
    phase_boost_value = float(phase_boost)
    return {
        "health": int(health_value) if health_value.is_integer() else health_value,
        "healPercent": heal_value,
        "phaseBoost": phase_boost_value,
        "phaseHeat": phase_heat,
        "efficiency": efficiency,
        "repairAmount": health_value * (heal_value + phase_heat * phase_boost_value) / 100.0 * efficiency,
    }

def _boost_item(source: str) -> str | None:
    match = re.search(r"\bconsumeItem\s*\(\s*Items\.([A-Za-z_]\w*)\s*(?:,\s*[0-9_]+)?\s*\)\s*\.\s*boost\s*\(", source)
    return _camel_to_kebab(match.group(1)) if match else None

def _extract_mend_projector_light(source: str) -> dict[str, Any]:
    base_color = _color_value_assignment(source, "baseColor")
    emit_light = _boolean_assignment(source, "emitLight")
    light_radius = _numeric_assignment(source, "lightRadius")
    if base_color is None:
        raise ValueError("MendProjector baseColor default not found")
    if emit_light is None:
        raise ValueError("MendProjector emitLight assignment not found")
    if light_radius is None:
        raise ValueError("MendProjector lightRadius assignment not found")
    return {"baseColor": base_color, "emitLight": emit_light, "lightRadius": float(light_radius)}

def _boolean_assignment(source: str, key: str) -> bool | None:
    match = re.search(rf"\b{key}\s*=\s*(true|false)\s*;", source)
    return match.group(1) == "true" if match else None

def _color_value_assignment(source: str, key: str) -> str | None:
    match = re.search(rf"\b{key}\s*=\s*Color\.valueOf\(\s*\"([0-9A-Fa-f]+)\"\s*\)\s*;", source)
    return match.group(1).lower() if match else None
