from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
THERMAL_SOURCE = "core/src/mindustry/world/blocks/power/ThermalGenerator.java"
OWNER = "PortGame.source_thermal_generator_update_tile_output_liquid_state"
PROOF = "/root/Main.source_thermal_generator_update_tile_output_liquid_state"
METHOD = "updateTile() outputLiquid branch"


def source_key(type_name: str, expression: str, rule: str) -> dict:
    return {"type": type_name, "status": "source-backed", "java_source": THERMAL_SOURCE, "java_method": METHOD, "java_expr": expression, "rule": rule, "used_by": [OWNER.lower()]}


def input_alias(type_name: str, name: str) -> dict:
    return {"type": type_name, "status": "generated", "alias_of": f"source_thermal_generator_update_tile_output_liquid_input.{name}", "used_by": [OWNER.lower()]}


def main() -> None:
    keys = {
        "class": source_key("String", "public class ThermalGenerator extends PowerGenerator{", "ThermalGenerator class boundary."),
        "method": source_key("String", "public void updateTile(){", "ThermalGenerator updateTile method boundary."),
        "output_liquid_field": source_key("String", "public @Nullable LiquidStack outputLiquid;", "Output liquid field."),
        "build_class": source_key("String", "public class ThermalGeneratorBuild extends GeneratorBuild{", "ThermalGenerator build class boundary."),
        "output_liquid_guard": source_key("String", "if(outputLiquid != null){", "Output-liquid branch guard."),
        "added_assignment": source_key("String", "float added = Math.min(productionEfficiency * delta() * outputLiquid.amount, liquidCapacity - liquids.get(outputLiquid.liquid));", "Output-liquid amount clamp."),
        "liquids_add_call": source_key("String", "liquids.add(outputLiquid.liquid, added);", "Output-liquid storage mutation."),
        "dump_liquid_call": source_key("String", "dumpLiquid(outputLiquid.liquid);", "Output-liquid dump dispatch."),
        "output_liquid_present": input_alias("bool", "output_liquid_present"),
        "output_liquid_liquid": input_alias("String", "output_liquid_liquid"),
        "output_liquid_amount": input_alias("float", "output_liquid_amount"),
        "production_efficiency": input_alias("float", "production_efficiency"),
        "delta_value": input_alias("float", "delta_value"),
        "liquid_capacity": input_alias("float", "liquid_capacity"),
        "current_liquid_amount": input_alias("float", "current_liquid_amount"),
        "production_liquid_amount": source_key("float", "productionEfficiency * delta() * outputLiquid.amount", "Computed liquid production before capacity clamp."),
        "remaining_capacity": source_key("float", "liquidCapacity - liquids.get(outputLiquid.liquid)", "Remaining liquid capacity before add."),
        "added": source_key("float", "Math.min(productionEfficiency * delta() * outputLiquid.amount, liquidCapacity - liquids.get(outputLiquid.liquid))", "Evaluated clamped liquid amount."),
        "liquid_amount_after": {"type": "float", "status": "generated", "java_expr": "liquids.get(outputLiquid.liquid) + added", "alias_of": "source_thermal_generator_update_tile_output_liquid_input.current_liquid_amount + source_thermal_generator_update_tile_output_liquid_result.added", "used_by": [OWNER.lower()]},
        "dump_liquid_called": source_key("bool", "dumpLiquid(outputLiquid.liquid);", "Dump call occurs inside output-liquid branch."),
        "dump_liquid_state": source_key("Dictionary", "dumpLiquid(outputLiquid.liquid);", "Canonical dump dispatch state."),
    }
    source_symbols.upsert_source_state_schema(GODOT, "source_thermal_generator_update_tile_output_liquid_result", {"status": "active", "owner": OWNER, "runtime_proof": PROOF, "source_slice": "N937", "rule": "Dictionary returned by the source-backed ThermalGeneratorBuild.updateTile outputLiquid state.", "keys": keys})
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
