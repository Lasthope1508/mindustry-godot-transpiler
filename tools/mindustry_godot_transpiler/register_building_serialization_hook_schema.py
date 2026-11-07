from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
OWNER = "PortGame.source_building_serialization_hook_state"


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    entry = catalog["schemas"]["source_building_serialization_hook_result"]
    entry["keys"]["source_owner"] = {
        "type": "String",
        "status": "source-backed",
        "java_source": "core/src/mindustry/entities/comp/BuildingComp.java",
        "java_method": "BuildingComp.write(Writes write) / read(Reads read, byte revision)",
        "java_expr": "BuildingComp serialization hook owner",
        "rule": "Canonical owner marker for the shared BuildingComp serialization hook boundary.",
        "used_by": [OWNER.lower()],
    }
    source_symbols.upsert_source_state_schema(GODOT, "source_building_serialization_hook_result", entry)
    source_symbols.write_source_symbol_audit_report(GODOT)
    for name in ("comp_slices", "comp_api_contracts"):
        if name in source_ssot.registered_module_names(GODOT):
            source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == "__main__":
    main()
