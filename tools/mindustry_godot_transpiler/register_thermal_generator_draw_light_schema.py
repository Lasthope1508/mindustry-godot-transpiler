from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
THERMAL_SOURCE = "core/src/mindustry/world/blocks/power/ThermalGenerator.java"
DRAWF_SOURCE = "core/src/mindustry/graphics/Drawf.java"
MATHF_SOURCE = "arc-core/src/arc/math/Mathf.java"
COLOR_SOURCE = "arc-core/src/arc/graphics/Color.java"
OWNER = "PortGame.source_thermal_generator_draw_light_state"
PROOF = "/root/Main.source_thermal_generator_draw_light_state"
METHOD = "drawLight()"


def source_key(type_name: str, expression: str, rule: str, java_source: str = THERMAL_SOURCE, java_method: str = METHOD) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": java_source,
        "java_method": java_method,
        "java_expr": expression,
        "rule": rule,
        "used_by": [OWNER.lower()],
    }


def input_alias(type_name: str, name: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "alias_of": f"source_thermal_generator_draw_light_input.{name}",
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    keys = {
        "build_class": source_key("String", "public class ThermalGeneratorBuild extends GeneratorBuild{", "ThermalGenerator build class boundary."),
        "override": source_key("String", "@Override", "Override annotation for drawLight."),
        "method": source_key("String", "public void drawLight(){", "ThermalGenerator drawLight method boundary."),
        "drawf_light_call": source_key("String", "Drawf.light(x, y, (40f + Mathf.absin(10f, 5f)) * Math.min(productionEfficiency, 2f) * size, Color.scarlet, 0.4f);", "Thermal light dispatch call."),
        "drawf_light_method": source_key("String", "public static void light(float x, float y, float radius, Color color, float opacity){", "Drawf light overload.", DRAWF_SOURCE, "light(float x, float y, float radius, Color color, float opacity)"),
        "drawf_renderer_guard": source_key("String", "if(renderer == null) return;", "Drawf renderer null guard.", DRAWF_SOURCE, "light(float x, float y, float radius, Color color, float opacity)"),
        "drawf_lights_add": source_key("String", "renderer.lights.add(x, y, radius, color, opacity);", "Drawf light accumulation call.", DRAWF_SOURCE, "light(float x, float y, float radius, Color color, float opacity)"),
        "absin_time_overload": source_key("String", "public static float absin(float scl, float mag){", "Mathf absin overload using Time.time.", MATHF_SOURCE, "absin(float scl, float mag)"),
        "absin_time_return": source_key("String", "return absin(Time.time, scl, mag);", "Mathf absin delegates to the time overload.", MATHF_SOURCE, "absin(float scl, float mag)"),
        "absin_formula": source_key("String", "return (sin(in, scl * 2f, mag) + mag) / 2f;", "Mathf absin waveform formula.", MATHF_SOURCE, "absin(float in, float scl, float mag)"),
        "scarlet": source_key("String", "public static final Color scarlet = new Color(0xff341cff);", "Scarlet light color declaration.", COLOR_SOURCE, "Color.scarlet"),
        "source_x": input_alias("float", "source_x"),
        "source_y": input_alias("float", "source_y"),
        "source_time": input_alias("float", "source_time"),
        "production_efficiency": input_alias("float", "production_efficiency"),
        "size": input_alias("float", "size"),
        "absin": source_key("float", "Mathf.absin(10f, 5f)", "Time-based absin modulation.", MATHF_SOURCE, "absin(float scl, float mag)"),
        "capped_production_efficiency": source_key("float", "Math.min(productionEfficiency, 2f)", "Production efficiency cap in light radius."),
        "light_radius": source_key("float", "(40f + Mathf.absin(10f, 5f)) * Math.min(productionEfficiency, 2f) * size", "Computed thermal light radius."),
        "light_color": source_key("String", "Color.scarlet", "Color passed into Drawf.light."),
        "light_color_rgba8888": source_key("String", "0xff341cff", "Scarlet color packed value.", COLOR_SOURCE, "Color.scarlet"),
        "opacity": source_key("float", "0.4f", "Thermal light opacity."),
        "light_call": source_key("Dictionary", "Drawf.light(x, y, (40f + Mathf.absin(10f, 5f)) * Math.min(productionEfficiency, 2f) * size, Color.scarlet, 0.4f);", "Evaluated Drawf.light dispatch state."),
    }
    source_symbols.upsert_source_state_schema(GODOT, "source_thermal_generator_draw_light_result", {
        "status": "active",
        "owner": OWNER,
        "runtime_proof": PROOF,
        "source_slice": "N932",
        "rule": "Dictionary returned by the source-backed ThermalGeneratorBuild.drawLight state.",
        "keys": keys,
    })
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
