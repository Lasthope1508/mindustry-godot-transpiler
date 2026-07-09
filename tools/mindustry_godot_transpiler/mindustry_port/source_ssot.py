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


EXTENSION_MANIFEST_MODULE = SourceSsotModule(
    "module_manifest",
    Path("src/generated/source_ssot_modules.json"),
    "modules",
    "module",
)
EXTENSION_MODULE_ROOT = "src/generated/source_modules/"

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


def extension_manifest_relative_path() -> Path:
    return EXTENSION_MANIFEST_MODULE.relative_path


def load_extension_manifest(godot_root: Path) -> dict[str, Any]:
    path = Path(godot_root) / extension_manifest_relative_path()
    if not path.exists():
        return {"version": 1, "modules": {}}
    return json.loads(path.read_text(encoding="utf-8"))


def _extension_module_from_entry(name: str, entry: dict[str, Any]) -> SourceSsotModule:
    return SourceSsotModule(
        name,
        Path(str(entry.get("path", ""))),
        str(entry.get("root_key", "")),
        str(entry.get("label", "")),
    )


def extension_modules(godot_root: Path) -> list[SourceSsotModule]:
    manifest = load_extension_manifest(godot_root)
    modules = manifest.get("modules", {})
    if not isinstance(modules, dict):
        return []
    result: list[SourceSsotModule] = []
    for name, entry in modules.items():
        if isinstance(entry, dict):
            result.append(_extension_module_from_entry(str(name), entry))
    return result


def registered_modules(godot_root: Path) -> list[SourceSsotModule]:
    return [*MODULES, EXTENSION_MANIFEST_MODULE, *extension_modules(godot_root)]


def registered_module_names(godot_root: Path) -> list[str]:
    return [entry.name for entry in registered_modules(godot_root)]


def registered_module(godot_root: Path, name: str) -> SourceSsotModule:
    if name in _MODULES_BY_NAME:
        return module(name)
    if name == EXTENSION_MANIFEST_MODULE.name:
        return EXTENSION_MANIFEST_MODULE
    for entry in extension_modules(godot_root):
        if entry.name == name:
            return entry
    raise KeyError(f"source SSOT module not registered: {name}")


def registered_relative_path(godot_root: Path, name: str) -> Path:
    return registered_module(godot_root, name).relative_path


def registered_root_key(godot_root: Path, name: str) -> str:
    return registered_module(godot_root, name).root_key


def registered_runtime_label(godot_root: Path, name: str) -> str:
    return registered_module(godot_root, name).runtime_label


def load_json(godot_root: Path, name: str) -> dict[str, Any]:
    return json.loads((Path(godot_root) / relative_path(name)).read_text(encoding="utf-8"))


def load_registered_json(godot_root: Path, name: str) -> dict[str, Any]:
    path = Path(godot_root) / registered_relative_path(godot_root, name)
    return json.loads(path.read_text(encoding="utf-8"))


def load_all_json(godot_root: Path) -> dict[str, dict[str, Any]]:
    return {module_name: load_json(godot_root, module_name) for module_name in module_names()}


def load_all_registered_json(godot_root: Path) -> dict[str, dict[str, Any]]:
    return {
        module_name: load_registered_json(godot_root, module_name)
        for module_name in registered_module_names(godot_root)
    }


def write_json(godot_root: Path, name: str, data: dict[str, Any]) -> Path:
    path = Path(godot_root) / relative_path(name)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return path


def _validate_module_file(godot_root: Path, entry: SourceSsotModule, errors: list[str]) -> dict[str, Any]:
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
        return report
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        errors.append(f"{entry.name}: invalid JSON at {entry.relative_path.as_posix()}: {exc.msg}")
        return report
    if not isinstance(data, dict):
        errors.append(f"{entry.name}: root must be an object")
        return report
    report["loaded"] = True
    if entry.root_key:
        report["root_key_present"] = entry.root_key in data
        if not report["root_key_present"]:
            errors.append(f"{entry.name}: missing root key {entry.root_key}")
    return report


def _manifest_extension_modules(godot_root: Path, errors: list[str]) -> list[SourceSsotModule]:
    manifest_path = godot_root / EXTENSION_MANIFEST_MODULE.relative_path
    if not manifest_path.exists():
        return []
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return []
    if not isinstance(manifest, dict):
        return []
    modules = manifest.get("modules", {})
    if not isinstance(modules, dict):
        return []
    result: list[SourceSsotModule] = []
    reserved_names = set(module_names()) | {EXTENSION_MANIFEST_MODULE.name}
    for name, entry in modules.items():
        module_name = str(name)
        if module_name in reserved_names:
            errors.append(f"{module_name}: extension module name duplicates a core module")
            continue
        if not isinstance(entry, dict):
            errors.append(f"{module_name}: extension module entry must be an object")
            continue
        relative_path = str(entry.get("path", ""))
        root_key = str(entry.get("root_key", ""))
        if not root_key:
            errors.append(f"{module_name}: extension module root_key is required")
        path_obj = Path(relative_path)
        path_text = path_obj.as_posix()
        if path_obj.is_absolute() or ".." in path_obj.parts or not path_text.startswith(EXTENSION_MODULE_ROOT):
            errors.append(f"{module_name}: extension path must stay under src/generated/source_modules")
            continue
        result.append(_extension_module_from_entry(module_name, entry))
    return result


def validate_json_modules(godot_root: Path) -> dict[str, Any]:
    godot_root = Path(godot_root)
    errors: list[str] = []
    module_reports: list[dict[str, Any]] = []
    for entry in [*MODULES, EXTENSION_MANIFEST_MODULE]:
        module_reports.append(_validate_module_file(godot_root, entry, errors))
    for entry in _manifest_extension_modules(godot_root, errors):
        module_reports.append(_validate_module_file(godot_root, entry, errors))
    return {
        "module_count": len(module_reports),
        "modules": module_reports,
        "errors": errors,
    }
