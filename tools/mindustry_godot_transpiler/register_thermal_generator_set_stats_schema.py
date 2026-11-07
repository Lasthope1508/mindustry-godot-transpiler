from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
THERMAL_SOURCE = "core/src/mindustry/world/blocks/power/ThermalGenerator.java"
POWER_SOURCE = "core/src/mindustry/world/blocks/power/PowerGenerator.java"
BLOCK_SOURCE = "core/src/mindustry/world/Block.java"
STAT_SOURCE = "core/src/mindustry/world/meta/Stat.java"
STAT_UNIT_SOURCE = "core/src/mindustry/world/meta/StatUnit.java"
OWNER = "PortGame.source_thermal_generator_set_stats_state"
PROOF = "/root/Main.source_thermal_generator_set_stats_state"
METHOD = "setStats()"


def source_key(type_name: str, expression: str, rule: str, java_source: str = THERMAL_SOURCE) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": java_source,
        "java_method": METHOD,
        "java_expr": expression,
        "rule": rule,
        "used_by": [OWNER.lower()],
    }


def input_alias(type_name: str, name: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "alias_of": f"source_thermal_generator_set_stats_input.{name}",
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    keys = {
        "class": source_key("String", "public class ThermalGenerator extends PowerGenerator{", "ThermalGenerator class boundary."),
        "attribute_field": source_key("String", "public Attribute attribute = Attribute.heat;", "ThermalGenerator heat attribute field."),
        "display_efficiency_scale_field": source_key("String", "public float displayEfficiencyScale = 1f;", "ThermalGenerator display scale field."),
        "display_efficiency_field": source_key("String", "public boolean displayEfficiency = true;", "ThermalGenerator display toggle field."),
        "override": source_key("String", "@Override", "Override annotation for setStats."),
        "method": source_key("String", "public void setStats(){", "setStats method boundary."),
        "super_call": source_key("String", "super.setStats();", "Inherited PowerGenerator stats are applied first."),
        "tiles_stat_add": source_key("String", "stats.add(Stat.tiles, attribute, floating, size * size * displayEfficiencyScale, !displayEfficiency);", "Thermal tile stat registration."),
        "generation_type_remove": source_key("String", "stats.remove(generationType);", "Inherited generation stat is removed before the scaled replacement."),
        "generation_type_add": source_key("String", "stats.add(generationType, powerProduction * 60.0f / displayEfficiencyScale, StatUnit.powerSecond);", "Scaled generation stat registration."),
        "power_production_field": source_key("String", "public float powerProduction;", "Inherited PowerGenerator production field.", POWER_SOURCE),
        "generation_type_field": source_key("String", "public Stat generationType = Stat.basePowerGeneration;", "Inherited generation stat field.", POWER_SOURCE),
        "floating_field": source_key("String", "public boolean floating = false;", "Block floating field passed into tile stats.", BLOCK_SOURCE),
        "stats_add_attribute": source_key("Variant", "attribute", "Attribute argument supplied to the tile stat call."),
        "stats_remove": source_key("Variant", "stats.remove(generationType);", "Generation stat removal call state."),
        "stat_base_power_generation": source_key("String", "Stat.basePowerGeneration", "Default PowerGenerator generation stat.", POWER_SOURCE),
        "stat_tiles": source_key("String", "tiles = new Stat(\"tiles\", StatCat.crafting)", "Tile stat identifier declaration.", STAT_SOURCE),
        "stat_unit_power_second": source_key("String", "powerSecond = new StatUnit(\"powerSecond\", \"[accent]\" + Iconc.power + \"[]\")", "Power generation stat unit declaration.", STAT_UNIT_SOURCE),
        "power_production": input_alias("float", "power_production"),
        "display_efficiency_scale": input_alias("float", "display_efficiency_scale"),
        "display_efficiency": input_alias("bool", "display_efficiency"),
        "size": input_alias("float", "size"),
        "floating": input_alias("bool", "floating"),
        "super_set_stats_state": input_alias("Dictionary", "super_set_stats_state"),
        "tile_stat_scale": source_key("float", "size * size * displayEfficiencyScale", "Computed tile stat scale."),
        "tile_stat_start_zero": source_key("bool", "!displayEfficiency", "Computed tile stat start-zero flag."),
        "generation_stat_removed": source_key("bool", "stats.remove(generationType);", "Whether the inherited generation stat was removed."),
        "generation_stat_value": source_key("float", "powerProduction * 60.0f / displayEfficiencyScale", "Computed scaled generation stat value."),
        "generation_stat_unit": source_key("String", "powerSecond = new StatUnit(\"powerSecond\", \"[accent]\" + Iconc.power + \"[]\")", "Generation stat unit declaration.", STAT_UNIT_SOURCE),
        "tile_stat_call": source_key("Dictionary", "stats.add(Stat.tiles, attribute, floating, size * size * displayEfficiencyScale, !displayEfficiency);", "Tile stat call state."),
        "generation_stat_call": source_key("Dictionary", "stats.add(generationType, powerProduction * 60.0f / displayEfficiencyScale, StatUnit.powerSecond);", "Generation stat call state."),
    }
    source_symbols.upsert_source_state_schema(GODOT, "source_thermal_generator_set_stats_result", {
        "status": "active",
        "owner": OWNER,
        "runtime_proof": PROOF,
        "source_slice": "N933",
        "rule": "Dictionary returned by the source-backed ThermalGenerator.setStats state.",
        "keys": keys,
    })
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
