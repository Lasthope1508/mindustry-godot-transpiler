from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_is_discovered_state"
PROOF = "/root/Main.BuildingVisibilityStateModuleProof"
TESTS = ["test_building_visibility_slice.py", "test_emitter.py", "test_source_parity.py"]


def main() -> None:
    expressions = [
        "public boolean isDiscovered(Team viewer){",
        "if(state.rules.limitMapArea && world.getDarkness(tile.x, tile.y) >= 3){",
        "if(viewer == null || !state.rules.staticFog || !state.rules.fog){",
        "if(block.size <= 2){",
        "int s = block.size / 2;",
        "fogControl.isDiscovered(viewer, tile.x + s, tile.y - s);",
    ]
    symbols = {
        "building_is_discovered.method": {
            "status": "source-backed", "godot_owner": OWNER, "godot_symbol": "source_building_is_discovered_result.is_discovered",
            "rule": "Building discovery follows the source darkness, fog-policy, and edge-probe order.", "tests": TESTS,
            "runtime_proof": PROOF, "java_source": SOURCE, "java_method": "isDiscovered(Team)", "java_expr": expressions[0],
        },
        "building_is_discovered.darkness_gate": {
            "status": "source-backed", "godot_owner": OWNER, "godot_symbol": "source_building_is_discovered_result.path",
            "rule": "Map darkness blocks discovery before any fog probe.", "tests": TESTS,
            "runtime_proof": PROOF, "java_source": SOURCE, "java_method": "isDiscovered(Team)", "java_expr": expressions[1],
        },
        "building_is_discovered.fog_probes": {
            "status": "source-backed", "godot_owner": OWNER, "godot_symbol": "source_building_is_discovered_result.probes",
            "rule": "Large blocks preserve the source center plus four-corner discovery probes.", "tests": TESTS,
            "runtime_proof": PROOF, "java_source": SOURCE, "java_method": "isDiscovered(Team)", "java_expr": expressions[-1],
        },
    }
    source_symbols.upsert_source_slice(GODOT, "N1913", {
        "status": "done", "java_source": SOURCE, "java_class": "mindustry.entities.comp.BuildingComp", "java_method": "isDiscovered(Team)",
        "godot_owner": OWNER, "exact_exprs": expressions, "source_symbols": list(symbols), "tests": TESTS,
        "runtime_proof": PROOF, "rule": "Canonical visibility owner mirrors BuildingComp.isDiscovered map and fog probes.",
    })
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {
        "status": "active", "source_slice": "N1913", "java_source": SOURCE, "source_method": "BuildingComp.isDiscovered(Team)",
        "params": [
            {"name": "limit_map_area", "type": "bool", "schema": "source_building_is_discovered_input.limit_map_area"},
            {"name": "darkness", "type": "float", "schema": "source_building_is_discovered_input.darkness"},
            {"name": "fog_discovered_lookup", "type": "Callable", "schema": "source_building_is_discovered_input.fog_discovered_lookup"},
        ],
        "return_keys": ["source_owner", "is_discovered", "path", "probes", "discovered_point"], "tests": TESTS,
        "runtime_proof": PROOF, "rule": "Explicit environment and fog lookup dependencies preserve source-order discovery semantics.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_is_discovered_input", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "limit_map_area": {"type": "bool", "status": "explicit-input", "java_source": SOURCE, "java_expr": "state.rules.limitMapArea", "rule": "Map area darkness gate."},
            "darkness": {"type": "float", "status": "explicit-input", "java_source": SOURCE, "java_expr": "world.getDarkness(tile.x, tile.y)", "rule": "World darkness at Building tile."},
            "fog_discovered_lookup": {"type": "Callable", "status": "explicit-input", "java_source": SOURCE, "java_expr": "fogControl.isDiscovered(viewer, ...)", "rule": "Fog discovery dependency."},
        },
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_is_discovered_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "is_discovered": {"type": "bool", "status": "source-backed", "java_source": SOURCE, "java_expr": "return fogControl.isDiscovered(viewer, tile.x, tile.y);", "rule": "Final source discovery result."},
            "path": {"type": "String", "status": "source-backed", "java_source": SOURCE, "java_expr": "if(viewer == null || !state.rules.staticFog || !state.rules.fog){", "rule": "Executed source branch."},
            "probes": {"type": "Array", "status": "source-backed", "java_source": SOURCE, "java_expr": "int s = block.size / 2;", "rule": "Center/corner probe coordinates."},
            "discovered_point": {"type": "Variant", "status": "source-backed", "java_source": SOURCE, "java_expr": "fogControl.isDiscovered(viewer, tile.x + s, tile.y - s);", "rule": "First successful source-ordered probe or null."},
        },
    })
    source_symbols.upsert_source_symbols(GODOT, symbols)
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
