"""Canonical source-symbol registry checks."""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any


from . import source_ssot


REGISTRY_MODULE = source_ssot.module("registry")
AUDIT_REPORT_MODULE = source_ssot.module("audit_report")
SLICE_LEDGER_MODULE = source_ssot.module("slice_ledger")
API_CONTRACTS_MODULE = source_ssot.module("api_contracts")
STATE_SCHEMA_MODULE = source_ssot.module("state_schema")
REGISTRY_RELATIVE_PATH = REGISTRY_MODULE.relative_path
AUDIT_REPORT_RELATIVE_PATH = AUDIT_REPORT_MODULE.relative_path
SLICE_LEDGER_RELATIVE_PATH = SLICE_LEDGER_MODULE.relative_path
API_CONTRACTS_RELATIVE_PATH = API_CONTRACTS_MODULE.relative_path
STATE_SCHEMA_RELATIVE_PATH = STATE_SCHEMA_MODULE.relative_path
ALLOWED_STATUSES = {"source-backed", "explicit-input", "deferred", "generated"}
REQUIRED_ENTRY_FIELDS = {"status", "godot_symbol", "godot_owner", "rule", "tests", "runtime_proof"}
SOURCE_REQUIRED_STATUSES = {"source-backed", "explicit-input"}
DEFAULT_EXEMPT_SOURCE_OWNERS = ["port_game.source_symbol_registry_state", "port_game.source_symbol_audit_state"]
CANONICAL_OWNER_ALIASES_POLICY_KEY = "canonicalOwnerAliases"

def _canonical_godot_owner(owner: str) -> str:
    if owner.startswith("PortGame."):
        return "port_game." + owner[len("PortGame."):]
    return owner


def _canonical_owner_aliases(registry: dict[str, Any]) -> dict[str, str]:
    policy = registry.get("policy", {})
    aliases = policy.get(CANONICAL_OWNER_ALIASES_POLICY_KEY, {}) if isinstance(policy, dict) else {}
    if not isinstance(aliases, dict):
        return {}
    return {
        _canonical_godot_owner(str(alias)): _canonical_godot_owner(str(target))
        for alias, target in aliases.items()
    }


def _resolve_canonical_owner(owner: str, aliases: dict[str, str]) -> str:
    current = _canonical_godot_owner(owner)
    seen: set[str] = set()
    while current in aliases:
        if current in seen:
            raise ValueError(f"canonical owner alias cycle: {current}")
        seen.add(current)
        current = aliases[current]
    return current


def _canonical_owner_alias_errors(registry: dict[str, Any]) -> list[str]:
    policy = registry.get("policy", {})
    aliases_value = policy.get(CANONICAL_OWNER_ALIASES_POLICY_KEY, {}) if isinstance(policy, dict) else {}
    if not isinstance(aliases_value, dict):
        return [f"registry: policy.{CANONICAL_OWNER_ALIASES_POLICY_KEY} must be an object"]
    symbols = registry.get("symbols", {})
    registered_owners = {
        _canonical_godot_owner(str(entry.get("godot_owner", "")))
        for entry in symbols.values()
        if isinstance(entry, dict) and entry.get("godot_owner")
    } if isinstance(symbols, dict) else set()
    aliases = _canonical_owner_aliases(registry)
    errors: list[str] = []
    for alias, target in sorted(aliases.items()):
        if not alias or not target:
            errors.append(f"registry: canonical owner alias {alias!r} must have non-empty names")
        elif alias == target:
            errors.append(f"registry: canonical owner alias {alias} cannot target itself")
        elif target not in registered_owners:
            errors.append(f"registry: canonical owner alias {alias} targets unregistered owner {target}")
        elif target in aliases:
            errors.append(f"registry: canonical owner alias {alias} creates an alias chain through {target}")
    return errors

def _normalize_registry_owner_entries(registry: dict[str, Any]) -> dict[str, Any]:
    normalized = dict(registry)
    symbols = normalized.get("symbols", {})
    if isinstance(symbols, dict):
        normalized["symbols"] = {
            symbol: {
                **entry,
                "godot_owner": _canonical_godot_owner(str(entry.get("godot_owner", ""))),
            } if isinstance(entry, dict) else entry
            for symbol, entry in symbols.items()
        }
    return normalized


def load_source_symbol_registry(godot_root: Path) -> dict[str, Any]:
    return source_ssot.load_json(godot_root, "registry")


def load_source_symbol_audit_report(godot_root: Path) -> dict[str, Any]:
    return _normalize_audit_report_entries(source_ssot.load_json(godot_root, "audit_report"))

def _normalize_audit_report_entries(audit: dict[str, Any]) -> dict[str, Any]:
    normalized = dict(audit)
    normalized["registeredSourceOwners"] = [_canonical_godot_owner(str(owner)) for owner in audit.get("registeredSourceOwners", [])]
    normalized["exemptSourceOwners"] = [_canonical_godot_owner(str(owner)) for owner in audit.get("exemptSourceOwners", [])]
    normalized["legacyUnregisteredOwners"] = [_canonical_godot_owner(str(owner)) for owner in audit.get("legacyUnregisteredOwners", [])]
    normalized["sourceFunctions"] = [
        {
            **entry,
            "owner": _canonical_godot_owner(str(entry.get("owner", ""))),
            **({"canonical_owner": _canonical_godot_owner(str(entry.get("canonical_owner", "")))} if entry.get("canonical_owner") else {}),
        } if isinstance(entry, dict) else entry
        for entry in audit.get("sourceFunctions", [])
    ]
    return normalized


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


def _catalog_owner_tokens(owner: Any) -> list[str]:
    """Expand a cluster owner declaration without changing its canonical text."""
    return [
        _canonical_godot_owner(token.strip())
        for token in str(owner or "").split(";")
        if token.strip()
    ]


def _godot_function_return_type(text: str, opening_parenthesis: int) -> str:
    """Read an explicit annotation after balanced parameters, not from the body."""
    depth = 0
    quote = ""
    index = opening_parenthesis
    while index < len(text):
        character = text[index]
        if quote:
            if character == "\\":
                index += 2
                continue
            if text.startswith(quote, index):
                index += len(quote)
                quote = ""
                continue
        elif character in ("'", '"'):
            quote = character * 3 if text.startswith(character * 3, index) else character
            index += len(quote)
            continue
        elif character == "#":
            newline = text.find("\n", index)
            if newline < 0:
                return ""
            index = newline + 1
            continue
        elif character == "(":
            depth += 1
        elif character == ")":
            depth -= 1
            if depth == 0:
                annotation = re.match(r"\s*->\s*([A-Za-z_][A-Za-z0-9_]*)\s*:", text[index + 1:])
                return annotation.group(1) if annotation else ""
        index += 1
    return ""


def _discover_godot_owner_functions(godot_root: Path, *, return_types: dict[str, str] | None = None) -> set[str]:
    """Discover callable owners across source modules and PortGame bridge files."""
    owners: set[str] = set()
    root = Path(godot_root)
    for path in sorted(root.rglob("*.gd")):
        if path.relative_to(root).parts[:2] == ("tools", "runtime_proofs"):
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        class_name = path.stem
        class_match = re.search(r"^class_name\s+([A-Za-z_][A-Za-z0-9_]*)", text, re.MULTILINE)
        if class_match:
            class_name = class_match.group(1)
        is_port_bridge = path.name.endswith("PortBridge.gd")
        if is_port_bridge or class_name == "PortGame":
            class_name = "port_game"
        for match in re.finditer(r"^(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", text, re.MULTILINE):
            function_name = match.group(1)
            if is_port_bridge:
                if function_name.startswith(("source_", "generated_")):
                    owners.add(f"{class_name}.{function_name}")
            elif function_name.startswith(("source_", "generated_", "tile_")):
                owners.add(f"{class_name}.{function_name}")
            if return_types is not None and f"{class_name}.{function_name}" in owners:
                return_types[f"{class_name}.{function_name}"] = _godot_function_return_type(text, match.end() - 1)
    return owners


def _resolve_contract_schema_reference(
    owner: str,
    reference: Any,
    schemas: dict[str, Any],
    parameter_name: str = "",
) -> tuple[str, str] | None:
    """Resolve direct and owner-prefixed schema references used by contracts."""
    value = str(reference or "")
    if value in schemas:
        return value, ""
    base, separator, key = value.partition(".")
    if separator and base in schemas and key in schemas[base].get("keys", {}):
        return base, key
    if separator and base.endswith("_input"):
        state_base = f"{base[:-len('_input')]}_state_input"
        if state_base in schemas:
            state_keys = schemas[state_base].get("keys", {})
            if key in state_keys:
                return state_base, key
            if parameter_name and parameter_name in state_keys:
                return state_base, parameter_name
    return None


def _contract_result_schema_name(
    owner: str,
    schemas: dict[str, Any],
    return_keys: list[Any] | None = None,
) -> str | None:
    function_name = owner.rsplit(".", 1)[-1]
    candidates = []
    if function_name.endswith("_state"):
        base = function_name[: -len("_state")]
        candidates.extend((f"{base}_result", f"{base}_state_result"))
    candidates.append(f"{function_name}_result")
    for prefix in (
        "source_bullet_type_",
        "source_power_graph_",
        "source_building_",
        "source_overdrive_projector_",
    ):
        if function_name.startswith(prefix):
            base = function_name[len(prefix) :]
            if base.endswith("_state"):
                base = base[: -len("_state")]
            candidates.append(f"{base}_result")

    requested_keys = {str(key) for key in (return_keys or [])}
    for candidate in dict.fromkeys(candidates):
        schema = schemas.get(candidate)
        if not isinstance(schema, dict):
            continue
        return candidate

    # Some legacy contracts omit the canonical schema name. Accept only a
    # unique schema whose keys and explicit used_by metadata both identify it.
    if requested_keys:
        owner_key = _canonical_godot_owner(owner).lower()
        matches = []
        for name, schema in schemas.items():
            if not name.endswith("_result"):
                continue
            if not isinstance(schema, dict):
                continue
            schema_keys = schema.get("keys", {})
            used_by = {
                str(used).lower()
                for key in requested_keys
                for used in schema_keys.get(key, {}).get("used_by", [])
            }
            if owner_key in used_by and any(key in schema_keys for key in requested_keys):
                matches.append(name)
        if len(matches) == 1:
            return matches[0]
    return None


def validate_source_catalog(godot_root: Path) -> dict[str, Any]:
    """Validate linkage across the canonical registry, ledgers, contracts, and schemas."""
    godot_root = Path(godot_root)
    registry = load_source_symbol_registry(godot_root)
    ledger = load_source_slice_ledger(godot_root)
    contracts = load_source_api_contracts(godot_root)
    schema_catalog = load_source_state_schema(godot_root)
    symbols = registry.get("symbols", {})
    slices = ledger.get("slices", {})
    contract_map = contracts.get("contracts", {})
    schemas = schema_catalog.get("schemas", {})
    aliases = _canonical_owner_aliases(registry)
    registered_owners = {
        _resolve_canonical_owner(str(entry.get("godot_owner", "")), aliases)
        for entry in symbols.values()
        if isinstance(entry, dict) and entry.get("godot_owner")
    }
    return_types: dict[str, str] = {}
    discovered_owners = {
        _resolve_canonical_owner(owner, aliases)
        for owner in _discover_godot_owner_functions(godot_root, return_types=return_types)
    }
    categories: dict[str, list[str]] = {
        "owner_registration": [],
        "slice_symbol_linkage": [],
        "contract_slice_linkage": [],
        "contract_schema_linkage": [],
        "return_schema_linkage": [],
        "implementation_linkage": [],
        "proof_test_metadata": [],
        "duplicate_canonical_ownership": [],
        "alias_graph": [],
    }
    return_schema_diagnostics: dict[str, list[str]] = {
        "missing_result_schema_contracts": [],
        "unknown_return_keys": [],
    }

    def add(category: str, message: str) -> None:
        categories[category].append(message)

    for alias in aliases:
        try:
            _resolve_canonical_owner(alias, aliases)
        except ValueError as exc:
            add("alias_graph", str(exc))
    for error in _canonical_owner_alias_errors(registry):
        add("alias_graph", error)

    for slice_id, entry in sorted(slices.items()):
        if not isinstance(entry, dict):
            continue
        for symbol in entry.get("source_symbols", []):
            if symbol not in symbols:
                add("slice_symbol_linkage", f"slice {slice_id}: symbol not registered: {symbol}")
        if not entry.get("tests") or not entry.get("runtime_proof"):
            add("proof_test_metadata", f"slice {slice_id}: tests and runtime_proof are required")

    for owner, entry in sorted(contract_map.items()):
        canonical_owner = _canonical_godot_owner(owner)
        if _resolve_canonical_owner(canonical_owner, aliases) not in registered_owners:
            add("owner_registration", f"contract {owner}: owner not registered")
        source_slice = entry.get("source_slice") if isinstance(entry, dict) else None
        if source_slice not in slices:
            add("contract_slice_linkage", f"contract {owner}: slice not registered: {source_slice}")
        if not isinstance(entry, dict):
            continue
        if not entry.get("tests") or not entry.get("runtime_proof"):
            add("proof_test_metadata", f"contract {owner}: tests and runtime_proof are required")
        for index, param in enumerate(entry.get("params", [])):
            reference = param.get("schema") if isinstance(param, dict) else ""
            parameter_name = str(param.get("name", "")) if isinstance(param, dict) else ""
            if _resolve_contract_schema_reference(canonical_owner, reference, schemas, parameter_name) is None:
                add("contract_schema_linkage", f"contract {owner}: param {index} schema not linked: {reference}")
        declared_void = entry.get("return_type") == "void"
        if declared_void:
            if entry.get("return_keys") != []:
                add("return_schema_linkage", f"contract {owner}: void return requires empty return_keys")
            if return_types.get(canonical_owner) != "void":
                add("implementation_linkage", f"contract {owner}: void return requires an explicit -> void implementation")
        elif "generated_" not in canonical_owner:
            result_schema = _contract_result_schema_name(canonical_owner, schemas, entry.get("return_keys", []))
            if result_schema is None:
                return_schema_diagnostics["missing_result_schema_contracts"].append(owner)
                add("return_schema_linkage", f"contract {owner}: result schema not registered")
            else:
                result_keys = schemas[result_schema].get("keys", {})
                for key in entry.get("return_keys", []):
                    if key not in result_keys:
                        return_schema_diagnostics["unknown_return_keys"].append(f"{owner}:{key}")
                        add("return_schema_linkage", f"contract {owner}: return key not in {result_schema}: {key}")

        if canonical_owner not in discovered_owners:
            add("implementation_linkage", f"contract {owner}: facade/module function not discovered")

    for symbol, entry in sorted(symbols.items()):
        if not isinstance(entry, dict):
            continue
        if not entry.get("tests") or not entry.get("runtime_proof"):
            add("proof_test_metadata", f"symbol {symbol}: tests and runtime_proof are required")

    canonical_symbol_records: dict[tuple[str, str], list[str]] = {}
    for symbol, entry in symbols.items():
        if not isinstance(entry, dict):
            continue
        owner = _resolve_canonical_owner(str(entry.get("godot_owner", "")), aliases)
        identity = (owner, str(entry.get("godot_symbol", "")))
        canonical_symbol_records.setdefault(identity, []).append(str(entry.get("source_slice", "")))
    for (owner, godot_symbol), source_slices in sorted(canonical_symbol_records.items()):
        if len(source_slices) > 1 and len(set(source_slices)) > 1:
            add(
                "duplicate_canonical_ownership",
                f"owner {owner}: canonical symbol duplicated across source slices: {godot_symbol}",
            )

    for slice_id, entry in sorted(slices.items()):
        if not isinstance(entry, dict):
            continue
        source_symbols = entry.get("source_symbols", [])
        if len(source_symbols) != len(set(source_symbols)):
            add("duplicate_canonical_ownership", f"slice {slice_id}: duplicate source symbol identity")

    json_report = source_ssot.validate_json_modules(godot_root)
    errors = [f"{category}: {message}" for category, messages in categories.items() for message in messages]
    errors.extend(f"json_modules: {message}" for message in json_report.get("errors", []))
    return {
        "errors": errors,
        "categories": categories,
        "counts": {category: len(messages) for category, messages in categories.items()},
        "return_schema_diagnostics": return_schema_diagnostics,
        "json_module_count": json_report.get("module_count", 0),
        "json_errors": list(json_report.get("errors", [])),
    }


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
        relative_path = path.relative_to(godot_root)
        if relative_path.parts[:2] == ("tools", "runtime_proofs"):
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        class_name = path.stem
        class_match = re.search(r"^class_name\s+([A-Za-z_][A-Za-z0-9_]*)", text, re.MULTILINE)
        if class_match:
            class_name = class_match.group(1)
        if path.name.endswith("PortBridge.gd"):
            class_name = "PortGame"
        for match in re.finditer(r"^func\s+(source_[A-Za-z0-9_]+)\s*\(", text, re.MULTILINE):
            function_name = match.group(1)
            discovered.append({
                "owner": _canonical_godot_owner(f"{class_name}.{function_name}"),
                "function": function_name,
                "gdscript_path": str(relative_path).replace("\\", "/"),
            })
    return discovered


def audit_godot_source_symbol_coverage(godot_root: Path, registry: dict[str, Any]) -> dict[str, Any]:
    discovered = discover_godot_source_functions(godot_root)
    registry = _normalize_registry_owner_entries(registry)
    owner_aliases = _canonical_owner_aliases(registry)
    discovered = [
        {**entry, "canonical_owner": _resolve_canonical_owner(entry["owner"], owner_aliases)}
        for entry in discovered
    ]
    discovered_owners = {entry["owner"] for entry in discovered}
    canonical_discovered_owners = {entry["canonical_owner"] for entry in discovered}
    registered_owners = {
        entry.get("godot_owner", "")
        for entry in registry.get("symbols", {}).values()
        if entry.get("godot_owner", "") in canonical_discovered_owners
    }
    policy = registry.get("policy", {})
    exempt_owners = {
        _canonical_godot_owner(str(owner))
        for owner in policy.get("exemptSourceOwners", DEFAULT_EXEMPT_SOURCE_OWNERS)
    }
    canonical_owner_by_discovered_owner = {
        entry["owner"]: entry["canonical_owner"]
        for entry in discovered
    }
    exempt_discovered = sorted(
        owner for owner, canonical_owner in canonical_owner_by_discovered_owner.items()
        if canonical_owner in exempt_owners
    )
    legacy_unregistered = sorted(
        owner for owner, canonical_owner in canonical_owner_by_discovered_owner.items()
        if canonical_owner not in registered_owners and owner not in exempt_discovered
    )
    canonical_alias_entries = [
        entry for entry in discovered if entry["owner"] != entry["canonical_owner"]
    ]
    duplicate_source_function_record_count = len(discovered) - len(discovered_owners)
    canonical_alias_owner_count = len({entry["canonical_owner"] for entry in canonical_alias_entries})
    canonical_alias_collapse_count = len(canonical_alias_entries) - canonical_alias_owner_count
    function_record_accounting_gap = (
        len(discovered)
        - len(registered_owners)
        - len(exempt_discovered)
        - len(legacy_unregistered)
    )
    owner_coverage_gap = (
        len(canonical_discovered_owners)
        - len(registered_owners)
        - len(exempt_discovered)
        - len(legacy_unregistered)
    )
    return {
        "version": 1,
        "policy": {
            "newSourceOwnerRequiresRegistry": bool(policy.get("newSourceOwnerRequiresRegistry", True)),
            "legacyBackfillStatus": str(policy.get("legacyBackfillStatus", "tracked")),
            CANONICAL_OWNER_ALIASES_POLICY_KEY: owner_aliases,
        },
        "totalSourceFunctions": len(discovered),
        "discoveredSourceOwnerCount": len(discovered_owners),
        "canonicalDiscoveredOwnerCount": len(canonical_discovered_owners),
        "registeredSourceOwnerCount": len(registered_owners),
        "exemptSourceOwnerCount": len(exempt_discovered),
        "legacyUnregisteredOwnerCount": len(legacy_unregistered),
        "canonicalAliasFunctionCount": len(canonical_alias_entries),
        "canonicalAliasOwnerCount": canonical_alias_owner_count,
        "canonicalAliasCollapseCount": canonical_alias_collapse_count,
        "duplicateSourceFunctionRecordCount": duplicate_source_function_record_count,
        "ownerCoverageGap": owner_coverage_gap,
        "functionRecordAccountingGap": function_record_accounting_gap,
        "registeredSourceOwners": sorted(registered_owners),
        "exemptSourceOwners": exempt_discovered,
        "legacyUnregisteredOwners": legacy_unregistered,
        "sourceFunctions": discovered,
    }


def write_source_symbol_audit_report(godot_root: Path) -> dict[str, Any]:
    godot_root = Path(godot_root)
    registry = load_source_symbol_registry(godot_root)
    audit = audit_godot_source_symbol_coverage(godot_root, registry)
    source_ssot.write_json(godot_root, "audit_report", audit)
    return audit


def upsert_source_symbols(godot_root: Path, entries: dict[str, dict[str, Any]]) -> dict[str, dict[str, Any]]:
    """Register source symbols through the canonical registry validation gate."""
    godot_root = Path(godot_root)
    registry = load_source_symbol_registry(godot_root)
    symbols = registry.get("symbols")
    if not isinstance(symbols, dict):
        raise ValueError("source symbol registry must contain a symbols object")
    symbols.update(entries)
    errors = validate_source_symbol_registry(registry)
    if errors:
        raise ValueError("invalid source symbol registry: " + "; ".join(errors))
    source_ssot.write_json(godot_root, "registry", registry)
    return entries


def upsert_source_slice(godot_root: Path, slice_id: str, entry: dict[str, Any]) -> dict[str, Any]:
    """Register or replace one canonical source slice after validating the ledger."""
    godot_root = Path(godot_root)
    ledger = load_source_slice_ledger(godot_root)
    slices = ledger.get("slices")
    if not isinstance(slices, dict):
        raise ValueError("source slice ledger must contain a slices object")
    slices[slice_id] = entry
    errors = validate_source_slice_ledger(ledger)
    if errors:
        raise ValueError("invalid source slice ledger: " + "; ".join(errors))
    source_ssot.write_json(godot_root, "slice_ledger", ledger)
    return entry


def upsert_source_api_contract(godot_root: Path, owner: str, contract: dict[str, Any]) -> dict[str, Any]:
    """Register one canonical source API contract after validating the full catalog."""
    godot_root = Path(godot_root)
    contracts = load_source_api_contracts(godot_root)
    contract_map = contracts.get("contracts")
    if not isinstance(contract_map, dict):
        raise ValueError("source API contracts must contain a contracts object")
    contract_map[owner] = contract
    errors = validate_source_api_contracts(contracts)
    if errors:
        raise ValueError("invalid source API contract catalog: " + "; ".join(errors))
    source_ssot.write_json(godot_root, "api_contracts", contracts)
    return contract


def upsert_source_state_schema(godot_root: Path, schema_name: str, entry: dict[str, Any]) -> dict[str, Any]:
    """Register or replace one canonical state schema after validating the catalog."""
    godot_root = Path(godot_root)
    schema = load_source_state_schema(godot_root)
    schemas = schema.get("schemas")
    if not isinstance(schemas, dict):
        raise ValueError("source state schema must contain a schemas object")
    schemas[schema_name] = entry
    errors = validate_source_state_schema(schema)
    if errors:
        raise ValueError("invalid source state schema: " + "; ".join(errors))
    source_ssot.write_json(godot_root, "state_schema", schema)
    return entry


def rename_source_state_schema(godot_root: Path, schema_name: str, new_schema_name: str) -> dict[str, Any]:
    """Rename one canonical state schema without bypassing catalog validation."""
    godot_root = Path(godot_root)
    schema = load_source_state_schema(godot_root)
    schemas = schema.get("schemas")
    if not isinstance(schemas, dict) or schema_name not in schemas:
        raise KeyError(f"source state schema not registered: {schema_name}")
    if new_schema_name in schemas:
        raise KeyError(f"source state schema already registered: {new_schema_name}")
    entry = schemas.pop(schema_name)
    schemas[new_schema_name] = entry
    errors = validate_source_state_schema(schema)
    if errors:
        raise ValueError("invalid source state schema: " + "; ".join(errors))
    source_ssot.write_json(godot_root, "state_schema", schema)
    return entry


def update_source_slice(godot_root: Path, slice_id: str, update: dict[str, Any]) -> dict[str, Any]:
    """Update one canonical source slice after validating the complete ledger."""
    godot_root = Path(godot_root)
    ledger = load_source_slice_ledger(godot_root)
    slices = ledger.get("slices")
    if not isinstance(slices, dict) or slice_id not in slices or not isinstance(slices[slice_id], dict):
        raise KeyError(f"source slice not registered: {slice_id}")
    slices[slice_id] = {**slices[slice_id], **update}
    errors = validate_source_slice_ledger(ledger)
    if errors:
        raise ValueError("invalid source slice ledger: " + "; ".join(errors))
    source_ssot.write_json(godot_root, "slice_ledger", ledger)
    return slices[slice_id]


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

    errors.extend(_canonical_owner_alias_errors(registry))

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
        return_type = entry.get("return_type", "Dictionary")
        if return_type not in ("Dictionary", "void"):
            errors.append(f"{owner}: return_type must be Dictionary or void")
        if return_type == "void" and return_keys != []:
            errors.append(f"{owner}: void return requires empty return_keys")
        elif return_type != "void" and (not isinstance(return_keys, list) or not return_keys):
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
