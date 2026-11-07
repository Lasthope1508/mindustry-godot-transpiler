from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/defense/turrets/Turret.java"
OWNER = "PortGame.source_turret_set_stats_state"


def source_key(type_name: str, expression: str, rule: str) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": SOURCE,
        "java_method": "setStats()",
        "java_expr": expression,
        "rule": rule,
        "used_by": [OWNER.lower()],
    }


def input_alias(type_name: str, input_name: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "alias_of": f"source_turret_set_stats_input.{input_name}",
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    entry = catalog["schemas"]["source_turret_set_stats_result"]
    entry["keys"].update({
        "inaccuracy_stat_expr": source_key("String", "stats.add(Stat.inaccuracy, (int)inaccuracy, StatUnit.degrees);", "Inaccuracy stat expression."),
        "reload_stat_expr": source_key("String", "stats.add(Stat.reload, 60f / (reload + (!reloadWhileCharging ? shoot.firstShotDelay : 0f)) * shoot.shots, StatUnit.perSecond);", "Reload stat expression."),
        "targets_air_stat_expr": source_key("String", "stats.add(Stat.targetsAir, targetAir);", "Air targeting stat expression."),
        "targets_ground_stat_expr": source_key("String", "stats.add(Stat.targetsGround, targetGround);", "Ground targeting stat expression."),
        "ammo_use_guard_expr": source_key("String", "if(ammoPerShot != 1)", "Ammo-use stat guard."),
        "ammo_use_stat_expr": source_key("String", "stats.add(Stat.ammoUse, ammoPerShot, StatUnit.perShot);", "Ammo-use stat expression."),
        "input_heat_guard_expr": source_key("String", "if(heatRequirement > 0)", "Input heat stat guard."),
        "input_heat_stat_expr": source_key("String", "stats.add(Stat.input, heatRequirement, StatUnit.heatUnits);", "Input heat stat expression."),
        "max_efficiency_guard_expr": source_key("String", "if(heatRequirement > 0 && maxHeatEfficiency > 0)", "Maximum heat efficiency stat guard."),
        "max_efficiency_stat_expr": source_key("String", "stats.add(Stat.maxEfficiency, (int)(maxHeatEfficiency * 100f), StatUnit.percent);", "Maximum heat efficiency stat expression."),
        "inaccuracy_value": input_alias("float", "inaccuracy"),
        "reload_value": input_alias("float", "reload"),
        "reload_while_charging": input_alias("bool", "reload_while_charging"),
        "shoot_first_shot_delay": input_alias("float", "shoot_first_shot_delay"),
        "shoot_shots": input_alias("float", "shoot_shots"),
        "target_air": input_alias("bool", "target_air"),
        "target_ground": input_alias("bool", "target_ground"),
        "ammo_per_shot": input_alias("int", "ammo_per_shot"),
        "heat_requirement": input_alias("float", "heat_requirement"),
        "max_heat_efficiency": input_alias("float", "max_heat_efficiency"),
        "super_set_stats_called": source_key("bool", "super.setStats();", "Superclass setStats call is executed first."),
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_turret_set_stats_result", entry)
    for name in ("defense_slices", "defense_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
