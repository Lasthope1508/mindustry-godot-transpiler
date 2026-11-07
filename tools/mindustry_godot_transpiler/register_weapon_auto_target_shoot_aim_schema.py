from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/type/Weapon.java"
OWNER = "PortGame.source_weapon_update_auto_target_shoot_aim_state"
METHOD = "Weapon.update(Unit unit, WeaponMount mount) auto target shoot aim"


def source_key(type_name: str, expression: str, rule: str, java_source: str = SOURCE) -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": java_source,
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
    entry = catalog["schemas"]["source_weapon_update_auto_target_shoot_aim_result"]
    entry["keys"].update({
        "targetExists": source_key("bool", "mount.target != null", "Target guard state."),
        "withinRange": source_key("float", "bullet.range + Math.abs(shootY) + (mount.target instanceof Sized s ? s.hitSize()/2f : 0f)", "Effective target range used by within()."),
        "targetWithin": source_key("bool", "mount.target.within(mountX, mountY, bullet.range + Math.abs(shootY) + (mount.target instanceof Sized s ? s.hitSize()/2f : 0f))", "Target within check result."),
        "canShoot": alias("bool", "source_weapon_update_auto_target_shoot_aim_input.can_shoot"),
        "predictTarget": alias("bool", "source_weapon_update_auto_target_shoot_aim_input.weapon_state.predictTarget"),
        "mountX": alias("float", "source_weapon_update_auto_target_shoot_aim_input.mount_x"),
        "mountY": alias("float", "source_weapon_update_auto_target_shoot_aim_input.mount_y"),
        "withinSource": source_key("String", "mount.target.within(mountX, mountY, bullet.range + Math.abs(shootY) + (mount.target instanceof Sized s ? s.hitSize()/2f : 0f))", "Exact target within source expression."),
        "predictGuardSource": source_key("String", "if(predictTarget){", "Predictive aim branch guard."),
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_weapon_update_auto_target_shoot_aim_result", entry)
    source_ssot.write_registered_json(GODOT, "type_slices", source_ssot.build_extension_shard(GODOT, "type_slices"))
    source_ssot.write_registered_json(GODOT, "type_api_contracts", source_ssot.build_extension_shard(GODOT, "type_api_contracts"))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
