from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/bullet/BulletType.java"
OWNER = "PortGame.source_bullet_type_hit_entity_damage_cap_state"
PROOF = "/root/Main.source_bullet_type_hit_entity_damage_cap_state"
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
    catalog = source_symbols.load_source_state_schema(GODOT)
    entry = catalog["schemas"]["hit_entity_damage_cap_result"]
    entry["keys"].update({
        "bulletType": alias("Dictionary", "bullet_type_state"),
        "bullet": alias("Dictionary", "bullet_state"),
        "entity": alias("Dictionary", "entity_state"),
        "hitEntity": alias("Dictionary", "hit_entity_state"),
        "maxDamageFraction": alias("float", "bullet_type_state.maxDamageFraction"),
        "lifestealDeferred": source_key("bool", "if(lifesteal > 0f && b.owner instanceof Healthc o){", "Lifesteal remains deferred to the following hitEntity slice."),
        "armorDamageDeferred": source_key("bool", "if(pierceArmor){", "Armor damage remains deferred to the following hitEntity slice."),
        "unitImpulseDeferred": source_key("bool", "if(entity instanceof Unit unit){", "Unit impulse remains deferred to the following hitEntity slice."),
        "pierceDeferred": source_key("bool", "handlePierce(b, health, entity.x(), entity.y());", "Pierce handling remains deferred after damage-cap processing."),
        "wasDeadSource": source_key("String", "boolean wasDead = entity instanceof Unit u && u.dead;", "Pre-hit unit death snapshot."),
        "healthcGateSource": source_key("String", "if(entity instanceof Healthc h){", "Healthc processing gate."),
        "damageSource": source_key("String", "float damage = b.damage;", "Initial bullet damage assignment."),
        "shieldSource": source_key("String", "float shield = entity instanceof Shieldc s ? Math.max(s.shield(), 0f) : 0f;", "Shield amount assignment."),
        "maxDamageFractionGateSource": source_key("String", "if(maxDamageFraction > 0){", "Maximum damage fraction gate."),
        "capSource": source_key("String", "float cap = h.maxHealth() * maxDamageFraction + shield;", "Effective damage cap assignment."),
        "damageCapSource": source_key("String", "damage = Math.min(damage, cap);", "Damage cap assignment."),
        "healthCapCommentSource": source_key("String", "//cap health to effective health for handlePierce to handle it properly", "Effective health cap comment."),
        "healthCapSource": source_key("String", "health = Math.min(health, cap);", "Effective health cap assignment."),
        "healthShieldSource": source_key("String", "health += shield", "Shield is added when the max damage fraction gate is not active."),
        "lifestealBoundarySource": source_key("String", "if(lifesteal > 0f && b.owner instanceof Healthc o){", "Downstream lifesteal boundary."),
    })
    source_symbols.upsert_source_state_schema(GODOT, "hit_entity_damage_cap_result", entry)
    for name in ("bullet_slices", "bullet_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
