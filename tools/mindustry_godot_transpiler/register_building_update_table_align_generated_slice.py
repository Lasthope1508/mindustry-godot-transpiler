from pathlib import Path
from mindustry_port import source_ssot, source_symbols

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_update_table_align_state"
PROOF = "/root/Main.BuildingConfigureStateModuleProof"
TESTS = ["test_building_update_table_align_generated_slice.py", "test_emitter.py"]


def field(type_name: str, expression: str, rule: str, status: str = "source-backed") -> dict:
    return {"type": type_name, "status": status, "java_source": SOURCE, "java_method": "updateTableAlign(Table)", "java_expr": expression, "rule": rule}


def main() -> None:
    source_symbols.upsert_source_symbols(GODOT, {
        "building_update_table_align.method": {
            "status": "source-backed", "source_slice": "N1956", "godot_owner": OWNER,
            "godot_symbol": "source_building_update_table_align_result.method", "java_source": SOURCE,
            "java_method": "updateTableAlign(Table)", "java_expr": "public void updateTableAlign(Table table){",
            "tests": TESTS, "runtime_proof": PROOF,
            "rule": "Exact table alignment hook boundary from BuildingComp.",
        },
        "building_update_table_align.mouse_screen": {
            "status": "source-backed", "source_slice": "N1956", "godot_owner": OWNER,
            "godot_symbol": "source_building_update_table_align_result.mouse_screen_input", "java_source": SOURCE,
            "java_method": "updateTableAlign(Table)", "java_expr": "Vec2 pos = Core.input.mouseScreen(x, y - block.size * tilesize / 2f - 1);",
            "tests": TESTS, "runtime_proof": PROOF,
            "rule": "Core input lookup is an explicit runtime dependency; canonical state does not access a singleton directly.",
        },
        "building_update_table_align.position": {
            "status": "source-backed", "source_slice": "N1956", "godot_owner": OWNER,
            "godot_symbol": "source_building_update_table_align_result.alignment", "java_source": SOURCE,
            "java_method": "updateTableAlign(Table)", "java_expr": "table.setPosition(pos.x, pos.y, Align.top);",
            "tests": TESTS, "runtime_proof": PROOF,
            "rule": "Table receives the mouse-screen position with Align.top exactly as upstream.",
        },
    })
    source_symbols.upsert_source_slice(GODOT, "N1956", {
        "status": "done", "java_source": SOURCE, "java_class": "mindustry.entities.comp.BuildingComp",
        "java_method": "updateTableAlign(Table)", "godot_owner": OWNER,
        "generated_owner": "BuildingComp.java_method_updateTableAlign_164",
        "exact_exprs": ["public void updateTableAlign(Table table){", "Vec2 pos = Core.input.mouseScreen(x, y - block.size * tilesize / 2f - 1);", "table.setPosition(pos.x, pos.y, Align.top);"],
        "source_symbols": ["building_update_table_align.method", "building_update_table_align.mouse_screen", "building_update_table_align.position"],
        "tests": TESTS, "runtime_proof": PROOF,
        "rule": "Generated updateTableAlign delegates to the canonical configure state while preserving the explicit mouse-screen dependency and top alignment.",
    })
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {
        "status": "active", "source_slice": "N1956", "java_source": SOURCE, "source_method": "updateTableAlign(Table)",
        "params": [
            {"name": "table", "type": "Table", "schema": "source_building_update_table_align_input.table"},
            {"name": "x", "type": "float", "schema": "source_building_update_table_align_input.x"},
            {"name": "y", "type": "float", "schema": "source_building_update_table_align_input.y"},
            {"name": "block_size", "type": "int", "schema": "source_building_update_table_align_input.block_size"},
            {"name": "tilesize", "type": "float", "schema": "source_building_update_table_align_input.tilesize"},
            {"name": "mouse_screen_position", "type": "Variant", "schema": "source_building_update_table_align_input.mouse_screen_position"},
        ],
        "return_keys": ["source_owner", "method", "mouse_screen_expr", "set_position_expr", "table", "x", "y", "block_size", "tilesize", "mouse_screen_x", "mouse_screen_y", "mouse_screen_input", "mouse_screen_y_input", "alignment", "updated"],
        "tests": TESTS, "runtime_proof": PROOF,
        "rule": "Runtime dependencies are explicit inputs; the result records the exact source expressions and top alignment.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_update_table_align_input", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {key: field(type_name, expr, rule, "explicit-input") for key, type_name, expr, rule in [
            ("table", "Variant", "public void updateTableAlign(Table table){", "Exact Java table parameter."),
            ("x", "float", "Core.input.mouseScreen(x, y - block.size * tilesize / 2f - 1);", "Building x coordinate dependency."),
            ("y", "float", "Core.input.mouseScreen(x, y - block.size * tilesize / 2f - 1);", "Building y coordinate dependency."),
            ("block_size", "int", "block.size * tilesize / 2f", "Block size dependency."),
            ("tilesize", "float", "block.size * tilesize / 2f", "World tilesize dependency."),
            ("mouse_screen_position", "Variant", "Vec2 pos = Core.input.mouseScreen(x, y - block.size * tilesize / 2f - 1);", "Resolved Core input position."),
        ]},
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_update_table_align_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {key: field(type_name, expr, rule) for key, type_name, expr, rule in [
            ("source_owner", "String", "PortGame.source_building_update_table_align_state", "Canonical owner marker."),
            ("method", "String", "public void updateTableAlign(Table table){", "Exact method identity."),
            ("mouse_screen_expr", "String", "Vec2 pos = Core.input.mouseScreen(x, y - block.size * tilesize / 2f - 1);", "Exact source lookup expression."),
            ("set_position_expr", "String", "table.setPosition(pos.x, pos.y, Align.top);", "Exact source table mutation expression."),
            ("table", "Variant", "public void updateTableAlign(Table table){", "Preserved table input."),
            ("x", "float", "Core.input.mouseScreen(x, y - block.size * tilesize / 2f - 1);", "Preserved x dependency."),
            ("y", "float", "Core.input.mouseScreen(x, y - block.size * tilesize / 2f - 1);", "Preserved y dependency."),
            ("block_size", "int", "block.size * tilesize / 2f", "Preserved block size dependency."),
            ("tilesize", "float", "block.size * tilesize / 2f", "Preserved tilesize dependency."),
            ("mouse_screen_x", "float", "pos.x", "Resolved screen x."),
            ("mouse_screen_y", "float", "pos.y", "Resolved screen y."),
            ("mouse_screen_input", "Variant", "Core.input.mouseScreen(x, y - block.size * tilesize / 2f - 1);", "Explicit resolved screen position."),
            ("mouse_screen_y_input", "float", "y - block.size * tilesize / 2f - 1", "Exact lookup y argument."),
            ("alignment", "String", "Align.top", "Top alignment constant."),
            ("updated", "bool", "table.setPosition(pos.x, pos.y, Align.top);", "Records that the source mutation was applied."),
        ]},
    })
    source_symbols.upsert_source_state_schema(GODOT, "generated_building_comp_update_table_align_bridge_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {key: field(type_name, expr, rule, "generated") for key, type_name, expr, rule in [
            ("source_owner", "String", "PortGame.source_building_update_table_align_state", "Canonical owner marker."),
            ("generated_owner", "String", "public void updateTableAlign(Table table){", "Generated callback identity."),
            ("result", "Dictionary", "table.setPosition(pos.x, pos.y, Align.top);", "Generated result."),
            ("canonical", "Dictionary", "table.setPosition(pos.x, pos.y, Align.top);", "Canonical result."),
            ("matches", "bool", "table.setPosition(pos.x, pos.y, Align.top);", "Generated and canonical results match."),
        ]},
    })
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
