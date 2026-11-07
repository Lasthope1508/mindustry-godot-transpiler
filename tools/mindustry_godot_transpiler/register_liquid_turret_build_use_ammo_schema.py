from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java"
OWNER = "PortGame.source_liquid_turret_build_use_ammo_state"
METHOD = "LiquidTurretBuild.useAmmo()"


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
    entry = catalog["schemas"]["source_liquid_turret_build_use_ammo_result"]
    entry["keys"].update({
        "source_owner": alias("String", OWNER.lower()),
        "inner_class": source_key(
            "String",
            "public class LiquidTurretBuild extends TurretBuild{",
            "LiquidTurretBuild inner class boundary.",
        ),
        "override_expr": source_key("String", "@Override", "Override annotation."),
        "cheating_return_expr": source_key(
            "String",
            "if(cheating()) return ammoTypes.get(liquids.current());",
            "Cheating branch returns the current liquid ammo type without removal.",
        ),
        "type_lookup_expr": source_key(
            "String",
            "BulletType type = ammoTypes.get(liquids.current());",
            "Non-cheating ammo type lookup.",
        ),
        "remove_expr": source_key(
            "String",
            "liquids.remove(liquids.current(), 1f / type.ammoMultiplier);",
            "Non-cheating liquid consumption.",
        ),
        "return_expr": source_key("String", "return type;", "Non-cheating ammo return."),
        "cheating": alias("bool", "source_liquid_turret_build_use_ammo_input.cheating"),
        "current_liquid": alias("Variant", "source_liquid_turret_build_use_ammo_input.current_liquid"),
        "ammo_type": alias("Variant", "source_liquid_turret_build_use_ammo_input.ammo_type"),
        "ammo_multiplier": alias("float", "source_liquid_turret_build_use_ammo_input.ammo_multiplier"),
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_liquid_turret_build_use_ammo_result", entry)
    for name in ("defense_slices", "defense_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
