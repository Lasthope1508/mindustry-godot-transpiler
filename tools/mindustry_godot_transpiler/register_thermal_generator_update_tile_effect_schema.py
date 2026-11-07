from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
THERMAL_SOURCE = "core/src/mindustry/world/blocks/power/ThermalGenerator.java"
MATHF_SOURCE = "arc-core/src/arc/math/Mathf.java"
OWNER = "PortGame.source_thermal_generator_update_tile_effect_state"
PROOF = "/root/Main.source_thermal_generator_update_tile_effect_state"
METHOD = "updateTile() effect branch"


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
        "alias_of": f"source_thermal_generator_update_tile_effect_input.{name}",
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    keys = {
        "method": source_key("String", "public void updateTile(){", "ThermalGenerator updateTile method boundary."),
        "generate_effect_field": source_key("String", "public Effect generateEffect = Fx.none;", "ThermalGenerator effect field."),
        "effect_chance_field": source_key("String", "public float effectChance = 0.05f;", "ThermalGenerator effect chance field."),
        "effect_gate": source_key("String", "if(productionEfficiency > 0.1f && Mathf.chanceDelta(effectChance)){", "ThermalGenerator effect branch guard."),
        "generate_effect_call": source_key("String", "generateEffect.at(x + Mathf.range(3f), y + Mathf.range(3f));", "ThermalGenerator effect dispatch call."),
        "chance_delta_method": source_key("String", "public static boolean chanceDelta(double d){", "Mathf chanceDelta method boundary.", MATHF_SOURCE),
        "chance_delta_return": source_key("String", "return rand.nextFloat() < d * Time.delta;", "Mathf chanceDelta return expression.", MATHF_SOURCE),
        "range_method": source_key("String", "public static float range(float range){", "Mathf range method boundary.", MATHF_SOURCE),
        "range_return": source_key("String", "return random(-range, range);", "Mathf range return expression.", MATHF_SOURCE),
        "source_x": input_alias("float", "source_x"),
        "source_y": input_alias("float", "source_y"),
        "production_efficiency": input_alias("float", "production_efficiency"),
        "effect_chance": input_alias("float", "effect_chance"),
        "chance_delta_result": input_alias("bool", "chance_delta_result"),
        "range_x": input_alias("float", "range_x"),
        "range_y": input_alias("float", "range_y"),
        "generate_effect_name": input_alias("String", "generate_effect_name"),
        "effect_triggered": source_key("bool", "productionEfficiency > 0.1f && Mathf.chanceDelta(effectChance)", "Evaluated ThermalGenerator effect gate result."),
        "effect_x": source_key("float", "x + Mathf.range(3f)", "Evaluated x coordinate for generateEffect.at."),
        "effect_y": source_key("float", "y + Mathf.range(3f)", "Evaluated y coordinate for generateEffect.at."),
        "generate_effect_state": {
            "type": "Dictionary",
            "status": "generated",
            "alias_of": "source_thermal_generator_update_tile_effect_input.generate_effect_name",
            "used_by": [OWNER.lower()],
        },
    }
    source_symbols.upsert_source_state_schema(
        GODOT,
        "source_thermal_generator_update_tile_effect_result",
        {
            "status": "active",
            "owner": OWNER,
            "runtime_proof": PROOF,
            "source_slice": "N936",
            "rule": "Dictionary returned by the source-backed ThermalGeneratorBuild.updateTile effect state.",
            "keys": keys,
        },
    )
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
