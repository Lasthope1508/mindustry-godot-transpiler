from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
THERMAL_SOURCE = "core/src/mindustry/world/blocks/power/ThermalGenerator.java"
BLOCK_SOURCE = "core/src/mindustry/world/Block.java"
OWNER = "PortGame.source_thermal_generator_can_place_on_state"
PROOF = "/root/Main.source_thermal_generator_can_place_on_state"
METHOD = "canPlaceOn(Tile tile, Team team, int rotation)"


def source_key(type_name: str, expression: str, rule: str, java_source: str = THERMAL_SOURCE) -> dict:
    return {"type": type_name, "status": "source-backed", "java_source": java_source, "java_method": METHOD, "java_expr": expression, "rule": rule, "used_by": [OWNER.lower()]}


def input_alias(type_name: str, name: str) -> dict:
    return {"type": type_name, "status": "generated", "alias_of": f"source_thermal_generator_can_place_on_input.{name}", "used_by": [OWNER.lower()]}


def main() -> None:
    keys = {
        "class": source_key("String", "public class ThermalGenerator extends PowerGenerator{", "ThermalGenerator class boundary."),
        "attribute_field": source_key("String", "public Attribute attribute = Attribute.heat;", "Heat attribute field."),
        "min_efficiency_field": source_key("String", "public float minEfficiency = 0f;", "Minimum heat threshold field."),
        "override": source_key("String", "@Override", "Override annotation."),
        "method": source_key("String", "public boolean canPlaceOn(Tile tile, Team team, int rotation){", "Thermal canPlaceOn method boundary."),
        "heat_comment": source_key("String", "//make sure there's heat at this location", "Upstream placement rationale."),
        "return_can_place_on": source_key("String", "return tile.getLinkedTilesAs(this, tempTiles).sumf(other -> other.floor().attributes.get(attribute)) > minEfficiency;", "Heat threshold predicate."),
        "parent_method": source_key("String", "public boolean canPlaceOn(Tile tile, Team team, int rotation){", "Inherited Block placement predicate.", BLOCK_SOURCE),
        "parent_return": source_key("String", "return true;", "Inherited Block default placement result.", BLOCK_SOURCE),
        "linked_attribute_sum": input_alias("float", "linked_attribute_sum"),
        "min_efficiency": input_alias("float", "min_efficiency"),
        "can_place_on": source_key("bool", "return tile.getLinkedTilesAs(this, tempTiles).sumf(other -> other.floor().attributes.get(attribute)) > minEfficiency;", "Evaluated heat placement predicate."),
    }
    source_symbols.upsert_source_state_schema(GODOT, "source_thermal_generator_can_place_on_result", {"status": "active", "owner": OWNER, "runtime_proof": PROOF, "source_slice": "N931", "rule": "Dictionary returned by the source-backed ThermalGenerator.canPlaceOn state.", "keys": keys})
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
