from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java"
OWNER = "PortGame.source_tractor_beam_turret_build_update_tile_damage_pierce_state"
METHOD = "TractorBeamBuild.updateTile() damage pierce"


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


def alias(type_name: str, name: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "alias_of": f"source_tractor_beam_turret_build_update_tile_damage_pierce_input.{name}",
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    entry = catalog["schemas"]["source_tractor_beam_turret_build_update_tile_damage_pierce_result"]
    entry["keys"].update({
        "source_owner": source_key("String", "public void updateTile(){", "Canonical runtime owner marker."),
        "shoot_within_guard": alias("bool", "shoot_within_guard"),
        "target_after": alias("Variant", "target_after"),
        "damage": alias("float", "damage"),
        "eff": alias("float", "eff"),
        "time_scale": alias("float", "time_scale"),
        "rules_block_damage": alias("float", "rules_block_damage"),
        "team": alias("Variant", "team"),
        "damage_gate_evaluated": source_key("bool", "shootWithinGuard", "Evaluated damage-path guard."),
        "damage_gate": source_key("bool", "shootWithinGuard && damage > 0", "Damage execution gate."),
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_tractor_beam_turret_build_update_tile_damage_pierce_result", entry)
    for name in ("defense_slices", "defense_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
