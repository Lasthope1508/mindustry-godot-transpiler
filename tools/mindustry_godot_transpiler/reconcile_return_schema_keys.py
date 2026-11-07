"""Backfill result-schema keys only when the canonical state function proves them."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
UPSTREAM = ROOT.parent / "mindustry-upstream"


def function_candidates(owner: str) -> list[str]:
    stem = owner.split(".")[-1]
    if stem.startswith("source_"):
        stem = stem[len("source_") :]
    parts = stem.split("_")
    return ["_".join(parts[index:]) for index in range(len(parts))]


def find_canonical_function(owner: str, keys: list[str]) -> tuple[Path, str, str] | None:
    candidates = function_candidates(owner)
    patterns = [re.compile(rf"^static func {re.escape(name)}\s*\(", re.MULTILINE) for name in candidates]
    fallback = None
    best = None
    best_score = -1
    for path in sorted((GODOT / "src" / "game").rglob("*.gd")):
        text = path.read_text(encoding="utf-8", errors="replace")
        for name, pattern in zip(candidates, patterns):
            match = pattern.search(text)
            if not match:
                continue
            end = re.search(r"^static func |^func ", text[match.end() :], re.MULTILINE)
            body_end = match.end() + end.start() if end else len(text)
            candidate = (path, name, text[match.start() : body_end])
            if fallback is None:
                fallback = candidate
            score = sum(body_proves_key(candidate[2], key) for key in keys)
            if score > best_score:
                best = candidate
                best_score = score
    if best_score > 0:
        return best
    if fallback:
        return fallback
    owner_function = owner.split(".")[-1]
    for path in sorted((GODOT / "src" / "game").rglob("*.gd")):
        text = path.read_text(encoding="utf-8", errors="replace")
        match = re.search(rf"^func {re.escape(owner_function)}\s*\(", text, re.MULTILINE)
        if match:
            return path, owner_function, text[match.start() :]
    return None


def body_proves_key(body: str, key: str) -> bool:
    return bool(re.search(rf"[\"']{re.escape(key)}[\"']\s*:", body))


def body_value(body: str, key: str) -> str | None:
    match = re.search(rf"[\"']{re.escape(key)}[\"']\s*:\s*([^,\n]+)", body)
    return match.group(1).strip() if match else None


def camel_case(key: str) -> str:
    parts = key.split("_")
    return parts[0] + "".join(part.capitalize() for part in parts[1:])


def upstream_evidence(source_file: str, key: str, body_value_text: str | None) -> str | None:
    path = UPSTREAM / source_file
    if not path.exists():
        return None
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    candidates = [key, camel_case(key)]
    if body_value_text and body_value_text.startswith(('"', "'")):
        candidates.append(body_value_text.strip('"\''))
    for line in lines:
        if any(candidate and candidate in line for candidate in candidates):
            return line.strip()
    return None


def common_source_metadata(entry: dict) -> tuple[str, str] | None:
    for value in entry.get("keys", {}).values():
        if value.get("java_source") and value.get("java_method"):
            return str(value["java_source"]), str(value["java_method"])
    return None


def input_schema_for_key(schema_catalog: dict, result_schema: str, key: str) -> str | None:
    base = result_schema.removesuffix("_result")
    candidate = f"{base}_input"
    if candidate in schema_catalog.get("schemas", {}) and key in schema_catalog["schemas"][candidate].get("keys", {}):
        return candidate
    return None


def contract_input_schema_for_key(catalog: dict, contract: dict, key: str) -> str | None:
    for param in contract.get("params", []):
        schema_name = str(param.get("schema", ""))
        schema = catalog.get("schemas", {}).get(schema_name, {})
        if key in schema.get("keys", {}):
            return schema_name
    return None


def reconcile(dry_run: bool, owner_filter: set[str] | None = None) -> dict:
    registry = source_symbols.load_source_symbol_registry(GODOT)
    contracts = source_symbols.load_source_api_contracts(GODOT)
    catalog = source_symbols.load_source_state_schema(GODOT)
    schemas = catalog["schemas"]
    added: list[str] = []
    unresolved: list[str] = []
    for owner, contract in sorted(contracts.get("contracts", {}).items()):
        if owner_filter and owner not in owner_filter:
            continue
        if "generated_" in owner.lower():
            continue
        result_schema = source_symbols._contract_result_schema_name(owner, schemas, contract.get("return_keys", []))
        if result_schema is None:
            continue
        entry = schemas[result_schema]
        missing = [key for key in contract.get("return_keys", []) if key not in entry.get("keys", {})]
        if not missing:
            continue
        function = find_canonical_function(owner, missing)
        metadata = common_source_metadata(entry)
        source_file, source_method = metadata or ("", owner)
        for key in missing:
            identity = f"{owner}:{key}"
            if not function or not body_proves_key(function[2], key):
                unresolved.append(identity)
                continue
            value = body_value(function[2], key)
            evidence = upstream_evidence(source_file, key, value) if source_file else None
            input_schema = input_schema_for_key(catalog, result_schema, key) or contract_input_schema_for_key(catalog, contract, key)
            if input_schema:
                item = {
                    "type": "Variant",
                    "status": "generated",
                    "alias_of": f"{input_schema}.{key}",
                    "used_by": [owner.lower()],
                }
            elif evidence:
                item = {
                    "type": "Variant",
                    "status": "source-backed",
                    "java_source": source_file,
                    "java_method": source_method,
                    "java_expr": evidence,
                    "rule": f"Upstream evidence for canonical return key {key}.",
                    "used_by": [owner.lower()],
                }
            else:
                unresolved.append(identity)
                continue
            entry.setdefault("keys", {})[key] = item
            added.append(identity)
    if not dry_run:
        # Validate the complete in-memory catalog, then persist it once. Repeated
        # full-catalog writes make a large SSOT vulnerable to partial output.
        errors = source_symbols.validate_source_state_schema(catalog)
        if errors:
            raise ValueError("invalid reconciled state schema: " + "; ".join(errors))
        source_ssot.write_json(GODOT, "state_schema", catalog)
        for name in ("defense_slices", "defense_api_contracts"):
            if name in source_ssot.registered_module_names(GODOT):
                shard = source_ssot.build_extension_shard(GODOT, name)
                source_ssot.write_registered_json(GODOT, name, shard)
        source_symbols.write_source_symbol_audit_report(GODOT)
    return {"added": added, "unresolved": unresolved}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--owner", action="append", default=[])
    args = parser.parse_args()
    print(json.dumps(reconcile(args.dry_run, set(args.owner) or None), indent=2))


if __name__ == "__main__":
    main()
