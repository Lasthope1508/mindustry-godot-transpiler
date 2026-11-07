from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = ROOT / "mindustry-upstream" / "core" / "src" / "mindustry" / "entities" / "comp" / "UnitComp.java"


def main() -> None:
    source_text = SOURCE.read_text(encoding="utf-8")
    ledger = source_symbols.load_source_slice_ledger(GODOT)["slices"]
    definitions = {
        "N1850": ("unit_set_prop_laccess_double.prop", "source_unit_set_prop_laccess_double_result.prop", "switch(prop){", "Property selector."),
        "N1851": ("unit_set_prop_laccess_object.prop", "source_unit_set_prop_laccess_object_result.prop", "switch(prop){", "Property selector."),
        "N1852": ("unit_set_prop_content.content", "source_unit_set_prop_content_result.content", "if(content instanceof Item item){", "Content type selector."),
    }
    entries = {}
    for slice_id, (symbol_name, godot_symbol, expression, rule) in definitions.items():
        slice_entry = ledger[slice_id]
        owner = slice_entry["godot_owner"]
        method = slice_entry["java_method"]
        if expression not in source_text:
            raise ValueError(f"canonical expression missing from UnitComp.java: {expression}")
        entries[symbol_name] = {
            "status": "source-backed",
            "godot_owner": owner,
            "godot_symbol": godot_symbol,
            "rule": rule,
            "tests": slice_entry["tests"],
            "runtime_proof": slice_entry["runtime_proof"],
            "java_source": slice_entry["java_source"],
            "java_method": method,
            "java_expr": expression,
        }

    source_symbols.upsert_source_symbols(GODOT, entries)
    # Domain symbol shards are virtual mirrors derived at read time from the registry.
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
