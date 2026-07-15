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
    canonical_module: str = ""
    canonical_collection_key: str = ""
    canonical_key_field: str = ""
    canonical_value_field: str = ""
    canonical_reference_key: str = ""
    canonical_reference_prefix: str = ""
    mirror_fields: tuple[str, ...] = ()


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
    SourceSsotModule("playable_content", Path("src/generated/playable_content.json"), "", ""),
    SourceSsotModule("asset_manifest", Path("src/generated/asset_manifest.json"), "", ""),
    SourceSsotModule("source_manifest", Path("src/generated/source_manifest.json"), "", ""),
    SourceSsotModule("ast_manifest", Path("src/generated/ast_manifest.json"), "", ""),
    SourceSsotModule("content_registry", Path("src/generated/content_registry.json"), "", ""),
    SourceSsotModule("emitted_classes", Path("src/generated/emitted_classes.json"), "", ""),
    SourceSsotModule("port_report", Path("src/generated/port_report.json"), "", ""),
)

_MODULES_BY_NAME = {module.name: module for module in MODULES}
_MODULE_ALIASES = {
    "source_slice_ledger_slices": "slice_ledger",
    "source_api_contracts_contracts": "api_contracts",
    "port_report_unsupported_features": "port_report",
    "asset_manifest_assets": "asset_manifest",
    "source_manifest_files": "source_manifest",
    "source_audit_functions": "audit_report",
    "source_audit_registered_owners": "audit_report",
    "source_audit_exempt_owners": "audit_report",
    "source_audit_legacy_unregistered_owners": "audit_report",
    "helper_state_schema": "state_schema",
    "payload_state_schema": "state_schema",
    "payload_symbols": "registry",
    "type_state_schema": "state_schema",
    "type_symbols": "registry",
    "bullet_state_schema": "state_schema",
    "bullet_symbols": "registry",
    "power_state_schema": "state_schema",
    "power_symbols": "registry",
    "comp_state_schema": "state_schema",
    "consumer_state_schema": "state_schema",
    "block_state_schema": "state_schema",
    "block_symbols": "registry",
    "defense_state_schema": "state_schema",
    "consumer_symbols": "registry",
    "comp_symbols": "registry",
    "defense_symbols": "registry",
}
_SOURCE_SLICE_LEDGER_MIRROR_FIELDS = (
    "exact_exprs",
    "godot_owner",
    "java_class",
    "java_method",
    "java_source",
    "runtime_proof",
    "source_symbols",
    "status",
    "tests",
    "slice",
)
_DOMAIN_SYMBOL_SHARDS: dict[str, dict[str, Any]] = {
    "consumer_symbols": {
        "slice_module": "consumer_slices",
        "contract_module": "consumer_api_contracts",
        "slice_filter": "",
        "include_contract_owner_symbols": False,
        "policy": {
            "canonicalOwner": "source_symbol_registry",
            "newConsumerSymbolRequiresCanonicalMirror": True,
            "source": "Derived from consumer_slices.source_symbols and canonical source_symbol_registry.symbols; no symbol metadata is authored here.",
        },
        "mirror_fields": (
            "status",
            "java_source",
            "java_method",
            "java_expr",
            "godot_symbol",
            "godot_owner",
            "rule",
            "tests",
            "runtime_proof",
        ),
    },
    "payload_symbols": {
        "slice_module": "payload_slices",
        "contract_module": "payload_api_contracts",
        "slice_filter": "/world/blocks/payloads/",
        "include_contract_owner_symbols": True,
        "mirror_fields": (
            "status",
            "java_expr",
            "godot_symbol",
            "godot_owner",
            "rule",
            "tests",
            "runtime_proof",
        ),
    },
    "block_symbols": {
        "slice_module": "block_slices",
        "contract_module": "block_api_contracts",
        "slice_filter": "core/src/mindustry/world/Block.java",
        "include_contract_owner_symbols": False,
        "mirror_fields": (
            "status",
            "java_expr",
            "godot_symbol",
            "godot_owner",
            "rule",
            "tests",
            "runtime_proof",
        ),
    },
    "type_symbols": {
        "slice_module": "type_slices",
        "contract_module": "type_api_contracts",
        "slice_filter": "/type/",
        "include_contract_owner_symbols": False,
        "mirror_fields": (
            "status",
            "java_expr",
            "godot_symbol",
            "godot_owner",
            "rule",
            "tests",
            "runtime_proof",
        ),
    },
    "bullet_symbols": {
        "slice_module": "bullet_slices",
        "contract_module": "bullet_api_contracts",
        "slice_filter": "/entities/bullet/",
        "include_contract_owner_symbols": False,
        "mirror_fields": (
            "status",
            "java_expr",
            "godot_symbol",
            "godot_owner",
            "rule",
            "tests",
            "runtime_proof",
        ),
    },
    "power_symbols": {
        "slice_module": "power_slices",
        "contract_module": "power_api_contracts",
        "slice_filter": "/world/blocks/power/",
        "include_contract_owner_symbols": True,
        "mirror_fields": (
            "status",
            "java_expr",
            "godot_symbol",
            "godot_owner",
            "rule",
            "tests",
            "runtime_proof",
        ),
    },
    "comp_symbols": {
        "slice_module": "comp_slices",
        "contract_module": "comp_api_contracts",
        "slice_filter": "/entities/comp/",
        "include_contract_owner_symbols": True,
        "mirror_fields": (
            "status",
            "java_expr",
            "godot_symbol",
            "godot_owner",
            "rule",
            "tests",
            "runtime_proof",
        ),
    },
    "defense_symbols": {
        "slice_module": "defense_slices",
        "contract_module": "defense_api_contracts",
        "slice_filter": "/world/blocks/defense/",
        "include_contract_owner_symbols": True,
        "mirror_fields": (
            "status",
            "java_expr",
            "godot_symbol",
            "godot_owner",
            "rule",
            "tests",
            "runtime_proof",
        ),
    },
}
_DOMAIN_STATE_SCHEMA_SHARDS: dict[str, dict[str, Any]] = {
    "payload_state_schema": {
        "contract_module": "payload_api_contracts",
        "mirror_fields": ("keys",),
    },
    "type_state_schema": {
        "contract_module": "type_api_contracts",
        "mirror_fields": ("keys",),
    },
    "bullet_state_schema": {
        "contract_module": "bullet_api_contracts",
        "mirror_fields": ("keys",),
    },
    "power_state_schema": {
        "contract_module": "power_api_contracts",
        "mirror_fields": ("keys",),
    },
    "consumer_state_schema": {
        "contract_module": "consumer_api_contracts",
        "mirror_fields": ("keys",),
    },
    "comp_state_schema": {
        "contract_module": "comp_api_contracts",
        "mirror_fields": ("keys",),
    },
    "block_state_schema": {
        "contract_module": "block_api_contracts",
        "mirror_fields": ("keys",),
    },
    "defense_state_schema": {
        "contract_module": "defense_api_contracts",
        "mirror_fields": ("keys",),
    },
}


def module_names() -> list[str]:
    return [module.name for module in MODULES]


def module(name: str) -> SourceSsotModule:
    if name in _MODULE_ALIASES:
        return module(_MODULE_ALIASES[name])
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
    mirror_fields = entry.get("mirror_fields", [])
    if not isinstance(mirror_fields, list):
        mirror_fields = []
    return SourceSsotModule(
        name,
        Path(str(entry.get("path", ""))),
        str(entry.get("root_key", "")),
        str(entry.get("label", "")),
        str(entry.get("canonical_module", "")),
        str(entry.get("canonical_collection_key", "")),
        str(entry.get("canonical_key_field", "")),
        str(entry.get("canonical_value_field", "")),
        str(entry.get("canonical_reference_key", "")),
        str(entry.get("canonical_reference_prefix", "")),
        tuple(str(field) for field in mirror_fields),
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
    if name in _MODULE_ALIASES:
        return registered_module(godot_root, _MODULE_ALIASES[name])
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
    if name == "source_slice_ledger_slices":
        return _virtual_source_slice_ledger_slices(godot_root)
    if name == "source_api_contracts_contracts":
        return _virtual_source_api_contracts_contracts(godot_root)
    if name == "port_report_unsupported_features":
        return _virtual_port_report_unsupported_features(godot_root)
    if name == "asset_manifest_assets":
        return _virtual_asset_manifest_assets(godot_root)
    if name == "source_manifest_files":
        return _virtual_source_manifest_files(godot_root)
    if name == "source_audit_functions":
        return _virtual_indexed_list_shard(
            godot_root,
            canonical_module="audit_report",
            canonical_collection_key="sourceFunctions",
            root_key="functions",
            canonical_reference_key="canonical_function",
            canonical_reference_prefix="source_symbol_audit_report.sourceFunctions.",
            value_field="function_entry",
        )
    if name == "source_audit_registered_owners":
        return _virtual_indexed_list_shard(
            godot_root,
            canonical_module="audit_report",
            canonical_collection_key="registeredSourceOwners",
            root_key="owners",
            canonical_reference_key="canonical_owner",
            canonical_reference_prefix="source_symbol_audit_report.registeredSourceOwners.",
            value_field="owner",
        )
    if name == "source_audit_exempt_owners":
        return _virtual_indexed_list_shard(
            godot_root,
            canonical_module="audit_report",
            canonical_collection_key="exemptSourceOwners",
            root_key="owners",
            canonical_reference_key="canonical_owner",
            canonical_reference_prefix="source_symbol_audit_report.exemptSourceOwners.",
            value_field="owner",
        )
    if name == "source_audit_legacy_unregistered_owners":
        return _virtual_indexed_list_shard(
            godot_root,
            canonical_module="audit_report",
            canonical_collection_key="legacyUnregisteredOwners",
            root_key="owners",
            canonical_reference_key="canonical_owner",
            canonical_reference_prefix="source_symbol_audit_report.legacyUnregisteredOwners.",
            value_field="owner",
        )
    if name == "helper_state_schema":
        return _virtual_helper_state_schema(godot_root)
    if name in _DOMAIN_STATE_SCHEMA_SHARDS:
        return _virtual_domain_state_schema(godot_root, name)
    if name in _DOMAIN_SYMBOL_SHARDS:
        return _virtual_domain_symbols(godot_root, name)
    path = Path(godot_root) / registered_relative_path(godot_root, name)
    return json.loads(path.read_text(encoding="utf-8"))

def _virtual_source_slice_ledger_slices(godot_root: Path) -> dict[str, Any]:
    canonical_slices = load_registered_json(godot_root, "slice_ledger").get("slices", {})
    if not isinstance(canonical_slices, dict):
        canonical_slices = {}
    mirror: dict[str, Any] = {}
    for slice_id, canonical_entry in sorted(canonical_slices.items()):
        if not isinstance(canonical_entry, dict):
            continue
        entry: dict[str, Any] = {"canonical_slice": f"source_slice_ledger.{slice_id}"}
        for field in _SOURCE_SLICE_LEDGER_MIRROR_FIELDS:
            if field == "slice":
                entry[field] = canonical_entry
            else:
                entry[field] = canonical_entry[field]
        mirror[str(slice_id)] = entry
    return {"version": 1, "slices": mirror}

def _virtual_source_api_contracts_contracts(godot_root: Path) -> dict[str, Any]:
    canonical_contracts = load_registered_json(godot_root, "api_contracts").get("contracts", {})
    if not isinstance(canonical_contracts, dict):
        canonical_contracts = {}
    mirror: dict[str, Any] = {}
    for contract_owner, canonical_entry in sorted(canonical_contracts.items()):
        if not isinstance(canonical_entry, dict):
            continue
        entry: dict[str, Any] = {"canonical_contract": f"source_api_contracts.{contract_owner}"}
        for field in ("java_source", "params", "return_keys", "rule", "runtime_proof", "source_method", "source_slice", "status", "tests", "contract"):
            if field == "contract":
                entry[field] = canonical_entry
            else:
                entry[field] = canonical_entry[field]
        mirror[str(contract_owner)] = entry
    return {"version": 1, "contracts": mirror}

def _virtual_port_report_unsupported_features(godot_root: Path) -> dict[str, Any]:
    canonical_features = load_registered_json(godot_root, "port_report").get("unsupported_features", [])
    if not isinstance(canonical_features, list):
        canonical_features = []
    mirror: dict[str, Any] = {}
    for index, canonical_entry in enumerate(canonical_features):
        if not isinstance(canonical_entry, dict):
            continue
        entry: dict[str, Any] = {"canonical_feature": f"port_report.unsupported_features.{index}"}
        entry["index"] = index
        entry["feature_entry"] = canonical_entry
        mirror[str(index)] = entry
    return {"version": 1, "features": mirror}

def _virtual_asset_manifest_assets(godot_root: Path) -> dict[str, Any]:
    canonical_assets = load_registered_json(godot_root, "asset_manifest").get("assets", [])
    if not isinstance(canonical_assets, list):
        canonical_assets = []
    mirror: dict[str, Any] = {}
    for canonical_entry in canonical_assets:
        if not isinstance(canonical_entry, dict):
            continue
        target = str(canonical_entry.get("target", ""))
        if not target:
            continue
        entry: dict[str, Any] = {"canonical_asset": f"asset_manifest.assets.{target}"}
        for field in ("bytes", "sha256", "source", "target"):
            entry[field] = canonical_entry[field]
        mirror[target] = entry
    return {"version": 1, "assets": mirror}

def _virtual_source_manifest_files(godot_root: Path) -> dict[str, Any]:
    canonical_files = load_registered_json(godot_root, "source_manifest").get("files", [])
    if not isinstance(canonical_files, list):
        canonical_files = []
    mirror: dict[str, Any] = {}
    for canonical_entry in canonical_files:
        if not isinstance(canonical_entry, dict):
            continue
        path = str(canonical_entry.get("path", ""))
        if not path:
            continue
        entry: dict[str, Any] = {"canonical_file": f"source_manifest.files.{path}"}
        for field in ("bytes", "package", "path", "sha256", "types"):
            entry[field] = canonical_entry[field]
        mirror[path] = entry
    return {"version": 1, "files": mirror}

def _virtual_indexed_list_shard(
    godot_root: Path,
    *,
    canonical_module: str,
    canonical_collection_key: str,
    root_key: str,
    canonical_reference_key: str,
    canonical_reference_prefix: str,
    value_field: str,
) -> dict[str, Any]:
    canonical_values = load_registered_json(godot_root, canonical_module).get(canonical_collection_key, [])
    if not isinstance(canonical_values, list):
        canonical_values = []
    mirror: dict[str, Any] = {}
    for index, canonical_entry in enumerate(canonical_values):
        item_key = str(index)
        mirror[item_key] = {
            canonical_reference_key: f"{canonical_reference_prefix}{item_key}",
            "index": index,
            value_field: canonical_entry,
        }
    return {"version": 1, root_key: mirror}


def _virtual_domain_symbols(godot_root: Path, shard_name: str) -> dict[str, Any]:
    config = _DOMAIN_SYMBOL_SHARDS[shard_name]
    domain_slices = load_registered_json(godot_root, str(config["slice_module"])).get("slices", {})
    domain_contracts = load_registered_json(godot_root, str(config["contract_module"])).get("contracts", {})
    canonical_symbols = load_registered_json(godot_root, "registry").get("symbols", {})
    if not isinstance(domain_slices, dict):
        domain_slices = {}
    if not isinstance(domain_contracts, dict):
        domain_contracts = {}
    if not isinstance(canonical_symbols, dict):
        canonical_symbols = {}
    slice_filter = str(config["slice_filter"])
    include_contract_owner_symbols = bool(config.get("include_contract_owner_symbols", True))
    expected_symbol_names = {
        str(symbol_name)
        for slice_entry in domain_slices.values()
        if isinstance(slice_entry, dict) and slice_filter in str(slice_entry.get("java_source", ""))
        for symbol_name in slice_entry.get("source_symbols", [])
    }
    if include_contract_owner_symbols:
        expected_symbol_names |= {
            str(symbol_name)
            for symbol_name, symbol_entry in canonical_symbols.items()
            if isinstance(symbol_entry, dict) and symbol_entry.get("godot_owner") in domain_contracts
        }
    mirror: dict[str, Any] = {}
    for symbol_name in sorted(expected_symbol_names):
        canonical_entry = canonical_symbols.get(symbol_name)
        if not isinstance(canonical_entry, dict):
            continue
        entry: dict[str, Any] = {"canonical_symbol": f"source_symbol_registry.{symbol_name}"}
        for field in config["mirror_fields"]:
            entry[field] = canonical_entry[field]
        mirror[symbol_name] = entry
    result: dict[str, Any] = {"version": 1, "symbols": mirror}
    if "policy" in config:
        result["policy"] = config["policy"]
    return result

def _schema_names_for_contracts(canonical_schema: dict[str, Any], contracts: dict[str, Any]) -> set[str]:
    schema_names: set[str] = set()
    for owner, contract in sorted(contracts.items()):
        if not isinstance(contract, dict):
            continue
        for param in contract.get("params", []):
            if not isinstance(param, dict) or "schema" not in param:
                continue
            schema_name = str(param["schema"]).split(".", 1)[0]
            if schema_name in canonical_schema:
                schema_names.add(schema_name)
        source_name = str(owner).split(".")[-1]
        if source_name.endswith("_state"):
            result_schema_name = source_name[:-len("_state")] + "_result"
            if result_schema_name in canonical_schema:
                schema_names.add(result_schema_name)
    return schema_names

def _virtual_helper_state_schema(godot_root: Path) -> dict[str, Any]:
    canonical_schema = load_registered_json(godot_root, "state_schema").get("schemas", {})
    canonical_contracts = load_registered_json(godot_root, "api_contracts").get("contracts", {})
    if not isinstance(canonical_schema, dict):
        canonical_schema = {}
    if not isinstance(canonical_contracts, dict):
        canonical_contracts = {}
    domain_schema_names = _schema_names_for_contracts(canonical_schema, canonical_contracts)
    sharded_schema_names: set[str] = set()
    for module_name in registered_module_names(godot_root):
        if not module_name.endswith("_state_schema") or module_name == "helper_state_schema":
            continue
        schemas = load_registered_json(godot_root, module_name).get("schemas", {})
        if isinstance(schemas, dict):
            sharded_schema_names.update(str(schema_name) for schema_name in schemas)
    expected_schema_names = set(canonical_schema) - domain_schema_names - sharded_schema_names
    mirror: dict[str, Any] = {}
    for schema_name in sorted(expected_schema_names):
        canonical_entry = canonical_schema.get(schema_name)
        if not isinstance(canonical_entry, dict):
            continue
        mirror[schema_name] = {
            "canonical_schema": f"source_state_schema.{schema_name}",
            "keys": canonical_entry["keys"],
        }
    return {"version": 1, "schemas": mirror}

def _virtual_domain_state_schema(godot_root: Path, shard_name: str) -> dict[str, Any]:
    config = _DOMAIN_STATE_SCHEMA_SHARDS[shard_name]
    domain_contracts = load_registered_json(godot_root, str(config["contract_module"])).get("contracts", {})
    canonical_schema = load_registered_json(godot_root, "state_schema").get("schemas", {})
    if not isinstance(domain_contracts, dict):
        domain_contracts = {}
    if not isinstance(canonical_schema, dict):
        canonical_schema = {}
    expected_schema_names = _schema_names_for_contracts(canonical_schema, domain_contracts)
    mirror: dict[str, Any] = {}
    for schema_name in sorted(expected_schema_names):
        canonical_entry = canonical_schema.get(schema_name)
        if not isinstance(canonical_entry, dict):
            continue
        entry: dict[str, Any] = {"canonical_schema": f"source_state_schema.{schema_name}"}
        for field in config["mirror_fields"]:
            entry[field] = canonical_entry[field]
        mirror[schema_name] = entry
    return {"version": 1, "schemas": mirror}

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
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    return path


def _canonical_values_for_extension(godot_root: Path, entry: SourceSsotModule) -> dict[str, Any]:
    canonical_module = registered_module(godot_root, entry.canonical_module)
    canonical_data = load_registered_json(godot_root, entry.canonical_module)
    if canonical_module.root_key:
        canonical_entries = canonical_data.get(canonical_module.root_key, {})
        if not isinstance(canonical_entries, dict):
            raise ValueError(f"{entry.name}: canonical root key {canonical_module.root_key} must be an object")
        return {str(key): value for key, value in canonical_entries.items()}
    if not entry.canonical_collection_key:
        raise ValueError(f"{entry.name}: canonical module {entry.canonical_module} has no root key")
    canonical_values_raw = _nested_value(canonical_data, entry.canonical_collection_key)
    canonical_values: dict[str, Any] = {}
    if isinstance(canonical_values_raw, dict):
        if entry.canonical_key_field and entry.canonical_key_field in canonical_values_raw:
            canonical_values = {str(canonical_values_raw[entry.canonical_key_field]): canonical_values_raw}
        else:
            canonical_values = {str(key): value for key, value in canonical_values_raw.items()}
    elif isinstance(canonical_values_raw, list):
        for index, value in enumerate(canonical_values_raw):
            if entry.canonical_key_field == "@index":
                canonical_values[str(index)] = value
            elif entry.canonical_key_field:
                if not isinstance(value, dict):
                    raise ValueError(f"{entry.name}: canonical collection {entry.canonical_module}.{entry.canonical_collection_key} entries must be objects")
                canonical_values[str(value.get(entry.canonical_key_field, ""))] = value
            else:
                canonical_values[str(value)] = value
    else:
        raise ValueError(f"{entry.name}: canonical collection {entry.canonical_module}.{entry.canonical_collection_key} must be an array or object")
    return canonical_values

def build_extension_shard(godot_root: Path, name: str) -> dict[str, Any]:
    godot_root = Path(godot_root)
    entry = registered_module(godot_root, name)
    if not entry.canonical_module:
        raise ValueError(f"{entry.name}: canonical_module is required")
    if not entry.root_key:
        raise ValueError(f"{entry.name}: root_key is required")
    if not entry.canonical_reference_key:
        raise ValueError(f"{entry.name}: canonical_reference_key is required")
    if not entry.canonical_reference_prefix:
        raise ValueError(f"{entry.name}: canonical_reference_prefix is required")
    if not entry.mirror_fields:
        raise ValueError(f"{entry.name}: mirror_fields must be a non-empty list")

    canonical_values = _canonical_values_for_extension(godot_root, entry)
    shard_entries: dict[str, Any] = {}
    for item_key, canonical_value in sorted(canonical_values.items()):
        shard_entry: dict[str, Any] = {
            entry.canonical_reference_key: f"{entry.canonical_reference_prefix}{item_key}",
        }
        for field in entry.mirror_fields:
            if field == entry.canonical_value_field:
                shard_entry[field] = canonical_value
            elif entry.canonical_key_field == "@index" and field == "index":
                shard_entry[field] = int(item_key)
            elif isinstance(canonical_value, dict):
                shard_entry[field] = canonical_value[field]
            else:
                shard_entry[field] = canonical_value
        shard_entries[item_key] = shard_entry
    return {"version": 1, entry.root_key: shard_entries}

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
    if entry.canonical_module and entry.root_key and report["root_key_present"]:
        report["canonical_mirror"] = _validate_extension_canonical_mirror(godot_root, entry, data, errors)
    return report

def _validate_extension_canonical_mirror(
    godot_root: Path,
    entry: SourceSsotModule,
    data: dict[str, Any],
    errors: list[str],
) -> dict[str, Any]:
    report = {
        "canonical_module": entry.canonical_module,
        "canonical_collection_key": entry.canonical_collection_key,
        "canonical_key_field": entry.canonical_key_field,
        "canonical_value_field": entry.canonical_value_field,
        "canonical_reference_key": entry.canonical_reference_key,
        "canonical_reference_prefix": entry.canonical_reference_prefix,
        "mirror_fields": list(entry.mirror_fields),
        "checked": 0,
    }
    if not entry.canonical_reference_key:
        errors.append(f"{entry.name}: canonical_reference_key is required")
        return report
    if not entry.canonical_reference_prefix:
        errors.append(f"{entry.name}: canonical_reference_prefix is required")
        return report
    if not entry.mirror_fields:
        errors.append(f"{entry.name}: mirror_fields must be a non-empty list")
        return report
    try:
        canonical_module = registered_module(godot_root, entry.canonical_module)
    except KeyError:
        errors.append(f"{entry.name}: canonical module {entry.canonical_module} is not registered")
        return report
    if not canonical_module.root_key:
        if entry.canonical_collection_key:
            return _validate_extension_canonical_array_mirror(godot_root, entry, data, errors, report)
        errors.append(f"{entry.name}: canonical module {entry.canonical_module} has no root key")
        return report
    try:
        canonical_data = load_registered_json(godot_root, entry.canonical_module)
    except (FileNotFoundError, json.JSONDecodeError) as exc:
        errors.append(f"{entry.name}: cannot load canonical module {entry.canonical_module}: {exc}")
        return report
    shard_entries = data.get(entry.root_key, {})
    canonical_entries = canonical_data.get(canonical_module.root_key, {})
    if not isinstance(shard_entries, dict):
        errors.append(f"{entry.name}: root key {entry.root_key} must be an object")
        return report
    if not isinstance(canonical_entries, dict):
        errors.append(f"{entry.name}: canonical root key {canonical_module.root_key} must be an object")
        return report
    for item_key, shard_entry in sorted(shard_entries.items()):
        if not isinstance(shard_entry, dict):
            errors.append(f"{entry.name}.{item_key}: shard entry must be an object")
            continue
        canonical_entry = canonical_entries.get(item_key)
        if not isinstance(canonical_entry, dict):
            errors.append(f"{entry.name}.{item_key}: missing canonical {entry.canonical_module}.{item_key}")
            continue
        expected_reference = f"{entry.canonical_reference_prefix}{item_key}"
        if shard_entry.get(entry.canonical_reference_key) != expected_reference:
            errors.append(f"{entry.name}.{item_key}: {entry.canonical_reference_key} must be {expected_reference}")
        for field in entry.mirror_fields:
            if field not in shard_entry:
                errors.append(f"{entry.name}.{item_key}: missing mirror field {field}")
                continue
            if field == entry.canonical_value_field:
                expected_value = canonical_entry
            else:
                if field not in canonical_entry:
                    errors.append(f"{entry.name}.{item_key}: canonical {entry.canonical_module}.{item_key} missing field {field}")
                    continue
                expected_value = canonical_entry[field]
            if shard_entry[field] != expected_value:
                errors.append(f"{entry.name}.{item_key}: mirror field {field} differs from {entry.canonical_module}.{item_key}")
        report["checked"] += 1
    return report

def _nested_value(data: dict[str, Any], dotted_key: str) -> Any:
    value: Any = data
    for key in dotted_key.split("."):
        if not isinstance(value, dict) or key not in value:
            return None
        value = value[key]
    return value

def _validate_extension_canonical_array_mirror(
    godot_root: Path,
    entry: SourceSsotModule,
    data: dict[str, Any],
    errors: list[str],
    report: dict[str, Any],
) -> dict[str, Any]:
    try:
        canonical_data = load_registered_json(godot_root, entry.canonical_module)
    except (FileNotFoundError, json.JSONDecodeError) as exc:
        errors.append(f"{entry.name}: cannot load canonical module {entry.canonical_module}: {exc}")
        return report
    shard_entries = data.get(entry.root_key, {})
    canonical_values_raw = _nested_value(canonical_data, entry.canonical_collection_key)
    if not isinstance(shard_entries, dict):
        errors.append(f"{entry.name}: root key {entry.root_key} must be an object")
        return report
    canonical_values: dict[str, Any] = {}
    if isinstance(canonical_values_raw, dict):
        if entry.canonical_key_field and entry.canonical_key_field in canonical_values_raw:
            canonical_values = {str(canonical_values_raw[entry.canonical_key_field]): canonical_values_raw}
        else:
            canonical_values = {str(key): value for key, value in canonical_values_raw.items()}
    elif isinstance(canonical_values_raw, list):
        for index, value in enumerate(canonical_values_raw):
            if entry.canonical_key_field == "@index":
                canonical_values[str(index)] = value
            elif entry.canonical_key_field:
                if not isinstance(value, dict):
                    errors.append(f"{entry.name}: canonical collection {entry.canonical_module}.{entry.canonical_collection_key} entries must be objects")
                    continue
                canonical_values[str(value.get(entry.canonical_key_field, ""))] = value
            else:
                canonical_values[str(value)] = value
    else:
        errors.append(f"{entry.name}: canonical collection {entry.canonical_module}.{entry.canonical_collection_key} must be an array or object")
        return report
    for item_key, shard_entry in sorted(shard_entries.items()):
        if not isinstance(shard_entry, dict):
            errors.append(f"{entry.name}.{item_key}: shard entry must be an object")
            continue
        if item_key not in canonical_values:
            errors.append(f"{entry.name}.{item_key}: missing canonical {entry.canonical_module}.{entry.canonical_collection_key}.{item_key}")
            continue
        expected_reference = f"{entry.canonical_reference_prefix}{item_key}"
        if shard_entry.get(entry.canonical_reference_key) != expected_reference:
            errors.append(f"{entry.name}.{item_key}: {entry.canonical_reference_key} must be {expected_reference}")
        for field in entry.mirror_fields:
            if field not in shard_entry:
                errors.append(f"{entry.name}.{item_key}: missing mirror field {field}")
                continue
            canonical_value = canonical_values[item_key]
            if field == entry.canonical_value_field:
                expected_value = canonical_value
            elif entry.canonical_key_field == "@index" and field == "index":
                expected_value = int(item_key)
            else:
                expected_value = canonical_value.get(field) if isinstance(canonical_value, dict) else canonical_value
            if shard_entry[field] != expected_value:
                errors.append(f"{entry.name}.{item_key}: mirror field {field} differs from {entry.canonical_module}.{entry.canonical_collection_key}.{item_key}")
        report["checked"] += 1
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
        canonical_module = str(entry.get("canonical_module", ""))
        if canonical_module:
            if str(entry.get("canonical_reference_key", "")) == "":
                errors.append(f"{module_name}: canonical_reference_key is required")
            if str(entry.get("canonical_reference_prefix", "")) == "":
                errors.append(f"{module_name}: canonical_reference_prefix is required")
            if not isinstance(entry.get("mirror_fields", []), list) or not entry.get("mirror_fields"):
                errors.append(f"{module_name}: mirror_fields must be a non-empty list")
        path_obj = Path(relative_path)
        path_text = path_obj.as_posix()
        if path_obj.is_absolute() or ".." in path_obj.parts or not path_text.startswith(EXTENSION_MODULE_ROOT):
            errors.append(f"{module_name}: extension path must stay under src/generated/source_modules")
            continue
        result.append(_extension_module_from_entry(module_name, entry))
    return result


def _validate_generated_json_coverage(
    godot_root: Path,
    extension_entries: list[SourceSsotModule],
    errors: list[str],
) -> None:
    registered_paths = {
        entry.relative_path.as_posix()
        for entry in [*MODULES, EXTENSION_MANIFEST_MODULE, *extension_entries]
    }
    generated_root = godot_root / "src/generated"
    source_modules_root = generated_root / "source_modules"
    discovered_paths: list[Path] = []
    if generated_root.exists():
        discovered_paths.extend(sorted(generated_root.glob("*.json")))
    if source_modules_root.exists():
        discovered_paths.extend(sorted(source_modules_root.glob("*.json")))
    for json_path in discovered_paths:
        relative_path = json_path.relative_to(godot_root).as_posix()
        if relative_path in registered_paths:
            continue
        module_name = json_path.stem
        errors.append(f"{module_name}: unregistered generated JSON file {relative_path}")

def validate_json_modules(godot_root: Path) -> dict[str, Any]:
    godot_root = Path(godot_root)
    errors: list[str] = []
    module_reports: list[dict[str, Any]] = []
    for entry in [*MODULES, EXTENSION_MANIFEST_MODULE]:
        module_reports.append(_validate_module_file(godot_root, entry, errors))
    extension_entries = _manifest_extension_modules(godot_root, errors)
    for entry in extension_entries:
        module_reports.append(_validate_module_file(godot_root, entry, errors))
    _validate_generated_json_coverage(godot_root, extension_entries, errors)
    return {
        "module_count": len(module_reports),
        "modules": module_reports,
        "errors": errors,
    }
