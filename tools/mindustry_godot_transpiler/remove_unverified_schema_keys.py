"""Remove entries created by unverified generic schema backfills."""

from pathlib import Path

from mindustry_port import source_ssot, source_symbols


GODOT = Path(__file__).resolve().parents[2] / "godot-mindustry"


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    removed = 0
    for entry in catalog["schemas"].values():
        keys = entry.get("keys", {})
        for key in list(keys):
            if str(keys[key].get("java_expr", "")).startswith(("canonical_state_return:", "canonical:", "canonical_gdscript:")):
                del keys[key]
                removed += 1
    errors = source_symbols.validate_source_state_schema(catalog)
    if errors:
        raise ValueError("invalid source state schema: " + "; ".join(errors))
    source_ssot.write_json(GODOT, "state_schema", catalog)
    for module in source_ssot.registered_modules(GODOT):
        if module.canonical_module == "state_schema":
            source_ssot.write_registered_json(GODOT, module.name, source_ssot.build_extension_shard(GODOT, module.name))
    print(f"removed_unverified_keys={removed}")


if __name__ == "__main__":
    main()
