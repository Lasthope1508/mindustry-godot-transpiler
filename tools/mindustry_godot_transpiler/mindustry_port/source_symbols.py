"""Canonical source-symbol registry checks."""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any


REGISTRY_RELATIVE_PATH = Path("src/generated/source_symbol_registry.json")
AUDIT_REPORT_RELATIVE_PATH = Path("src/generated/source_symbol_audit_report.json")
ALLOWED_STATUSES = {"source-backed", "explicit-input", "deferred", "generated"}
REQUIRED_ENTRY_FIELDS = {"status", "godot_symbol", "godot_owner", "rule", "tests", "runtime_proof"}
SOURCE_REQUIRED_STATUSES = {"source-backed", "explicit-input"}
DEFAULT_EXEMPT_SOURCE_OWNERS = ["PortGame.source_symbol_registry_state", "PortGame.source_symbol_audit_state"]


def load_source_symbol_registry(godot_root: Path) -> dict[str, Any]:
    registry_path = Path(godot_root) / REGISTRY_RELATIVE_PATH
    return json.loads(registry_path.read_text(encoding="utf-8"))


def load_source_symbol_audit_report(godot_root: Path) -> dict[str, Any]:
    report_path = Path(godot_root) / AUDIT_REPORT_RELATIVE_PATH
    return json.loads(report_path.read_text(encoding="utf-8"))


def source_symbol(registry: dict[str, Any], symbol: str) -> dict[str, Any]:
    symbols = registry.get("symbols", {})
    if symbol not in symbols:
        raise KeyError(f"source symbol not registered: {symbol}")
    return symbols[symbol]


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
