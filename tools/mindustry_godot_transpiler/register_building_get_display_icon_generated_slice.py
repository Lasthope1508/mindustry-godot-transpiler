from pathlib import Path
from mindustry_port import source_ssot, source_symbols
ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_display_icon_state"
PROOF = "/root/Main.BuildingDisplayStateModuleProof"
TESTS = ["test_building_get_display_icon_generated_slice.py", "test_emitter.py"]

def main():
    source_symbols.upsert_source_slice(GODOT, "N1954", {
        "status": "done", "java_source": SOURCE,
        "java_class": "mindustry.entities.comp.BuildingComp",
        "java_method": "getDisplayIcon()",
        "godot_owner": OWNER,
        "generated_owner": "BuildingComp.java_method_getDisplayIcon_158",
        "exact_exprs": ["public TextureRegion getDisplayIcon(){", "return block.uiIcon;"],
        "source_symbols": ["building_display_icon.method"], "tests": TESTS, "runtime_proof": PROOF,
        "rule": "Generated BuildingComp getDisplayIcon delegates to the existing canonical display icon owner; no second public source contract is introduced.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "generated_building_comp_get_display_icon_bridge_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "source_owner": {"type": "String", "status": "generated", "java_source": SOURCE, "java_method": "getDisplayIcon()", "java_expr": "public TextureRegion getDisplayIcon(){", "rule": "Existing canonical source owner."},
            "generated_owner": {"type": "String", "status": "generated", "java_source": SOURCE, "java_method": "getDisplayIcon()", "java_expr": "public TextureRegion getDisplayIcon(){", "rule": "Generated callback identity."},
            "result": {"type": "Variant", "status": "generated", "java_source": SOURCE, "java_method": "getDisplayIcon()", "java_expr": "return block.uiIcon;", "rule": "Generated result delegates to block.uiIcon through the canonical display icon state."},
            "canonical": {"type": "Variant", "status": "generated", "java_source": SOURCE, "java_method": "getDisplayIcon()", "java_expr": "return block.uiIcon;", "rule": "Canonical display icon result."},
            "matches": {"type": "bool", "status": "generated", "java_source": SOURCE, "java_method": "getDisplayIcon()", "java_expr": "return block.uiIcon;", "rule": "Generated and canonical icon values match."},
        },
    })
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)

if __name__ == "__main__": main()

