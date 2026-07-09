"""Canonical SSOT JSON catalog for source-backed migration metadata."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass(frozen=True)
class SourceSsotModule:
    name: str
    relative_path: Path
    root_key: str
    runtime_label: str


MODULES: tuple[SourceSsotModule, ...] = (
    SourceSsotModule("registry", Path("src/generated/source_symbol_registry.json"), "symbols", "symbol"),
    SourceSsotModule("audit_report", Path("src/generated/source_symbol_audit_report.json"), "", ""),
    SourceSsotModule("slice_ledger", Path("src/generated/source_slice_ledger.json"), "slices", "sliceId"),
    SourceSsotModule("api_contracts", Path("src/generated/source_api_contracts.json"), "contracts", "owner"),
    SourceSsotModule("state_schema", Path("src/generated/source_state_schema.json"), "schemas", "schemaName"),
)

_MODULES_BY_NAME = {module.name: module for module in MODULES}


def module_names() -> list[str]:
    return [module.name for module in MODULES]


def module(name: str) -> SourceSsotModule:
    if name not in _MODULES_BY_NAME:
        raise KeyError(f"source SSOT module not registered: {name}")
    return _MODULES_BY_NAME[name]


def relative_path(name: str) -> Path:
    return module(name).relative_path


def root_key(name: str) -> str:
    return module(name).root_key


def runtime_label(name: str) -> str:
    return module(name).runtime_label


def load_json(godot_root: Path, name: str) -> dict[str, Any]:
    return json.loads((Path(godot_root) / relative_path(name)).read_text(encoding="utf-8"))
