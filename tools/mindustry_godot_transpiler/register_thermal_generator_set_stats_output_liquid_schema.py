from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
THERMAL_SOURCE = "core/src/mindustry/world/blocks/power/ThermalGenerator.java"
LIQUID_STACK_SOURCE = "core/src/mindustry/type/LiquidStack.java"
STAT_SOURCE = "core/src/mindustry/world/meta/Stat.java"
STAT_VALUES_SOURCE = "core/src/mindustry/world/meta/StatValues.java"
OWNER = "PortGame.source_thermal_generator_set_stats_output_liquid_state"
PROOF = "/root/Main.source_thermal_generator_set_stats_output_liquid_state"
METHOD = "setStats() outputLiquid branch"


def source_key(type_name: str, expression: str, rule: str, java_source: str = THERMAL_SOURCE, java_method: str = METHOD) -> dict:
    return {"type": type_name, "status": "source-backed", "java_source": java_source, "java_method": java_method, "java_expr": expression, "rule": rule, "used_by": [OWNER.lower()]}


def input_alias(type_name: str, name: str) -> dict:
    return {"type": type_name, "status": "generated", "alias_of": f"source_thermal_generator_set_stats_output_liquid_input.{name}", "used_by": [OWNER.lower()]}


def main() -> None:
    keys = {
        "class": source_key("String", "public class ThermalGenerator extends PowerGenerator{", "ThermalGenerator class boundary."),
        "output_liquid_field": source_key("String", "public @Nullable LiquidStack outputLiquid;", "Output liquid field."),
        "method": source_key("String", "public void setStats(){", "ThermalGenerator setStats method boundary."),
        "output_liquid_guard": source_key("String", "if(outputLiquid != null){", "Output-liquid stats branch guard."),
        "output_liquid_stat_add": source_key("String", "stats.add(Stat.output, StatValues.liquid(outputLiquid.liquid, outputLiquid.amount * size * size * 60f, true));", "Output-liquid stat registration."),
        "liquid_stack_class": source_key("String", "public class LiquidStack implements Comparable<LiquidStack>{", "LiquidStack class boundary.", LIQUID_STACK_SOURCE, "LiquidStack"),
        "liquid_stack_liquid": source_key("String", "public Liquid liquid;", "LiquidStack liquid field.", LIQUID_STACK_SOURCE, "LiquidStack"),
        "liquid_stack_amount": source_key("String", "public float amount;", "LiquidStack amount field.", LIQUID_STACK_SOURCE, "LiquidStack"),
        "stat_output": source_key("String", "output = new Stat(\"output\", StatCat.crafting),", "Output stat declaration.", STAT_SOURCE, "Stat"),
        "stat_values_liquid": source_key("String", "public static StatValue liquid(Liquid liquid, float amount, boolean perSecond){", "Liquid stat value factory.", STAT_VALUES_SOURCE, "liquid(Liquid liquid, float amount, boolean perSecond)"),
        "stat_values_liquid_return": source_key("String", "return table -> table.add(displayLiquid(liquid, amount, perSecond)).left();", "Liquid stat value table population.", STAT_VALUES_SOURCE, "liquid(Liquid liquid, float amount, boolean perSecond)"),
        "output_liquid_present": input_alias("bool", "output_liquid_present"),
        "output_liquid_liquid": input_alias("String", "output_liquid_liquid"),
        "output_liquid_amount": input_alias("float", "output_liquid_amount"),
        "size": input_alias("float", "size"),
        "output_stat_added": input_alias("bool", "output_liquid_present"),
        "output_stat_amount": source_key("float", "outputLiquid.amount * size * size * 60f", "Computed per-second output stat amount."),
        "output_stat_call": source_key("Dictionary", "stats.add(Stat.output, StatValues.liquid(outputLiquid.liquid, outputLiquid.amount * size * size * 60f, true));", "Evaluated output stat registration state."),
    }
    source_symbols.upsert_source_state_schema(GODOT, "source_thermal_generator_set_stats_output_liquid_result", {"status": "active", "owner": OWNER, "runtime_proof": PROOF, "source_slice": "N934", "rule": "Dictionary returned by the source-backed ThermalGenerator.setStats outputLiquid state.", "keys": keys})
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
