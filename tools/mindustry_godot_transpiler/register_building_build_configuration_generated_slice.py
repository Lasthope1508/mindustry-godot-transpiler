from pathlib import Path
from mindustry_port import source_ssot, source_symbols

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/comp/BuildingComp.java"
OWNER = "PortGame.source_building_build_configuration_state"
PROOF = "/root/Main.BuildingConfigureStateModuleProof"
TESTS = ["test_building_build_configuration_generated_slice.py", "test_emitter.py"]


def main():
    source_symbols.upsert_source_symbols(GODOT, {
        "building_build_configuration.method": {
            "status": "source-backed", "source_slice": "N1955", "godot_owner": OWNER,
            "godot_symbol": "source_building_build_configuration_result.method", "java_source": SOURCE,
            "java_method": "buildConfiguration(Table)", "java_expr": "public void buildConfiguration(Table table){",
            "tests": TESTS, "runtime_proof": PROOF,
            "rule": "Exact empty base UI hook; concrete block overrides are outside this slice.",
        },
        "building_build_configuration.table": {
            "status": "source-backed", "source_slice": "N1955", "godot_owner": OWNER,
            "godot_symbol": "source_building_build_configuration_result.table", "java_source": SOURCE,
            "java_method": "buildConfiguration(Table)", "java_expr": "public void buildConfiguration(Table table){",
            "tests": TESTS, "runtime_proof": PROOF,
            "rule": "Table is preserved as the explicit Java hook input while the base body performs no UI mutation.",
        },
    })
    source_symbols.upsert_source_slice(GODOT, "N1955", {
        "status": "done", "java_source": SOURCE,
        "java_class": "mindustry.entities.comp.BuildingComp",
        "java_method": "buildConfiguration(Table)",
        "godot_owner": OWNER,
        "generated_owner": "BuildingComp.java_method_buildConfiguration_163",
        "exact_exprs": [
            "/** Called when this block is tapped to build a UI on the table.",
            "public void buildConfiguration(Table table){",
            "public void buildConfiguration(Table table){\\n    }",
        ],
        "source_symbols": ["building_build_configuration.method", "building_build_configuration.table"],
        "tests": TESTS, "runtime_proof": PROOF,
        "rule": "Generated BuildingComp buildConfiguration delegates to the canonical configure owner and preserves the upstream empty UI hook without inventing UI behavior.",
    })
    source_symbols.upsert_source_api_contract(GODOT, OWNER, {
        "status": "active", "source_slice": "N1955", "java_source": SOURCE,
        "source_method": "buildConfiguration(Table)",
        "params": [{"name": "table", "type": "Table", "schema": "source_building_build_configuration_input.table"}],
        "return_keys": ["source_owner", "method", "comment", "table", "no_op"],
        "tests": TESTS, "runtime_proof": PROOF,
        "rule": "Base BuildingComp hook preserves the Table input and exact empty Java body; concrete block UI overrides remain deferred.",
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_build_configuration_input", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {"table": {"type": "Variant", "status": "explicit-input", "java_source": SOURCE, "java_method": "buildConfiguration(Table)", "java_expr": "public void buildConfiguration(Table table){", "rule": "Exact Java Table parameter."}},
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_building_build_configuration_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "source_owner": {"type": "String", "status": "source-backed", "java_source": SOURCE, "java_method": "buildConfiguration(Table)", "java_expr": "public void buildConfiguration(Table table){", "rule": "Canonical owner marker."},
            "method": {"type": "String", "status": "source-backed", "java_source": SOURCE, "java_method": "buildConfiguration(Table)", "java_expr": "public void buildConfiguration(Table table){", "rule": "Exact Java method identity."},
            "comment": {"type": "String", "status": "source-backed", "java_source": SOURCE, "java_method": "buildConfiguration(Table)", "java_expr": "/** Called when this block is tapped to build a UI on the table.", "rule": "Exact upstream documentation boundary."},
            "table": {"type": "Variant", "status": "explicit-input", "java_source": SOURCE, "java_method": "buildConfiguration(Table)", "java_expr": "public void buildConfiguration(Table table){", "rule": "Preserved Table argument."},
            "no_op": {"type": "bool", "status": "source-backed", "java_source": SOURCE, "java_method": "buildConfiguration(Table)", "java_expr": "public void buildConfiguration(Table table){\\n    }", "rule": "Base method has an empty body."},
        },
    })
    source_symbols.upsert_source_state_schema(GODOT, "generated_building_comp_build_configuration_bridge_result", {
        "status": "active", "owner": OWNER, "runtime_proof": PROOF,
        "keys": {
            "source_owner": {"type": "String", "status": "generated", "java_source": SOURCE, "java_method": "buildConfiguration(Table)", "java_expr": "public void buildConfiguration(Table table){", "rule": "Canonical configure owner."},
            "generated_owner": {"type": "String", "status": "generated", "java_source": SOURCE, "java_method": "buildConfiguration(Table)", "java_expr": "public void buildConfiguration(Table table){", "rule": "Generated callback identity."},
            "result": {"type": "Dictionary", "status": "generated", "java_source": SOURCE, "java_method": "buildConfiguration(Table)", "java_expr": "public void buildConfiguration(Table table){\\n    }", "rule": "Canonical empty UI hook result."},
            "canonical": {"type": "Dictionary", "status": "generated", "java_source": SOURCE, "java_method": "buildConfiguration(Table)", "java_expr": "public void buildConfiguration(Table table){\\n    }", "rule": "Canonical configure state."},
            "matches": {"type": "bool", "status": "generated", "java_source": SOURCE, "java_method": "buildConfiguration(Table)", "java_expr": "public void buildConfiguration(Table table){\\n    }", "rule": "Generated and canonical hook states match."},
        },
    })
    for name in ("comp_slices", "comp_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
