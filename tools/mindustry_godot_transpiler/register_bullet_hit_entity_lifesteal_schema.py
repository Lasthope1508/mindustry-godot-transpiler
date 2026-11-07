from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/bullet/BulletType.java"
OWNER = "PortGame.source_bullet_type_hit_entity_lifesteal_state"
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
    entry = catalog["schemas"]["hit_entity_lifesteal_result"]
    entry["keys"].update({
        "bulletType": alias("Dictionary", "bullet_type_state"),
        "bullet": alias("Dictionary", "bullet_state"),
        "entity": alias("Dictionary", "entity_state"),
        "hitEntity": alias("Dictionary", "hit_entity_state"),
        "damageCap": alias("Dictionary", "hit_entity_damage_cap_result"),
        "ownerHealth": alias("Dictionary", "owner_health_state"),
        "armorDamageDeferred": source_key(
            "bool",
            "if(pierceArmor){",
            "Armor damage remains deferred to the following hitEntity slice.",
        ),
        "unitImpulseDeferred": source_key(
            "bool",
            "if(entity instanceof Unit unit){",
            "Unit effects remain deferred to the following hitEntity slice.",
        ),
        "pierceDeferred": source_key(
            "bool",
            "handlePierce(b, health, entity.x(), entity.y());",
            "Pierce handling remains deferred after hitEntity processing.",
        ),
        "healthcGateSource": source_key(
            "String",
            "if(entity instanceof Healthc h){",
            "Healthc processing gate.",
        ),
        "lifestealBoundarySource": source_key(
            "String",
            "if(lifesteal > 0f && b.owner instanceof Healthc o){",
            "Exact lifesteal branch boundary.",
        ),
        "lifestealResultSource": source_key(
            "String",
            "float result = Math.max(Math.min(h.health(), damage), 0);",
            "Exact source lifesteal result clamp.",
        ),
        "ownerHealSource": source_key(
            "String",
            "o.heal(result * lifesteal);",
            "Exact owner heal side effect.",
        ),
        "pierceArmorBoundarySource": source_key(
            "String",
            "if(pierceArmor){",
            "Armor damage branch follows lifesteal in the source method.",
        ),
    })
    source_symbols.upsert_source_state_schema(GODOT, "hit_entity_lifesteal_result", entry)
    for name in ("bullet_slices", "bullet_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
