import json
import re
from pathlib import Path
from typing import Any

import javalang
from javalang.tree import Assignment, ClassCreator, Literal, MethodInvocation, StatementExpression

UPSTREAM_COMMIT = "2bdedfed25932ebf11330d3584092c50e2e26d96"


def _source_content_dir(upstream_root: Path) -> Path:
    return Path(upstream_root) / "core" / "src" / "mindustry" / "content"


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


def extract_blocks(upstream_root: Path) -> list[dict[str, str]]:
    source = (_source_content_dir(upstream_root) / "Blocks.java").read_text(encoding="utf-8", errors="replace")
    declared = _declared_block_fields(source)
    pattern = re.compile(r"\b([A-Za-z_]\w*)\s*=\s*new\s+([A-Za-z_]\w*)\s*\(\s*\"([^\"]+)\"", re.MULTILINE)
    blocks = []
    for match in pattern.finditer(source):
        field, implementation, content_id = match.groups()
        if field not in declared:
            continue
        blocks.append({"field": field, "id": content_id, "implementation": implementation})
    return blocks


def _declared_block_fields(source: str) -> set[str]:
    match = re.search(r"public\s+static\s+Block\s+(.*?)\s*;", source, re.DOTALL)
    if not match:
        return set()
    declarations = re.sub(r"//.*", "", match.group(1))
    return {name for name in re.findall(r"\b[A-Za-z_]\w*\b", declarations) if name != "Block"}


def build_content_registry(upstream_root: Path, godot_root: Path) -> dict[str, Any]:
    items = extract_items(upstream_root, godot_root)
    liquids = extract_liquids(upstream_root, godot_root)
    blocks = extract_blocks(upstream_root)
    return {
        "upstream_commit": UPSTREAM_COMMIT,
        "items": items,
        "liquids": liquids,
        "blocks": blocks,
        "counts": {"items": len(items), "liquids": len(liquids), "blocks": len(blocks)},
    }


def gdscript_literal(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True).replace(": true", ": true").replace(": false", ": false")


def write_gdscript_registry(registry: dict[str, Any], output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    text = "\n".join([
        "# Generated from Mindustry upstream.",
        "# Source: core/src/mindustry/content/{Items,Liquids,Blocks}.java",
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
