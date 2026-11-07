"""Register the remaining P1 return keys with explicit upstream evidence."""

from __future__ import annotations

from pathlib import Path

from mindustry_port import source_ssot, source_symbols


ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / "godot-mindustry"


def evidence(source: str, method: str, expression: str, type_name: str = "Variant") -> dict:
    return {
        "type": type_name,
        "status": "source-backed",
        "java_source": source,
        "java_method": method,
        "java_expr": expression,
        "rule": "Explicit upstream source evidence for the canonical return key.",
    }


def alias(target: str, type_name: str = "Variant") -> dict:
    return {"type": type_name, "status": "generated", "alias_of": target}


def main() -> None:
    catalog = source_symbols.load_source_state_schema(GODOT)
    schemas = catalog["schemas"]

    building = "core/src/mindustry/entities/comp/BuildingComp.java"
    block = "core/src/mindustry/world/Block.java"
    bullet = "core/src/mindustry/entities/bullet/BasicBulletType.java"
    consume_item = "core/src/mindustry/world/consumers/ConsumeItemFilter.java"
    consume_efficiency = "core/src/mindustry/world/consumers/ConsumeItemEfficiency.java"
    consume_liquid = "core/src/mindustry/world/consumers/ConsumeLiquidFilter.java"
    floor = "core/src/mindustry/world/blocks/environment/Floor.java"
    payload = "core/src/mindustry/world/blocks/payloads/BuildPayload.java"
    turret = "core/src/mindustry/world/blocks/defense/turrets/ContinuousLiquidTurret.java"
    liquid_turret = "core/src/mindustry/world/blocks/defense/turrets/LiquidTurret.java"
    tractor = "core/src/mindustry/world/blocks/defense/turrets/TractorBeamTurret.java"
    unit = "core/src/mindustry/entities/units/AIController.java"
    weapon = "core/src/mindustry/type/Weapon.java"

    updates = {
        "source_building_sleep_result": {
            "sleeping_after": evidence(building, "sleep()", "sleeping = true;", "bool"),
            "sleeping_entities_after": evidence(building, "sleep()", "sleepingEntities++;", "int"),
        },
        "source_building_no_sleep_result": {
            "sleeping_after": evidence(building, "noSleep()", "sleeping = false;", "bool"),
            "sleeping_entities_after": evidence(building, "noSleep()", "sleepingEntities--;", "int"),
        },
        "source_block_consume_generic_result": {
            "cons_power_expr": evidence(block, "consume(T consume)", "consPower = (ConsumePower)consume;"),
        },
        "source_block_post_init_shown_planets_result": {
            "shown_planets_comment": evidence(block, "postInit()", "//usually, an empty set of planets is a configuration error. auto-assign based on requirements", "String"),
            "content_planets_loop_expr": evidence(block, "postInit()", "for(Planet planet : content.planets())", "String"),
        },
        "source_bullet_texture_result": {
            "texture": evidence(bullet, "load()", "frontRegion = Core.atlas.find(sprite);", "Variant"),
        },
        "source_consume_item_efficiency_constructor_result": {
            "constructor": evidence(consume_efficiency, "ConsumeItemEfficiency(Boolf<Item> item)", "public ConsumeItemEfficiency(Boolf<Item> item){", "String"),
            "filter_assignment_expr": evidence(consume_efficiency, "ConsumeItemEfficiency(Boolf<Item> item)", "super(item);", "String"),
        },
        "source_consume_item_efficiency_default_constructor_result": {
            "filter_field": evidence(consume_efficiency, "ConsumeItemEfficiency()", "public ConsumeItemEfficiency(){", "String"),
        },
        "source_consume_item_filter_default_constructor_result": {
            "filter_field": evidence(consume_item, "ConsumeItemFilter()", "public Boolf<Item> filter = i -> false;", "String"),
        },
        "source_consume_liquid_filter_build_result": {
            "content_liquids_expr": evidence(consume_liquid, "build(Building build, Table table)", "Seq<Liquid> list = content.liquids().select", "String"),
        },
        "source_continuous_liquid_turret_set_stats_result": {
            "super_set_stats_called": evidence(turret, "setStats()", "super.setStats();", "bool"),
            "stats_replace_called": evidence(turret, "setStats()", "stats.replace(Stat.ammo, StatValues.ammo(ammoTypes));", "bool"),
        },
        "source_continuous_liquid_turret_build_get_ammo_content_result": {},
        "source_continuous_liquid_turret_build_should_active_sound_result": {},
        "source_dump_payload_state_result": {
            "returnTrue": evidence(payload, "dump()", "return true;", "bool"),
        },
        "source_floor_draw_main_result": {
            "autotile_bit_call": evidence(floor, "drawMain(Tile tile)", "int bit = TileBitmask.values[bits];", "String"),
        },
        "source_tractor_beam_turret_init_result": {
            "override_expr": evidence(tractor, "init()", "@Override", "String"),
            "super_init_called": evidence(tractor, "init()", "super.init();", "bool"),
            "update_clip_radius_call": evidence(tractor, "init()", "updateClipRadius(range + tilesize);", "String"),
        },
        "source_unit_after_read_result": {
            "controllerIsAIController": evidence(unit, "afterRead(Unit unit)", "controller instanceof AIController", "bool"),
            "aiKeepState": evidence(unit, "afterRead(Unit unit)", "ai.keepState()", "bool"),
        },
    }

    # Inner-class markers are one canonical source boundary shared by all
    # methods on the same generated turret build class.
    for schema_name in (
        "source_continuous_liquid_turret_build_get_ammo_content_result",
        "source_continuous_liquid_turret_build_should_active_sound_result",
    ):
        updates[schema_name]["inner_class"] = evidence(turret, "public class ContinuousLiquidTurretBuild", "public class ContinuousLiquidTurretBuild extends ContinuousTurretBuild{", "String")
    updates["source_continuous_liquid_turret_build_get_ammo_content_result"]["return_expr"] = evidence(turret, "getAmmoContent()", "return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;", "String")
    updates["source_continuous_liquid_turret_build_should_active_sound_result"]["return_expr"] = evidence(turret, "shouldActiveSound()", "return wasShooting && enabled;", "String")

    liquid_inner = "public class LiquidTurretBuild extends TurretBuild{"
    liquid_inner_entry = evidence(liquid_turret, "public class LiquidTurretBuild", liquid_inner, "String")
    updates.update({
        "source_liquid_turret_build_accept_item_result": {
            "inner_class": liquid_inner_entry,
            "return_expr": evidence(liquid_turret, "acceptItem(Building source, Item item)", "return false;", "String"),
        },
        "source_liquid_turret_build_get_ammo_content_result": {
            "inner_class": liquid_inner_entry,
            "return_expr": evidence(liquid_turret, "getAmmoContent()", "return liquids != null && liquids.currentAmount() > 0f ? liquids.current() : null;", "String"),
        },
        "source_liquid_turret_build_get_ammo_fraction_result": {
            "inner_class": liquid_inner_entry,
            "override_expr": evidence(liquid_turret, "getAmmoFraction()", "@Override", "String"),
            "return_expr": evidence(liquid_turret, "getAmmoFraction()", "return liquids.currentAmount() / liquidCapacity;", "String"),
        },
        "source_liquid_turret_build_sense_object_result": {
            "inner_class": liquid_inner_entry,
            "switch_return_expr": evidence(liquid_turret, "senseObject(LAccess sensor)", "return switch(sensor){", "String"),
        },
        "source_liquid_turret_build_should_active_sound_result": {
            "inner_class": liquid_inner_entry,
            "return_expr": evidence(liquid_turret, "shouldActiveSound()", "return wasShooting && enabled;", "String"),
        },
    })

    initial_guard = "source_weapon_bullet_initial_guard_result"
    for schema_name in (
        "source_weapon_update_always_continuous_keepalive_result",
        "source_weapon_update_auto_target_retarget_result",
        "source_weapon_update_bullet_origin_result",
    ):
        updates.setdefault(schema_name, {})
    for schema_name in (
        "source_weapon_bullet_angle_life_result",
        "source_weapon_bullet_create_call_result",
        "source_weapon_bullet_effects_result",
        "source_weapon_bullet_handle_call_result",
        "source_weapon_bullet_heat_result",
        "source_weapon_bullet_mount_recoil_result",
    ):
        updates.setdefault(schema_name, {})["bulletContinues"] = alias(f"{initial_guard}.bulletContinues", "bool")
    updates["source_weapon_bullet_angle_life_result"]["mountCharging"] = alias(f"{initial_guard}.mountCharging", "bool")
    updates["source_weapon_bullet_create_call_result"].update({
        "mountCharging": alias(f"{initial_guard}.mountCharging", "bool"),
        "mountBulletSetFromCreateCall": evidence(weapon, "Weapon.bullet(...)", "mount.bullet = bullet.create(...);", "bool"),
        "angleLifeState": evidence(weapon, "Weapon.bullet(...) angle/life block", "lifeScl = bullet.scaleLife ? Mathf.clamp(...);", "Dictionary"),
        "shooterState": evidence(weapon, "Weapon.bullet(...) shooter selection", "Entityc shooter = unit.controller() instanceof MissileAI ai ? ai.shooter : unit;", "Dictionary"),
    })
    updates["source_weapon_bullet_effects_result"].update({
        "weaponX": evidence(weapon, "Weapon.bullet(...) effects branch", "ejectEffect.at(mountX, mountY, angle * Mathf.sign(this.x));", "float"),
        "mathfSignSource": evidence(weapon, "Weapon.bullet(...) effects branch", "Mathf.sign(this.x)", "String"),
    })
    updates["source_weapon_update_always_continuous_keepalive_result"].update({
        "gate": evidence(weapon, "update(Unit unit, WeaponMount mount)", "if(alwaysContinuous && mount.shoot){", "bool"),
        "mountShoot": evidence(weapon, "update(Unit unit, WeaponMount mount)", "mount.shoot", "bool"),
    })
    updates["source_weapon_update_auto_target_retarget_result"]["retargetAfterDecrement"] = evidence(weapon, "update(Unit unit, WeaponMount mount)", "(mount.retarget -= Time.delta)", "float")
    updates["source_weapon_update_bullet_origin_result"].update({
        "mountX": alias("source_weapon_update_mount_origin_result.mountX", "float"),
        "mountY": alias("source_weapon_update_mount_origin_result.mountY", "float"),
    })

    for schema_name, keys in updates.items():
        if schema_name not in schemas:
            raise KeyError(f"missing canonical result schema: {schema_name}")
        schemas[schema_name].setdefault("keys", {}).update(keys)

    errors = source_symbols.validate_source_state_schema(catalog)
    if errors:
        raise ValueError("invalid state schema after P1 batch: " + "; ".join(errors))
    source_ssot.write_json(GODOT, "state_schema", catalog)
    for name in source_ssot.registered_module_names(GODOT):
        if name.endswith("_state_schema"):
            source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))
    source_symbols.write_source_symbol_audit_report(GODOT)
    print("registered", sum(len(keys) for keys in updates.values()), "return keys across", len(updates), "schemas")


if __name__ == "__main__":
    main()
