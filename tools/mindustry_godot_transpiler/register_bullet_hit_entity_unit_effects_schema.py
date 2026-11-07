from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"
SOURCE = "core/src/mindustry/entities/bullet/BulletType.java"
OWNER = "PortGame.source_bullet_type_hit_entity_unit_effects_state"
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
    entry = catalog["schemas"]["hit_entity_unit_effects_result"]
    entry["keys"].update({
        "bulletType": alias("Dictionary", "bullet_type_state"),
        "bullet": alias("Dictionary", "bullet_state"),
        "entity": alias("Dictionary", "entity_state"),
        "armorDamage": alias("Dictionary", "hit_entity_armor_damage_result"),
        "destroyEventDeferred": source_key(
            "bool",
            "if(!wasDead && entity instanceof Unit unit && unit.dead){",
            "Destroy event remains deferred to the following hitEntity slice.",
        ),
        "pierceDeferred": source_key(
            "bool",
            "handlePierce(b, health, entity.x(), entity.y());",
            "Pierce handling remains deferred after Unit effects.",
        ),
        "unitGateSource": source_key(
            "String",
            "if(entity instanceof Unit unit){",
            "Exact Unit effects branch boundary.",
        ),
        "impulseVectorSource": source_key(
            "String",
            "Tmp.v3.set(unit).sub(b).nor().scl(knockback * 80f);",
            "Exact source impulse vector calculation.",
        ),
        "impactAngleSource": source_key(
            "String",
            "if(impact) Tmp.v3.setAngle(b.rotation() + (knockback < 0 ? 180f : 0f));",
            "Exact optional impact angle adjustment.",
        ),
        "unitImpulseSource": source_key(
            "String",
            "unit.impulse(Tmp.v3);",
            "Exact Unit impulse side effect.",
        ),
        "unitApplySource": source_key(
            "String",
            "unit.apply(status, statusDuration);",
            "Exact Unit status application side effect.",
        ),
        "bulletDamageEventSource": source_key(
            "String",
            "Events.fire(bulletDamageEvent.set(unit, b));",
            "Exact bullet damage event side effect.",
        ),
        "destroyEventBoundarySource": source_key(
            "String",
            "if(!wasDead && entity instanceof Unit unit && unit.dead){",
            "Exact downstream Unit destroy-event boundary.",
        ),
    })
    source_symbols.upsert_source_state_schema(GODOT, "hit_entity_unit_effects_result", entry)
    for name in ("bullet_slices", "bullet_api_contracts"):
        source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)


if __name__ == "__main__":
    main()
