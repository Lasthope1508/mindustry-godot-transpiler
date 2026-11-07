from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
THERMAL_SOURCE = "core/src/mindustry/world/blocks/power/ThermalGenerator.java"
BLOCK_SOURCE = "core/src/mindustry/world/Block.java"
BUNDLE_SOURCE = "core/assets/bundles/bundle.properties"
OWNER = "PortGame.source_thermal_generator_draw_place_state"
PROOF = "/root/Main.source_thermal_generator_draw_place_state"
METHOD = "drawPlace(int x, int y, int rotation, boolean valid)"


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
        "alias_of": f"source_thermal_generator_draw_place_input.{name}",
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    keys = {
        "class": source_key("String", "public class ThermalGenerator extends PowerGenerator{", "ThermalGenerator class boundary."),
        "display_efficiency_scale_field": source_key("String", "public float displayEfficiencyScale = 1f;", "ThermalGenerator display scale field."),
        "display_efficiency_field": source_key("String", "public boolean displayEfficiency = true;", "ThermalGenerator display toggle field."),
        "attribute_field": source_key("String", "public Attribute attribute = Attribute.heat;", "ThermalGenerator heat attribute field."),
        "method": source_key("String", "public void drawPlace(int x, int y, int rotation, boolean valid){", "ThermalGenerator drawPlace method boundary."),
        "super_draw_place": source_key("String", "super.drawPlace(x, y, rotation, valid);", "Inherited Block placement draw runs first."),
        "display_efficiency_guard": source_key("String", "if(displayEfficiency){", "Placement text is conditional on displayEfficiency."),
        "draw_place_text_call": source_key("String", "drawPlaceText(Core.bundle.formatFloat(\"bar.efficiency\", sumAttribute(attribute, x, y) * 100 * displayEfficiencyScale, 1), x, y, valid);", "Thermal placement efficiency text call."),
        "block_draw_place": source_key("String", "public void drawPlace(int x, int y, int rotation, boolean valid){", "Inherited Block drawPlace contract.", BLOCK_SOURCE),
        "block_draw_place_text": source_key("String", "public float drawPlaceText(String text, int x, int y, boolean valid){", "Inherited Block placement text overload.", BLOCK_SOURCE),
        "bundle_efficiency": source_key("String", "bar.efficiency = Efficiency: {0}%", "Efficiency placement label.", BUNDLE_SOURCE),
        "x": input_alias("int", "x"),
        "y": input_alias("int", "y"),
        "rotation": input_alias("int", "rotation"),
        "valid": input_alias("bool", "valid"),
        "display_efficiency": input_alias("bool", "display_efficiency"),
        "sum_attribute": input_alias("float", "sum_attribute"),
        "display_efficiency_scale": input_alias("float", "display_efficiency_scale"),
        "efficiency_value": source_key("float", "sumAttribute(attribute, x, y) * 100 * displayEfficiencyScale", "Computed percentage shown by the placement text."),
        "bundle_key": source_key("String", "\"bar.efficiency\"", "Bundle key passed to Core.bundle.formatFloat."),
        "decimals": source_key("int", "1", "One decimal place passed to Core.bundle.formatFloat."),
        "draw_place_text_added": input_alias("bool", "display_efficiency"),
        "draw_place_text_state": source_key("Dictionary", "drawPlaceText(Core.bundle.formatFloat(\"bar.efficiency\", sumAttribute(attribute, x, y) * 100 * displayEfficiencyScale, 1), x, y, valid);", "Canonical placement text state produced by the guarded branch."),
    }
    source_symbols.upsert_source_state_schema(GODOT, "source_thermal_generator_draw_place_result", {
        "status": "active",
        "owner": OWNER,
        "runtime_proof": PROOF,
        "source_slice": "N935",
        "rule": "Dictionary returned by the source-backed ThermalGenerator.drawPlace state.",
        "keys": keys,
    })
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
