from pathlib import Path
from mindustry_port import source_ssot, source_symbols

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_cursor_state"
PROOF = "/root/Main.source_building_cursor_state"
TESTS = ["test_building_get_cursor_generated_slice.py", "test_emitter.py", "test_source_symbols.py"]


def main() -> None:
    source_symbols.upsert_source_symbols(GODOT, {
        "building_cursor.generated_delegate": {
            "status": "source-backed", "source_slice": "N1957", "godot_owner": OWNER,
            "godot_symbol": "source_building_cursor_result.generated_delegate", "java_source": SOURCE,
            "java_method": "getCursor()", "java_expr": "public Cursor getCursor(){",
            "tests": TESTS, "runtime_proof": PROOF,
            "rule": "Generated BuildingComp getCursor delegates to the existing canonical cursor owner; no duplicate cursor contract is created.",
        },
    })
    source_symbols.upsert_source_slice(GODOT, "N1957", {
        "status": "done", "java_source": SOURCE, "java_class": "mindustry.entities.comp.BuildingComp",
        "java_method": "getCursor()", "godot_owner": OWNER,
        "generated_owner": "BuildingComp.java_method_getCursor_165",
        "exact_exprs": ["public Cursor getCursor(){", "return block.configurable && interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;"],
        "source_symbols": ["building_cursor.generated_delegate"], "tests": TESTS, "runtime_proof": PROOF,
        "rule": "Generated getCursor delegates to the existing canonical source_building_cursor_state owner.",
    })
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
