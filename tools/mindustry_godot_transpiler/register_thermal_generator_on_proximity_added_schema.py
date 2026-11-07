from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
THERMAL_SOURCE = "core/src/mindustry/world/blocks/power/ThermalGenerator.java"
BUILDING_COMP_SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
BLOCK_SOURCE = "core/src/mindustry/world/Block.java"
OWNER = "PortGame.source_thermal_generator_on_proximity_added_state"
PROOF = "/root/Main.source_thermal_generator_on_proximity_added_state"
METHOD = "onProximityAdded()"


def source_key(type_name: str, expression: str, rule: str, java_source: str = THERMAL_SOURCE) -> dict:
    return {"type": type_name, "status": "source-backed", "java_source": java_source, "java_method": METHOD, "java_expr": expression, "rule": rule, "used_by": [OWNER.lower()]}


def input_alias(type_name: str, name: str) -> dict:
    return {"type": type_name, "status": "generated", "alias_of": f"source_thermal_generator_on_proximity_added_input.{name}", "used_by": [OWNER.lower()]}


def main() -> None:
    keys = {
        "build_class": source_key("String", "public class ThermalGeneratorBuild extends GeneratorBuild{", "ThermalGenerator build class boundary."),
        "sum_field": source_key("String", "public float sum;", "Cached attribute sum field."),
        "override": source_key("String", "@Override", "Override annotation."),
        "method": source_key("String", "public void onProximityAdded(){", "Thermal onProximityAdded method boundary."),
        "super_call": source_key("String", "super.onProximityAdded();", "Inherited proximity callback runs first."),
        "sum_assignment": source_key("String", "sum = sumAttribute(attribute, tile.x, tile.y);", "Cache linked attribute sum after proximity setup."),
        "parent_comment": source_key("String", "Called after this building is created in the world. May be called multiple times, or when adjacent buildings change.", "Inherited callback documentation.", BUILDING_COMP_SOURCE),
        "parent_method": source_key("String", "public void onProximityAdded(){", "Inherited BuildingComp callback.", BUILDING_COMP_SOURCE),
        "parent_power_guard": source_key("String", "if(power != null){", "Power graph update guard.", BUILDING_COMP_SOURCE),
        "parent_update_power_graph": source_key("String", "updatePowerGraph();", "Power graph update call.", BUILDING_COMP_SOURCE),
        "sum_attribute_method": source_key("String", "public float sumAttribute(@Nullable Attribute attr, int x, int y){", "Block attribute aggregation helper.", BLOCK_SOURCE),
        "sum_attribute_null_attr": source_key("String", "if(attr == null) return 0;", "Null attribute guard.", BLOCK_SOURCE),
        "sum_attribute_null_tile": source_key("String", "if(tile == null) return 0;", "Null tile guard.", BLOCK_SOURCE),
        "sum_attribute": input_alias("float", "sum_attribute"),
        "super_on_proximity_added_state": input_alias("Dictionary", "super_on_proximity_added_state"),
        "sum": source_key("float", "sum = sumAttribute(attribute, tile.x, tile.y);", "Evaluated cached attribute sum."),
    }
    source_symbols.upsert_source_state_schema(GODOT, "source_thermal_generator_on_proximity_added_result", {"status": "active", "owner": OWNER, "runtime_proof": PROOF, "source_slice": "N930", "rule": "Dictionary returned by the source-backed ThermalGeneratorBuild.onProximityAdded state.", "keys": keys})
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
