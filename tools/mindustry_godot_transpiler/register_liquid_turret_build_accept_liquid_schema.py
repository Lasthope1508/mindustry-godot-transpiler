from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java"
OWNER = "PortGame.source_liquid_turret_build_accept_liquid_state"
METHOD = "LiquidTurretBuild.acceptLiquid(Building source, Liquid liquid)"


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
    entry = catalog["schemas"]["source_liquid_turret_build_accept_liquid_result"]
    entry["keys"].update({
        "source_owner": alias("String", OWNER.lower()),
        "inner_class": source_key("String", "public class LiquidTurretBuild extends TurretBuild{", "LiquidTurretBuild inner class boundary."),
        "override_expr": source_key("String", "@Override", "Override annotation."),
        "return_expr": source_key(
            "String",
            "return ammoTypes.get(liquid) != null && (liquids.current() == liquid || ((!ammoTypes.containsKey(liquids.current()) || liquids.get(liquids.current()) <= 1f / ammoTypes.get(liquids.current()).ammoMultiplier + 0.001f)));",
            "Exact acceptLiquid return condition.",
        ),
        "source_building": alias("Variant", "source_liquid_turret_build_accept_liquid_input.source_building"),
        "liquid": alias("Variant", "source_liquid_turret_build_accept_liquid_input.liquid"),
        "ammo_type": alias("Variant", "source_liquid_turret_build_accept_liquid_input.ammo_type"),
        "current_liquid": alias("Variant", "source_liquid_turret_build_accept_liquid_input.current_liquid"),
        "current_liquid_ammo_type_present": alias("bool", "source_liquid_turret_build_accept_liquid_input.current_liquid_ammo_type_present"),
        "current_liquid_amount": alias("float", "source_liquid_turret_build_accept_liquid_input.current_liquid_amount"),
        "current_ammo_multiplier": alias("float", "source_liquid_turret_build_accept_liquid_input.current_ammo_multiplier"),
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_liquid_turret_build_accept_liquid_result", entry)
    for name in ("defense_slices", "defense_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
