"""Register shared result-envelope metadata from each canonical API contract."""

from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    contracts = source_symbols.load_source_api_contracts(GODOT)["contracts"]
    schemas = catalog["schemas"]
    added = 0
    for owner, contract in sorted(contracts.items()):
        if "generated_" in owner.lower():
            continue
        result_schema = source_symbols._contract_result_schema_name(owner, schemas, contract.get("return_keys", []))
        if not result_schema:
            continue
        keys = schemas[result_schema].setdefault("keys", {})
        return_keys = set(contract.get("return_keys", []))
        if "source_owner" in return_keys and "source_owner" not in keys:
            keys["source_owner"] = {
                "type": "String", "status": "generated", "java_expr": owner,
                "rule": "Canonical result owner envelope from the API contract.",
            }
            added += 1
        if "source" in return_keys and "source" not in keys:
            keys["source"] = {
                "type": "String", "status": "generated", "java_expr": contract.get("java_source", ""),
                "rule": "Canonical upstream source identity from the API contract.",
            }
            added += 1
        if "method" in return_keys and "method" not in keys:
            keys["method"] = {
                "type": "String", "status": "source-backed",
                "java_source": contract.get("java_source", ""),
                "java_method": contract.get("source_method", ""),
                "java_expr": contract.get("source_method", ""),
                "rule": "Canonical source method identity from the API contract.",
            }
            added += 1
    errors = source_symbols.validate_source_state_schema(catalog)
    if errors:
        raise ValueError("invalid result envelope metadata: " + "; ".join(errors))
    source_ssot.write_json(GODOT, "state_schema", catalog)
    for module in source_ssot.registered_modules(GODOT):
        if module.canonical_module == "state_schema":
            source_ssot.write_registered_json(GODOT, module.name, source_ssot.build_extension_shard(GODOT, module.name))
    source_symbols.write_source_symbol_audit_report(GODOT)
    print(f"registered_result_envelope_metadata={added}")


if __name__ == "__main__":
    main()
