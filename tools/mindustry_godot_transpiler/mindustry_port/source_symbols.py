"""Canonical source-symbol registry checks."""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any


from . import source_ssot


REGISTRY_RELATIVE_PATH = source_ssot.relative_path("registry")
AUDIT_REPORT_RELATIVE_PATH = source_ssot.relative_path("audit_report")
SLICE_LEDGER_RELATIVE_PATH = source_ssot.relative_path("slice_ledger")
API_CONTRACTS_RELATIVE_PATH = source_ssot.relative_path("api_contracts")
STATE_SCHEMA_RELATIVE_PATH = source_ssot.relative_path("state_schema")
ALLOWED_STATUSES = {"source-backed", "explicit-input", "deferred", "generated"}
REQUIRED_ENTRY_FIELDS = {"status", "godot_symbol", "godot_owner", "rule", "tests", "runtime_proof"}
SOURCE_REQUIRED_STATUSES = {"source-backed", "explicit-input"}
DEFAULT_EXEMPT_SOURCE_OWNERS = ["PortGame.source_symbol_registry_state", "PortGame.source_symbol_audit_state"]


def load_source_symbol_registry(godot_root: Path) -> dict[str, Any]:
    return source_ssot.load_json(godot_root, "registry")


def load_source_symbol_audit_report(godot_root: Path) -> dict[str, Any]:
    return source_ssot.load_json(godot_root, "audit_report")


def load_source_slice_ledger(godot_root: Path) -> dict[str, Any]:
    return source_ssot.load_json(godot_root, "slice_ledger")


def load_source_api_contracts(godot_root: Path) -> dict[str, Any]:
    return source_ssot.load_json(godot_root, "api_contracts")


def load_source_state_schema(godot_root: Path) -> dict[str, Any]:
    return source_ssot.load_json(godot_root, "state_schema")


def source_symbol(registry: dict[str, Any], symbol: str) -> dict[str, Any]:
    symbols = registry.get("symbols", {})
    if symbol not in symbols:
        raise KeyError(f"source symbol not registered: {symbol}")
    return symbols[symbol]


def source_slice(ledger: dict[str, Any], slice_id: str) -> dict[str, Any]:
    slices = ledger.get("slices", {})
    if slice_id not in slices:
        raise KeyError(f"source slice not registered: {slice_id}")
    return slices[slice_id]


def api_contract(contracts: dict[str, Any], owner: str) -> dict[str, Any]:
    contract_map = contracts.get("contracts", {})
    if owner not in contract_map:
        raise KeyError(f"source API contract not registered: {owner}")
    return contract_map[owner]


def state_schema(schema: dict[str, Any], schema_name: str) -> dict[str, Any]:
    schemas = schema.get("schemas", {})
    if schema_name not in schemas:
        raise KeyError(f"source state schema not registered: {schema_name}")
    return schemas[schema_name]


def symbols_for_owner(registry: dict[str, Any], godot_owner: str) -> dict[str, dict[str, Any]]:
    return {
        symbol: entry
        for symbol, entry in registry.get("symbols", {}).items()
        if entry.get("godot_owner") == godot_owner
    }


def discover_godot_source_functions(godot_root: Path) -> list[dict[str, Any]]:
    godot_root = Path(godot_root)
    discovered: list[dict[str, Any]] = []
    for path in sorted(godot_root.rglob("*.gd")):
        text = path.read_text(encoding="utf-8", errors="replace")
        class_name = path.stem
        class_match = re.search(r"^class_name\s+([A-Za-z_][A-Za-z0-9_]*)", text, re.MULTILINE)
        if class_match:
            class_name = class_match.group(1)
        for match in re.finditer(r"^func\s+(source_[A-Za-z0-9_]+)\s*\(", text, re.MULTILINE):
            function_name = match.group(1)
            discovered.append({
                "owner": f"{class_name}.{function_name}",
                "function": function_name,
                "gdscript_path": str(path.relative_to(godot_root)).replace("\\", "/"),
            })
    return discovered


def audit_godot_source_symbol_coverage(godot_root: Path, registry: dict[str, Any]) -> dict[str, Any]:
    discovered = discover_godot_source_functions(godot_root)
    discovered_owners = {entry["owner"] for entry in discovered}
    registered_owners = {
        entry.get("godot_owner", "")
        for entry in registry.get("symbols", {}).values()
        if entry.get("godot_owner", "") in discovered_owners
    }
    policy = registry.get("policy", {})
    exempt_owners = set(policy.get("exemptSourceOwners", DEFAULT_EXEMPT_SOURCE_OWNERS))
    exempt_discovered = sorted(discovered_owners & exempt_owners)
    legacy_unregistered = sorted(discovered_owners - registered_owners - set(exempt_discovered))
    return {
        "version": 1,
        "policy": {
            "newSourceOwnerRequiresRegistry": bool(policy.get("newSourceOwnerRequiresRegistry", True)),
            "legacyBackfillStatus": str(policy.get("legacyBackfillStatus", "tracked")),
        },
        "totalSourceFunctions": len(discovered),
        "registeredSourceOwnerCount": len(registered_owners),
        "exemptSourceOwnerCount": len(exempt_discovered),
        "legacyUnregisteredOwnerCount": len(legacy_unregistered),
        "registeredSourceOwners": sorted(registered_owners),
        "exemptSourceOwners": exempt_discovered,
        "legacyUnregisteredOwners": legacy_unregistered,
        "sourceFunctions": discovered,
    }


def write_source_symbol_audit_report(godot_root: Path) -> dict[str, Any]:
    godot_root = Path(godot_root)
    registry = load_source_symbol_registry(godot_root)
    audit = audit_godot_source_symbol_coverage(godot_root, registry)
    report_path = godot_root / AUDIT_REPORT_RELATIVE_PATH
    report_path.write_text(json.dumps(audit, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return audit


def validate_source_symbol_registry(registry: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if registry.get("version") != 1:
        errors.append("registry: version must be 1")
    policy = registry.get("policy", {})
    if not isinstance(policy, dict):
        errors.append("registry: policy must be an object")
    elif policy.get("newSourceOwnerRequiresRegistry") is not True:
        errors.append("registry: policy.newSourceOwnerRequiresRegistry must be true")
    symbols = registry.get("symbols")
    if not isinstance(symbols, dict) or not symbols:
        errors.append("registry: symbols must be a non-empty object")
        return errors

    for symbol, entry in sorted(symbols.items()):
        if not isinstance(entry, dict):
            errors.append(f"{symbol}: entry must be an object")
            continue
        for field in sorted(REQUIRED_ENTRY_FIELDS):
            if field not in entry:
                errors.append(f"{symbol}: requires {field}")
        status = entry.get("status")
        if status not in ALLOWED_STATUSES:
            errors.append(f"{symbol}: status must be one of {sorted(ALLOWED_STATUSES)}")
        if status in SOURCE_REQUIRED_STATUSES:
            for field in ("java_source", "java_method", "java_expr"):
                if not entry.get(field):
                    errors.append(f"{symbol}: {status} requires {field}")
        tests = entry.get("tests", [])
        if not isinstance(tests, list) or not tests:
            errors.append(f"{symbol}: tests must be a non-empty list")
    return errors


def validate_source_slice_ledger(ledger: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if ledger.get("version") != 1:
        errors.append("slice ledger: version must be 1")
    policy = ledger.get("policy", {})
    if not isinstance(policy, dict):
        errors.append("slice ledger: policy must be an object")
    elif policy.get("newSliceRequiresLedger") is not True:
        errors.append("slice ledger: policy.newSliceRequiresLedger must be true")
    slices = ledger.get("slices")
    if not isinstance(slices, dict) or not slices:
        errors.append("slice ledger: slices must be a non-empty object")
        return errors
    required_fields = {"status", "java_source", "java_class", "java_method", "godot_owner", "exact_exprs", "source_symbols", "tests", "runtime_proof"}
    for slice_id, entry in sorted(slices.items()):
        if not isinstance(entry, dict):
            errors.append(f"{slice_id}: slice entry must be an object")
            continue
        for field in sorted(required_fields):
            if field not in entry:
                errors.append(f"{slice_id}: requires {field}")
        for field in ("exact_exprs", "source_symbols", "tests"):
            value = entry.get(field, [])
            if not isinstance(value, list) or not value:
                errors.append(f"{slice_id}: {field} must be a non-empty list")
    return errors


def validate_source_api_contracts(contracts: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if contracts.get("version") != 1:
        errors.append("api contracts: version must be 1")
    policy = contracts.get("policy", {})
    if not isinstance(policy, dict):
        errors.append("api contracts: policy must be an object")
    elif policy.get("newSourceOwnerRequiresApiContract") is not True:
        errors.append("api contracts: policy.newSourceOwnerRequiresApiContract must be true")
    contract_map = contracts.get("contracts")
    if not isinstance(contract_map, dict) or not contract_map:
        errors.append("api contracts: contracts must be a non-empty object")
        return errors
    required_fields = {"status", "source_slice", "java_source", "source_method", "params", "return_keys", "tests", "runtime_proof", "rule"}
    for owner, entry in sorted(contract_map.items()):
        if not isinstance(entry, dict):
            errors.append(f"{owner}: contract entry must be an object")
            continue
        for field in sorted(required_fields):
            if field not in entry:
                errors.append(f"{owner}: requires {field}")
        params = entry.get("params", [])
        if not isinstance(params, list):
            errors.append(f"{owner}: params must be a list")
        else:
            for index, param in enumerate(params):
                if not isinstance(param, dict):
                    errors.append(f"{owner}.params[{index}]: param must be an object")
                    continue
                for field in ("name", "type", "schema"):
                    if not param.get(field):
                        errors.append(f"{owner}.params[{index}]: requires {field}")
        return_keys = entry.get("return_keys", [])
        if not isinstance(return_keys, list) or not return_keys:
            errors.append(f"{owner}: return_keys must be a non-empty list")
        tests = entry.get("tests", [])
        if not isinstance(tests, list) or not tests:
            errors.append(f"{owner}: tests must be a non-empty list")
    return errors


def validate_source_state_schema(schema: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if schema.get("version") != 1:
        errors.append("state schema: version must be 1")
    policy = schema.get("policy", {})
    if not isinstance(policy, dict):
        errors.append("state schema: policy must be an object")
    elif policy.get("newDictionaryKeyRequiresSchema") is not True:
        errors.append("state schema: policy.newDictionaryKeyRequiresSchema must be true")
    schemas = schema.get("schemas")
    if not isinstance(schemas, dict) or not schemas:
        errors.append("state schema: schemas must be a non-empty object")
        return errors
    for schema_name, schema_entry in sorted(schemas.items()):
        if not isinstance(schema_entry, dict):
            errors.append(f"{schema_name}: schema entry must be an object")
            continue
        keys = schema_entry.get("keys")
        if not isinstance(keys, dict) or not keys:
            errors.append(f"{schema_name}: keys must be a non-empty object")
            continue
        for key_name, key_entry in sorted(keys.items()):
            if not isinstance(key_entry, dict):
                errors.append(f"{schema_name}.{key_name}: key entry must be an object")
                continue
            for field in ("type", "status"):
                if not key_entry.get(field):
                    errors.append(f"{schema_name}.{key_name}: requires {field}")
            status = key_entry.get("status")
            has_alias = bool(key_entry.get("alias_of"))
            if status in SOURCE_REQUIRED_STATUSES and not has_alias:
                for field in ("java_source", "java_expr"):
                    if not key_entry.get(field):
                        errors.append(f"{schema_name}.{key_name}: {status} requires {field}")
            if status == "generated" and not has_alias and not key_entry.get("java_expr"):
                errors.append(f"{schema_name}.{key_name}: generated requires alias_of or java_expr")
    return errors
