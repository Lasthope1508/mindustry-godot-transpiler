from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/type/UnitType.java"
PROOF = "/root/Main.UnitTypeCoreModuleProof"
TESTS = ["test_unit_type_hooks_slice"]


def schema_key(type_name: str, method: str, expression: str, rule: str) -> dict:
    return {"type": type_name, "status": "source-backed", "java_source": SOURCE, "java_method": method, "java_expr": expression, "rule": rule}


def symbol(owner: str, name: str, godot_symbol: str, method: str, expression: str, rule: str) -> tuple[str, dict]:
    return name, {
        "status": "source-backed",
        "godot_owner": owner,
        "godot_symbol": godot_symbol,
        "rule": rule,
        "tests": TESTS,
        "runtime_proof": PROOF,
        "java_source": SOURCE,
        "java_method": method,
        "java_expr": expression,
    }


def main() -> None:
    entries = {}
    hooks = [
        ("N1879", "update", "UnitType.update(Unit)", "PortGame.source_unit_type_update_state", "public void update(Unit unit){", "UnitType.java_method_update_17", "source_unit_type_update_result"),
        ("N1880", "updatePayload", "UnitType.updatePayload(Unit,Unit,Building)", "PortGame.source_unit_type_update_payload_state", "public void updatePayload(Unit unit, @Nullable Unit unitHolder, @Nullable Building buildingHolder){", "UnitType.java_method_updatePayload_18", "source_unit_type_update_payload_result"),
        ("N1881", "killed", "UnitType.killed(Unit)", "PortGame.source_unit_type_killed_state", "public void killed(Unit unit){}", "UnitType.java_method_killed_19", "source_unit_type_killed_result"),
        ("N1882", "landed", "UnitType.landed(Unit)", "PortGame.source_unit_type_landed_state", "public void landed(Unit unit){}", "UnitType.java_method_landed_20", "source_unit_type_landed_result"),
    ]
    for slice_id, method_name, source_method, owner, method_expr, generated_method, result_schema in hooks:
        expressions = [method_expr]
        entries.update(dict([
            symbol(owner, f"unit_type_{method_name}.method", f"{result_schema}.method", source_method, method_expr, "Method boundary."),
            symbol(owner, f"unit_type_{method_name}.no_op", f"{result_schema}.no_op", source_method, method_expr, "Canonical source method is intentionally empty."),
        ]))
        source_symbols.upsert_source_slice(GODOT, slice_id, {
            "status": "done", "java_source": SOURCE, "java_class": "mindustry.type.UnitType",
            "java_method": source_method, "godot_owner": owner, "exact_exprs": expressions,
            "source_symbols": [f"unit_type_{method_name}.method", f"unit_type_{method_name}.no_op"],
            "tests": TESTS, "runtime_proof": PROOF,
        })
        params = [{"name": "unit", "type": "Variant", "schema": f"{result_schema}_input.unit"}]
        if method_name == "updatePayload":
            params.extend([
                {"name": "unit_holder", "type": "Variant", "schema": f"{result_schema}_input.unit_holder"},
                {"name": "building_holder", "type": "Variant", "schema": f"{result_schema}_input.building_holder"},
            ])
        source_symbols.upsert_source_api_contract(GODOT, owner, {
            "status": "active", "source_slice": slice_id, "java_source": SOURCE,
            "source_method": source_method, "params": params,
            "return_keys": ["source_owner", "source", "method", "no_op", "body"],
            "tests": TESTS, "runtime_proof": PROOF,
            "rule": f"Canonical source-backed no-op contract for {source_method}; no behavior is invented.",
        })
        input_keys = {param["name"]: schema_key(param["type"], source_method, param["name"], "Explicit hook input.") for param in params}
        result_keys = {
            "no_op": schema_key("bool", source_method, method_expr, "Canonical no-op result."),
            "body": schema_key("String", source_method, method_expr, "Source-backed explanation."),
        }
        source_symbols.upsert_source_state_schema(GODOT, f"{result_schema}_input", {"status": "active", "owner": owner, "runtime_proof": PROOF, "keys": input_keys})
        source_symbols.upsert_source_state_schema(GODOT, result_schema, {"status": "active", "owner": owner, "runtime_proof": PROOF, "keys": result_keys})
    source_symbols.upsert_source_symbols(GODOT, entries)
    for name in ("type_slices", "type_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
