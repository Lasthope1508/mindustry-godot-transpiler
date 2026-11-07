from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/power/PowerNode.java"
TEST = "test_power_node_presentation_matches_upstream_source"


def source_key(owner: str, method: str, expression: str, type_name: str, status: str = "source-backed") -> dict:
    return {
        "type": type_name,
        "status": status,
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
        "rule": "Exact upstream PowerNode presentation expression or explicit render input.",
        "used_by": [owner.lower()],
    }


def alias(type_name: str, target: str, owner: str) -> dict:
    return {"type": type_name, "status": "generated", "alias_of": target, "used_by": [owner.lower()]}


def register(owner: str, slice_id: str, method: str, input_name: str, result_name: str, expressions: dict, inputs: dict, results: dict) -> None:
    symbols = {
        "power_node_presentation." + name: {
            "godot_owner": owner,
            "godot_symbol": result_name + "." + name,
            "java_expr": expression,
            "java_method": method,
            "java_source": SOURCE,
            "rule": "PowerNode presentation source expression.",
            "runtime_proof": "/root/Main.source_power_node_presentation_state",
            "source_slice": slice_id,
            "status": "source-backed",
            "tests": [TEST],
        }
        for name, expression in expressions.items()
    }
    symbols.update({
        "power_node_presentation." + name: {
            "godot_owner": owner,
            "godot_symbol": input_name + "." + name,
            "java_expr": entry["java_expr"],
            "java_method": method,
            "java_source": SOURCE,
            "rule": "Explicit render-engine input for PowerNode presentation.",
            "runtime_proof": "/root/Main.source_power_node_presentation_state",
            "source_slice": slice_id,
            "status": "explicit-input",
            "tests": [TEST],
        }
        for name, entry in inputs.items()
    })
    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.upsert_source_slice(GODOT, slice_id, {
        "exact_exprs": list(expressions.values()),
        "deferred_exprs": ["Godot renderer and texture resources remain explicit runtime inputs."],
        "godot_owner": owner,
        "java_class": "mindustry.world.blocks.power.PowerNode",
        "java_method": method,
        "java_source": SOURCE,
        "rule": "Registers PowerNode presentation state.",
        "runtime_proof": "/root/Main.source_power_node_presentation_state",
        "source_symbols": list(symbols),
        "status": "done",
        "tests": [TEST],
    })
    source_symbols.upsert_source_api_contract(GODOT, owner, {
        "java_source": SOURCE,
        "params": [{"name": name, "schema": input_name + "." + name, "type": entry["type"]} for name, entry in inputs.items()],
        "return_keys": list(results),
        "rule": "Public runtime contract for PowerNode presentation state.",
        "runtime_proof": "/root/Main.source_power_node_presentation_state",
        "source_method": method,
        "source_slice": slice_id,
        "status": "source-backed",
        "tests": [TEST],
    })
    source_symbols.upsert_source_state_schema(GODOT, input_name, {
        "keys": inputs,
        "owner": owner,
        "rule": "Explicit presentation inputs for PowerNode.",
        "runtime_proof": "/root/Main.source_power_node_presentation_state",
        "source_slice": slice_id,
        "status": "source-backed",
    })
    source_symbols.upsert_source_state_schema(GODOT, result_name, {
        "keys": results,
        "owner": owner,
        "rule": "Canonical PowerNode presentation result.",
        "runtime_proof": "/root/Main.source_power_node_presentation_state",
        "source_slice": slice_id,
        "status": "source-backed",
    })


def main() -> None:
    owner = "PortGame.source_power_node_setup_color_state"
    setup_method = "setupColor(float satisfaction)"
    setup_input = "source_power_node_setup_color_input"
    setup_result = "source_power_node_setup_color_result"
    setup_expr = {
        "method": "protected void setupColor(float satisfaction){",
        "expression": "Draw.color(Tmp.c1.set(laserColor1).lerp(laserColor2, (1f - satisfaction) * 0.86f + Mathf.absin(3f, 0.1f)).a(Renderer.laserOpacity * Lod.alpha2));",
    }
    setup_inputs = {
        name: source_key(owner, setup_method, expression, "float", "explicit-input")
        for name, expression in {
            "satisfaction": "satisfaction",
            "laser_opacity": "Renderer.laserOpacity",
            "lod_alpha2": "Lod.alpha2",
            "absin_value": "Mathf.absin(3f, 0.1f)",
        }.items()
    }
    setup_results = {name: source_key(owner, setup_method, expression, "String") for name, expression in setup_expr.items()}
    setup_results.update({name: alias("float", setup_input + "." + name, owner) for name in setup_inputs})
    setup_results.update({"lerp_factor": source_key(owner, setup_method, "(1f - satisfaction) * 0.86f + Mathf.absin(3f, 0.1f)", "float", "derived"), "alpha": source_key(owner, setup_method, "Renderer.laserOpacity * Lod.alpha2", "float", "derived")})
    register(owner, "N1936", setup_method, setup_input, setup_result, setup_expr, setup_inputs, setup_results)

    owner = "PortGame.source_power_node_draw_laser_state"
    laser_method = "drawLaser(float x1, float y1, float x2, float y2, int size1, int size2, boolean light)"
    laser_input = "source_power_node_draw_laser_input"
    laser_result = "source_power_node_draw_laser_result"
    laser_expr = {
        "method": "public void drawLaser(float x1, float y1, float x2, float y2, int size1, int size2){",
        "overload_method": laser_method,
        "delegate_expr": "drawLaser(x1, y1, x2, y2, size1, size2, true);",
        "angle_expr": "float angle1 = Angles.angle(x1, y1, x2, y2),",
        "vector_expr": "vx = Mathf.cosDeg(angle1), vy = Mathf.sinDeg(angle1),",
        "length_expr": "len1 = size1 * tilesize / 2f - 1.5f, len2 = size2 * tilesize / 2f - 1.5f;",
        "draw_expr": "Drawf.laser(laser, laserEnd, laserEnd, x1 + vx*len1, y1 + vy*len1, x2 - vx*len2, y2 - vy*len2, laserScale, light);",
    }
    laser_inputs = {
        "laser_state": source_key(owner, laser_method, "x1, y1, x2, y2, size1, size2, tilesize, angle1, vx, vy", "Dictionary", "explicit-input"),
        "light": source_key(owner, laser_method, "light", "bool", "explicit-input"),
    }
    laser_results = {name: source_key(owner, laser_method, expression, "String") for name, expression in laser_expr.items()}
    laser_results.update({name: alias(entry["type"], laser_input + "." + name, owner) for name, entry in laser_inputs.items()})
    laser_results.update({name: source_key(owner, laser_method, expression, "float", "derived") for name, expression in {"angle1": "Angles.angle(x1, y1, x2, y2)", "vx": "Mathf.cosDeg(angle1)", "vy": "Mathf.sinDeg(angle1)", "len1": "size1 * tilesize / 2f - 1.5f", "len2": "size2 * tilesize / 2f - 1.5f"}.items()})
    laser_results.update({"start": source_key(owner, laser_method, "x1 + vx*len1, y1 + vy*len1", "Vector2", "derived"), "end": source_key(owner, laser_method, "x2 - vx*len2, y2 - vy*len2", "Vector2", "derived")})
    register(owner, "N1937", laser_method, laser_input, laser_result, laser_expr, laser_inputs, laser_results)
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
