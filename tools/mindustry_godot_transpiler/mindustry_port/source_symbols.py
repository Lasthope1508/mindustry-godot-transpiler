"""Canonical source-symbol registry checks."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any


REGISTRY_RELATIVE_PATH = Path("src/generated/source_symbol_registry.json")
ALLOWED_STATUSES = {"source-backed", "explicit-input", "deferred", "generated"}
REQUIRED_ENTRY_FIELDS = {"status", "godot_symbol", "godot_owner", "rule", "tests", "runtime_proof"}
SOURCE_REQUIRED_STATUSES = {"source-backed", "explicit-input"}


def load_source_symbol_registry(godot_root: Path) -> dict[str, Any]:
    registry_path = Path(godot_root) / REGISTRY_RELATIVE_PATH
    return json.loads(registry_path.read_text(encoding="utf-8"))


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


def validate_source_symbol_registry(registry: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if registry.get("version") != 1:
        errors.append("registry: version must be 1")
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
