from pathlib import Path

from mindustry_port import source_ssot, source_symbols

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_on_configure_build_tapped_state"
PROOF = "/root/Main.BuildingConfigureStateModuleProof"
TESTS = ["test_building_on_configure_build_tapped_generated_slice.py", "test_building_configure_entry_slice.py"]


def main() -> None:
    symbol = "building_on_configure_build_tapped.method"
    source_symbols.upsert_source_slice(GODOT, "N1953", {
        "status": "done", "java_source": SOURCE,
        "java_class": "mindustry.entities.comp.BuildingComp",
        "java_method": "onConfigureBuildTapped(Building other)",
        "godot_owner": OWNER,
        "generated_owner": "BuildingComp.java_method_onConfigureBuildTapped_166",
        "exact_exprs": ["public boolean onConfigureBuildTapped(Building other){", "block.clearOnDoubleTap", "self() == other", "deselect();", "configure(null);", "return false;", "return true;", "return self() != other;"],
        "source_symbols": [symbol], "tests": TESTS, "runtime_proof": PROOF,
        "rule": "Generated BuildingComp callback delegates to the existing canonical configure owner; no second source owner or contract is introduced.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "generated_building_comp_on_configure_build_tapped_bridge_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            key: {
                "type": type_name, "status": "generated", "java_source": SOURCE,
                "java_method": "onConfigureBuildTapped(Building other)",
                "java_expr": "public boolean onConfigureBuildTapped(Building other){",
                "rule": rule,
            }
            for key, type_name, rule in [
                ("source_owner", "String", "Existing canonical source owner."),
                ("generated_owner", "String", "Generated callback identity."),
                ("result", "Dictionary", "Actual generated result using the existing N604 result schema."),
                ("canonical", "Dictionary", "Canonical N604 state for comparison."),
                ("matches", "bool", "Strict full-result equality, rejecting null."),
            ]
        },
    })
    source_symbols.upsert_source_state_schema(GODOT, "building_configure_tap_branch_proof_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {"configure_tap_branches_match": {
            "type": "bool", "status": "generated", "java_source": SOURCE,
            "java_expr": "return self() != other;",
            "rule": "Checks all four input combinations against Java branch expectations.",
        }},
    })
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
