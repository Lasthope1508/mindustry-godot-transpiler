from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java"
OWNER = "PortGame.source_liquid_turret_build_find_target_extinguish_state"
METHOD = "LiquidTurretBuild.findTarget()"


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


def alias(type_name: str, target: str) -> dict:
    return {
        "type": type_name,
        "status": "generated",
        "alias_of": target,
        "used_by": [OWNER.lower()],
    }


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    entry = catalog["schemas"]["source_liquid_turret_build_find_target_extinguish_result"]
    entry["keys"].update({
        "source_owner": alias("String", OWNER.lower()),
        "inner_class": source_key(
            "String",
            "public class LiquidTurretBuild extends TurretBuild{",
            "LiquidTurretBuild inner class boundary.",
        ),
        "override_expr": source_key("String", "@Override", "Override annotation."),
        "guard_expr": source_key(
            "String",
            "if(extinguish && liquids.current().canExtinguish()){",
            "Exact extinguish-fire scan guard.",
        ),
        "result_init_expr": source_key(
            "String",
            "Fire result = null;",
            "Fire target result initialization.",
        ),
        "assign_expr": source_key(
            "String",
            "target = result;",
            "Target assignment after a fire result is found.",
        ),
        "return_expr": source_key("String", "return;", "Early return after assigning a fire target."),
        "super_find_target_expr": source_key(
            "String",
            "super.findTarget();",
            "Fallback turret target scan.",
        ),
        "extinguish": alias(
            "bool",
            "source_liquid_turret_build_find_target_extinguish_input.extinguish",
        ),
        "current_liquid_can_extinguish": alias(
            "bool",
            "source_liquid_turret_build_find_target_extinguish_input.current_liquid_can_extinguish",
        ),
        "fire_result": alias(
            "Variant",
            "source_liquid_turret_build_find_target_extinguish_input.fire_result",
        ),
        "target_assigned": source_key(
            "bool",
            "target = result;",
            "Runtime target-assignment state from the source branch.",
        ),
    })
    source_symbols.upsert_source_state_schema(
        GODOT,
        "source_liquid_turret_build_find_target_extinguish_result",
        entry,
    )
    for name in ("defense_slices", "defense_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
