from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/bullet/BulletType.java"
OWNER = "PortGame.source_bullet_type_hit_entity_armor_damage_state"
METHOD = "hitEntity(Bullet b, Hitboxc entity, float health)"


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
    source_symbols.upsert_source_state_schema(GODOT, "hit_entity_health_damage_call_result", {
        "status": "active",
        "owner": OWNER.lower(),
        "runtime_proof": "/root/Main.source_bullet_type_hit_entity_armor_damage_state",
        "keys": {
            "call": source_key("String", "h.damagePierce(damage)", "Selected Healthc damage call; armor multiplier and default branches use the corresponding source calls."),
            "damage": source_key("float", "damage", "Damage passed to the selected Healthc call."),
            "armorMultiplier": source_key("float", "armorMultiplier", "Only present in the armor multiplier call record."),
        },
    })
    catalog = source_symbols.load_source_state_schema(GODOT)
    entry = catalog["schemas"]["hit_entity_armor_damage_result"]
    entry["keys"].update({
        "bulletType": alias("Dictionary", "bullet_type_state"),
        "bullet": alias("Dictionary", "bullet_state"),
        "entity": alias("Dictionary", "entity_state"),
        "hitEntity": alias("Dictionary", "hit_entity_state"),
        "damageCap": alias("Dictionary", "hit_entity_damage_cap_result"),
        "lifesteal": alias("Dictionary", "hit_entity_lifesteal_result"),
        "unitImpulseDeferred": source_key("bool", "if(entity instanceof Unit unit){", "Unit effects remain deferred to the following hitEntity slice."),
        "pierceDeferred": source_key("bool", "handlePierce(b, health, entity.x(), entity.y());", "Pierce handling remains deferred after armor damage."),
        "healthcGateSource": source_key("String", "if(entity instanceof Healthc h){", "Healthc processing gate."),
        "damageLocalSource": source_key("String", "float damage = b.damage", "Local damage assignment boundary."),
        "pierceArmorSource": source_key("String", "if(pierceArmor){", "Pierce armor branch."),
        "damagePierceSource": source_key("String", "h.damagePierce(damage)", "Pierce armor damage call."),
        "armorMultiplierSource": source_key("String", "}else if(armorMultiplier != 1)", "Armor multiplier branch."),
        "damageArmorMultSource": source_key("String", "h.damageArmorMult(damage, armorMultiplier)", "Armor multiplier damage call."),
        "damageSource": source_key("String", "}else{\n                h.damage(damage);", "Default health damage branch exactly as laid out in upstream source."),
        "unitBoundarySource": source_key("String", "if(entity instanceof Unit unit){", "Unit effects boundary."),
    })
    entry["keys"]["damageGatePassed"] = source_key("bool", "}else{\n                h.damage(damage);", "Whether the source final else damage branch is selected." )
    entry["keys"]["healthDamageCall"] = alias("Dictionary|null", "hit_entity_health_damage_call_result")
    source_symbols.upsert_source_state_schema(GODOT, "hit_entity_armor_damage_result", entry)
    for name in ("bullet_slices", "bullet_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
