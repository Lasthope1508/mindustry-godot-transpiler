from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/defense/turrets/ContinuousTurret.java"
OWNER = "PortGame.source_continuous_turret_set_stats_state"
METHOD = "ContinuousTurret.setStats()"


def source_key(type_name: str, expression: str, rule: str) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": SOURCE,
        "java_method": METHOD,
        "java_expr": expression,
        "rule": rule,
        "used_by": [OWNER.lower()],
    }


def input_alias(type_name: str, name: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "alias_of": f"source_continuous_turret_set_stats_input.{name}",
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    entry = catalog["schemas"]["source_continuous_turret_set_stats_result"]
    entry["keys"].update({
        "source_owner": source_key("String", "public void setStats(){", "Canonical runtime owner marker."),
        "stats_add_expr": source_key("String", "stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));", "Ammo stat expression."),
        "remove_reload_expr": source_key("String", "stats.remove(Stat.reload);", "Reload stat removal expression."),
        "remove_inaccuracy_expr": source_key("String", "stats.remove(Stat.inaccuracy);", "Inaccuracy stat removal expression."),
        "super_set_stats_called": source_key("bool", "super.setStats();", "Superclass stats call is executed."),
        "stats_add_called": source_key("bool", "stats.add(Stat.ammo, StatValues.ammo(ObjectMap.of(this, shootType)));", "Ammo stat call is executed."),
        "object_map_call": source_key("Dictionary", "ObjectMap.of(this, shootType)", "Ammo stat ObjectMap call state."),
        "ammo_values_call": source_key("Dictionary", "StatValues.ammo(ObjectMap.of(this, shootType))", "Ammo stat value call state."),
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_continuous_turret_set_stats_result", entry)
    for name in ("defense_slices", "defense_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
