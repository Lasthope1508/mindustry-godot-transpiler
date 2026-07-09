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

def load_all_json(godot_root: Path) -> dict[str, dict[str, Any]]:
    return {module_name: load_json(godot_root, module_name) for module_name in module_names()}

def write_json(godot_root: Path, name: str, data: dict[str, Any]) -> Path:
    path = Path(godot_root) / relative_path(name)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return path

def validate_json_modules(godot_root: Path) -> dict[str, Any]:
    godot_root = Path(godot_root)
    errors: list[str] = []
    module_reports: list[dict[str, Any]] = []
    for entry in MODULES:
        path = godot_root / entry.relative_path
        report: dict[str, Any] = {
            "name": entry.name,
            "path": entry.relative_path.as_posix(),
            "root_key": entry.root_key,
            "runtime_label": entry.runtime_label,
            "loaded": False,
            "root_key_present": entry.root_key == "",
        }
        if not path.exists():
            errors.append(f"{entry.name}: missing {entry.relative_path.as_posix()}")
            module_reports.append(report)
            continue
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            errors.append(f"{entry.name}: invalid JSON at {entry.relative_path.as_posix()}: {exc.msg}")
            module_reports.append(report)
            continue
        if not isinstance(data, dict):
            errors.append(f"{entry.name}: root must be an object")
            module_reports.append(report)
            continue
        report["loaded"] = True
        if entry.root_key:
            report["root_key_present"] = entry.root_key in data
            if not report["root_key_present"]:
                errors.append(f"{entry.name}: missing root key {entry.root_key}")
        module_reports.append(report)
    return {
        "module_count": len(MODULES),
        "modules": module_reports,
        "errors": errors,
    }
