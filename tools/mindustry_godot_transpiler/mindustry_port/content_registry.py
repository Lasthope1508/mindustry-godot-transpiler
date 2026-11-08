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

def _source_world_dir(upstream_root: Path) -> Path:
    return Path(upstream_root) / "core" / "src" / "mindustry" / "world"


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
    from .terrain_content import TerrainContentResolver, UNKNOWN, anonymous_body, block_creators

    source = (_source_content_dir(upstream_root) / "Blocks.java").read_text(encoding="utf-8", errors="replace")
    declared = _declared_block_fields(source)
    asset_root = _asset_root(godot_root) if godot_root is not None else None
    can_overdrive_defaults = _can_overdrive_defaults(upstream_root)
    power_defaults = _power_defaults(upstream_root)
    has_items_defaults = _has_items_defaults(upstream_root)
    default_item_capacity = _block_item_capacity_default(upstream_root)
    class_sources = _class_sources(upstream_root)
    drill_blocked_defaults = _drill_blocked_defaults(upstream_root)
    item_source = _source_content_dir(upstream_root) / 'Items.java'
    terrain = TerrainContentResolver(upstream_root, _extract_creators(item_source, {'Item'}) if item_source.exists() else [])
    blocks = []
    for field, implementation, arguments, assignment_end in block_creators(source):
        if field not in declared:
            continue
        definitions = terrain.resolve(implementation, arguments)
        # Existing literal-name extraction remains valid independently of
        # unsupported terrain metadata. Item-only constructors need source name
        # delegation; never derive an id from the Java field spelling.
        first_argument = javalang.parse.parse_expression('new ' + implementation + '(' + arguments + ')').arguments[0]
        content_id = _literal_value(first_argument) if isinstance(first_argument, Literal) and first_argument.value.startswith('"') else definitions.get('name')
        if not isinstance(content_id, str) or not content_id: continue
        properties = _block_properties(source, assignment_end, implementation, can_overdrive_defaults, has_items_defaults, default_item_capacity, power_defaults, class_sources)
        overrides = terrain.overrides(anonymous_body(source, assignment_end))
        for key in ('itemDrop', 'cacheLayer'):
            value = overrides.get(key, definitions.get(key, UNKNOWN))
            if value is not UNKNOWN:
                properties[key] = value[1] if isinstance(value, tuple) else value
        entry = {"field": field, "id": content_id, "implementation": implementation, "properties": properties}
        if implementation in drill_blocked_defaults:
            definitions = _drill_blocked_definitions(_initializer_body(source, assignment_end))
            if definitions is not None:
                entry["properties"].update({**drill_blocked_defaults[implementation], **definitions})
        if asset_root is not None:
            entry["texture"] = _block_texture_path(asset_root, content_id)
        blocks.append(entry)
    return blocks

def _drill_blocked_definitions(initializer: str) -> dict[str, Any] | None:
    """Only unconditional null/Items fields/Seq.with references are resolved."""
    def item_field(node):
        if not isinstance(node, javalang.tree.MemberReference) or node.qualifier != 'Items' or node.selectors or node.prefix_operators or node.postfix_operators:
            raise ValueError('Unresolved Item field')
        return node.member

    try:
        tokens = list(javalang.tokenizer.tokenize(initializer))
        result = {}
        depth = 0
        for index, token in enumerate(tokens):
            if token.value == '{': depth += 1
            elif token.value == '}': depth -= 1
            if token.value not in ('blockedItem', 'blockedItems'): continue
            if depth != 2 or index == 0 or tokens[index - 1].value not in ('{', ';', '}') or tokens[index + 1].value != '=':
                return None
            end = next(i for i in range(index + 2, len(tokens)) if tokens[i].value == ';')
            value = javalang.parse.parse_expression(' '.join(t.value for t in tokens[index + 2:end]))
            if isinstance(value, Literal) and value.value == 'null' and not value.prefix_operators and not value.postfix_operators and not value.selectors:
                result[token.value] = None
            elif token.value == 'blockedItem':
                result[token.value] = item_field(value)
            elif isinstance(value, MethodInvocation) and value.qualifier == 'Seq' and value.member == 'with' and not value.selectors and not value.prefix_operators and not value.postfix_operators:
                result[token.value] = [item_field(arg) for arg in value.arguments]
            else:
                return None
        return result
    except (ValueError, IndexError, StopIteration, javalang.parser.JavaSyntaxError, javalang.tokenizer.LexerError):
        return None


def _drill_blocked_defaults(upstream_root: Path) -> dict[str, dict[str, Any]]:
    sources = {}
    parents = {}
    for path in (_source_world_dir(upstream_root) / 'blocks').rglob('*.java'):
        text = path.read_text(encoding='utf-8', errors='replace')
        match = re.search(r'\bclass\s+(\w+)\s+extends\s+(\w+)', text)
        if match:
            sources[match[1]], parents[match[1]] = text, match[2]
    base = sources.get('Drill', '')
    if not all(re.search(r'public\s+@Nullable\s+' + typ + r'\s+' + field + r'\s*;', base) for typ, field in [('Item', 'blockedItem'), ('Seq<Item>', 'blockedItems')]):
        return {}
    cache = {}

    def resolve(name):
        if name in cache: return cache[name]
        if name == 'Drill':
            values = {'blockedItem': None, 'blockedItems': None}
        elif name in parents:
            parent = resolve(parents[name])
            if parent is None:
                cache[name] = None
                return None
            values = dict(parent)
        else:
            return None
        overrides = _drill_blocked_definitions('{' + _constructor_body(sources[name], name) + '}')
        cache[name] = None if overrides is None else {**values, **overrides}
        return cache[name]

    return {name: value for name in sources if (value := resolve(name)) is not None}


def _block_item_capacity_default(upstream_root: Path) -> int:
    block_source = (_source_world_dir(upstream_root) / "Block.java").read_text(encoding="utf-8", errors="replace")
    match = re.search(r"\bpublic\s+int\s+itemCapacity\s*=\s*([0-9_]+)\s*;", block_source)
    if not match:
        raise ValueError("Block.itemCapacity default not found in Block.java")
    return int(match.group(1).replace("_", ""))

def _has_items_defaults(upstream_root: Path) -> dict[str, bool]:
    defaults: dict[str, bool] = {}
    blocks_root = _source_world_dir(upstream_root) / "blocks"
    for source_path in blocks_root.rglob("*.java"):
        source = source_path.read_text(encoding="utf-8", errors="replace")
        class_match = re.search(r"\bclass\s+([A-Za-z_]\w*)", source)
        assignment = _boolean_assignment(source, "hasItems")
        if class_match and assignment is not None:
            defaults[class_match.group(1)] = assignment
    return defaults

def _can_overdrive_defaults(upstream_root: Path) -> dict[str, bool]:
    block_source = (_source_world_dir(upstream_root) / "Block.java").read_text(encoding="utf-8", errors="replace")
    default = _boolean_assignment(block_source, "canOverdrive")
    if default is None:
        raise ValueError("Block.canOverdrive default not found in Block.java")
    defaults = {"Block": default}
    blocks_root = _source_world_dir(upstream_root) / "blocks"
    for source_path in blocks_root.rglob("*.java"):
        source = source_path.read_text(encoding="utf-8", errors="replace")
        class_match = re.search(r"\bclass\s+([A-Za-z_]\w*)", source)
        assignment = _boolean_assignment(source, "canOverdrive")
        if class_match and assignment is not None:
            defaults[class_match.group(1)] = assignment
    return defaults

def _power_defaults(upstream_root: Path) -> dict[str, dict[str, bool]]:
    world_root = _source_world_dir(upstream_root)
    block_source = (world_root / "Block.java").read_text(encoding="utf-8", errors="replace")
    base = {}
    for key in ["hasPower", "consumesPower", "outputsPower", "connectedPower", "hasLiquids"]:
        value = _boolean_assignment(block_source, key)
        if value is not None:
            base[key] = value
    class_sources: dict[str, str] = {"Block": block_source}
    class_parents: dict[str, str] = {}
    blocks_root = world_root / "blocks"
    if blocks_root.exists():
        for source_path in blocks_root.rglob("*.java"):
            source = source_path.read_text(encoding="utf-8", errors="replace")
            class_match = re.search(r"\bclass\s+([A-Za-z_]\w*)\s+extends\s+([A-Za-z_]\w*)", source)
            if not class_match:
                continue
            class_name, parent = class_match.groups()
            class_sources[class_name] = source
            class_parents[class_name] = parent
    defaults: dict[str, dict[str, bool]] = {"Block": base}

    def resolved(class_name: str) -> dict[str, bool]:
        if class_name in defaults:
            return defaults[class_name]
        parent = class_parents.get(class_name, "Block")
        values = dict(resolved(parent) if parent != class_name else base)
        source = class_sources.get(class_name, "")
        constructor = _constructor_body(source, class_name)
        for key in ["hasPower", "consumesPower", "outputsPower", "connectedPower", "hasLiquids"]:
            value = _boolean_assignment(constructor, key)
            if value is not None:
                values[key] = value
        defaults[class_name] = values
        return values

    for class_name in class_sources:
        resolved(class_name)
    return defaults

def _block_properties(source: str, assignment_end: int, implementation: str = "", can_overdrive_defaults: dict[str, bool] | None = None, has_items_defaults: dict[str, bool] | None = None, default_item_capacity: int | None = None, power_defaults: dict[str, dict[str, bool]] | None = None, class_sources: dict[str, str] | None = None) -> dict[str, Any]:
    initializer = _initializer_body(source, assignment_end)
    properties: dict[str, Any] = {}
    if can_overdrive_defaults is not None:
        properties["canOverdrive"] = can_overdrive_defaults.get(implementation, can_overdrive_defaults["Block"])
    if power_defaults is not None and implementation in power_defaults:
        properties.update(power_defaults[implementation])
    if has_items_defaults is not None and implementation in has_items_defaults:
        properties["hasItems"] = has_items_defaults[implementation]
    category = re.search(r"requirements\s*\(\s*Category\.([A-Za-z_]\w*)", initializer)
    if category:
        properties["category"] = category.group(1)
    requirements = _block_requirements(initializer)
    if requirements:
        properties["requirements"] = requirements
    for key in ["size", "health", "itemCapacity", "tier", "recoils", "maxNodes"]:
        match = re.search(rf"\b{key}\s*=\s*([0-9_]+)\s*;", initializer)
        if match:
            properties[key] = int(match.group(1).replace("_", ""))
    has_liquids = _boolean_assignment(initializer, "hasLiquids")
    if has_liquids is not None:
        properties["hasLiquids"] = has_liquids
    has_items = _boolean_assignment(initializer, "hasItems")
    if has_items is not None:
        properties["hasItems"] = has_items
    if properties.get("hasItems") is True and "itemCapacity" not in properties and default_item_capacity is not None:
        properties["itemCapacity"] = default_item_capacity
    for key in ["range", "reload", "drillTime", "speed", "displayedSpeed", "shootY", "inaccuracy", "rotateSpeed", "shootCone", "recoil", "scaledHealth", "healPercent", "phaseBoost", "phaseRangeBoost", "speedBoost", "speedBoostPhase", "useTime", "lightRadius", "laserRange", "powerProduction", "itemDuration"]:
        value = _numeric_assignment(initializer, key)
        if value is not None:
            properties[key] = value
    buffered_capacity = _consume_power_buffered_capacity(initializer)
    if buffered_capacity is not None:
        properties["consumePowerBuffered"] = buffered_capacity
        properties["powerCapacity"] = buffered_capacity
        properties["powerBuffered"] = True
    power_usage = _consume_power_usage(initializer)
    if power_usage is not None:
        properties["consumePower"] = power_usage
        properties["powerUsage"] = power_usage
        properties["powerCapacity"] = 0.0
        properties["powerBuffered"] = False
        properties["hasPower"] = True
        properties["consumesPower"] = True
    base_color = _color_value_assignment(initializer, "baseColor")
    if base_color is not None:
        properties["baseColor"] = base_color
    phase_color = _color_value_assignment(initializer, "phaseColor")
    if phase_color is not None:
        properties["phaseColor"] = phase_color
    emit_light = _boolean_assignment(initializer, "emitLight")
    if emit_light is not None:
        properties["emitLight"] = emit_light
    has_boost = _boolean_assignment(initializer, "hasBoost")
    if has_boost is not None:
        properties["hasBoost"] = has_boost
    can_overdrive = _boolean_assignment(initializer, "canOverdrive")
    if can_overdrive is not None:
        properties["canOverdrive"] = can_overdrive
    if "scaledHealth" in properties and "health" not in properties and not _has_assignment(initializer, "health"):
        properties["health"] = int(int(properties.get("size", 1)) * int(properties.get("size", 1)) * float(properties["scaledHealth"]))
    if implementation == "MendProjector":
        _apply_mend_projector_defaults(properties, initializer)
    if implementation == "OverdriveProjector":
        _apply_overdrive_projector_defaults(properties, initializer)
    booster_item = _boost_item(initializer)
    if booster_item is not None:
        properties["boosterItem"] = booster_item
        if implementation in ["MendProjector", "OverdriveProjector"]:
            properties["boosterUseTime"] = float(_numeric_assignment(initializer, "useTime") or properties.get("useTime", 400.0))
    shoot_pattern = _shoot_alternate_pattern(initializer)
    if shoot_pattern is not None:
        properties["shootPattern"] = shoot_pattern
    ammo = _block_ammo(initializer)
    if ammo:
        limit_range_margin = _limit_range_margin(initializer)
        if implementation == "ItemTurret" and limit_range_margin is not None:
            properties["limitRangeMargin"] = limit_range_margin
            _apply_limit_range_to_ammo(properties, ammo, limit_range_margin)
        properties["ammo"] = ammo
    # Field values for consumer amount expressions: the implementation class's
    # field defaults first, then the block initializer's own assignments (which
    # override the class defaults, e.g. thorium-reactor's `heating = 0.02f`).
    field_values: dict[str, int | float] = {}
    if class_sources and implementation in class_sources:
        field_values.update(_numeric_field_values(class_sources[implementation]))
    field_values.update(_numeric_assignments(initializer))
    liquid_consumers = _consume_liquid_descriptors(initializer, field_values)
    if liquid_consumers:
        properties["consumeLiquid"] = liquid_consumers
    item_consumers = _consume_item_descriptors(initializer)
    if item_consumers:
        properties["consumeItem"] = item_consumers
    if implementation == "ItemTurret":
        _apply_item_turret_ammo_defaults(properties, initializer)
    return properties

def _consume_liquid_descriptors(initializer: str, field_values: dict[str, int | float] | None = None) -> list[dict[str, Any]] | None:
    """Resolve standalone literal calls; None leaves the whole block unresolved.

    Keep Java field identity for typed runtime resolution. Omitted flags belong
    to canonical Consume classification defaults. Tokenization removes comments
    and rejects nested/assigned calls rather than making them unconditional.
    Field references in the amount expression (e.g. `heating / coolantPower`)
    resolve through `field_values` (initializer assignments, then class field
    defaults); an unresolvable field leaves the whole block unresolved.
    """
    field_values = field_values or {}

    def number(node):
        if isinstance(node, Literal):
            value = _number_literal(node.value)
            for operator in reversed(node.prefix_operators or []):
                if operator not in ('+', '-'):
                    raise ValueError('Unsupported numeric prefix')
                value = -value if operator == '-' else value
            return value
        if isinstance(node, javalang.tree.BinaryOperation) and node.operator == '/':
            left, right = number(node.operandl), number(node.operandr)
            return int(left / right) if isinstance(left, int) and isinstance(right, int) else left / right
        if isinstance(node, javalang.tree.MemberReference) and not node.qualifier and not node.selectors and node.member in field_values:
            return field_values[node.member]
        raise ValueError('Unresolved amount expression')

    try:
        tokens = list(javalang.tokenizer.tokenize(initializer))
        if any(t.value in ('consumeBuilder', 'findConsumer', 'removeConsumer', 'removeConsumers') for t in tokens):
            return None
        result = []
        depth = 0
        for index, token in enumerate(tokens):
            if token.value == '{':
                depth += 1
            elif token.value == '}':
                depth -= 1
            if token.value != 'consumeLiquid' or index + 1 >= len(tokens) or tokens[index + 1].value != '(':
                continue
            if depth != 2 or index == 0 or tokens[index - 1].value not in ('{', ';', '}'):
                return None
            end = next(i for i in range(index, len(tokens)) if tokens[i].value == ';')
            expression = javalang.parse.parse_expression(' '.join(t.value for t in tokens[index:end]))
            if not isinstance(expression, MethodInvocation) or expression.qualifier or len(expression.arguments) != 2:
                return None
            liquid, amount = expression.arguments
            if not isinstance(liquid, javalang.tree.MemberReference) or liquid.qualifier != 'Liquids' or liquid.selectors:
                return None
            descriptor = {'liquid': liquid.member, 'amount': float(number(amount))}
            for selector in expression.selectors or []:
                if not isinstance(selector, MethodInvocation):
                    return None
                arguments = selector.arguments
                if selector.member == 'boost' and not arguments:
                    # Consume.boost(): return optional(true, true).
                    descriptor.update(optional=True, booster=True)
                elif selector.member in ('optional', 'update'):
                    count = 2 if selector.member == 'optional' else 1
                    if len(arguments) != count or any(not isinstance(a, Literal) or a.value not in ('true', 'false') or a.prefix_operators for a in arguments):
                        return None
                    flags = [a.value == 'true' for a in arguments]
                    if selector.member == 'optional':
                        descriptor.update(optional=flags[0], booster=flags[1])
                    else:
                        descriptor['update'] = flags[0]
                else:
                    return None
            result.append(descriptor)
        return result
    except (ValueError, TypeError, StopIteration, ZeroDivisionError, javalang.parser.JavaSyntaxError, javalang.tokenizer.LexerError):
        return None


def _consume_item_descriptors(initializer: str) -> list[dict[str, Any]] | None:
    """Resolve standalone literal consumeItem/consumeItems calls; None leaves the whole block unresolved.

    `consumeItem(Items.<name>)` defaults the amount to 1 (Block.java:1167-1173);
    `consumeItems(with(Items.<a>, <n>, ...))` expands to one descriptor per stack.
    Assigned calls (`itemConsumer = consumeItem(...)`) are the booster item, already
    captured by `_boost_item`, so they are skipped rather than resolved here.
    Selector flags (boost/optional/update) mirror `_consume_liquid_descriptors`.
    """
    def number(node):
        if isinstance(node, Literal):
            value = _number_literal(node.value)
            for operator in reversed(node.prefix_operators or []):
                if operator not in ('+', '-'):
                    raise ValueError('Unsupported numeric prefix')
                value = -value if operator == '-' else value
            return value
        raise ValueError('Unresolved amount expression')

    def selector_flags(expression):
        flags: dict[str, Any] = {}
        for selector in expression.selectors or []:
            if not isinstance(selector, MethodInvocation):
                return None
            arguments = selector.arguments
            if selector.member == 'boost' and not arguments:
                # Consume.boost(): return optional(true, true).
                flags.update(optional=True, booster=True)
            elif selector.member in ('optional', 'update'):
                count = 2 if selector.member == 'optional' else 1
                if len(arguments) != count or any(not isinstance(a, Literal) or a.value not in ('true', 'false') or a.prefix_operators for a in arguments):
                    return None
                values = [a.value == 'true' for a in arguments]
                if selector.member == 'optional':
                    flags.update(optional=values[0], booster=values[1])
                else:
                    flags['update'] = values[0]
            else:
                return None
        return flags

    try:
        tokens = list(javalang.tokenizer.tokenize(initializer))
        if any(t.value in ('consumeBuilder', 'findConsumer', 'removeConsumer', 'removeConsumers') for t in tokens):
            return None
        result = []
        depth = 0
        for index, token in enumerate(tokens):
            if token.value == '{':
                depth += 1
            elif token.value == '}':
                depth -= 1
            if token.value not in ('consumeItem', 'consumeItems') or index + 1 >= len(tokens) or tokens[index + 1].value != '(':
                continue
            if depth != 2 or index == 0 or tokens[index - 1].value not in ('{', ';', '}'):
                if index > 0 and tokens[index - 1].value == '=':
                    continue
                return None
            end = next(i for i in range(index, len(tokens)) if tokens[i].value == ';')
            expression = javalang.parse.parse_expression(' '.join(t.value for t in tokens[index:end]))
            if not isinstance(expression, MethodInvocation) or expression.qualifier:
                return None
            flags = selector_flags(expression)
            if flags is None:
                return None
            if expression.member == 'consumeItem':
                if len(expression.arguments) not in (1, 2):
                    return None
                item = expression.arguments[0]
                if not isinstance(item, javalang.tree.MemberReference) or item.qualifier != 'Items' or item.selectors:
                    return None
                amount = int(number(expression.arguments[1])) if len(expression.arguments) == 2 else 1
                descriptor = {'item': _camel_to_kebab(item.member), 'amount': amount}
                descriptor.update(flags)
                result.append(descriptor)
            else:
                if len(expression.arguments) != 1:
                    return None
                with_call = expression.arguments[0]
                if not isinstance(with_call, MethodInvocation) or with_call.member != 'with' or with_call.qualifier:
                    return None
                args = with_call.arguments
                if len(args) % 2 != 0:
                    return None
                for i in range(0, len(args), 2):
                    item, amount = args[i], args[i + 1]
                    if not isinstance(item, javalang.tree.MemberReference) or item.qualifier != 'Items' or item.selectors:
                        return None
                    descriptor = {'item': _camel_to_kebab(item.member), 'amount': int(number(amount))}
                    descriptor.update(flags)
                    result.append(descriptor)
        return result
    except (ValueError, TypeError, StopIteration, ZeroDivisionError, javalang.parser.JavaSyntaxError, javalang.tokenizer.LexerError):
        return None


def _apply_item_turret_ammo_defaults(properties: dict[str, Any], initializer: str) -> None:
    for key, default in {"maxAmmo": 30, "ammoPerShot": 1}.items():
        value = _numeric_assignment(initializer, key)
        if value is not None:
            properties[key] = int(value)
        elif not _has_assignment(initializer, key):
            properties[key] = default
    consume = _boolean_assignment(initializer, "consumeAmmoOnce")
    if consume is not None:
        properties["consumeAmmoOnce"] = consume
    elif not _has_assignment(initializer, "consumeAmmoOnce"):
        properties["consumeAmmoOnce"] = True

def _apply_mend_projector_defaults(properties: dict[str, Any], initializer: str) -> None:
    for key, default in {"healPercent": 12.0, "phaseBoost": 12.0, "phaseRangeBoost": 50.0}.items():
        if key not in properties and not _has_assignment(initializer, key):
            properties[key] = default
    if "baseColor" not in properties and not _has_assignment(initializer, "baseColor"):
        properties["baseColor"] = "84f491"
    if "emitLight" not in properties and not _has_assignment(initializer, "emitLight"):
        properties["emitLight"] = True
    if "lightRadius" not in properties and not _has_assignment(initializer, "lightRadius"):
        properties["lightRadius"] = 50.0

def _apply_overdrive_projector_defaults(properties: dict[str, Any], initializer: str) -> None:
    for key, default in {"reload": 60.0, "range": 80.0, "speedBoost": 1.5, "speedBoostPhase": 0.75, "useTime": 400.0, "phaseRangeBoost": 20.0}.items():
        if key not in properties and not _has_assignment(initializer, key):
            properties[key] = default
    if "hasBoost" not in properties and not _has_assignment(initializer, "hasBoost"):
        properties["hasBoost"] = True
    if "baseColor" not in properties and not _has_assignment(initializer, "baseColor"):
        properties["baseColor"] = "feb380"
    if "phaseColor" not in properties and not _has_assignment(initializer, "phaseColor"):
        properties["phaseColor"] = "ffd59e"
    if "emitLight" not in properties and not _has_assignment(initializer, "emitLight"):
        properties["emitLight"] = True
    if "lightRadius" not in properties and not _has_assignment(initializer, "lightRadius"):
        properties["lightRadius"] = 50.0
def _boost_item(source: str) -> str | None:
    match = re.search(r"\bconsumeItem\s*\(\s*Items\.([A-Za-z_]\w*)\s*(?:,\s*[0-9_]+)?\s*\)\s*\.\s*boost\s*\(", source)
    return _camel_to_kebab(match.group(1)) if match else None

def _has_assignment(source: str, key: str) -> bool:
    return re.search(rf"\b{key}\s*=", source) is not None

def _boolean_assignment(source: str, key: str) -> bool | None:
    match = re.search(rf"\b{key}\s*=\s*(true|false)\s*;", source)
    return match.group(1) == "true" if match else None

def _consume_power_buffered_capacity(source: str) -> float | None:
    match = re.search(r"\bconsumePowerBuffered\s*\(\s*([0-9_]+(?:\.[0-9_]+)?[fFdD]?)\s*\)\s*;", source)
    return float(_number_literal(match.group(1))) if match else None

def _consume_power_usage(source: str) -> float | None:
    match = re.search(r"\bconsumePower\s*\(\s*([0-9_]+(?:\.[0-9_]+)?[fFdD]?(?:\s*/\s*[0-9_]+(?:\.[0-9_]+)?[fFdD]?)?)\s*\)\s*;", source)
    return _numeric_expression(match.group(1)) if match else None

def _numeric_expression(raw: str) -> float:
    parts = [part.strip() for part in raw.split("/")]
    value = float(_number_literal(parts[0]))
    for part in parts[1:]:
        value /= float(_number_literal(part))
    return value

def _color_value_assignment(source: str, key: str) -> str | None:
    match = re.search(rf"\b{key}\s*=\s*Color\.valueOf\(\s*\"([0-9A-Fa-f]+)\"\s*\)\s*;", source)
    return match.group(1).lower() if match else None

def _numeric_assignment(source: str, key: str) -> int | float | None:
    match = re.search(rf"\b{key}\s*=\s*([0-9_]+(?:\.[0-9_]+)?[fFdDlL]?)\s*;", source)
    return _number_literal(match.group(1)) if match else None


def _class_sources(upstream_root: Path) -> dict[str, str]:
    """Map block implementation class name -> source text."""
    sources: dict[str, str] = {}
    blocks_root = _source_world_dir(upstream_root) / "blocks"
    if blocks_root.exists():
        for source_path in blocks_root.rglob("*.java"):
            source = source_path.read_text(encoding="utf-8", errors="replace")
            class_match = re.search(r"\bclass\s+([A-Za-z_]\w*)", source)
            if class_match:
                sources[class_match.group(1)] = source
    return sources


def _numeric_field_values(source: str) -> dict[str, int | float]:
    """Numeric field defaults from a class source (`public float x = 0.5f;`)."""
    values: dict[str, int | float] = {}
    for match in re.finditer(r"\b(?:public|protected|private)\s+(?:static\s+)?(?:final\s+)?(?:float|int|double|long)\s+([A-Za-z_]\w*)\s*=\s*([0-9_]+(?:\.[0-9_]+)?[fFdDlL]?)\s*;", source):
        values[match.group(1)] = _number_literal(match.group(2))
    return values


def _numeric_assignments(source: str) -> dict[str, int | float]:
    """Numeric assignments in an initializer block (`heating = 0.02f;`)."""
    values: dict[str, int | float] = {}
    for match in re.finditer(r"\b([A-Za-z_]\w*)\s*=\s*([0-9_]+(?:\.[0-9_]+)?[fFdDlL]?)\s*;", source):
        values[match.group(1)] = _number_literal(match.group(2))
    return values

def _shoot_alternate_pattern(source: str) -> dict[str, Any] | None:
    match = re.search(r"\bshoot\s*=\s*new\s+ShootAlternate\s*\(\s*([0-9_]+(?:\.[0-9_]+)?[fFdD]?)\s*\)", source)
    if not match:
        return None
    return {"type": "ShootAlternate", "spread": _number_literal(match.group(1))}

def _block_ammo(initializer: str) -> list[dict[str, Any]]:
    pattern = re.compile(r"Items\.([A-Za-z_]\w*)\s*,\s*new\s+BasicBulletType\s*\(\s*([0-9_]+(?:\.[0-9_]+)?[fFdD]?)\s*,\s*([0-9_]+(?:\.[0-9_]+)?[fFdD]?)(?:\s*,\s*\"([^\"]+)\")?", re.MULTILINE)
    ammo = []
    for match in pattern.finditer(initializer):
        item, speed, damage, sprite = match.groups()
        entry = {"item": _camel_to_kebab(item), "speed": _number_literal(speed), "damage": _number_literal(damage), "sprite": sprite or "bullet"}
        bullet_body = _initializer_body(initializer, match.end())
        lifetime = _numeric_assignment(bullet_body, "lifetime")
        if lifetime is not None:
            entry["lifetime"] = lifetime
        width = _numeric_assignment(bullet_body, "width")
        if width is not None:
            entry["width"] = width
        height = _numeric_assignment(bullet_body, "height")
        if height is not None:
            entry["height"] = height
        hit_size = _numeric_assignment(bullet_body, "hitSize")
        if hit_size is not None:
            entry["hitSize"] = hit_size
        ammo_multiplier = _numeric_assignment(bullet_body, "ammoMultiplier")
        if ammo_multiplier is not None:
            entry["ammoMultiplier"] = ammo_multiplier
        reload_multiplier = _numeric_assignment(bullet_body, "reloadMultiplier")
        if reload_multiplier is not None:
            entry["reloadMultiplier"] = reload_multiplier
        range_change = _numeric_assignment(bullet_body, "rangeChange")
        if range_change is not None:
            entry["rangeChange"] = range_change
        extra_range_margin = _numeric_assignment(bullet_body, "extraRangeMargin")
        if extra_range_margin is not None:
            entry["extraRangeMargin"] = extra_range_margin
        inaccuracy = _numeric_assignment(bullet_body, "inaccuracy")
        if inaccuracy is not None:
            entry["inaccuracy"] = inaccuracy
        ammo.append(entry)
    return ammo

def _limit_range_margin(source: str) -> float | None:
    match = re.search(r"\blimitRange\s*\(\s*(-?[0-9_]+(?:\.[0-9_]+)?[fFdD]?)?\s*\)\s*;", source)
    if not match:
        return None
    raw = match.group(1)
    return 9.0 if raw is None else float(_number_literal(raw))

def _apply_limit_range_to_ammo(properties: dict[str, Any], ammo: list[dict[str, Any]], margin: float) -> None:
    for entry in ammo:
        speed = float(entry.get("speed", 0.0))
        if speed == 0.0:
            continue
        real_range = float(properties.get("range", 0.0)) + float(entry.get("rangeChange", 0.0))
        entry["lifetime"] = (real_range + margin + float(entry.get("extraRangeMargin", 0.0)) + 10.0) / speed

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

def _constructor_body(source: str, class_name: str) -> str:
    match = re.search(rf"\b{class_name}\s*\([^)]*\)\s*\{{", source)
    if not match:
        return ""
    start = match.end() - 1
    depth = 0
    for index in range(start, len(source)):
        char = source[index]
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return source[start:index + 1]
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
