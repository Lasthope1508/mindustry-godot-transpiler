import json
import re
from pathlib import Path
from typing import Any

import javalang
from javalang.tree import Assignment, ClassCreator, Literal, MethodInvocation, StatementExpression

UPSTREAM_COMMIT = "2bdedfed25932ebf11330d3584092c50e2e26d96"


def _source_content_dir(upstream_root: Path) -> Path:
    return Path(upstream_root) / "core" / "src" / "mindustry" / "content"

def _source_game_dir(upstream_root: Path) -> Path:
    return Path(upstream_root) / "core" / "src" / "mindustry" / "game"


def _asset_root(godot_root: Path) -> Path:
    return Path(godot_root) / "assets"


def _type_name(node: Any) -> str:
    node_type = getattr(node, "type", None)
    return getattr(node_type, "name", "") if node_type is not None else ""


def _literal_value(node: Any) -> Any:
    if isinstance(node, Literal):
        raw = str(node.value)
        if raw.startswith('"') and raw.endswith('"'):
            return raw[1:-1]
        if raw == "true":
            return True
        if raw == "false":
            return False
        number = raw.replace("_", "")
        if number.endswith(("f", "F", "d", "D", "l", "L")):
            number = number[:-1]
        try:
            return float(number) if "." in number else int(number)
        except ValueError:
            return raw
    if isinstance(node, MethodInvocation) and node.member == "valueOf" and node.arguments:
        return _literal_value(node.arguments[0])
    member = getattr(node, "member", None)
    qualifier = getattr(node, "qualifier", None)
    if member and qualifier:
        return f"{qualifier}.{member}"
    if member:
        return str(member)
    return str(node)


def _constructor_color(creator: ClassCreator) -> str:
    if len(creator.arguments) < 2:
        return ""
    value = _literal_value(creator.arguments[1])
    return value if isinstance(value, str) else ""


def _constructor_id(creator: ClassCreator) -> str:
    if not creator.arguments:
        return ""
    value = _literal_value(creator.arguments[0])
    return value if isinstance(value, str) else ""


def _creator_properties(creator: ClassCreator) -> dict[str, Any]:
    properties: dict[str, Any] = {}
    for block in creator.body or []:
        for statement in block or []:
            expression = getattr(statement, "expression", None) if isinstance(statement, StatementExpression) else None
            if not isinstance(expression, Assignment):
                continue
            key = getattr(expression.expressionl, "member", "")
            if key:
                properties[key] = _literal_value(expression.value)
    return properties


def _texture_path(asset_root: Path, relative_path: str) -> str:
    path = asset_root / relative_path
    if not path.exists():
        return ""
    return "res://assets/" + relative_path.replace("\\", "/")


def _extract_creators(java_file: Path, expected_types: set[str]) -> list[dict[str, Any]]:
    source = Path(java_file).read_text(encoding="utf-8", errors="replace")
    tree = javalang.parse.parse(source)
    entries = []
    for _, assignment in tree.filter(Assignment):
        creator = assignment.value
        if not isinstance(creator, ClassCreator):
            continue
        implementation = _type_name(creator)
        if implementation not in expected_types:
            continue
        field = getattr(assignment.expressionl, "member", "")
        content_id = _constructor_id(creator)
        if not field or not content_id:
            continue
        entries.append({
            "field": field,
            "id": content_id,
            "implementation": implementation,
            "color": _constructor_color(creator),
            "properties": _creator_properties(creator),
        })
    return entries


def _with_icon_paths(entries: list[dict[str, Any]], asset_root: Path, prefix: str) -> list[dict[str, Any]]:
    result = []
    for entry in entries:
        copy = dict(entry)
        icon = f"core/assets-raw/sprites/items/{prefix}{entry['id']}.png"
        copy["texture"] = _texture_path(asset_root, icon)
        result.append(copy)
    return result


def extract_items(upstream_root: Path, godot_root: Path) -> list[dict[str, Any]]:
    entries = _extract_creators(_source_content_dir(upstream_root) / "Items.java", {"Item"})
    return _with_icon_paths(entries, _asset_root(godot_root), "item-")


def extract_liquids(upstream_root: Path, godot_root: Path) -> list[dict[str, Any]]:
    entries = _extract_creators(_source_content_dir(upstream_root) / "Liquids.java", {"Liquid", "CellLiquid"})
    return _with_icon_paths(entries, _asset_root(godot_root), "liquid-")

def extract_units(upstream_root: Path, godot_root: Path) -> list[dict[str, Any]]:
    java_file = _source_content_dir(upstream_root) / "UnitTypes.java"
    if not java_file.exists():
        return []
    entries = _extract_unit_creators(java_file)
    result = []
    asset_root = _asset_root(godot_root)
    for entry in entries:
        copy = dict(entry)
        copy["texture"] = _texture_path(asset_root, f"core/assets-raw/sprites/units/{entry['id']}.png")
        result.append(copy)
    return result

def _extract_unit_creators(java_file: Path) -> list[dict[str, Any]]:
    source = Path(java_file).read_text(encoding="utf-8", errors="replace")
    pattern = re.compile(r"\b([A-Za-z_]\w*)\s*=\s*new\s+(UnitType|ErekirUnitType|NeoplasmUnitType)\s*\(\s*\"([^\"]+)\"", re.MULTILINE)
    units = []
    for match in pattern.finditer(source):
        field, implementation, content_id = match.groups()
        units.append({
            "field": field,
            "id": content_id,
            "implementation": implementation,
            "properties": _unit_properties(source, match.end()),
        })
    return units

def _unit_properties(source: str, assignment_end: int) -> dict[str, Any]:
    initializer = _initializer_body(source, assignment_end)
    properties: dict[str, Any] = {}
    for key in ["speed", "health", "hitSize"]:
        match = re.search(rf"\b{key}\s*=\s*([0-9_]+(?:\.[0-9_]+)?[fFdDlL]?)\s*;", initializer)
        if match:
            properties[key] = _number_literal(match.group(1))
    weapons = _unit_weapons(initializer)
    if weapons:
        properties["weapons"] = weapons
    return properties

def _unit_weapons(initializer: str) -> list[dict[str, Any]]:
    pattern = re.compile(r"weapons\.add\s*\(\s*new\s+[A-Za-z_]\w*\s*\([^)]*\)", re.MULTILINE)
    weapons = []
    for match in pattern.finditer(initializer):
        weapon_body = _initializer_body(initializer, match.end())
        bullet_match = re.search(r"bullet\s*=\s*new\s+BasicBulletType\s*\(\s*([0-9_]+(?:\.[0-9_]+)?[fFdD]?)\s*,\s*([0-9_]+(?:\.[0-9_]+)?[fFdD]?)(?:\s*,\s*\"([^\"]+)\")?", weapon_body, re.MULTILINE)
        if not bullet_match:
            continue
        speed, damage, sprite = bullet_match.groups()
        bullet = {"speed": _number_literal(speed), "damage": _number_literal(damage), "sprite": sprite or "bullet"}
        bullet_body = _initializer_body(weapon_body, bullet_match.end())
        lifetime = _numeric_assignment(bullet_body, "lifetime")
        if lifetime is not None:
            bullet["lifetime"] = lifetime
        entry: dict[str, Any] = {"bullet": bullet}
        reload = _numeric_assignment(weapon_body, "reload")
        if reload is not None:
            entry["reload"] = reload
        weapons.append(entry)
    return weapons

def _number_literal(raw: str) -> int | float:
    number = raw.replace("_", "")
    suffix = number[-1:] if number else ""
    if suffix in "fFdDlL":
        number = number[:-1]
    return float(number) if "." in number or suffix in "fFdD" else int(number)

def extract_waves(upstream_root: Path, units: list[dict[str, Any]]) -> dict[str, Any]:
    java_file = _source_game_dir(upstream_root) / "Waves.java"
    if not java_file.exists():
        return {"version": 0, "groups": []}
    source = java_file.read_text(encoding="utf-8", errors="replace")
    version_match = re.search(r"waveVersion\s*=\s*([0-9_]+)", source)
    version = int(version_match.group(1).replace("_", "")) if version_match else 0
    field_to_id = {unit["field"]: unit["id"] for unit in units}
    groups = []
    pattern = re.compile(r"new\s+SpawnGroup\s*\(\s*([A-Za-z_]\w*)\s*\)", re.MULTILINE)
    for match in pattern.finditer(source):
        field = match.group(1)
        unit_id = field_to_id.get(field, _camel_to_kebab(field))
        group: dict[str, Any] = {"unit": unit_id}
        body = _initializer_body(source, match.end())
        for key in ["begin", "end", "spacing", "max", "unitAmount"]:
            value = _numeric_assignment(body, key)
            if value is not None:
                group[key] = value
        for key in ["unitScaling", "shields", "shieldScaling"]:
            value = _numeric_assignment(body, key)
            if value is not None:
                group[key] = value
        groups.append(group)
    return {"version": version, "groups": groups}


def extract_blocks(upstream_root: Path, godot_root: Path | None = None) -> list[dict[str, str]]:
    source = (_source_content_dir(upstream_root) / "Blocks.java").read_text(encoding="utf-8", errors="replace")
    declared = _declared_block_fields(source)
    asset_root = _asset_root(godot_root) if godot_root is not None else None
    pattern = re.compile(r"\b([A-Za-z_]\w*)\s*=\s*new\s+([A-Za-z_]\w*)\s*\(\s*\"([^\"]+)\"", re.MULTILINE)
    blocks = []
    for match in pattern.finditer(source):
        field, implementation, content_id = match.groups()
        if field not in declared:
            continue
        entry = {"field": field, "id": content_id, "implementation": implementation, "properties": _block_properties(source, match.end())}
        if asset_root is not None:
            entry["texture"] = _block_texture_path(asset_root, content_id)
        blocks.append(entry)
    return blocks

def _block_properties(source: str, assignment_end: int) -> dict[str, Any]:
    initializer = _initializer_body(source, assignment_end)
    properties: dict[str, Any] = {}
    category = re.search(r"requirements\s*\(\s*Category\.([A-Za-z_]\w*)", initializer)
    if category:
        properties["category"] = category.group(1)
    requirements = _block_requirements(initializer)
    if requirements:
        properties["requirements"] = requirements
    for key in ["size", "health"]:
        match = re.search(rf"\b{key}\s*=\s*([0-9_]+)\s*;", initializer)
        if match:
            properties[key] = int(match.group(1).replace("_", ""))
    for key in ["range", "reload"]:
        value = _numeric_assignment(initializer, key)
        if value is not None:
            properties[key] = value
    ammo = _block_ammo(initializer)
    if ammo:
        properties["ammo"] = ammo
    return properties

def _numeric_assignment(source: str, key: str) -> int | float | None:
    match = re.search(rf"\b{key}\s*=\s*([0-9_]+(?:\.[0-9_]+)?[fFdDlL]?)\s*;", source)
    return _number_literal(match.group(1)) if match else None

def _block_ammo(initializer: str) -> list[dict[str, Any]]:
    pattern = re.compile(r"ammo\s*\(\s*Items\.([A-Za-z_]\w*)\s*,\s*new\s+BasicBulletType\s*\(\s*([0-9_]+(?:\.[0-9_]+)?[fFdD]?)\s*,\s*([0-9_]+(?:\.[0-9_]+)?[fFdD]?)(?:\s*,\s*\"([^\"]+)\")?", re.MULTILINE)
    ammo = []
    for match in pattern.finditer(initializer):
        item, speed, damage, sprite = match.groups()
        entry = {"item": _camel_to_kebab(item), "speed": _number_literal(speed), "damage": _number_literal(damage), "sprite": sprite or "bullet"}
        bullet_body = _initializer_body(initializer, match.end())
        lifetime = _numeric_assignment(bullet_body, "lifetime")
        if lifetime is not None:
            entry["lifetime"] = lifetime
        ammo.append(entry)
    return ammo

def _block_requirements(initializer: str) -> list[dict[str, Any]]:
    match = re.search(r"requirements\s*\([^;]*?with\((.*?)\)\s*\)", initializer, re.DOTALL)
    if not match:
        return []
    args = [part.strip() for part in match.group(1).replace("\n", " ").split(",")]
    requirements = []
    index = 0
    while index + 1 < len(args):
        item_match = re.match(r"Items\.([A-Za-z_]\w*)", args[index])
        amount_match = re.match(r"([0-9_]+)", args[index + 1])
        if item_match and amount_match:
            requirements.append({"item": _camel_to_kebab(item_match.group(1)), "amount": int(amount_match.group(1).replace("_", ""))})
        index += 2
    return requirements

def _camel_to_kebab(name: str) -> str:
    return re.sub(r"(?<!^)([A-Z])", r"-\1", name).lower()

def _initializer_body(source: str, start: int) -> str:
    end = source.find(";", start)
    double_brace = source.find("{{", start, end if end != -1 else len(source))
    if double_brace == -1:
        return ""
    depth = 0
    index = double_brace
    while index < len(source):
        char = source[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return source[double_brace:index + 1]
        index += 1
    return ""


def _declared_block_fields(source: str) -> set[str]:
    match = re.search(r"public\s+static\s+Block\s+(.*?)\s*;", source, re.DOTALL)
    if not match:
        return set()
    declarations = re.sub(r"//.*", "", match.group(1))
    return {name for name in re.findall(r"\b[A-Za-z_]\w*\b", declarations) if name != "Block"}


def _block_texture_path(asset_root: Path, block_id: str) -> str:
    if block_id == "air":
        return ""
    blocks_root = Path(asset_root) / "core" / "assets-raw" / "sprites" / "blocks"
    if not blocks_root.exists():
        return ""
    candidates = [
        f"{block_id}.png",
        f"{block_id}-preview.png",
        f"{block_id}-0-0.png",
        f"{block_id}-1.png",
        f"{block_id}1.png",
    ]
    for name in candidates:
        matches = sorted(blocks_root.rglob(name))
        if matches:
            return "res://assets/" + matches[0].relative_to(asset_root).as_posix()
    prefixed = sorted(blocks_root.rglob(f"{block_id}-*.png"))
    if prefixed:
        return "res://assets/" + prefixed[0].relative_to(asset_root).as_posix()
    return ""


def build_content_registry(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    items = extract_items(upstream_root, godot_root)
    liquids = extract_liquids(upstream_root, godot_root)
    blocks = extract_blocks(upstream_root, godot_root)
    units = extract_units(upstream_root, godot_root)
    waves = extract_waves(upstream_root, units)
    return {
        "upstream_commit": UPSTREAM_COMMIT,
        "items": items,
        "liquids": liquids,
        "blocks": blocks,
        "units": units,
        "waves": waves,
        "counts": {"items": len(items), "liquids": len(liquids), "blocks": len(blocks), "units": len(units)},
    }


def gdscript_literal(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True).replace(": true", ": true").replace(": false", ": false")


def write_gdscript_registry(registry: dict[str, Any], output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    text = "\n".join([
        "# Generated from Mindustry upstream.",
        "# Source: core/src/mindustry/content/{Items,Liquids,Blocks,UnitTypes}.java",
        f"# Upstream commit: {UPSTREAM_COMMIT}",
        "# Do not edit by hand.",
        "extends RefCounted",
        "class_name MindustryContentRegistry",
        "",
        f"const UPSTREAM_COMMIT := {gdscript_literal(registry['upstream_commit'])}",
        f"const COUNTS := {gdscript_literal(registry['counts'])}",
        f"const ITEMS := {gdscript_literal(registry['items'])}",
        f"const LIQUIDS := {gdscript_literal(registry['liquids'])}",
        f"const BLOCKS := {gdscript_literal(registry['blocks'])}",
        f"const UNITS := {gdscript_literal(registry['units'])}",
        f"const WAVES := {gdscript_literal(registry['waves'])}",
        "",
        "static func counts() -> Dictionary:",
        "\treturn COUNTS",
        "",
    ])
    output_path.write_text(text, encoding="utf-8")


def write_content_registry(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    registry = build_content_registry(upstream_root, godot_root)
    generated = Path(godot_root) / "src" / "generated"
    generated.mkdir(parents=True, exist_ok=True)
    (generated / "content_registry.json").write_text(json.dumps(registry, indent=2, sort_keys=True), encoding="utf-8")
    write_gdscript_registry(registry, generated / "MindustryContentRegistry.gd")
    return registry
