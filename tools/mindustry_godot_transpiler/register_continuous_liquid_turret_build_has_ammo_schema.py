from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java"
OWNER = "PortGame.source_continuous_liquid_turret_build_has_ammo_state"
METHOD = "ContinuousLiquidTurretBuild.hasAmmo()"


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
    entry = catalog["schemas"]["source_continuous_liquid_turret_build_has_ammo_result"]
    entry["keys"].update({
        "source_owner": alias("String", OWNER.lower()),
        "inner_class": source_key(
            "String",
            "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{",
            "ContinuousLiquidTurretBuild inner class boundary.",
        ),
        "field": source_key("String", "boolean activated;", "Activated state field."),
        "override_expr": source_key("String", "@Override", "Override annotation."),
        "return_expr": source_key(
            "String",
            "return hasCorrectAmmo() && ammoTypes.get(liquids.current()) != null && liquids.currentAmount() > 0f && activated;",
            "Exact continuous turret hasAmmo condition.",
        ),
        "has_correct_ammo": alias("bool", "source_continuous_liquid_turret_build_has_ammo_input.has_correct_ammo"),
        "current_liquid": alias("Variant", "source_continuous_liquid_turret_build_has_ammo_input.current_liquid"),
        "ammo_type": alias("Variant", "source_continuous_liquid_turret_build_has_ammo_input.ammo_type"),
        "current_amount": alias("float", "source_continuous_liquid_turret_build_has_ammo_input.current_amount"),
        "activated": alias("bool", "source_continuous_liquid_turret_build_has_ammo_input.activated"),
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_continuous_liquid_turret_build_has_ammo_result", entry)
    for name in ("defense_slices", "defense_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
