import unittest
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools" / "mindustry_godot_transpiler"))

from mindustry_port import source_symbols


class SourceSymbolRegistryTests(unittest.TestCase):
    def test_draw_parts_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])
        self.assertEqual(registry["version"], 1)

        fin_entry = source_symbols.source_symbol(registry, "bullet.fin")
        self.assertEqual(fin_entry["status"], "explicit-input")
        self.assertEqual(fin_entry["java_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(fin_entry["java_method"], "drawParts(Bullet b)")
        self.assertEqual(fin_entry["java_expr"], "b.fin()")
        self.assertEqual(fin_entry["godot_owner"], "PortGame.source_bullet_type_draw_parts_state")
        self.assertIn("test_bullet_type_draw_parts_state_matches_upstream_source", fin_entry["tests"])

        warmup_entry = source_symbols.source_symbol(registry, "draw_part.params.warmup")
        self.assertEqual(warmup_entry["status"], "source-backed")
        self.assertEqual(warmup_entry["java_expr"], "DrawPart.params.set(b.fin(), 0f, 0f, 0f, 0f, 0f, b.x, b.y, b.rotation()).warmup")
        self.assertEqual(warmup_entry["godot_symbol"], "partParams.warmup")
        self.assertEqual(warmup_entry["runtime_proof"], "/root/Main.source_bullet_type_draw_parts_state")

    def test_source_symbol_registry_rejects_unbacked_source_symbols(self):
        registry = {
            "version": 1,
            "symbols": {
                "bad.symbol": {
                    "status": "source-backed",
                    "godot_symbol": "bad",
                    "godot_owner": "PortGame.bad",
                    "rule": "bad",
                    "tests": [],
                    "runtime_proof": "/root/Main.bad",
                }
            },
        }

        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertIn("bad.symbol: source-backed requires java_source", errors)
        self.assertIn("bad.symbol: source-backed requires java_method", errors)
        self.assertIn("bad.symbol: source-backed requires java_expr", errors)

    def test_test_collision_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        bullet_team = source_symbols.source_symbol(registry, "test_collision.bullet.team")
        self.assertEqual(bullet_team["java_expr"], "bullet.team")
        self.assertEqual(bullet_team["godot_symbol"], "bullet_state.team")
        self.assertEqual(bullet_team["godot_owner"], "PortGame.source_bullet_type_test_collision_state")

        tile_health = source_symbols.source_symbol(registry, "test_collision.tile.healthf")
        self.assertEqual(tile_health["status"], "explicit-input")
        self.assertEqual(tile_health["java_expr"], "tile.healthf()")
        self.assertEqual(tile_health["runtime_proof"], "/root/Main.source_bullet_type_test_collision_state")

    def test_hit_tile_heal_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        heal_gate = source_symbols.source_symbol(registry, "hit_tile.heal_gate")
        self.assertEqual(heal_gate["java_expr"], "heals() && build.team == b.team && !(build.block instanceof ConstructBlock)")
        self.assertEqual(heal_gate["godot_owner"], "PortGame.source_bullet_type_hit_tile_heal_state")
        self.assertEqual(heal_gate["runtime_proof"], "/root/Main.source_bullet_type_hit_tile_heal_state")

        heal_amount = source_symbols.source_symbol(registry, "hit_tile.heal_amount_formula")
        self.assertEqual(heal_amount["java_expr"], "healPercent / 100f * build.maxHealth + healAmount")
        self.assertEqual(heal_amount["godot_symbol"], "hit_tile_heal_result.healAppliedAmount")

    def test_hit_tile_fire_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        fire_gate = source_symbols.source_symbol(registry, "hit_tile.fire_gate")
        self.assertEqual(fire_gate["java_expr"], "makeFire && build.team != b.team")
        self.assertEqual(fire_gate["godot_owner"], "PortGame.source_bullet_type_hit_tile_fire_state")
        self.assertEqual(fire_gate["runtime_proof"], "/root/Main.source_bullet_type_hit_tile_fire_state")

        build_tile = source_symbols.source_symbol(registry, "hit_tile.build.tile")
        self.assertEqual(build_tile["java_expr"], "build.tile")
        self.assertEqual(build_tile["godot_symbol"], "build_state.tile")

    def test_hit_tile_enemy_direct_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        enemy_gate = source_symbols.source_symbol(registry, "hit_tile.enemy_direct_gate")
        self.assertEqual(enemy_gate["java_expr"], "build.team != b.team && direct")
        self.assertEqual(enemy_gate["godot_owner"], "PortGame.source_bullet_type_hit_tile_enemy_direct_state")
        self.assertEqual(enemy_gate["runtime_proof"], "/root/Main.source_bullet_type_hit_tile_enemy_direct_state")

        direct = source_symbols.source_symbol(registry, "hit_tile.direct")
        self.assertEqual(direct["status"], "explicit-input")
        self.assertEqual(direct["godot_symbol"], "hit_tile_state.direct")

    def test_hit_tile_lifesteal_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        lifesteal_gate = source_symbols.source_symbol(registry, "hit_tile.lifesteal_gate")
        self.assertEqual(lifesteal_gate["java_expr"], "lifesteal > 0f && b.owner instanceof Healthc o")
        self.assertEqual(lifesteal_gate["godot_owner"], "PortGame.source_bullet_type_hit_tile_lifesteal_state")
        self.assertEqual(lifesteal_gate["runtime_proof"], "/root/Main.source_bullet_type_hit_tile_lifesteal_state")

        owner_is_healthc = source_symbols.source_symbol(registry, "hit_tile.owner.is_healthc")
        self.assertEqual(owner_is_healthc["status"], "explicit-input")
        self.assertEqual(owner_is_healthc["godot_symbol"], "owner_health_state.isHealthc")

        lifesteal_result = source_symbols.source_symbol(registry, "hit_tile.lifesteal_result")
        self.assertEqual(lifesteal_result["java_expr"], "Math.max(Math.min(build.health, damage), 0)")
        self.assertEqual(lifesteal_result["godot_symbol"], "hit_tile_lifesteal_result.lifestealResult")

    def test_handle_pierce_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        sub = source_symbols.source_symbol(registry, "handle_pierce.sub")
        self.assertEqual(sub["java_expr"], "Mathf.zero(pierceDamageFactor) ? 0f : Math.max(initialHealth * pierceDamageFactor, 0)")
        self.assertEqual(sub["godot_owner"], "PortGame.source_bullet_type_handle_pierce_state")
        self.assertEqual(sub["runtime_proof"], "/root/Main.source_bullet_type_handle_pierce_state")

        damage_subtract = source_symbols.source_symbol(registry, "handle_pierce.damage_subtract")
        self.assertEqual(damage_subtract["java_expr"], "Float.isNaN(sub) ? b.damage : Math.min(b.damage, sub)")
        self.assertEqual(damage_subtract["godot_symbol"], "handle_pierce_result.damageSubtract")

        initial_health = source_symbols.source_symbol(registry, "handle_pierce.initial_health")
        self.assertEqual(initial_health["status"], "explicit-input")
        self.assertEqual(initial_health["godot_symbol"], "pierce_state.initialHealth")

    def test_hit_entity_damage_cap_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        damage = source_symbols.source_symbol(registry, "hit_entity.damage")
        self.assertEqual(damage["java_expr"], "b.damage")
        self.assertEqual(damage["godot_owner"], "PortGame.source_bullet_type_hit_entity_damage_cap_state")
        self.assertEqual(damage["runtime_proof"], "/root/Main.source_bullet_type_hit_entity_damage_cap_state")

        shield = source_symbols.source_symbol(registry, "hit_entity.shield")
        self.assertEqual(shield["java_expr"], "entity instanceof Shieldc s ? Math.max(s.shield(), 0f) : 0f")
        self.assertEqual(shield["godot_symbol"], "hit_entity_damage_cap_result.shield")

        cap = source_symbols.source_symbol(registry, "hit_entity.cap")
        self.assertEqual(cap["java_expr"], "h.maxHealth() * maxDamageFraction + shield")
        self.assertEqual(cap["godot_symbol"], "hit_entity_damage_cap_result.cap")

        entity_health = source_symbols.source_symbol(registry, "hit_entity.health")
        self.assertEqual(entity_health["status"], "explicit-input")
        self.assertEqual(entity_health["godot_symbol"], "hit_entity_state.health")

    def test_hit_entity_lifesteal_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        lifesteal_gate = source_symbols.source_symbol(registry, "hit_entity.lifesteal_gate")
        self.assertEqual(lifesteal_gate["java_expr"], "lifesteal > 0f && b.owner instanceof Healthc o")
        self.assertEqual(lifesteal_gate["godot_owner"], "PortGame.source_bullet_type_hit_entity_lifesteal_state")
        self.assertEqual(lifesteal_gate["runtime_proof"], "/root/Main.source_bullet_type_hit_entity_lifesteal_state")

        entity_health = source_symbols.source_symbol(registry, "hit_entity.entity.health")
        self.assertEqual(entity_health["java_expr"], "h.health()")
        self.assertEqual(entity_health["godot_symbol"], "entity_state.health")

        lifesteal_result = source_symbols.source_symbol(registry, "hit_entity.lifesteal_result")
        self.assertEqual(lifesteal_result["java_expr"], "Math.max(Math.min(h.health(), damage), 0)")
        self.assertEqual(lifesteal_result["godot_symbol"], "hit_entity_lifesteal_result.lifestealResult")

        owner_heal = source_symbols.source_symbol(registry, "hit_entity.owner_heal")
        self.assertEqual(owner_heal["java_expr"], "o.heal(result * lifesteal)")
        self.assertEqual(owner_heal["godot_symbol"], "hit_entity_lifesteal_result.ownerHealCalled")

    def test_hit_entity_armor_damage_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        pierce_armor = source_symbols.source_symbol(registry, "hit_entity.pierce_armor")
        self.assertEqual(pierce_armor["java_expr"], "pierceArmor")
        self.assertEqual(pierce_armor["godot_symbol"], "bullet_type_state.pierceArmor")
        self.assertEqual(pierce_armor["godot_owner"], "PortGame.source_bullet_type_hit_entity_armor_damage_state")
        self.assertEqual(pierce_armor["runtime_proof"], "/root/Main.source_bullet_type_hit_entity_armor_damage_state")

        armor_multiplier = source_symbols.source_symbol(registry, "hit_entity.armor_multiplier")
        self.assertEqual(armor_multiplier["java_expr"], "armorMultiplier")
        self.assertEqual(armor_multiplier["godot_symbol"], "bullet_type_state.armorMultiplier")

        damage_pierce_call = source_symbols.source_symbol(registry, "hit_entity.damage_pierce_call")
        self.assertEqual(damage_pierce_call["java_expr"], "h.damagePierce(damage)")
        self.assertEqual(damage_pierce_call["godot_symbol"], "hit_entity_armor_damage_result.damagePierceCalled")

        damage_armor_mult_call = source_symbols.source_symbol(registry, "hit_entity.damage_armor_mult_call")
        self.assertEqual(damage_armor_mult_call["java_expr"], "h.damageArmorMult(damage, armorMultiplier)")
        self.assertEqual(damage_armor_mult_call["godot_symbol"], "hit_entity_armor_damage_result.damageArmorMultCalled")

        damage_call = source_symbols.source_symbol(registry, "hit_entity.damage_call")
        self.assertEqual(damage_call["java_expr"], "h.damage(damage)")
        self.assertEqual(damage_call["godot_symbol"], "hit_entity_armor_damage_result.damageCalled")

    def test_hit_entity_unit_effects_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        unit_gate = source_symbols.source_symbol(registry, "hit_entity.unit_gate")
        self.assertEqual(unit_gate["java_expr"], "entity instanceof Unit unit")
        self.assertEqual(unit_gate["godot_owner"], "PortGame.source_bullet_type_hit_entity_unit_effects_state")
        self.assertEqual(unit_gate["runtime_proof"], "/root/Main.source_bullet_type_hit_entity_unit_effects_state")

        knockback = source_symbols.source_symbol(registry, "hit_entity.knockback")
        self.assertEqual(knockback["java_expr"], "knockback")
        self.assertEqual(knockback["godot_symbol"], "bullet_type_state.knockback")

        impact = source_symbols.source_symbol(registry, "hit_entity.impact")
        self.assertEqual(impact["java_expr"], "impact")
        self.assertEqual(impact["godot_symbol"], "bullet_type_state.impact")

        impulse = source_symbols.source_symbol(registry, "hit_entity.unit_impulse_call")
        self.assertEqual(impulse["java_expr"], "unit.impulse(Tmp.v3)")
        self.assertEqual(impulse["godot_symbol"], "hit_entity_unit_effects_result.impulseCalled")

        apply_status = source_symbols.source_symbol(registry, "hit_entity.unit_apply_status")
        self.assertEqual(apply_status["java_expr"], "unit.apply(status, statusDuration)")
        self.assertEqual(apply_status["godot_symbol"], "hit_entity_unit_effects_result.statusApplyCalled")

        event = source_symbols.source_symbol(registry, "hit_entity.bullet_damage_event")
        self.assertEqual(event["java_expr"], "Events.fire(bulletDamageEvent.set(unit, b))")
        self.assertEqual(event["godot_symbol"], "hit_entity_unit_effects_result.bulletDamageEventFired")

    def test_hit_entity_unit_destroy_event_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        was_dead = source_symbols.source_symbol(registry, "hit_entity.was_dead")
        self.assertEqual(was_dead["godot_symbol"], "hit_entity_damage_cap_result.wasDead")

        unit_dead = source_symbols.source_symbol(registry, "hit_entity.entity.unit_dead")
        self.assertEqual(unit_dead["godot_symbol"], "entity_state.unitDead")

        destroy_gate = source_symbols.source_symbol(registry, "hit_entity.unit_destroy_gate")
        self.assertEqual(destroy_gate["java_expr"], "!wasDead && entity instanceof Unit unit && unit.dead")
        self.assertEqual(destroy_gate["godot_owner"], "PortGame.source_bullet_type_hit_entity_unit_destroy_event_state")
        self.assertEqual(destroy_gate["runtime_proof"], "/root/Main.source_bullet_type_hit_entity_unit_destroy_event_state")

        event = source_symbols.source_symbol(registry, "hit_entity.unit_destroy_event")
        self.assertEqual(event["java_expr"], "Events.fire(new UnitBulletDestroyEvent(unit, b))")
        self.assertEqual(event["godot_symbol"], "hit_entity_unit_destroy_event_result.unitDestroyEventFired")

    def test_hit_entity_handle_pierce_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        handle_call = source_symbols.source_symbol(registry, "hit_entity.handle_pierce_call")
        self.assertEqual(handle_call["java_expr"], "handlePierce(b, health, entity.x(), entity.y())")
        self.assertEqual(handle_call["godot_owner"], "PortGame.source_bullet_type_hit_entity_handle_pierce_state")
        self.assertEqual(handle_call["runtime_proof"], "/root/Main.source_bullet_type_hit_entity_handle_pierce_state")

        initial_health = source_symbols.source_symbol(registry, "hit_entity.handle_pierce_initial_health")
        self.assertEqual(initial_health["java_expr"], "health")
        self.assertEqual(initial_health["godot_symbol"], "pierce_state.initialHealth")

    def test_bullet_type_damage_multiplier_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        unit_branch = source_symbols.source_symbol(registry, "damage_multiplier.unit_branch")
        self.assertEqual(unit_branch["java_expr"], "b.owner instanceof Unit u")
        self.assertEqual(unit_branch["godot_owner"], "PortGame.source_bullet_type_damage_multiplier_state")
        self.assertEqual(unit_branch["runtime_proof"], "/root/Main.source_bullet_type_damage_multiplier_state")

        unit_result = source_symbols.source_symbol(registry, "damage_multiplier.unit_result")
        self.assertEqual(unit_result["java_expr"], "u.damageMultiplier() * state.rules.unitDamage(b.team)")
        self.assertEqual(unit_result["godot_symbol"], "damage_multiplier_result.damageMultiplier")

        building_result = source_symbols.source_symbol(registry, "damage_multiplier.building_result")
        self.assertEqual(building_result["java_expr"], "state.rules.blockDamage(b.team)")
        self.assertEqual(building_result["godot_symbol"], "damage_multiplier_result.damageMultiplier")

        fallback = source_symbols.source_symbol(registry, "damage_multiplier.fallback")
        self.assertEqual(fallback["java_expr"], "return 1f")
        self.assertEqual(fallback["godot_symbol"], "damage_multiplier_result.damageMultiplier")

    def test_bullet_type_hit_default_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        hit_call = source_symbols.source_symbol(registry, "hit.default_call")
        self.assertEqual(hit_call["java_expr"], "hit(b, b.x, b.y, true)")
        self.assertEqual(hit_call["godot_owner"], "PortGame.source_bullet_type_hit_default_state")
        self.assertEqual(hit_call["runtime_proof"], "/root/Main.source_bullet_type_hit_default_state")

        create_frags = source_symbols.source_symbol(registry, "hit.default_create_frags")
        self.assertEqual(create_frags["java_expr"], "true")
        self.assertEqual(create_frags["godot_symbol"], "hit_default_result.createFrags")

    def test_bullet_type_hit_xy_default_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        hit_call = source_symbols.source_symbol(registry, "hit.xy_default_call")
        self.assertEqual(hit_call["java_expr"], "hit(b, x, y, true)")
        self.assertEqual(hit_call["godot_owner"], "PortGame.source_bullet_type_hit_xy_default_state")
        self.assertEqual(hit_call["runtime_proof"], "/root/Main.source_bullet_type_hit_xy_default_state")

        hit_x = source_symbols.source_symbol(registry, "hit.xy_default_x")
        self.assertEqual(hit_x["java_expr"], "x")
        self.assertEqual(hit_x["godot_symbol"], "hit_xy_state.x")

        create_frags = source_symbols.source_symbol(registry, "hit.xy_default_create_frags")
        self.assertEqual(create_frags["java_expr"], "true")
        self.assertEqual(create_frags["godot_symbol"], "hit_xy_default_result.createFrags")

    def test_bullet_type_hit_effects_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        hit_effect = source_symbols.source_symbol(registry, "hit.effects.hit_effect_call")
        self.assertEqual(hit_effect["java_expr"], "hitEffect.at(x, y, b.rotation(), hitColor)")
        self.assertEqual(hit_effect["godot_owner"], "PortGame.source_bullet_type_hit_effects_state")
        self.assertEqual(hit_effect["runtime_proof"], "/root/Main.source_bullet_type_hit_effects_state")

        hit_sound = source_symbols.source_symbol(registry, "hit.effects.hit_sound_call")
        self.assertEqual(hit_sound["java_expr"], "hitSound.at(x, y, hitSoundPitch + Mathf.range(hitSoundPitchRange), hitSoundVolume)")
        self.assertEqual(hit_sound["godot_symbol"], "hit_effects_result.hitSoundCall")

        shake_call = source_symbols.source_symbol(registry, "hit.effects.shake_call")
        self.assertEqual(shake_call["java_expr"], "Effect.shake(hitShake, hitShake, b)")
        self.assertEqual(shake_call["godot_symbol"], "hit_effects_result.shakeCall")

    def test_bullet_type_hit_frag_dispatch_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        frag_gate = source_symbols.source_symbol(registry, "hit.frag_dispatch.frag_gate")
        self.assertEqual(frag_gate["java_expr"], "createFrags && fragOnHit")
        self.assertEqual(frag_gate["godot_owner"], "PortGame.source_bullet_type_hit_frag_dispatch_state")
        self.assertEqual(frag_gate["runtime_proof"], "/root/Main.source_bullet_type_hit_frag_dispatch_state")

        delay_gate = source_symbols.source_symbol(registry, "hit.frag_dispatch.delay_gate")
        self.assertEqual(delay_gate["java_expr"], "delayFrags && fragBullet != null && fragBullet.delayFrags")
        self.assertEqual(delay_gate["godot_symbol"], "hit_frag_dispatch_result.delayFragGatePassed")

        time_run = source_symbols.source_symbol(registry, "hit.frag_dispatch.time_run_call")
        self.assertEqual(time_run["java_expr"], "Time.run(0f, () -> createFrags(b, x, y))")
        self.assertEqual(time_run["godot_symbol"], "hit_frag_dispatch_result.timeRunCall")

        direct_call = source_symbols.source_symbol(registry, "hit.frag_dispatch.create_frags_call")
        self.assertEqual(direct_call["java_expr"], "createFrags(b, x, y)")
        self.assertEqual(direct_call["godot_symbol"], "hit_frag_dispatch_result.createFragsCall")

    def test_bullet_type_hit_post_frag_dispatch_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        puddles_call = source_symbols.source_symbol(registry, "hit.post_frag_dispatch.create_puddles_call")
        self.assertEqual(puddles_call["java_expr"], "createPuddles(b, x, y)")
        self.assertEqual(puddles_call["godot_owner"], "PortGame.source_bullet_type_hit_post_frag_dispatch_state")
        self.assertEqual(puddles_call["runtime_proof"], "/root/Main.source_bullet_type_hit_post_frag_dispatch_state")

        incend_call = source_symbols.source_symbol(registry, "hit.post_frag_dispatch.create_incend_call")
        self.assertEqual(incend_call["java_expr"], "createIncend(b, x, y)")
        self.assertEqual(incend_call["godot_symbol"], "hit_post_frag_dispatch_result.createIncendCall")

        units_call = source_symbols.source_symbol(registry, "hit.post_frag_dispatch.create_units_call")
        self.assertEqual(units_call["java_expr"], "createUnits(b, x, y)")
        self.assertEqual(units_call["godot_symbol"], "hit_post_frag_dispatch_result.createUnitsCall")

    def test_bullet_type_hit_suppression_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        suppression_range = source_symbols.source_symbol(registry, "hit.suppression.range")
        self.assertEqual(suppression_range["java_expr"], "suppressionRange")
        self.assertEqual(suppression_range["godot_symbol"], "bullet_type_state.suppressionRange")
        self.assertEqual(suppression_range["godot_owner"], "PortGame.source_bullet_type_hit_suppression_state")
        self.assertEqual(suppression_range["runtime_proof"], "/root/Main.source_bullet_type_hit_suppression_state")

        suppression_gate = source_symbols.source_symbol(registry, "hit.suppression.gate")
        self.assertEqual(suppression_gate["java_expr"], "suppressionRange > 0")
        self.assertEqual(suppression_gate["godot_symbol"], "hit_suppression_result.suppressionGatePassed")

        apply_suppression = source_symbols.source_symbol(registry, "hit.suppression.apply_call")
        self.assertEqual(apply_suppression["java_expr"], "Damage.applySuppression(b.team, b.x, b.y, suppressionRange, suppressionDuration, 0f, suppressionEffectChance, new Vec2(b.x, b.y), suppressColor)")
        self.assertEqual(apply_suppression["godot_symbol"], "hit_suppression_result.applySuppressionCall")

        pooled_vec2 = source_symbols.source_symbol(registry, "hit.suppression.pooled_vec2")
        self.assertEqual(pooled_vec2["java_expr"], "new Vec2(b.x, b.y)")
        self.assertEqual(pooled_vec2["godot_symbol"], "hit_suppression_result.suppressionVector")

    def test_bullet_type_hit_splash_damage_dispatch_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        splash_call = source_symbols.source_symbol(registry, "hit.splash_damage_dispatch.create_splash_damage_call")
        self.assertEqual(splash_call["java_expr"], "createSplashDamage(b, x, y)")
        self.assertEqual(splash_call["godot_symbol"], "hit_splash_damage_dispatch_result.createSplashDamageCall")
        self.assertEqual(splash_call["godot_owner"], "PortGame.source_bullet_type_hit_splash_damage_dispatch_state")
        self.assertEqual(splash_call["runtime_proof"], "/root/Main.source_bullet_type_hit_splash_damage_dispatch_state")

        lightning_boundary = source_symbols.source_symbol(registry, "hit.splash_damage_dispatch.lightning_boundary")
        self.assertEqual(lightning_boundary["java_expr"], "for(int i = 0; i < lightning; i++)")
        self.assertEqual(lightning_boundary["godot_symbol"], "hit_splash_damage_dispatch_result.lightningBoundarySource")

    def test_audit_reports_whole_godot_source_surface(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        audit = source_symbols.audit_godot_source_symbol_coverage(ROOT / "godot-mindustry", registry)

        self.assertGreater(audit["totalSourceFunctions"], 400)
        self.assertEqual(audit["registeredSourceOwnerCount"], 21)
        self.assertEqual(audit["exemptSourceOwnerCount"], 5)
        self.assertEqual(audit["legacyUnregisteredOwnerCount"], audit["totalSourceFunctions"] - 26)
        self.assertIn("PortGame.source_symbol_registry_state", audit["exemptSourceOwners"])
        self.assertIn("PortGame.source_symbol_audit_state", audit["exemptSourceOwners"])
        self.assertIn("PortGame.source_slice_ledger_state", audit["exemptSourceOwners"])
        self.assertIn("PortGame.source_api_contract_state", audit["exemptSourceOwners"])
        self.assertIn("PortGame.source_state_schema_state", audit["exemptSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_draw_parts_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_test_collision_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_tile_heal_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_tile_fire_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_tile_enemy_direct_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_tile_lifesteal_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_handle_pierce_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_entity_damage_cap_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_entity_lifesteal_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_entity_armor_damage_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_entity_unit_effects_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_entity_unit_destroy_event_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_entity_handle_pierce_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_damage_multiplier_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_default_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_xy_default_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_effects_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_frag_dispatch_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_post_frag_dispatch_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_suppression_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_hit_splash_damage_dispatch_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_overdrive_projector_range", audit["legacyUnregisteredOwners"])
        self.assertEqual(audit["policy"]["newSourceOwnerRequiresRegistry"], True)

    def test_audit_report_file_matches_current_godot_source(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        expected = source_symbols.audit_godot_source_symbol_coverage(ROOT / "godot-mindustry", registry)
        actual = source_symbols.load_source_symbol_audit_report(ROOT / "godot-mindustry")

        self.assertEqual(actual, expected)

    def test_source_slice_ledger_tracks_registered_source_owners(self):
        ledger = source_symbols.load_source_slice_ledger(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_slice_ledger(ledger)

        self.assertEqual(errors, [])
        self.assertTrue(ledger["policy"]["newSliceRequiresLedger"])

        draw_parts = source_symbols.source_slice(ledger, "N399")
        self.assertEqual(draw_parts["java_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(draw_parts["java_method"], "drawParts(Bullet b)")
        self.assertEqual(draw_parts["godot_owner"], "PortGame.source_bullet_type_draw_parts_state")
        self.assertIn("DrawPart.params.set(b.fin(), 0f, 0f, 0f, 0f, 0f, b.x, b.y, b.rotation())", draw_parts["exact_exprs"])

        test_collision = source_symbols.source_slice(ledger, "N401")
        self.assertEqual(test_collision["exact_exprs"], ["return !heals() || tile.team != bullet.team || tile.healthf() < 1f;"])

        hit_tile_heal = source_symbols.source_slice(ledger, "N405")
        self.assertEqual(hit_tile_heal["java_method"], "hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct)")
        self.assertEqual(hit_tile_heal["godot_owner"], "PortGame.source_bullet_type_hit_tile_heal_state")
        self.assertIn("build.heal(healPercent / 100f * build.maxHealth + healAmount)", hit_tile_heal["exact_exprs"])

        hit_tile_fire = source_symbols.source_slice(ledger, "N406")
        self.assertEqual(hit_tile_fire["java_method"], "hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct)")
        self.assertEqual(hit_tile_fire["godot_owner"], "PortGame.source_bullet_type_hit_tile_fire_state")
        self.assertIn("Fires.create(build.tile)", hit_tile_fire["exact_exprs"])

        hit_tile_enemy_direct = source_symbols.source_slice(ledger, "N407")
        self.assertEqual(hit_tile_enemy_direct["java_method"], "hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct)")
        self.assertEqual(hit_tile_enemy_direct["godot_owner"], "PortGame.source_bullet_type_hit_tile_enemy_direct_state")
        self.assertIn("}else if(build.team != b.team && direct)", hit_tile_enemy_direct["exact_exprs"])

        hit_tile_lifesteal = source_symbols.source_slice(ledger, "N408")
        self.assertEqual(hit_tile_lifesteal["java_method"], "hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct)")
        self.assertEqual(hit_tile_lifesteal["godot_owner"], "PortGame.source_bullet_type_hit_tile_lifesteal_state")
        self.assertIn("float result = Math.max(Math.min(build.health, damage), 0)", hit_tile_lifesteal["exact_exprs"])

        handle_pierce = source_symbols.source_slice(ledger, "N409")
        self.assertEqual(handle_pierce["java_method"], "handlePierce(Bullet b, float initialHealth, float x, float y)")
        self.assertEqual(handle_pierce["godot_owner"], "PortGame.source_bullet_type_handle_pierce_state")
        self.assertIn("b.damage -= Float.isNaN(sub) ? b.damage : Math.min(b.damage, sub)", handle_pierce["exact_exprs"])

        hit_entity_damage_cap = source_symbols.source_slice(ledger, "N410")
        self.assertEqual(hit_entity_damage_cap["java_method"], "hitEntity(Bullet b, Hitboxc entity, float health)")
        self.assertEqual(hit_entity_damage_cap["godot_owner"], "PortGame.source_bullet_type_hit_entity_damage_cap_state")
        self.assertIn("float shield = entity instanceof Shieldc s ? Math.max(s.shield(), 0f) : 0f", hit_entity_damage_cap["exact_exprs"])

        hit_entity_lifesteal = source_symbols.source_slice(ledger, "N411")
        self.assertEqual(hit_entity_lifesteal["java_method"], "hitEntity(Bullet b, Hitboxc entity, float health)")
        self.assertEqual(hit_entity_lifesteal["godot_owner"], "PortGame.source_bullet_type_hit_entity_lifesteal_state")
        self.assertIn("float result = Math.max(Math.min(h.health(), damage), 0)", hit_entity_lifesteal["exact_exprs"])

        hit_entity_armor_damage = source_symbols.source_slice(ledger, "N412")
        self.assertEqual(hit_entity_armor_damage["java_method"], "hitEntity(Bullet b, Hitboxc entity, float health)")
        self.assertEqual(hit_entity_armor_damage["godot_owner"], "PortGame.source_bullet_type_hit_entity_armor_damage_state")
        self.assertIn("h.damageArmorMult(damage, armorMultiplier)", hit_entity_armor_damage["exact_exprs"])

        hit_entity_unit_effects = source_symbols.source_slice(ledger, "N413")
        self.assertEqual(hit_entity_unit_effects["java_method"], "hitEntity(Bullet b, Hitboxc entity, float health)")
        self.assertEqual(hit_entity_unit_effects["godot_owner"], "PortGame.source_bullet_type_hit_entity_unit_effects_state")
        self.assertIn("Events.fire(bulletDamageEvent.set(unit, b))", hit_entity_unit_effects["exact_exprs"])

        hit_entity_unit_destroy = source_symbols.source_slice(ledger, "N414")
        self.assertEqual(hit_entity_unit_destroy["java_method"], "hitEntity(Bullet b, Hitboxc entity, float health)")
        self.assertEqual(hit_entity_unit_destroy["godot_owner"], "PortGame.source_bullet_type_hit_entity_unit_destroy_event_state")
        self.assertIn("Events.fire(new UnitBulletDestroyEvent(unit, b))", hit_entity_unit_destroy["exact_exprs"])

        hit_entity_handle_pierce = source_symbols.source_slice(ledger, "N415")
        self.assertEqual(hit_entity_handle_pierce["java_method"], "hitEntity(Bullet b, Hitboxc entity, float health)")
        self.assertEqual(hit_entity_handle_pierce["godot_owner"], "PortGame.source_bullet_type_hit_entity_handle_pierce_state")
        self.assertIn("handlePierce(b, health, entity.x(), entity.y())", hit_entity_handle_pierce["exact_exprs"])

        damage_multiplier = source_symbols.source_slice(ledger, "N416")
        self.assertEqual(damage_multiplier["java_method"], "damageMultiplier(Bullet b)")
        self.assertEqual(damage_multiplier["godot_owner"], "PortGame.source_bullet_type_damage_multiplier_state")
        self.assertIn("if(b.owner instanceof Unit u) return u.damageMultiplier() * state.rules.unitDamage(b.team)", damage_multiplier["exact_exprs"])

        hit_default = source_symbols.source_slice(ledger, "N417")
        self.assertEqual(hit_default["java_method"], "hit(Bullet b)")
        self.assertEqual(hit_default["godot_owner"], "PortGame.source_bullet_type_hit_default_state")
        self.assertIn("hit(b, b.x, b.y, true)", hit_default["exact_exprs"])

        hit_xy_default = source_symbols.source_slice(ledger, "N418")
        self.assertEqual(hit_xy_default["java_method"], "hit(Bullet b, float x, float y)")
        self.assertEqual(hit_xy_default["godot_owner"], "PortGame.source_bullet_type_hit_xy_default_state")
        self.assertIn("hit(b, x, y, true)", hit_xy_default["exact_exprs"])

        hit_effects = source_symbols.source_slice(ledger, "N419")
        self.assertEqual(hit_effects["java_method"], "hit(Bullet b, float x, float y, boolean createFrags)")
        self.assertEqual(hit_effects["godot_owner"], "PortGame.source_bullet_type_hit_effects_state")
        self.assertIn("hitEffect.at(x, y, b.rotation(), hitColor)", hit_effects["exact_exprs"])
        self.assertIn("Effect.shake(hitShake, hitShake, b)", hit_effects["exact_exprs"])

        hit_frag_dispatch = source_symbols.source_slice(ledger, "N420")
        self.assertEqual(hit_frag_dispatch["java_method"], "hit(Bullet b, float x, float y, boolean createFrags)")
        self.assertEqual(hit_frag_dispatch["godot_owner"], "PortGame.source_bullet_type_hit_frag_dispatch_state")
        self.assertIn("if(createFrags && fragOnHit)", hit_frag_dispatch["exact_exprs"])
        self.assertIn("Time.run(0f, () -> createFrags(b, x, y))", hit_frag_dispatch["exact_exprs"])
        self.assertIn("createFrags(b, x, y)", hit_frag_dispatch["exact_exprs"])

        hit_post_frag_dispatch = source_symbols.source_slice(ledger, "N421")
        self.assertEqual(hit_post_frag_dispatch["java_method"], "hit(Bullet b, float x, float y, boolean createFrags)")
        self.assertEqual(hit_post_frag_dispatch["godot_owner"], "PortGame.source_bullet_type_hit_post_frag_dispatch_state")
        self.assertIn("createPuddles(b, x, y)", hit_post_frag_dispatch["exact_exprs"])
        self.assertIn("createIncend(b, x, y)", hit_post_frag_dispatch["exact_exprs"])
        self.assertIn("createUnits(b, x, y)", hit_post_frag_dispatch["exact_exprs"])

        hit_suppression = source_symbols.source_slice(ledger, "N422")
        self.assertEqual(hit_suppression["java_method"], "hit(Bullet b, float x, float y, boolean createFrags)")
        self.assertEqual(hit_suppression["godot_owner"], "PortGame.source_bullet_type_hit_suppression_state")
        self.assertIn("if(suppressionRange > 0)", hit_suppression["exact_exprs"])
        self.assertIn("Damage.applySuppression(b.team, b.x, b.y, suppressionRange, suppressionDuration, 0f, suppressionEffectChance, new Vec2(b.x, b.y), suppressColor)", hit_suppression["exact_exprs"])
        self.assertIn("createSplashDamage(b, x, y)", hit_suppression["deferred_exprs"])

        hit_splash_dispatch = source_symbols.source_slice(ledger, "N423")
        self.assertEqual(hit_splash_dispatch["java_method"], "hit(Bullet b, float x, float y, boolean createFrags)")
        self.assertEqual(hit_splash_dispatch["godot_owner"], "PortGame.source_bullet_type_hit_splash_damage_dispatch_state")
        self.assertIn("createSplashDamage(b, x, y)", hit_splash_dispatch["exact_exprs"])
        self.assertIn("for(int i = 0; i < lightning; i++)", hit_splash_dispatch["deferred_exprs"])

    def test_api_contracts_pin_runtime_params_and_return_keys(self):
        contracts = source_symbols.load_source_api_contracts(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_api_contracts(contracts)

        self.assertEqual(errors, [])
        self.assertTrue(contracts["policy"]["newSourceOwnerRequiresApiContract"])

        contract = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_test_collision_state")
        self.assertEqual([param["name"] for param in contract["params"]], ["bullet_type_state", "bullet_state", "tile_state"])
        self.assertEqual(contract["params"][2]["schema"], "tile_state")
        self.assertIn("collides", contract["return_keys"])
        self.assertIn("tileHealthf", contract["return_keys"])
        self.assertEqual(contract["source_method"], "testCollision(Bullet bullet, Building tile)")

        hit_tile_heal = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_tile_heal_state")
        self.assertEqual([param["name"] for param in hit_tile_heal["params"]], ["bullet_type_state", "bullet_state", "build_state"])
        self.assertEqual(hit_tile_heal["params"][2]["schema"], "build_state")
        self.assertIn("healGatePassed", hit_tile_heal["return_keys"])
        self.assertIn("healAppliedAmount", hit_tile_heal["return_keys"])
        self.assertEqual(hit_tile_heal["source_method"], "hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct)")

        hit_tile_fire = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_tile_fire_state")
        self.assertEqual([param["name"] for param in hit_tile_fire["params"]], ["bullet_type_state", "bullet_state", "build_state"])
        self.assertEqual(hit_tile_fire["params"][2]["schema"], "build_state")
        self.assertIn("fireGatePassed", hit_tile_fire["return_keys"])
        self.assertIn("firesCreateCall", hit_tile_fire["return_keys"])
        self.assertEqual(hit_tile_fire["source_method"], "hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct)")

        hit_tile_enemy_direct = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_tile_enemy_direct_state")
        self.assertEqual([param["name"] for param in hit_tile_enemy_direct["params"]], ["bullet_type_state", "bullet_state", "build_state", "hit_tile_state"])
        self.assertEqual(hit_tile_enemy_direct["params"][3]["schema"], "hit_tile_state")
        self.assertIn("enemyDirectGatePassed", hit_tile_enemy_direct["return_keys"])
        self.assertIn("hitCalled", hit_tile_enemy_direct["return_keys"])
        self.assertEqual(hit_tile_enemy_direct["source_method"], "hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct)")

        hit_tile_lifesteal = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_tile_lifesteal_state")
        self.assertEqual([param["name"] for param in hit_tile_lifesteal["params"]], ["bullet_type_state", "bullet_state", "build_state", "hit_tile_state", "owner_health_state"])
        self.assertEqual(hit_tile_lifesteal["params"][4]["schema"], "owner_health_state")
        self.assertIn("lifestealGatePassed", hit_tile_lifesteal["return_keys"])
        self.assertIn("ownerHealAmount", hit_tile_lifesteal["return_keys"])
        self.assertEqual(hit_tile_lifesteal["source_method"], "hitTile(Bullet b, Building build, float x, float y, float initialHealth, boolean direct)")

        handle_pierce = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_handle_pierce_state")
        self.assertEqual([param["name"] for param in handle_pierce["params"]], ["bullet_type_state", "bullet_state", "pierce_state"])
        self.assertEqual(handle_pierce["params"][2]["schema"], "pierce_state")
        self.assertIn("damage", handle_pierce["return_keys"])
        self.assertIn("removeCalled", handle_pierce["return_keys"])
        self.assertEqual(handle_pierce["source_method"], "handlePierce(Bullet b, float initialHealth, float x, float y)")

        hit_entity_damage_cap = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_entity_damage_cap_state")
        self.assertEqual([param["name"] for param in hit_entity_damage_cap["params"]], ["bullet_type_state", "bullet_state", "entity_state", "hit_entity_state"])
        self.assertEqual(hit_entity_damage_cap["params"][2]["schema"], "entity_state")
        self.assertEqual(hit_entity_damage_cap["params"][3]["schema"], "hit_entity_state")
        self.assertIn("maxDamageFractionGatePassed", hit_entity_damage_cap["return_keys"])
        self.assertIn("effectiveHealth", hit_entity_damage_cap["return_keys"])
        self.assertEqual(hit_entity_damage_cap["source_method"], "hitEntity(Bullet b, Hitboxc entity, float health)")

        hit_entity_lifesteal = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_entity_lifesteal_state")
        self.assertEqual([param["name"] for param in hit_entity_lifesteal["params"]], ["bullet_type_state", "bullet_state", "entity_state", "hit_entity_state", "damage_cap_state", "owner_health_state"])
        self.assertEqual(hit_entity_lifesteal["params"][4]["schema"], "hit_entity_damage_cap_result")
        self.assertEqual(hit_entity_lifesteal["params"][5]["schema"], "owner_health_state")
        self.assertIn("lifestealGatePassed", hit_entity_lifesteal["return_keys"])
        self.assertIn("ownerHealAmount", hit_entity_lifesteal["return_keys"])
        self.assertEqual(hit_entity_lifesteal["source_method"], "hitEntity(Bullet b, Hitboxc entity, float health)")

        hit_entity_armor_damage = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_entity_armor_damage_state")
        self.assertEqual([param["name"] for param in hit_entity_armor_damage["params"]], ["bullet_type_state", "bullet_state", "entity_state", "hit_entity_state", "damage_cap_state", "lifesteal_state"])
        self.assertEqual(hit_entity_armor_damage["params"][4]["schema"], "hit_entity_damage_cap_result")
        self.assertEqual(hit_entity_armor_damage["params"][5]["schema"], "hit_entity_lifesteal_result")
        self.assertIn("damagePierceCalled", hit_entity_armor_damage["return_keys"])
        self.assertIn("damageArmorMultCalled", hit_entity_armor_damage["return_keys"])
        self.assertIn("damageCalled", hit_entity_armor_damage["return_keys"])
        self.assertEqual(hit_entity_armor_damage["source_method"], "hitEntity(Bullet b, Hitboxc entity, float health)")

        hit_entity_unit_effects = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_entity_unit_effects_state")
        self.assertEqual([param["name"] for param in hit_entity_unit_effects["params"]], ["bullet_type_state", "bullet_state", "entity_state", "armor_damage_state"])
        self.assertEqual(hit_entity_unit_effects["params"][3]["schema"], "hit_entity_armor_damage_result")
        self.assertIn("unitGatePassed", hit_entity_unit_effects["return_keys"])
        self.assertIn("impulseVector", hit_entity_unit_effects["return_keys"])
        self.assertIn("bulletDamageEventFired", hit_entity_unit_effects["return_keys"])
        self.assertEqual(hit_entity_unit_effects["source_method"], "hitEntity(Bullet b, Hitboxc entity, float health)")

        hit_entity_unit_destroy = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_entity_unit_destroy_event_state")
        self.assertEqual([param["name"] for param in hit_entity_unit_destroy["params"]], ["bullet_state", "entity_state", "damage_cap_state", "unit_effects_state"])
        self.assertEqual(hit_entity_unit_destroy["params"][2]["schema"], "hit_entity_damage_cap_result")
        self.assertEqual(hit_entity_unit_destroy["params"][3]["schema"], "hit_entity_unit_effects_result")
        self.assertIn("destroyEventGatePassed", hit_entity_unit_destroy["return_keys"])
        self.assertIn("unitDestroyEventFired", hit_entity_unit_destroy["return_keys"])
        self.assertEqual(hit_entity_unit_destroy["source_method"], "hitEntity(Bullet b, Hitboxc entity, float health)")

        hit_entity_handle_pierce = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_entity_handle_pierce_state")
        self.assertEqual([param["name"] for param in hit_entity_handle_pierce["params"]], ["bullet_type_state", "bullet_state", "entity_state", "damage_cap_state", "unit_destroy_event_state"])
        self.assertEqual(hit_entity_handle_pierce["params"][3]["schema"], "hit_entity_damage_cap_result")
        self.assertEqual(hit_entity_handle_pierce["params"][4]["schema"], "hit_entity_unit_destroy_event_result")
        self.assertIn("handlePierceCalled", hit_entity_handle_pierce["return_keys"])
        self.assertIn("handlePierce", hit_entity_handle_pierce["return_keys"])
        self.assertEqual(hit_entity_handle_pierce["source_method"], "hitEntity(Bullet b, Hitboxc entity, float health)")

        damage_multiplier = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_damage_multiplier_state")
        self.assertEqual([param["name"] for param in damage_multiplier["params"]], ["bullet_state", "bullet_owner_state", "rules_state"])
        self.assertEqual(damage_multiplier["params"][1]["schema"], "bullet_owner_state")
        self.assertEqual(damage_multiplier["params"][2]["schema"], "rules_state")
        self.assertIn("damageMultiplier", damage_multiplier["return_keys"])
        self.assertIn("branch", damage_multiplier["return_keys"])
        self.assertEqual(damage_multiplier["source_method"], "damageMultiplier(Bullet b)")

        hit_default = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_default_state")
        self.assertEqual([param["name"] for param in hit_default["params"]], ["bullet_state"])
        self.assertEqual(hit_default["params"][0]["schema"], "bullet_state")
        self.assertIn("hitCall", hit_default["return_keys"])
        self.assertIn("createFrags", hit_default["return_keys"])
        self.assertEqual(hit_default["source_method"], "hit(Bullet b)")

        hit_xy_default = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_xy_default_state")
        self.assertEqual([param["name"] for param in hit_xy_default["params"]], ["bullet_state", "hit_xy_state"])
        self.assertEqual(hit_xy_default["params"][1]["schema"], "hit_xy_state")
        self.assertIn("hitCall", hit_xy_default["return_keys"])
        self.assertIn("createFrags", hit_xy_default["return_keys"])
        self.assertEqual(hit_xy_default["source_method"], "hit(Bullet b, float x, float y)")

        hit_effects = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_effects_state")
        self.assertEqual([param["name"] for param in hit_effects["params"]], ["bullet_type_state", "bullet_state", "hit_xy_state"])
        self.assertEqual(hit_effects["params"][2]["schema"], "hit_xy_state")
        self.assertIn("hitEffectCall", hit_effects["return_keys"])
        self.assertIn("hitSoundCall", hit_effects["return_keys"])
        self.assertIn("shakeCall", hit_effects["return_keys"])
        self.assertEqual(hit_effects["source_method"], "hit(Bullet b, float x, float y, boolean createFrags)")

        hit_frag_dispatch = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_frag_dispatch_state")
        self.assertEqual([param["name"] for param in hit_frag_dispatch["params"]], ["bullet_type_state", "bullet_state", "hit_xy_state", "hit_frag_state"])
        self.assertEqual(hit_frag_dispatch["params"][3]["schema"], "hit_frag_state")
        self.assertIn("fragGatePassed", hit_frag_dispatch["return_keys"])
        self.assertIn("delayFragGatePassed", hit_frag_dispatch["return_keys"])
        self.assertIn("timeRunCall", hit_frag_dispatch["return_keys"])
        self.assertIn("createFragsCall", hit_frag_dispatch["return_keys"])
        self.assertEqual(hit_frag_dispatch["source_method"], "hit(Bullet b, float x, float y, boolean createFrags)")

        hit_post_frag_dispatch = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_post_frag_dispatch_state")
        self.assertEqual([param["name"] for param in hit_post_frag_dispatch["params"]], ["bullet_type_state", "bullet_state", "hit_xy_state", "hit_frag_dispatch_state"])
        self.assertEqual(hit_post_frag_dispatch["params"][3]["schema"], "hit_frag_dispatch_result")
        self.assertIn("createPuddlesCall", hit_post_frag_dispatch["return_keys"])
        self.assertIn("createIncendCall", hit_post_frag_dispatch["return_keys"])
        self.assertIn("createUnitsCall", hit_post_frag_dispatch["return_keys"])
        self.assertEqual(hit_post_frag_dispatch["source_method"], "hit(Bullet b, float x, float y, boolean createFrags)")

        hit_suppression = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_suppression_state")
        self.assertEqual([param["name"] for param in hit_suppression["params"]], ["bullet_type_state", "bullet_state", "hit_xy_state", "hit_post_frag_dispatch_state"])
        self.assertEqual(hit_suppression["params"][3]["schema"], "hit_post_frag_dispatch_result")
        self.assertIn("suppressionGatePassed", hit_suppression["return_keys"])
        self.assertIn("applySuppressionCall", hit_suppression["return_keys"])
        self.assertIn("suppressionVector", hit_suppression["return_keys"])
        self.assertEqual(hit_suppression["source_method"], "hit(Bullet b, float x, float y, boolean createFrags)")

        hit_splash_dispatch = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_hit_splash_damage_dispatch_state")
        self.assertEqual([param["name"] for param in hit_splash_dispatch["params"]], ["bullet_type_state", "bullet_state", "hit_xy_state", "hit_suppression_state"])
        self.assertEqual(hit_splash_dispatch["params"][3]["schema"], "hit_suppression_result")
        self.assertIn("createSplashDamageCall", hit_splash_dispatch["return_keys"])
        self.assertIn("lightningBoundarySource", hit_splash_dispatch["return_keys"])
        self.assertEqual(hit_splash_dispatch["source_method"], "hit(Bullet b, float x, float y, boolean createFrags)")

    def test_state_schema_pins_dictionary_keys_and_aliases(self):
        schema = source_symbols.load_source_state_schema(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_state_schema(schema)

        self.assertEqual(errors, [])
        self.assertTrue(schema["policy"]["newDictionaryKeyRequiresSchema"])

        bullet_state = source_symbols.state_schema(schema, "bullet_state")
        self.assertEqual(bullet_state["keys"]["team"]["java_expr"], "bullet.team")
        self.assertEqual(bullet_state["keys"]["fin"]["java_expr"], "b.fin()")

        bullet_type_state = source_symbols.state_schema(schema, "bullet_type_state")
        self.assertEqual(bullet_type_state["keys"]["pierceArmor"]["java_expr"], "pierceArmor")
        self.assertEqual(bullet_type_state["keys"]["armorMultiplier"]["java_expr"], "armorMultiplier")
        self.assertEqual(bullet_type_state["keys"]["knockback"]["java_expr"], "knockback")
        self.assertEqual(bullet_type_state["keys"]["status"]["java_expr"], "status")
        self.assertEqual(bullet_type_state["keys"]["statusDuration"]["java_expr"], "statusDuration")
        self.assertEqual(bullet_type_state["keys"]["hitEffect"]["java_expr"], "hitEffect")
        self.assertEqual(bullet_type_state["keys"]["hitSoundPitchRange"]["java_expr"], "hitSoundPitchRange")
        self.assertEqual(bullet_type_state["keys"]["hitShake"]["java_expr"], "hitShake")
        self.assertEqual(bullet_type_state["keys"]["fragOnHit"]["java_expr"], "fragOnHit")
        self.assertEqual(bullet_type_state["keys"]["delayFrags"]["java_expr"], "delayFrags")
        self.assertEqual(bullet_type_state["keys"]["fragBullet"]["java_expr"], "fragBullet")
        self.assertEqual(bullet_type_state["keys"]["suppressionRange"]["java_expr"], "suppressionRange")
        self.assertEqual(bullet_type_state["keys"]["suppressionDuration"]["java_expr"], "suppressionDuration")
        self.assertEqual(bullet_type_state["keys"]["suppressionEffectChance"]["java_expr"], "suppressionEffectChance")
        self.assertEqual(bullet_type_state["keys"]["suppressColor"]["java_expr"], "suppressColor")

        tile_state = source_symbols.state_schema(schema, "tile_state")
        self.assertEqual(tile_state["keys"]["healthf"]["java_expr"], "tile.healthf()")
        self.assertEqual(tile_state["keys"]["healthf"]["status"], "explicit-input")

        test_collision_output = source_symbols.state_schema(schema, "test_collision_result")
        self.assertEqual(test_collision_output["keys"]["tileHealthf"]["alias_of"], "tile_state.healthf")

        build_state = source_symbols.state_schema(schema, "build_state")
        self.assertEqual(build_state["keys"]["maxHealth"]["java_expr"], "build.maxHealth")
        self.assertEqual(build_state["keys"]["blockIsConstructBlock"]["java_expr"], "build.block instanceof ConstructBlock")
        self.assertEqual(build_state["keys"]["tile"]["java_expr"], "build.tile")

        hit_tile_output = source_symbols.state_schema(schema, "hit_tile_heal_result")
        self.assertEqual(hit_tile_output["keys"]["healGatePassed"]["java_expr"], "heals() && build.team == b.team && !(build.block instanceof ConstructBlock)")
        self.assertEqual(hit_tile_output["keys"]["healEffectCall"]["java_expr"], "healEffect.at(build.x, build.y, 0f, healColor, build.block)")

        hit_tile_fire_output = source_symbols.state_schema(schema, "hit_tile_fire_result")
        self.assertEqual(hit_tile_fire_output["keys"]["fireGatePassed"]["java_expr"], "makeFire && build.team != b.team")
        self.assertEqual(hit_tile_fire_output["keys"]["firesCreateCall"]["java_expr"], "Fires.create(build.tile)")

        hit_tile_state = source_symbols.state_schema(schema, "hit_tile_state")
        self.assertEqual(hit_tile_state["keys"]["direct"]["java_expr"], "direct")
        self.assertEqual(hit_tile_state["keys"]["direct"]["status"], "explicit-input")

        enemy_direct_output = source_symbols.state_schema(schema, "hit_tile_enemy_direct_result")
        self.assertEqual(enemy_direct_output["keys"]["enemyDirectGatePassed"]["java_expr"], "build.team != b.team && direct")
        self.assertEqual(enemy_direct_output["keys"]["hitCalled"]["java_expr"], "hit(b)")

        owner_health_state = source_symbols.state_schema(schema, "owner_health_state")
        self.assertEqual(owner_health_state["keys"]["isHealthc"]["java_expr"], "b.owner instanceof Healthc o")
        self.assertEqual(owner_health_state["keys"]["isHealthc"]["status"], "explicit-input")

        lifesteal_output = source_symbols.state_schema(schema, "hit_tile_lifesteal_result")
        self.assertEqual(lifesteal_output["keys"]["lifestealGatePassed"]["java_expr"], "lifesteal > 0f && b.owner instanceof Healthc o")
        self.assertEqual(lifesteal_output["keys"]["lifestealResult"]["java_expr"], "Math.max(Math.min(build.health, damage), 0)")
        self.assertEqual(lifesteal_output["keys"]["ownerHealAmount"]["java_expr"], "result * lifesteal")

        pierce_state = source_symbols.state_schema(schema, "pierce_state")
        self.assertEqual(pierce_state["keys"]["initialHealth"]["java_expr"], "initialHealth")
        self.assertEqual(pierce_state["keys"]["initialHealth"]["status"], "explicit-input")

        handle_pierce_output = source_symbols.state_schema(schema, "handle_pierce_result")
        self.assertEqual(handle_pierce_output["keys"]["sub"]["java_expr"], "Mathf.zero(pierceDamageFactor) ? 0f : Math.max(initialHealth * pierceDamageFactor, 0)")
        self.assertEqual(handle_pierce_output["keys"]["damageSubtract"]["java_expr"], "Float.isNaN(sub) ? b.damage : Math.min(b.damage, sub)")
        self.assertEqual(handle_pierce_output["keys"]["removeGatePassed"]["java_expr"], "removeAfterPierce && b.damage <= 0")

        entity_state = source_symbols.state_schema(schema, "entity_state")
        self.assertEqual(entity_state["keys"]["isHealthc"]["java_expr"], "entity instanceof Healthc h")
        self.assertEqual(entity_state["keys"]["isShieldc"]["java_expr"], "entity instanceof Shieldc s")
        self.assertEqual(entity_state["keys"]["shield"]["java_expr"], "s.shield()")
        self.assertEqual(entity_state["keys"]["health"]["java_expr"], "h.health()")
        self.assertEqual(entity_state["keys"]["x"]["java_expr"], "unit.x")
        self.assertEqual(entity_state["keys"]["y"]["java_expr"], "unit.y")

        hit_entity_state = source_symbols.state_schema(schema, "hit_entity_state")
        self.assertEqual(hit_entity_state["keys"]["health"]["java_expr"], "health")
        self.assertEqual(hit_entity_state["keys"]["health"]["status"], "explicit-input")

        hit_entity_damage_cap_output = source_symbols.state_schema(schema, "hit_entity_damage_cap_result")
        self.assertEqual(hit_entity_damage_cap_output["keys"]["shield"]["java_expr"], "entity instanceof Shieldc s ? Math.max(s.shield(), 0f) : 0f")
        self.assertEqual(hit_entity_damage_cap_output["keys"]["cap"]["java_expr"], "h.maxHealth() * maxDamageFraction + shield")
        self.assertEqual(hit_entity_damage_cap_output["keys"]["effectiveHealth"]["java_expr"], "health")

        hit_entity_lifesteal_output = source_symbols.state_schema(schema, "hit_entity_lifesteal_result")
        self.assertEqual(hit_entity_lifesteal_output["keys"]["lifestealGatePassed"]["java_expr"], "lifesteal > 0f && b.owner instanceof Healthc o")
        self.assertEqual(hit_entity_lifesteal_output["keys"]["lifestealResult"]["java_expr"], "Math.max(Math.min(h.health(), damage), 0)")
        self.assertEqual(hit_entity_lifesteal_output["keys"]["ownerHealAmount"]["java_expr"], "result * lifesteal")

        hit_entity_armor_damage_output = source_symbols.state_schema(schema, "hit_entity_armor_damage_result")
        self.assertEqual(hit_entity_armor_damage_output["keys"]["pierceArmorGatePassed"]["java_expr"], "pierceArmor")
        self.assertEqual(hit_entity_armor_damage_output["keys"]["armorMultiplierGatePassed"]["java_expr"], "armorMultiplier != 1")
        self.assertEqual(hit_entity_armor_damage_output["keys"]["damagePierceCalled"]["java_expr"], "h.damagePierce(damage)")
        self.assertEqual(hit_entity_armor_damage_output["keys"]["damageArmorMultCalled"]["java_expr"], "h.damageArmorMult(damage, armorMultiplier)")
        self.assertEqual(hit_entity_armor_damage_output["keys"]["damageCalled"]["java_expr"], "h.damage(damage)")

        hit_entity_unit_effects_output = source_symbols.state_schema(schema, "hit_entity_unit_effects_result")
        self.assertEqual(hit_entity_unit_effects_output["keys"]["unitGatePassed"]["java_expr"], "entity instanceof Unit unit")
        self.assertEqual(hit_entity_unit_effects_output["keys"]["impulseVector"]["java_expr"], "Tmp.v3.set(unit).sub(b).nor().scl(knockback * 80f)")
        self.assertEqual(hit_entity_unit_effects_output["keys"]["impulseCalled"]["java_expr"], "unit.impulse(Tmp.v3)")
        self.assertEqual(hit_entity_unit_effects_output["keys"]["statusApplyCalled"]["java_expr"], "unit.apply(status, statusDuration)")
        self.assertEqual(hit_entity_unit_effects_output["keys"]["bulletDamageEventFired"]["java_expr"], "Events.fire(bulletDamageEvent.set(unit, b))")

        hit_entity_unit_destroy_output = source_symbols.state_schema(schema, "hit_entity_unit_destroy_event_result")
        self.assertEqual(hit_entity_unit_destroy_output["keys"]["destroyEventGatePassed"]["java_expr"], "!wasDead && entity instanceof Unit unit && unit.dead")
        self.assertEqual(hit_entity_unit_destroy_output["keys"]["unitDestroyEventFired"]["java_expr"], "Events.fire(new UnitBulletDestroyEvent(unit, b))")

        hit_entity_handle_pierce_output = source_symbols.state_schema(schema, "hit_entity_handle_pierce_result")
        self.assertEqual(hit_entity_handle_pierce_output["keys"]["handlePierceCalled"]["java_expr"], "handlePierce(b, health, entity.x(), entity.y())")
        self.assertEqual(hit_entity_handle_pierce_output["keys"]["effectiveHealth"]["alias_of"], "hit_entity_damage_cap_result.effectiveHealth")
        self.assertEqual(hit_entity_handle_pierce_output["keys"]["handlePierce"]["alias_of"], "handle_pierce_result")

        bullet_owner_state = source_symbols.state_schema(schema, "bullet_owner_state")
        self.assertEqual(bullet_owner_state["keys"]["isUnit"]["java_expr"], "b.owner instanceof Unit u")
        self.assertEqual(bullet_owner_state["keys"]["unitDamageMultiplier"]["java_expr"], "u.damageMultiplier()")
        self.assertEqual(bullet_owner_state["keys"]["isBuilding"]["java_expr"], "b.owner instanceof Building")

        rules_state = source_symbols.state_schema(schema, "rules_state")
        self.assertEqual(rules_state["keys"]["unitDamage"]["java_expr"], "state.rules.unitDamage(b.team)")
        self.assertEqual(rules_state["keys"]["blockDamage"]["java_expr"], "state.rules.blockDamage(b.team)")

        damage_multiplier_output = source_symbols.state_schema(schema, "damage_multiplier_result")
        self.assertEqual(damage_multiplier_output["keys"]["damageMultiplier"]["java_expr"], "damageMultiplier(Bullet b)")
        self.assertEqual(damage_multiplier_output["keys"]["branch"]["status"], "generated")

        hit_default_output = source_symbols.state_schema(schema, "hit_default_result")
        self.assertEqual(hit_default_output["keys"]["hitCall"]["java_expr"], "hit(b, b.x, b.y, true)")
        self.assertEqual(hit_default_output["keys"]["x"]["alias_of"], "bullet_state.x")
        self.assertEqual(hit_default_output["keys"]["createFrags"]["java_expr"], "true")

        hit_xy_state = source_symbols.state_schema(schema, "hit_xy_state")
        self.assertEqual(hit_xy_state["keys"]["x"]["java_expr"], "x")
        self.assertEqual(hit_xy_state["keys"]["x"]["status"], "explicit-input")

        hit_xy_default_output = source_symbols.state_schema(schema, "hit_xy_default_result")
        self.assertEqual(hit_xy_default_output["keys"]["hitCall"]["java_expr"], "hit(b, x, y, true)")
        self.assertEqual(hit_xy_default_output["keys"]["x"]["alias_of"], "hit_xy_state.x")
        self.assertEqual(hit_xy_default_output["keys"]["createFrags"]["java_expr"], "true")

        hit_effects_output = source_symbols.state_schema(schema, "hit_effects_result")
        self.assertEqual(hit_effects_output["keys"]["hitEffectCall"]["java_expr"], "hitEffect.at(x, y, b.rotation(), hitColor)")
        self.assertEqual(hit_effects_output["keys"]["hitSoundCall"]["java_expr"], "hitSound.at(x, y, hitSoundPitch + Mathf.range(hitSoundPitchRange), hitSoundVolume)")
        self.assertEqual(hit_effects_output["keys"]["shakeCall"]["java_expr"], "Effect.shake(hitShake, hitShake, b)")

        hit_frag_state = source_symbols.state_schema(schema, "hit_frag_state")
        self.assertEqual(hit_frag_state["keys"]["createFrags"]["java_expr"], "createFrags")
        self.assertEqual(hit_frag_state["keys"]["createFrags"]["status"], "explicit-input")

        hit_frag_dispatch_output = source_symbols.state_schema(schema, "hit_frag_dispatch_result")
        self.assertEqual(hit_frag_dispatch_output["keys"]["fragGatePassed"]["java_expr"], "createFrags && fragOnHit")
        self.assertEqual(hit_frag_dispatch_output["keys"]["delayFragGatePassed"]["java_expr"], "delayFrags && fragBullet != null && fragBullet.delayFrags")
        self.assertEqual(hit_frag_dispatch_output["keys"]["timeRunCall"]["java_expr"], "Time.run(0f, () -> createFrags(b, x, y))")
        self.assertEqual(hit_frag_dispatch_output["keys"]["createFragsCall"]["java_expr"], "createFrags(b, x, y)")

        hit_post_frag_dispatch_output = source_symbols.state_schema(schema, "hit_post_frag_dispatch_result")
        self.assertEqual(hit_post_frag_dispatch_output["keys"]["createPuddlesCall"]["java_expr"], "createPuddles(b, x, y)")
        self.assertEqual(hit_post_frag_dispatch_output["keys"]["createIncendCall"]["java_expr"], "createIncend(b, x, y)")
        self.assertEqual(hit_post_frag_dispatch_output["keys"]["createUnitsCall"]["java_expr"], "createUnits(b, x, y)")
        self.assertEqual(hit_post_frag_dispatch_output["keys"]["suppressionBoundarySource"]["java_expr"], "if(suppressionRange > 0)")

        hit_suppression_output = source_symbols.state_schema(schema, "hit_suppression_result")
        self.assertEqual(hit_suppression_output["keys"]["suppressionGatePassed"]["java_expr"], "suppressionRange > 0")
        self.assertEqual(hit_suppression_output["keys"]["applySuppressionCall"]["java_expr"], "Damage.applySuppression(b.team, b.x, b.y, suppressionRange, suppressionDuration, 0f, suppressionEffectChance, new Vec2(b.x, b.y), suppressColor)")
        self.assertEqual(hit_suppression_output["keys"]["suppressionVector"]["java_expr"], "new Vec2(b.x, b.y)")
        self.assertEqual(hit_suppression_output["keys"]["splashDamageBoundarySource"]["java_expr"], "createSplashDamage(b, x, y)")

        hit_splash_dispatch_output = source_symbols.state_schema(schema, "hit_splash_damage_dispatch_result")
        self.assertEqual(hit_splash_dispatch_output["keys"]["createSplashDamageCall"]["java_expr"], "createSplashDamage(b, x, y)")
        self.assertEqual(hit_splash_dispatch_output["keys"]["lightningBoundarySource"]["java_expr"], "for(int i = 0; i < lightning; i++)")

    def test_state_schema_rejects_keys_without_source_or_alias(self):
        schema = {
            "version": 1,
            "schemas": {
                "bad_state": {
                    "status": "active",
                    "keys": {
                        "madeUp": {"type": "float", "status": "source-backed"}
                    },
                }
            },
        }

        errors = source_symbols.validate_source_state_schema(schema)

        self.assertIn("bad_state.madeUp: source-backed requires java_source", errors)
        self.assertIn("bad_state.madeUp: source-backed requires java_expr", errors)


if __name__ == "__main__":
    unittest.main()
