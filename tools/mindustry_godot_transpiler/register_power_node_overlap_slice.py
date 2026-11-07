from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/power/PowerNode.java"
TEST = "test_power_node_overlaps_matches_upstream_source"


def key(owner: str, method: str, expression: str, type_name: str, status: str = "source-backed") -> dict:
    return {
        "type": type_name,
        "status": status,
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
        "rule": "Exact upstream PowerNode overlap expression or explicit geometry runtime input.",
        "used_by": [owner.lower()],
    }


def alias(type_name: str, target: str, owner: str) -> dict:
    return {"type": type_name, "status": "generated", "alias_of": target, "used_by": [owner.lower()]}


def register(owner: str, slice_id: str, method: str, input_name: str, result_name: str, expressions: dict, inputs: dict, results: dict) -> None:
    symbols = {}
    for name, expression in expressions.items():
        symbols["power_node_overlaps." + name] = {
            "godot_owner": owner,
            "godot_symbol": result_name + "." + name,
            "java_expr": expression,
            "java_method": method,
            "java_source": SOURCE,
            "rule": "PowerNode overlap source expression.",
            "runtime_proof": "/root/Main.source_power_node_overlaps_state",
            "source_slice": slice_id,
            "status": "source-backed",
            "tests": [TEST],
        }
    for name, entry in inputs.items():
        symbols["power_node_overlaps." + name] = {
            "godot_owner": owner,
            "godot_symbol": input_name + "." + name,
            "java_expr": entry["java_expr"],
            "java_method": method,
            "java_source": SOURCE,
            "rule": "Explicit geometry runtime input for PowerNode overlap.",
            "runtime_proof": "/root/Main.source_power_node_overlaps_state",
            "source_slice": slice_id,
            "status": "explicit-input",
            "tests": [TEST],
        }
    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.upsert_source_slice(GODOT, slice_id, {
        "exact_exprs": list(expressions.values()),
        "deferred_exprs": ["Intersector/world geometry remains an explicit runtime input."],
        "godot_owner": owner,
        "java_class": "mindustry.world.blocks.power.PowerNode",
        "java_method": method,
        "java_source": SOURCE,
        "rule": "Registers PowerNode overlap overload behavior.",
        "runtime_proof": "/root/Main.source_power_node_overlaps_state",
        "source_symbols": list(symbols),
        "status": "done",
        "tests": [TEST],
    })
    source_symbols.upsert_source_api_contract(GODOT, owner, {
        "java_source": SOURCE,
        "params": [{"name": name, "schema": input_name + "." + name, "type": value["type"]} for name, value in inputs.items()],
        "return_keys": list(results),
        "rule": "Public runtime contract for PowerNode overlap state.",
        "runtime_proof": "/root/Main.source_power_node_overlaps_state",
        "source_method": method,
        "source_slice": slice_id,
        "status": "source-backed",
        "tests": [TEST],
    })
    source_symbols.upsert_source_state_schema(GODOT, input_name, {
        "keys": inputs,
        "owner": owner,
        "rule": "Explicit geometry inputs for PowerNode overlap.",
        "runtime_proof": "/root/Main.source_power_node_overlaps_state",
        "source_slice": slice_id,
        "status": "source-backed",
    })
    source_symbols.upsert_source_state_schema(GODOT, result_name, {
        "keys": results,
        "owner": owner,
        "rule": "Canonical PowerNode overlap result.",
        "runtime_proof": "/root/Main.source_power_node_overlaps_state",
        "source_slice": slice_id,
        "status": "source-backed",
    })


def main() -> None:
    owner = "PortGame.source_power_node_overlaps_state"
    method = "overlaps(...)"
    expressions = {
        "block_method": "protected boolean overlaps(float srcx, float srcy, Tile other, Block otherBlock, float range){",
        "block_expr": "Intersector.overlaps(Tmp.cr1.set(srcx, srcy, range), Tmp.r1.setCentered(other.worldx() + otherBlock.offset, other.worldy() + otherBlock.offset, otherBlock.size * tilesize, otherBlock.size * tilesize))",
        "tile_method": "protected boolean overlaps(float srcx, float srcy, Tile other, float range){",
        "tile_expr": "Intersector.overlaps(Tmp.cr1.set(srcx, srcy, range), other.getHitbox(Tmp.r1))",
        "building_method": "protected boolean overlaps(Building src, Building other, float range){",
        "building_expr": "return overlaps(src.x, src.y, other.tile, range);",
        "tile_range_method": "protected boolean overlaps(Tile src, Tile other, float range){",
        "tile_range_expr": "return overlaps(src.drawx(), src.drawy(), other, range);",
    }
    inputs = {
        "overlap_result": key(owner, method, "Intersector.overlaps(...)", "bool", "explicit-input"),
    }
    results = {name: key(owner, method, expression, "String") for name, expression in expressions.items()}
    results.update({"overlap_result": alias("bool", "source_power_node_overlaps_input.overlap_result", owner), "overlaps": key(owner, method, "return Intersector.overlaps(...)", "bool", "derived")})
    register(owner, "N1934", method, "source_power_node_overlaps_input", "source_power_node_overlaps_result", expressions, inputs, results)

    nullable_owner = "PortGame.source_power_node_overlaps_nullable_state"
    nullable_method = "public boolean overlaps(@Nullable Tile src, @Nullable Tile other){"
    nullable_expressions = {
        "method": nullable_method,
        "guard_expr": "if(src == null || other == null) return true;",
        "expression": "Intersector.overlaps(Tmp.cr1.set(src.worldx() + offset, src.worldy() + offset, laserRange * tilesize), Tmp.r1.setSize(size * tilesize).setCenter(other.worldx() + offset, other.worldy() + offset))",
    }
    nullable_inputs = {
        "src_present": key(nullable_owner, nullable_method, "src", "bool", "explicit-input"),
        "other_present": key(nullable_owner, nullable_method, "other", "bool", "explicit-input"),
        "overlap_result": key(nullable_owner, nullable_method, "Intersector.overlaps(...)" , "bool", "explicit-input"),
    }
    nullable_results = {name: key(nullable_owner, nullable_method, expression, "String") for name, expression in nullable_expressions.items()}
    nullable_results.update({
        name: alias("bool", "source_power_node_overlaps_nullable_input." + name, nullable_owner)
        for name in nullable_inputs
    })
    nullable_results["overlaps"] = key(nullable_owner, nullable_method, "if(src == null || other == null) return true;", "bool", "derived")
    register(nullable_owner, "N1935", nullable_method, "source_power_node_overlaps_nullable_input", "source_power_node_overlaps_nullable_result", nullable_expressions, nullable_inputs, nullable_results)
    for name in ("power_slices", "power_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
