from pathlib import Path

from mindustry_port import source_ssot, source_symbols


GODOT = Path(__file__).resolve().parents[2] / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java"
OWNER = "PortGame.source_tractor_beam_turret_set_stats_state"
METHOD = "TractorBeamTurret.setStats()"


def item(type_name: str, expression: str, rule: str) -> dict:
    return {"type": type_name, "status": "source-backed", "java_source": SOURCE, "java_method": METHOD, "java_expr": expression, "rule": rule, "used_by": [OWNER.lower()]}


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    entry = catalog["schemas"]["source_tractor_beam_turret_set_stats_result"]
    entry["keys"].update({
        "super_set_stats_called": item("bool", "super.setStats();", "Superclass setStats call is executed."),
        "targets_air_stat_call": item("Dictionary", "stats.add(Stat.targetsAir, targetAir);", "Air targeting stat call state."),
        "targets_ground_stat_call": item("Dictionary", "stats.add(Stat.targetsGround, targetGround);", "Ground targeting stat call state."),
        "damage_stat_call": item("Dictionary", "stats.add(Stat.damage, damage * 60f, StatUnit.perSecond);", "Damage stat call state."),
    })
    errors = source_symbols.validate_source_state_schema(catalog)
    if errors:
        raise ValueError("invalid source state schema: " + "; ".join(errors))
    source_ssot.write_json(GODOT, "state_schema", catalog)
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
