from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/type/Weapon.java"
OWNER = "PortGame.source_weapon_bullet_geometry_state"
METHOD = "Weapon.bullet(Unit unit, WeaponMount mount, float xOffset, float yOffset, float angleOffset, Mover mover) geometry block"


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
    entry = catalog["schemas"]["source_weapon_bullet_geometry_result"]
    entry["keys"].update({
        "bulletContinues": alias("bool", "source_weapon_bullet_initial_guard_result.bulletContinues"),
        "mountCharging": alias("bool", "source_weapon_bullet_initial_guard_result.mountCharging"),
        "xSpreadSource": source_key("String", "xSpread = Mathf.range(xRand),", "Exact x spread source assignment."),
        "ySpreadSource": source_key("String", "ySpread = Mathf.range(yRand),", "Exact y spread source assignment."),
        "mathfRangeSource": source_key("String", "public static float range(float range){\n        return random(-range, range);\n    }", "Arc Mathf.range implementation used by spread.", "arc-core/src/arc/math/Mathf.java"),
        "weaponRotationSource": source_key("String", "weaponRotation = unit.rotation - 90 + (rotate ? mount.rotation : baseRotation),", "Exact weapon rotation assignment."),
        "mountXSource": source_key("String", "mountX = unit.x + Angles.trnsx(unit.rotation - 90, x, y),", "Exact mount X transform."),
        "mountYSource": source_key("String", "mountY = unit.y + Angles.trnsy(unit.rotation - 90, x, y),", "Exact mount Y transform."),
        "bulletXSource": source_key("String", "bulletX = mountX + Angles.trnsx(weaponRotation, this.shootX + xOffset + xSpread, this.shootY + yOffset + ySpread),", "Exact bullet X transform."),
        "bulletYSource": source_key("String", "bulletY = mountY + Angles.trnsy(weaponRotation, this.shootX + xOffset + xSpread, this.shootY + yOffset + ySpread),", "Exact bullet Y transform."),
        "anglesSource": source_key("String", "return rv.set(x, y).rotate(angle).x;", "Angles.trnsx/trnsy rotate the offset vector.", "arc-core/src/arc/math/Angles.java"),
        "shootAngleReservedSource": source_key("String", "shootAngle = bulletRotation(unit, mount, bulletX, bulletY) + angleOffset,", "Shoot angle is reserved for the following geometry block."),
    })
    source_symbols.upsert_source_state_schema(GODOT, "source_weapon_bullet_geometry_result", entry)
    for name in ("bullet_slices", "bullet_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
