"""Register UnitType result-envelope keys proven by canonical state modules."""

from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/type/UnitType.java"


def source_key(method: str, expression: str, type_name: str = "String") -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
        "rule": "Canonical UnitType source envelope key.",
    }


def generated_key(expression: str, type_name: str = "String") -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "java_expr": expression,
        "rule": "Canonical generated bridge envelope key.",
    }


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    schemas = catalog["schemas"]

    core = {
        "source_unit_type_create_controller_result": {
            "source_owner": generated_key("PortGame.source_unit_type_create_controller_state"),
            "source": generated_key(SOURCE),
            "generated_owner": generated_key("UnitType.java_method_createController_1"),
            "generated_method": generated_key("java_method_createController_1"),
        },
        "source_unit_type_has_weapons_result": {
            "source_owner": generated_key("PortGame.source_unit_type_has_weapons_state"),
            "source": generated_key(SOURCE),
            "generated_owner": generated_key("UnitType.java_method_hasWeapons_10"),
            "generated_method": generated_key("java_method_hasWeapons_10"),
        },
    }
    hooks = {
        "source_unit_type_update_result": ("UnitType.update(Unit)", "public void update(Unit unit){"),
        "source_unit_type_update_payload_result": ("UnitType.updatePayload(Unit,Unit,Building)", "public void updatePayload(Unit unit, @Nullable Unit unitHolder, @Nullable Building buildingHolder){"),
        "source_unit_type_killed_result": ("UnitType.killed(Unit)", "public void killed(Unit unit){}"),
        "source_unit_type_landed_result": ("UnitType.landed(Unit)", "public void landed(Unit unit){}"),
    }

    for schema_name, keys in core.items():
        schemas[schema_name]["keys"].update(keys)
    for schema_name, (method, expression) in hooks.items():
        owner = "PortGame." + schema_name.removesuffix("_result")
        schemas[schema_name]["keys"].update({
            "source_owner": generated_key(owner),
            "source": generated_key(SOURCE),
            "method": source_key(method, expression),
        })

    errors = source_symbols.validate_source_state_schema(catalog)
    if errors:
        raise ValueError("invalid UnitType result schemas: " + "; ".join(errors))
    source_ssot.write_json(GODOT, "state_schema", catalog)
    for module in source_ssot.registered_modules(GODOT):
        if module.canonical_module == "state_schema":
            source_ssot.write_registered_json(GODOT, module.name, source_ssot.build_extension_shard(GODOT, module.name))
    source_symbols.write_source_symbol_audit_report(GODOT)
    print("registered_unit_type_result_envelopes=6")


if __name__ == "__main__":
    main()
