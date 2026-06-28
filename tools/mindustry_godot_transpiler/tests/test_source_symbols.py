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

    def test_bullet_type_create_splash_damage_damage_dispatch_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        damage_gate = source_symbols.source_symbol(registry, "create_splash_damage.damage_dispatch.gate")
        self.assertEqual(damage_gate["java_expr"], "splashDamageRadius > 0 && !b.absorbed")
        self.assertEqual(damage_gate["godot_symbol"], "create_splash_damage_damage_dispatch_result.splashDamageGatePassed")
        self.assertEqual(damage_gate["godot_owner"], "PortGame.source_bullet_type_create_splash_damage_damage_dispatch_state")
        self.assertEqual(damage_gate["runtime_proof"], "/root/Main.source_bullet_type_create_splash_damage_damage_dispatch_state")

        damage_call = source_symbols.source_symbol(registry, "create_splash_damage.damage_dispatch.damage_call")
        self.assertEqual(damage_call["java_expr"], "Damage.damage(b.team, x, y, splashDamageRadius, splashDamage * b.damageMultiplier(), splashDamagePierce, collidesAir, collidesGround, scaledSplashDamage, b, armorMultiplier)")
        self.assertEqual(damage_call["godot_symbol"], "create_splash_damage_damage_dispatch_result.damageCall")

        status_boundary = source_symbols.source_symbol(registry, "create_splash_damage.damage_dispatch.status_boundary")
        self.assertEqual(status_boundary["java_expr"], "if(status != StatusEffects.none)")
        self.assertEqual(status_boundary["godot_symbol"], "create_splash_damage_damage_dispatch_result.statusBoundarySource")

    def test_bullet_type_create_splash_damage_status_dispatch_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        status_gate = source_symbols.source_symbol(registry, "create_splash_damage.status_dispatch.gate")
        self.assertEqual(status_gate["java_expr"], "status != StatusEffects.none")
        self.assertEqual(status_gate["godot_symbol"], "create_splash_damage_status_dispatch_result.statusGatePassed")
        self.assertEqual(status_gate["godot_owner"], "PortGame.source_bullet_type_create_splash_damage_status_dispatch_state")
        self.assertEqual(status_gate["runtime_proof"], "/root/Main.source_bullet_type_create_splash_damage_status_dispatch_state")

        status_call = source_symbols.source_symbol(registry, "create_splash_damage.status_dispatch.status_call")
        self.assertEqual(status_call["java_expr"], "Damage.status(b.team, x, y, splashDamageRadius, status, statusDuration, collidesAir, collidesGround)")
        self.assertEqual(status_call["godot_symbol"], "create_splash_damage_status_dispatch_result.statusCall")

        heals_boundary = source_symbols.source_symbol(registry, "create_splash_damage.status_dispatch.heals_boundary")
        self.assertEqual(heals_boundary["java_expr"], "if(heals())")
        self.assertEqual(heals_boundary["godot_symbol"], "create_splash_damage_status_dispatch_result.healsBoundarySource")

    def test_bullet_type_create_splash_damage_heal_dispatch_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        heal_gate = source_symbols.source_symbol(registry, "create_splash_damage.heal_dispatch.gate")
        self.assertEqual(heal_gate["java_expr"], "heals()")
        self.assertEqual(heal_gate["godot_symbol"], "create_splash_damage_heal_dispatch_result.healGatePassed")
        self.assertEqual(heal_gate["godot_owner"], "PortGame.source_bullet_type_create_splash_damage_heal_dispatch_state")
        self.assertEqual(heal_gate["runtime_proof"], "/root/Main.source_bullet_type_create_splash_damage_heal_dispatch_state")

        each_block = source_symbols.source_symbol(registry, "create_splash_damage.heal_dispatch.each_block_call")
        self.assertEqual(each_block["java_expr"], "indexer.eachBlock(b.team, x, y, splashDamageRadius, Building::damaged, other -> {...})")
        self.assertEqual(each_block["godot_symbol"], "create_splash_damage_heal_dispatch_result.eachBlockCall")

        heal_amount = source_symbols.source_symbol(registry, "create_splash_damage.heal_dispatch.heal_amount")
        self.assertEqual(heal_amount["java_expr"], "healPercent / 100f * other.maxHealth() + healAmount")
        self.assertEqual(heal_amount["godot_symbol"], "create_splash_damage_heal_dispatch_result.healApplications")

        make_fire_boundary = source_symbols.source_symbol(registry, "create_splash_damage.heal_dispatch.make_fire_boundary")
        self.assertEqual(make_fire_boundary["java_expr"], "if(makeFire)")
        self.assertEqual(make_fire_boundary["godot_symbol"], "create_splash_damage_heal_dispatch_result.makeFireBoundarySource")

    def test_bullet_type_create_splash_damage_make_fire_dispatch_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        make_fire = source_symbols.source_symbol(registry, "create_splash_damage.make_fire_dispatch.make_fire")
        self.assertEqual(make_fire["java_expr"], "makeFire")
        self.assertEqual(make_fire["godot_symbol"], "bullet_type_state.makeFire")
        self.assertEqual(make_fire["godot_owner"], "PortGame.source_bullet_type_create_splash_damage_make_fire_dispatch_state")
        self.assertEqual(make_fire["runtime_proof"], "/root/Main.source_bullet_type_create_splash_damage_make_fire_dispatch_state")

        each_block = source_symbols.source_symbol(registry, "create_splash_damage.make_fire_dispatch.each_block_call")
        self.assertEqual(each_block["java_expr"], "indexer.eachBlock(null, x, y, splashDamageRadius, other -> other.team != b.team, other -> Fires.create(other.tile))")
        self.assertEqual(each_block["godot_symbol"], "create_splash_damage_make_fire_dispatch_result.eachBlockCall")

        fire_call = source_symbols.source_symbol(registry, "create_splash_damage.make_fire_dispatch.fires_create_call")
        self.assertEqual(fire_call["java_expr"], "Fires.create(other.tile)")
        self.assertEqual(fire_call["godot_symbol"], "create_splash_damage_make_fire_dispatch_result.fireApplications")

        create_frags_boundary = source_symbols.source_symbol(registry, "create_splash_damage.make_fire_dispatch.create_frags_boundary")
        self.assertEqual(create_frags_boundary["java_expr"], "public void createFrags(Bullet b, float x, float y){")
        self.assertEqual(create_frags_boundary["godot_symbol"], "create_splash_damage_make_fire_dispatch_result.createFragsBoundarySource")

    def test_bullet_type_create_frags_initial_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        initial_gate = source_symbols.source_symbol(registry, "create_frags.initial.gate")
        self.assertEqual(initial_gate["java_expr"], "fragBullet != null && (fragOnAbsorb || !b.absorbed) && (pierceFragCap < 0 || b.frags < pierceFragCap)")
        self.assertEqual(initial_gate["godot_symbol"], "create_frags_initial_result.fragGatePassed")
        self.assertEqual(initial_gate["godot_owner"], "PortGame.source_bullet_type_create_frags_initial_state")
        self.assertEqual(initial_gate["runtime_proof"], "/root/Main.source_bullet_type_create_frags_initial_state")

        bullet_frags = source_symbols.source_symbol(registry, "create_frags.initial.bullet_frags")
        self.assertEqual(bullet_frags["java_expr"], "b.frags")
        self.assertEqual(bullet_frags["godot_symbol"], "bullet_state.frags")

        loop_boundary = source_symbols.source_symbol(registry, "create_frags.initial.loop_boundary")
        self.assertEqual(loop_boundary["java_expr"], "for(int i = 0; i < fragBullets; i++)")
        self.assertEqual(loop_boundary["godot_symbol"], "create_frags_initial_result.loopIterations")

        random_len_boundary = source_symbols.source_symbol(registry, "create_frags.initial.random_len_boundary")
        self.assertEqual(random_len_boundary["java_expr"], "float len = Mathf.random(fragOffsetMin, fragOffsetMax)")
        self.assertEqual(random_len_boundary["godot_symbol"], "create_frags_initial_result.randomLenBoundarySource")

    def test_bullet_type_create_frags_random_geometry_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        random_len = source_symbols.source_symbol(registry, "create_frags.random_geometry.random_len")
        self.assertEqual(random_len["java_expr"], "float len = Mathf.random(fragOffsetMin, fragOffsetMax)")
        self.assertEqual(random_len["godot_symbol"], "create_frags_random_geometry_result.fragmentPlans.len")
        self.assertEqual(random_len["godot_owner"], "PortGame.source_bullet_type_create_frags_random_geometry_state")
        self.assertEqual(random_len["runtime_proof"], "/root/Main.source_bullet_type_create_frags_random_geometry_state")

        angle_formula = source_symbols.source_symbol(registry, "create_frags.random_geometry.angle_formula")
        self.assertEqual(angle_formula["java_expr"], "b.rotation() + Mathf.range(fragRandomSpread / 2) + fragAngle + fragSpread * i - (fragBullets - 1) * fragSpread / 2f")
        self.assertEqual(angle_formula["godot_symbol"], "create_frags_random_geometry_result.fragmentPlans.angle")

        create_call_boundary = source_symbols.source_symbol(registry, "create_frags.random_geometry.create_call_boundary")
        self.assertEqual(create_call_boundary["status"], "deferred")
        self.assertEqual(create_call_boundary["java_expr"], "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax))")

    def test_bullet_type_create_frags_create_call_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        create_call = source_symbols.source_symbol(registry, "create_frags.create_call.frag_bullet_create")
        self.assertEqual(create_call["java_expr"], "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax))")
        self.assertEqual(create_call["godot_symbol"], "create_frags_create_call_result.fragmentCreateCalls")
        self.assertEqual(create_call["godot_owner"], "PortGame.source_bullet_type_create_frags_create_call_state")
        self.assertEqual(create_call["runtime_proof"], "/root/Main.source_bullet_type_create_frags_create_call_state")

        trnsx = source_symbols.source_symbol(registry, "create_frags.create_call.trnsx")
        self.assertEqual(trnsx["java_expr"], "Angles.trnsx(a, len)")
        self.assertEqual(trnsx["godot_symbol"], "create_frags_create_call_result.fragmentCreateCalls.x")

        velocity_samples = source_symbols.source_symbol(registry, "create_frags.create_call.velocity_samples")
        self.assertEqual(velocity_samples["status"], "explicit-input")
        self.assertEqual(velocity_samples["godot_symbol"], "frag_random_state.velocitySamples")

        life_samples = source_symbols.source_symbol(registry, "create_frags.create_call.life_samples")
        self.assertEqual(life_samples["status"], "explicit-input")
        self.assertEqual(life_samples["godot_symbol"], "frag_random_state.lifeSamples")

    def test_bullet_type_create_frags_increment_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        increment = source_symbols.source_symbol(registry, "create_frags.increment.frags_increment")
        self.assertEqual(increment["java_expr"], "b.frags++")
        self.assertEqual(increment["godot_symbol"], "create_frags_increment_result.bulletFragsAfter")
        self.assertEqual(increment["godot_owner"], "PortGame.source_bullet_type_create_frags_increment_state")
        self.assertEqual(increment["runtime_proof"], "/root/Main.source_bullet_type_create_frags_increment_state")

        gate = source_symbols.source_symbol(registry, "create_frags.increment.gate")
        self.assertEqual(gate["java_expr"], "fragBullet != null && (fragOnAbsorb || !b.absorbed) && (pierceFragCap < 0 || b.frags < pierceFragCap)")
        self.assertEqual(gate["godot_symbol"], "create_frags_create_call_result.fragGatePassed")

    def test_bullet_type_create_puddles_initial_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "create_puddles.initial.gate")
        self.assertEqual(gate["java_expr"], "puddleLiquid != null && puddles > 0")
        self.assertEqual(gate["godot_symbol"], "create_puddles_initial_result.puddleGatePassed")
        self.assertEqual(gate["godot_owner"], "PortGame.source_bullet_type_create_puddles_initial_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_bullet_type_create_puddles_initial_state")

        loop_boundary = source_symbols.source_symbol(registry, "create_puddles.initial.loop_boundary")
        self.assertEqual(loop_boundary["java_expr"], "for(int i = 0; i < puddles; i++)")
        self.assertEqual(loop_boundary["godot_symbol"], "create_puddles_initial_result.loopIterations")

        puddle_liquid = source_symbols.source_symbol(registry, "create_puddles.initial.puddle_liquid")
        self.assertEqual(puddle_liquid["java_expr"], "puddleLiquid = Liquids.water")
        self.assertEqual(puddle_liquid["godot_symbol"], "bullet_type_state.puddleLiquid")

    def test_bullet_type_create_puddles_tile_world_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        tile_world = source_symbols.source_symbol(registry, "create_puddles.tile_world.tile_world_call")
        self.assertEqual(tile_world["java_expr"], "Tile tile = world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange))")
        self.assertEqual(tile_world["godot_symbol"], "create_puddles_tile_world_result.tileWorldCalls")
        self.assertEqual(tile_world["godot_owner"], "PortGame.source_bullet_type_create_puddles_tile_world_state")
        self.assertEqual(tile_world["runtime_proof"], "/root/Main.source_bullet_type_create_puddles_tile_world_state")

        x_samples = source_symbols.source_symbol(registry, "create_puddles.tile_world.x_range_samples")
        self.assertEqual(x_samples["status"], "explicit-input")
        self.assertEqual(x_samples["godot_symbol"], "puddle_random_state.xRangeSamples")

        y_samples = source_symbols.source_symbol(registry, "create_puddles.tile_world.y_range_samples")
        self.assertEqual(y_samples["status"], "explicit-input")
        self.assertEqual(y_samples["godot_symbol"], "puddle_random_state.yRangeSamples")

    def test_bullet_type_create_puddles_deposit_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        deposit = source_symbols.source_symbol(registry, "create_puddles.deposit.deposit_call")
        self.assertEqual(deposit["java_expr"], "Puddles.deposit(tile, puddleLiquid, puddleAmount)")
        self.assertEqual(deposit["godot_symbol"], "create_puddles_deposit_result.depositCalls")
        self.assertEqual(deposit["godot_owner"], "PortGame.source_bullet_type_create_puddles_deposit_state")
        self.assertEqual(deposit["runtime_proof"], "/root/Main.source_bullet_type_create_puddles_deposit_state")

        amount = source_symbols.source_symbol(registry, "create_puddles.deposit.puddle_amount")
        self.assertEqual(amount["java_expr"], "puddleAmount = 5f")
        self.assertEqual(amount["godot_symbol"], "bullet_type_state.puddleAmount")

        liquid = source_symbols.source_symbol(registry, "create_puddles.deposit.puddle_liquid")
        self.assertEqual(liquid["java_expr"], "puddleLiquid = Liquids.water")
        self.assertEqual(liquid["godot_symbol"], "bullet_type_state.puddleLiquid")

    def test_bullet_type_create_incend_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        call = source_symbols.source_symbol(registry, "create_incend.create_incend_call")
        self.assertEqual(call["java_expr"], "Damage.createIncend(x, y, incendSpread, incendAmount)")
        self.assertEqual(call["godot_symbol"], "create_incend_result.createIncendCall")
        self.assertEqual(call["godot_owner"], "PortGame.source_bullet_type_create_incend_state")
        self.assertEqual(call["runtime_proof"], "/root/Main.source_bullet_type_create_incend_state")

        chance = source_symbols.source_symbol(registry, "create_incend.chance")
        self.assertEqual(chance["java_expr"], "incendChance = 1f")
        self.assertEqual(chance["godot_symbol"], "bullet_type_state.incendChance")

        chance_passed = source_symbols.source_symbol(registry, "create_incend.chance_passed")
        self.assertEqual(chance_passed["status"], "explicit-input")
        self.assertEqual(chance_passed["godot_symbol"], "incend_random_state.chancePassed")

    def test_bullet_type_create_units_initial_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "create_units.initial.gate")
        self.assertEqual(gate["java_expr"], "!net.client() && despawnUnit != null && Mathf.chance(despawnUnitChance)")
        self.assertEqual(gate["godot_symbol"], "create_units_initial_result.createUnitsGatePassed")
        self.assertEqual(gate["godot_owner"], "PortGame.source_bullet_type_create_units_initial_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_bullet_type_create_units_initial_state")

        net_client = source_symbols.source_symbol(registry, "create_units.initial.net_client")
        self.assertEqual(net_client["java_expr"], "net.client()")
        self.assertEqual(net_client["godot_symbol"], "net_state.client")
        self.assertEqual(net_client["status"], "explicit-input")

        chance_passed = source_symbols.source_symbol(registry, "create_units.initial.chance_passed")
        self.assertEqual(chance_passed["java_expr"], "Mathf.chance(despawnUnitChance)")
        self.assertEqual(chance_passed["godot_symbol"], "create_units_random_state.chancePassed")
        self.assertEqual(chance_passed["status"], "explicit-input")

        despawn_unit = source_symbols.source_symbol(registry, "create_units.initial.despawn_unit")
        self.assertEqual(despawn_unit["java_expr"], "despawnUnit")
        self.assertEqual(despawn_unit["godot_symbol"], "bullet_type_state.despawnUnit")

    def test_bullet_type_create_units_random_offset_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        offset_plan = source_symbols.source_symbol(registry, "create_units.random_offset.unit_offset_plans")
        self.assertEqual(offset_plan["java_expr"], "Tmp.v1.rnd(Mathf.random(despawnUnitRadius))")
        self.assertEqual(offset_plan["godot_symbol"], "create_units_random_offset_result.unitOffsetPlans")
        self.assertEqual(offset_plan["godot_owner"], "PortGame.source_bullet_type_create_units_random_offset_state")
        self.assertEqual(offset_plan["runtime_proof"], "/root/Main.source_bullet_type_create_units_random_offset_state")

        length_samples = source_symbols.source_symbol(registry, "create_units.random_offset.length_samples")
        self.assertEqual(length_samples["java_expr"], "Mathf.random(despawnUnitRadius)")
        self.assertEqual(length_samples["godot_symbol"], "create_units_random_state.lengthSamples")
        self.assertEqual(length_samples["status"], "explicit-input")

        theta_samples = source_symbols.source_symbol(registry, "create_units.random_offset.theta_samples")
        self.assertEqual(theta_samples["java_expr"], "Mathf.random(0f, Mathf.PI2)")
        self.assertEqual(theta_samples["godot_symbol"], "create_units_random_state.thetaSamples")
        self.assertEqual(theta_samples["status"], "explicit-input")

    def test_bullet_type_create_units_spawn_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        spawn_calls = source_symbols.source_symbol(registry, "create_units.spawn.spawn_calls")
        self.assertEqual(spawn_calls["java_expr"], "despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y)")
        self.assertEqual(spawn_calls["godot_symbol"], "create_units_spawn_result.spawnCalls")
        self.assertEqual(spawn_calls["godot_owner"], "PortGame.source_bullet_type_create_units_spawn_state")
        self.assertEqual(spawn_calls["runtime_proof"], "/root/Main.source_bullet_type_create_units_spawn_state")

        despawn_unit = source_symbols.source_symbol(registry, "create_units.spawn.despawn_unit")
        self.assertEqual(despawn_unit["java_expr"], "despawnUnit")
        self.assertEqual(despawn_unit["godot_symbol"], "bullet_type_state.despawnUnit")

        team = source_symbols.source_symbol(registry, "create_units.spawn.team")
        self.assertEqual(team["java_expr"], "b.team")
        self.assertEqual(team["godot_symbol"], "bullet_state.team")

        unit_offset_plans = source_symbols.source_symbol(registry, "create_units.spawn.unit_offset_plans")
        self.assertEqual(unit_offset_plans["java_expr"], "x + Tmp.v1.x, y + Tmp.v1.y")
        self.assertEqual(unit_offset_plans["godot_symbol"], "create_units_random_offset_result.unitOffsetPlans")

        rotation = source_symbols.source_symbol(registry, "create_units.spawn.rotation_boundary")
        self.assertEqual(rotation["status"], "deferred")
        self.assertEqual(rotation["java_expr"], "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation();")

        notify = source_symbols.source_symbol(registry, "create_units.spawn.notify_boundary")
        self.assertEqual(notify["status"], "deferred")
        self.assertEqual(notify["java_expr"], "Units.notifyUnitSpawn(u);")

    def test_bullet_type_create_units_rotation_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        rotation_assignments = source_symbols.source_symbol(registry, "create_units.rotation.rotation_assignments")
        self.assertEqual(rotation_assignments["java_expr"], "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation()")
        self.assertEqual(rotation_assignments["godot_symbol"], "create_units_rotation_result.rotationAssignments")
        self.assertEqual(rotation_assignments["godot_owner"], "PortGame.source_bullet_type_create_units_rotation_state")
        self.assertEqual(rotation_assignments["runtime_proof"], "/root/Main.source_bullet_type_create_units_rotation_state")

        face_outwards = source_symbols.source_symbol(registry, "create_units.rotation.face_outwards")
        self.assertEqual(face_outwards["java_expr"], "faceOutwards")
        self.assertEqual(face_outwards["godot_symbol"], "bullet_type_state.faceOutwards")

        bullet_rotation = source_symbols.source_symbol(registry, "create_units.rotation.bullet_rotation")
        self.assertEqual(bullet_rotation["java_expr"], "b.rotation()")
        self.assertEqual(bullet_rotation["godot_symbol"], "bullet_state.rotation")
        self.assertEqual(bullet_rotation["status"], "explicit-input")

        tmp_v1_angle = source_symbols.source_symbol(registry, "create_units.rotation.tmp_v1_angle")
        self.assertEqual(tmp_v1_angle["java_expr"], "Tmp.v1.angle()")
        self.assertEqual(tmp_v1_angle["godot_symbol"], "create_units_rotation_result.rotationAssignments.tmpV1Angle")

        notify = source_symbols.source_symbol(registry, "create_units.rotation.notify_boundary")
        self.assertEqual(notify["status"], "deferred")
        self.assertEqual(notify["java_expr"], "Units.notifyUnitSpawn(u);")

    def test_bullet_type_create_units_notify_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        notify_calls = source_symbols.source_symbol(registry, "create_units.notify.notify_calls")
        self.assertEqual(notify_calls["java_expr"], "Units.notifyUnitSpawn(u)")
        self.assertEqual(notify_calls["godot_symbol"], "create_units_notify_result.notifyCalls")
        self.assertEqual(notify_calls["godot_owner"], "PortGame.source_bullet_type_create_units_notify_state")
        self.assertEqual(notify_calls["runtime_proof"], "/root/Main.source_bullet_type_create_units_notify_state")

        rotation_assignments = source_symbols.source_symbol(registry, "create_units.notify.rotation_assignments")
        self.assertEqual(rotation_assignments["java_expr"], "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation()")
        self.assertEqual(rotation_assignments["godot_symbol"], "create_units_rotation_result.rotationAssignments")

    def test_bullet_type_despawned_dispatch_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        despawn_hit = source_symbols.source_symbol(registry, "despawned.dispatch.despawn_hit")
        self.assertEqual(despawn_hit["java_expr"], "despawnHit")
        self.assertEqual(despawn_hit["godot_symbol"], "bullet_type_state.despawnHit")
        self.assertEqual(despawn_hit["godot_owner"], "PortGame.source_bullet_type_despawned_dispatch_state")
        self.assertEqual(despawn_hit["runtime_proof"], "/root/Main.source_bullet_type_despawned_dispatch_state")

        bullet_x = source_symbols.source_symbol(registry, "despawned.dispatch.bullet_x")
        self.assertEqual(bullet_x["java_expr"], "b.x")
        self.assertEqual(bullet_x["godot_symbol"], "bullet_state.x")

        bullet_y = source_symbols.source_symbol(registry, "despawned.dispatch.bullet_y")
        self.assertEqual(bullet_y["java_expr"], "b.y")
        self.assertEqual(bullet_y["godot_symbol"], "bullet_state.y")

        hit_call = source_symbols.source_symbol(registry, "despawned.dispatch.hit_call")
        self.assertEqual(hit_call["java_expr"], "hit(b, b.x, b.y, false)")
        self.assertEqual(hit_call["godot_symbol"], "despawned_dispatch_result.hitCall")

        create_units_call = source_symbols.source_symbol(registry, "despawned.dispatch.create_units_call")
        self.assertEqual(create_units_call["java_expr"], "createUnits(b, b.x, b.y)")
        self.assertEqual(create_units_call["godot_symbol"], "despawned_dispatch_result.createUnitsCall")

        effect_boundary = source_symbols.source_symbol(registry, "despawned.dispatch.effect_boundary")
        self.assertEqual(effect_boundary["status"], "deferred")
        self.assertEqual(effect_boundary["java_expr"], "despawnEffect.at(b.x, b.y, b.rotation(), hitColor);")

        sound_boundary = source_symbols.source_symbol(registry, "despawned.dispatch.sound_boundary")
        self.assertEqual(sound_boundary["status"], "deferred")
        self.assertEqual(sound_boundary["java_expr"], "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));")

        shake_boundary = source_symbols.source_symbol(registry, "despawned.dispatch.shake_boundary")
        self.assertEqual(shake_boundary["status"], "deferred")
        self.assertEqual(shake_boundary["java_expr"], "Effect.shake(despawnShake, despawnShake, b);")

    def test_bullet_type_despawned_effect_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        despawn_effect = source_symbols.source_symbol(registry, "despawned.effect.despawn_effect")
        self.assertEqual(despawn_effect["java_expr"], "despawnEffect")
        self.assertEqual(despawn_effect["godot_symbol"], "bullet_type_state.despawnEffect")
        self.assertEqual(despawn_effect["godot_owner"], "PortGame.source_bullet_type_despawned_effect_state")
        self.assertEqual(despawn_effect["runtime_proof"], "/root/Main.source_bullet_type_despawned_effect_state")

        hit_color = source_symbols.source_symbol(registry, "despawned.effect.hit_color")
        self.assertEqual(hit_color["java_expr"], "hitColor")
        self.assertEqual(hit_color["godot_symbol"], "bullet_type_state.hitColor")

        effect_call = source_symbols.source_symbol(registry, "despawned.effect.effect_call")
        self.assertEqual(effect_call["java_expr"], "despawnEffect.at(b.x, b.y, b.rotation(), hitColor)")
        self.assertEqual(effect_call["godot_symbol"], "despawned_effect_result.despawnEffectCall")

        sound_boundary = source_symbols.source_symbol(registry, "despawned.effect.sound_boundary")
        self.assertEqual(sound_boundary["status"], "deferred")
        self.assertEqual(sound_boundary["java_expr"], "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));")

        shake_boundary = source_symbols.source_symbol(registry, "despawned.effect.shake_boundary")
        self.assertEqual(shake_boundary["status"], "deferred")
        self.assertEqual(shake_boundary["java_expr"], "Effect.shake(despawnShake, despawnShake, b);")

    def test_bullet_type_despawned_sound_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        despawn_sound = source_symbols.source_symbol(registry, "despawned.sound.despawn_sound")
        self.assertEqual(despawn_sound["java_expr"], "despawnSound")
        self.assertEqual(despawn_sound["godot_symbol"], "bullet_type_state.despawnSound")
        self.assertEqual(despawn_sound["godot_owner"], "PortGame.source_bullet_type_despawned_sound_state")
        self.assertEqual(despawn_sound["runtime_proof"], "/root/Main.source_bullet_type_despawned_sound_state")

        pitch_range = source_symbols.source_symbol(registry, "despawned.sound.hit_sound_pitch_range")
        self.assertEqual(pitch_range["java_expr"], "hitSoundPitchRange")
        self.assertEqual(pitch_range["godot_symbol"], "bullet_type_state.hitSoundPitchRange")

        range_sample = source_symbols.source_symbol(registry, "despawned.sound.range_sample")
        self.assertEqual(range_sample["java_expr"], "Mathf.range(hitSoundPitchRange)")
        self.assertEqual(range_sample["godot_symbol"], "despawn_sound_random_state.rangeSample")
        self.assertEqual(range_sample["status"], "explicit-input")

        sound_call = source_symbols.source_symbol(registry, "despawned.sound.sound_call")
        self.assertEqual(sound_call["java_expr"], "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange))")
        self.assertEqual(sound_call["godot_symbol"], "despawned_sound_result.despawnSoundCall")

        shake_boundary = source_symbols.source_symbol(registry, "despawned.sound.shake_boundary")
        self.assertEqual(shake_boundary["status"], "deferred")
        self.assertEqual(shake_boundary["java_expr"], "Effect.shake(despawnShake, despawnShake, b);")

    def test_bullet_type_despawned_shake_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        despawn_shake = source_symbols.source_symbol(registry, "despawned.shake.despawn_shake")
        self.assertEqual(despawn_shake["java_expr"], "despawnShake")
        self.assertEqual(despawn_shake["godot_symbol"], "bullet_type_state.despawnShake")
        self.assertEqual(despawn_shake["godot_owner"], "PortGame.source_bullet_type_despawned_shake_state")
        self.assertEqual(despawn_shake["runtime_proof"], "/root/Main.source_bullet_type_despawned_shake_state")

        shake_call = source_symbols.source_symbol(registry, "despawned.shake.shake_call")
        self.assertEqual(shake_call["java_expr"], "Effect.shake(despawnShake, despawnShake, b)")
        self.assertEqual(shake_call["godot_symbol"], "despawned_shake_result.shakeCall")

        effect_position = source_symbols.source_symbol(registry, "despawned.shake.effect_shake_position")
        self.assertEqual(effect_position["java_expr"], "shake(intensity, duration, loc.getX(), loc.getY())")
        self.assertEqual(effect_position["godot_symbol"], "despawned_shake_result.effectShakePositionSource")

        removed_boundary = source_symbols.source_symbol(registry, "despawned.shake.removed_boundary")
        self.assertEqual(removed_boundary["status"], "deferred")
        self.assertEqual(removed_boundary["java_expr"], "public void removed(Bullet b){")

    def test_bullet_type_removed_trail_fade_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        trail_length = source_symbols.source_symbol(registry, "removed.trail_fade.trail_length")
        self.assertEqual(trail_length["java_expr"], "trailLength")
        self.assertEqual(trail_length["godot_symbol"], "bullet_type_state.trailLength")
        self.assertEqual(trail_length["godot_owner"], "PortGame.source_bullet_type_removed_trail_fade_state")
        self.assertEqual(trail_length["runtime_proof"], "/root/Main.source_bullet_type_removed_trail_fade_state")

        trail_size = source_symbols.source_symbol(registry, "removed.trail_fade.trail_size")
        self.assertEqual(trail_size["java_expr"], "b.trail.size()")
        self.assertEqual(trail_size["godot_symbol"], "bullet_state.trail.size")
        self.assertEqual(trail_size["status"], "explicit-input")

        trail_fade_call = source_symbols.source_symbol(registry, "removed.trail_fade.trail_fade_call")
        self.assertEqual(trail_fade_call["java_expr"], "Fx.trailFade.at(b.x, b.y, trailWidth, trailColor, b.trail.copy())")
        self.assertEqual(trail_fade_call["godot_symbol"], "removed_trail_fade_result.trailFadeCall")

        frag_boundary = source_symbols.source_symbol(registry, "removed.trail_fade.frag_boundary")
        self.assertEqual(frag_boundary["status"], "deferred")
        self.assertEqual(frag_boundary["java_expr"], "if(b.frags == 0 && fragOnDespawn && fragBullet != null){")

    def test_bullet_type_removed_frag_dispatch_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        frag_on_despawn = source_symbols.source_symbol(registry, "removed.frag_dispatch.frag_on_despawn")
        self.assertEqual(frag_on_despawn["java_expr"], "fragOnDespawn")
        self.assertEqual(frag_on_despawn["godot_symbol"], "bullet_type_state.fragOnDespawn")
        self.assertEqual(frag_on_despawn["godot_owner"], "PortGame.source_bullet_type_removed_frag_dispatch_state")
        self.assertEqual(frag_on_despawn["runtime_proof"], "/root/Main.source_bullet_type_removed_frag_dispatch_state")

        bullet_frags = source_symbols.source_symbol(registry, "removed.frag_dispatch.bullet_frags")
        self.assertEqual(bullet_frags["java_expr"], "b.frags")
        self.assertEqual(bullet_frags["godot_symbol"], "bullet_state.frags")

        gate = source_symbols.source_symbol(registry, "removed.frag_dispatch.frag_gate")
        self.assertEqual(gate["java_expr"], "b.frags == 0 && fragOnDespawn && fragBullet != null")
        self.assertEqual(gate["godot_symbol"], "removed_frag_dispatch_result.fragGatePassed")

        create_frags_call = source_symbols.source_symbol(registry, "removed.frag_dispatch.create_frags_call")
        self.assertEqual(create_frags_call["java_expr"], "createFrags(b, b.x, b.y)")
        self.assertEqual(create_frags_call["godot_symbol"], "removed_frag_dispatch_result.createFragsCall")

        boundary = source_symbols.source_symbol(registry, "removed.frag_dispatch.building_damage_boundary")
        self.assertEqual(boundary["status"], "deferred")
        self.assertEqual(boundary["java_expr"], "public float buildingDamage(Bullet b){")

    def test_bullet_type_building_damage_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        damage = source_symbols.source_symbol(registry, "building_damage.damage")
        self.assertEqual(damage["java_expr"], "b.damage()")
        self.assertEqual(damage["godot_symbol"], "bullet_state.damage")
        self.assertEqual(damage["godot_owner"], "PortGame.source_bullet_type_building_damage_state")
        self.assertEqual(damage["runtime_proof"], "/root/Main.source_bullet_type_building_damage_state")

        multiplier = source_symbols.source_symbol(registry, "building_damage.building_damage_multiplier")
        self.assertEqual(multiplier["java_expr"], "b.buildingDamageMultiplier")
        self.assertEqual(multiplier["godot_symbol"], "bullet_state.buildingDamageMultiplier")

        return_value = source_symbols.source_symbol(registry, "building_damage.return_value")
        self.assertEqual(return_value["java_expr"], "b.damage() * b.buildingDamageMultiplier")
        self.assertEqual(return_value["godot_symbol"], "building_damage_result.buildingDamage")

        shield_boundary = source_symbols.source_symbol(registry, "building_damage.shield_damage_boundary")
        self.assertEqual(shield_boundary["status"], "deferred")
        self.assertEqual(shield_boundary["java_expr"], "public float shieldDamage(Bullet b){")

    def test_bullet_type_shield_damage_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        damage = source_symbols.source_symbol(registry, "shield_damage.damage")
        self.assertEqual(damage["java_expr"], "b.damage()")
        self.assertEqual(damage["godot_symbol"], "bullet_state.damage")
        self.assertEqual(damage["godot_owner"], "PortGame.source_bullet_type_shield_damage_state")
        self.assertEqual(damage["runtime_proof"], "/root/Main.source_bullet_type_shield_damage_state")

        multiplier = source_symbols.source_symbol(registry, "shield_damage.shield_damage_multiplier")
        self.assertEqual(multiplier["java_expr"], "shieldDamageMultiplier")
        self.assertEqual(multiplier["godot_symbol"], "bullet_type_state.shieldDamageMultiplier")

        return_value = source_symbols.source_symbol(registry, "shield_damage.return_value")
        self.assertEqual(return_value["java_expr"], "b.damage() * shieldDamageMultiplier")
        self.assertEqual(return_value["godot_symbol"], "shield_damage_result.shieldDamage")

        draw_boundary = source_symbols.source_symbol(registry, "shield_damage.draw_boundary")
        self.assertEqual(draw_boundary["status"], "deferred")
        self.assertEqual(draw_boundary["java_expr"], "public void draw(Bullet b){")

    def test_bullet_type_draw_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        draw_trail_call = source_symbols.source_symbol(registry, "draw.draw_trail_call")
        self.assertEqual(draw_trail_call["java_expr"], "drawTrail(b);")
        self.assertEqual(draw_trail_call["godot_symbol"], "draw_result.drawTrailCalled")
        self.assertEqual(draw_trail_call["godot_owner"], "PortGame.source_bullet_type_draw_state")
        self.assertEqual(draw_trail_call["runtime_proof"], "/root/Main.source_bullet_type_draw_state")

        draw_parts_call = source_symbols.source_symbol(registry, "draw.draw_parts_call")
        self.assertEqual(draw_parts_call["java_expr"], "drawParts(b);")
        self.assertEqual(draw_parts_call["godot_symbol"], "draw_result.drawPartsCalled")

        return_source = source_symbols.source_symbol(registry, "draw.return_source")
        self.assertEqual(return_source["java_expr"], "drawTrail(b); drawParts(b);")
        self.assertEqual(return_source["godot_symbol"], "draw_result.drawReturnSource")

        draw_trail_boundary = source_symbols.source_symbol(registry, "draw.draw_trail_boundary")
        self.assertEqual(draw_trail_boundary["status"], "deferred")
        self.assertEqual(draw_trail_boundary["java_expr"], "public void drawTrail(Bullet b){")

    def test_bullet_type_draw_trail_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "draw_trail.gate")
        self.assertEqual(gate["java_expr"], "if(trailLength > 0 && b.trail != null){")
        self.assertEqual(gate["godot_symbol"], "draw_trail_result.gatePassed")
        self.assertEqual(gate["godot_owner"], "PortGame.source_bullet_type_draw_trail_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_bullet_type_draw_trail_state")

        trail_draw_call = source_symbols.source_symbol(registry, "draw_trail.trail_draw_call")
        self.assertEqual(trail_draw_call["java_expr"], "b.trail.draw(trailColor, trailWidth)")
        self.assertEqual(trail_draw_call["godot_symbol"], "draw_trail_result.trailDrawCall")

        draw_z_below = source_symbols.source_symbol(registry, "draw_trail.draw_z_below")
        self.assertEqual(draw_z_below["java_expr"], "Draw.z(z - 0.0001f)")
        self.assertEqual(draw_z_below["godot_symbol"], "draw_trail_result.drawZBelow")

        draw_parts_boundary = source_symbols.source_symbol(registry, "draw_trail.draw_parts_boundary")
        self.assertEqual(draw_parts_boundary["status"], "deferred")
        self.assertEqual(draw_parts_boundary["java_expr"], "public void drawParts(Bullet b){")

    def test_bullet_type_draw_light_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        early_return = source_symbols.source_symbol(registry, "draw_light.early_return")
        self.assertEqual(early_return["java_expr"], "if(lightOpacity <= 0f || lightRadius <= 0f) return;")
        self.assertEqual(early_return["godot_symbol"], "draw_light_result.gatePassed")
        self.assertEqual(early_return["godot_owner"], "PortGame.source_bullet_type_draw_light_state")
        self.assertEqual(early_return["runtime_proof"], "/root/Main.source_bullet_type_draw_light_state")

        drawf_light_call = source_symbols.source_symbol(registry, "draw_light.drawf_light_call")
        self.assertEqual(drawf_light_call["java_expr"], "Drawf.light(b, lightRadius, lightColor, lightOpacity);")
        self.assertEqual(drawf_light_call["godot_symbol"], "draw_light_result.drawfLightCall")

        light_color = source_symbols.source_symbol(registry, "draw_light.light_color")
        self.assertEqual(light_color["java_expr"], "lightColor")
        self.assertEqual(light_color["godot_symbol"], "draw_light_result.lightColor")

        init_boundary = source_symbols.source_symbol(registry, "draw_light.init_boundary")
        self.assertEqual(init_boundary["status"], "deferred")
        self.assertEqual(init_boundary["java_expr"], "public void init(Bullet b){")

    def test_bullet_type_init_initial_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        kill_shooter_gate = source_symbols.source_symbol(registry, "init_initial.kill_shooter_gate")
        self.assertEqual(kill_shooter_gate["java_expr"], "if(killShooter && b.owner() instanceof Healthc h && !h.dead()){")
        self.assertEqual(kill_shooter_gate["godot_symbol"], "init_initial_result.killShooterApplied")
        self.assertEqual(kill_shooter_gate["godot_owner"], "PortGame.source_bullet_type_init_initial_state")
        self.assertEqual(kill_shooter_gate["runtime_proof"], "/root/Main.source_bullet_type_init_initial_state")

        kill_call = source_symbols.source_symbol(registry, "init_initial.kill_call")
        self.assertEqual(kill_call["java_expr"], "h.kill();")
        self.assertEqual(kill_call["godot_symbol"], "init_initial_result.owner")

        instant_disappear = source_symbols.source_symbol(registry, "init_initial.instant_disappear_assignment")
        self.assertEqual(instant_disappear["java_expr"], "b.time = lifetime + 1f;")
        self.assertEqual(instant_disappear["godot_symbol"], "init_initial_result.bullet.time")

        spawn_boundary = source_symbols.source_symbol(registry, "init_initial.spawn_bullets_boundary")
        self.assertEqual(spawn_boundary["status"], "deferred")
        self.assertEqual(spawn_boundary["java_expr"], "if(spawnBullets.size > 0){")

    def test_bullet_type_init_spawn_bullets_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "init_spawn_bullets.gate")
        self.assertEqual(gate["java_expr"], "if(spawnBullets.size > 0){")
        self.assertEqual(gate["godot_symbol"], "init_spawn_bullets_result.spawnBulletsApplied")
        self.assertEqual(gate["godot_owner"], "PortGame.source_bullet_type_init_spawn_bullets_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_bullet_type_init_spawn_bullets_state")

        loop = source_symbols.source_symbol(registry, "init_spawn_bullets.loop")
        self.assertEqual(loop["java_expr"], "for(var bullet : spawnBullets){")
        self.assertEqual(loop["godot_symbol"], "init_spawn_bullets_result.spawnBulletCount")

        create_call = source_symbols.source_symbol(registry, "init_spawn_bullets.create_call")
        self.assertEqual(create_call["java_expr"], "bullet.create(b, b.x, b.y, b.rotation() + Mathf.range(spawnBulletRandomSpread));")
        self.assertEqual(create_call["godot_symbol"], "init_spawn_bullets_result.spawnBulletCalls")

        random_offset = source_symbols.source_symbol(registry, "init_spawn_bullets.random_offset")
        self.assertEqual(random_offset["status"], "explicit-input")
        self.assertEqual(random_offset["java_expr"], "Mathf.range(spawnBulletRandomSpread)")
        self.assertEqual(random_offset["godot_symbol"], "spawn_bullet_random_state.offsets")

        update_boundary = source_symbols.source_symbol(registry, "init_spawn_bullets.update_boundary")
        self.assertEqual(update_boundary["status"], "deferred")
        self.assertEqual(update_boundary["java_expr"], "public void update(Bullet b){")

    def test_bullet_type_update_dispatch_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        update_trail = source_symbols.source_symbol(registry, "update_dispatch.update_trail_call")
        self.assertEqual(update_trail["java_expr"], "updateTrail(b);")
        self.assertEqual(update_trail["godot_symbol"], "update_dispatch_result.callOrder[0]")
        self.assertEqual(update_trail["godot_owner"], "PortGame.source_bullet_type_update_dispatch_state")
        self.assertEqual(update_trail["runtime_proof"], "/root/Main.source_bullet_type_update_dispatch_state")

        update_homing = source_symbols.source_symbol(registry, "update_dispatch.update_homing_call")
        self.assertEqual(update_homing["java_expr"], "updateHoming(b);")
        self.assertEqual(update_homing["godot_symbol"], "update_dispatch_result.callOrder[1]")

        update_weaving = source_symbols.source_symbol(registry, "update_dispatch.update_weaving_call")
        self.assertEqual(update_weaving["java_expr"], "updateWeaving(b);")
        self.assertEqual(update_weaving["godot_symbol"], "update_dispatch_result.callOrder[2]")

        update_trail_effects = source_symbols.source_symbol(registry, "update_dispatch.update_trail_effects_call")
        self.assertEqual(update_trail_effects["java_expr"], "updateTrailEffects(b);")
        self.assertEqual(update_trail_effects["godot_symbol"], "update_dispatch_result.callOrder[3]")

        update_interval = source_symbols.source_symbol(registry, "update_dispatch.update_bullet_interval_call")
        self.assertEqual(update_interval["java_expr"], "updateBulletInterval(b);")
        self.assertEqual(update_interval["godot_symbol"], "update_dispatch_result.callOrder[4]")

        interval_boundary = source_symbols.source_symbol(registry, "update_dispatch.update_bullet_interval_boundary")
        self.assertEqual(interval_boundary["status"], "deferred")
        self.assertEqual(interval_boundary["java_expr"], "public void updateBulletInterval(Bullet b){")

    def test_bullet_type_update_bullet_interval_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "update_bullet_interval.gate")
        self.assertEqual(gate["java_expr"], "if(intervalBullet != null && b.time >= intervalDelay && b.timer.get(2, bulletInterval)){")
        self.assertEqual(gate["godot_symbol"], "update_bullet_interval_result.gatePassed")
        self.assertEqual(gate["godot_owner"], "PortGame.source_bullet_type_update_bullet_interval_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_bullet_type_update_bullet_interval_state")

        timer_get = source_symbols.source_symbol(registry, "update_bullet_interval.timer_get")
        self.assertEqual(timer_get["status"], "explicit-input")
        self.assertEqual(timer_get["java_expr"], "b.timer.get(2, bulletInterval)")
        self.assertEqual(timer_get["godot_symbol"], "interval_timer_state.timerGetResult")

        timer_index = source_symbols.source_symbol(registry, "update_bullet_interval.timer_index")
        self.assertEqual(timer_index["java_expr"], "b.timer.get(2, bulletInterval)")
        self.assertEqual(timer_index["godot_symbol"], "update_bullet_interval_result.timerIndex")

        timer_time = source_symbols.source_symbol(registry, "update_bullet_interval.timer_time")
        self.assertEqual(timer_time["java_expr"], "bulletInterval")
        self.assertEqual(timer_time["godot_symbol"], "update_bullet_interval_result.timerTime")

        angle = source_symbols.source_symbol(registry, "update_bullet_interval.angle")
        self.assertEqual(angle["java_expr"], "float ang = b.rotation();")
        self.assertEqual(angle["godot_symbol"], "update_bullet_interval_result.baseAngle")

        loop = source_symbols.source_symbol(registry, "update_bullet_interval.loop")
        self.assertEqual(loop["java_expr"], "for(int i = 0; i < intervalBullets; i++){")
        self.assertEqual(loop["godot_symbol"], "update_bullet_interval_result.intervalBulletCount")

        create_call = source_symbols.source_symbol(registry, "update_bullet_interval.create_call")
        self.assertEqual(create_call["java_expr"], "intervalBullet.create(b, b.x, b.y, ang + Mathf.range(intervalRandomSpread) + intervalAngle + ((i - (intervalBullets - 1f)/2f) * intervalSpread));")
        self.assertEqual(create_call["godot_symbol"], "update_bullet_interval_result.intervalBulletCalls")

        random_offset = source_symbols.source_symbol(registry, "update_bullet_interval.random_offset")
        self.assertEqual(random_offset["status"], "explicit-input")
        self.assertEqual(random_offset["java_expr"], "Mathf.range(intervalRandomSpread)")
        self.assertEqual(random_offset["godot_symbol"], "interval_random_state.offsets")

        homing_boundary = source_symbols.source_symbol(registry, "update_bullet_interval.update_homing_boundary")
        self.assertEqual(homing_boundary["status"], "deferred")
        self.assertEqual(homing_boundary["java_expr"], "public void updateHoming(Bullet b){")

    def test_bullet_type_update_trail_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "update_trail.gate")
        self.assertEqual(gate["java_expr"], "if(!headless && trailLength > 0){")
        self.assertEqual(gate["godot_symbol"], "update_trail_result.gatePassed")
        self.assertEqual(gate["godot_owner"], "PortGame.source_bullet_type_update_trail_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_bullet_type_update_trail_state")

        headless = source_symbols.source_symbol(registry, "update_trail.headless")
        self.assertEqual(headless["status"], "explicit-input")
        self.assertEqual(headless["java_expr"], "headless")
        self.assertEqual(headless["godot_symbol"], "headless_state.headless")

        null_guard = source_symbols.source_symbol(registry, "update_trail.trail_null_guard")
        self.assertEqual(null_guard["java_expr"], "if(b.trail == null){")
        self.assertEqual(null_guard["godot_symbol"], "update_trail_result.trailCreated")

        length_assignment = source_symbols.source_symbol(registry, "update_trail.length_assignment")
        self.assertEqual(length_assignment["java_expr"], "b.trail.length = trailLength;")
        self.assertEqual(length_assignment["godot_symbol"], "update_trail_result.trail.length")

        update_call = source_symbols.source_symbol(registry, "update_trail.update_call")
        self.assertEqual(update_call["java_expr"], "b.trail.update(b.x, b.y, trailInterp.apply(b.fin()) * (1f + (trailSinMag > 0 ? Mathf.absin(Time.time, trailSinScl, trailSinMag) : 0f)));")
        self.assertEqual(update_call["godot_symbol"], "update_trail_result.trail")

        trail_interp = source_symbols.source_symbol(registry, "update_trail.trail_interp_value")
        self.assertEqual(trail_interp["status"], "explicit-input")
        self.assertEqual(trail_interp["java_expr"], "trailInterp.apply(b.fin())")
        self.assertEqual(trail_interp["godot_symbol"], "trail_interp_state.trailInterpValue")

        absin = source_symbols.source_symbol(registry, "update_trail.absin_value")
        self.assertEqual(absin["status"], "explicit-input")
        self.assertEqual(absin["java_expr"], "Mathf.absin(Time.time, trailSinScl, trailSinMag)")
        self.assertEqual(absin["godot_symbol"], "trail_absin_state.absinValue")

        time_delta = source_symbols.source_symbol(registry, "update_trail.time_delta")
        self.assertEqual(time_delta["status"], "explicit-input")
        self.assertEqual(time_delta["java_expr"], "Time.delta")
        self.assertEqual(time_delta["godot_symbol"], "time_state.delta")

        init_boundary = source_symbols.source_symbol(registry, "update_trail.init_boundary")
        self.assertEqual(init_boundary["status"], "deferred")
        self.assertEqual(init_boundary["java_expr"], "public void init(){")

    def test_bullet_type_update_homing_initial_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "update_homing_initial.gate")
        self.assertEqual(gate["java_expr"], "if(homingPower > 0.0001f && b.time >= homingDelay){")
        self.assertEqual(gate["godot_symbol"], "update_homing_initial_result.gatePassed")
        self.assertEqual(gate["godot_owner"], "PortGame.source_bullet_type_update_homing_initial_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_bullet_type_update_homing_initial_state")

        real_aim_x = source_symbols.source_symbol(registry, "update_homing_initial.real_aim_x")
        self.assertEqual(real_aim_x["java_expr"], "float realAimX = b.aimX < 0 ? b.x : b.aimX;")
        self.assertEqual(real_aim_x["godot_symbol"], "update_homing_initial_result.realAimX")

        real_aim_y = source_symbols.source_symbol(registry, "update_homing_initial.real_aim_y")
        self.assertEqual(real_aim_y["java_expr"], "float realAimY = b.aimY < 0 ? b.y : b.aimY;")
        self.assertEqual(real_aim_y["godot_symbol"], "update_homing_initial_result.realAimY")

        aim_x = source_symbols.source_symbol(registry, "update_homing_initial.aim_x")
        self.assertEqual(aim_x["status"], "explicit-input")
        self.assertEqual(aim_x["java_expr"], "b.aimX")
        self.assertEqual(aim_x["godot_symbol"], "bullet_state.aimX")

        aim_y = source_symbols.source_symbol(registry, "update_homing_initial.aim_y")
        self.assertEqual(aim_y["status"], "explicit-input")
        self.assertEqual(aim_y["java_expr"], "b.aimY")
        self.assertEqual(aim_y["godot_symbol"], "bullet_state.aimY")

        target_reserved = source_symbols.source_symbol(registry, "update_homing_initial.target_reserved")
        self.assertEqual(target_reserved["status"], "deferred")
        self.assertEqual(target_reserved["java_expr"], "Teamc target;")
        self.assertEqual(target_reserved["godot_symbol"], "update_homing_initial_result.targetReservedSource")

        follow_reserved = source_symbols.source_symbol(registry, "update_homing_initial.follow_aim_reserved")
        self.assertEqual(follow_reserved["status"], "deferred")
        self.assertEqual(follow_reserved["java_expr"], "if(followAimSpeed > 0f && b.shooter instanceof Unit u){")
        self.assertEqual(follow_reserved["godot_symbol"], "update_homing_initial_result.followAimReservedSource")

    def test_bullet_type_update_homing_target_velocity_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        target_gate = source_symbols.source_symbol(registry, "update_homing_target_velocity.target_gate")
        self.assertEqual(target_gate["java_expr"], "if(target != null){")
        self.assertEqual(target_gate["godot_symbol"], "update_homing_target_velocity_result.targetGatePassed")
        self.assertEqual(target_gate["godot_owner"], "PortGame.source_bullet_type_update_homing_target_velocity_state")
        self.assertEqual(target_gate["runtime_proof"], "/root/Main.source_bullet_type_update_homing_target_velocity_state")

        set_angle = source_symbols.source_symbol(registry, "update_homing_target_velocity.set_angle")
        self.assertEqual(set_angle["java_expr"], "b.vel.setAngle(Angles.moveToward(b.rotation(), b.angleTo(target), homingPower * Time.delta * 50f));")
        self.assertEqual(set_angle["godot_symbol"], "update_homing_target_velocity_result.velocity")

        current_rotation = source_symbols.source_symbol(registry, "update_homing_target_velocity.current_rotation")
        self.assertEqual(current_rotation["java_expr"], "b.rotation()")
        self.assertEqual(current_rotation["godot_symbol"], "update_homing_target_velocity_result.currentRotation")

        target_angle = source_symbols.source_symbol(registry, "update_homing_target_velocity.target_angle")
        self.assertEqual(target_angle["java_expr"], "b.angleTo(target)")
        self.assertEqual(target_angle["godot_symbol"], "update_homing_target_velocity_result.targetAngle")

        max_turn = source_symbols.source_symbol(registry, "update_homing_target_velocity.max_turn")
        self.assertEqual(max_turn["java_expr"], "homingPower * Time.delta * 50f")
        self.assertEqual(max_turn["godot_symbol"], "update_homing_target_velocity_result.maxTurn")

        move_toward = source_symbols.source_symbol(registry, "update_homing_target_velocity.move_toward")
        self.assertEqual(move_toward["java_expr"], "Angles.moveToward(b.rotation(), b.angleTo(target), homingPower * Time.delta * 50f)")
        self.assertEqual(move_toward["godot_symbol"], "update_homing_target_velocity_result.nextAngle")

        target_state = source_symbols.source_symbol(registry, "update_homing_target_velocity.target_state")
        self.assertEqual(target_state["status"], "explicit-input")
        self.assertEqual(target_state["java_expr"], "target")
        self.assertEqual(target_state["godot_symbol"], "target_state")

        velocity = source_symbols.source_symbol(registry, "update_homing_target_velocity.velocity")
        self.assertEqual(velocity["java_expr"], "b.vel")
        self.assertEqual(velocity["godot_symbol"], "bullet_state.velocity")

        angle_to = source_symbols.source_symbol(registry, "update_homing_target_velocity.position_angle_to")
        self.assertEqual(angle_to["java_source"], "arc-core/src/arc/math/geom/Position.java")
        self.assertEqual(angle_to["java_expr"], "return Angles.angle(getX(), getY(), other.getX(), other.getY());")

        vec2_set_angle = source_symbols.source_symbol(registry, "update_homing_target_velocity.vec2_set_angle")
        self.assertEqual(vec2_set_angle["java_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(vec2_set_angle["java_expr"], "this.set(len(), 0f); this.rotateRad(radians);")

    def test_bullet_type_update_homing_follow_aim_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        follow_gate = source_symbols.source_symbol(registry, "update_homing_follow_aim.gate")
        self.assertEqual(follow_gate["java_expr"], "if(followAimSpeed > 0f && b.shooter instanceof Unit u){")
        self.assertEqual(follow_gate["godot_symbol"], "update_homing_follow_aim_result.followAimGatePassed")
        self.assertEqual(follow_gate["godot_owner"], "PortGame.source_bullet_type_update_homing_follow_aim_state")
        self.assertEqual(follow_gate["runtime_proof"], "/root/Main.source_bullet_type_update_homing_follow_aim_state")

        angle = source_symbols.source_symbol(registry, "update_homing_follow_aim.angle")
        self.assertEqual(angle["java_expr"], "float angle = b.angleTo(u.aimX, u.aimY);")
        self.assertEqual(angle["godot_symbol"], "update_homing_follow_aim_result.targetAngle")

        set_angle = source_symbols.source_symbol(registry, "update_homing_follow_aim.set_angle")
        self.assertEqual(set_angle["java_expr"], "b.vel.setAngle(Angles.moveToward(b.vel.angle(), angle, followAimSpeed * Time.delta));")
        self.assertEqual(set_angle["godot_symbol"], "update_homing_follow_aim_result.velocity")

        velocity_angle = source_symbols.source_symbol(registry, "update_homing_follow_aim.velocity_angle")
        self.assertEqual(velocity_angle["java_expr"], "b.vel.angle()")
        self.assertEqual(velocity_angle["godot_symbol"], "update_homing_follow_aim_result.currentVelocityAngle")

        max_turn = source_symbols.source_symbol(registry, "update_homing_follow_aim.max_turn")
        self.assertEqual(max_turn["java_expr"], "followAimSpeed * Time.delta")
        self.assertEqual(max_turn["godot_symbol"], "update_homing_follow_aim_result.maxTurn")

        move_toward = source_symbols.source_symbol(registry, "update_homing_follow_aim.move_toward")
        self.assertEqual(move_toward["java_expr"], "Angles.moveToward(b.vel.angle(), angle, followAimSpeed * Time.delta)")
        self.assertEqual(move_toward["godot_symbol"], "update_homing_follow_aim_result.nextAngle")

        shooter = source_symbols.source_symbol(registry, "update_homing_follow_aim.shooter_state")
        self.assertEqual(shooter["status"], "explicit-input")
        self.assertEqual(shooter["java_expr"], "b.shooter instanceof Unit u")
        self.assertEqual(shooter["godot_symbol"], "shooter_state.isUnit")

    def test_bullet_type_update_weaving_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "update_weaving.gate")
        self.assertEqual(gate["java_expr"], "if(weaveMag != 0){")
        self.assertEqual(gate["godot_symbol"], "update_weaving_result.weaveGatePassed")
        self.assertEqual(gate["godot_owner"], "PortGame.source_bullet_type_update_weaving_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_bullet_type_update_weaving_state")

        rotate_call = source_symbols.source_symbol(registry, "update_weaving.rotate_rad_exact")
        self.assertEqual(rotate_call["java_expr"], "b.vel.rotateRadExact((float)Math.sin((b.time + Math.PI * weaveScale/2f) / weaveScale) * weaveMag * (weaveRandom ? (Mathf.randomSeed(b.id, 0, 1) == 1 ? -1 : 1) : 1f) * Time.delta * Mathf.degRad);")
        self.assertEqual(rotate_call["godot_symbol"], "update_weaving_result.velocity")

        rotation_radians = source_symbols.source_symbol(registry, "update_weaving.rotation_radians")
        self.assertEqual(rotation_radians["java_expr"], "(float)Math.sin((b.time + Math.PI * weaveScale/2f) / weaveScale) * weaveMag * (weaveRandom ? (Mathf.randomSeed(b.id, 0, 1) == 1 ? -1 : 1) : 1f) * Time.delta * Mathf.degRad")
        self.assertEqual(rotation_radians["godot_symbol"], "update_weaving_result.rotationRadians")

        random_seed = source_symbols.source_symbol(registry, "update_weaving.random_seed_result")
        self.assertEqual(random_seed["status"], "explicit-input")
        self.assertEqual(random_seed["java_expr"], "Mathf.randomSeed(b.id, 0, 1)")
        self.assertEqual(random_seed["godot_symbol"], "random_seed_result")

        velocity = source_symbols.source_symbol(registry, "update_weaving.velocity")
        self.assertEqual(velocity["java_expr"], "b.vel")
        self.assertEqual(velocity["godot_symbol"], "bullet_state.velocity")

        vec2_rotate = source_symbols.source_symbol(registry, "update_weaving.vec2_rotate_rad_exact")
        self.assertEqual(vec2_rotate["java_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(vec2_rotate["java_expr"], "float newX = this.x * cos - this.y * sin; float newY = this.x * sin + this.y * cos;")

    def test_bullet_type_update_weaving_rotate_speed_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "update_weaving_rotate_speed.gate")
        self.assertEqual(gate["java_expr"], "if(rotateSpeed != 0){")
        self.assertEqual(gate["godot_symbol"], "update_weaving_rotate_speed_result.rotateSpeedGatePassed")
        self.assertEqual(gate["godot_owner"], "PortGame.source_bullet_type_update_weaving_rotate_speed_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_bullet_type_update_weaving_rotate_speed_state")

        rotate_call = source_symbols.source_symbol(registry, "update_weaving_rotate_speed.rotate_call")
        self.assertEqual(rotate_call["java_expr"], "b.vel.rotate(rotateSpeed * Time.delta);")
        self.assertEqual(rotate_call["godot_symbol"], "update_weaving_rotate_speed_result.velocity")

        rotation_radians = source_symbols.source_symbol(registry, "update_weaving_rotate_speed.rotation_radians")
        self.assertEqual(rotation_radians["java_expr"], "rotateSpeed * Time.delta")
        self.assertEqual(rotation_radians["godot_symbol"], "update_weaving_rotate_speed_result.rotationRadians")

        vec2_rotate = source_symbols.source_symbol(registry, "update_weaving_rotate_speed.vec2_rotate")
        self.assertEqual(vec2_rotate["java_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(vec2_rotate["java_expr"], "return rotateRad(degrees * Mathf.degreesToRadians);")

    def test_bullet_type_update_weaving_circle_shooter_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "update_weaving_circle_shooter.gate")
        self.assertEqual(gate["java_expr"], "if(circleShooter && b.owner instanceof Healthc h && h.isValid()){")
        self.assertEqual(gate["godot_symbol"], "update_weaving_circle_shooter_result.circleShooterGatePassed")
        self.assertEqual(gate["godot_owner"], "PortGame.source_bullet_type_update_weaving_circle_shooter_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_bullet_type_update_weaving_circle_shooter_state")

        tmp_set_sub = source_symbols.source_symbol(registry, "update_weaving_circle_shooter.tmp_set_sub")
        self.assertEqual(tmp_set_sub["java_expr"], "Tmp.v1.set(h).sub(b);")
        self.assertEqual(tmp_set_sub["godot_symbol"], "update_weaving_circle_shooter_result.tmpBeforeRotate")

        tmp_rotate = source_symbols.source_symbol(registry, "update_weaving_circle_shooter.tmp_rotate")
        self.assertEqual(tmp_rotate["java_expr"], "Tmp.v1.rotate(90f * Mathf.lerp(0f, 1f, 1f - Mathf.clamp((Tmp.v1.len() - circleShooterRadius) / circleShooterRadiusSmooth)));")
        self.assertEqual(tmp_rotate["godot_symbol"], "update_weaving_circle_shooter_result.rotationDegrees")

        velocity = source_symbols.source_symbol(registry, "update_weaving_circle_shooter.velocity_add_limit")
        self.assertEqual(velocity["java_expr"], "b.vel.add(Tmp.v1.limit(speed * circleShooterRotateSpeed * Time.delta)).limit(speed);")
        self.assertEqual(velocity["godot_symbol"], "update_weaving_circle_shooter_result.velocity")

        mathf_lerp = source_symbols.source_symbol(registry, "update_weaving_circle_shooter.mathf_lerp")
        self.assertEqual(mathf_lerp["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertIn("return fromValue + (toValue - fromValue) * progress;", mathf_lerp["java_expr"])

        mathf_clamp = source_symbols.source_symbol(registry, "update_weaving_circle_shooter.mathf_clamp")
        self.assertEqual(mathf_clamp["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertIn("return Math.max(Math.min(value, 1f), 0f);", mathf_clamp["java_expr"])

    def test_bullet_type_update_trail_effects_chance_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        can_spawn = source_symbols.source_symbol(registry, "update_trail_effects_chance.can_spawn")
        self.assertEqual(can_spawn["java_expr"], "boolean canSpawn = trailMinVelocity <= 0f || b.vel.len2() >= trailMinVelocity * trailMinVelocity;")
        self.assertEqual(can_spawn["godot_symbol"], "update_trail_effects_chance_result.canSpawn")
        self.assertEqual(can_spawn["godot_owner"], "PortGame.source_bullet_type_update_trail_effects_chance_state")
        self.assertEqual(can_spawn["runtime_proof"], "/root/Main.source_bullet_type_update_trail_effects_chance_state")

        chance_gate = source_symbols.source_symbol(registry, "update_trail_effects_chance.chance_gate")
        self.assertEqual(chance_gate["java_expr"], "if(trailChance > 0 && canSpawn){")
        self.assertEqual(chance_gate["godot_symbol"], "update_trail_effects_chance_result.chanceGatePassed")

        chance_delta = source_symbols.source_symbol(registry, "update_trail_effects_chance.chance_delta")
        self.assertEqual(chance_delta["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertIn("return rand.nextFloat() < d * Time.delta;", chance_delta["java_expr"])
        self.assertEqual(chance_delta["godot_symbol"], "update_trail_effects_chance_result.chanceDeltaResult")

        spread_random = source_symbols.source_symbol(registry, "update_trail_effects_chance.spread_random")
        self.assertEqual(spread_random["java_expr"], "Tmp.v1.rnd(Mathf.random(trailSpread));")
        self.assertEqual(spread_random["godot_symbol"], "update_trail_effects_chance_result.tmpOffset")

        spread_zero = source_symbols.source_symbol(registry, "update_trail_effects_chance.spread_zero")
        self.assertEqual(spread_zero["java_expr"], "Tmp.v1.setZero();")
        self.assertEqual(spread_zero["godot_symbol"], "update_trail_effects_chance_result.tmpOffset")

        effect_at = source_symbols.source_symbol(registry, "update_trail_effects_chance.effect_at")
        self.assertEqual(effect_at["java_expr"], "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor);")
        self.assertEqual(effect_at["godot_symbol"], "update_trail_effects_chance_result.effectCalls")

        vec2_len2 = source_symbols.source_symbol(registry, "update_trail_effects_chance.vec2_len2")
        self.assertEqual(vec2_len2["java_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertIn("return x * x + y * y;", vec2_len2["java_expr"])

    def test_bullet_type_update_trail_effects_interval_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        interval_gate = source_symbols.source_symbol(registry, "update_trail_effects_interval.interval_gate")
        self.assertEqual(interval_gate["java_expr"], "if(trailInterval > 0f && canSpawn){")
        self.assertEqual(interval_gate["godot_symbol"], "update_trail_effects_interval_result.intervalGatePassed")
        self.assertEqual(interval_gate["godot_owner"], "PortGame.source_bullet_type_update_trail_effects_interval_state")
        self.assertEqual(interval_gate["runtime_proof"], "/root/Main.source_bullet_type_update_trail_effects_interval_state")

        timer_call = source_symbols.source_symbol(registry, "update_trail_effects_interval.timer_call")
        self.assertEqual(timer_call["java_expr"], "if(b.timer(0, trailInterval)){")
        self.assertEqual(timer_call["godot_symbol"], "update_trail_effects_interval_result.timerGetResult")

        timer_comp = source_symbols.source_symbol(registry, "update_trail_effects_interval.timer_comp")
        self.assertEqual(timer_comp["java_source"], "core/src/mindustry/entities/comp/TimerComp.java")
        self.assertIn("if(Float.isInfinite(time)) return false;", timer_comp["java_expr"])
        self.assertIn("return timer.get(index, time);", timer_comp["java_expr"])

        interval_get = source_symbols.source_symbol(registry, "update_trail_effects_interval.interval_get")
        self.assertEqual(interval_get["java_source"], "arc-core/src/arc/util/Interval.java")
        self.assertIn("boolean got = check(id, time);", interval_get["java_expr"])

        effect_at = source_symbols.source_symbol(registry, "update_trail_effects_interval.effect_at")
        self.assertEqual(effect_at["java_expr"], "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor);")
        self.assertEqual(effect_at["godot_symbol"], "update_trail_effects_interval_result.effectCalls")

    def test_bullet_type_init_type_defaults_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        pierce_gate = source_symbols.source_symbol(registry, "init_type_defaults.pierce_gate")
        self.assertEqual(pierce_gate["java_expr"], "if(pierceCap >= 1){")
        self.assertEqual(pierce_gate["godot_symbol"], "init_type_defaults_result.pierceApplied")
        self.assertEqual(pierce_gate["godot_owner"], "PortGame.source_bullet_type_init_type_defaults_state")
        self.assertEqual(pierce_gate["runtime_proof"], "/root/Main.source_bullet_type_init_type_defaults_state")

        pierce_assign = source_symbols.source_symbol(registry, "init_type_defaults.pierce_assign")
        self.assertEqual(pierce_assign["java_expr"], "pierce = true;")
        self.assertEqual(pierce_assign["godot_symbol"], "init_type_defaults_result.bulletType.pierce")

        set_defaults_gate = source_symbols.source_symbol(registry, "init_type_defaults.set_defaults_gate")
        self.assertEqual(set_defaults_gate["java_expr"], "if(setDefaults){")
        self.assertEqual(set_defaults_gate["godot_symbol"], "init_type_defaults_result.setDefaults")

        status_none_gate = source_symbols.source_symbol(registry, "init_type_defaults.status_none_gate")
        self.assertEqual(status_none_gate["java_expr"], "if(status == StatusEffects.none){")
        self.assertEqual(status_none_gate["godot_symbol"], "init_type_defaults_result.statusShockedApplied")

        status_shocked = source_symbols.source_symbol(registry, "init_type_defaults.status_shocked_assign")
        self.assertEqual(status_shocked["java_expr"], "status = StatusEffects.shocked;")
        self.assertEqual(status_shocked["godot_symbol"], "init_type_defaults_result.bulletType.status")

        despawn_hit_gate = source_symbols.source_symbol(registry, "init_type_defaults.despawn_hit_gate")
        self.assertEqual(despawn_hit_gate["java_expr"], "if(fragBullet != null || splashDamageRadius > 0 || lightning > 0){")
        self.assertEqual(despawn_hit_gate["godot_symbol"], "init_type_defaults_result.despawnHitApplied")

        status_effects_none = source_symbols.source_symbol(registry, "init_type_defaults.status_effects_none")
        self.assertEqual(status_effects_none["java_source"], "core/src/mindustry/content/StatusEffects.java")
        self.assertEqual(status_effects_none["java_expr"], "none = new StatusEffect(\"none\");")

    def test_bullet_type_init_frag_velocity_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        frag_gate = source_symbols.source_symbol(registry, "init_frag_velocity.frag_gate")
        self.assertEqual(frag_gate["java_expr"], "if(fragBullet != null){")
        self.assertEqual(frag_gate["godot_symbol"], "init_frag_velocity_result.fragGatePassed")
        self.assertEqual(frag_gate["godot_owner"], "PortGame.source_bullet_type_init_frag_velocity_state")
        self.assertEqual(frag_gate["runtime_proof"], "/root/Main.source_bullet_type_init_frag_velocity_state")

        keep_velocity = source_symbols.source_symbol(registry, "init_frag_velocity.frag_keep_velocity_assign")
        self.assertEqual(keep_velocity["java_expr"], "fragBullet.keepVelocity = false;")
        self.assertEqual(keep_velocity["godot_symbol"], "init_frag_velocity_result.fragBullet.keepVelocity")

        scale_keep_velocity = source_symbols.source_symbol(registry, "init_frag_velocity.frag_scale_keep_velocity_assign")
        self.assertEqual(scale_keep_velocity["java_expr"], "fragBullet.scaleKeepVelocity = false;")
        self.assertEqual(scale_keep_velocity["godot_symbol"], "init_frag_velocity_result.fragBullet.scaleKeepVelocity")

        keep_velocity_field = source_symbols.source_symbol(registry, "init_frag_velocity.keep_velocity_field")
        self.assertEqual(keep_velocity_field["java_expr"], "public boolean keepVelocity = true;")
        self.assertEqual(keep_velocity_field["godot_symbol"], "bullet_type_state.keepVelocity")

    def test_bullet_type_init_lightning_type_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "init_lightning_type.gate")
        self.assertEqual(gate["java_expr"], "if(lightningType == null){")
        self.assertEqual(gate["godot_symbol"], "init_lightning_type_result.lightningTypeGatePassed")
        self.assertEqual(gate["godot_owner"], "PortGame.source_bullet_type_init_lightning_type_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_bullet_type_init_lightning_type_state")

        choice = source_symbols.source_symbol(registry, "init_lightning_type.choice")
        self.assertEqual(choice["java_expr"], "!collidesAir ? Bullets.damageLightningGround : !collidesGround ? Bullets.damageLightningAir : Bullets.damageLightning;")
        self.assertEqual(choice["godot_symbol"], "init_lightning_type_result.lightningType")

        ground_copy = source_symbols.source_symbol(registry, "init_lightning_type.damage_lightning_ground_copy")
        self.assertEqual(ground_copy["java_source"], "core/src/mindustry/content/Bullets.java")
        self.assertEqual(ground_copy["java_expr"], "damageLightningGround = damageLightning.copy();")

        air_collides_tiles = source_symbols.source_symbol(registry, "init_lightning_type.damage_lightning_air_collides_tiles")
        self.assertEqual(air_collides_tiles["java_expr"], "damageLightningAir.collidesTiles = false;")

    def test_bullet_type_init_light_radius_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "init_light_radius.gate")
        self.assertEqual(gate["java_expr"], "if(lightRadius <= -1){")
        self.assertEqual(gate["godot_symbol"], "init_light_radius_result.lightRadiusGatePassed")
        self.assertEqual(gate["godot_owner"], "PortGame.source_bullet_type_init_light_radius_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_bullet_type_init_light_radius_state")

        assign = source_symbols.source_symbol(registry, "init_light_radius.assign")
        self.assertEqual(assign["java_expr"], "lightRadius = Math.max(18, hitSize * 5f);")
        self.assertEqual(assign["godot_symbol"], "init_light_radius_result.lightRadius")

        hit_size_field = source_symbols.source_symbol(registry, "init_light_radius.hit_size_field")
        self.assertEqual(hit_size_field["java_expr"], "public float hitSize = 4;")
        self.assertEqual(hit_size_field["godot_symbol"], "bullet_type_state.hitSize")

        light_radius_field = source_symbols.source_symbol(registry, "init_light_radius.light_radius_field")
        self.assertEqual(light_radius_field["java_expr"], "public float lightRadius = -1f;")
        self.assertEqual(light_radius_field["godot_symbol"], "bullet_type_state.lightRadius")

    def test_bullet_type_init_draw_size_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        assign = source_symbols.source_symbol(registry, "init_draw_size.assign")
        self.assertEqual(assign["java_expr"], "drawSize = Math.max(drawSize, trailLength * speed * 2f);")
        self.assertEqual(assign["godot_symbol"], "init_draw_size_result.drawSize")
        self.assertEqual(assign["godot_owner"], "PortGame.source_bullet_type_init_draw_size_state")
        self.assertEqual(assign["runtime_proof"], "/root/Main.source_bullet_type_init_draw_size_state")

        draw_size_field = source_symbols.source_symbol(registry, "init_draw_size.draw_size_field")
        self.assertEqual(draw_size_field["java_expr"], "public float drawSize = 40f;")
        self.assertEqual(draw_size_field["godot_symbol"], "bullet_type_state.drawSize")

        trail_length_field = source_symbols.source_symbol(registry, "init_draw_size.trail_length_field")
        self.assertEqual(trail_length_field["java_expr"], "public int trailLength = -1;")
        self.assertEqual(trail_length_field["godot_symbol"], "bullet_type_state.trailLength")

        speed_field = source_symbols.source_symbol(registry, "init_draw_size.speed_field")
        self.assertEqual(speed_field["java_expr"], "public float speed = 1f;")
        self.assertEqual(speed_field["godot_symbol"], "bullet_type_state.speed")

    def test_bullet_type_init_range_assignment_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        assign = source_symbols.source_symbol(registry, "init_range_assignment.assign")
        self.assertEqual(assign["java_expr"], "range = calculateRange();")
        self.assertEqual(assign["godot_symbol"], "init_range_assignment_result.range")
        self.assertEqual(assign["godot_owner"], "PortGame.source_bullet_type_init_range_assignment_state")
        self.assertEqual(assign["runtime_proof"], "/root/Main.source_bullet_type_init_range_assignment_state")

        range_field = source_symbols.source_symbol(registry, "init_range_assignment.range_field")
        self.assertEqual(range_field["java_expr"], "public float range = 0f;")
        self.assertEqual(range_field["godot_symbol"], "bullet_type_state.range")

        calculate_range_method = source_symbols.source_symbol(registry, "init_range_assignment.calculate_range_method")
        self.assertEqual(calculate_range_method["java_expr"], "protected float calculateRange(){")
        self.assertEqual(calculate_range_method["godot_symbol"], "init_range_assignment_result.calculateRangeDeferred")

    def test_bullet_type_calculate_range_override_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate_return = source_symbols.source_symbol(registry, "calculate_range_override.gate_return")
        self.assertEqual(gate_return["java_expr"], "if(rangeOverride > 0) return rangeOverride;")
        self.assertEqual(gate_return["godot_symbol"], "calculate_range_override_result.range")
        self.assertEqual(gate_return["godot_owner"], "PortGame.source_bullet_type_calculate_range_override_state")
        self.assertEqual(gate_return["runtime_proof"], "/root/Main.source_bullet_type_calculate_range_override_state")

        range_override_field = source_symbols.source_symbol(registry, "calculate_range_override.range_override_field")
        self.assertEqual(range_override_field["java_expr"], "public float rangeOverride = -1f;")
        self.assertEqual(range_override_field["godot_symbol"], "bullet_type_state.rangeOverride")

    def test_bullet_type_calculate_range_spawn_unit_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate_return = source_symbols.source_symbol(registry, "calculate_range_spawn_unit.gate_return")
        self.assertEqual(gate_return["java_expr"], "if(spawnUnit != null) return spawnUnit.lifetime * spawnUnit.speed;")
        self.assertEqual(gate_return["godot_symbol"], "calculate_range_spawn_unit_result.range")
        self.assertEqual(gate_return["godot_owner"], "PortGame.source_bullet_type_calculate_range_spawn_unit_state")
        self.assertEqual(gate_return["runtime_proof"], "/root/Main.source_bullet_type_calculate_range_spawn_unit_state")

        spawn_unit_field = source_symbols.source_symbol(registry, "calculate_range_spawn_unit.spawn_unit_field")
        self.assertEqual(spawn_unit_field["java_expr"], "public @Nullable UnitType spawnUnit;")
        self.assertEqual(spawn_unit_field["godot_symbol"], "bullet_type_state.spawnUnit")

        lifetime_field = source_symbols.source_symbol(registry, "calculate_range_spawn_unit.unit_type_lifetime_field")
        self.assertEqual(lifetime_field["java_expr"], "public float lifetime = 60f * 5f;")
        self.assertEqual(lifetime_field["godot_symbol"], "unit_type_state.lifetime")

        speed_field = source_symbols.source_symbol(registry, "calculate_range_spawn_unit.unit_type_speed_field")
        self.assertEqual(speed_field["java_expr"], "public float speed = 1.1f,")
        self.assertEqual(speed_field["godot_symbol"], "unit_type_state.speed")

    def test_bullet_type_calculate_range_despawn_unit_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate_return = source_symbols.source_symbol(registry, "calculate_range_despawn_unit.gate_return")
        self.assertEqual(gate_return["java_expr"], "if(despawnUnit != null) return despawnUnit.lifetime * despawnUnit.speed;")
        self.assertEqual(gate_return["godot_symbol"], "calculate_range_despawn_unit_result.range")
        self.assertEqual(gate_return["godot_owner"], "PortGame.source_bullet_type_calculate_range_despawn_unit_state")
        self.assertEqual(gate_return["runtime_proof"], "/root/Main.source_bullet_type_calculate_range_despawn_unit_state")

        despawn_unit_field = source_symbols.source_symbol(registry, "calculate_range_despawn_unit.despawn_unit_field")
        self.assertEqual(despawn_unit_field["java_expr"], "public @Nullable UnitType despawnUnit;")
        self.assertEqual(despawn_unit_field["godot_symbol"], "bullet_type_state.despawnUnit")

    def test_bullet_type_calculate_range_fallback_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        fallback_return = source_symbols.source_symbol(registry, "calculate_range_fallback.return_expr")
        self.assertEqual(fallback_return["java_expr"], "return Math.max(Mathf.zero(drag) ? speed * lifetime : speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag, maxRange);")
        self.assertEqual(fallback_return["godot_symbol"], "calculate_range_fallback_result.range")
        self.assertEqual(fallback_return["godot_owner"], "PortGame.source_bullet_type_calculate_range_fallback_state")
        self.assertEqual(fallback_return["runtime_proof"], "/root/Main.source_bullet_type_calculate_range_fallback_state")

        drag_field = source_symbols.source_symbol(registry, "calculate_range_fallback.drag_field")
        self.assertEqual(drag_field["java_expr"], "public float drag = 0f;")
        self.assertEqual(drag_field["godot_symbol"], "bullet_type_state.drag")

        max_range_field = source_symbols.source_symbol(registry, "calculate_range_fallback.max_range_field")
        self.assertEqual(max_range_field["java_expr"], "public float maxRange = -1f;")
        self.assertEqual(max_range_field["godot_symbol"], "bullet_type_state.maxRange")

        lifetime_field = source_symbols.source_symbol(registry, "calculate_range_fallback.lifetime_field")
        self.assertEqual(lifetime_field["java_expr"], "public float lifetime = 40f;")
        self.assertEqual(lifetime_field["godot_symbol"], "bullet_type_state.lifetime")

        mathf_zero = source_symbols.source_symbol(registry, "calculate_range_fallback.mathf_zero")
        self.assertEqual(mathf_zero["java_expr"], "return Math.abs(value) <= FLOAT_ROUNDING_ERROR;")
        self.assertEqual(mathf_zero["godot_symbol"], "calculate_range_fallback_result.zeroDrag")

        mathf_pow = source_symbols.source_symbol(registry, "calculate_range_fallback.mathf_pow")
        self.assertEqual(mathf_pow["java_expr"], "return (float)Math.pow(a, b);")
        self.assertEqual(mathf_pow["godot_symbol"], "calculate_range_fallback_result.fallbackRange")

    def test_bullet_type_continuous_damage_default_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        default_return = source_symbols.source_symbol(registry, "continuous_damage_default.return_expr")
        self.assertEqual(default_return["java_expr"], "return -1f;")
        self.assertEqual(default_return["godot_symbol"], "continuous_damage_default_result.continuousDamage")
        self.assertEqual(default_return["godot_owner"], "PortGame.source_bullet_type_continuous_damage_default_state")
        self.assertEqual(default_return["runtime_proof"], "/root/Main.source_bullet_type_continuous_damage_default_state")

        doc = source_symbols.source_symbol(registry, "continuous_damage_default.doc")
        self.assertEqual(doc["java_expr"], "/** @return continuous damage in damage/sec, or -1 if not continuous. */")
        self.assertEqual(doc["godot_symbol"], "source_line.continuous_damage_default.doc")

    def test_bullet_type_heals_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        return_expr = source_symbols.source_symbol(registry, "heals.return_expr")
        self.assertEqual(return_expr["java_expr"], "return healPercent > 0 || healAmount > 0;")
        self.assertEqual(return_expr["godot_symbol"], "heals_result.heals")
        self.assertEqual(return_expr["godot_owner"], "PortGame.source_bullet_type_heals_state")
        self.assertEqual(return_expr["runtime_proof"], "/root/Main.source_bullet_type_heals_state")

        heal_percent = source_symbols.source_symbol(registry, "heals.heal_percent_field")
        self.assertEqual(heal_percent["java_expr"], "public float healPercent = 0f;")
        self.assertEqual(heal_percent["godot_symbol"], "bullet_type_state.healPercent")

        heal_amount = source_symbols.source_symbol(registry, "heals.heal_amount_field")
        self.assertEqual(heal_amount["java_expr"], "public float healAmount = 0f;")
        self.assertEqual(heal_amount["godot_symbol"], "bullet_type_state.healAmount")

    def test_bullet_type_create_initial_gate_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        angle_offset = source_symbols.source_symbol(registry, "create_initial_gate.angle_offset_assignment")
        self.assertEqual(angle_offset["java_expr"], "angle += angleOffset + Mathf.range(randomAngleOffset);")
        self.assertEqual(angle_offset["godot_symbol"], "create_initial_gate_result.angle")
        self.assertEqual(angle_offset["godot_owner"], "PortGame.source_bullet_type_create_initial_gate_state")
        self.assertEqual(angle_offset["runtime_proof"], "/root/Main.source_bullet_type_create_initial_gate_state")

        chance_gate = source_symbols.source_symbol(registry, "create_initial_gate.create_chance_gate")
        self.assertEqual(chance_gate["java_expr"], "if(!Mathf.chance(createChance)) return null;")
        self.assertEqual(chance_gate["godot_symbol"], "create_initial_gate_result.createChancePassed")

        ignore_spawn_angle = source_symbols.source_symbol(registry, "create_initial_gate.ignore_spawn_angle")
        self.assertEqual(ignore_spawn_angle["java_expr"], "if(ignoreSpawnAngle) angle = 0;")
        self.assertEqual(ignore_spawn_angle["godot_symbol"], "create_initial_gate_result.ignoreSpawnAngleApplied")

        spawn_unit_boundary = source_symbols.source_symbol(registry, "create_initial_gate.spawn_unit_boundary")
        self.assertEqual(spawn_unit_boundary["status"], "deferred")
        self.assertEqual(spawn_unit_boundary["java_expr"], "if(spawnUnit != null){")

        angle_offset_field = source_symbols.source_symbol(registry, "create_initial_gate.angle_offset_field")
        self.assertEqual(angle_offset_field["java_expr"], "public float angleOffset = 0f, randomAngleOffset = 0f;")
        self.assertEqual(angle_offset_field["godot_symbol"], "bullet_type_state.angleOffset")

        random_angle_offset_field = source_symbols.source_symbol(registry, "create_initial_gate.random_angle_offset_field")
        self.assertEqual(random_angle_offset_field["java_expr"], "public float angleOffset = 0f, randomAngleOffset = 0f;")
        self.assertEqual(random_angle_offset_field["godot_symbol"], "bullet_type_state.randomAngleOffset")

        create_chance_field = source_symbols.source_symbol(registry, "create_initial_gate.create_chance_field")
        self.assertEqual(create_chance_field["java_expr"], "public float createChance = 1;")
        self.assertEqual(create_chance_field["godot_symbol"], "bullet_type_state.createChance")

        ignore_spawn_angle_field = source_symbols.source_symbol(registry, "create_initial_gate.ignore_spawn_angle_field")
        self.assertEqual(ignore_spawn_angle_field["java_expr"], "public boolean ignoreSpawnAngle = false;")
        self.assertEqual(ignore_spawn_angle_field["godot_symbol"], "bullet_type_state.ignoreSpawnAngle")

        random_angle_sample = source_symbols.source_symbol(registry, "create_initial_gate.random_angle_offset_sample")
        self.assertEqual(random_angle_sample["status"], "explicit-input")
        self.assertEqual(random_angle_sample["java_expr"], "Mathf.range(randomAngleOffset)")
        self.assertEqual(random_angle_sample["godot_symbol"], "create_initial_gate_input.randomAngleOffsetSample")

        chance_roll = source_symbols.source_symbol(registry, "create_initial_gate.create_chance_roll")
        self.assertEqual(chance_roll["status"], "explicit-input")
        self.assertEqual(chance_roll["java_expr"], "rand.nextFloat()")
        self.assertEqual(chance_roll["godot_symbol"], "create_initial_gate_input.createChanceRoll")

        mathf_range = source_symbols.source_symbol(registry, "create_initial_gate.mathf_range")
        self.assertEqual(mathf_range["java_expr"], "return random(-range, range);")
        self.assertEqual(mathf_range["godot_symbol"], "create_initial_gate_result.mathfRangeSource")

        mathf_chance = source_symbols.source_symbol(registry, "create_initial_gate.mathf_chance")
        self.assertEqual(mathf_chance["java_expr"], "return d >= 1f || rand.nextFloat() < d;")
        self.assertEqual(mathf_chance["godot_symbol"], "create_initial_gate_result.mathfChanceSource")

    def test_bullet_type_create_spawn_unit_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        spawn_unit_gate = source_symbols.source_symbol(registry, "create_spawn_unit.spawn_unit_gate")
        self.assertEqual(spawn_unit_gate["java_expr"], "if(spawnUnit != null){")
        self.assertEqual(spawn_unit_gate["godot_symbol"], "create_spawn_unit_result.spawnUnitBranchEntered")
        self.assertEqual(spawn_unit_gate["godot_owner"], "PortGame.source_bullet_type_create_spawn_unit_state")
        self.assertEqual(spawn_unit_gate["runtime_proof"], "/root/Main.source_bullet_type_create_spawn_unit_state")

        client_guard = source_symbols.source_symbol(registry, "create_spawn_unit.client_guard")
        self.assertEqual(client_guard["java_expr"], "if(!net.client()){")
        self.assertEqual(client_guard["godot_symbol"], "create_spawn_unit_result.spawnSkippedClient")

        spawn_create = source_symbols.source_symbol(registry, "create_spawn_unit.spawn_create")
        self.assertEqual(spawn_create["java_expr"], "Unit spawned = spawnUnit.create(team);")
        self.assertEqual(spawn_create["godot_symbol"], "create_spawn_unit_result.spawnedUnit")

        spawned_velocity = source_symbols.source_symbol(registry, "create_spawn_unit.spawned_velocity")
        self.assertEqual(spawned_velocity["java_expr"], "spawned.vel.trns(angle, spawnUnit.speed);")
        self.assertEqual(spawned_velocity["godot_symbol"], "create_spawn_unit_result.spawnedUnit.velocity")

        missile_ai_assignment = source_symbols.source_symbol(registry, "create_spawn_unit.missile_ai_shooter_assignment")
        self.assertEqual(missile_ai_assignment["java_expr"], "ai.shooter = unit; ai.shooter = control.unit();")
        self.assertEqual(missile_ai_assignment["godot_symbol"], "create_spawn_unit_result.spawnedUnit.missileAIShooter")

        kill_shooter = source_symbols.source_symbol(registry, "create_spawn_unit.kill_shooter")
        self.assertEqual(kill_shooter["java_expr"], "if(killShooter && owner instanceof Healthc h && !h.dead()) h.kill();")
        self.assertEqual(kill_shooter["godot_symbol"], "create_spawn_unit_result.ownerKilled")

        return_null = source_symbols.source_symbol(registry, "create_spawn_unit.return_null")
        self.assertEqual(return_null["java_expr"], "return null;")
        self.assertEqual(return_null["godot_symbol"], "create_spawn_unit_result.bulletCreateReturnsNull")

        bullet_create_boundary = source_symbols.source_symbol(registry, "create_spawn_unit.bullet_create_boundary")
        self.assertEqual(bullet_create_boundary["status"], "deferred")
        self.assertEqual(bullet_create_boundary["java_expr"], "Bullet bullet = Bullet.create();")

    def test_bullet_type_create_bullet_identity_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        bullet_create = source_symbols.source_symbol(registry, "create_bullet_identity.bullet_create")
        self.assertEqual(bullet_create["java_expr"], "Bullet bullet = Bullet.create();")
        self.assertEqual(bullet_create["godot_symbol"], "create_bullet_identity_result.bullet")
        self.assertEqual(bullet_create["godot_owner"], "PortGame.source_bullet_type_create_bullet_identity_state")
        self.assertEqual(bullet_create["runtime_proof"], "/root/Main.source_bullet_type_create_bullet_identity_state")

        type_assignment = source_symbols.source_symbol(registry, "create_bullet_identity.type_assignment")
        self.assertEqual(type_assignment["java_expr"], "bullet.type = this;")
        self.assertEqual(type_assignment["godot_symbol"], "create_bullet_identity_result.bullet.type")

        owner_assignment = source_symbols.source_symbol(registry, "create_bullet_identity.owner_assignment")
        self.assertEqual(owner_assignment["java_expr"], "bullet.owner = owner;")
        self.assertEqual(owner_assignment["godot_symbol"], "create_bullet_identity_result.bullet.owner")

        shooter_assignment = source_symbols.source_symbol(registry, "create_bullet_identity.shooter_assignment")
        self.assertEqual(shooter_assignment["java_expr"], "bullet.shooter = (shooter == null ? owner : shooter);")
        self.assertEqual(shooter_assignment["godot_symbol"], "create_bullet_identity_result.bullet.shooter")

        team_assignment = source_symbols.source_symbol(registry, "create_bullet_identity.team_assignment")
        self.assertEqual(team_assignment["java_expr"], "bullet.team = team;")
        self.assertEqual(team_assignment["godot_symbol"], "create_bullet_identity_result.bullet.team")

        time_assignment = source_symbols.source_symbol(registry, "create_bullet_identity.time_assignment")
        self.assertEqual(time_assignment["java_expr"], "bullet.time = 0f;")
        self.assertEqual(time_assignment["godot_symbol"], "create_bullet_identity_result.bullet.time")

        origin_x_assignment = source_symbols.source_symbol(registry, "create_bullet_identity.origin_x_assignment")
        self.assertEqual(origin_x_assignment["java_expr"], "bullet.originX = x;")
        self.assertEqual(origin_x_assignment["godot_symbol"], "create_bullet_identity_result.bullet.originX")

        origin_y_assignment = source_symbols.source_symbol(registry, "create_bullet_identity.origin_y_assignment")
        self.assertEqual(origin_y_assignment["java_expr"], "bullet.originY = y;")
        self.assertEqual(origin_y_assignment["godot_symbol"], "create_bullet_identity_result.bullet.originY")

        aim_tile_boundary = source_symbols.source_symbol(registry, "create_bullet_identity.aim_tile_boundary")
        self.assertEqual(aim_tile_boundary["status"], "deferred")
        self.assertEqual(aim_tile_boundary["java_expr"], "if(!(aimX == -1f && aimY == -1f)){")

    def test_bullet_type_create_aim_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        aim_gate = source_symbols.source_symbol(registry, "create_aim.aim_gate")
        self.assertEqual(aim_gate["java_expr"], "if(!(aimX == -1f && aimY == -1f)){")
        self.assertEqual(aim_gate["godot_symbol"], "create_aim_result.hasAimTile")
        self.assertEqual(aim_gate["godot_owner"], "PortGame.source_bullet_type_create_aim_state")
        self.assertEqual(aim_gate["runtime_proof"], "/root/Main.source_bullet_type_create_aim_state")

        aim_tile_assignment = source_symbols.source_symbol(registry, "create_aim.aim_tile_assignment")
        self.assertEqual(aim_tile_assignment["java_expr"], "bullet.aimTile = target instanceof Building b ? b.tile : world.tileWorld(aimX, aimY);")
        self.assertEqual(aim_tile_assignment["godot_symbol"], "create_aim_result.bullet.aimTile")

        aim_x_assignment = source_symbols.source_symbol(registry, "create_aim.aim_x_assignment")
        self.assertEqual(aim_x_assignment["java_expr"], "bullet.aimX = aimX;")
        self.assertEqual(aim_x_assignment["godot_symbol"], "create_aim_result.bullet.aimX")

        aim_y_assignment = source_symbols.source_symbol(registry, "create_aim.aim_y_assignment")
        self.assertEqual(aim_y_assignment["java_expr"], "bullet.aimY = aimY;")
        self.assertEqual(aim_y_assignment["godot_symbol"], "create_aim_result.bullet.aimY")

        world_tile_world = source_symbols.source_symbol(registry, "create_aim.world_tile_world")
        self.assertEqual(world_tile_world["java_expr"], "return tile(Math.round(x / tilesize), Math.round(y / tilesize));")
        self.assertEqual(world_tile_world["godot_symbol"], "create_aim_result.worldTileWorldSource")

        init_vel_boundary = source_symbols.source_symbol(registry, "create_aim.init_vel_boundary")
        self.assertEqual(init_vel_boundary["status"], "deferred")
        self.assertEqual(init_vel_boundary["java_expr"], "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f));")

    def test_bullet_type_create_velocity_position_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        init_vel_call = source_symbols.source_symbol(registry, "create_velocity_position.init_vel_call")
        self.assertEqual(init_vel_call["java_expr"], "bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f));")
        self.assertEqual(init_vel_call["godot_symbol"], "create_velocity_position_result.bullet.velocity")
        self.assertEqual(init_vel_call["godot_owner"], "PortGame.source_bullet_type_create_velocity_position_state")
        self.assertEqual(init_vel_call["runtime_proof"], "/root/Main.source_bullet_type_create_velocity_position_state")

        velocity_scale_random_factor = source_symbols.source_symbol(registry, "create_velocity_position.velocity_scale_random_factor")
        self.assertEqual(velocity_scale_random_factor["status"], "explicit-input")
        self.assertEqual(velocity_scale_random_factor["java_expr"], "Mathf.random(velocityScaleRandMin, velocityScaleRandMax)")
        self.assertEqual(velocity_scale_random_factor["godot_symbol"], "velocity_scale_random_factor")

        velocity_scale_fields = source_symbols.source_symbol(registry, "create_velocity_position.velocity_scale_rand_fields")
        self.assertEqual(velocity_scale_fields["java_expr"], "public float velocityScaleRandMin = 1f, velocityScaleRandMax = 1f;")
        self.assertEqual(velocity_scale_fields["godot_symbol"], "bullet_type_state.velocityScaleRandMin")

        bullet_comp_init_vel = source_symbols.source_symbol(registry, "create_velocity_position.bullet_comp_init_vel")
        self.assertEqual(bullet_comp_init_vel["java_expr"], "public void initVel(float angle, float amount){\n        vel.trns(angle, amount);\n        rotation = angle;\n    }")
        self.assertEqual(bullet_comp_init_vel["godot_symbol"], "create_velocity_position_result.bullet.rotation")

        set_call = source_symbols.source_symbol(registry, "create_velocity_position.set_call")
        self.assertEqual(set_call["java_expr"], "bullet.set(x, y);")
        self.assertEqual(set_call["godot_symbol"], "create_velocity_position_result.bullet.x")

        last_x_assignment = source_symbols.source_symbol(registry, "create_velocity_position.last_x_assignment")
        self.assertEqual(last_x_assignment["java_expr"], "bullet.lastX = x;")
        self.assertEqual(last_x_assignment["godot_symbol"], "create_velocity_position_result.bullet.lastX")

        last_y_assignment = source_symbols.source_symbol(registry, "create_velocity_position.last_y_assignment")
        self.assertEqual(last_y_assignment["java_expr"], "bullet.lastY = y;")
        self.assertEqual(last_y_assignment["godot_symbol"], "create_velocity_position_result.bullet.lastY")

        lifetime_boundary = source_symbols.source_symbol(registry, "create_velocity_position.lifetime_boundary")
        self.assertEqual(lifetime_boundary["status"], "deferred")
        self.assertEqual(lifetime_boundary["java_expr"], "bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f);")

    def test_bullet_type_create_lifetime_payload_damage_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        lifetime_assignment = source_symbols.source_symbol(registry, "create_lifetime_payload_damage.lifetime_assignment")
        self.assertEqual(lifetime_assignment["java_expr"], "bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f);")
        self.assertEqual(lifetime_assignment["godot_symbol"], "create_lifetime_payload_damage_result.bullet.lifetime")
        self.assertEqual(lifetime_assignment["godot_owner"], "PortGame.source_bullet_type_create_lifetime_payload_damage_state")
        self.assertEqual(lifetime_assignment["runtime_proof"], "/root/Main.source_bullet_type_create_lifetime_payload_damage_state")

        life_scale_random_factor = source_symbols.source_symbol(registry, "create_lifetime_payload_damage.life_scale_random_factor")
        self.assertEqual(life_scale_random_factor["status"], "explicit-input")
        self.assertEqual(life_scale_random_factor["java_expr"], "Mathf.random(lifeScaleRandMin, lifeScaleRandMax)")
        self.assertEqual(life_scale_random_factor["godot_symbol"], "life_scale_random_factor")

        data_assignment = source_symbols.source_symbol(registry, "create_lifetime_payload_damage.data_assignment")
        self.assertEqual(data_assignment["java_expr"], "bullet.data = data;")
        self.assertEqual(data_assignment["godot_symbol"], "create_lifetime_payload_damage_result.bullet.data")

        hit_size_assignment = source_symbols.source_symbol(registry, "create_lifetime_payload_damage.hit_size_assignment")
        self.assertEqual(hit_size_assignment["java_expr"], "bullet.hitSize = hitSize;")
        self.assertEqual(hit_size_assignment["godot_symbol"], "create_lifetime_payload_damage_result.bullet.hitSize")

        damage_assignment = source_symbols.source_symbol(registry, "create_lifetime_payload_damage.damage_assignment")
        self.assertEqual(damage_assignment["java_expr"], "bullet.damage = (damage < 0 ? this.damage : damage) * bullet.damageMultiplier();")
        self.assertEqual(damage_assignment["godot_symbol"], "create_lifetime_payload_damage_result.bullet.damage")

        damage_multiplier_factor = source_symbols.source_symbol(registry, "create_lifetime_payload_damage.damage_multiplier_factor")
        self.assertEqual(damage_multiplier_factor["status"], "explicit-input")
        self.assertEqual(damage_multiplier_factor["java_expr"], "bullet.damageMultiplier()")
        self.assertEqual(damage_multiplier_factor["godot_symbol"], "damage_multiplier_factor")

        building_damage_multiplier = source_symbols.source_symbol(registry, "create_lifetime_payload_damage.building_damage_multiplier_assignment")
        self.assertEqual(building_damage_multiplier["java_expr"], "bullet.buildingDamageMultiplier = buildingDamageMultiplier;")
        self.assertEqual(building_damage_multiplier["godot_symbol"], "create_lifetime_payload_damage_result.bullet.buildingDamageMultiplier")

        trail_clear_boundary = source_symbols.source_symbol(registry, "create_lifetime_payload_damage.trail_clear_boundary")
        self.assertEqual(trail_clear_boundary["status"], "deferred")
        self.assertEqual(trail_clear_boundary["java_expr"], "if(bullet.trail != null){")

    def test_bullet_type_create_trail_add_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        trail_null_guard = source_symbols.source_symbol(registry, "create_trail_add.trail_null_guard")
        self.assertEqual(trail_null_guard["java_expr"], "if(bullet.trail != null){")
        self.assertEqual(trail_null_guard["godot_symbol"], "create_trail_add_result.trailNullGuardSource")
        self.assertEqual(trail_null_guard["godot_owner"], "PortGame.source_bullet_type_create_trail_add_state")
        self.assertEqual(trail_null_guard["runtime_proof"], "/root/Main.source_bullet_type_create_trail_add_state")

        trail_clear_call = source_symbols.source_symbol(registry, "create_trail_add.trail_clear_call")
        self.assertEqual(trail_clear_call["java_expr"], "bullet.trail.clear();")
        self.assertEqual(trail_clear_call["godot_symbol"], "create_trail_add_result.bullet.trail.points")

        trail_clear_impl = source_symbols.source_symbol(registry, "create_trail_add.trail_clear_impl")
        self.assertEqual(trail_clear_impl["java_source"], "core/src/mindustry/graphics/Trail.java")
        self.assertEqual(trail_clear_impl["java_expr"], "points.clear();")
        self.assertEqual(trail_clear_impl["godot_symbol"], "create_trail_add_result.bullet.trail.points")

        bullet_add_call = source_symbols.source_symbol(registry, "create_trail_add.bullet_add_call")
        self.assertEqual(bullet_add_call["java_expr"], "bullet.add();")
        self.assertEqual(bullet_add_call["godot_symbol"], "create_trail_add_result.bulletAdded")

        bullet_comp_add = source_symbols.source_symbol(registry, "create_trail_add.bullet_comp_add")
        self.assertEqual(bullet_comp_add["java_source"], "core/src/mindustry/entities/comp/BulletComp.java")
        self.assertEqual(bullet_comp_add["java_expr"], "public void add(){\n        type.init(self());\n    }")
        self.assertEqual(bullet_comp_add["godot_symbol"], "create_trail_add_result.typeInitCall")

        bullet_trail_field = source_symbols.source_symbol(registry, "create_trail_add.bullet_comp_trail_field")
        self.assertEqual(bullet_trail_field["java_expr"], "transient @Nullable Trail trail;")
        self.assertEqual(bullet_trail_field["godot_symbol"], "bullet_state.trail")

        keep_velocity_boundary = source_symbols.source_symbol(registry, "create_trail_add.keep_velocity_boundary")
        self.assertEqual(keep_velocity_boundary["status"], "deferred")
        self.assertEqual(keep_velocity_boundary["java_expr"], "if(keepVelocity && owner instanceof Velc v){")

    def test_bullet_type_create_keep_velocity_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        keep_velocity_gate = source_symbols.source_symbol(registry, "create_keep_velocity.keep_velocity_gate")
        self.assertEqual(keep_velocity_gate["java_expr"], "if(keepVelocity && owner instanceof Velc v){")
        self.assertEqual(keep_velocity_gate["godot_symbol"], "create_keep_velocity_result.keepVelocityApplied")
        self.assertEqual(keep_velocity_gate["godot_owner"], "PortGame.source_bullet_type_create_keep_velocity_state")
        self.assertEqual(keep_velocity_gate["runtime_proof"], "/root/Main.source_bullet_type_create_keep_velocity_state")

        len_before = source_symbols.source_symbol(registry, "create_keep_velocity.len_before")
        self.assertEqual(len_before["java_expr"], "float len = bullet.vel.len();")
        self.assertEqual(len_before["godot_symbol"], "create_keep_velocity_result.lenBefore")

        add_owner_velocity = source_symbols.source_symbol(registry, "create_keep_velocity.add_owner_velocity")
        self.assertEqual(add_owner_velocity["java_expr"], "bullet.vel.add(v.vel());")
        self.assertEqual(add_owner_velocity["godot_symbol"], "create_keep_velocity_result.bulletVelAfter")

        lifetime_scale = source_symbols.source_symbol(registry, "create_keep_velocity.lifetime_scale")
        self.assertEqual(lifetime_scale["java_expr"], "if(newLen > 0f) bullet.lifetime *= Math.min(1f, len / newLen);")
        self.assertEqual(lifetime_scale["godot_symbol"], "create_keep_velocity_result.bullet.lifetime")

        return_bullet = source_symbols.source_symbol(registry, "create_keep_velocity.return_bullet")
        self.assertEqual(return_bullet["java_expr"], "return bullet;")
        self.assertEqual(return_bullet["godot_symbol"], "create_keep_velocity_result.returnedBullet")

        vel_comp_vel = source_symbols.source_symbol(registry, "create_keep_velocity.vel_comp_vel")
        self.assertEqual(vel_comp_vel["java_source"], "core/src/mindustry/entities/comp/VelComp.java")
        self.assertEqual(vel_comp_vel["java_expr"], "@SyncLocal Vec2 vel = new Vec2();")
        self.assertEqual(vel_comp_vel["godot_symbol"], "create_keep_velocity_owner_state.vel")

        vec2_len = source_symbols.source_symbol(registry, "create_keep_velocity.vec2_len")
        self.assertEqual(vec2_len["java_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(vec2_len["java_expr"], "public float len(){\n        return (float)Math.sqrt(x * x + y * y);\n    }")
        self.assertEqual(vec2_len["godot_symbol"], "create_keep_velocity_result.vec2LenSource")

        vec2_add = source_symbols.source_symbol(registry, "create_keep_velocity.vec2_add")
        self.assertEqual(vec2_add["java_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(vec2_add["java_expr"], "public Vec2 add(Vec2 v){\n        x += v.x;\n        y += v.y;\n        return this;\n    }")
        self.assertEqual(vec2_add["godot_symbol"], "create_keep_velocity_result.vec2AddSource")

    def test_arc_mathf_absin_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        absin_time_overload = source_symbols.source_symbol(registry, "arc_mathf_absin.time_overload")
        self.assertEqual(absin_time_overload["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(absin_time_overload["java_expr"], "public static float absin(float scl, float mag){\n        return absin(Time.time, scl, mag);\n    }")
        self.assertEqual(absin_time_overload["godot_owner"], "PortGame.source_absin")
        self.assertEqual(absin_time_overload["runtime_proof"], "/root/Main.source_absin")

        absin_formula = source_symbols.source_symbol(registry, "arc_mathf_absin.formula")
        self.assertEqual(absin_formula["java_expr"], "public static float absin(float in, float scl, float mag){\n        return (sin(in, scl * 2f, mag) + mag) / 2f;\n    }")
        self.assertEqual(absin_formula["godot_symbol"], "source_absin_result.absin")

        sin_scaled = source_symbols.source_symbol(registry, "arc_mathf_absin.sin_scaled")
        self.assertEqual(sin_scaled["java_expr"], "public static float sin(float radians, float scl, float mag){\n        return sin(radians / scl) * mag;\n    }")
        self.assertEqual(sin_scaled["godot_symbol"], "source_absin_result.sinScaled")

        value_input = source_symbols.source_symbol(registry, "arc_mathf_absin.value_input")
        self.assertEqual(value_input["status"], "explicit-input")
        self.assertEqual(value_input["java_expr"], "in")
        self.assertEqual(value_input["godot_symbol"], "source_absin_input.value")

    def test_arc_mathf_approach_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_mathf_approach.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(method["java_expr"], "public static float approach(float from, float to, float speed){\n        return from + Mathf.clamp(to - from, -speed, speed);\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_approach")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_approach")

        clamp_expr = source_symbols.source_symbol(registry, "arc_mathf_approach.clamp_expr")
        self.assertEqual(clamp_expr["java_expr"], "Mathf.clamp(to - from, -speed, speed)")
        self.assertEqual(clamp_expr["godot_symbol"], "source_approach_result.clampedDelta")

        from_input = source_symbols.source_symbol(registry, "arc_mathf_approach.from_input")
        self.assertEqual(from_input["status"], "explicit-input")
        self.assertEqual(from_input["java_expr"], "from")
        self.assertEqual(from_input["godot_symbol"], "source_approach_input.from")

    def test_arc_mathf_approach_delta_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_mathf_approach_delta.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(method["java_expr"], "public static float approachDelta(float from, float to, float speed){\n        return approach(from, to, Time.delta * speed);\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_approach_delta")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_approach_delta")

        scaled_speed = source_symbols.source_symbol(registry, "arc_mathf_approach_delta.scaled_speed")
        self.assertEqual(scaled_speed["java_expr"], "Time.delta * speed")
        self.assertEqual(scaled_speed["godot_symbol"], "source_approach_delta_result.scaledSpeed")

        delta_input = source_symbols.source_symbol(registry, "arc_mathf_approach_delta.delta_input")
        self.assertEqual(delta_input["status"], "explicit-input")
        self.assertEqual(delta_input["java_expr"], "Time.delta")
        self.assertEqual(delta_input["godot_symbol"], "source_approach_delta_input.sourceDelta")

    def test_arc_chance_delta_threshold_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_chance_delta_threshold.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(method["java_expr"], "public static boolean chanceDelta(double d){\n        return rand.nextFloat() < d * Time.delta;\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_chance_delta_threshold")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_chance_delta_threshold")

        threshold = source_symbols.source_symbol(registry, "arc_chance_delta_threshold.threshold_expr")
        self.assertEqual(threshold["java_expr"], "d * Time.delta")
        self.assertEqual(threshold["godot_symbol"], "source_arc_chance_delta_threshold_result.threshold")

        chance_input = source_symbols.source_symbol(registry, "arc_chance_delta_threshold.chance_input")
        self.assertEqual(chance_input["status"], "explicit-input")
        self.assertEqual(chance_input["java_expr"], "d")
        self.assertEqual(chance_input["godot_symbol"], "source_arc_chance_delta_threshold_input.chance")

        delta_input = source_symbols.source_symbol(registry, "arc_chance_delta_threshold.delta_input")
        self.assertEqual(delta_input["status"], "explicit-input")
        self.assertEqual(delta_input["java_expr"], "Time.delta")
        self.assertEqual(delta_input["godot_symbol"], "source_arc_chance_delta_threshold_input.sourceDelta")

    def test_arc_is_power_of_two_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_is_power_of_two.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(method["java_expr"], "public static boolean isPowerOfTwo(int value){\n        return value != 0 && (value & value - 1) == 0;\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_is_power_of_two")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_is_power_of_two")

        nonzero_guard = source_symbols.source_symbol(registry, "arc_is_power_of_two.nonzero_guard")
        self.assertEqual(nonzero_guard["java_expr"], "value != 0")
        self.assertEqual(nonzero_guard["godot_symbol"], "source_arc_is_power_of_two_result.nonzero")

        bit_test = source_symbols.source_symbol(registry, "arc_is_power_of_two.bit_test")
        self.assertEqual(bit_test["java_expr"], "(value & value - 1) == 0")
        self.assertEqual(bit_test["godot_symbol"], "source_arc_is_power_of_two_result.bitTest")

        value_input = source_symbols.source_symbol(registry, "arc_is_power_of_two.value_input")
        self.assertEqual(value_input["status"], "explicit-input")
        self.assertEqual(value_input["java_expr"], "value")
        self.assertEqual(value_input["godot_symbol"], "source_arc_is_power_of_two_input.value")

    def test_arc_lerp_delta_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_lerp_delta.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(method["java_expr"], "public static float lerpDelta(float fromValue, float toValue, float progress){\n        return lerp(fromValue, toValue, clamp(progress * Time.delta));\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_lerp_delta")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_lerp_delta")

        scaled_progress = source_symbols.source_symbol(registry, "arc_lerp_delta.scaled_progress")
        self.assertEqual(scaled_progress["java_expr"], "progress * Time.delta")
        self.assertEqual(scaled_progress["godot_symbol"], "source_arc_lerp_delta_result.scaledProgress")

        clamp_expr = source_symbols.source_symbol(registry, "arc_lerp_delta.clamp_expr")
        self.assertEqual(clamp_expr["java_expr"], "public static float clamp(float value){\n        return Math.max(Math.min(value, 1f), 0f);\n    }")
        self.assertEqual(clamp_expr["godot_symbol"], "source_arc_lerp_delta_result.clampedProgress")

        lerp_expr = source_symbols.source_symbol(registry, "arc_lerp_delta.lerp_expr")
        self.assertEqual(lerp_expr["java_expr"], "public static float lerp(float fromValue, float toValue, float progress){\n        return fromValue + (toValue - fromValue) * progress;\n    }")
        self.assertEqual(lerp_expr["godot_symbol"], "source_arc_lerp_delta_result.lerpDelta")

        delta_input = source_symbols.source_symbol(registry, "arc_lerp_delta.delta_input")
        self.assertEqual(delta_input["status"], "explicit-input")
        self.assertEqual(delta_input["java_expr"], "Time.delta")
        self.assertEqual(delta_input["godot_symbol"], "source_arc_lerp_delta_input.sourceDelta")

    def test_arc_mathf_cos_lookup_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_mathf_cos_lookup.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(method["java_expr"], "public static float cos(float radians){\n        return sinTable[(int)((radians + PI / 2) * radToIndex) & sinMask];\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_mathf_cos_lookup")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_mathf_cos_lookup")

        index_expr = source_symbols.source_symbol(registry, "arc_mathf_cos_lookup.index_expr")
        self.assertEqual(index_expr["java_expr"], "(int)((radians + PI / 2) * radToIndex) & sinMask")
        self.assertEqual(index_expr["godot_symbol"], "source_arc_mathf_cos_lookup_result.index")

        table_init = source_symbols.source_symbol(registry, "arc_mathf_cos_lookup.sin_table_init")
        self.assertEqual(table_init["java_expr"], "sinTable[i] = (float)Math.sin((i + 0.5f) / sinCount * radFull);")
        self.assertEqual(table_init["godot_symbol"], "source_arc_mathf_cos_lookup_result.tableValueSource")

        radians_input = source_symbols.source_symbol(registry, "arc_mathf_cos_lookup.radians_input")
        self.assertEqual(radians_input["status"], "explicit-input")
        self.assertEqual(radians_input["java_expr"], "radians")
        self.assertEqual(radians_input["godot_symbol"], "source_arc_mathf_cos_lookup_input.radians")

    def test_arc_mathf_sin_lookup_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_mathf_sin_lookup.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(method["java_expr"], "public static float sin(float radians){\n        return sinTable[(int)(radians * radToIndex) & sinMask];\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_mathf_sin_lookup")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_mathf_sin_lookup")

        index_expr = source_symbols.source_symbol(registry, "arc_mathf_sin_lookup.index_expr")
        self.assertEqual(index_expr["java_expr"], "(int)(radians * radToIndex) & sinMask")
        self.assertEqual(index_expr["godot_symbol"], "source_arc_mathf_sin_lookup_result.index")

        table_init = source_symbols.source_symbol(registry, "arc_mathf_sin_lookup.sin_table_init")
        self.assertEqual(table_init["java_expr"], "sinTable[i] = (float)Math.sin((i + 0.5f) / sinCount * radFull);")
        self.assertEqual(table_init["godot_symbol"], "source_arc_mathf_sin_lookup_result.tableValueSource")

        radians_input = source_symbols.source_symbol(registry, "arc_mathf_sin_lookup.radians_input")
        self.assertEqual(radians_input["status"], "explicit-input")
        self.assertEqual(radians_input["java_expr"], "radians")
        self.assertEqual(radians_input["godot_symbol"], "source_arc_mathf_sin_lookup_input.radians")

    def test_arc_mathf_sin_scaled_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_mathf_sin_scaled.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(method["java_expr"], "public static float sin(float radians, float scl, float mag){\n        return sin(radians / scl) * mag;\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_mathf_sin_scaled")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_mathf_sin_scaled")

        scaled_radians = source_symbols.source_symbol(registry, "arc_mathf_sin_scaled.scaled_radians")
        self.assertEqual(scaled_radians["java_expr"], "radians / scl")
        self.assertEqual(scaled_radians["godot_symbol"], "source_arc_mathf_sin_scaled_result.scaledRadians")

        sin_lookup = source_symbols.source_symbol(registry, "arc_mathf_sin_scaled.sin_lookup")
        self.assertEqual(sin_lookup["java_expr"], "sin(radians / scl)")
        self.assertEqual(sin_lookup["godot_symbol"], "source_arc_mathf_sin_scaled_result.sinLookup")

        mag_input = source_symbols.source_symbol(registry, "arc_mathf_sin_scaled.mag_input")
        self.assertEqual(mag_input["status"], "explicit-input")
        self.assertEqual(mag_input["java_expr"], "mag")
        self.assertEqual(mag_input["godot_symbol"], "source_arc_mathf_sin_scaled_input.mag")

    def test_arc_mathf_sin_table_value_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        table_init = source_symbols.source_symbol(registry, "arc_mathf_sin_table_value.table_init")
        self.assertEqual(table_init["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(table_init["java_expr"], "sinTable[i] = (float)Math.sin((i + 0.5f) / sinCount * radFull);")
        self.assertEqual(table_init["godot_owner"], "PortGame.source_arc_mathf_sin_table_value")
        self.assertEqual(table_init["runtime_proof"], "/root/Main.source_arc_mathf_sin_table_value")

        cardinal_zero = source_symbols.source_symbol(registry, "arc_mathf_sin_table_value.cardinal_zero")
        self.assertEqual(cardinal_zero["java_expr"], "sinTable[0] = 0f;")
        self.assertEqual(cardinal_zero["godot_symbol"], "source_arc_mathf_sin_table_value_result.cardinalZero")

        cardinal_ninety = source_symbols.source_symbol(registry, "arc_mathf_sin_table_value.cardinal_ninety")
        self.assertEqual(cardinal_ninety["java_expr"], "sinTable[(int)(90 * degToIndex) & sinMask] = 1f;")
        self.assertEqual(cardinal_ninety["godot_symbol"], "source_arc_mathf_sin_table_value_result.cardinalNinety")

        index_input = source_symbols.source_symbol(registry, "arc_mathf_sin_table_value.index_input")
        self.assertEqual(index_input["status"], "explicit-input")
        self.assertEqual(index_input["java_expr"], "i")
        self.assertEqual(index_input["godot_symbol"], "source_arc_mathf_sin_table_value_input.index")

    def test_arc_random_seed_float_max_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_random_seed_float_max.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(method["java_expr"], "public static float randomSeed(long seed, float max){\n        seedr.setSeed(seed * 99999);\n        return seedr.nextFloat() * max;\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_random_seed_float_max")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_random_seed_float_max")

        seed_scale = source_symbols.source_symbol(registry, "arc_random_seed_float_max.seed_scale")
        self.assertEqual(seed_scale["java_expr"], "seed * 99999")
        self.assertEqual(seed_scale["godot_symbol"], "source_arc_random_seed_float_max_result.scaledSeed")

        set_seed = source_symbols.source_symbol(registry, "arc_random_seed_float_max.set_seed")
        self.assertEqual(set_seed["java_expr"], "seedr.setSeed(seed * 99999);")
        self.assertEqual(set_seed["godot_symbol"], "source_arc_random_seed_float_max_result.setSeed")

        next_float = source_symbols.source_symbol(registry, "arc_random_seed_float_max.next_float")
        self.assertEqual(next_float["java_expr"], "seedr.nextFloat()")
        self.assertEqual(next_float["godot_symbol"], "source_arc_random_seed_float_max_result.nextFloat")

        max_input = source_symbols.source_symbol(registry, "arc_random_seed_float_max.max_input")
        self.assertEqual(max_input["status"], "explicit-input")
        self.assertEqual(max_input["java_expr"], "max")
        self.assertEqual(max_input["godot_symbol"], "source_arc_random_seed_float_max_input.max")

    def test_arc_random_seed_int_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_random_seed_int.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(method["java_expr"], "public static int randomSeed(long seed, int min, int max){\n        seedr.setSeed(seed);\n        if(isPowerOfTwo(max)){\n            seedr.nextInt();\n        }\n        return seedr.nextInt(max - min + 1) + min;\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_random_seed_int")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_random_seed_int")

        power_gate = source_symbols.source_symbol(registry, "arc_random_seed_int.power_of_two_gate")
        self.assertEqual(power_gate["java_expr"], "if(isPowerOfTwo(max))")
        self.assertEqual(power_gate["godot_symbol"], "source_arc_random_seed_int_result.powerOfTwoGate")

        warmup = source_symbols.source_symbol(registry, "arc_random_seed_int.power_of_two_next_int")
        self.assertEqual(warmup["java_expr"], "seedr.nextInt();")
        self.assertEqual(warmup["godot_symbol"], "source_arc_random_seed_int_result.powerOfTwoNextInt")

        bound = source_symbols.source_symbol(registry, "arc_random_seed_int.bound")
        self.assertEqual(bound["java_expr"], "max - min + 1")
        self.assertEqual(bound["godot_symbol"], "source_arc_random_seed_int_result.bound")

        min_input = source_symbols.source_symbol(registry, "arc_random_seed_int.min_input")
        self.assertEqual(min_input["status"], "explicit-input")
        self.assertEqual(min_input["java_expr"], "min")
        self.assertEqual(min_input["godot_symbol"], "source_arc_random_seed_int_input.min")

    def test_arc_strings_fixed_one_decimal_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_strings_fixed_one_decimal.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/util/Strings.java")
        self.assertEqual(method["java_expr"], "public static String fixed(float d, int decimalPlaces){\n        return fixedBuilder(d, decimalPlaces).toString();\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_strings_fixed_one_decimal")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_strings_fixed_one_decimal")

        decimal_places = source_symbols.source_symbol(registry, "arc_strings_fixed_one_decimal.decimal_places")
        self.assertEqual(decimal_places["java_expr"], "decimalPlaces = 1")
        self.assertEqual(decimal_places["godot_symbol"], "source_arc_strings_fixed_one_decimal_result.decimalPlaces")

        scaled = source_symbols.source_symbol(registry, "arc_strings_fixed_one_decimal.scaled")
        self.assertEqual(scaled["java_expr"], "dec.append((int)(float)(d * Math.pow(10, decimalPlaces) + 0.0001f));")
        self.assertEqual(scaled["godot_symbol"], "source_arc_strings_fixed_one_decimal_result.scaled")

        dot_insert = source_symbols.source_symbol(registry, "arc_strings_fixed_one_decimal.dot_insert")
        self.assertEqual(dot_insert["java_expr"], "result.append(\".\");")
        self.assertEqual(dot_insert["godot_symbol"], "source_arc_strings_fixed_one_decimal_result.dotInserted")

        value_input = source_symbols.source_symbol(registry, "arc_strings_fixed_one_decimal.value_input")
        self.assertEqual(value_input["status"], "explicit-input")
        self.assertEqual(value_input["java_expr"], "d")
        self.assertEqual(value_input["godot_symbol"], "source_arc_strings_fixed_one_decimal_input.value")

    def test_arc_vec2_limit_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_vec2_limit.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(method["java_expr"], "public Vec2 limit(float limit){\n        return limit2(limit * limit);\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_vec2_limit")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_vec2_limit")

        limit2 = source_symbols.source_symbol(registry, "arc_vec2_limit.limit2_expr")
        self.assertEqual(limit2["java_expr"], "limit * limit")
        self.assertEqual(limit2["godot_symbol"], "source_arc_vec2_limit_result.limit2")

        len2 = source_symbols.source_symbol(registry, "arc_vec2_limit.len2_method")
        self.assertEqual(len2["java_expr"], "public float len2(){\n        return x * x + y * y;\n    }")
        self.assertEqual(len2["godot_symbol"], "source_arc_vec2_limit_result.len2")

        scale_expr = source_symbols.source_symbol(registry, "arc_vec2_limit.scale_expr")
        self.assertEqual(scale_expr["java_expr"], "(float)Math.sqrt(limit2 / len2)")
        self.assertEqual(scale_expr["godot_symbol"], "source_arc_vec2_limit_result.scale")

        vec_input = source_symbols.source_symbol(registry, "arc_vec2_limit.vec_input")
        self.assertEqual(vec_input["status"], "explicit-input")
        self.assertEqual(vec_input["java_expr"], "this")
        self.assertEqual(vec_input["godot_symbol"], "source_arc_vec2_limit_input.vec")

    def test_block_can_replace_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "block_can_replace.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/world/Block.java")
        self.assertEqual(method["java_method"], "canReplace(Block other)")
        self.assertEqual(method["java_expr"], "public boolean canReplace(Block other){\n        if(other.alwaysReplace) return true;\n        if(other.privileged) return false;\n        return other.replaceable && (other != this || (rotate && quickRotate)) && ((this.group != BlockGroup.none && other.group == this.group) || other == this) &&\n            (size == other.size || (size >= other.size && ((subclass != null && subclass == other.subclass) || group.anyReplace)));\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_block_can_replace_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_block_can_replace_state")

        always_replace = source_symbols.source_symbol(registry, "block_can_replace.other_always_replace")
        self.assertEqual(always_replace["java_expr"], "if(other.alwaysReplace) return true;")
        self.assertEqual(always_replace["godot_symbol"], "source_block_can_replace_result.otherAlwaysReplace")

        privileged = source_symbols.source_symbol(registry, "block_can_replace.other_privileged")
        self.assertEqual(privileged["java_expr"], "if(other.privileged) return false;")
        self.assertEqual(privileged["godot_symbol"], "source_block_can_replace_result.otherPrivileged")

        replacement_gate = source_symbols.source_symbol(registry, "block_can_replace.replacement_gate")
        self.assertEqual(replacement_gate["java_expr"], "other.replaceable && (other != this || (rotate && quickRotate)) && ((this.group != BlockGroup.none && other.group == this.group) || other == this)")
        self.assertEqual(replacement_gate["godot_symbol"], "source_block_can_replace_result.replacementGate")

        size_gate = source_symbols.source_symbol(registry, "block_can_replace.size_gate")
        self.assertEqual(size_gate["java_expr"], "size == other.size || (size >= other.size && ((subclass != null && subclass == other.subclass) || group.anyReplace))")
        self.assertEqual(size_gate["godot_symbol"], "source_block_can_replace_result.sizeGate")

        result = source_symbols.source_symbol(registry, "block_can_replace.result")
        self.assertEqual(result["java_expr"], "return other.replaceable && (other != this || (rotate && quickRotate)) && ((this.group != BlockGroup.none && other.group == this.group) || other == this) &&\n            (size == other.size || (size >= other.size && ((subclass != null && subclass == other.subclass) || group.anyReplace)));")
        self.assertEqual(result["godot_symbol"], "source_block_can_replace_result.canReplace")

        input_other_replaceable = source_symbols.source_symbol(registry, "block_can_replace.other_replaceable_input")
        self.assertEqual(input_other_replaceable["status"], "explicit-input")
        self.assertEqual(input_other_replaceable["java_expr"], "other.replaceable")
        self.assertEqual(input_other_replaceable["godot_symbol"], "source_block_can_replace_input.otherReplaceable")

    def test_block_dump_time_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        field = source_symbols.source_symbol(registry, "block_dump_time.field")
        self.assertEqual(field["java_source"], "core/src/mindustry/world/Block.java")
        self.assertEqual(field["java_method"], "field declaration")
        self.assertEqual(field["java_expr"], "public int dumpTime = 5;")
        self.assertEqual(field["godot_owner"], "PortGame.source_block_dump_time")
        self.assertEqual(field["runtime_proof"], "/root/Main.source_block_dump_time")

        default_value = source_symbols.source_symbol(registry, "block_dump_time.default_value")
        self.assertEqual(default_value["java_expr"], "5")
        self.assertEqual(default_value["godot_symbol"], "source_block_dump_time_result.defaultDumpTime")

        block_id_input = source_symbols.source_symbol(registry, "block_dump_time.block_id_input")
        self.assertEqual(block_id_input["status"], "explicit-input")
        self.assertEqual(block_id_input["java_expr"], "name")
        self.assertEqual(block_id_input["godot_symbol"], "source_block_dump_time_input.blockId")

    def test_block_health_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        health_field = source_symbols.source_symbol(registry, "block_health.field")
        self.assertEqual(health_field["java_source"], "core/src/mindustry/world/Block.java")
        self.assertEqual(health_field["java_method"], "init()")
        self.assertEqual(health_field["java_expr"], "public int health = -1;")
        self.assertEqual(health_field["godot_owner"], "PortGame.source_block_health")
        self.assertEqual(health_field["runtime_proof"], "/root/Main.source_block_health")

        scaled_field = source_symbols.source_symbol(registry, "block_health.scaled_health_field")
        self.assertEqual(scaled_field["java_expr"], "public float scaledHealth = -1;")
        self.assertEqual(scaled_field["godot_symbol"], "source_block_health_result.scaledHealth")

        default_scaled = source_symbols.source_symbol(registry, "block_health.default_scaled_health")
        self.assertEqual(default_scaled["java_expr"], "scaledHealth = 40;")
        self.assertEqual(default_scaled["godot_symbol"], "source_block_health_result.defaultScaledHealth")

        formula = source_symbols.source_symbol(registry, "block_health.computed_health")
        self.assertEqual(formula["java_expr"], "health = round ?\n                Mathf.round(size * size * scaledHealth, 5) :\n                (int)(size * size * scaledHealth);")
        self.assertEqual(formula["godot_symbol"], "source_block_health_result.health")

        block_id_input = source_symbols.source_symbol(registry, "block_health.block_id_input")
        self.assertEqual(block_id_input["status"], "explicit-input")
        self.assertEqual(block_id_input["java_expr"], "name")
        self.assertEqual(block_id_input["godot_symbol"], "source_block_health_input.blockId")

    def test_block_health_at_cell_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        import_field = source_symbols.source_symbol(registry, "block_health_at_cell.health_import")
        self.assertEqual(import_field["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(import_field["java_method"], "create(Block block, Team team)")
        self.assertEqual(import_field["java_expr"], "@Import float x, y, health, maxHealth;")
        self.assertEqual(import_field["godot_owner"], "PortGame.source_block_health_at_cell")
        self.assertEqual(import_field["runtime_proof"], "/root/Main.source_block_health_at_cell")

        create_health = source_symbols.source_symbol(registry, "block_health_at_cell.create_health")
        self.assertEqual(create_health["java_expr"], "health = block.health;")
        self.assertEqual(create_health["godot_symbol"], "source_block_health_at_cell_result.health")

        sense_health = source_symbols.source_symbol(registry, "block_health_at_cell.sense_health")
        self.assertEqual(sense_health["java_expr"], "case health -> health;")
        self.assertEqual(sense_health["godot_symbol"], "source_block_health_at_cell_result.senseHealth")

        clamp_health = source_symbols.source_symbol(registry, "block_health_at_cell.clamp_health")
        self.assertEqual(clamp_health["java_expr"], "health = (float)Mathf.clamp(value, 0, maxHealth);")
        self.assertEqual(clamp_health["godot_symbol"], "source_block_health_at_cell_result.clampHealth")

        x_input = source_symbols.source_symbol(registry, "block_health_at_cell.x_input")
        self.assertEqual(x_input["status"], "explicit-input")
        self.assertEqual(x_input["java_expr"], "tile.x")
        self.assertEqual(x_input["godot_symbol"], "source_block_health_at_cell_input.x")

    def test_block_is_damaged_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "block_is_damaged.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/HealthComp.java")
        self.assertEqual(method["java_method"], "damaged()")
        self.assertEqual(method["java_expr"], "boolean damaged(){\n        return health < maxHealth - 0.001f;\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_block_is_damaged")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_block_is_damaged")

        health = source_symbols.source_symbol(registry, "block_is_damaged.health")
        self.assertEqual(health["java_expr"], "health")
        self.assertEqual(health["godot_symbol"], "source_block_is_damaged_result.health")

        max_health = source_symbols.source_symbol(registry, "block_is_damaged.max_health")
        self.assertEqual(max_health["java_expr"], "maxHealth")
        self.assertEqual(max_health["godot_symbol"], "source_block_is_damaged_result.maxHealth")

        epsilon = source_symbols.source_symbol(registry, "block_is_damaged.epsilon")
        self.assertEqual(epsilon["java_expr"], "0.001f")
        self.assertEqual(epsilon["godot_symbol"], "source_block_is_damaged_result.epsilon")

        damaged = source_symbols.source_symbol(registry, "block_is_damaged.return")
        self.assertEqual(damaged["java_expr"], "return health < maxHealth - 0.001f;")
        self.assertEqual(damaged["godot_symbol"], "source_block_is_damaged_result.damaged")

    def test_block_item_capacity_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        field = source_symbols.source_symbol(registry, "block_item_capacity.field")
        self.assertEqual(field["java_source"], "core/src/mindustry/world/Block.java")
        self.assertEqual(field["java_method"], "field declaration")
        self.assertEqual(field["java_expr"], "public int itemCapacity = 10;")
        self.assertEqual(field["godot_owner"], "PortGame.source_block_item_capacity")
        self.assertEqual(field["runtime_proof"], "/root/Main.source_block_item_capacity")

        sense = source_symbols.source_symbol(registry, "block_item_capacity.building_sense")
        self.assertEqual(sense["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(sense["java_expr"], "case itemCapacity -> block.hasItems ? block.itemCapacity : 0;")
        self.assertEqual(sense["godot_symbol"], "source_block_item_capacity_result.buildingSenseItemCapacity")

        core_sense = source_symbols.source_symbol(registry, "block_item_capacity.core_sense")
        self.assertEqual(core_sense["java_source"], "core/src/mindustry/world/blocks/storage/CoreBlock.java")
        self.assertEqual(core_sense["java_expr"], "if(sensor == LAccess.itemCapacity) return storageCapacity;")
        self.assertEqual(core_sense["godot_symbol"], "source_block_item_capacity_result.coreStorageCapacity")

        block_id_input = source_symbols.source_symbol(registry, "block_item_capacity.block_id_input")
        self.assertEqual(block_id_input["status"], "explicit-input")
        self.assertEqual(block_id_input["java_expr"], "name")
        self.assertEqual(block_id_input["godot_symbol"], "source_block_item_capacity_input.blockId")

    def test_block_sprite_base_position_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        create_position = source_symbols.source_symbol(registry, "block_sprite_base_position.create_position")
        self.assertEqual(create_position["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(create_position["java_method"], "create(Block block, Team team)")
        self.assertEqual(create_position["java_expr"], "set(tile.drawx(), tile.drawy());")
        self.assertEqual(create_position["godot_owner"], "PortGame.source_block_sprite_base_position")
        self.assertEqual(create_position["runtime_proof"], "/root/Main.source_block_sprite_base_position")

        drawx = source_symbols.source_symbol(registry, "block_sprite_base_position.tile_drawx")
        self.assertEqual(drawx["java_source"], "core/src/mindustry/world/Tile.java")
        self.assertEqual(drawx["java_expr"], "return block().offset + worldx();")
        self.assertEqual(drawx["godot_symbol"], "source_block_sprite_base_position_result.drawX")

        worldx = source_symbols.source_symbol(registry, "block_sprite_base_position.tile_worldx")
        self.assertEqual(worldx["java_expr"], "return x * tilesize;")
        self.assertEqual(worldx["godot_symbol"], "source_block_sprite_base_position_result.worldX")

        offset = source_symbols.source_symbol(registry, "block_sprite_base_position.block_offset")
        self.assertEqual(offset["java_source"], "core/src/mindustry/world/Block.java")
        self.assertEqual(offset["java_expr"], "offset = ((size + 1) % 2) * tilesize / 2f;")
        self.assertEqual(offset["godot_symbol"], "source_block_sprite_base_position_result.offset")

        cell_input = source_symbols.source_symbol(registry, "block_sprite_base_position.cell_input")
        self.assertEqual(cell_input["status"], "explicit-input")
        self.assertEqual(cell_input["java_expr"], "tile.x, tile.y")
        self.assertEqual(cell_input["godot_symbol"], "source_block_sprite_base_position_input.cell")

    def test_block_time_scale_at_cell_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        field = source_symbols.source_symbol(registry, "block_time_scale_at_cell.field")
        self.assertEqual(field["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(field["java_method"], "field declaration")
        self.assertEqual(field["java_expr"], "private transient float timeScale = 1f, timeScaleDuration;")
        self.assertEqual(field["godot_owner"], "PortGame.source_block_time_scale_at_cell")
        self.assertEqual(field["runtime_proof"], "/root/Main.source_block_time_scale_at_cell")

        getter = source_symbols.source_symbol(registry, "block_time_scale_at_cell.getter")
        self.assertEqual(getter["java_method"], "timeScale()")
        self.assertEqual(getter["java_expr"], "return timeScale;")
        self.assertEqual(getter["godot_symbol"], "source_block_time_scale_at_cell_result.timeScale")

        sense = source_symbols.source_symbol(registry, "block_time_scale_at_cell.sense")
        self.assertEqual(sense["java_method"], "sense(LAccess sensor)")
        self.assertEqual(sense["java_expr"], "case timescale -> timeScale;")
        self.assertEqual(sense["godot_symbol"], "source_block_time_scale_at_cell_result.senseTimeScale")

        cell_input = source_symbols.source_symbol(registry, "block_time_scale_at_cell.cell_input")
        self.assertEqual(cell_input["status"], "explicit-input")
        self.assertEqual(cell_input["java_expr"], "tile.x, tile.y")
        self.assertEqual(cell_input["godot_symbol"], "source_block_time_scale_at_cell_input.cell")

    def test_block_time_scale_duration_at_cell_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        field = source_symbols.source_symbol(registry, "block_time_scale_duration_at_cell.field")
        self.assertEqual(field["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(field["java_method"], "field declaration")
        self.assertEqual(field["java_expr"], "private transient float timeScale = 1f, timeScaleDuration;")
        self.assertEqual(field["godot_owner"], "PortGame.source_block_time_scale_duration_at_cell")
        self.assertEqual(field["runtime_proof"], "/root/Main.source_block_time_scale_duration_at_cell")

        write_duration = source_symbols.source_symbol(registry, "block_time_scale_duration_at_cell.write_duration")
        self.assertEqual(write_duration["java_method"], "write(Writes write)")
        self.assertEqual(write_duration["java_expr"], "write.f(timeScaleDuration);")
        self.assertEqual(write_duration["godot_symbol"], "source_block_time_scale_duration_at_cell_result.writeDuration")

        read_duration = source_symbols.source_symbol(registry, "block_time_scale_duration_at_cell.read_duration")
        self.assertEqual(read_duration["java_method"], "read(Reads read, byte revision)")
        self.assertEqual(read_duration["java_expr"], "timeScaleDuration = read.f();")
        self.assertEqual(read_duration["godot_symbol"], "source_block_time_scale_duration_at_cell_result.readDuration")

        apply_duration = source_symbols.source_symbol(registry, "block_time_scale_duration_at_cell.apply_boost_duration")
        self.assertEqual(apply_duration["java_expr"], "timeScaleDuration = Math.max(timeScaleDuration, duration);")
        self.assertEqual(apply_duration["godot_symbol"], "source_block_time_scale_duration_at_cell_result.applyBoostDuration")

        decay = source_symbols.source_symbol(registry, "block_time_scale_duration_at_cell.decay")
        self.assertEqual(decay["java_expr"], "if((timeScaleDuration -= Time.delta) <= 0f){")
        self.assertEqual(decay["godot_symbol"], "source_block_time_scale_duration_at_cell_result.decayGate")

    def test_building_absorb_lasers_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_absorb_lasers.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "absorbLasers()")
        self.assertEqual(method["java_expr"], "return block.absorbLasers;")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_absorb_lasers_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_absorb_lasers_state")
        self.assertEqual(method["godot_symbol"], "source_building_absorb_lasers_result.absorbLasers")

        field = source_symbols.source_symbol(registry, "building_absorb_lasers.block_field")
        self.assertEqual(field["java_source"], "core/src/mindustry/world/Block.java")
        self.assertEqual(field["java_method"], "field declaration")
        self.assertEqual(field["java_expr"], "public boolean absorbLasers = false;")
        self.assertEqual(field["godot_symbol"], "source_building_absorb_lasers_result.defaultAbsorbLasers")

        input_value = source_symbols.source_symbol(registry, "building_absorb_lasers.input")
        self.assertEqual(input_value["status"], "explicit-input")
        self.assertEqual(input_value["java_expr"], "block.absorbLasers")
        self.assertEqual(input_value["godot_symbol"], "source_building_absorb_lasers_input.blockAbsorbLasers")

    def test_building_accept_item_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_accept_item.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "acceptItem(Building source, Item item)")
        self.assertEqual(method["java_expr"], "return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_accept_item_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_accept_item_state")
        self.assertEqual(method["godot_symbol"], "source_building_accept_item_result.acceptItem")

        consumes_item = source_symbols.source_symbol(registry, "building_accept_item.consumes_item")
        self.assertEqual(consumes_item["status"], "explicit-input")
        self.assertEqual(consumes_item["java_expr"], "block.consumesItem(item)")
        self.assertEqual(consumes_item["godot_symbol"], "source_building_accept_item_input.consumesItem")

        item_count = source_symbols.source_symbol(registry, "building_accept_item.item_count")
        self.assertEqual(item_count["status"], "explicit-input")
        self.assertEqual(item_count["java_expr"], "items.get(item)")
        self.assertEqual(item_count["godot_symbol"], "source_building_accept_item_input.itemCount")

        maximum_accepted = source_symbols.source_symbol(registry, "building_accept_item.maximum_accepted")
        self.assertEqual(maximum_accepted["status"], "explicit-input")
        self.assertEqual(maximum_accepted["java_expr"], "getMaximumAccepted(item)")
        self.assertEqual(maximum_accepted["godot_symbol"], "source_building_accept_item_input.maximumAccepted")

    def test_building_accept_liquid_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_accept_liquid.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "acceptLiquid(Building source, Liquid liquid)")
        self.assertEqual(method["java_expr"], "return block.hasLiquids && block.consumesLiquid(liquid);")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_accept_liquid_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_accept_liquid_state")
        self.assertEqual(method["godot_symbol"], "source_building_accept_liquid_result.acceptLiquid")

        has_liquids = source_symbols.source_symbol(registry, "building_accept_liquid.has_liquids")
        self.assertEqual(has_liquids["status"], "explicit-input")
        self.assertEqual(has_liquids["java_expr"], "block.hasLiquids")
        self.assertEqual(has_liquids["godot_symbol"], "source_building_accept_liquid_input.hasLiquids")

        consumes_liquid = source_symbols.source_symbol(registry, "building_accept_liquid.consumes_liquid")
        self.assertEqual(consumes_liquid["status"], "explicit-input")
        self.assertEqual(consumes_liquid["java_expr"], "block.consumesLiquid(liquid)")
        self.assertEqual(consumes_liquid["godot_symbol"], "source_building_accept_liquid_input.consumesLiquid")

    def test_building_accept_payload_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_accept_payload.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "acceptPayload(Building source, Payload payload)")
        self.assertEqual(method["java_expr"], "return false;")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_accept_payload_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_accept_payload_state")
        self.assertEqual(method["godot_symbol"], "source_building_accept_payload_result.acceptPayload")

    def test_building_accept_stack_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_accept_stack.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "acceptStack(Item item, int amount, Teamc source)")
        self.assertEqual(method["java_expr"], "if(acceptItem(self(), item) && block.hasItems && (source == null || source.team() == team)){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_accept_stack_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_accept_stack_state")
        self.assertEqual(method["godot_symbol"], "source_building_accept_stack_result.acceptStackGate")

        result = source_symbols.source_symbol(registry, "building_accept_stack.result")
        self.assertEqual(result["java_expr"], "return Math.min(getMaximumAccepted(item) - items.get(item), amount);")
        self.assertEqual(result["godot_symbol"], "source_building_accept_stack_result.acceptStack")

        fallback = source_symbols.source_symbol(registry, "building_accept_stack.fallback")
        self.assertEqual(fallback["java_expr"], "return 0;")
        self.assertEqual(fallback["godot_symbol"], "source_building_accept_stack_result.fallback")

    def test_building_after_destroyed_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        guard = source_symbols.source_symbol(registry, "building_after_destroyed.guard")
        self.assertEqual(guard["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(guard["java_method"], "afterDestroyed()")
        self.assertEqual(guard["java_expr"], "if(block.destroyBullet != null){")
        self.assertEqual(guard["godot_owner"], "PortGame.source_building_after_destroyed_state")
        self.assertEqual(guard["runtime_proof"], "/root/Main.source_building_after_destroyed_state")
        self.assertEqual(guard["godot_symbol"], "source_building_after_destroyed_result.createBulletGate")

        create_call = source_symbols.source_symbol(registry, "building_after_destroyed.create_call")
        self.assertEqual(create_call["java_expr"], "block.destroyBullet.create(this, block.destroyBulletSameTeam ? team : Team.derelict, x, y, Mathf.randomSeed(id(), 360f));")
        self.assertEqual(create_call["godot_symbol"], "source_building_after_destroyed_result.createBullet")

        team_choice = source_symbols.source_symbol(registry, "building_after_destroyed.team_choice")
        self.assertEqual(team_choice["java_expr"], "block.destroyBulletSameTeam ? team : Team.derelict")
        self.assertEqual(team_choice["godot_symbol"], "source_building_after_destroyed_result.team")

        rotation = source_symbols.source_symbol(registry, "building_after_destroyed.rotation")
        self.assertEqual(rotation["java_expr"], "Mathf.randomSeed(id(), 360f)")
        self.assertEqual(rotation["godot_symbol"], "source_building_after_destroyed_result.rotation")

    def test_building_after_picked_up_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        guard = source_symbols.source_symbol(registry, "building_after_picked_up.power_guard")
        self.assertEqual(guard["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(guard["java_method"], "afterPickedUp()")
        self.assertEqual(guard["java_expr"], "if(power != null){")
        self.assertEqual(guard["godot_owner"], "PortGame.source_building_after_picked_up_state")
        self.assertEqual(guard["runtime_proof"], "/root/Main.source_building_after_picked_up_state")
        self.assertEqual(guard["godot_symbol"], "source_building_after_picked_up_result.powerGuard")

        new_graph = source_symbols.source_symbol(registry, "building_after_picked_up.new_power_graph")
        self.assertEqual(new_graph["java_expr"], "power.graph = new PowerGraph();")
        self.assertEqual(new_graph["godot_symbol"], "source_building_after_picked_up_result.newPowerGraph")

        clear_links = source_symbols.source_symbol(registry, "building_after_picked_up.clear_links")
        self.assertEqual(clear_links["java_expr"], "power.links.clear();")
        self.assertEqual(clear_links["godot_symbol"], "source_building_after_picked_up_result.clearLinks")

        reset_guard = source_symbols.source_symbol(registry, "building_after_picked_up.status_reset_guard")
        self.assertEqual(reset_guard["java_expr"], "if(block.consPower != null && !block.consPower.buffered){")
        self.assertEqual(reset_guard["godot_symbol"], "source_building_after_picked_up_result.statusResetGate")

        status_reset = source_symbols.source_symbol(registry, "building_after_picked_up.status_reset")
        self.assertEqual(status_reset["java_expr"], "power.status = 0f;")
        self.assertEqual(status_reset["godot_symbol"], "source_building_after_picked_up_result.status")

    def test_building_ambient_volume_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_ambient_volume.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "ambientVolume()")
        self.assertEqual(method["java_expr"], "public float ambientVolume(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_ambient_volume")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_ambient_volume")
        self.assertEqual(method["godot_symbol"], "source_building_ambient_volume_result.method")

        ambient_volume = source_symbols.source_symbol(registry, "building_ambient_volume.return_efficiency")
        self.assertEqual(ambient_volume["java_expr"], "return efficiency;")
        self.assertEqual(ambient_volume["godot_symbol"], "source_building_ambient_volume_result.ambientVolume")

        efficiency = source_symbols.source_symbol(registry, "building_ambient_volume.efficiency")
        self.assertEqual(efficiency["status"], "explicit-input")
        self.assertEqual(efficiency["java_expr"], "efficiency")
        self.assertEqual(efficiency["godot_symbol"], "source_building_ambient_volume_input.efficiency")

    def test_building_apply_boost_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        guard = source_symbols.source_symbol(registry, "building_apply_boost.can_overdrive_guard")
        self.assertEqual(guard["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(guard["java_method"], "applyBoost(float intensity, float duration)")
        self.assertEqual(guard["java_expr"], "if(!block.canOverdrive) return;")
        self.assertEqual(guard["godot_owner"], "PortGame.source_building_apply_boost_state")
        self.assertEqual(guard["runtime_proof"], "/root/Main.source_building_apply_boost_state")
        self.assertEqual(guard["godot_symbol"], "source_building_apply_boost_result.canOverdriveGate")

        refresh_guard = source_symbols.source_symbol(registry, "building_apply_boost.refresh_guard")
        self.assertEqual(refresh_guard["java_expr"], "if(intensity >= this.timeScale - 0.001f){")
        self.assertEqual(refresh_guard["godot_symbol"], "source_building_apply_boost_result.refreshDurationGate")

        duration_max = source_symbols.source_symbol(registry, "building_apply_boost.duration_max")
        self.assertEqual(duration_max["java_expr"], "timeScaleDuration = Math.max(timeScaleDuration, duration);")
        self.assertEqual(duration_max["godot_symbol"], "source_building_apply_boost_result.timeScaleDuration")

        scale_max = source_symbols.source_symbol(registry, "building_apply_boost.time_scale_max")
        self.assertEqual(scale_max["java_expr"], "timeScale = Math.max(timeScale, intensity);")
        self.assertEqual(scale_max["godot_symbol"], "source_building_apply_boost_result.timeScale")

        current_time_scale = source_symbols.source_symbol(registry, "building_apply_boost.current_time_scale")
        self.assertEqual(current_time_scale["status"], "explicit-input")
        self.assertEqual(current_time_scale["java_expr"], "this.timeScale")
        self.assertEqual(current_time_scale["godot_symbol"], "source_building_apply_boost_input.currentTimeScale")

    def test_building_block_half_extent_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        square_call = source_symbols.source_symbol(registry, "building_block_half_extent.draw_configure_square")
        self.assertEqual(square_call["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(square_call["java_method"], "drawConfigure()")
        self.assertEqual(square_call["java_expr"], "Lines.square(x, y, block.size * tilesize / 2f + 1f);")
        self.assertEqual(square_call["godot_owner"], "PortGame.source_building_block_half_extent")
        self.assertEqual(square_call["runtime_proof"], "/root/Main.source_building_block_half_extent")
        self.assertEqual(square_call["godot_symbol"], "source_building_block_half_extent_result.drawConfigureSquare")

        half_extent = source_symbols.source_symbol(registry, "building_block_half_extent.formula")
        self.assertEqual(half_extent["java_expr"], "block.size * tilesize / 2f")
        self.assertEqual(half_extent["godot_symbol"], "source_building_block_half_extent_result.halfExtent")

        block_size = source_symbols.source_symbol(registry, "building_block_half_extent.block_size")
        self.assertEqual(block_size["status"], "explicit-input")
        self.assertEqual(block_size["java_expr"], "block.size")
        self.assertEqual(block_size["godot_symbol"], "source_building_block_half_extent_input.blockSize")

    def test_building_bullet_damage_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        delegate = source_symbols.source_symbol(registry, "building_bullet_damage.delegate")
        self.assertEqual(delegate["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(delegate["java_method"], "damage(Bullet bullet, Team source, float damage)")
        self.assertEqual(delegate["java_expr"], "damage(source, damage);")
        self.assertEqual(delegate["godot_owner"], "PortGame.source_building_bullet_damage_state")
        self.assertEqual(delegate["runtime_proof"], "/root/Main.source_building_bullet_damage_state")
        self.assertEqual(delegate["godot_symbol"], "source_building_bullet_damage_result.delegatesToSourceDamage")

        event = source_symbols.source_symbol(registry, "building_bullet_damage.event")
        self.assertEqual(event["java_expr"], "Events.fire(bulletDamageEvent.set(self(), bullet));")
        self.assertEqual(event["godot_symbol"], "source_building_bullet_damage_result.firesBulletDamageEvent")

        event_field = source_symbols.source_symbol(registry, "building_bullet_damage.event_field")
        self.assertEqual(event_field["java_expr"], "static final BuildDamageEvent bulletDamageEvent = new BuildDamageEvent();")
        self.assertEqual(event_field["godot_symbol"], "source_building_bullet_damage_result.bulletDamageEvent")

        bullet = source_symbols.source_symbol(registry, "building_bullet_damage.bullet")
        self.assertEqual(bullet["status"], "explicit-input")
        self.assertEqual(bullet["java_expr"], "bullet")
        self.assertEqual(bullet["godot_symbol"], "source_building_bullet_damage_input.bullet")

    def test_building_can_be_replaced_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_can_be_replaced.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "canBeReplaced(Block other)")
        self.assertEqual(method["java_expr"], "public boolean canBeReplaced(Block other){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_can_be_replaced_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_can_be_replaced_state")
        self.assertEqual(method["godot_symbol"], "source_building_can_be_replaced_result.method")

        delegate = source_symbols.source_symbol(registry, "building_can_be_replaced.delegate")
        self.assertEqual(delegate["java_expr"], "return other.canReplace(block);")
        self.assertEqual(delegate["godot_symbol"], "source_building_can_be_replaced_result.canBeReplaced")

        other_can_replace = source_symbols.source_symbol(registry, "building_can_be_replaced.other_can_replace_block")
        self.assertEqual(other_can_replace["status"], "explicit-input")
        self.assertEqual(other_can_replace["java_expr"], "other.canReplace(block)")
        self.assertEqual(other_can_replace["godot_symbol"], "source_building_can_be_replaced_input.otherCanReplaceBlock")

    def test_building_can_consume_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_can_consume.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "canConsume()")
        self.assertEqual(method["java_expr"], "public boolean canConsume(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_can_consume_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_can_consume_state")
        self.assertEqual(method["godot_symbol"], "source_building_can_consume_result.method")

        result = source_symbols.source_symbol(registry, "building_can_consume.result")
        self.assertEqual(result["java_expr"], "return potentialEfficiency > 0;")
        self.assertEqual(result["godot_symbol"], "source_building_can_consume_result.canConsume")

        potential_efficiency = source_symbols.source_symbol(registry, "building_can_consume.potential_efficiency")
        self.assertEqual(potential_efficiency["status"], "explicit-input")
        self.assertEqual(potential_efficiency["java_expr"], "potentialEfficiency")
        self.assertEqual(potential_efficiency["godot_symbol"], "source_building_can_consume_input.potentialEfficiency")

    def test_building_can_pickup_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_can_pickup.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "canPickup()")
        self.assertEqual(method["java_expr"], "public boolean canPickup(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_can_pickup_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_can_pickup_state")
        self.assertEqual(method["godot_symbol"], "source_building_can_pickup_result.method")

        result = source_symbols.source_symbol(registry, "building_can_pickup.result")
        self.assertEqual(result["java_expr"], "return block.canPickup;")
        self.assertEqual(result["godot_symbol"], "source_building_can_pickup_result.canPickup")

        block_can_pickup = source_symbols.source_symbol(registry, "building_can_pickup.block_can_pickup")
        self.assertEqual(block_can_pickup["status"], "explicit-input")
        self.assertEqual(block_can_pickup["java_expr"], "block.canPickup")
        self.assertEqual(block_can_pickup["godot_symbol"], "source_building_can_pickup_input.blockCanPickup")

    def test_building_change_team_delegate_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        delegate = source_symbols.source_symbol(registry, "building_change_team_delegate.call")
        self.assertEqual(delegate["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(delegate["java_method"], "changeTeam(Team next)")
        self.assertEqual(delegate["java_expr"], "changeTeam(next, true);")
        self.assertEqual(delegate["godot_owner"], "PortGame.source_building_change_team_delegate_state")
        self.assertEqual(delegate["runtime_proof"], "/root/Main.source_building_change_team_delegate_state")
        self.assertEqual(delegate["godot_symbol"], "source_building_change_team_delegate_result.delegates_to_change_team")

        update_power = source_symbols.source_symbol(registry, "building_change_team_delegate.update_power")
        self.assertEqual(update_power["java_expr"], "true")
        self.assertEqual(update_power["godot_symbol"], "source_building_change_team_delegate_result.update_power")

        next_team = source_symbols.source_symbol(registry, "building_change_team_delegate.next_team")
        self.assertEqual(next_team["status"], "explicit-input")
        self.assertEqual(next_team["java_expr"], "next")
        self.assertEqual(next_team["godot_symbol"], "source_building_change_team_delegate_input.next_team")

    def test_building_change_team_final_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        add_index = source_symbols.source_symbol(registry, "building_change_team_final.add_index")
        self.assertEqual(add_index["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(add_index["java_method"], "changeTeam(Team next, boolean updatePower)")
        self.assertEqual(add_index["java_expr"], "indexer.addIndex(tile);")
        self.assertEqual(add_index["godot_owner"], "PortGame.source_building_change_team_final_state")
        self.assertEqual(add_index["runtime_proof"], "/root/Main.source_building_change_team_final_state")
        self.assertEqual(add_index["godot_symbol"], "source_building_change_team_final_result.add_index")

        event = source_symbols.source_symbol(registry, "building_change_team_final.team_change_event")
        self.assertEqual(event["java_expr"], "Events.fire(teamChangeEvent.set(last, self()));")
        self.assertEqual(event["godot_symbol"], "source_building_change_team_final_result.team_change_event")

        check_allow_update = source_symbols.source_symbol(registry, "building_change_team_final.check_allow_update")
        self.assertEqual(check_allow_update["java_expr"], "checkAllowUpdate();")
        self.assertEqual(check_allow_update["godot_symbol"], "source_building_change_team_final_result.check_allow_update")

        last_team = source_symbols.source_symbol(registry, "building_change_team_final.last_team")
        self.assertEqual(last_team["status"], "explicit-input")
        self.assertEqual(last_team["java_expr"], "last")
        self.assertEqual(last_team["godot_symbol"], "source_building_change_team_final_input.last_team")

    def test_building_change_team_initial_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        current_guard = source_symbols.source_symbol(registry, "building_change_team_initial.current_team_guard")
        self.assertEqual(current_guard["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(current_guard["java_method"], "changeTeam(Team next, boolean updatePower)")
        self.assertEqual(current_guard["java_expr"], "if(this.team == next) return;")
        self.assertEqual(current_guard["godot_owner"], "PortGame.source_building_change_team_initial_state")
        self.assertEqual(current_guard["runtime_proof"], "/root/Main.source_building_change_team_initial_state")
        self.assertEqual(current_guard["godot_symbol"], "source_building_change_team_initial_result.returned")

        force_team = source_symbols.source_symbol(registry, "building_change_team_initial.force_team")
        self.assertEqual(force_team["java_expr"], "if(block.forceTeam != null) team = block.forceTeam;")
        self.assertEqual(force_team["godot_symbol"], "source_building_change_team_initial_result.team")

        remove_index = source_symbols.source_symbol(registry, "building_change_team_initial.remove_index")
        self.assertEqual(remove_index["java_expr"], "if(was) indexer.removeIndex(tile);")
        self.assertEqual(remove_index["godot_symbol"], "source_building_change_team_initial_result.remove_index")

        next_team = source_symbols.source_symbol(registry, "building_change_team_initial.next_team")
        self.assertEqual(next_team["status"], "explicit-input")
        self.assertEqual(next_team["java_expr"], "next")
        self.assertEqual(next_team["godot_symbol"], "source_building_change_team_initial_input.next_team")

    def test_building_change_team_power_links_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        loop = source_symbols.source_symbol(registry, "building_change_team_power_links.loop")
        self.assertEqual(loop["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(loop["java_method"], "changeTeam(Team next, boolean updatePower)")
        self.assertEqual(loop["java_expr"], "for(int i = 0; i < power.links.size; i++){")
        self.assertEqual(loop["godot_owner"], "PortGame.source_building_change_team_power_links_state")
        self.assertEqual(loop["runtime_proof"], "/root/Main.source_building_change_team_power_links_state")
        self.assertEqual(loop["godot_symbol"], "source_building_change_team_power_links_result.link_count")

        remove_index = source_symbols.source_symbol(registry, "building_change_team_power_links.remove_index")
        self.assertEqual(remove_index["java_expr"], "power.links.removeIndex(i);")
        self.assertEqual(remove_index["godot_symbol"], "source_building_change_team_power_links_result.remove_index")

        update_power_graph = source_symbols.source_symbol(registry, "building_change_team_power_links.update_power_graph")
        self.assertEqual(update_power_graph["java_expr"], "updatePowerGraph();")
        self.assertEqual(update_power_graph["godot_symbol"], "source_building_change_team_power_links_result.update_power_graph")

        link_count = source_symbols.source_symbol(registry, "building_change_team_power_links.link_count")
        self.assertEqual(link_count["status"], "explicit-input")
        self.assertEqual(link_count["java_expr"], "power.links.size")
        self.assertEqual(link_count["godot_symbol"], "source_building_change_team_power_links_input.link_count")

    def test_building_change_team_power_proximity_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "building_change_team_power_proximity.gate")
        self.assertEqual(gate["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(gate["java_method"], "changeTeam(Team next, boolean updatePower)")
        self.assertEqual(gate["java_expr"], "if(power != null && updatePower){")
        self.assertEqual(gate["godot_owner"], "PortGame.source_building_change_team_power_proximity_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_building_change_team_power_proximity_state")
        self.assertEqual(gate["godot_symbol"], "source_building_change_team_power_proximity_result.proximity_reflow")

        old_graph = source_symbols.source_symbol(registry, "building_change_team_power_proximity.old_graph")
        self.assertEqual(old_graph["java_expr"], "var oldGraph = power.graph;")
        self.assertEqual(old_graph["godot_symbol"], "source_building_change_team_power_proximity_result.old_graph")

        reflow_other = source_symbols.source_symbol(registry, "building_change_team_power_proximity.reflow_other")
        self.assertEqual(reflow_other["java_expr"], "new PowerGraph().reflow(other);")
        self.assertEqual(reflow_other["godot_symbol"], "source_building_change_team_power_proximity_result.proximity_reflow")

        power_present = source_symbols.source_symbol(registry, "building_change_team_power_proximity.power_present")
        self.assertEqual(power_present["status"], "explicit-input")
        self.assertEqual(power_present["java_expr"], "power != null")
        self.assertEqual(power_present["godot_symbol"], "source_building_change_team_power_proximity_input.power_present")

    def test_building_check_allow_update_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        guard = source_symbols.source_symbol(registry, "building_check_allow_update.guard")
        self.assertEqual(guard["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(guard["java_method"], "checkAllowUpdate()")
        self.assertEqual(guard["java_expr"], "if(!allowUpdate()){")
        self.assertEqual(guard["godot_owner"], "PortGame.source_building_check_allow_update_state")
        self.assertEqual(guard["runtime_proof"], "/root/Main.source_building_check_allow_update_state")
        self.assertEqual(guard["godot_symbol"], "source_building_check_allow_update_result.enabled")

        disable = source_symbols.source_symbol(registry, "building_check_allow_update.disable")
        self.assertEqual(disable["java_expr"], "enabled = false;")
        self.assertEqual(disable["godot_symbol"], "source_building_check_allow_update_result.enabled")

        current_enabled = source_symbols.source_symbol(registry, "building_check_allow_update.current_enabled")
        self.assertEqual(current_enabled["status"], "explicit-input")
        self.assertEqual(current_enabled["java_expr"], "enabled")
        self.assertEqual(current_enabled["godot_symbol"], "source_building_check_allow_update_input.current_enabled")

        allow_update_result = source_symbols.source_symbol(registry, "building_check_allow_update.allow_update_result")
        self.assertEqual(allow_update_result["status"], "explicit-input")
        self.assertEqual(allow_update_result["java_expr"], "allowUpdate()")
        self.assertEqual(allow_update_result["godot_symbol"], "source_building_check_allow_update_input.allow_update_result")

    def test_building_check_solid_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_check_solid.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "checkSolid()")
        self.assertEqual(method["java_expr"], "public boolean checkSolid(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_check_solid_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_check_solid_state")
        self.assertEqual(method["godot_symbol"], "source_building_check_solid_result.method")

        result = source_symbols.source_symbol(registry, "building_check_solid.result")
        self.assertEqual(result["java_expr"], "return false;")
        self.assertEqual(result["godot_symbol"], "source_building_check_solid_result.checkSolid")

    def test_building_check_suppression_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        gate = source_symbols.source_symbol(registry, "building_check_suppression.gate")
        self.assertEqual(gate["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(gate["java_method"], "checkSuppression()")
        self.assertEqual(gate["java_expr"], "if(isHealSuppressed()){")
        self.assertEqual(gate["godot_owner"], "PortGame.source_building_check_suppression_state")
        self.assertEqual(gate["runtime_proof"], "/root/Main.source_building_check_suppression_state")
        self.assertEqual(gate["godot_symbol"], "source_building_check_suppression_result.suppressed")

        heal_suppressed = source_symbols.source_symbol(registry, "building_check_suppression.heal_suppressed")
        self.assertEqual(heal_suppressed["java_method"], "isHealSuppressed()")
        self.assertEqual(heal_suppressed["java_expr"], "return block.suppressable && Time.time <= healSuppressionTime;")
        self.assertEqual(heal_suppressed["godot_symbol"], "source_building_check_suppression_result.suppressed")

        chance = source_symbols.source_symbol(registry, "building_check_suppression.chance_delta")
        self.assertEqual(chance["java_expr"], "if(Mathf.chanceDelta(0.03)){")
        self.assertEqual(chance["godot_symbol"], "source_building_check_suppression_result.chance_threshold")

        particle = source_symbols.source_symbol(registry, "building_check_suppression.particle")
        self.assertEqual(particle["java_expr"], "Fx.regenSuppressParticle.at(x + Mathf.range(block.size * tilesize/2f - 1f), y + Mathf.range(block.size * tilesize/2f - 1f), suppressColor);")
        self.assertEqual(particle["godot_symbol"], "source_building_check_suppression_result.effect")

        block_suppressable = source_symbols.source_symbol(registry, "building_check_suppression.block_suppressable")
        self.assertEqual(block_suppressable["status"], "explicit-input")
        self.assertEqual(block_suppressable["java_expr"], "block.suppressable")
        self.assertEqual(block_suppressable["godot_symbol"], "source_building_check_suppression_input.block_suppressable")

        source_time = source_symbols.source_symbol(registry, "building_check_suppression.source_time")
        self.assertEqual(source_time["status"], "explicit-input")
        self.assertEqual(source_time["java_expr"], "Time.time")
        self.assertEqual(source_time["godot_symbol"], "source_building_check_suppression_input.source_time")

    def test_building_collide_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_collide.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "collide(Bullet other)")
        self.assertEqual(method["java_expr"], "public boolean collide(Bullet other){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_collide_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_collide_state")
        self.assertEqual(method["godot_symbol"], "source_building_collide_result.method")

        result = source_symbols.source_symbol(registry, "building_collide.result")
        self.assertEqual(result["java_expr"], "return true;")
        self.assertEqual(result["godot_symbol"], "source_building_collide_result.collide")

        other = source_symbols.source_symbol(registry, "building_collide.other")
        self.assertEqual(other["status"], "explicit-input")
        self.assertEqual(other["java_expr"], "other")
        self.assertEqual(other["godot_symbol"], "source_building_collide_input.other")

    def test_building_collision_damage_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_collision_damage.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "collision(Bullet other)")
        self.assertEqual(method["java_expr"], "public boolean collision(Bullet other){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_collision_damage_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_collision_damage_state")
        self.assertEqual(method["godot_symbol"], "source_building_collision_damage_result.method")

        was_dead = source_symbols.source_symbol(registry, "building_collision_damage.was_dead")
        self.assertEqual(was_dead["java_expr"], "boolean wasDead = health <= 0;")
        self.assertEqual(was_dead["godot_symbol"], "source_building_collision_damage_result.was_dead")

        raw_damage = source_symbols.source_symbol(registry, "building_collision_damage.raw_damage")
        self.assertEqual(raw_damage["java_expr"], "float damage = other.type.buildingDamage(other);")
        self.assertEqual(raw_damage["godot_symbol"], "source_building_collision_damage_result.raw_damage")

        armor = source_symbols.source_symbol(registry, "building_collision_damage.armor")
        self.assertEqual(armor["java_expr"], "block.armor * t.armorMultiplier * t.blockArmorMultiplier")
        self.assertEqual(armor["godot_symbol"], "source_building_collision_damage_result.armor")

        apply_armor = source_symbols.source_symbol(registry, "building_collision_damage.apply_armor")
        self.assertEqual(apply_armor["java_expr"], "damage = Damage.applyArmor(damage, block.armor * t.armorMultiplier * t.blockArmorMultiplier);")
        self.assertEqual(apply_armor["godot_symbol"], "source_building_collision_damage_result.damage")

        return_true = source_symbols.source_symbol(registry, "building_collision_damage.return_true")
        self.assertEqual(return_true["java_expr"], "return true;")
        self.assertEqual(return_true["godot_symbol"], "source_building_collision_damage_result.removed")

        current_health = source_symbols.source_symbol(registry, "building_collision_damage.current_health")
        self.assertEqual(current_health["status"], "explicit-input")
        self.assertEqual(current_health["java_expr"], "health")
        self.assertEqual(current_health["godot_symbol"], "source_building_collision_damage_input.current_health")

        pierce_armor = source_symbols.source_symbol(registry, "building_collision_damage.bullet_pierce_armor")
        self.assertEqual(pierce_armor["status"], "explicit-input")
        self.assertEqual(pierce_armor["java_expr"], "t.pierceArmor")
        self.assertEqual(pierce_armor["godot_symbol"], "source_building_collision_damage_input.bullet_pierce_armor")

    def test_building_config_default_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        comment = source_symbols.source_symbol(registry, "building_config_default.comment")
        self.assertEqual(comment["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(comment["java_method"], "config()")
        self.assertEqual(comment["java_expr"], "/** Tile configuration. Defaults to null. Used for block rebuilding. */")
        self.assertEqual(comment["godot_owner"], "PortGame.source_building_config_default")
        self.assertEqual(comment["runtime_proof"], "/root/Main.source_building_config_default")
        self.assertEqual(comment["godot_symbol"], "source_building_config_default_result.comment")

        nullable = source_symbols.source_symbol(registry, "building_config_default.nullable")
        self.assertEqual(nullable["java_expr"], "@Nullable")
        self.assertEqual(nullable["godot_symbol"], "source_building_config_default_result.nullable")

        method = source_symbols.source_symbol(registry, "building_config_default.method")
        self.assertEqual(method["java_expr"], "public Object config(){")
        self.assertEqual(method["godot_symbol"], "source_building_config_default_result.method")

        result = source_symbols.source_symbol(registry, "building_config_default.result")
        self.assertEqual(result["java_expr"], "return null;")
        self.assertEqual(result["godot_symbol"], "source_building_config_default_result.config")

    def test_building_configure_menu_visibility_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        show_method = source_symbols.source_symbol(registry, "building_configure_menu_visibility.show_method")
        self.assertEqual(show_method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(show_method["java_method"], "shouldShowConfigure(Player player) / shouldHideConfigure(Player player)")
        self.assertEqual(show_method["java_expr"], "public boolean shouldShowConfigure(Player player){")
        self.assertEqual(show_method["godot_owner"], "PortGame.source_building_configure_menu_visibility_state")
        self.assertEqual(show_method["runtime_proof"], "/root/Main.source_building_configure_menu_visibility_state")
        self.assertEqual(show_method["godot_symbol"], "source_building_configure_menu_visibility_result.show_method")

        show_result = source_symbols.source_symbol(registry, "building_configure_menu_visibility.should_show")
        self.assertEqual(show_result["java_expr"], "return true;")
        self.assertEqual(show_result["godot_symbol"], "source_building_configure_menu_visibility_result.should_show")

        hide_method = source_symbols.source_symbol(registry, "building_configure_menu_visibility.hide_method")
        self.assertEqual(hide_method["java_expr"], "public boolean shouldHideConfigure(Player player){")
        self.assertEqual(hide_method["godot_symbol"], "source_building_configure_menu_visibility_result.hide_method")

        hide_result = source_symbols.source_symbol(registry, "building_configure_menu_visibility.should_hide")
        self.assertEqual(hide_result["java_expr"], "return false;")
        self.assertEqual(hide_result["godot_symbol"], "source_building_configure_menu_visibility_result.should_hide")

        player = source_symbols.source_symbol(registry, "building_configure_menu_visibility.player")
        self.assertEqual(player["status"], "explicit-input")
        self.assertEqual(player["java_expr"], "player")
        self.assertEqual(player["godot_symbol"], "source_building_configure_menu_visibility_input.player")

    def test_building_configured_copy_config_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        branch = source_symbols.source_symbol(registry, "building_configured_copy_config.branch")
        self.assertEqual(branch["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(branch["java_method"], "configured(@Nullable Unit builder, @Nullable Object value)")
        self.assertEqual(branch["java_expr"], "}else if(value instanceof Building build){")
        self.assertEqual(branch["godot_owner"], "PortGame.source_building_configured_copy_config_state")
        self.assertEqual(branch["runtime_proof"], "/root/Main.source_building_configured_copy_config_state")
        self.assertEqual(branch["godot_symbol"], "source_building_configured_copy_config_result.copy_branch")

        comment = source_symbols.source_symbol(registry, "building_configured_copy_config.comment")
        self.assertEqual(comment["java_expr"], "//copy config of another building")
        self.assertEqual(comment["godot_symbol"], "source_building_configured_copy_config_result.comment")

        config_line = source_symbols.source_symbol(registry, "building_configured_copy_config.config_line")
        self.assertEqual(config_line["java_expr"], "var conf = build.config();")
        self.assertEqual(config_line["godot_symbol"], "source_building_configured_copy_config_result.config")

        guard = source_symbols.source_symbol(registry, "building_configured_copy_config.guard")
        self.assertEqual(guard["java_expr"], "if(conf != null && !(conf instanceof Building)){")
        self.assertEqual(guard["godot_symbol"], "source_building_configured_copy_config_result.recurse")

        recurse = source_symbols.source_symbol(registry, "building_configured_copy_config.recurse")
        self.assertEqual(recurse["java_expr"], "configured(builder, conf);")
        self.assertEqual(recurse["godot_symbol"], "source_building_configured_copy_config_result.recurse")

        value_is_building = source_symbols.source_symbol(registry, "building_configured_copy_config.value_is_building")
        self.assertEqual(value_is_building["status"], "explicit-input")
        self.assertEqual(value_is_building["java_expr"], "value instanceof Building build")
        self.assertEqual(value_is_building["godot_symbol"], "source_building_configured_copy_config_input.value_is_building")

        copied_config = source_symbols.source_symbol(registry, "building_configured_copy_config.copied_config")
        self.assertEqual(copied_config["status"], "explicit-input")
        self.assertEqual(copied_config["java_expr"], "build.config()")
        self.assertEqual(copied_config["godot_symbol"], "source_building_configured_copy_config_input.copied_config")

    def test_building_configured_direct_handler_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        guard = source_symbols.source_symbol(registry, "building_configured_direct_handler.guard")
        self.assertEqual(guard["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(guard["java_method"], "configured(@Nullable Unit builder, @Nullable Object value)")
        self.assertEqual(guard["java_expr"], "if(block.configurations.containsKey(type)){")
        self.assertEqual(guard["godot_owner"], "PortGame.source_building_configured_direct_handler_state")
        self.assertEqual(guard["runtime_proof"], "/root/Main.source_building_configured_direct_handler_state")
        self.assertEqual(guard["godot_symbol"], "source_building_configured_direct_handler_result.handled")

        handler_call = source_symbols.source_symbol(registry, "building_configured_direct_handler.handler_call")
        self.assertEqual(handler_call["java_expr"], "block.configurations.get(type).get(this, value);")
        self.assertEqual(handler_call["godot_symbol"], "source_building_configured_direct_handler_result.handled")

        copy_boundary = source_symbols.source_symbol(registry, "building_configured_direct_handler.copy_boundary")
        self.assertEqual(copy_boundary["java_expr"], "}else if(value instanceof Building build){")
        self.assertEqual(copy_boundary["godot_symbol"], "source_building_configured_direct_handler_result.copy_boundary")

        has_configuration = source_symbols.source_symbol(registry, "building_configured_direct_handler.has_configuration")
        self.assertEqual(has_configuration["status"], "explicit-input")
        self.assertEqual(has_configuration["java_expr"], "block.configurations.containsKey(type)")
        self.assertEqual(has_configuration["godot_symbol"], "source_building_configured_direct_handler_input.has_configuration")

        configured_type = source_symbols.source_symbol(registry, "building_configured_direct_handler.configured_type")
        self.assertEqual(configured_type["status"], "explicit-input")
        self.assertEqual(configured_type["java_expr"], "type")
        self.assertEqual(configured_type["godot_symbol"], "source_building_configured_direct_handler_input.configured_type")

        value_state = source_symbols.source_symbol(registry, "building_configured_direct_handler.value_state")
        self.assertEqual(value_state["status"], "explicit-input")
        self.assertEqual(value_state["java_expr"], "value")
        self.assertEqual(value_state["godot_symbol"], "source_building_configured_direct_handler_input.value_state")

    def test_building_configured_last_access_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        guard = source_symbols.source_symbol(registry, "building_configured_last_access.guard")
        self.assertEqual(guard["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(guard["java_method"], "configured(@Nullable Unit builder, @Nullable Object value) / updateLastAccess(Player player)")
        self.assertEqual(guard["java_expr"], "if(builder != null && builder.isPlayer()){")
        self.assertEqual(guard["godot_owner"], "PortGame.source_building_configured_last_access_state")
        self.assertEqual(guard["runtime_proof"], "/root/Main.source_building_configured_last_access_state")
        self.assertEqual(guard["godot_symbol"], "source_building_configured_last_access_result.updated")

        update_call = source_symbols.source_symbol(registry, "building_configured_last_access.update_call")
        self.assertEqual(update_call["java_expr"], "updateLastAccess(builder.getPlayer());")
        self.assertEqual(update_call["godot_symbol"], "source_building_configured_last_access_result.updated")

        method = source_symbols.source_symbol(registry, "building_configured_last_access.method")
        self.assertEqual(method["java_expr"], "public void updateLastAccess(Player player){")
        self.assertEqual(method["godot_symbol"], "source_building_configured_last_access_result.method")

        assignment = source_symbols.source_symbol(registry, "building_configured_last_access.assignment")
        self.assertEqual(assignment["java_expr"], "lastAccessed = player.coloredName();")
        self.assertEqual(assignment["godot_symbol"], "source_building_configured_last_access_result.last_accessed")

        builder_state = source_symbols.source_symbol(registry, "building_configured_last_access.builder_state")
        self.assertEqual(builder_state["status"], "explicit-input")
        self.assertEqual(builder_state["java_expr"], "builder")
        self.assertEqual(builder_state["godot_symbol"], "source_building_configured_last_access_input.builder_state")

        current_last_accessed = source_symbols.source_symbol(registry, "building_configured_last_access.current_last_accessed")
        self.assertEqual(current_last_accessed["status"], "explicit-input")
        self.assertEqual(current_last_accessed["java_expr"], "lastAccessed")
        self.assertEqual(current_last_accessed["godot_symbol"], "source_building_configured_last_access_input.current_last_accessed")

    def test_building_configured_type_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        assignment = source_symbols.source_symbol(registry, "building_configured_type.assignment")
        self.assertEqual(assignment["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(assignment["java_method"], "configured(@Nullable Unit builder, @Nullable Object value)")
        self.assertEqual(assignment["java_expr"], "Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();")
        self.assertEqual(assignment["godot_owner"], "PortGame.source_building_configured_type_state")
        self.assertEqual(assignment["runtime_proof"], "/root/Main.source_building_configured_type_state")
        self.assertEqual(assignment["godot_symbol"], "source_building_configured_type_result.type_name")

        item_override = source_symbols.source_symbol(registry, "building_configured_type.item_override")
        self.assertEqual(item_override["java_expr"], "if(value instanceof Item) type = Item.class;")
        self.assertEqual(item_override["godot_symbol"], "source_building_configured_type_result.type_name")

        block_override = source_symbols.source_symbol(registry, "building_configured_type.block_override")
        self.assertEqual(block_override["java_expr"], "if(value instanceof Block) type = Block.class;")
        self.assertEqual(block_override["godot_symbol"], "source_building_configured_type_result.type_name")

        liquid_override = source_symbols.source_symbol(registry, "building_configured_type.liquid_override")
        self.assertEqual(liquid_override["java_expr"], "if(value instanceof Liquid) type = Liquid.class;")
        self.assertEqual(liquid_override["godot_symbol"], "source_building_configured_type_result.type_name")

        unit_type_override = source_symbols.source_symbol(registry, "building_configured_type.unit_type_override")
        self.assertEqual(unit_type_override["java_expr"], "if(value instanceof UnitType) type = UnitType.class;")
        self.assertEqual(unit_type_override["godot_symbol"], "source_building_configured_type_result.type_name")

        value_state = source_symbols.source_symbol(registry, "building_configured_type.value_state")
        self.assertEqual(value_state["status"], "explicit-input")
        self.assertEqual(value_state["java_expr"], "value")
        self.assertEqual(value_state["godot_symbol"], "source_building_configured_type_input.value_state")

    def test_building_consume_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_consume.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "consume()")
        self.assertEqual(method["java_expr"], "public void consume(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_consume_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_consume_state")
        self.assertEqual(method["godot_symbol"], "source_building_consume_result.method")

        loop = source_symbols.source_symbol(registry, "building_consume.loop")
        self.assertEqual(loop["java_expr"], "for(Consume cons : block.consumers){")
        self.assertEqual(loop["godot_symbol"], "source_building_consume_result.triggered")

        trigger_call = source_symbols.source_symbol(registry, "building_consume.trigger_call")
        self.assertEqual(trigger_call["java_expr"], "cons.trigger(self());")
        self.assertEqual(trigger_call["godot_symbol"], "source_building_consume_result.triggered")

        consumers = source_symbols.source_symbol(registry, "building_consume.consumers")
        self.assertEqual(consumers["status"], "explicit-input")
        self.assertEqual(consumers["java_expr"], "block.consumers")
        self.assertEqual(consumers["godot_symbol"], "source_building_consume_input.consumers")

        self_state = source_symbols.source_symbol(registry, "building_consume.self_state")
        self.assertEqual(self_state["status"], "explicit-input")
        self.assertEqual(self_state["java_expr"], "self()")
        self.assertEqual(self_state["godot_symbol"], "source_building_consume_input.self_state")

    def test_building_consume_trigger_valid_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        comment = source_symbols.source_symbol(registry, "building_consume_trigger_valid.comment")
        self.assertEqual(comment["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(comment["java_method"], "consumeTriggerValid()")
        self.assertEqual(comment["java_expr"], "/** @return whether this building is currently \"burning\" a trigger consumer (an item) - if true, valid() on those will return true. */")
        self.assertEqual(comment["godot_owner"], "PortGame.source_building_consume_trigger_valid_state")
        self.assertEqual(comment["runtime_proof"], "/root/Main.source_building_consume_trigger_valid_state")
        self.assertEqual(comment["godot_symbol"], "source_building_consume_trigger_valid_result.comment")

        method = source_symbols.source_symbol(registry, "building_consume_trigger_valid.method")
        self.assertEqual(method["java_expr"], "public boolean consumeTriggerValid(){")
        self.assertEqual(method["godot_symbol"], "source_building_consume_trigger_valid_result.method")

        result = source_symbols.source_symbol(registry, "building_consume_trigger_valid.result")
        self.assertEqual(result["java_expr"], "return false;")
        self.assertEqual(result["godot_symbol"], "source_building_consume_trigger_valid_result.consume_trigger_valid")

    def test_building_control_config_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_control_config.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "control(LAccess type, Object p1, double p2, double p3, double p4)")
        self.assertEqual(method["java_expr"], "public void control(LAccess type, Object p1, double p2, double p3, double p4){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_control_config_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_control_config_state")
        self.assertEqual(method["godot_symbol"], "source_building_control_config_result.method")

        lag_comment = source_symbols.source_symbol(registry, "building_control_config.lag_comment")
        self.assertEqual(lag_comment["java_expr"], "//don't execute configure instructions that copy logic building configures; this can cause extreme lag")
        self.assertEqual(lag_comment["godot_symbol"], "source_building_control_config_result.lag_comment")

        guard = source_symbols.source_symbol(registry, "building_control_config.guard")
        self.assertEqual(guard["java_expr"], "if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){")
        self.assertEqual(guard["godot_symbol"], "source_building_control_config_result.configured_called")

        configured_call = source_symbols.source_symbol(registry, "building_control_config.configured_call")
        self.assertEqual(configured_call["java_expr"], "configured(null, p1);")
        self.assertEqual(configured_call["godot_symbol"], "source_building_control_config_result.value")

        p1_value = source_symbols.source_symbol(registry, "building_control_config.p1_value")
        self.assertEqual(p1_value["status"], "explicit-input")
        self.assertEqual(p1_value["java_expr"], "p1")
        self.assertEqual(p1_value["godot_symbol"], "source_building_control_config_input.p1_value")

    def test_building_control_enabled_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_control_enabled.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "control(LAccess type, double p1, double p2, double p3, double p4)")
        self.assertEqual(method["java_expr"], "public void control(LAccess type, double p1, double p2, double p3, double p4){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_control_enabled_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_control_enabled_state")
        self.assertEqual(method["godot_symbol"], "source_building_control_enabled_result.method")

        guard = source_symbols.source_symbol(registry, "building_control_enabled.guard")
        self.assertEqual(guard["java_expr"], "if(type == LAccess.enabled){")
        self.assertEqual(guard["godot_symbol"], "source_building_control_enabled_result.guard")

        assignment = source_symbols.source_symbol(registry, "building_control_enabled.assignment")
        self.assertEqual(assignment["java_expr"], "enabled = !Mathf.zero((float)p1);")
        self.assertEqual(assignment["godot_symbol"], "source_building_control_enabled_result.enabled")

        p1 = source_symbols.source_symbol(registry, "building_control_enabled.p1")
        self.assertEqual(p1["status"], "explicit-input")
        self.assertEqual(p1["java_expr"], "p1")
        self.assertEqual(p1["godot_symbol"], "source_building_control_enabled_input.p1")

    def test_building_cursor_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        comment = source_symbols.source_symbol(registry, "building_cursor.comment")
        self.assertEqual(comment["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(comment["java_method"], "getCursor()")
        self.assertEqual(comment["java_expr"], "/** Returns whether a hand cursor should be shown over this block. */")
        self.assertEqual(comment["godot_owner"], "PortGame.source_building_cursor_state")
        self.assertEqual(comment["runtime_proof"], "/root/Main.source_building_cursor_state")
        self.assertEqual(comment["godot_symbol"], "source_building_cursor_result.comment")

        method = source_symbols.source_symbol(registry, "building_cursor.method")
        self.assertEqual(method["java_expr"], "public Cursor getCursor(){")
        self.assertEqual(method["godot_symbol"], "source_building_cursor_result.method")

        result = source_symbols.source_symbol(registry, "building_cursor.result")
        self.assertEqual(result["java_expr"], "return block.configurable && interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;")
        self.assertEqual(result["godot_symbol"], "source_building_cursor_result.cursor")

        configurable = source_symbols.source_symbol(registry, "building_cursor.block_configurable")
        self.assertEqual(configurable["status"], "explicit-input")
        self.assertEqual(configurable["java_expr"], "block.configurable")
        self.assertEqual(configurable["godot_symbol"], "source_building_cursor_input.block_configurable")

    def test_building_damage_block_health_scale_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        block_health = source_symbols.source_symbol(registry, "building_damage_block_health_scale.block_health")
        self.assertEqual(block_health["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(block_health["java_method"], "damage(float damage)")
        self.assertEqual(block_health["java_expr"], "float dm = state.rules.blockHealth(team);")
        self.assertEqual(block_health["godot_owner"], "PortGame.source_building_damage_block_health_scale_state")
        self.assertEqual(block_health["runtime_proof"], "/root/Main.source_building_damage_block_health_scale_state")
        self.assertEqual(block_health["godot_symbol"], "source_building_damage_block_health_scale_input.block_health_multiplier")

        last_damage_time = source_symbols.source_symbol(registry, "building_damage_block_health_scale.last_damage_time")
        self.assertEqual(last_damage_time["java_expr"], "lastDamageTime = Time.time;")
        self.assertEqual(last_damage_time["godot_symbol"], "source_building_damage_block_health_scale_result.last_damage_time")

        zero_guard = source_symbols.source_symbol(registry, "building_damage_block_health_scale.zero_guard")
        self.assertEqual(zero_guard["java_expr"], "if(Mathf.zero(dm)){")
        self.assertEqual(zero_guard["godot_symbol"], "source_building_damage_block_health_scale_result.damage")

        zero_assignment = source_symbols.source_symbol(registry, "building_damage_block_health_scale.zero_assignment")
        self.assertEqual(zero_assignment["java_expr"], "damage = health + 1;")
        self.assertEqual(zero_assignment["godot_symbol"], "source_building_damage_block_health_scale_result.damage")

        scale_assignment = source_symbols.source_symbol(registry, "building_damage_block_health_scale.scale_assignment")
        self.assertEqual(scale_assignment["java_expr"], "damage /= dm;")
        self.assertEqual(scale_assignment["godot_symbol"], "source_building_damage_block_health_scale_result.damage")

    def test_building_damage_dead_guard_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        dead_guard = source_symbols.source_symbol(registry, "building_damage_dead_guard.dead_guard")
        self.assertEqual(dead_guard["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(dead_guard["java_method"], "damage(float damage)")
        self.assertEqual(dead_guard["java_expr"], "if(dead()) return;")
        self.assertEqual(dead_guard["godot_owner"], "PortGame.source_building_damage_dead_guard_state")
        self.assertEqual(dead_guard["runtime_proof"], "/root/Main.source_building_damage_dead_guard_state")
        self.assertEqual(dead_guard["godot_symbol"], "source_building_damage_dead_guard_result.returned")

        continues = source_symbols.source_symbol(registry, "building_damage_dead_guard.continues")
        self.assertEqual(continues["java_expr"], "if(dead()) return;")
        self.assertEqual(continues["godot_symbol"], "source_building_damage_dead_guard_result.continues")

        dead_state = source_symbols.source_symbol(registry, "building_damage_dead_guard.dead_state")
        self.assertEqual(dead_state["status"], "explicit-input")
        self.assertEqual(dead_state["java_expr"], "dead()")
        self.assertEqual(dead_state["godot_symbol"], "source_building_damage_dead_guard_input.dead_state")

    def test_building_damage_delegate_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        comment = source_symbols.source_symbol(registry, "building_damage_delegate.comment")
        self.assertEqual(comment["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(comment["java_method"], "damage(@Nullable Team source, float damage)")
        self.assertEqual(comment["java_expr"], "/** Used to handle damage from splash damage for certain types of blocks. */")
        self.assertEqual(comment["godot_owner"], "PortGame.source_building_damage_delegate_state")
        self.assertEqual(comment["runtime_proof"], "/root/Main.source_building_damage_delegate_state")
        self.assertEqual(comment["godot_symbol"], "source_building_damage_delegate_result.comment")

        method = source_symbols.source_symbol(registry, "building_damage_delegate.method")
        self.assertEqual(method["java_expr"], "public void damage(@Nullable Team source, float damage){")
        self.assertEqual(method["godot_symbol"], "source_building_damage_delegate_result.method")

        delegate_call = source_symbols.source_symbol(registry, "building_damage_delegate.delegate_call")
        self.assertEqual(delegate_call["java_expr"], "damage(damage);")
        self.assertEqual(delegate_call["godot_symbol"], "source_building_damage_delegate_result.delegates_to_damage")

        source_team = source_symbols.source_symbol(registry, "building_damage_delegate.source_team")
        self.assertEqual(source_team["status"], "explicit-input")
        self.assertEqual(source_team["java_expr"], "source")
        self.assertEqual(source_team["godot_symbol"], "source_building_damage_delegate_input.source_team")

        damage = source_symbols.source_symbol(registry, "building_damage_delegate.damage")
        self.assertEqual(damage["status"], "explicit-input")
        self.assertEqual(damage["java_expr"], "damage")
        self.assertEqual(damage["godot_symbol"], "source_building_damage_delegate_input.damage")

    def test_building_damage_handle_damage_gate_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        client_comment = source_symbols.source_symbol(registry, "building_damage_handle_damage_gate.client_comment")
        self.assertEqual(client_comment["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(client_comment["java_method"], "damage(float damage)")
        self.assertEqual(client_comment["java_expr"], "//TODO handle this better on the client.")
        self.assertEqual(client_comment["godot_owner"], "PortGame.source_building_damage_handle_damage_gate_state")
        self.assertEqual(client_comment["runtime_proof"], "/root/Main.source_building_damage_handle_damage_gate_state")
        self.assertEqual(client_comment["godot_symbol"], "source_building_damage_handle_damage_gate_result.client_comment")

        client_guard = source_symbols.source_symbol(registry, "building_damage_handle_damage_gate.client_guard")
        self.assertEqual(client_guard["java_expr"], "if(!net.client()){")
        self.assertEqual(client_guard["godot_symbol"], "source_building_damage_handle_damage_gate_result.handle_damage_called")

        health_assignment = source_symbols.source_symbol(registry, "building_damage_handle_damage_gate.health_assignment")
        self.assertEqual(health_assignment["java_expr"], "health -= handleDamage(damage);")
        self.assertEqual(health_assignment["godot_symbol"], "source_building_damage_handle_damage_gate_result.health")

        net_client = source_symbols.source_symbol(registry, "building_damage_handle_damage_gate.net_client")
        self.assertEqual(net_client["status"], "explicit-input")
        self.assertEqual(net_client["java_expr"], "net.client()")
        self.assertEqual(net_client["godot_symbol"], "source_building_damage_handle_damage_gate_input.net_client")

        handled_damage = source_symbols.source_symbol(registry, "building_damage_handle_damage_gate.handled_damage")
        self.assertEqual(handled_damage["status"], "explicit-input")
        self.assertEqual(handled_damage["java_expr"], "handleDamage(damage)")
        self.assertEqual(handled_damage["godot_symbol"], "source_building_damage_handle_damage_gate_input.handled_damage")

    def test_building_damage_health_changed_call_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        call = source_symbols.source_symbol(registry, "building_damage_health_changed_call.call")
        self.assertEqual(call["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(call["java_method"], "damage(float damage)")
        self.assertEqual(call["java_expr"], "healthChanged();")
        self.assertEqual(call["godot_owner"], "PortGame.source_building_damage_health_changed_call_state")
        self.assertEqual(call["runtime_proof"], "/root/Main.source_building_damage_health_changed_call_state")
        self.assertEqual(call["godot_symbol"], "source_building_damage_health_changed_call_result.health_changed")

    def test_building_delta_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        comment = source_symbols.source_symbol(registry, "building_delta.comment")
        self.assertEqual(comment["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(comment["java_method"], "delta()")
        self.assertEqual(comment["java_expr"], "/** Scaled delta. */")
        self.assertEqual(comment["godot_owner"], "PortGame.source_building_delta")
        self.assertEqual(comment["runtime_proof"], "/root/Main.source_building_delta")
        self.assertEqual(comment["godot_symbol"], "source_building_delta_result.comment")

        method = source_symbols.source_symbol(registry, "building_delta.method")
        self.assertEqual(method["java_expr"], "public float delta(){")
        self.assertEqual(method["godot_symbol"], "source_building_delta_result.method")

        delta_return = source_symbols.source_symbol(registry, "building_delta.return")
        self.assertEqual(delta_return["java_expr"], "return Time.delta * timeScale;")
        self.assertEqual(delta_return["godot_symbol"], "source_building_delta_result.delta")

        source_delta = source_symbols.source_symbol(registry, "building_delta.source_delta")
        self.assertEqual(source_delta["status"], "explicit-input")
        self.assertEqual(source_delta["java_expr"], "Time.delta")
        self.assertEqual(source_delta["godot_symbol"], "source_building_delta_input.source_delta")

        time_scale = source_symbols.source_symbol(registry, "building_delta.time_scale")
        self.assertEqual(time_scale["status"], "explicit-input")
        self.assertEqual(time_scale["java_expr"], "timeScale")
        self.assertEqual(time_scale["godot_symbol"], "source_building_delta_input.time_scale")

    def test_building_display_efficiency_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_display_efficiency.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "getDisplayEfficiency()")
        self.assertEqual(method["java_expr"], "public float getDisplayEfficiency(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_display_efficiency")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_display_efficiency")
        self.assertEqual(method["godot_symbol"], "source_building_display_efficiency_result.method")

        display_efficiency = source_symbols.source_symbol(registry, "building_display_efficiency.return")
        self.assertEqual(display_efficiency["java_expr"], "return getProgressIncrease(1f) / edelta();")
        self.assertEqual(display_efficiency["godot_symbol"], "source_building_display_efficiency_result.displayEfficiency")

        progress_increase = source_symbols.source_symbol(registry, "building_display_efficiency.progress_increase")
        self.assertEqual(progress_increase["java_expr"], "getProgressIncrease(1f)")
        self.assertEqual(progress_increase["godot_symbol"], "source_building_display_efficiency_result.progressIncrease")

        base_time = source_symbols.source_symbol(registry, "building_display_efficiency.base_time")
        self.assertEqual(base_time["java_expr"], "1f")
        self.assertEqual(base_time["godot_symbol"], "source_building_display_efficiency_result.baseTime")

        edelta_value = source_symbols.source_symbol(registry, "building_display_efficiency.edelta")
        self.assertEqual(edelta_value["status"], "explicit-input")
        self.assertEqual(edelta_value["java_expr"], "edelta()")
        self.assertEqual(edelta_value["godot_symbol"], "source_building_display_efficiency_input.edelta_value")

    def test_building_display_flow_rate_label_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        display_flow = source_symbols.source_symbol(registry, "building_display_flow_rate_label.display_flow")
        self.assertEqual(display_flow["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(display_flow["java_method"], "display(Table table)")
        self.assertEqual(display_flow["java_expr"], "if(displayFlow){")
        self.assertEqual(display_flow["godot_owner"], "PortGame.source_building_display_flow_rate_label")
        self.assertEqual(display_flow["runtime_proof"], "/root/Main.source_building_display_flow_rate_label")
        self.assertEqual(display_flow["godot_symbol"], "source_building_display_flow_rate_label_result.displayFlowGate")

        per_second = source_symbols.source_symbol(registry, "building_display_flow_rate_label.per_second_label")
        self.assertEqual(per_second["java_expr"], "String ps = \" \" + StatUnit.perSecond.localized();")
        self.assertEqual(per_second["godot_symbol"], "source_building_display_flow_rate_label_input.per_second_label")

        flow_rate_call = source_symbols.source_symbol(registry, "building_display_flow_rate_label.flow_rate_call")
        self.assertEqual(flow_rate_call["java_expr"], "flowItems.getFlowRate(item)")
        self.assertEqual(flow_rate_call["godot_symbol"], "source_building_display_flow_rate_label_input.flow_rate")

        unknown = source_symbols.source_symbol(registry, "building_display_flow_rate_label.unknown")
        self.assertEqual(unknown["java_expr"], "flowItems.getFlowRate(item) < 0 ? \"...\"")
        self.assertEqual(unknown["godot_symbol"], "source_building_display_flow_rate_label_result.unknown")

        fixed = source_symbols.source_symbol(registry, "building_display_flow_rate_label.fixed")
        self.assertEqual(fixed["java_expr"], "Strings.fixed(flowItems.getFlowRate(item), 1) + ps")
        self.assertEqual(fixed["godot_symbol"], "source_building_display_flow_rate_label_result.fixedLabel")

    def test_building_display_icon_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_display_icon.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "display(Table table)")
        self.assertEqual(method["java_expr"], "public void display(Table table){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_display_icon_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_display_icon_state")
        self.assertEqual(method["godot_symbol"], "source_building_display_icon_result.method")

        image_call = source_symbols.source_symbol(registry, "building_display_icon.image_call")
        self.assertEqual(image_call["java_expr"], "t.add(new Image(block.getDisplayIcon(tile))).scaling(Scaling.fit).size(8 * 4);")
        self.assertEqual(image_call["godot_symbol"], "source_building_display_icon_result.imageCall")

        icon_lookup = source_symbols.source_symbol(registry, "building_display_icon.icon_lookup")
        self.assertEqual(icon_lookup["status"], "explicit-input")
        self.assertEqual(icon_lookup["java_expr"], "block.getDisplayIcon(tile)")
        self.assertEqual(icon_lookup["godot_symbol"], "source_building_display_icon_input.block_ui_icon")

        scaling = source_symbols.source_symbol(registry, "building_display_icon.scaling")
        self.assertEqual(scaling["java_expr"], "Scaling.fit")
        self.assertEqual(scaling["godot_symbol"], "source_building_display_icon_result.scaling")

        size = source_symbols.source_symbol(registry, "building_display_icon.size")
        self.assertEqual(size["java_expr"], "8 * 4")
        self.assertEqual(size["godot_symbol"], "source_building_display_icon_result.size")

    def test_building_display_name_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_display_name.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "getDisplayName()")
        self.assertEqual(method["java_expr"], "public String getDisplayName(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_display_name_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_display_name_state")
        self.assertEqual(method["godot_symbol"], "source_building_display_name_result.method")

        derelict_comment = source_symbols.source_symbol(registry, "building_display_name.derelict_comment")
        self.assertEqual(derelict_comment["java_expr"], "//derelict team icon currently doesn't display")
        self.assertEqual(derelict_comment["godot_symbol"], "source_building_display_name_result.derelictComment")

        derelict = source_symbols.source_symbol(registry, "building_display_name.derelict_return")
        self.assertEqual(derelict["java_expr"], "block.localizedName + \"\\n\" + Core.bundle.get(\"block.derelict\")")
        self.assertEqual(derelict["godot_symbol"], "source_building_display_name_result.derelictName")

        regular = source_symbols.source_symbol(registry, "building_display_name.regular_return")
        self.assertEqual(regular["java_expr"], "block.localizedName + (team == player.team() || team.emoji.isEmpty() ? \"\" : \" \" + team.emoji)")
        self.assertEqual(regular["godot_symbol"], "source_building_display_name_result.displayName")

        label_wrap = source_symbols.source_symbol(registry, "building_display_name.label_wrap")
        self.assertEqual(label_wrap["java_method"], "display(Table table)")
        self.assertEqual(label_wrap["java_expr"], "t.labelWrap(block.getDisplayName(tile)).left().width(190f).padLeft(5);")
        self.assertEqual(label_wrap["godot_symbol"], "source_building_display_name_result.labelWrap")

        localized_name = source_symbols.source_symbol(registry, "building_display_name.localized_name")
        self.assertEqual(localized_name["status"], "explicit-input")
        self.assertEqual(localized_name["java_expr"], "block.localizedName")
        self.assertEqual(localized_name["godot_symbol"], "source_building_display_name_input.localized_name")

    def test_building_display_ui_gates_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_display_ui_gates.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "display(Table table)")
        self.assertEqual(method["java_expr"], "public void display(Table table){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_display_ui_gates_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_display_ui_gates_state")
        self.assertEqual(method["godot_symbol"], "source_building_display_ui_gates_result.method")

        header = source_symbols.source_symbol(registry, "building_display_ui_gates.header_table")
        self.assertEqual(header["java_expr"], "table.table(t -> {")
        self.assertEqual(header["godot_symbol"], "source_building_display_ui_gates_result.displayHeader")

        same_team = source_symbols.source_symbol(registry, "building_display_ui_gates.same_team_guard")
        self.assertEqual(same_team["java_expr"], "if(team == player.team()){")
        self.assertEqual(same_team["godot_symbol"], "source_building_display_ui_gates_result.sameTeamDetails")

        bars = source_symbols.source_symbol(registry, "building_display_ui_gates.display_bars_call")
        self.assertEqual(bars["java_expr"], "displayBars(bars);")
        self.assertEqual(bars["godot_symbol"], "source_building_display_ui_gates_result.displayBars")

        consumption = source_symbols.source_symbol(registry, "building_display_ui_gates.display_consumption_table")
        self.assertEqual(consumption["java_expr"], "table.table(this::displayConsumption).growX();")
        self.assertEqual(consumption["godot_symbol"], "source_building_display_ui_gates_result.displayConsumption")

        flow_formula = source_symbols.source_symbol(registry, "building_display_ui_gates.display_flow_formula")
        self.assertEqual(flow_formula["java_expr"], "boolean displayFlow = (block.category == Category.distribution || block.category == Category.liquid) && block.displayFlow;")
        self.assertEqual(flow_formula["godot_symbol"], "source_building_display_ui_gates_result.displayFlowFormula")

        flow_guard = source_symbols.source_symbol(registry, "building_display_ui_gates.display_flow_guard")
        self.assertEqual(flow_guard["java_expr"], "if(displayFlow){")
        self.assertEqual(flow_guard["godot_symbol"], "source_building_display_ui_gates_result.displayFlow")

        last_accessed = source_symbols.source_symbol(registry, "building_display_ui_gates.last_accessed_guard")
        self.assertEqual(last_accessed["java_expr"], "if(net.active() && lastAccessed != null){")
        self.assertEqual(last_accessed["godot_symbol"], "source_building_display_ui_gates_result.displayLastAccessed")

        block_category = source_symbols.source_symbol(registry, "building_display_ui_gates.block_category")
        self.assertEqual(block_category["status"], "explicit-input")
        self.assertEqual(block_category["java_expr"], "block.category")
        self.assertEqual(block_category["godot_symbol"], "source_building_display_ui_gates_input.block_category")

    def test_building_draw_cached_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        comment = source_symbols.source_symbol(registry, "building_draw_cached.comment")
        self.assertEqual(comment["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(comment["java_method"], "drawCached()")
        self.assertEqual(comment["java_expr"], "/** Called only if {@link Block#drawCached} is true (off by default). */")
        self.assertEqual(comment["godot_owner"], "PortGame.source_building_draw_cached_state")
        self.assertEqual(comment["runtime_proof"], "/root/Main.source_building_draw_cached_state")
        self.assertEqual(comment["godot_symbol"], "source_building_draw_cached_result.comment")

        method = source_symbols.source_symbol(registry, "building_draw_cached.method")
        self.assertEqual(method["java_expr"], "public void drawCached(){")
        self.assertEqual(method["godot_symbol"], "source_building_draw_cached_result.method")

        delegate = source_symbols.source_symbol(registry, "building_draw_cached.draw_delegate")
        self.assertEqual(delegate["java_expr"], "draw();")
        self.assertEqual(delegate["godot_symbol"], "source_building_draw_cached_result.drawDelegate")

        variants = source_symbols.source_symbol(registry, "building_draw_cached.variants")
        self.assertEqual(variants["status"], "explicit-input")
        self.assertEqual(variants["java_expr"], "block.variants")
        self.assertEqual(variants["godot_symbol"], "source_building_draw_cached_input.variants")

        tile_pos = source_symbols.source_symbol(registry, "building_draw_cached.tile_pos")
        self.assertEqual(tile_pos["status"], "explicit-input")
        self.assertEqual(tile_pos["java_expr"], "tile.pos()")
        self.assertEqual(tile_pos["godot_symbol"], "source_building_draw_cached_input.tile_pos")

        drawrot = source_symbols.source_symbol(registry, "building_draw_cached.drawrot_formula")
        self.assertEqual(drawrot["java_method"], "drawrot()")
        self.assertEqual(drawrot["java_expr"], "return block.rotate && block.rotateDraw ? rotation * 90 : 0f;")
        self.assertEqual(drawrot["godot_symbol"], "source_building_draw_cached_result.drawrotFormula")

    def test_building_draw_configure_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_draw_configure.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "drawConfigure()")
        self.assertEqual(method["java_expr"], "public void drawConfigure(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_draw_configure_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_draw_configure_state")
        self.assertEqual(method["godot_symbol"], "source_building_draw_configure_result.method")

        color = source_symbols.source_symbol(registry, "building_draw_configure.color")
        self.assertEqual(color["java_expr"], "Draw.color(Pal.accent);")
        self.assertEqual(color["godot_symbol"], "source_building_draw_configure_result.color")

        stroke = source_symbols.source_symbol(registry, "building_draw_configure.stroke")
        self.assertEqual(stroke["java_expr"], "Lines.stroke(1f);")
        self.assertEqual(stroke["godot_symbol"], "source_building_draw_configure_result.stroke")

        square = source_symbols.source_symbol(registry, "building_draw_configure.square")
        self.assertEqual(square["java_expr"], "Lines.square(x, y, block.size * tilesize / 2f + 1f);")
        self.assertEqual(square["godot_symbol"], "source_building_draw_configure_result.square")

        radius_offset = source_symbols.source_symbol(registry, "building_draw_configure.radius_offset")
        self.assertEqual(radius_offset["java_expr"], "+ 1f")
        self.assertEqual(radius_offset["godot_symbol"], "source_building_draw_configure_result.radiusOffset")

        reset = source_symbols.source_symbol(registry, "building_draw_configure.reset")
        self.assertEqual(reset["java_expr"], "Draw.reset();")
        self.assertEqual(reset["godot_symbol"], "source_building_draw_configure_result.reset")

        source_x = source_symbols.source_symbol(registry, "building_draw_configure.source_x")
        self.assertEqual(source_x["status"], "explicit-input")
        self.assertEqual(source_x["java_expr"], "x")
        self.assertEqual(source_x["godot_symbol"], "source_building_draw_configure_input.source_x")

        block_size = source_symbols.source_symbol(registry, "building_draw_configure.block_size")
        self.assertEqual(block_size["status"], "explicit-input")
        self.assertEqual(block_size["java_expr"], "block.size")
        self.assertEqual(block_size["godot_symbol"], "source_building_draw_configure_input.block_size_value")

    def test_building_draw_cracks_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_draw_cracks.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "drawCracks()")
        self.assertEqual(method["java_expr"], "public void drawCracks(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_draw_cracks_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_draw_cracks_state")
        self.assertEqual(method["godot_symbol"], "source_building_draw_cracks_result.method")

        guard = source_symbols.source_symbol(registry, "building_draw_cracks.guard")
        self.assertEqual(guard["java_expr"], "if(!block.drawCracks || !damaged() || block.size > BlockRenderer.maxCrackSize) return;")
        self.assertEqual(guard["godot_symbol"], "source_building_draw_cracks_result.visible")

        crack_index = source_symbols.source_symbol(registry, "building_draw_cracks.crack_index")
        self.assertEqual(crack_index["java_expr"], "Mathf.clamp((int)((1f - healthf()) * BlockRenderer.crackRegions), 0, BlockRenderer.crackRegions-1)")
        self.assertEqual(crack_index["godot_symbol"], "source_building_draw_cracks_result.crackIndex")

        lightness = source_symbols.source_symbol(registry, "building_draw_cracks.lightness")
        self.assertEqual(lightness["java_expr"], "0.1f + (1f - healthf())* 0.6f")
        self.assertEqual(lightness["godot_symbol"], "source_building_draw_cracks_result.lightness")

        rotation = source_symbols.source_symbol(registry, "building_draw_cracks.rotation")
        self.assertEqual(rotation["java_expr"], "(id%4)*90")
        self.assertEqual(rotation["godot_symbol"], "source_building_draw_cracks_result.rotationDegrees")

        todo = source_symbols.source_symbol(registry, "building_draw_cracks.todo")
        self.assertEqual(todo["java_expr"], "//TODO could be random, flipped, pseudorandom, etc")
        self.assertEqual(todo["godot_symbol"], "source_building_draw_cracks_result.todo")

        draw_cracks = source_symbols.source_symbol(registry, "building_draw_cracks.draw_cracks")
        self.assertEqual(draw_cracks["status"], "explicit-input")
        self.assertEqual(draw_cracks["java_expr"], "block.drawCracks")
        self.assertEqual(draw_cracks["godot_symbol"], "source_building_draw_cracks_input.draw_cracks")

        position_id = source_symbols.source_symbol(registry, "building_draw_cracks.position_id")
        self.assertEqual(position_id["status"], "explicit-input")
        self.assertEqual(position_id["java_expr"], "pos()")
        self.assertEqual(position_id["godot_symbol"], "source_building_draw_cracks_input.position_id")

    def test_building_draw_item_selection_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_draw_item_selection.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "drawItemSelection(@Nullable UnlockableContent selection)")
        self.assertEqual(method["java_expr"], "public void drawItemSelection(@Nullable UnlockableContent selection){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_draw_item_selection_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_draw_item_selection_state")
        self.assertEqual(method["godot_symbol"], "source_building_draw_item_selection_result.method")

        guard = source_symbols.source_symbol(registry, "building_draw_item_selection.guard")
        self.assertEqual(guard["java_expr"], "if(selection != null){")
        self.assertEqual(guard["godot_symbol"], "source_building_draw_item_selection_result.visible")

        dx = source_symbols.source_symbol(registry, "building_draw_item_selection.dx")
        self.assertEqual(dx["java_expr"], "x - block.size * tilesize/2f")
        self.assertEqual(dx["godot_symbol"], "source_building_draw_item_selection_result.dx")

        selection_width = source_symbols.source_symbol(registry, "building_draw_item_selection.selection_width")
        self.assertEqual(selection_width["java_expr"], "iconSmall / 4f * selection.fullIcon.ratio()")
        self.assertEqual(selection_width["godot_symbol"], "source_building_draw_item_selection_result.selection_width")

        mixcol = source_symbols.source_symbol(registry, "building_draw_item_selection.mixcol")
        self.assertEqual(mixcol["java_expr"], "Draw.mixcol(Color.darkGray, 1f);")
        self.assertEqual(mixcol["godot_symbol"], "source_building_draw_item_selection_result.shadow_color")

        shadow_rect = source_symbols.source_symbol(registry, "building_draw_item_selection.shadow_rect")
        self.assertEqual(shadow_rect["java_expr"], "Draw.rect(selection.fullIcon, dx, dy - 1, s, h);")
        self.assertEqual(shadow_rect["godot_symbol"], "source_building_draw_item_selection_result.shadow_rect")

        foreground_rect = source_symbols.source_symbol(registry, "building_draw_item_selection.foreground_rect")
        self.assertEqual(foreground_rect["java_expr"], "Draw.rect(selection.fullIcon, dx, dy, s, h);")
        self.assertEqual(foreground_rect["godot_symbol"], "source_building_draw_item_selection_result.foreground_rect")

        has_selection = source_symbols.source_symbol(registry, "building_draw_item_selection.has_selection")
        self.assertEqual(has_selection["status"], "explicit-input")
        self.assertEqual(has_selection["java_expr"], "selection != null")
        self.assertEqual(has_selection["godot_symbol"], "source_building_draw_item_selection_input.has_selection")

    def test_building_draw_light_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_draw_light.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "drawLight()")
        self.assertEqual(method["java_expr"], "public void drawLight(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_draw_light_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_draw_light_state")
        self.assertEqual(method["godot_symbol"], "source_building_draw_light_result.method")

        liquid_select = source_symbols.source_symbol(registry, "building_draw_light.liquid_select")
        self.assertEqual(liquid_select["java_expr"], "Liquid liq = block.hasLiquids && block.lightLiquid == null ? liquids.current() : block.lightLiquid;")
        self.assertEqual(liquid_select["godot_symbol"], "source_building_draw_light_result.liquidSelect")

        guard = source_symbols.source_symbol(registry, "building_draw_light.guard")
        self.assertEqual(guard["java_expr"], "if(block.hasLiquids && block.drawLiquidLight && liq.lightColor.a > 0.001f){")
        self.assertEqual(guard["godot_symbol"], "source_building_draw_light_result.visible")

        visual_update = source_symbols.source_symbol(registry, "building_draw_light.visual_update")
        self.assertEqual(visual_update["java_expr"], "visualLiquid = Mathf.lerpDelta(visualLiquid, liquids.get(liq)>= 0.01f ? 1f : 0f, 0.06f);")
        self.assertEqual(visual_update["godot_symbol"], "source_building_draw_light_result.visualLiquid")

        draw_liquid_light = source_symbols.source_symbol(registry, "building_draw_light.draw_liquid_light")
        self.assertEqual(draw_liquid_light["java_expr"], "drawLiquidLight(liq, visualLiquid);")
        self.assertEqual(draw_liquid_light["godot_symbol"], "source_building_draw_light_result.drawLiquidLightCall")

        has_liquids = source_symbols.source_symbol(registry, "building_draw_light.has_liquids")
        self.assertEqual(has_liquids["status"], "explicit-input")
        self.assertEqual(has_liquids["java_expr"], "block.hasLiquids")
        self.assertEqual(has_liquids["godot_symbol"], "source_building_draw_light_input.has_liquids")

    def test_building_draw_liquid_light_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_draw_liquid_light.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "drawLiquidLight(Liquid liquid, float amount)")
        self.assertEqual(method["java_expr"], "public void drawLiquidLight(Liquid liquid, float amount){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_draw_liquid_light_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_draw_liquid_light_state")
        self.assertEqual(method["godot_symbol"], "source_building_draw_liquid_light_result.method")

        amount_gate = source_symbols.source_symbol(registry, "building_draw_liquid_light.amount_gate")
        self.assertEqual(amount_gate["java_expr"], "if(amount > 0.01f){")
        self.assertEqual(amount_gate["godot_symbol"], "source_building_draw_liquid_light_result.visible")

        color = source_symbols.source_symbol(registry, "building_draw_liquid_light.color")
        self.assertEqual(color["java_expr"], "Color color = liquid.lightColor;")
        self.assertEqual(color["godot_symbol"], "source_building_draw_liquid_light_result.color")

        opacity = source_symbols.source_symbol(registry, "building_draw_liquid_light.opacity")
        self.assertEqual(opacity["java_expr"], "float opacity = color.a * fract;")
        self.assertEqual(opacity["godot_symbol"], "source_building_draw_liquid_light_result.opacity")

        drawf_light = source_symbols.source_symbol(registry, "building_draw_liquid_light.drawf_light")
        self.assertEqual(drawf_light["java_expr"], "Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);")
        self.assertEqual(drawf_light["godot_symbol"], "source_building_draw_liquid_light_result.drawfLightCall")

        amount = source_symbols.source_symbol(registry, "building_draw_liquid_light.amount")
        self.assertEqual(amount["status"], "explicit-input")
        self.assertEqual(amount["java_expr"], "amount")
        self.assertEqual(amount["godot_symbol"], "source_building_draw_liquid_light_input.amount")

    def test_building_draw_select_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_draw_select.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "drawSelect()")
        self.assertEqual(method["java_expr"], "public void drawSelect(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_draw_select_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_draw_select_state")
        self.assertEqual(method["godot_symbol"], "source_building_draw_select_result.method")

        comment = source_symbols.source_symbol(registry, "building_draw_select.comment")
        self.assertEqual(comment["java_expr"], "/** Draw the block overlay that is shown when a cursor is over the block. */")
        self.assertEqual(comment["godot_symbol"], "source_building_draw_select_result.comment")

        overlay = source_symbols.source_symbol(registry, "building_draw_select.overlay")
        self.assertEqual(overlay["java_expr"], "block.drawOverlay(x, y, rotation);")
        self.assertEqual(overlay["godot_symbol"], "source_building_draw_select_result.overlay")

        inactive_gate = source_symbols.source_symbol(registry, "building_draw_select.inactive_unit_factory_gate")
        self.assertEqual(inactive_gate["java_expr"], "if(status() == BlockStatus.inactiveUnitFactory){")
        self.assertEqual(inactive_gate["godot_symbol"], "source_building_draw_select_result.placeTextVisible")

        place_text = source_symbols.source_symbol(registry, "building_draw_select.place_text")
        self.assertEqual(place_text["java_expr"], "block.drawPlaceText(Core.bundle.format(\"rules.unitfactoryactivation.objective\", UI.formatTime((float)Math.max(0f, state.rules.unitActivationDelay(team) - state.tick))), tile.x, tile.y, false);")
        self.assertEqual(place_text["godot_symbol"], "source_building_draw_select_result.placeText")

        block_status = source_symbols.source_symbol(registry, "building_draw_select.block_status")
        self.assertEqual(block_status["status"], "explicit-input")
        self.assertEqual(block_status["java_expr"], "status()")
        self.assertEqual(block_status["godot_symbol"], "source_building_draw_select_input.block_status")

        source_rotation = source_symbols.source_symbol(registry, "building_draw_select.source_rotation")
        self.assertEqual(source_rotation["status"], "explicit-input")
        self.assertEqual(source_rotation["java_expr"], "rotation")
        self.assertEqual(source_rotation["godot_symbol"], "source_building_draw_select_input.source_rotation")

        unit_activation_delay = source_symbols.source_symbol(registry, "building_draw_select.unit_activation_delay")
        self.assertEqual(unit_activation_delay["status"], "explicit-input")
        self.assertEqual(unit_activation_delay["java_expr"], "state.rules.unitActivationDelay(team)")
        self.assertEqual(unit_activation_delay["godot_symbol"], "source_building_draw_select_input.unit_activation_delay")

    def test_building_draw_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_draw.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "draw()")
        self.assertEqual(method["java_expr"], "public void draw(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_draw_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_draw_state")
        self.assertEqual(method["godot_symbol"], "source_building_draw_result.method")

        comment = source_symbols.source_symbol(registry, "building_draw.comment")
        self.assertEqual(comment["java_expr"], "/** Called only if {@link Block#drawDynamic} is true (on by default). */")
        self.assertEqual(comment["godot_symbol"], "source_building_draw_result.comment")

        base_guard = source_symbols.source_symbol(registry, "building_draw.base_region_guard")
        self.assertEqual(base_guard["java_expr"], "if(block.variants == 0 || block.variantRegions == null){")
        self.assertEqual(base_guard["godot_symbol"], "source_building_draw_result.baseRegionGuard")

        region_draw = source_symbols.source_symbol(registry, "building_draw.region_draw")
        self.assertEqual(region_draw["java_expr"], "Draw.rect(block.region, x, y, drawrot());")
        self.assertEqual(region_draw["godot_symbol"], "source_building_draw_result.regionDraw")

        variant_draw = source_symbols.source_symbol(registry, "building_draw.variant_draw")
        self.assertEqual(variant_draw["java_expr"], "Draw.rect(block.variantRegions[Mathf.randomSeed(tile.pos(), 0, Math.max(0, block.variantRegions.length - 1))], x, y, drawrot());")
        self.assertEqual(variant_draw["godot_symbol"], "source_building_draw_result.variantDraw")

        random_seed = source_symbols.source_symbol(registry, "building_draw.random_seed")
        self.assertEqual(random_seed["java_expr"], "Mathf.randomSeed(tile.pos(), 0, Math.max(0, block.variantRegions.length - 1))")
        self.assertEqual(random_seed["godot_symbol"], "source_building_draw_result.variant_index")

        variants = source_symbols.source_symbol(registry, "building_draw.variants")
        self.assertEqual(variants["status"], "explicit-input")
        self.assertEqual(variants["java_expr"], "block.variants")
        self.assertEqual(variants["godot_symbol"], "source_building_draw_input.variants")

        rotation_quadrants = source_symbols.source_symbol(registry, "building_draw.rotation_quadrants")
        self.assertEqual(rotation_quadrants["status"], "explicit-input")
        self.assertEqual(rotation_quadrants["java_expr"], "rotation")
        self.assertEqual(rotation_quadrants["godot_symbol"], "source_building_draw_input.rotation_quadrants")

    def test_building_draw_status_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_draw_status.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "drawStatus()")
        self.assertEqual(method["java_expr"], "public void drawStatus(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_draw_status_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_draw_status_state")
        self.assertEqual(method["godot_symbol"], "source_building_draw_status_result.method")

        guard = source_symbols.source_symbol(registry, "building_draw_status.guard")
        self.assertEqual(guard["java_expr"], "if(block.enableDrawStatus && block.consumers.length > 0){")
        self.assertEqual(guard["godot_symbol"], "source_building_draw_status_result.visible")

        multiplier = source_symbols.source_symbol(registry, "building_draw_status.multiplier")
        self.assertEqual(multiplier["java_expr"], "float multiplier = block.size > 1 ? 1 : 0.64f;")
        self.assertEqual(multiplier["godot_symbol"], "source_building_draw_status_result.multiplier")

        brcx = source_symbols.source_symbol(registry, "building_draw_status.brcx")
        self.assertEqual(brcx["java_expr"], "float brcx = x + (block.size * tilesize / 2f) - (tilesize * multiplier / 2f);")
        self.assertEqual(brcx["godot_symbol"], "source_building_draw_status_result.brcx")

        brcy = source_symbols.source_symbol(registry, "building_draw_status.brcy")
        self.assertEqual(brcy["java_expr"], "float brcy = y - (block.size * tilesize / 2f) + (tilesize * multiplier / 2f);")
        self.assertEqual(brcy["godot_symbol"], "source_building_draw_status_result.brcy")

        gray_square = source_symbols.source_symbol(registry, "building_draw_status.gray_square")
        self.assertEqual(gray_square["java_expr"], "Fill.square(brcx, brcy, 2.5f * multiplier, 45);")
        self.assertEqual(gray_square["godot_symbol"], "source_building_draw_status_result.gray_square_size")

        status_square = source_symbols.source_symbol(registry, "building_draw_status.status_square")
        self.assertEqual(status_square["java_expr"], "Fill.square(brcx, brcy, 1.5f * multiplier, 45);")
        self.assertEqual(status_square["godot_symbol"], "source_building_draw_status_result.status_square_size")

        enable_draw_status = source_symbols.source_symbol(registry, "building_draw_status.enable_draw_status")
        self.assertEqual(enable_draw_status["status"], "explicit-input")
        self.assertEqual(enable_draw_status["java_expr"], "block.enableDrawStatus")
        self.assertEqual(enable_draw_status["godot_symbol"], "source_building_draw_status_input.enable_draw_status")

        consumers_length = source_symbols.source_symbol(registry, "building_draw_status.consumers_length")
        self.assertEqual(consumers_length["status"], "explicit-input")
        self.assertEqual(consumers_length["java_expr"], "block.consumers.length")
        self.assertEqual(consumers_length["godot_symbol"], "source_building_draw_status_input.consumers_length")

    def test_building_draw_team_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_draw_team.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "drawTeam()")
        self.assertEqual(method["java_expr"], "public void drawTeam(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_draw_team_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_draw_team_state")
        self.assertEqual(method["godot_symbol"], "source_building_draw_team_result.method")

        color = source_symbols.source_symbol(registry, "building_draw_team.color")
        self.assertEqual(color["java_expr"], "Draw.color(team.color);")
        self.assertEqual(color["godot_symbol"], "source_building_draw_team_result.color")

        rect = source_symbols.source_symbol(registry, "building_draw_team.rect")
        self.assertEqual(rect["java_expr"], "Draw.rect(\"block-border\", x - block.size * tilesize / 2f + 4, y - block.size * tilesize / 2f + 4);")
        self.assertEqual(rect["godot_symbol"], "source_building_draw_team_result.rect")

        border_x = source_symbols.source_symbol(registry, "building_draw_team.border_x")
        self.assertEqual(border_x["java_expr"], "x - block.size * tilesize / 2f + 4")
        self.assertEqual(border_x["godot_symbol"], "source_building_draw_team_result.x")

        border_y = source_symbols.source_symbol(registry, "building_draw_team.border_y")
        self.assertEqual(border_y["java_expr"], "y - block.size * tilesize / 2f + 4")
        self.assertEqual(border_y["godot_symbol"], "source_building_draw_team_result.y")

        team_color = source_symbols.source_symbol(registry, "building_draw_team.team_color")
        self.assertEqual(team_color["status"], "explicit-input")
        self.assertEqual(team_color["java_expr"], "team.color")
        self.assertEqual(team_color["godot_symbol"], "source_building_draw_team_input.team_color")

        block_size = source_symbols.source_symbol(registry, "building_draw_team.block_size")
        self.assertEqual(block_size["status"], "explicit-input")
        self.assertEqual(block_size["java_expr"], "block.size")
        self.assertEqual(block_size["godot_symbol"], "source_building_draw_team_input.block_size_value")

    def test_building_draw_team_top_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_draw_team_top.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "drawTeamTop()")
        self.assertEqual(method["java_expr"], "public void drawTeamTop(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_draw_team_top_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_draw_team_top_state")
        self.assertEqual(method["godot_symbol"], "source_building_draw_team_top_result.method")

        guard = source_symbols.source_symbol(registry, "building_draw_team_top.guard")
        self.assertEqual(guard["java_expr"], "if(block.teamRegion.found()){")
        self.assertEqual(guard["godot_symbol"], "source_building_draw_team_top_result.visible")

        tint = source_symbols.source_symbol(registry, "building_draw_team_top.tint")
        self.assertEqual(tint["java_expr"], "if(block.teamRegions[team.id] == block.teamRegion) Draw.color(team.color);")
        self.assertEqual(tint["godot_symbol"], "source_building_draw_team_top_result.tint_color")

        rect = source_symbols.source_symbol(registry, "building_draw_team_top.rect")
        self.assertEqual(rect["java_expr"], "Draw.rect(block.teamRegions[team.id], x, y);")
        self.assertEqual(rect["godot_symbol"], "source_building_draw_team_top_result.rect")

        reset = source_symbols.source_symbol(registry, "building_draw_team_top.reset")
        self.assertEqual(reset["java_expr"], "Draw.color();")
        self.assertEqual(reset["godot_symbol"], "source_building_draw_team_top_result.color_reset")

        team_region_found = source_symbols.source_symbol(registry, "building_draw_team_top.team_region_found")
        self.assertEqual(team_region_found["status"], "explicit-input")
        self.assertEqual(team_region_found["java_expr"], "block.teamRegion.found()")
        self.assertEqual(team_region_found["godot_symbol"], "source_building_draw_team_top_input.team_region_found")

        team_region_matches_team = source_symbols.source_symbol(registry, "building_draw_team_top.team_region_matches_team")
        self.assertEqual(team_region_matches_team["status"], "explicit-input")
        self.assertEqual(team_region_matches_team["java_expr"], "block.teamRegions[team.id] == block.teamRegion")
        self.assertEqual(team_region_matches_team["godot_symbol"], "source_building_draw_team_top_input.team_region_matches_team")

    def test_building_drawrot_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_drawrot.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "drawrot()")
        self.assertEqual(method["java_expr"], "public float drawrot(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_drawrot_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_drawrot_state")
        self.assertEqual(method["godot_symbol"], "source_building_drawrot_result.method")

        rotation = source_symbols.source_symbol(registry, "building_drawrot.rotation")
        self.assertEqual(rotation["java_expr"], "return block.rotate && block.rotateDraw ? rotation * 90 : 0f;")
        self.assertEqual(rotation["godot_symbol"], "source_building_drawrot_result.rotation_degrees")

        block_rotate = source_symbols.source_symbol(registry, "building_drawrot.block_rotate")
        self.assertEqual(block_rotate["status"], "explicit-input")
        self.assertEqual(block_rotate["java_expr"], "block.rotate")
        self.assertEqual(block_rotate["godot_symbol"], "source_building_drawrot_input.block_rotate")

        block_rotate_draw = source_symbols.source_symbol(registry, "building_drawrot.block_rotate_draw")
        self.assertEqual(block_rotate_draw["status"], "explicit-input")
        self.assertEqual(block_rotate_draw["java_expr"], "block.rotateDraw")
        self.assertEqual(block_rotate_draw["godot_symbol"], "source_building_drawrot_input.block_rotate_draw")

        rotation_quadrants = source_symbols.source_symbol(registry, "building_drawrot.rotation_quadrants")
        self.assertEqual(rotation_quadrants["status"], "explicit-input")
        self.assertEqual(rotation_quadrants["java_expr"], "rotation")
        self.assertEqual(rotation_quadrants["godot_symbol"], "source_building_drawrot_input.rotation_quadrants")

    def test_building_edelta_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_edelta.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "edelta()")
        self.assertEqual(method["java_expr"], "public float edelta(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_edelta")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_edelta")
        self.assertEqual(method["godot_symbol"], "source_building_edelta_result.method")

        edelta_return = source_symbols.source_symbol(registry, "building_edelta.return")
        self.assertEqual(edelta_return["java_expr"], "return efficiency * delta();")
        self.assertEqual(edelta_return["godot_symbol"], "source_building_edelta_result.edelta")

        efficiency = source_symbols.source_symbol(registry, "building_edelta.efficiency")
        self.assertEqual(efficiency["status"], "explicit-input")
        self.assertEqual(efficiency["java_expr"], "efficiency")
        self.assertEqual(efficiency["godot_symbol"], "source_building_edelta_input.efficiency")

        source_delta = source_symbols.source_symbol(registry, "building_edelta.source_delta")
        self.assertEqual(source_delta["status"], "explicit-input")
        self.assertEqual(source_delta["java_method"], "delta()")
        self.assertEqual(source_delta["java_expr"], "Time.delta")
        self.assertEqual(source_delta["godot_symbol"], "source_building_edelta_input.source_delta")

        time_scale = source_symbols.source_symbol(registry, "building_edelta.time_scale")
        self.assertEqual(time_scale["status"], "explicit-input")
        self.assertEqual(time_scale["java_method"], "delta()")
        self.assertEqual(time_scale["java_expr"], "timeScale")
        self.assertEqual(time_scale["godot_symbol"], "source_building_edelta_input.time_scale")

    def test_building_efficiency_scale_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        comment = source_symbols.source_symbol(registry, "building_efficiency_scale.comment")
        self.assertEqual(comment["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(comment["java_method"], "efficiencyScale()")
        self.assertEqual(comment["java_expr"], "/** Calculate your own efficiency multiplier. By default, this is applied in updateEfficiencyMultiplier. */")
        self.assertEqual(comment["godot_owner"], "PortGame.source_building_efficiency_scale_state")
        self.assertEqual(comment["runtime_proof"], "/root/Main.source_building_efficiency_scale_state")
        self.assertEqual(comment["godot_symbol"], "source_building_efficiency_scale_result.comment")

        method = source_symbols.source_symbol(registry, "building_efficiency_scale.method")
        self.assertEqual(method["java_expr"], "public float efficiencyScale(){")
        self.assertEqual(method["godot_symbol"], "source_building_efficiency_scale_result.method")

        return_value = source_symbols.source_symbol(registry, "building_efficiency_scale.return")
        self.assertEqual(return_value["java_expr"], "return 1f;")
        self.assertEqual(return_value["godot_symbol"], "source_building_efficiency_scale_result.efficiency_scale")

    def test_building_draw_disabled_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "building_draw_disabled.method")
        self.assertEqual(method["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(method["java_method"], "drawDisabled()")
        self.assertEqual(method["java_expr"], "public void drawDisabled(){")
        self.assertEqual(method["godot_owner"], "PortGame.source_building_draw_disabled_state")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_building_draw_disabled_state")
        self.assertEqual(method["godot_symbol"], "source_building_draw_disabled_result.method")

        color = source_symbols.source_symbol(registry, "building_draw_disabled.color")
        self.assertEqual(color["java_expr"], "Draw.color(Color.scarlet);")
        self.assertEqual(color["godot_symbol"], "source_building_draw_disabled_result.color")

        alpha = source_symbols.source_symbol(registry, "building_draw_disabled.alpha")
        self.assertEqual(alpha["java_expr"], "Draw.alpha(0.8f);")
        self.assertEqual(alpha["godot_symbol"], "source_building_draw_disabled_result.alpha")

        size = source_symbols.source_symbol(registry, "building_draw_disabled.size")
        self.assertEqual(size["java_expr"], "float size = 6f;")
        self.assertEqual(size["godot_symbol"], "source_building_draw_disabled_result.size")

        rect = source_symbols.source_symbol(registry, "building_draw_disabled.rect")
        self.assertEqual(rect["java_expr"], "Draw.rect(Icon.cancel.getRegion(), x, y, size, size);")
        self.assertEqual(rect["godot_symbol"], "source_building_draw_disabled_result.rect")

        reset = source_symbols.source_symbol(registry, "building_draw_disabled.reset")
        self.assertEqual(reset["java_expr"], "Draw.reset();")
        self.assertEqual(reset["godot_symbol"], "source_building_draw_disabled_result.reset")

        source_x = source_symbols.source_symbol(registry, "building_draw_disabled.source_x")
        self.assertEqual(source_x["status"], "explicit-input")
        self.assertEqual(source_x["java_expr"], "x")
        self.assertEqual(source_x["godot_symbol"], "source_building_draw_disabled_input.source_x")

    def test_arc_mathf_cos_scaled_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_mathf_cos_scaled.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(method["java_expr"], "public static float cos(float radians, float scl, float mag){\n        return cos(radians / scl) * mag;\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_mathf_cos_scaled")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_mathf_cos_scaled")

        scaled_radians = source_symbols.source_symbol(registry, "arc_mathf_cos_scaled.scaled_radians")
        self.assertEqual(scaled_radians["java_expr"], "radians / scl")
        self.assertEqual(scaled_radians["godot_symbol"], "source_arc_mathf_cos_scaled_result.scaledRadians")

        cos_lookup = source_symbols.source_symbol(registry, "arc_mathf_cos_scaled.cos_lookup")
        self.assertEqual(cos_lookup["java_expr"], "cos(radians / scl)")
        self.assertEqual(cos_lookup["godot_symbol"], "source_arc_mathf_cos_scaled_result.cosLookup")

        mag_input = source_symbols.source_symbol(registry, "arc_mathf_cos_scaled.mag_input")
        self.assertEqual(mag_input["status"], "explicit-input")
        self.assertEqual(mag_input["java_expr"], "mag")
        self.assertEqual(mag_input["godot_symbol"], "source_arc_mathf_cos_scaled_input.mag")

    def test_arc_mathf_mod_float_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_mathf_mod_float.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(method["java_expr"], "public static float mod(float f, float n){\n        return ((f % n) + n) % n;\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_mathf_mod_float")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_mathf_mod_float")

        raw_mod = source_symbols.source_symbol(registry, "arc_mathf_mod_float.raw_mod")
        self.assertEqual(raw_mod["java_expr"], "f % n")
        self.assertEqual(raw_mod["godot_symbol"], "source_arc_mathf_mod_float_result.rawMod")

        offset_mod = source_symbols.source_symbol(registry, "arc_mathf_mod_float.offset_mod")
        self.assertEqual(offset_mod["java_expr"], "(f % n) + n")
        self.assertEqual(offset_mod["godot_symbol"], "source_arc_mathf_mod_float_result.offsetMod")

        divisor_input = source_symbols.source_symbol(registry, "arc_mathf_mod_float.divisor_input")
        self.assertEqual(divisor_input["status"], "explicit-input")
        self.assertEqual(divisor_input["java_expr"], "n")
        self.assertEqual(divisor_input["godot_symbol"], "source_arc_mathf_mod_float_input.divisor")

    def test_arc_mathf_num_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_mathf_num.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(method["java_expr"], "public static int num(boolean b){\n        return b ? 1 : 0;\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_mathf_num")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_mathf_num")

        ternary = source_symbols.source_symbol(registry, "arc_mathf_num.ternary")
        self.assertEqual(ternary["java_expr"], "b ? 1 : 0")
        self.assertEqual(ternary["godot_symbol"], "source_arc_mathf_num_result.num")

        false_value = source_symbols.source_symbol(registry, "arc_mathf_num.false_value")
        self.assertEqual(false_value["java_expr"], "0")
        self.assertEqual(false_value["godot_symbol"], "source_arc_mathf_num_result.falseValue")

        value_input = source_symbols.source_symbol(registry, "arc_mathf_num.value_input")
        self.assertEqual(value_input["status"], "explicit-input")
        self.assertEqual(value_input["java_expr"], "b")
        self.assertEqual(value_input["godot_symbol"], "source_arc_mathf_num_input.value")

    def test_arc_angles_angle_distance_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        angle_dist_method = source_symbols.source_symbol(registry, "arc_angles_angle_dist.method")
        self.assertEqual(angle_dist_method["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(angle_dist_method["java_expr"], "public static float angleDist(float a, float b){\n        a = Mathf.mod(a, 360f);\n        b = Mathf.mod(b, 360f);\n        return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a);\n    }")
        self.assertEqual(angle_dist_method["godot_owner"], "PortGame.source_angle_distance")
        self.assertEqual(angle_dist_method["runtime_proof"], "/root/Main.source_angle_distance")

        mod_a = source_symbols.source_symbol(registry, "arc_angles_angle_dist.mod_a")
        self.assertEqual(mod_a["java_expr"], "a = Mathf.mod(a, 360f);")
        self.assertEqual(mod_a["godot_symbol"], "source_angle_distance_result.currentMod")

        mod_b = source_symbols.source_symbol(registry, "arc_angles_angle_dist.mod_b")
        self.assertEqual(mod_b["java_expr"], "b = Mathf.mod(b, 360f);")
        self.assertEqual(mod_b["godot_symbol"], "source_angle_distance_result.targetMod")

        min_distance = source_symbols.source_symbol(registry, "arc_angles_angle_dist.min_distance")
        self.assertEqual(min_distance["java_expr"], "Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a)")
        self.assertEqual(min_distance["godot_symbol"], "source_angle_distance_result.angleDistance")

        current_input = source_symbols.source_symbol(registry, "arc_angles_angle_dist.current_input")
        self.assertEqual(current_input["status"], "explicit-input")
        self.assertEqual(current_input["java_expr"], "a")
        self.assertEqual(current_input["godot_symbol"], "source_angle_distance_input.currentDegrees")

    def test_arc_angles_angle_dist_canonical_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_angles_angle_dist_canonical.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(method["java_expr"], "public static float angleDist(float a, float b){\n        a = Mathf.mod(a, 360f);\n        b = Mathf.mod(b, 360f);\n        return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a);\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_angles_angle_dist")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_angles_angle_dist")

        mod_a = source_symbols.source_symbol(registry, "arc_angles_angle_dist_canonical.mod_a")
        self.assertEqual(mod_a["java_expr"], "a = Mathf.mod(a, 360f);")
        self.assertEqual(mod_a["godot_symbol"], "source_arc_angles_angle_dist_result.angleAMod")

        min_distance = source_symbols.source_symbol(registry, "arc_angles_angle_dist_canonical.min_distance")
        self.assertEqual(min_distance["java_expr"], "Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a)")
        self.assertEqual(min_distance["godot_symbol"], "source_arc_angles_angle_dist_result.angleDistance")

    def test_arc_angles_backward_distance_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_angles_backward_distance.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(method["java_expr"], "public static float backwardDistance(float angle1, float angle2){\n        return 360 - Math.abs(angle1 - angle2);\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_angles_backward_distance")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_angles_backward_distance")

        return_expr = source_symbols.source_symbol(registry, "arc_angles_backward_distance.return_expr")
        self.assertEqual(return_expr["java_expr"], "return 360 - Math.abs(angle1 - angle2);")
        self.assertEqual(return_expr["godot_symbol"], "source_arc_angles_backward_distance_result.backwardDistance")

        angle1_input = source_symbols.source_symbol(registry, "arc_angles_backward_distance.angle1_input")
        self.assertEqual(angle1_input["status"], "explicit-input")
        self.assertEqual(angle1_input["java_expr"], "angle1")
        self.assertEqual(angle1_input["godot_symbol"], "source_arc_angles_backward_distance_input.angle1")

    def test_arc_angles_forward_distance_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_angles_forward_distance.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(method["java_expr"], "public static float forwardDistance(float angle1, float angle2){\n        return Math.abs(angle1 - angle2);\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_angles_forward_distance")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_angles_forward_distance")

        return_expr = source_symbols.source_symbol(registry, "arc_angles_forward_distance.return_expr")
        self.assertEqual(return_expr["java_expr"], "return Math.abs(angle1 - angle2);")
        self.assertEqual(return_expr["godot_symbol"], "source_arc_angles_forward_distance_result.forwardDistance")

        angle1_input = source_symbols.source_symbol(registry, "arc_angles_forward_distance.angle1_input")
        self.assertEqual(angle1_input["status"], "explicit-input")
        self.assertEqual(angle1_input["java_expr"], "angle1")
        self.assertEqual(angle1_input["godot_symbol"], "source_arc_angles_forward_distance_input.angle1")

    def test_arc_angles_move_toward_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_angles_move_toward.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(method["java_expr"], "public static float moveToward(float angle, float to, float speed){\n        if(Math.abs(angleDist(angle, to)) < speed) return to;\n        angle = Mathf.mod(angle, 360f);\n        to = Mathf.mod(to, 360f);\n\n        if(angle > to == backwardDistance(angle, to) > forwardDistance(angle, to)){\n            angle -= speed;\n        }else{\n            angle += speed;\n        }\n\n        return angle;\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_angles_move_toward")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_angles_move_toward")

        snap_guard = source_symbols.source_symbol(registry, "arc_angles_move_toward.snap_guard")
        self.assertEqual(snap_guard["java_expr"], "if(Math.abs(angleDist(angle, to)) < speed) return to;")
        self.assertEqual(snap_guard["godot_symbol"], "source_arc_angles_move_toward_result.snapToTarget")

        branch = source_symbols.source_symbol(registry, "arc_angles_move_toward.branch_condition")
        self.assertEqual(branch["java_expr"], "angle > to == backwardDistance(angle, to) > forwardDistance(angle, to)")
        self.assertEqual(branch["godot_symbol"], "source_arc_angles_move_toward_result.turnBackward")

        return_expr = source_symbols.source_symbol(registry, "arc_angles_move_toward.return_expr")
        self.assertEqual(return_expr["java_expr"], "return angle;")
        self.assertEqual(return_expr["godot_symbol"], "source_arc_angles_move_toward_result.moveToward")

    def test_arc_angles_trns_vec_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        trnsx_method = source_symbols.source_symbol(registry, "arc_angles_trns_vec.trnsx_method")
        self.assertEqual(trnsx_method["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(trnsx_method["java_expr"], "public static float trnsx(float angle, float x, float y){\n        return rv.set(x, y).rotate(angle).x;\n    }")
        self.assertEqual(trnsx_method["godot_owner"], "PortGame.source_arc_angles_trns_vec")
        self.assertEqual(trnsx_method["runtime_proof"], "/root/Main.source_arc_angles_trns_vec")

        trnsy_method = source_symbols.source_symbol(registry, "arc_angles_trns_vec.trnsy_method")
        self.assertEqual(trnsy_method["java_expr"], "public static float trnsy(float angle, float x, float y){\n        return rv.set(x, y).rotate(angle).y;\n    }")
        self.assertEqual(trnsy_method["godot_symbol"], "source_arc_angles_trns_vec_result.y")

        vec2_trns = source_symbols.source_symbol(registry, "arc_angles_trns_vec.vec2_trns")
        self.assertEqual(vec2_trns["java_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(vec2_trns["java_expr"], "public Vec2 trns(float angle, float x, float y){\n        return set(x, y).rotate(angle);\n    }")
        self.assertEqual(vec2_trns["godot_symbol"], "source_arc_angles_trns_vec_result.source")

        rotate_rad = source_symbols.source_symbol(registry, "arc_angles_trns_vec.rotate_rad")
        self.assertEqual(rotate_rad["java_expr"], "float newX = this.x * cos - this.y * sin;\n        float newY = this.x * sin + this.y * cos;")
        self.assertEqual(rotate_rad["godot_symbol"], "source_arc_angles_trns_vec_result.vec2RotateSource")

    def test_source_angles_angle_dist_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "source_angles_angle_dist.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(method["java_expr"], "public static float angleDist(float a, float b){\n        a = Mathf.mod(a, 360f);\n        b = Mathf.mod(b, 360f);\n        return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a);\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_angles_angle_dist")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_angles_angle_dist")

        wrapper = source_symbols.source_symbol(registry, "source_angles_angle_dist.canonical_wrapper")
        self.assertEqual(wrapper["status"], "generated")
        self.assertEqual(wrapper["godot_symbol"], "source_angles_angle_dist_result.angleDistance")
        self.assertEqual(wrapper["rule"], "Runtime delegates to canonical source_arc_angles_angle_dist(a, b) to avoid duplicating the angleDist formula.")

    def test_arc_angles_angle_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        method = source_symbols.source_symbol(registry, "arc_angles_angle.method")
        self.assertEqual(method["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(method["java_expr"], "public static float angle(float x, float y, float x2, float y2){\n        float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;\n        if(ang < 0) ang += 360f;\n        return ang;\n    }")
        self.assertEqual(method["godot_owner"], "PortGame.source_arc_angles_angle")
        self.assertEqual(method["runtime_proof"], "/root/Main.source_arc_angles_angle")

        atan2_expr = source_symbols.source_symbol(registry, "arc_angles_angle.atan2_expr")
        self.assertEqual(atan2_expr["java_expr"], "float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;")
        self.assertEqual(atan2_expr["godot_symbol"], "source_arc_angles_angle_result.rawAngle")

        negative_wrap = source_symbols.source_symbol(registry, "arc_angles_angle.negative_wrap")
        self.assertEqual(negative_wrap["java_expr"], "if(ang < 0) ang += 360f;")
        self.assertEqual(negative_wrap["godot_symbol"], "source_arc_angles_angle_result.negativeWrap")

    def test_arc_position_angle_to_target_symbols_are_registered_with_source_backing(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        errors = source_symbols.validate_source_symbol_registry(registry)

        self.assertEqual(errors, [])

        position_angle_to = source_symbols.source_symbol(registry, "arc_position_angle_to.other_method")
        self.assertEqual(position_angle_to["java_source"], "arc-core/src/arc/math/geom/Position.java")
        self.assertEqual(position_angle_to["java_expr"], "default float angleTo(Position other){\n        return Angles.angle(getX(), getY(), other.getX(), other.getY());\n    }")
        self.assertEqual(position_angle_to["godot_owner"], "PortGame.source_angle_to_target")
        self.assertEqual(position_angle_to["runtime_proof"], "/root/Main.source_angle_to_target")

        angles_angle = source_symbols.source_symbol(registry, "arc_position_angle_to.angles_angle")
        self.assertEqual(angles_angle["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(angles_angle["java_expr"], "public static float angle(float x, float y, float x2, float y2){\n        float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;\n        if(ang < 0) ang += 360f;\n        return ang;\n    }")
        self.assertEqual(angles_angle["godot_symbol"], "source_angle_to_target_result.targetAngle")

        origin_x = source_symbols.source_symbol(registry, "arc_position_angle_to.origin_x_input")
        self.assertEqual(origin_x["status"], "explicit-input")
        self.assertEqual(origin_x["java_expr"], "getX()")
        self.assertEqual(origin_x["godot_symbol"], "source_angle_to_target_input.originX")

        target_y = source_symbols.source_symbol(registry, "arc_position_angle_to.target_y_input")
        self.assertEqual(target_y["status"], "explicit-input")
        self.assertEqual(target_y["java_expr"], "other.getY()")
        self.assertEqual(target_y["godot_symbol"], "source_angle_to_target_input.targetY")

    def test_audit_reports_whole_godot_source_surface(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        audit = source_symbols.audit_godot_source_symbol_coverage(ROOT / "godot-mindustry", registry)

        self.assertGreater(audit["totalSourceFunctions"], 400)
        self.assertEqual(audit["registeredSourceOwnerCount"], 178)
        self.assertEqual(audit["exemptSourceOwnerCount"], 5)
        self.assertEqual(audit["legacyUnregisteredOwnerCount"], audit["totalSourceFunctions"] - 183)
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
        self.assertIn("PortGame.source_bullet_type_create_splash_damage_damage_dispatch_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_splash_damage_status_dispatch_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_splash_damage_heal_dispatch_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_splash_damage_make_fire_dispatch_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_frags_initial_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_frags_random_geometry_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_frags_create_call_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_frags_increment_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_puddles_initial_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_puddles_tile_world_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_puddles_deposit_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_incend_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_units_initial_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_units_random_offset_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_units_spawn_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_units_rotation_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_units_notify_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_init_initial_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_init_spawn_bullets_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_update_dispatch_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_update_bullet_interval_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_update_trail_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_update_homing_initial_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_update_homing_target_velocity_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_update_homing_follow_aim_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_update_weaving_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_update_weaving_rotate_speed_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_update_weaving_circle_shooter_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_update_trail_effects_chance_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_update_trail_effects_interval_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_init_type_defaults_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_init_frag_velocity_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_init_lightning_type_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_init_light_radius_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_init_draw_size_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_init_range_assignment_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_calculate_range_override_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_calculate_range_spawn_unit_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_calculate_range_despawn_unit_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_calculate_range_fallback_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_continuous_damage_default_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_heals_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_initial_gate_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_spawn_unit_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_bullet_identity_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_aim_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_velocity_position_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_lifetime_payload_damage_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_trail_add_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_create_keep_velocity_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_despawned_dispatch_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_despawned_effect_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_despawned_sound_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_despawned_shake_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_removed_trail_fade_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_removed_frag_dispatch_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_building_damage_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_shield_damage_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_draw_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_draw_trail_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_bullet_type_draw_light_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_absin", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_approach", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_approach_delta", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_angles_angle", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_angles_backward_distance", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_angles_forward_distance", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_angles_move_toward", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_angles_trns_vec", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_chance_delta_threshold", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_is_power_of_two", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_lerp_delta", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_mathf_cos_lookup", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_mathf_cos_scaled", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_mathf_mod_float", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_mathf_num", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_mathf_sin_lookup", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_mathf_sin_scaled", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_mathf_sin_table_value", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_random_seed_float_max", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_random_seed_int", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_strings_fixed_one_decimal", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_vec2_limit", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_block_can_replace_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_block_dump_time", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_block_health", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_block_health_at_cell", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_block_is_damaged", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_block_item_capacity", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_block_sprite_base_position", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_block_time_scale_at_cell", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_block_time_scale_duration_at_cell", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_absorb_lasers_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_accept_item_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_accept_liquid_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_accept_payload_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_accept_stack_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_after_destroyed_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_after_picked_up_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_ambient_volume", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_apply_boost_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_block_half_extent", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_bullet_damage_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_can_be_replaced_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_can_consume_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_can_pickup_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_change_team_delegate_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_change_team_final_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_change_team_initial_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_change_team_power_links_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_change_team_power_proximity_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_check_allow_update_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_check_solid_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_check_suppression_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_collide_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_collision_damage_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_config_default", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_configure_menu_visibility_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_configured_copy_config_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_configured_direct_handler_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_configured_last_access_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_configured_type_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_consume_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_consume_trigger_valid_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_control_config_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_control_enabled_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_cursor_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_damage_block_health_scale_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_damage_dead_guard_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_damage_delegate_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_damage_handle_damage_gate_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_damage_health_changed_call_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_delta", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_display_efficiency", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_display_flow_rate_label", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_display_icon_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_display_name_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_display_ui_gates_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_draw_cached_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_draw_configure_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_draw_cracks_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_draw_disabled_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_draw_item_selection_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_draw_light_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_building_draw_liquid_light_state", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_arc_angles_angle_dist", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_angle_distance", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_angle_to_target", audit["registeredSourceOwners"])
        self.assertIn("PortGame.source_angles_angle_dist", audit["registeredSourceOwners"])
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

        create_splash_damage_dispatch = source_symbols.source_slice(ledger, "N424")
        self.assertEqual(create_splash_damage_dispatch["java_method"], "createSplashDamage(Bullet b, float x, float y)")
        self.assertEqual(create_splash_damage_dispatch["godot_owner"], "PortGame.source_bullet_type_create_splash_damage_damage_dispatch_state")
        self.assertIn("if(splashDamageRadius > 0 && !b.absorbed)", create_splash_damage_dispatch["exact_exprs"])
        self.assertIn("Damage.damage(b.team, x, y, splashDamageRadius, splashDamage * b.damageMultiplier(), splashDamagePierce, collidesAir, collidesGround, scaledSplashDamage, b, armorMultiplier)", create_splash_damage_dispatch["exact_exprs"])
        self.assertIn("if(status != StatusEffects.none)", create_splash_damage_dispatch["deferred_exprs"])

        create_splash_damage_status = source_symbols.source_slice(ledger, "N425")
        self.assertEqual(create_splash_damage_status["java_method"], "createSplashDamage(Bullet b, float x, float y)")
        self.assertEqual(create_splash_damage_status["godot_owner"], "PortGame.source_bullet_type_create_splash_damage_status_dispatch_state")
        self.assertIn("if(status != StatusEffects.none)", create_splash_damage_status["exact_exprs"])
        self.assertIn("Damage.status(b.team, x, y, splashDamageRadius, status, statusDuration, collidesAir, collidesGround)", create_splash_damage_status["exact_exprs"])
        self.assertIn("if(heals())", create_splash_damage_status["deferred_exprs"])

        create_splash_damage_heal = source_symbols.source_slice(ledger, "N426")
        self.assertEqual(create_splash_damage_heal["java_method"], "createSplashDamage(Bullet b, float x, float y)")
        self.assertEqual(create_splash_damage_heal["godot_owner"], "PortGame.source_bullet_type_create_splash_damage_heal_dispatch_state")
        self.assertIn("if(heals())", create_splash_damage_heal["exact_exprs"])
        self.assertIn("indexer.eachBlock(b.team, x, y, splashDamageRadius, Building::damaged, other -> {...})", create_splash_damage_heal["exact_exprs"])
        self.assertIn("if(makeFire)", create_splash_damage_heal["deferred_exprs"])

        create_splash_damage_make_fire = source_symbols.source_slice(ledger, "N427")
        self.assertEqual(create_splash_damage_make_fire["java_method"], "createSplashDamage(Bullet b, float x, float y)")
        self.assertEqual(create_splash_damage_make_fire["godot_owner"], "PortGame.source_bullet_type_create_splash_damage_make_fire_dispatch_state")
        self.assertIn("if(makeFire)", create_splash_damage_make_fire["exact_exprs"])
        self.assertIn("indexer.eachBlock(null, x, y, splashDamageRadius, other -> other.team != b.team, other -> Fires.create(other.tile))", create_splash_damage_make_fire["exact_exprs"])
        self.assertIn("public void createFrags(Bullet b, float x, float y){", create_splash_damage_make_fire["deferred_exprs"])

        create_frags_initial = source_symbols.source_slice(ledger, "N428")
        self.assertEqual(create_frags_initial["java_method"], "createFrags(Bullet b, float x, float y)")
        self.assertEqual(create_frags_initial["godot_owner"], "PortGame.source_bullet_type_create_frags_initial_state")
        self.assertIn("if(fragBullet != null && (fragOnAbsorb || !b.absorbed) && (pierceFragCap < 0 || b.frags < pierceFragCap))", create_frags_initial["exact_exprs"])
        self.assertIn("for(int i = 0; i < fragBullets; i++)", create_frags_initial["exact_exprs"])
        self.assertIn("float len = Mathf.random(fragOffsetMin, fragOffsetMax)", create_frags_initial["deferred_exprs"])

        create_frags_random_geometry = source_symbols.source_slice(ledger, "N429")
        self.assertEqual(create_frags_random_geometry["java_method"], "createFrags(Bullet b, float x, float y)")
        self.assertEqual(create_frags_random_geometry["godot_owner"], "PortGame.source_bullet_type_create_frags_random_geometry_state")
        self.assertIn("float len = Mathf.random(fragOffsetMin, fragOffsetMax)", create_frags_random_geometry["exact_exprs"])
        self.assertIn("float a = b.rotation() + Mathf.range(fragRandomSpread / 2) + fragAngle + fragSpread * i - (fragBullets - 1) * fragSpread / 2f", create_frags_random_geometry["exact_exprs"])
        self.assertIn("fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax))", create_frags_random_geometry["deferred_exprs"])

        create_frags_create_call = source_symbols.source_slice(ledger, "N430")
        self.assertEqual(create_frags_create_call["java_method"], "createFrags(Bullet b, float x, float y)")
        self.assertEqual(create_frags_create_call["godot_owner"], "PortGame.source_bullet_type_create_frags_create_call_state")
        self.assertIn("fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax))", create_frags_create_call["exact_exprs"])
        self.assertIn("b.frags++", create_frags_create_call["deferred_exprs"])

        create_frags_increment = source_symbols.source_slice(ledger, "N431")
        self.assertEqual(create_frags_increment["java_method"], "createFrags(Bullet b, float x, float y)")
        self.assertEqual(create_frags_increment["godot_owner"], "PortGame.source_bullet_type_create_frags_increment_state")
        self.assertIn("b.frags++", create_frags_increment["exact_exprs"])

        create_puddles_initial = source_symbols.source_slice(ledger, "N432")
        self.assertEqual(create_puddles_initial["java_method"], "createPuddles(Bullet b, float x, float y)")
        self.assertEqual(create_puddles_initial["godot_owner"], "PortGame.source_bullet_type_create_puddles_initial_state")
        self.assertIn("if(puddleLiquid != null && puddles > 0)", create_puddles_initial["exact_exprs"])
        self.assertIn("for(int i = 0; i < puddles; i++)", create_puddles_initial["exact_exprs"])
        self.assertIn("Tile tile = world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange))", create_puddles_initial["deferred_exprs"])

        create_puddles_tile_world = source_symbols.source_slice(ledger, "N433")
        self.assertEqual(create_puddles_tile_world["java_method"], "createPuddles(Bullet b, float x, float y)")
        self.assertEqual(create_puddles_tile_world["godot_owner"], "PortGame.source_bullet_type_create_puddles_tile_world_state")
        self.assertIn("Tile tile = world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange))", create_puddles_tile_world["exact_exprs"])
        self.assertIn("Puddles.deposit(tile, puddleLiquid, puddleAmount)", create_puddles_tile_world["deferred_exprs"])

        create_puddles_deposit = source_symbols.source_slice(ledger, "N434")
        self.assertEqual(create_puddles_deposit["java_method"], "createPuddles(Bullet b, float x, float y)")
        self.assertEqual(create_puddles_deposit["godot_owner"], "PortGame.source_bullet_type_create_puddles_deposit_state")
        self.assertIn("Puddles.deposit(tile, puddleLiquid, puddleAmount)", create_puddles_deposit["exact_exprs"])

        create_incend = source_symbols.source_slice(ledger, "N435")
        self.assertEqual(create_incend["java_method"], "createIncend(Bullet b, float x, float y)")
        self.assertEqual(create_incend["godot_owner"], "PortGame.source_bullet_type_create_incend_state")
        self.assertIn("if(incendChance > 0 && Mathf.chance(incendChance))", create_incend["exact_exprs"])
        self.assertIn("Damage.createIncend(x, y, incendSpread, incendAmount)", create_incend["exact_exprs"])

        create_units_initial = source_symbols.source_slice(ledger, "N436")
        self.assertEqual(create_units_initial["java_method"], "createUnits(Bullet b, float x, float y)")
        self.assertEqual(create_units_initial["godot_owner"], "PortGame.source_bullet_type_create_units_initial_state")
        self.assertIn("if(!net.client() && despawnUnit != null && Mathf.chance(despawnUnitChance))", create_units_initial["exact_exprs"])
        self.assertIn("for(int i = 0; i < despawnUnitCount; i++)", create_units_initial["exact_exprs"])
        self.assertIn("Tmp.v1.rnd(Mathf.random(despawnUnitRadius))", create_units_initial["deferred_exprs"])

        create_units_random_offset = source_symbols.source_slice(ledger, "N437")
        self.assertEqual(create_units_random_offset["java_method"], "createUnits(Bullet b, float x, float y)")
        self.assertEqual(create_units_random_offset["godot_owner"], "PortGame.source_bullet_type_create_units_random_offset_state")
        self.assertIn("Tmp.v1.rnd(Mathf.random(despawnUnitRadius))", create_units_random_offset["exact_exprs"])
        self.assertIn("despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y)", create_units_random_offset["deferred_exprs"])

        create_units_spawn = source_symbols.source_slice(ledger, "N438")
        self.assertEqual(create_units_spawn["java_method"], "createUnits(Bullet b, float x, float y)")
        self.assertEqual(create_units_spawn["godot_owner"], "PortGame.source_bullet_type_create_units_spawn_state")
        self.assertIn("despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y)", create_units_spawn["exact_exprs"])
        self.assertIn("u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation();", create_units_spawn["deferred_exprs"])
        self.assertIn("Units.notifyUnitSpawn(u);", create_units_spawn["deferred_exprs"])

        create_units_rotation = source_symbols.source_slice(ledger, "N439")
        self.assertEqual(create_units_rotation["java_method"], "createUnits(Bullet b, float x, float y)")
        self.assertEqual(create_units_rotation["godot_owner"], "PortGame.source_bullet_type_create_units_rotation_state")
        self.assertIn("u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation()", create_units_rotation["exact_exprs"])
        self.assertIn("Units.notifyUnitSpawn(u);", create_units_rotation["deferred_exprs"])

        create_units_notify = source_symbols.source_slice(ledger, "N440")
        self.assertEqual(create_units_notify["java_method"], "createUnits(Bullet b, float x, float y)")
        self.assertEqual(create_units_notify["godot_owner"], "PortGame.source_bullet_type_create_units_notify_state")
        self.assertIn("Units.notifyUnitSpawn(u)", create_units_notify["exact_exprs"])

        despawned_dispatch = source_symbols.source_slice(ledger, "N441")
        self.assertEqual(despawned_dispatch["java_method"], "despawned(Bullet b)")
        self.assertEqual(despawned_dispatch["godot_owner"], "PortGame.source_bullet_type_despawned_dispatch_state")
        self.assertIn("if(despawnHit)", despawned_dispatch["exact_exprs"])
        self.assertIn("hit(b, b.x, b.y, false)", despawned_dispatch["exact_exprs"])
        self.assertIn("createUnits(b, b.x, b.y)", despawned_dispatch["exact_exprs"])
        self.assertIn("despawnEffect.at(b.x, b.y, b.rotation(), hitColor);", despawned_dispatch["deferred_exprs"])
        self.assertIn("despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));", despawned_dispatch["deferred_exprs"])
        self.assertIn("Effect.shake(despawnShake, despawnShake, b);", despawned_dispatch["deferred_exprs"])

        despawned_effect = source_symbols.source_slice(ledger, "N442")
        self.assertEqual(despawned_effect["java_method"], "despawned(Bullet b)")
        self.assertEqual(despawned_effect["godot_owner"], "PortGame.source_bullet_type_despawned_effect_state")
        self.assertIn("despawnEffect.at(b.x, b.y, b.rotation(), hitColor)", despawned_effect["exact_exprs"])
        self.assertIn("despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange));", despawned_effect["deferred_exprs"])
        self.assertIn("Effect.shake(despawnShake, despawnShake, b);", despawned_effect["deferred_exprs"])

        despawned_sound = source_symbols.source_slice(ledger, "N443")
        self.assertEqual(despawned_sound["java_method"], "despawned(Bullet b)")
        self.assertEqual(despawned_sound["godot_owner"], "PortGame.source_bullet_type_despawned_sound_state")
        self.assertIn("despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange))", despawned_sound["exact_exprs"])
        self.assertIn("Effect.shake(despawnShake, despawnShake, b);", despawned_sound["deferred_exprs"])

        despawned_shake = source_symbols.source_slice(ledger, "N444")
        self.assertEqual(despawned_shake["java_method"], "despawned(Bullet b)")
        self.assertEqual(despawned_shake["godot_owner"], "PortGame.source_bullet_type_despawned_shake_state")
        self.assertIn("Effect.shake(despawnShake, despawnShake, b)", despawned_shake["exact_exprs"])
        self.assertIn("public void removed(Bullet b){", despawned_shake["deferred_exprs"])

        removed_trail_fade = source_symbols.source_slice(ledger, "N445")
        self.assertEqual(removed_trail_fade["java_method"], "removed(Bullet b)")
        self.assertEqual(removed_trail_fade["godot_owner"], "PortGame.source_bullet_type_removed_trail_fade_state")
        self.assertIn("if(trailLength > 0 && b.trail != null && b.trail.size() > 0)", removed_trail_fade["exact_exprs"])
        self.assertIn("Fx.trailFade.at(b.x, b.y, trailWidth, trailColor, b.trail.copy())", removed_trail_fade["exact_exprs"])
        self.assertIn("if(b.frags == 0 && fragOnDespawn && fragBullet != null){", removed_trail_fade["deferred_exprs"])

        removed_frag_dispatch = source_symbols.source_slice(ledger, "N446")
        self.assertEqual(removed_frag_dispatch["java_method"], "removed(Bullet b)")
        self.assertEqual(removed_frag_dispatch["godot_owner"], "PortGame.source_bullet_type_removed_frag_dispatch_state")
        self.assertIn("if(b.frags == 0 && fragOnDespawn && fragBullet != null)", removed_frag_dispatch["exact_exprs"])
        self.assertIn("createFrags(b, b.x, b.y)", removed_frag_dispatch["exact_exprs"])
        self.assertIn("public float buildingDamage(Bullet b){", removed_frag_dispatch["deferred_exprs"])

        building_damage = source_symbols.source_slice(ledger, "N447")
        self.assertEqual(building_damage["java_method"], "buildingDamage(Bullet b)")
        self.assertEqual(building_damage["godot_owner"], "PortGame.source_bullet_type_building_damage_state")
        self.assertIn("return b.damage() * b.buildingDamageMultiplier", building_damage["exact_exprs"])
        self.assertIn("public float shieldDamage(Bullet b){", building_damage["deferred_exprs"])

        shield_damage = source_symbols.source_slice(ledger, "N448")
        self.assertEqual(shield_damage["java_method"], "shieldDamage(Bullet b)")
        self.assertEqual(shield_damage["godot_owner"], "PortGame.source_bullet_type_shield_damage_state")
        self.assertIn("return b.damage() * shieldDamageMultiplier", shield_damage["exact_exprs"])
        self.assertIn("public void draw(Bullet b){", shield_damage["deferred_exprs"])

        draw = source_symbols.source_slice(ledger, "N449")
        self.assertEqual(draw["java_method"], "draw(Bullet b)")
        self.assertEqual(draw["godot_owner"], "PortGame.source_bullet_type_draw_state")
        self.assertIn("drawTrail(b);", draw["exact_exprs"])
        self.assertIn("drawParts(b);", draw["exact_exprs"])
        self.assertIn("public void drawTrail(Bullet b){", draw["deferred_exprs"])

        draw_trail = source_symbols.source_slice(ledger, "N450")
        self.assertEqual(draw_trail["java_method"], "drawTrail(Bullet b)")
        self.assertEqual(draw_trail["godot_owner"], "PortGame.source_bullet_type_draw_trail_state")
        self.assertIn("if(trailLength > 0 && b.trail != null){", draw_trail["exact_exprs"])
        self.assertIn("b.trail.draw(trailColor, trailWidth)", draw_trail["exact_exprs"])
        self.assertIn("public void drawParts(Bullet b){", draw_trail["deferred_exprs"])

        draw_light = source_symbols.source_slice(ledger, "N451")
        self.assertEqual(draw_light["java_method"], "drawLight(Bullet b)")
        self.assertEqual(draw_light["godot_owner"], "PortGame.source_bullet_type_draw_light_state")
        self.assertIn("if(lightOpacity <= 0f || lightRadius <= 0f) return;", draw_light["exact_exprs"])
        self.assertIn("Drawf.light(b, lightRadius, lightColor, lightOpacity);", draw_light["exact_exprs"])
        self.assertIn("public void init(Bullet b){", draw_light["deferred_exprs"])

        init_initial = source_symbols.source_slice(ledger, "N452")
        self.assertEqual(init_initial["java_method"], "init(Bullet b)")
        self.assertEqual(init_initial["godot_owner"], "PortGame.source_bullet_type_init_initial_state")
        self.assertIn("if(killShooter && b.owner() instanceof Healthc h && !h.dead()){", init_initial["exact_exprs"])
        self.assertIn("h.kill();", init_initial["exact_exprs"])
        self.assertIn("b.time = lifetime + 1f;", init_initial["exact_exprs"])
        self.assertIn("if(spawnBullets.size > 0){", init_initial["deferred_exprs"])

        init_spawn = source_symbols.source_slice(ledger, "N453")
        self.assertEqual(init_spawn["java_method"], "init(Bullet b)")
        self.assertEqual(init_spawn["godot_owner"], "PortGame.source_bullet_type_init_spawn_bullets_state")
        self.assertIn("if(spawnBullets.size > 0){", init_spawn["exact_exprs"])
        self.assertIn("for(var bullet : spawnBullets){", init_spawn["exact_exprs"])
        self.assertIn("bullet.create(b, b.x, b.y, b.rotation() + Mathf.range(spawnBulletRandomSpread));", init_spawn["exact_exprs"])
        self.assertIn("public void update(Bullet b){", init_spawn["deferred_exprs"])

        update_dispatch = source_symbols.source_slice(ledger, "N454")
        self.assertEqual(update_dispatch["java_method"], "update(Bullet b)")
        self.assertEqual(update_dispatch["godot_owner"], "PortGame.source_bullet_type_update_dispatch_state")
        self.assertEqual(update_dispatch["exact_exprs"], [
            "updateTrail(b);",
            "updateHoming(b);",
            "updateWeaving(b);",
            "updateTrailEffects(b);",
            "updateBulletInterval(b);",
        ])
        self.assertIn("public void updateBulletInterval(Bullet b){", update_dispatch["deferred_exprs"])

        update_interval = source_symbols.source_slice(ledger, "N455")
        self.assertEqual(update_interval["java_method"], "updateBulletInterval(Bullet b)")
        self.assertEqual(update_interval["godot_owner"], "PortGame.source_bullet_type_update_bullet_interval_state")
        self.assertIn("if(intervalBullet != null && b.time >= intervalDelay && b.timer.get(2, bulletInterval)){", update_interval["exact_exprs"])
        self.assertIn("float ang = b.rotation();", update_interval["exact_exprs"])
        self.assertIn("for(int i = 0; i < intervalBullets; i++){", update_interval["exact_exprs"])
        self.assertIn("intervalBullet.create(b, b.x, b.y, ang + Mathf.range(intervalRandomSpread) + intervalAngle + ((i - (intervalBullets - 1f)/2f) * intervalSpread));", update_interval["exact_exprs"])
        self.assertIn("b.timer.get(2, bulletInterval)", update_interval["exact_exprs"])
        self.assertIn("public void updateHoming(Bullet b){", update_interval["deferred_exprs"])

        update_trail = source_symbols.source_slice(ledger, "N456")
        self.assertEqual(update_trail["java_method"], "updateTrail(Bullet b)")
        self.assertEqual(update_trail["godot_owner"], "PortGame.source_bullet_type_update_trail_state")
        self.assertIn("if(!headless && trailLength > 0){", update_trail["exact_exprs"])
        self.assertIn("if(b.trail == null){", update_trail["exact_exprs"])
        self.assertIn("b.trail = new Trail(trailLength);", update_trail["exact_exprs"])
        self.assertIn("b.trail.length = trailLength;", update_trail["exact_exprs"])
        self.assertIn("b.trail.update(b.x, b.y, trailInterp.apply(b.fin()) * (1f + (trailSinMag > 0 ? Mathf.absin(Time.time, trailSinScl, trailSinMag) : 0f)));", update_trail["exact_exprs"])
        self.assertIn("public void init(){", update_trail["deferred_exprs"])

        homing_initial = source_symbols.source_slice(ledger, "N457")
        self.assertEqual(homing_initial["java_method"], "updateHoming(Bullet b)")
        self.assertEqual(homing_initial["godot_owner"], "PortGame.source_bullet_type_update_homing_initial_state")
        self.assertIn("if(homingPower > 0.0001f && b.time >= homingDelay){", homing_initial["exact_exprs"])
        self.assertIn("float realAimX = b.aimX < 0 ? b.x : b.aimX;", homing_initial["exact_exprs"])
        self.assertIn("float realAimY = b.aimY < 0 ? b.y : b.aimY;", homing_initial["exact_exprs"])
        self.assertIn("Teamc target;", homing_initial["deferred_exprs"])
        self.assertIn("if(followAimSpeed > 0f && b.shooter instanceof Unit u){", homing_initial["deferred_exprs"])

        homing_target_velocity = source_symbols.source_slice(ledger, "N458")
        self.assertEqual(homing_target_velocity["java_method"], "updateHoming(Bullet b)")
        self.assertEqual(homing_target_velocity["godot_owner"], "PortGame.source_bullet_type_update_homing_target_velocity_state")
        self.assertIn("if(target != null){", homing_target_velocity["exact_exprs"])
        self.assertIn("b.vel.setAngle(Angles.moveToward(b.rotation(), b.angleTo(target), homingPower * Time.delta * 50f));", homing_target_velocity["exact_exprs"])
        self.assertIn("if(followAimSpeed > 0f && b.shooter instanceof Unit u){", homing_target_velocity["deferred_exprs"])

        homing_follow_aim = source_symbols.source_slice(ledger, "N459")
        self.assertEqual(homing_follow_aim["java_method"], "updateHoming(Bullet b)")
        self.assertEqual(homing_follow_aim["godot_owner"], "PortGame.source_bullet_type_update_homing_follow_aim_state")
        self.assertIn("if(followAimSpeed > 0f && b.shooter instanceof Unit u){", homing_follow_aim["exact_exprs"])
        self.assertIn("float angle = b.angleTo(u.aimX, u.aimY);", homing_follow_aim["exact_exprs"])
        self.assertIn("b.vel.setAngle(Angles.moveToward(b.vel.angle(), angle, followAimSpeed * Time.delta));", homing_follow_aim["exact_exprs"])
        self.assertIn("public void updateWeaving(Bullet b){", homing_follow_aim["deferred_exprs"])

        update_weaving = source_symbols.source_slice(ledger, "N460")
        self.assertEqual(update_weaving["java_method"], "updateWeaving(Bullet b)")
        self.assertEqual(update_weaving["godot_owner"], "PortGame.source_bullet_type_update_weaving_state")
        self.assertIn("if(weaveMag != 0){", update_weaving["exact_exprs"])
        self.assertIn("b.vel.rotateRadExact((float)Math.sin((b.time + Math.PI * weaveScale/2f) / weaveScale) * weaveMag * (weaveRandom ? (Mathf.randomSeed(b.id, 0, 1) == 1 ? -1 : 1) : 1f) * Time.delta * Mathf.degRad);", update_weaving["exact_exprs"])
        self.assertIn("if(rotateSpeed != 0){", update_weaving["deferred_exprs"])

        update_weaving_rotate_speed = source_symbols.source_slice(ledger, "N461")
        self.assertEqual(update_weaving_rotate_speed["java_method"], "updateWeaving(Bullet b)")
        self.assertEqual(update_weaving_rotate_speed["godot_owner"], "PortGame.source_bullet_type_update_weaving_rotate_speed_state")
        self.assertIn("if(rotateSpeed != 0){", update_weaving_rotate_speed["exact_exprs"])
        self.assertIn("b.vel.rotate(rotateSpeed * Time.delta);", update_weaving_rotate_speed["exact_exprs"])
        self.assertIn("if(circleShooter && b.owner instanceof Healthc h && h.isValid()){", update_weaving_rotate_speed["deferred_exprs"])

        update_weaving_circle_shooter = source_symbols.source_slice(ledger, "N462")
        self.assertEqual(update_weaving_circle_shooter["java_method"], "updateWeaving(Bullet b)")
        self.assertEqual(update_weaving_circle_shooter["godot_owner"], "PortGame.source_bullet_type_update_weaving_circle_shooter_state")
        self.assertIn("if(circleShooter && b.owner instanceof Healthc h && h.isValid()){", update_weaving_circle_shooter["exact_exprs"])
        self.assertIn("Tmp.v1.set(h).sub(b);", update_weaving_circle_shooter["exact_exprs"])
        self.assertIn("Tmp.v1.rotate(90f * Mathf.lerp(0f, 1f, 1f - Mathf.clamp((Tmp.v1.len() - circleShooterRadius) / circleShooterRadiusSmooth)));", update_weaving_circle_shooter["exact_exprs"])
        self.assertIn("b.vel.add(Tmp.v1.limit(speed * circleShooterRotateSpeed * Time.delta)).limit(speed);", update_weaving_circle_shooter["exact_exprs"])
        self.assertIn("public void updateTrailEffects(Bullet b){", update_weaving_circle_shooter["deferred_exprs"])

        update_trail_effects_chance = source_symbols.source_slice(ledger, "N463")
        self.assertEqual(update_trail_effects_chance["java_method"], "updateTrailEffects(Bullet b)")
        self.assertEqual(update_trail_effects_chance["godot_owner"], "PortGame.source_bullet_type_update_trail_effects_chance_state")
        self.assertIn("boolean canSpawn = trailMinVelocity <= 0f || b.vel.len2() >= trailMinVelocity * trailMinVelocity;", update_trail_effects_chance["exact_exprs"])
        self.assertIn("if(trailChance > 0 && canSpawn){", update_trail_effects_chance["exact_exprs"])
        self.assertIn("if(Mathf.chanceDelta(trailChance)){", update_trail_effects_chance["exact_exprs"])
        self.assertIn("trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor);", update_trail_effects_chance["exact_exprs"])
        self.assertIn("if(trailInterval > 0f && canSpawn){", update_trail_effects_chance["deferred_exprs"])

        update_trail_effects_interval = source_symbols.source_slice(ledger, "N464")
        self.assertEqual(update_trail_effects_interval["java_method"], "updateTrailEffects(Bullet b)")
        self.assertEqual(update_trail_effects_interval["godot_owner"], "PortGame.source_bullet_type_update_trail_effects_interval_state")
        self.assertIn("if(trailInterval > 0f && canSpawn){", update_trail_effects_interval["exact_exprs"])
        self.assertIn("if(b.timer(0, trailInterval)){", update_trail_effects_interval["exact_exprs"])
        self.assertIn("Tmp.v1.rnd(Mathf.random(trailSpread));", update_trail_effects_interval["exact_exprs"])
        self.assertIn("Tmp.v1.setZero();", update_trail_effects_interval["exact_exprs"])
        self.assertIn("trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor);", update_trail_effects_interval["exact_exprs"])
        self.assertIn("public void init(){", update_trail_effects_interval["deferred_exprs"])

        init_type_defaults = source_symbols.source_slice(ledger, "N465")
        self.assertEqual(init_type_defaults["java_method"], "init()")
        self.assertEqual(init_type_defaults["godot_owner"], "PortGame.source_bullet_type_init_type_defaults_state")
        self.assertIn("if(pierceCap >= 1){", init_type_defaults["exact_exprs"])
        self.assertIn("pierce = true;", init_type_defaults["exact_exprs"])
        self.assertIn("if(setDefaults){", init_type_defaults["exact_exprs"])
        self.assertIn("if(lightning > 0){", init_type_defaults["exact_exprs"])
        self.assertIn("if(status == StatusEffects.none){", init_type_defaults["exact_exprs"])
        self.assertIn("status = StatusEffects.shocked;", init_type_defaults["exact_exprs"])
        self.assertIn("if(fragBullet != null || splashDamageRadius > 0 || lightning > 0){", init_type_defaults["exact_exprs"])
        self.assertIn("despawnHit = true;", init_type_defaults["exact_exprs"])
        self.assertIn("if(fragBullet != null){", init_type_defaults["deferred_exprs"])

        init_frag_velocity = source_symbols.source_slice(ledger, "N466")
        self.assertEqual(init_frag_velocity["java_method"], "init()")
        self.assertEqual(init_frag_velocity["godot_owner"], "PortGame.source_bullet_type_init_frag_velocity_state")
        self.assertIn("if(fragBullet != null){", init_frag_velocity["exact_exprs"])
        self.assertIn("fragBullet.keepVelocity = false;", init_frag_velocity["exact_exprs"])
        self.assertIn("fragBullet.scaleKeepVelocity = false;", init_frag_velocity["exact_exprs"])
        self.assertIn("if(lightningType == null){", init_frag_velocity["deferred_exprs"])

        init_lightning_type = source_symbols.source_slice(ledger, "N467")
        self.assertEqual(init_lightning_type["java_method"], "init()")
        self.assertEqual(init_lightning_type["godot_owner"], "PortGame.source_bullet_type_init_lightning_type_state")
        self.assertIn("if(lightningType == null){", init_lightning_type["exact_exprs"])
        self.assertIn("lightningType =", init_lightning_type["exact_exprs"])
        self.assertIn("!collidesAir ? Bullets.damageLightningGround :", init_lightning_type["exact_exprs"])
        self.assertIn("!collidesGround ? Bullets.damageLightningAir :", init_lightning_type["exact_exprs"])
        self.assertIn("Bullets.damageLightning;", init_lightning_type["exact_exprs"])
        self.assertNotIn("if(lightRadius <= -1){", init_lightning_type["deferred_exprs"])

        init_light_radius = source_symbols.source_slice(ledger, "N468")
        self.assertEqual(init_light_radius["java_method"], "init()")
        self.assertEqual(init_light_radius["godot_owner"], "PortGame.source_bullet_type_init_light_radius_state")
        self.assertIn("if(lightRadius <= -1){", init_light_radius["exact_exprs"])
        self.assertIn("lightRadius = Math.max(18, hitSize * 5f);", init_light_radius["exact_exprs"])
        self.assertIn("public float hitSize = 4;", init_light_radius["exact_exprs"])
        self.assertIn("public float lightRadius = -1f;", init_light_radius["exact_exprs"])
        self.assertNotIn("drawSize = Math.max(drawSize, trailLength * speed * 2f);", init_light_radius["deferred_exprs"])

        init_draw_size = source_symbols.source_slice(ledger, "N469")
        self.assertEqual(init_draw_size["java_method"], "init()")
        self.assertEqual(init_draw_size["godot_owner"], "PortGame.source_bullet_type_init_draw_size_state")
        self.assertIn("drawSize = Math.max(drawSize, trailLength * speed * 2f);", init_draw_size["exact_exprs"])
        self.assertIn("public float speed = 1f;", init_draw_size["exact_exprs"])
        self.assertIn("public float drawSize = 40f;", init_draw_size["exact_exprs"])
        self.assertIn("public int trailLength = -1;", init_draw_size["exact_exprs"])
        self.assertIn("range = calculateRange();", init_light_radius["deferred_exprs"])
        self.assertNotIn("range = calculateRange();", init_draw_size["deferred_exprs"])

        init_range_assignment = source_symbols.source_slice(ledger, "N470")
        self.assertEqual(init_range_assignment["java_method"], "init()")
        self.assertEqual(init_range_assignment["godot_owner"], "PortGame.source_bullet_type_init_range_assignment_state")
        self.assertIn("public float range = 0f;", init_range_assignment["exact_exprs"])
        self.assertIn("drawSize = Math.max(drawSize, trailLength * speed * 2f);", init_range_assignment["exact_exprs"])
        self.assertIn("range = calculateRange();", init_range_assignment["exact_exprs"])
        self.assertNotIn("protected float calculateRange(){", init_range_assignment["deferred_exprs"])

        calculate_range_override = source_symbols.source_slice(ledger, "N471")
        self.assertEqual(calculate_range_override["java_method"], "calculateRange()")
        self.assertEqual(calculate_range_override["godot_owner"], "PortGame.source_bullet_type_calculate_range_override_state")
        self.assertIn("public float rangeOverride = -1f;", calculate_range_override["exact_exprs"])
        self.assertIn("protected float calculateRange(){", calculate_range_override["exact_exprs"])
        self.assertIn("if(rangeOverride > 0) return rangeOverride;", calculate_range_override["exact_exprs"])
        self.assertNotIn("if(spawnUnit != null) return spawnUnit.lifetime * spawnUnit.speed;", calculate_range_override["deferred_exprs"])

        calculate_range_spawn_unit = source_symbols.source_slice(ledger, "N472")
        self.assertEqual(calculate_range_spawn_unit["java_method"], "calculateRange()")
        self.assertEqual(calculate_range_spawn_unit["godot_owner"], "PortGame.source_bullet_type_calculate_range_spawn_unit_state")
        self.assertIn("public @Nullable UnitType spawnUnit;", calculate_range_spawn_unit["exact_exprs"])
        self.assertIn("if(rangeOverride > 0) return rangeOverride;", calculate_range_spawn_unit["exact_exprs"])
        self.assertIn("if(spawnUnit != null) return spawnUnit.lifetime * spawnUnit.speed;", calculate_range_spawn_unit["exact_exprs"])
        self.assertNotIn("if(despawnUnit != null) return despawnUnit.lifetime * despawnUnit.speed;", calculate_range_spawn_unit["deferred_exprs"])

        calculate_range_despawn_unit = source_symbols.source_slice(ledger, "N473")
        self.assertEqual(calculate_range_despawn_unit["java_method"], "calculateRange()")
        self.assertEqual(calculate_range_despawn_unit["godot_owner"], "PortGame.source_bullet_type_calculate_range_despawn_unit_state")
        self.assertIn("public @Nullable UnitType despawnUnit;", calculate_range_despawn_unit["exact_exprs"])
        self.assertIn("if(spawnUnit != null) return spawnUnit.lifetime * spawnUnit.speed;", calculate_range_despawn_unit["exact_exprs"])
        self.assertIn("if(despawnUnit != null) return despawnUnit.lifetime * despawnUnit.speed;", calculate_range_despawn_unit["exact_exprs"])
        self.assertNotIn("return Math.max(Mathf.zero(drag) ? speed * lifetime : speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag, maxRange);", calculate_range_despawn_unit["deferred_exprs"])

        calculate_range_fallback = source_symbols.source_slice(ledger, "N474")
        self.assertEqual(calculate_range_fallback["java_method"], "calculateRange()")
        self.assertEqual(calculate_range_fallback["godot_owner"], "PortGame.source_bullet_type_calculate_range_fallback_state")
        self.assertIn("public float speed = 1f;", calculate_range_fallback["exact_exprs"])
        self.assertIn("public float lifetime = 40f;", calculate_range_fallback["exact_exprs"])
        self.assertIn("public float drag = 0f;", calculate_range_fallback["exact_exprs"])
        self.assertIn("public float maxRange = -1f;", calculate_range_fallback["exact_exprs"])
        self.assertIn("if(despawnUnit != null) return despawnUnit.lifetime * despawnUnit.speed;", calculate_range_fallback["exact_exprs"])
        self.assertIn("return Math.max(Mathf.zero(drag) ? speed * lifetime : speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag, maxRange);", calculate_range_fallback["exact_exprs"])
        self.assertEqual(calculate_range_fallback["deferred_exprs"], [])

        continuous_damage_default = source_symbols.source_slice(ledger, "N475")
        self.assertEqual(continuous_damage_default["java_method"], "continuousDamage()")
        self.assertEqual(continuous_damage_default["godot_owner"], "PortGame.source_bullet_type_continuous_damage_default_state")
        self.assertIn("/** @return continuous damage in damage/sec, or -1 if not continuous. */", continuous_damage_default["exact_exprs"])
        self.assertIn("public float continuousDamage(){", continuous_damage_default["exact_exprs"])
        self.assertIn("return -1f;", continuous_damage_default["exact_exprs"])
        self.assertIn("public boolean heals(){", continuous_damage_default["exact_exprs"])
        self.assertEqual(continuous_damage_default["deferred_exprs"], [])

        heals = source_symbols.source_slice(ledger, "N476")
        self.assertEqual(heals["java_method"], "heals()")
        self.assertEqual(heals["godot_owner"], "PortGame.source_bullet_type_heals_state")
        self.assertIn("public float healPercent = 0f;", heals["exact_exprs"])
        self.assertIn("public float healAmount = 0f;", heals["exact_exprs"])
        self.assertIn("public boolean heals(){", heals["exact_exprs"])
        self.assertIn("return healPercent > 0 || healAmount > 0;", heals["exact_exprs"])
        self.assertIn("public boolean testCollision(Bullet bullet, Building tile){", heals["exact_exprs"])
        self.assertEqual(heals["deferred_exprs"], [])

        create_initial_gate = source_symbols.source_slice(ledger, "N477")
        self.assertEqual(create_initial_gate["java_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")
        self.assertEqual(create_initial_gate["godot_owner"], "PortGame.source_bullet_type_create_initial_gate_state")
        self.assertIn("angle += angleOffset + Mathf.range(randomAngleOffset);", create_initial_gate["exact_exprs"])
        self.assertIn("if(!Mathf.chance(createChance)) return null;", create_initial_gate["exact_exprs"])
        self.assertIn("if(ignoreSpawnAngle) angle = 0;", create_initial_gate["exact_exprs"])
        self.assertIn("public float angleOffset = 0f, randomAngleOffset = 0f;", create_initial_gate["exact_exprs"])
        self.assertIn("public float createChance = 1;", create_initial_gate["exact_exprs"])
        self.assertIn("public boolean ignoreSpawnAngle = false;", create_initial_gate["exact_exprs"])
        self.assertIn("return random(-range, range);", create_initial_gate["exact_exprs"])
        self.assertIn("return d >= 1f || rand.nextFloat() < d;", create_initial_gate["exact_exprs"])
        self.assertIn("if(spawnUnit != null){", create_initial_gate["deferred_exprs"])

        create_spawn_unit = source_symbols.source_slice(ledger, "N478")
        self.assertEqual(create_spawn_unit["java_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")
        self.assertEqual(create_spawn_unit["godot_owner"], "PortGame.source_bullet_type_create_spawn_unit_state")
        self.assertIn("if(spawnUnit != null){", create_spawn_unit["exact_exprs"])
        self.assertIn("if(!net.client()){", create_spawn_unit["exact_exprs"])
        self.assertIn("Unit spawned = spawnUnit.create(team);", create_spawn_unit["exact_exprs"])
        self.assertIn("spawned.set(x, y);", create_spawn_unit["exact_exprs"])
        self.assertIn("spawned.rotation = angle;", create_spawn_unit["exact_exprs"])
        self.assertIn("if(spawnUnit.missileAccelTime <= 0f){", create_spawn_unit["exact_exprs"])
        self.assertIn("spawned.vel.trns(angle, spawnUnit.speed);", create_spawn_unit["exact_exprs"])
        self.assertIn("if(spawned.controller() instanceof MissileAI ai){", create_spawn_unit["exact_exprs"])
        self.assertIn("if(shooter instanceof Unit unit){", create_spawn_unit["exact_exprs"])
        self.assertIn("ai.shooter = unit;", create_spawn_unit["exact_exprs"])
        self.assertIn("if(shooter instanceof ControlBlock control){", create_spawn_unit["exact_exprs"])
        self.assertIn("ai.shooter = control.unit();", create_spawn_unit["exact_exprs"])
        self.assertIn("spawned.add();", create_spawn_unit["exact_exprs"])
        self.assertIn("Units.notifyUnitSpawn(spawned);", create_spawn_unit["exact_exprs"])
        self.assertIn("if(killShooter && owner instanceof Healthc h && !h.dead()) h.kill();", create_spawn_unit["exact_exprs"])
        self.assertIn("return null;", create_spawn_unit["exact_exprs"])
        self.assertIn("Bullet bullet = Bullet.create();", create_spawn_unit["deferred_exprs"])

        create_bullet_identity = source_symbols.source_slice(ledger, "N479")
        self.assertEqual(create_bullet_identity["java_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")
        self.assertEqual(create_bullet_identity["godot_owner"], "PortGame.source_bullet_type_create_bullet_identity_state")
        self.assertIn("Bullet bullet = Bullet.create();", create_bullet_identity["exact_exprs"])
        self.assertIn("bullet.type = this;", create_bullet_identity["exact_exprs"])
        self.assertIn("bullet.owner = owner;", create_bullet_identity["exact_exprs"])
        self.assertIn("bullet.shooter = (shooter == null ? owner : shooter);", create_bullet_identity["exact_exprs"])
        self.assertIn("bullet.team = team;", create_bullet_identity["exact_exprs"])
        self.assertIn("bullet.time = 0f;", create_bullet_identity["exact_exprs"])
        self.assertIn("bullet.originX = x;", create_bullet_identity["exact_exprs"])
        self.assertIn("bullet.originY = y;", create_bullet_identity["exact_exprs"])
        self.assertIn("if(!(aimX == -1f && aimY == -1f)){", create_bullet_identity["deferred_exprs"])

        create_aim = source_symbols.source_slice(ledger, "N480")
        self.assertEqual(create_aim["java_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")
        self.assertEqual(create_aim["godot_owner"], "PortGame.source_bullet_type_create_aim_state")
        self.assertIn("if(!(aimX == -1f && aimY == -1f)){", create_aim["exact_exprs"])
        self.assertIn("bullet.aimTile = target instanceof Building b ? b.tile : world.tileWorld(aimX, aimY);", create_aim["exact_exprs"])
        self.assertIn("bullet.aimX = aimX;", create_aim["exact_exprs"])
        self.assertIn("bullet.aimY = aimY;", create_aim["exact_exprs"])
        self.assertIn("transient @Nullable Tile aimTile;", create_aim["exact_exprs"])
        self.assertIn("transient float aimX, aimY;", create_aim["exact_exprs"])
        self.assertIn("transient Tile tile;", create_aim["exact_exprs"])
        self.assertIn("return tile(Math.round(x / tilesize), Math.round(y / tilesize));", create_aim["exact_exprs"])
        self.assertIn("bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f));", create_aim["deferred_exprs"])

        create_velocity_position = source_symbols.source_slice(ledger, "N481")
        self.assertEqual(create_velocity_position["java_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(create_velocity_position["java_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")
        self.assertEqual(create_velocity_position["godot_owner"], "PortGame.source_bullet_type_create_velocity_position_state")
        self.assertIn("bullet.initVel(angle, speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f));", create_velocity_position["exact_exprs"])
        self.assertIn("bullet.set(x, y);", create_velocity_position["exact_exprs"])
        self.assertIn("bullet.lastX = x;", create_velocity_position["exact_exprs"])
        self.assertIn("bullet.lastY = y;", create_velocity_position["exact_exprs"])
        self.assertIn("public void initVel(float angle, float amount){\n        vel.trns(angle, amount);\n        rotation = angle;\n    }", create_velocity_position["exact_exprs"])
        self.assertIn("@Import float x, y, damage, lastX, lastY, time, lifetime;", create_velocity_position["exact_exprs"])
        self.assertIn("bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f);", create_velocity_position["deferred_exprs"])

        create_lifetime_payload_damage = source_symbols.source_slice(ledger, "N482")
        self.assertEqual(create_lifetime_payload_damage["java_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(create_lifetime_payload_damage["java_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")
        self.assertEqual(create_lifetime_payload_damage["godot_owner"], "PortGame.source_bullet_type_create_lifetime_payload_damage_state")
        self.assertIn("bullet.lifetime = lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f);", create_lifetime_payload_damage["exact_exprs"])
        self.assertIn("bullet.data = data;", create_lifetime_payload_damage["exact_exprs"])
        self.assertIn("bullet.hitSize = hitSize;", create_lifetime_payload_damage["exact_exprs"])
        self.assertIn("bullet.mover = mover;", create_lifetime_payload_damage["exact_exprs"])
        self.assertIn("bullet.damage = (damage < 0 ? this.damage : damage) * bullet.damageMultiplier();", create_lifetime_payload_damage["exact_exprs"])
        self.assertIn("bullet.buildingDamageMultiplier = buildingDamageMultiplier;", create_lifetime_payload_damage["exact_exprs"])
        self.assertIn("public float damageMultiplier(){\n        return type.damageMultiplier(self());\n    }", create_lifetime_payload_damage["exact_exprs"])
        self.assertIn("if(bullet.trail != null){", create_lifetime_payload_damage["deferred_exprs"])
        self.assertIn("bullet.add();", create_lifetime_payload_damage["deferred_exprs"])

        create_trail_add = source_symbols.source_slice(ledger, "N483")
        self.assertEqual(create_trail_add["java_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(create_trail_add["java_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")
        self.assertEqual(create_trail_add["godot_owner"], "PortGame.source_bullet_type_create_trail_add_state")
        self.assertIn("if(bullet.trail != null){", create_trail_add["exact_exprs"])
        self.assertIn("bullet.trail.clear();", create_trail_add["exact_exprs"])
        self.assertIn("bullet.add();", create_trail_add["exact_exprs"])
        self.assertIn("transient @Nullable Trail trail;", create_trail_add["exact_exprs"])
        self.assertIn("public void add(){\n        type.init(self());\n    }", create_trail_add["exact_exprs"])
        self.assertIn("points.clear();", create_trail_add["exact_exprs"])
        self.assertIn("if(keepVelocity && owner instanceof Velc v){", create_trail_add["deferred_exprs"])

        create_keep_velocity = source_symbols.source_slice(ledger, "N484")
        self.assertEqual(create_keep_velocity["java_source"], "core/src/mindustry/entities/bullet/BulletType.java")
        self.assertEqual(create_keep_velocity["java_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")
        self.assertEqual(create_keep_velocity["godot_owner"], "PortGame.source_bullet_type_create_keep_velocity_state")
        self.assertIn("public boolean keepVelocity = true;", create_keep_velocity["exact_exprs"])
        self.assertIn("public boolean scaleKeepVelocity = false;", create_keep_velocity["exact_exprs"])
        self.assertIn("if(keepVelocity && owner instanceof Velc v){", create_keep_velocity["exact_exprs"])
        self.assertIn("float len = bullet.vel.len();", create_keep_velocity["exact_exprs"])
        self.assertIn("bullet.vel.add(v.vel());", create_keep_velocity["exact_exprs"])
        self.assertIn("if(scaleKeepVelocity){", create_keep_velocity["exact_exprs"])
        self.assertIn("float newLen = bullet.vel.len();", create_keep_velocity["exact_exprs"])
        self.assertIn("if(newLen > 0f) bullet.lifetime *= Math.min(1f, len / newLen);", create_keep_velocity["exact_exprs"])
        self.assertIn("return bullet;", create_keep_velocity["exact_exprs"])
        self.assertIn("@SyncLocal Vec2 vel = new Vec2();", create_keep_velocity["exact_exprs"])
        self.assertIn("public float len(){\n        return (float)Math.sqrt(x * x + y * y);\n    }", create_keep_velocity["exact_exprs"])
        self.assertIn("public Vec2 add(Vec2 v){\n        x += v.x;\n        y += v.y;\n        return this;\n    }", create_keep_velocity["exact_exprs"])

        arc_mathf_absin = source_symbols.source_slice(ledger, "N485")
        self.assertEqual(arc_mathf_absin["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_mathf_absin["java_method"], "absin(float in, float scl, float mag)")
        self.assertEqual(arc_mathf_absin["godot_owner"], "PortGame.source_absin")
        self.assertIn("public static float absin(float scl, float mag){\n        return absin(Time.time, scl, mag);\n    }", arc_mathf_absin["exact_exprs"])
        self.assertIn("public static float absin(float in, float scl, float mag){\n        return (sin(in, scl * 2f, mag) + mag) / 2f;\n    }", arc_mathf_absin["exact_exprs"])
        self.assertIn("public static float sin(float radians, float scl, float mag){\n        return sin(radians / scl) * mag;\n    }", arc_mathf_absin["exact_exprs"])

        arc_angle_distance = source_symbols.source_slice(ledger, "N486")
        self.assertEqual(arc_angle_distance["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(arc_angle_distance["java_method"], "angleDist(float a, float b)")
        self.assertEqual(arc_angle_distance["godot_owner"], "PortGame.source_angle_distance")
        self.assertIn("public static float angleDist(float a, float b){\n        a = Mathf.mod(a, 360f);\n        b = Mathf.mod(b, 360f);\n        return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a);\n    }", arc_angle_distance["exact_exprs"])

        source_angle_to_target = source_symbols.source_slice(ledger, "N487")
        self.assertEqual(source_angle_to_target["java_source"], "arc-core/src/arc/math/geom/Position.java")
        self.assertEqual(source_angle_to_target["java_method"], "angleTo(Position other)")
        self.assertEqual(source_angle_to_target["godot_owner"], "PortGame.source_angle_to_target")
        self.assertIn("default float angleTo(Position other){\n        return Angles.angle(getX(), getY(), other.getX(), other.getY());\n    }", source_angle_to_target["exact_exprs"])
        self.assertIn("public static float angle(float x, float y, float x2, float y2){\n        float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;\n        if(ang < 0) ang += 360f;\n        return ang;\n    }", source_angle_to_target["exact_exprs"])

        source_angles_angle_dist = source_symbols.source_slice(ledger, "N488")
        self.assertEqual(source_angles_angle_dist["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(source_angles_angle_dist["java_method"], "angleDist(float a, float b)")
        self.assertEqual(source_angles_angle_dist["godot_owner"], "PortGame.source_angles_angle_dist")
        self.assertIn("public static float angleDist(float a, float b){\n        a = Mathf.mod(a, 360f);\n        b = Mathf.mod(b, 360f);\n        return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a);\n    }", source_angles_angle_dist["exact_exprs"])
        self.assertIn("source_arc_angles_angle_dist(a, b)", source_angles_angle_dist["exact_exprs"])

        arc_mathf_approach = source_symbols.source_slice(ledger, "N489")
        self.assertEqual(arc_mathf_approach["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_mathf_approach["java_method"], "approach(float from, float to, float speed)")
        self.assertEqual(arc_mathf_approach["godot_owner"], "PortGame.source_approach")
        self.assertIn("public static float approach(float from, float to, float speed){\n        return from + Mathf.clamp(to - from, -speed, speed);\n    }", arc_mathf_approach["exact_exprs"])
        self.assertIn("Mathf.clamp(to - from, -speed, speed)", arc_mathf_approach["exact_exprs"])

        arc_mathf_approach_delta = source_symbols.source_slice(ledger, "N490")
        self.assertEqual(arc_mathf_approach_delta["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_mathf_approach_delta["java_method"], "approachDelta(float from, float to, float speed)")
        self.assertEqual(arc_mathf_approach_delta["godot_owner"], "PortGame.source_approach_delta")
        self.assertIn("public static float approachDelta(float from, float to, float speed){\n        return approach(from, to, Time.delta * speed);\n    }", arc_mathf_approach_delta["exact_exprs"])
        self.assertIn("Time.delta * speed", arc_mathf_approach_delta["exact_exprs"])

        arc_angles_angle = source_symbols.source_slice(ledger, "N491")
        self.assertEqual(arc_angles_angle["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(arc_angles_angle["java_method"], "angle(float x, float y, float x2, float y2)")
        self.assertEqual(arc_angles_angle["godot_owner"], "PortGame.source_arc_angles_angle")
        self.assertIn("public static float angle(float x, float y, float x2, float y2){\n        float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;\n        if(ang < 0) ang += 360f;\n        return ang;\n    }", arc_angles_angle["exact_exprs"])
        self.assertIn("float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;", arc_angles_angle["exact_exprs"])

        arc_angles_angle_dist = source_symbols.source_slice(ledger, "N492")
        self.assertEqual(arc_angles_angle_dist["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(arc_angles_angle_dist["java_method"], "angleDist(float a, float b)")
        self.assertEqual(arc_angles_angle_dist["godot_owner"], "PortGame.source_arc_angles_angle_dist")
        self.assertIn("public static float angleDist(float a, float b){\n        a = Mathf.mod(a, 360f);\n        b = Mathf.mod(b, 360f);\n        return Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a);\n    }", arc_angles_angle_dist["exact_exprs"])
        self.assertIn("Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a)", arc_angles_angle_dist["exact_exprs"])

        arc_angles_backward_distance = source_symbols.source_slice(ledger, "N493")
        self.assertEqual(arc_angles_backward_distance["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(arc_angles_backward_distance["java_method"], "backwardDistance(float angle1, float angle2)")
        self.assertEqual(arc_angles_backward_distance["godot_owner"], "PortGame.source_arc_angles_backward_distance")
        self.assertIn("public static float backwardDistance(float angle1, float angle2){\n        return 360 - Math.abs(angle1 - angle2);\n    }", arc_angles_backward_distance["exact_exprs"])
        self.assertIn("return 360 - Math.abs(angle1 - angle2);", arc_angles_backward_distance["exact_exprs"])

        arc_angles_forward_distance = source_symbols.source_slice(ledger, "N494")
        self.assertEqual(arc_angles_forward_distance["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(arc_angles_forward_distance["java_method"], "forwardDistance(float angle1, float angle2)")
        self.assertEqual(arc_angles_forward_distance["godot_owner"], "PortGame.source_arc_angles_forward_distance")
        self.assertIn("public static float forwardDistance(float angle1, float angle2){\n        return Math.abs(angle1 - angle2);\n    }", arc_angles_forward_distance["exact_exprs"])
        self.assertIn("return Math.abs(angle1 - angle2);", arc_angles_forward_distance["exact_exprs"])

        arc_angles_move_toward = source_symbols.source_slice(ledger, "N495")
        self.assertEqual(arc_angles_move_toward["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(arc_angles_move_toward["java_method"], "moveToward(float angle, float to, float speed)")
        self.assertEqual(arc_angles_move_toward["godot_owner"], "PortGame.source_arc_angles_move_toward")
        self.assertIn("public static float moveToward(float angle, float to, float speed){\n        if(Math.abs(angleDist(angle, to)) < speed) return to;\n        angle = Mathf.mod(angle, 360f);\n        to = Mathf.mod(to, 360f);\n\n        if(angle > to == backwardDistance(angle, to) > forwardDistance(angle, to)){\n            angle -= speed;\n        }else{\n            angle += speed;\n        }\n\n        return angle;\n    }", arc_angles_move_toward["exact_exprs"])
        self.assertIn("angle > to == backwardDistance(angle, to) > forwardDistance(angle, to)", arc_angles_move_toward["exact_exprs"])

        arc_angles_trns_vec = source_symbols.source_slice(ledger, "N496")
        self.assertEqual(arc_angles_trns_vec["java_source"], "arc-core/src/arc/math/Angles.java")
        self.assertEqual(arc_angles_trns_vec["java_method"], "trnsx/trnsy(float angle, float x, float y)")
        self.assertEqual(arc_angles_trns_vec["godot_owner"], "PortGame.source_arc_angles_trns_vec")
        self.assertIn("public static float trnsx(float angle, float x, float y){\n        return rv.set(x, y).rotate(angle).x;\n    }", arc_angles_trns_vec["exact_exprs"])
        self.assertIn("public static float trnsy(float angle, float x, float y){\n        return rv.set(x, y).rotate(angle).y;\n    }", arc_angles_trns_vec["exact_exprs"])
        self.assertIn("float newX = this.x * cos - this.y * sin;\n        float newY = this.x * sin + this.y * cos;", arc_angles_trns_vec["exact_exprs"])

        arc_chance_delta_threshold = source_symbols.source_slice(ledger, "N497")
        self.assertEqual(arc_chance_delta_threshold["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_chance_delta_threshold["java_method"], "chanceDelta(double d)")
        self.assertEqual(arc_chance_delta_threshold["godot_owner"], "PortGame.source_arc_chance_delta_threshold")
        self.assertIn("public static boolean chanceDelta(double d){\n        return rand.nextFloat() < d * Time.delta;\n    }", arc_chance_delta_threshold["exact_exprs"])
        self.assertIn("d * Time.delta", arc_chance_delta_threshold["exact_exprs"])

        arc_is_power_of_two = source_symbols.source_slice(ledger, "N498")
        self.assertEqual(arc_is_power_of_two["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_is_power_of_two["java_method"], "isPowerOfTwo(int value)")
        self.assertEqual(arc_is_power_of_two["godot_owner"], "PortGame.source_arc_is_power_of_two")
        self.assertIn("public static boolean isPowerOfTwo(int value){\n        return value != 0 && (value & value - 1) == 0;\n    }", arc_is_power_of_two["exact_exprs"])
        self.assertIn("(value & value - 1) == 0", arc_is_power_of_two["exact_exprs"])

        arc_lerp_delta = source_symbols.source_slice(ledger, "N499")
        self.assertEqual(arc_lerp_delta["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_lerp_delta["java_method"], "lerpDelta(float fromValue, float toValue, float progress)")
        self.assertEqual(arc_lerp_delta["godot_owner"], "PortGame.source_arc_lerp_delta")
        self.assertIn("public static float lerpDelta(float fromValue, float toValue, float progress){\n        return lerp(fromValue, toValue, clamp(progress * Time.delta));\n    }", arc_lerp_delta["exact_exprs"])
        self.assertIn("public static float lerp(float fromValue, float toValue, float progress){\n        return fromValue + (toValue - fromValue) * progress;\n    }", arc_lerp_delta["exact_exprs"])

        arc_mathf_cos_lookup = source_symbols.source_slice(ledger, "N500")
        self.assertEqual(arc_mathf_cos_lookup["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_mathf_cos_lookup["java_method"], "cos(float radians)")
        self.assertEqual(arc_mathf_cos_lookup["godot_owner"], "PortGame.source_arc_mathf_cos_lookup")
        self.assertIn("public static float cos(float radians){\n        return sinTable[(int)((radians + PI / 2) * radToIndex) & sinMask];\n    }", arc_mathf_cos_lookup["exact_exprs"])
        self.assertIn("private static final int sinBits = 14;", arc_mathf_cos_lookup["exact_exprs"])
        self.assertIn("private static final float radToIndex = sinCount / radFull;", arc_mathf_cos_lookup["exact_exprs"])

        arc_mathf_sin_lookup = source_symbols.source_slice(ledger, "N504")
        self.assertEqual(arc_mathf_sin_lookup["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_mathf_sin_lookup["java_method"], "sin(float radians)")
        self.assertEqual(arc_mathf_sin_lookup["godot_owner"], "PortGame.source_arc_mathf_sin_lookup")
        self.assertIn("public static float sin(float radians){\n        return sinTable[(int)(radians * radToIndex) & sinMask];\n    }", arc_mathf_sin_lookup["exact_exprs"])
        self.assertIn("(int)(radians * radToIndex) & sinMask", arc_mathf_sin_lookup["exact_exprs"])

        arc_mathf_sin_scaled = source_symbols.source_slice(ledger, "N505")
        self.assertEqual(arc_mathf_sin_scaled["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_mathf_sin_scaled["java_method"], "sin(float radians, float scl, float mag)")
        self.assertEqual(arc_mathf_sin_scaled["godot_owner"], "PortGame.source_arc_mathf_sin_scaled")
        self.assertIn("public static float sin(float radians, float scl, float mag){\n        return sin(radians / scl) * mag;\n    }", arc_mathf_sin_scaled["exact_exprs"])
        self.assertIn("return sin(radians / scl) * mag;", arc_mathf_sin_scaled["exact_exprs"])

        arc_mathf_sin_table_value = source_symbols.source_slice(ledger, "N506")
        self.assertEqual(arc_mathf_sin_table_value["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_mathf_sin_table_value["java_method"], "static sinTable initializer")
        self.assertEqual(arc_mathf_sin_table_value["godot_owner"], "PortGame.source_arc_mathf_sin_table_value")
        self.assertIn("sinTable[i] = (float)Math.sin((i + 0.5f) / sinCount * radFull);", arc_mathf_sin_table_value["exact_exprs"])
        self.assertIn("sinTable[(int)(90 * degToIndex) & sinMask] = 1f;", arc_mathf_sin_table_value["exact_exprs"])

        arc_random_seed_float_max = source_symbols.source_slice(ledger, "N507")
        self.assertEqual(arc_random_seed_float_max["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_random_seed_float_max["java_method"], "randomSeed(long seed, float max)")
        self.assertEqual(arc_random_seed_float_max["godot_owner"], "PortGame.source_arc_random_seed_float_max")
        self.assertIn("public static float randomSeed(long seed, float max){\n        seedr.setSeed(seed * 99999);\n        return seedr.nextFloat() * max;\n    }", arc_random_seed_float_max["exact_exprs"])
        self.assertIn("seedr.setSeed(seed * 99999);", arc_random_seed_float_max["exact_exprs"])
        self.assertIn("return seedr.nextFloat() * max;", arc_random_seed_float_max["exact_exprs"])

        arc_random_seed_int = source_symbols.source_slice(ledger, "N508")
        self.assertEqual(arc_random_seed_int["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_random_seed_int["java_method"], "randomSeed(long seed, int min, int max)")
        self.assertEqual(arc_random_seed_int["godot_owner"], "PortGame.source_arc_random_seed_int")
        self.assertIn("public static int randomSeed(long seed, int min, int max){\n        seedr.setSeed(seed);\n        if(isPowerOfTwo(max)){\n            seedr.nextInt();\n        }\n        return seedr.nextInt(max - min + 1) + min;\n    }", arc_random_seed_int["exact_exprs"])
        self.assertIn("if(isPowerOfTwo(max))", arc_random_seed_int["exact_exprs"])
        self.assertIn("return seedr.nextInt(max - min + 1) + min;", arc_random_seed_int["exact_exprs"])

        arc_strings_fixed_one_decimal = source_symbols.source_slice(ledger, "N509")
        self.assertEqual(arc_strings_fixed_one_decimal["java_source"], "arc-core/src/arc/util/Strings.java")
        self.assertEqual(arc_strings_fixed_one_decimal["java_method"], "fixed(float d, int decimalPlaces)")
        self.assertEqual(arc_strings_fixed_one_decimal["godot_owner"], "PortGame.source_arc_strings_fixed_one_decimal")
        self.assertIn("public static String fixed(float d, int decimalPlaces){\n        return fixedBuilder(d, decimalPlaces).toString();\n    }", arc_strings_fixed_one_decimal["exact_exprs"])
        self.assertIn("dec.append((int)(float)(d * Math.pow(10, decimalPlaces) + 0.0001f));", arc_strings_fixed_one_decimal["exact_exprs"])
        self.assertIn("result.append(\".\");", arc_strings_fixed_one_decimal["exact_exprs"])

        arc_vec2_limit = source_symbols.source_slice(ledger, "N510")
        self.assertEqual(arc_vec2_limit["java_source"], "arc-core/src/arc/math/geom/Vec2.java")
        self.assertEqual(arc_vec2_limit["java_method"], "limit(float limit)")
        self.assertEqual(arc_vec2_limit["godot_owner"], "PortGame.source_arc_vec2_limit")
        self.assertIn("public Vec2 limit(float limit){\n        return limit2(limit * limit);\n    }", arc_vec2_limit["exact_exprs"])
        self.assertIn("public Vec2 limit2(float limit2){\n        float len2 = len2();\n        if(len2 > limit2){\n            return scl((float)Math.sqrt(limit2 / len2));\n        }\n        return this;\n    }", arc_vec2_limit["exact_exprs"])
        self.assertIn("public float len2(){\n        return x * x + y * y;\n    }", arc_vec2_limit["exact_exprs"])

        block_can_replace = source_symbols.source_slice(ledger, "N511")
        self.assertEqual(block_can_replace["java_source"], "core/src/mindustry/world/Block.java")
        self.assertEqual(block_can_replace["java_method"], "canReplace(Block other)")
        self.assertEqual(block_can_replace["godot_owner"], "PortGame.source_block_can_replace_state")
        self.assertIn("if(other.alwaysReplace) return true;", block_can_replace["exact_exprs"])
        self.assertIn("if(other.privileged) return false;", block_can_replace["exact_exprs"])
        self.assertIn("return other.replaceable && (other != this || (rotate && quickRotate)) && ((this.group != BlockGroup.none && other.group == this.group) || other == this) &&\n            (size == other.size || (size >= other.size && ((subclass != null && subclass == other.subclass) || group.anyReplace)));", block_can_replace["exact_exprs"])

        block_dump_time = source_symbols.source_slice(ledger, "N512")
        self.assertEqual(block_dump_time["java_source"], "core/src/mindustry/world/Block.java")
        self.assertEqual(block_dump_time["java_method"], "field declaration")
        self.assertEqual(block_dump_time["godot_owner"], "PortGame.source_block_dump_time")
        self.assertIn("public int dumpTime = 5;", block_dump_time["exact_exprs"])
        self.assertIn("5", block_dump_time["exact_exprs"])

        block_health = source_symbols.source_slice(ledger, "N513")
        self.assertEqual(block_health["java_source"], "core/src/mindustry/world/Block.java")
        self.assertEqual(block_health["java_method"], "init()")
        self.assertEqual(block_health["godot_owner"], "PortGame.source_block_health")
        self.assertIn("public int health = -1;", block_health["exact_exprs"])
        self.assertIn("public float scaledHealth = -1;", block_health["exact_exprs"])
        self.assertIn("health = round ?\n                Mathf.round(size * size * scaledHealth, 5) :\n                (int)(size * size * scaledHealth);", block_health["exact_exprs"])

        block_health_at_cell = source_symbols.source_slice(ledger, "N514")
        self.assertEqual(block_health_at_cell["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(block_health_at_cell["java_method"], "create(Block block, Team team)")
        self.assertEqual(block_health_at_cell["godot_owner"], "PortGame.source_block_health_at_cell")
        self.assertIn("@Import float x, y, health, maxHealth;", block_health_at_cell["exact_exprs"])
        self.assertIn("health = block.health;", block_health_at_cell["exact_exprs"])
        self.assertIn("case health -> health;", block_health_at_cell["exact_exprs"])

        block_is_damaged = source_symbols.source_slice(ledger, "N515")
        self.assertEqual(block_is_damaged["java_source"], "core/src/mindustry/entities/comp/HealthComp.java")
        self.assertEqual(block_is_damaged["java_method"], "damaged()")
        self.assertEqual(block_is_damaged["godot_owner"], "PortGame.source_block_is_damaged")
        self.assertIn("boolean damaged(){\n        return health < maxHealth - 0.001f;\n    }", block_is_damaged["exact_exprs"])
        self.assertIn("return health < maxHealth - 0.001f;", block_is_damaged["exact_exprs"])

        block_item_capacity = source_symbols.source_slice(ledger, "N516")
        self.assertEqual(block_item_capacity["java_source"], "core/src/mindustry/world/Block.java")
        self.assertEqual(block_item_capacity["java_method"], "field declaration")
        self.assertEqual(block_item_capacity["godot_owner"], "PortGame.source_block_item_capacity")
        self.assertIn("public int itemCapacity = 10;", block_item_capacity["exact_exprs"])
        self.assertIn("case itemCapacity -> block.hasItems ? block.itemCapacity : 0;", block_item_capacity["exact_exprs"])
        self.assertIn("if(sensor == LAccess.itemCapacity) return storageCapacity;", block_item_capacity["exact_exprs"])

        block_sprite_base_position = source_symbols.source_slice(ledger, "N517")
        self.assertEqual(block_sprite_base_position["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(block_sprite_base_position["java_method"], "create(Block block, Team team)")
        self.assertEqual(block_sprite_base_position["godot_owner"], "PortGame.source_block_sprite_base_position")
        self.assertIn("set(tile.drawx(), tile.drawy());", block_sprite_base_position["exact_exprs"])
        self.assertIn("return block().offset + worldx();", block_sprite_base_position["exact_exprs"])
        self.assertIn("offset = ((size + 1) % 2) * tilesize / 2f;", block_sprite_base_position["exact_exprs"])

        block_time_scale_at_cell = source_symbols.source_slice(ledger, "N518")
        self.assertEqual(block_time_scale_at_cell["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(block_time_scale_at_cell["java_method"], "timeScale()")
        self.assertEqual(block_time_scale_at_cell["godot_owner"], "PortGame.source_block_time_scale_at_cell")
        self.assertIn("private transient float timeScale = 1f, timeScaleDuration;", block_time_scale_at_cell["exact_exprs"])
        self.assertIn("return timeScale;", block_time_scale_at_cell["exact_exprs"])
        self.assertIn("case timescale -> timeScale;", block_time_scale_at_cell["exact_exprs"])

        block_time_scale_duration_at_cell = source_symbols.source_slice(ledger, "N519")
        self.assertEqual(block_time_scale_duration_at_cell["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(block_time_scale_duration_at_cell["java_method"], "field/read/write/update/apply duration state")
        self.assertEqual(block_time_scale_duration_at_cell["godot_owner"], "PortGame.source_block_time_scale_duration_at_cell")
        self.assertIn("private transient float timeScale = 1f, timeScaleDuration;", block_time_scale_duration_at_cell["exact_exprs"])
        self.assertIn("write.f(timeScaleDuration);", block_time_scale_duration_at_cell["exact_exprs"])
        self.assertIn("timeScaleDuration = read.f();", block_time_scale_duration_at_cell["exact_exprs"])
        self.assertIn("if((timeScaleDuration -= Time.delta) <= 0f){", block_time_scale_duration_at_cell["exact_exprs"])

        building_absorb_lasers = source_symbols.source_slice(ledger, "N520")
        self.assertEqual(building_absorb_lasers["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_absorb_lasers["java_method"], "absorbLasers()")
        self.assertEqual(building_absorb_lasers["godot_owner"], "PortGame.source_building_absorb_lasers_state")
        self.assertIn("return block.absorbLasers;", building_absorb_lasers["exact_exprs"])
        self.assertIn("public boolean absorbLasers = false;", building_absorb_lasers["exact_exprs"])

        building_accept_item = source_symbols.source_slice(ledger, "N521")
        self.assertEqual(building_accept_item["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_accept_item["java_method"], "acceptItem(Building source, Item item)")
        self.assertEqual(building_accept_item["godot_owner"], "PortGame.source_building_accept_item_state")
        self.assertIn("return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);", building_accept_item["exact_exprs"])
        self.assertIn("block.consumesItem(item)", building_accept_item["exact_exprs"])
        self.assertIn("items.get(item)", building_accept_item["exact_exprs"])
        self.assertIn("getMaximumAccepted(item)", building_accept_item["exact_exprs"])

        building_accept_liquid = source_symbols.source_slice(ledger, "N522")
        self.assertEqual(building_accept_liquid["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_accept_liquid["java_method"], "acceptLiquid(Building source, Liquid liquid)")
        self.assertEqual(building_accept_liquid["godot_owner"], "PortGame.source_building_accept_liquid_state")
        self.assertIn("return block.hasLiquids && block.consumesLiquid(liquid);", building_accept_liquid["exact_exprs"])
        self.assertIn("block.hasLiquids", building_accept_liquid["exact_exprs"])
        self.assertIn("block.consumesLiquid(liquid)", building_accept_liquid["exact_exprs"])

        building_accept_payload = source_symbols.source_slice(ledger, "N523")
        self.assertEqual(building_accept_payload["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_accept_payload["java_method"], "acceptPayload(Building source, Payload payload)")
        self.assertEqual(building_accept_payload["godot_owner"], "PortGame.source_building_accept_payload_state")
        self.assertIn("return false;", building_accept_payload["exact_exprs"])

        building_accept_stack = source_symbols.source_slice(ledger, "N524")
        self.assertEqual(building_accept_stack["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_accept_stack["java_method"], "acceptStack(Item item, int amount, Teamc source)")
        self.assertEqual(building_accept_stack["godot_owner"], "PortGame.source_building_accept_stack_state")
        self.assertIn("if(acceptItem(self(), item) && block.hasItems && (source == null || source.team() == team)){", building_accept_stack["exact_exprs"])
        self.assertIn("return Math.min(getMaximumAccepted(item) - items.get(item), amount);", building_accept_stack["exact_exprs"])
        self.assertIn("return 0;", building_accept_stack["exact_exprs"])

        building_after_destroyed = source_symbols.source_slice(ledger, "N525")
        self.assertEqual(building_after_destroyed["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_after_destroyed["java_method"], "afterDestroyed()")
        self.assertEqual(building_after_destroyed["godot_owner"], "PortGame.source_building_after_destroyed_state")
        self.assertIn("if(block.destroyBullet != null){", building_after_destroyed["exact_exprs"])
        self.assertIn("block.destroyBullet.create(this, block.destroyBulletSameTeam ? team : Team.derelict, x, y, Mathf.randomSeed(id(), 360f));", building_after_destroyed["exact_exprs"])
        self.assertIn("Mathf.randomSeed(id(), 360f)", building_after_destroyed["exact_exprs"])

        building_after_picked_up = source_symbols.source_slice(ledger, "N526")
        self.assertEqual(building_after_picked_up["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_after_picked_up["java_method"], "afterPickedUp()")
        self.assertEqual(building_after_picked_up["godot_owner"], "PortGame.source_building_after_picked_up_state")
        self.assertIn("if(power != null){", building_after_picked_up["exact_exprs"])
        self.assertIn("power.graph = new PowerGraph();", building_after_picked_up["exact_exprs"])
        self.assertIn("power.links.clear();", building_after_picked_up["exact_exprs"])
        self.assertIn("if(block.consPower != null && !block.consPower.buffered){", building_after_picked_up["exact_exprs"])
        self.assertIn("power.status = 0f;", building_after_picked_up["exact_exprs"])

        building_ambient_volume = source_symbols.source_slice(ledger, "N527")
        self.assertEqual(building_ambient_volume["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_ambient_volume["java_method"], "ambientVolume()")
        self.assertEqual(building_ambient_volume["godot_owner"], "PortGame.source_building_ambient_volume")
        self.assertIn("public float ambientVolume(){", building_ambient_volume["exact_exprs"])
        self.assertIn("return efficiency;", building_ambient_volume["exact_exprs"])
        self.assertIn("efficiency", building_ambient_volume["exact_exprs"])

        building_apply_boost = source_symbols.source_slice(ledger, "N528")
        self.assertEqual(building_apply_boost["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_apply_boost["java_method"], "applyBoost(float intensity, float duration)")
        self.assertEqual(building_apply_boost["godot_owner"], "PortGame.source_building_apply_boost_state")
        self.assertIn("if(!block.canOverdrive) return;", building_apply_boost["exact_exprs"])
        self.assertIn("if(intensity >= this.timeScale - 0.001f){", building_apply_boost["exact_exprs"])
        self.assertIn("timeScaleDuration = Math.max(timeScaleDuration, duration);", building_apply_boost["exact_exprs"])
        self.assertIn("timeScale = Math.max(timeScale, intensity);", building_apply_boost["exact_exprs"])

        building_block_half_extent = source_symbols.source_slice(ledger, "N529")
        self.assertEqual(building_block_half_extent["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_block_half_extent["java_method"], "drawConfigure()")
        self.assertEqual(building_block_half_extent["godot_owner"], "PortGame.source_building_block_half_extent")
        self.assertIn("Lines.square(x, y, block.size * tilesize / 2f + 1f);", building_block_half_extent["exact_exprs"])
        self.assertIn("block.size * tilesize / 2f", building_block_half_extent["exact_exprs"])
        self.assertIn("block.size", building_block_half_extent["exact_exprs"])
        self.assertIn("tilesize", building_block_half_extent["exact_exprs"])

        building_bullet_damage = source_symbols.source_slice(ledger, "N530")
        self.assertEqual(building_bullet_damage["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_bullet_damage["java_method"], "damage(Bullet bullet, Team source, float damage)")
        self.assertEqual(building_bullet_damage["godot_owner"], "PortGame.source_building_bullet_damage_state")
        self.assertIn("damage(source, damage);", building_bullet_damage["exact_exprs"])
        self.assertIn("Events.fire(bulletDamageEvent.set(self(), bullet));", building_bullet_damage["exact_exprs"])
        self.assertIn("static final BuildDamageEvent bulletDamageEvent = new BuildDamageEvent();", building_bullet_damage["exact_exprs"])

        building_can_be_replaced = source_symbols.source_slice(ledger, "N531")
        self.assertEqual(building_can_be_replaced["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_can_be_replaced["java_method"], "canBeReplaced(Block other)")
        self.assertEqual(building_can_be_replaced["godot_owner"], "PortGame.source_building_can_be_replaced_state")
        self.assertIn("public boolean canBeReplaced(Block other){", building_can_be_replaced["exact_exprs"])
        self.assertIn("return other.canReplace(block);", building_can_be_replaced["exact_exprs"])
        self.assertIn("other.canReplace(block)", building_can_be_replaced["exact_exprs"])

        building_can_consume = source_symbols.source_slice(ledger, "N532")
        self.assertEqual(building_can_consume["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_can_consume["java_method"], "canConsume()")
        self.assertEqual(building_can_consume["godot_owner"], "PortGame.source_building_can_consume_state")
        self.assertIn("public boolean canConsume(){", building_can_consume["exact_exprs"])
        self.assertIn("return potentialEfficiency > 0;", building_can_consume["exact_exprs"])
        self.assertIn("potentialEfficiency > 0", building_can_consume["exact_exprs"])

        building_can_pickup = source_symbols.source_slice(ledger, "N533")
        self.assertEqual(building_can_pickup["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_can_pickup["java_method"], "canPickup()")
        self.assertEqual(building_can_pickup["godot_owner"], "PortGame.source_building_can_pickup_state")
        self.assertIn("public boolean canPickup(){", building_can_pickup["exact_exprs"])
        self.assertIn("return block.canPickup;", building_can_pickup["exact_exprs"])
        self.assertIn("block.canPickup", building_can_pickup["exact_exprs"])

        building_change_team_delegate = source_symbols.source_slice(ledger, "N534")
        self.assertEqual(building_change_team_delegate["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_change_team_delegate["java_method"], "changeTeam(Team next)")
        self.assertEqual(building_change_team_delegate["godot_owner"], "PortGame.source_building_change_team_delegate_state")
        self.assertIn("public void changeTeam(Team next){", building_change_team_delegate["exact_exprs"])
        self.assertIn("changeTeam(next, true);", building_change_team_delegate["exact_exprs"])
        self.assertIn("next", building_change_team_delegate["exact_exprs"])
        self.assertIn("true", building_change_team_delegate["exact_exprs"])

        building_change_team_final = source_symbols.source_slice(ledger, "N535")
        self.assertEqual(building_change_team_final["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_change_team_final["java_method"], "changeTeam(Team next, boolean updatePower)")
        self.assertEqual(building_change_team_final["godot_owner"], "PortGame.source_building_change_team_final_state")
        self.assertIn("if(was){", building_change_team_final["exact_exprs"])
        self.assertIn("indexer.addIndex(tile);", building_change_team_final["exact_exprs"])
        self.assertIn("Events.fire(teamChangeEvent.set(last, self()));", building_change_team_final["exact_exprs"])
        self.assertIn("checkAllowUpdate();", building_change_team_final["exact_exprs"])

        building_change_team_initial = source_symbols.source_slice(ledger, "N536")
        self.assertEqual(building_change_team_initial["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_change_team_initial["java_method"], "changeTeam(Team next, boolean updatePower)")
        self.assertEqual(building_change_team_initial["godot_owner"], "PortGame.source_building_change_team_initial_state")
        self.assertIn("if(this.team == next) return;", building_change_team_initial["exact_exprs"])
        self.assertIn("if(block.forceTeam != null) team = block.forceTeam;", building_change_team_initial["exact_exprs"])
        self.assertIn("Team last = this.team;", building_change_team_initial["exact_exprs"])
        self.assertIn("if(was) indexer.removeIndex(tile);", building_change_team_initial["exact_exprs"])
        self.assertIn("this.team = next;", building_change_team_initial["exact_exprs"])

        building_change_team_power_links = source_symbols.source_slice(ledger, "N537")
        self.assertEqual(building_change_team_power_links["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_change_team_power_links["java_method"], "changeTeam(Team next, boolean updatePower)")
        self.assertEqual(building_change_team_power_links["godot_owner"], "PortGame.source_building_change_team_power_links_state")
        self.assertIn("for(int i = 0; i < power.links.size; i++){", building_change_team_power_links["exact_exprs"])
        self.assertIn("power.links.removeIndex(i);", building_change_team_power_links["exact_exprs"])
        self.assertIn("new PowerGraph().reflow(self());", building_change_team_power_links["exact_exprs"])
        self.assertIn("updatePowerGraph();", building_change_team_power_links["exact_exprs"])

        building_change_team_power_proximity = source_symbols.source_slice(ledger, "N538")
        self.assertEqual(building_change_team_power_proximity["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_change_team_power_proximity["java_method"], "changeTeam(Team next, boolean updatePower)")
        self.assertEqual(building_change_team_power_proximity["godot_owner"], "PortGame.source_building_change_team_power_proximity_state")
        self.assertIn("if(power != null && updatePower){", building_change_team_power_proximity["exact_exprs"])
        self.assertIn("var oldGraph = power.graph;", building_change_team_power_proximity["exact_exprs"])
        self.assertIn("for(var other : proximity){", building_change_team_power_proximity["exact_exprs"])
        self.assertIn("new PowerGraph().reflow(other);", building_change_team_power_proximity["exact_exprs"])

        building_check_allow_update = source_symbols.source_slice(ledger, "N539")
        self.assertEqual(building_check_allow_update["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_check_allow_update["java_method"], "checkAllowUpdate()")
        self.assertEqual(building_check_allow_update["godot_owner"], "PortGame.source_building_check_allow_update_state")
        self.assertIn("public void checkAllowUpdate(){", building_check_allow_update["exact_exprs"])
        self.assertIn("if(!allowUpdate()){", building_check_allow_update["exact_exprs"])
        self.assertIn("enabled = false;", building_check_allow_update["exact_exprs"])
        self.assertIn("allowUpdate()", building_check_allow_update["exact_exprs"])
        self.assertIn("enabled", building_check_allow_update["exact_exprs"])

        building_check_solid = source_symbols.source_slice(ledger, "N540")
        self.assertEqual(building_check_solid["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_check_solid["java_method"], "checkSolid()")
        self.assertEqual(building_check_solid["godot_owner"], "PortGame.source_building_check_solid_state")
        self.assertIn("public boolean checkSolid(){", building_check_solid["exact_exprs"])
        self.assertIn("return false;", building_check_solid["exact_exprs"])

        building_check_suppression = source_symbols.source_slice(ledger, "N541")
        self.assertEqual(building_check_suppression["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_check_suppression["java_method"], "checkSuppression()")
        self.assertEqual(building_check_suppression["godot_owner"], "PortGame.source_building_check_suppression_state")
        self.assertIn("public boolean checkSuppression(){", building_check_suppression["exact_exprs"])
        self.assertIn("if(isHealSuppressed()){", building_check_suppression["exact_exprs"])
        self.assertIn("if(Mathf.chanceDelta(0.03)){", building_check_suppression["exact_exprs"])
        self.assertIn("Fx.regenSuppressParticle.at(x + Mathf.range(block.size * tilesize/2f - 1f), y + Mathf.range(block.size * tilesize/2f - 1f), suppressColor);", building_check_suppression["exact_exprs"])
        self.assertIn("return block.suppressable && Time.time <= healSuppressionTime;", building_check_suppression["exact_exprs"])
        self.assertIn("return true;", building_check_suppression["exact_exprs"])
        self.assertIn("return false;", building_check_suppression["exact_exprs"])

        building_collide = source_symbols.source_slice(ledger, "N542")
        self.assertEqual(building_collide["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_collide["java_method"], "collide(Bullet other)")
        self.assertEqual(building_collide["godot_owner"], "PortGame.source_building_collide_state")
        self.assertIn("public boolean collide(Bullet other){", building_collide["exact_exprs"])
        self.assertIn("return true;", building_collide["exact_exprs"])
        self.assertIn("other", building_collide["exact_exprs"])

        building_collision_damage = source_symbols.source_slice(ledger, "N543")
        self.assertEqual(building_collision_damage["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_collision_damage["java_method"], "collision(Bullet other)")
        self.assertEqual(building_collision_damage["godot_owner"], "PortGame.source_building_collision_damage_state")
        self.assertIn("public boolean collision(Bullet other){", building_collision_damage["exact_exprs"])
        self.assertIn("boolean wasDead = health <= 0;", building_collision_damage["exact_exprs"])
        self.assertIn("float damage = other.type.buildingDamage(other);", building_collision_damage["exact_exprs"])
        self.assertIn("damage = Damage.applyArmor(damage, block.armor * t.armorMultiplier * t.blockArmorMultiplier);", building_collision_damage["exact_exprs"])
        self.assertIn("return true;", building_collision_damage["exact_exprs"])

        building_config_default = source_symbols.source_slice(ledger, "N544")
        self.assertEqual(building_config_default["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_config_default["java_method"], "config()")
        self.assertEqual(building_config_default["godot_owner"], "PortGame.source_building_config_default")
        self.assertIn("/** Tile configuration. Defaults to null. Used for block rebuilding. */", building_config_default["exact_exprs"])
        self.assertIn("@Nullable", building_config_default["exact_exprs"])
        self.assertIn("public Object config(){", building_config_default["exact_exprs"])
        self.assertIn("return null;", building_config_default["exact_exprs"])

        building_configure_menu_visibility = source_symbols.source_slice(ledger, "N545")
        self.assertEqual(building_configure_menu_visibility["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_configure_menu_visibility["java_method"], "shouldShowConfigure(Player player) / shouldHideConfigure(Player player)")
        self.assertEqual(building_configure_menu_visibility["godot_owner"], "PortGame.source_building_configure_menu_visibility_state")
        self.assertIn("/** Returns whether this config menu should show when the specified player taps it. */", building_configure_menu_visibility["exact_exprs"])
        self.assertIn("public boolean shouldShowConfigure(Player player){", building_configure_menu_visibility["exact_exprs"])
        self.assertIn("return true;", building_configure_menu_visibility["exact_exprs"])
        self.assertIn("/** Whether this configuration should be hidden now. Called every frame the config is open. */", building_configure_menu_visibility["exact_exprs"])
        self.assertIn("public boolean shouldHideConfigure(Player player){", building_configure_menu_visibility["exact_exprs"])
        self.assertIn("return false;", building_configure_menu_visibility["exact_exprs"])

        building_configured_copy_config = source_symbols.source_slice(ledger, "N546")
        self.assertEqual(building_configured_copy_config["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_configured_copy_config["java_method"], "configured(@Nullable Unit builder, @Nullable Object value)")
        self.assertEqual(building_configured_copy_config["godot_owner"], "PortGame.source_building_configured_copy_config_state")
        self.assertIn("}else if(value instanceof Building build){", building_configured_copy_config["exact_exprs"])
        self.assertIn("//copy config of another building", building_configured_copy_config["exact_exprs"])
        self.assertIn("var conf = build.config();", building_configured_copy_config["exact_exprs"])
        self.assertIn("if(conf != null && !(conf instanceof Building)){", building_configured_copy_config["exact_exprs"])
        self.assertIn("configured(builder, conf);", building_configured_copy_config["exact_exprs"])

        building_configured_direct_handler = source_symbols.source_slice(ledger, "N547")
        self.assertEqual(building_configured_direct_handler["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_configured_direct_handler["java_method"], "configured(@Nullable Unit builder, @Nullable Object value)")
        self.assertEqual(building_configured_direct_handler["godot_owner"], "PortGame.source_building_configured_direct_handler_state")
        self.assertIn("if(block.configurations.containsKey(type)){", building_configured_direct_handler["exact_exprs"])
        self.assertIn("block.configurations.get(type).get(this, value);", building_configured_direct_handler["exact_exprs"])
        self.assertIn("}else if(value instanceof Building build){", building_configured_direct_handler["exact_exprs"])

        building_configured_last_access = source_symbols.source_slice(ledger, "N548")
        self.assertEqual(building_configured_last_access["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_configured_last_access["java_method"], "configured(@Nullable Unit builder, @Nullable Object value) / updateLastAccess(Player player)")
        self.assertEqual(building_configured_last_access["godot_owner"], "PortGame.source_building_configured_last_access_state")
        self.assertIn("if(builder != null && builder.isPlayer()){", building_configured_last_access["exact_exprs"])
        self.assertIn("updateLastAccess(builder.getPlayer());", building_configured_last_access["exact_exprs"])
        self.assertIn("public void updateLastAccess(Player player){", building_configured_last_access["exact_exprs"])
        self.assertIn("lastAccessed = player.coloredName();", building_configured_last_access["exact_exprs"])

        building_configured_type = source_symbols.source_slice(ledger, "N549")
        self.assertEqual(building_configured_type["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_configured_type["java_method"], "configured(@Nullable Unit builder, @Nullable Object value)")
        self.assertEqual(building_configured_type["godot_owner"], "PortGame.source_building_configured_type_state")
        self.assertIn("Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();", building_configured_type["exact_exprs"])
        self.assertIn("if(value instanceof Item) type = Item.class;", building_configured_type["exact_exprs"])
        self.assertIn("if(value instanceof Block) type = Block.class;", building_configured_type["exact_exprs"])
        self.assertIn("if(value instanceof Liquid) type = Liquid.class;", building_configured_type["exact_exprs"])
        self.assertIn("if(value instanceof UnitType) type = UnitType.class;", building_configured_type["exact_exprs"])

        building_consume = source_symbols.source_slice(ledger, "N550")
        self.assertEqual(building_consume["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_consume["java_method"], "consume()")
        self.assertEqual(building_consume["godot_owner"], "PortGame.source_building_consume_state")
        self.assertIn("public void consume(){", building_consume["exact_exprs"])
        self.assertIn("for(Consume cons : block.consumers){", building_consume["exact_exprs"])
        self.assertIn("cons.trigger(self());", building_consume["exact_exprs"])
        self.assertIn("block.consumers", building_consume["exact_exprs"])
        self.assertIn("self()", building_consume["exact_exprs"])

        building_consume_trigger_valid = source_symbols.source_slice(ledger, "N551")
        self.assertEqual(building_consume_trigger_valid["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_consume_trigger_valid["java_method"], "consumeTriggerValid()")
        self.assertEqual(building_consume_trigger_valid["godot_owner"], "PortGame.source_building_consume_trigger_valid_state")
        self.assertIn("/** @return whether this building is currently \"burning\" a trigger consumer (an item) - if true, valid() on those will return true. */", building_consume_trigger_valid["exact_exprs"])
        self.assertIn("public boolean consumeTriggerValid(){", building_consume_trigger_valid["exact_exprs"])
        self.assertIn("return false;", building_consume_trigger_valid["exact_exprs"])

        building_control_config = source_symbols.source_slice(ledger, "N552")
        self.assertEqual(building_control_config["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_control_config["java_method"], "control(LAccess type, Object p1, double p2, double p3, double p4)")
        self.assertEqual(building_control_config["godot_owner"], "PortGame.source_building_control_config_state")
        self.assertIn("public void control(LAccess type, Object p1, double p2, double p3, double p4){", building_control_config["exact_exprs"])
        self.assertIn("//don't execute configure instructions that copy logic building configures; this can cause extreme lag", building_control_config["exact_exprs"])
        self.assertIn("if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){", building_control_config["exact_exprs"])
        self.assertIn("//change config only if it's new", building_control_config["exact_exprs"])
        self.assertIn("configured(null, p1);", building_control_config["exact_exprs"])

        building_control_enabled = source_symbols.source_slice(ledger, "N553")
        self.assertEqual(building_control_enabled["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_control_enabled["java_method"], "control(LAccess type, double p1, double p2, double p3, double p4)")
        self.assertEqual(building_control_enabled["godot_owner"], "PortGame.source_building_control_enabled_state")
        self.assertIn("public void control(LAccess type, double p1, double p2, double p3, double p4){", building_control_enabled["exact_exprs"])
        self.assertIn("if(type == LAccess.enabled){", building_control_enabled["exact_exprs"])
        self.assertIn("enabled = !Mathf.zero((float)p1);", building_control_enabled["exact_exprs"])
        self.assertIn("enabled", building_control_enabled["exact_exprs"])
        self.assertIn("type", building_control_enabled["exact_exprs"])
        self.assertIn("p1", building_control_enabled["exact_exprs"])

        building_cursor = source_symbols.source_slice(ledger, "N554")
        self.assertEqual(building_cursor["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_cursor["java_method"], "getCursor()")
        self.assertEqual(building_cursor["godot_owner"], "PortGame.source_building_cursor_state")
        self.assertIn("/** Returns whether a hand cursor should be shown over this block. */", building_cursor["exact_exprs"])
        self.assertIn("public Cursor getCursor(){", building_cursor["exact_exprs"])
        self.assertIn("return block.configurable && interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;", building_cursor["exact_exprs"])
        self.assertIn("block.configurable", building_cursor["exact_exprs"])
        self.assertIn("interactable(player.team())", building_cursor["exact_exprs"])

        building_damage_block_health_scale = source_symbols.source_slice(ledger, "N555")
        self.assertEqual(building_damage_block_health_scale["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_damage_block_health_scale["java_method"], "damage(float damage)")
        self.assertEqual(building_damage_block_health_scale["godot_owner"], "PortGame.source_building_damage_block_health_scale_state")
        self.assertIn("float dm = state.rules.blockHealth(team);", building_damage_block_health_scale["exact_exprs"])
        self.assertIn("lastDamageTime = Time.time;", building_damage_block_health_scale["exact_exprs"])
        self.assertIn("if(Mathf.zero(dm)){", building_damage_block_health_scale["exact_exprs"])
        self.assertIn("damage = health + 1;", building_damage_block_health_scale["exact_exprs"])
        self.assertIn("damage /= dm;", building_damage_block_health_scale["exact_exprs"])

        building_damage_dead_guard = source_symbols.source_slice(ledger, "N556")
        self.assertEqual(building_damage_dead_guard["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_damage_dead_guard["java_method"], "damage(float damage)")
        self.assertEqual(building_damage_dead_guard["godot_owner"], "PortGame.source_building_damage_dead_guard_state")
        self.assertIn("if(dead()) return;", building_damage_dead_guard["exact_exprs"])
        self.assertIn("dead()", building_damage_dead_guard["exact_exprs"])

        building_damage_delegate = source_symbols.source_slice(ledger, "N557")
        self.assertEqual(building_damage_delegate["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_damage_delegate["java_method"], "damage(@Nullable Team source, float damage)")
        self.assertEqual(building_damage_delegate["godot_owner"], "PortGame.source_building_damage_delegate_state")
        self.assertIn("/** Used to handle damage from splash damage for certain types of blocks. */", building_damage_delegate["exact_exprs"])
        self.assertIn("public void damage(@Nullable Team source, float damage){", building_damage_delegate["exact_exprs"])
        self.assertIn("damage(damage);", building_damage_delegate["exact_exprs"])

        building_damage_handle_damage_gate = source_symbols.source_slice(ledger, "N558")
        self.assertEqual(building_damage_handle_damage_gate["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_damage_handle_damage_gate["java_method"], "damage(float damage)")
        self.assertEqual(building_damage_handle_damage_gate["godot_owner"], "PortGame.source_building_damage_handle_damage_gate_state")
        self.assertIn("//TODO handle this better on the client.", building_damage_handle_damage_gate["exact_exprs"])
        self.assertIn("if(!net.client()){", building_damage_handle_damage_gate["exact_exprs"])
        self.assertIn("health -= handleDamage(damage);", building_damage_handle_damage_gate["exact_exprs"])

        building_damage_health_changed_call = source_symbols.source_slice(ledger, "N559")
        self.assertEqual(building_damage_health_changed_call["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_damage_health_changed_call["java_method"], "damage(float damage)")
        self.assertEqual(building_damage_health_changed_call["godot_owner"], "PortGame.source_building_damage_health_changed_call_state")
        self.assertIn("healthChanged();", building_damage_health_changed_call["exact_exprs"])

        building_delta = source_symbols.source_slice(ledger, "N560")
        self.assertEqual(building_delta["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_delta["java_method"], "delta()")
        self.assertEqual(building_delta["godot_owner"], "PortGame.source_building_delta")
        self.assertIn("/** Scaled delta. */", building_delta["exact_exprs"])
        self.assertIn("public float delta(){", building_delta["exact_exprs"])
        self.assertIn("return Time.delta * timeScale;", building_delta["exact_exprs"])
        self.assertIn("Time.delta", building_delta["exact_exprs"])
        self.assertIn("timeScale", building_delta["exact_exprs"])

        building_display_efficiency = source_symbols.source_slice(ledger, "N561")
        self.assertEqual(building_display_efficiency["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_display_efficiency["java_method"], "getDisplayEfficiency()")
        self.assertEqual(building_display_efficiency["godot_owner"], "PortGame.source_building_display_efficiency")
        self.assertIn("public float getDisplayEfficiency(){", building_display_efficiency["exact_exprs"])
        self.assertIn("return getProgressIncrease(1f) / edelta();", building_display_efficiency["exact_exprs"])
        self.assertIn("getProgressIncrease(1f)", building_display_efficiency["exact_exprs"])
        self.assertIn("1f", building_display_efficiency["exact_exprs"])
        self.assertIn("edelta()", building_display_efficiency["exact_exprs"])

        building_display_flow_rate_label = source_symbols.source_slice(ledger, "N562")
        self.assertEqual(building_display_flow_rate_label["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_display_flow_rate_label["java_method"], "display(Table table)")
        self.assertEqual(building_display_flow_rate_label["godot_owner"], "PortGame.source_building_display_flow_rate_label")
        self.assertIn("if(displayFlow){", building_display_flow_rate_label["exact_exprs"])
        self.assertIn("String ps = \" \" + StatUnit.perSecond.localized();", building_display_flow_rate_label["exact_exprs"])
        self.assertIn("flowItems.getFlowRate(item)", building_display_flow_rate_label["exact_exprs"])
        self.assertIn("flowItems.getFlowRate(item) < 0 ? \"...\"", building_display_flow_rate_label["exact_exprs"])
        self.assertIn("Strings.fixed(flowItems.getFlowRate(item), 1) + ps", building_display_flow_rate_label["exact_exprs"])

        building_display_icon = source_symbols.source_slice(ledger, "N563")
        self.assertEqual(building_display_icon["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_display_icon["java_method"], "display(Table table)")
        self.assertEqual(building_display_icon["godot_owner"], "PortGame.source_building_display_icon_state")
        self.assertIn("public void display(Table table){", building_display_icon["exact_exprs"])
        self.assertIn("t.add(new Image(block.getDisplayIcon(tile))).scaling(Scaling.fit).size(8 * 4);", building_display_icon["exact_exprs"])
        self.assertIn("block.getDisplayIcon(tile)", building_display_icon["exact_exprs"])
        self.assertIn("Scaling.fit", building_display_icon["exact_exprs"])
        self.assertIn("8 * 4", building_display_icon["exact_exprs"])

        building_display_name = source_symbols.source_slice(ledger, "N564")
        self.assertEqual(building_display_name["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_display_name["java_method"], "getDisplayName()")
        self.assertEqual(building_display_name["godot_owner"], "PortGame.source_building_display_name_state")
        self.assertIn("public String getDisplayName(){", building_display_name["exact_exprs"])
        self.assertIn("//derelict team icon currently doesn't display", building_display_name["exact_exprs"])
        self.assertIn("block.localizedName + \"\\n\" + Core.bundle.get(\"block.derelict\")", building_display_name["exact_exprs"])
        self.assertIn("block.localizedName + (team == player.team() || team.emoji.isEmpty() ? \"\" : \" \" + team.emoji)", building_display_name["exact_exprs"])
        self.assertIn("t.labelWrap(block.getDisplayName(tile)).left().width(190f).padLeft(5);", building_display_name["exact_exprs"])

        building_display_ui_gates = source_symbols.source_slice(ledger, "N565")
        self.assertEqual(building_display_ui_gates["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_display_ui_gates["java_method"], "display(Table table)")
        self.assertEqual(building_display_ui_gates["godot_owner"], "PortGame.source_building_display_ui_gates_state")
        self.assertIn("public void display(Table table){", building_display_ui_gates["exact_exprs"])
        self.assertIn("table.table(t -> {", building_display_ui_gates["exact_exprs"])
        self.assertIn("if(team == player.team()){", building_display_ui_gates["exact_exprs"])
        self.assertIn("displayBars(bars);", building_display_ui_gates["exact_exprs"])
        self.assertIn("table.table(this::displayConsumption).growX();", building_display_ui_gates["exact_exprs"])
        self.assertIn("boolean displayFlow = (block.category == Category.distribution || block.category == Category.liquid) && block.displayFlow;", building_display_ui_gates["exact_exprs"])
        self.assertIn("if(displayFlow){", building_display_ui_gates["exact_exprs"])
        self.assertIn("if(net.active() && lastAccessed != null){", building_display_ui_gates["exact_exprs"])

        building_draw_cached = source_symbols.source_slice(ledger, "N566")
        self.assertEqual(building_draw_cached["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_draw_cached["java_method"], "drawCached()")
        self.assertEqual(building_draw_cached["godot_owner"], "PortGame.source_building_draw_cached_state")
        self.assertIn("/** Called only if {@link Block#drawCached} is true (off by default). */", building_draw_cached["exact_exprs"])
        self.assertIn("public void drawCached(){", building_draw_cached["exact_exprs"])
        self.assertIn("draw();", building_draw_cached["exact_exprs"])
        self.assertIn("Draw.rect(block.region, x, y, drawrot());", building_draw_cached["exact_exprs"])
        self.assertIn("Draw.rect(block.variantRegions[Mathf.randomSeed(tile.pos(), 0, Math.max(0, block.variantRegions.length - 1))], x, y, drawrot());", building_draw_cached["exact_exprs"])
        self.assertIn("drawTeamTop();", building_draw_cached["exact_exprs"])

        building_draw_configure = source_symbols.source_slice(ledger, "N567")
        self.assertEqual(building_draw_configure["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_draw_configure["java_method"], "drawConfigure()")
        self.assertEqual(building_draw_configure["godot_owner"], "PortGame.source_building_draw_configure_state")
        self.assertIn("public void drawConfigure(){", building_draw_configure["exact_exprs"])
        self.assertIn("Draw.color(Pal.accent);", building_draw_configure["exact_exprs"])
        self.assertIn("Lines.stroke(1f);", building_draw_configure["exact_exprs"])
        self.assertIn("Lines.square(x, y, block.size * tilesize / 2f + 1f);", building_draw_configure["exact_exprs"])
        self.assertIn("+ 1f", building_draw_configure["exact_exprs"])
        self.assertIn("Draw.reset();", building_draw_configure["exact_exprs"])

        building_draw_cracks = source_symbols.source_slice(ledger, "N568")
        self.assertEqual(building_draw_cracks["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_draw_cracks["java_method"], "drawCracks()")
        self.assertEqual(building_draw_cracks["godot_owner"], "PortGame.source_building_draw_cracks_state")
        self.assertIn("public void drawCracks(){", building_draw_cracks["exact_exprs"])
        self.assertIn("if(!block.drawCracks || !damaged() || block.size > BlockRenderer.maxCrackSize) return;", building_draw_cracks["exact_exprs"])
        self.assertIn("int id = pos();", building_draw_cracks["exact_exprs"])
        self.assertIn("Mathf.clamp((int)((1f - healthf()) * BlockRenderer.crackRegions), 0, BlockRenderer.crackRegions-1)", building_draw_cracks["exact_exprs"])
        self.assertIn("Draw.colorl(0.2f, 0.1f + (1f - healthf())* 0.6f);", building_draw_cracks["exact_exprs"])
        self.assertIn("//TODO could be random, flipped, pseudorandom, etc", building_draw_cracks["exact_exprs"])
        self.assertIn("Draw.rect(region, x, y, (id%4)*90);", building_draw_cracks["exact_exprs"])
        self.assertIn("Draw.color();", building_draw_cracks["exact_exprs"])

        building_draw_disabled = source_symbols.source_slice(ledger, "N569")
        self.assertEqual(building_draw_disabled["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_draw_disabled["java_method"], "drawDisabled()")
        self.assertEqual(building_draw_disabled["godot_owner"], "PortGame.source_building_draw_disabled_state")
        self.assertIn("public void drawDisabled(){", building_draw_disabled["exact_exprs"])
        self.assertIn("Draw.color(Color.scarlet);", building_draw_disabled["exact_exprs"])
        self.assertIn("Draw.alpha(0.8f);", building_draw_disabled["exact_exprs"])
        self.assertIn("float size = 6f;", building_draw_disabled["exact_exprs"])
        self.assertIn("Draw.rect(Icon.cancel.getRegion(), x, y, size, size);", building_draw_disabled["exact_exprs"])
        self.assertIn("Draw.reset();", building_draw_disabled["exact_exprs"])

        building_draw_item_selection = source_symbols.source_slice(ledger, "N570")
        self.assertEqual(building_draw_item_selection["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_draw_item_selection["java_method"], "drawItemSelection(@Nullable UnlockableContent selection)")
        self.assertEqual(building_draw_item_selection["godot_owner"], "PortGame.source_building_draw_item_selection_state")
        self.assertIn("public void drawItemSelection(@Nullable UnlockableContent selection){", building_draw_item_selection["exact_exprs"])
        self.assertIn("if(selection != null){", building_draw_item_selection["exact_exprs"])
        self.assertIn("float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;", building_draw_item_selection["exact_exprs"])
        self.assertIn("Draw.mixcol(Color.darkGray, 1f);", building_draw_item_selection["exact_exprs"])
        self.assertIn("Draw.rect(selection.fullIcon, dx, dy - 1, s, h);", building_draw_item_selection["exact_exprs"])
        self.assertIn("Draw.reset();", building_draw_item_selection["exact_exprs"])
        self.assertIn("Draw.rect(selection.fullIcon, dx, dy, s, h);", building_draw_item_selection["exact_exprs"])

        building_draw_light = source_symbols.source_slice(ledger, "N571")
        self.assertEqual(building_draw_light["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_draw_light["java_method"], "drawLight()")
        self.assertEqual(building_draw_light["godot_owner"], "PortGame.source_building_draw_light_state")
        self.assertIn("public void drawLight(){", building_draw_light["exact_exprs"])
        self.assertIn("Liquid liq = block.hasLiquids && block.lightLiquid == null ? liquids.current() : block.lightLiquid;", building_draw_light["exact_exprs"])
        self.assertIn("if(block.hasLiquids && block.drawLiquidLight && liq.lightColor.a > 0.001f){", building_draw_light["exact_exprs"])
        self.assertIn("//yes, I am updating in draw()... but this is purely visual anyway, better have it here than in update() where it wastes time", building_draw_light["exact_exprs"])
        self.assertIn("visualLiquid = Mathf.lerpDelta(visualLiquid, liquids.get(liq)>= 0.01f ? 1f : 0f, 0.06f);", building_draw_light["exact_exprs"])
        self.assertIn("drawLiquidLight(liq, visualLiquid);", building_draw_light["exact_exprs"])

        building_draw_liquid_light = source_symbols.source_slice(ledger, "N572")
        self.assertEqual(building_draw_liquid_light["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_draw_liquid_light["java_method"], "drawLiquidLight(Liquid liquid, float amount)")
        self.assertEqual(building_draw_liquid_light["godot_owner"], "PortGame.source_building_draw_liquid_light_state")
        self.assertIn("public void drawLiquidLight(Liquid liquid, float amount){", building_draw_liquid_light["exact_exprs"])
        self.assertIn("if(amount > 0.01f){", building_draw_liquid_light["exact_exprs"])
        self.assertIn("Color color = liquid.lightColor;", building_draw_liquid_light["exact_exprs"])
        self.assertIn("float fract = 1f;", building_draw_liquid_light["exact_exprs"])
        self.assertIn("float opacity = color.a * fract;", building_draw_liquid_light["exact_exprs"])
        self.assertIn("if(opacity > 0.001f){", building_draw_liquid_light["exact_exprs"])
        self.assertIn("Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);", building_draw_liquid_light["exact_exprs"])

        building_draw_select = source_symbols.source_slice(ledger, "N573")
        self.assertEqual(building_draw_select["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_draw_select["java_method"], "drawSelect()")
        self.assertEqual(building_draw_select["godot_owner"], "PortGame.source_building_draw_select_state")
        self.assertIn("/** Draw the block overlay that is shown when a cursor is over the block. */", building_draw_select["exact_exprs"])
        self.assertIn("public void drawSelect(){", building_draw_select["exact_exprs"])
        self.assertIn("block.drawOverlay(x, y, rotation);", building_draw_select["exact_exprs"])
        self.assertIn("if(status() == BlockStatus.inactiveUnitFactory){", building_draw_select["exact_exprs"])
        self.assertIn("block.drawPlaceText(Core.bundle.format(\"rules.unitfactoryactivation.objective\", UI.formatTime((float)Math.max(0f, state.rules.unitActivationDelay(team) - state.tick))), tile.x, tile.y, false);", building_draw_select["exact_exprs"])

        building_draw = source_symbols.source_slice(ledger, "N574")
        self.assertEqual(building_draw["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_draw["java_method"], "draw()")
        self.assertEqual(building_draw["godot_owner"], "PortGame.source_building_draw_state")
        self.assertIn("/** Called only if {@link Block#drawDynamic} is true (on by default). */", building_draw["exact_exprs"])
        self.assertIn("public void draw(){", building_draw["exact_exprs"])
        self.assertIn("if(block.variants == 0 || block.variantRegions == null){", building_draw["exact_exprs"])
        self.assertIn("Draw.rect(block.region, x, y, drawrot());", building_draw["exact_exprs"])
        self.assertIn("Draw.rect(block.variantRegions[Mathf.randomSeed(tile.pos(), 0, Math.max(0, block.variantRegions.length - 1))], x, y, drawrot());", building_draw["exact_exprs"])
        self.assertIn("drawTeamTop();", building_draw["exact_exprs"])

        building_draw_status = source_symbols.source_slice(ledger, "N575")
        self.assertEqual(building_draw_status["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_draw_status["java_method"], "drawStatus()")
        self.assertEqual(building_draw_status["godot_owner"], "PortGame.source_building_draw_status_state")
        self.assertIn("public void drawStatus(){", building_draw_status["exact_exprs"])
        self.assertIn("if(block.enableDrawStatus && block.consumers.length > 0){", building_draw_status["exact_exprs"])
        self.assertIn("float multiplier = block.size > 1 ? 1 : 0.64f;", building_draw_status["exact_exprs"])
        self.assertIn("float brcx = x + (block.size * tilesize / 2f) - (tilesize * multiplier / 2f);", building_draw_status["exact_exprs"])
        self.assertIn("float brcy = y - (block.size * tilesize / 2f) + (tilesize * multiplier / 2f);", building_draw_status["exact_exprs"])
        self.assertIn("Fill.square(brcx, brcy, 2.5f * multiplier, 45);", building_draw_status["exact_exprs"])
        self.assertIn("Fill.square(brcx, brcy, 1.5f * multiplier, 45);", building_draw_status["exact_exprs"])

        building_draw_team = source_symbols.source_slice(ledger, "N576")
        self.assertEqual(building_draw_team["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_draw_team["java_method"], "drawTeam()")
        self.assertEqual(building_draw_team["godot_owner"], "PortGame.source_building_draw_team_state")
        self.assertIn("public void drawTeam(){", building_draw_team["exact_exprs"])
        self.assertIn("Draw.color(team.color);", building_draw_team["exact_exprs"])
        self.assertIn("Draw.rect(\"block-border\", x - block.size * tilesize / 2f + 4, y - block.size * tilesize / 2f + 4);", building_draw_team["exact_exprs"])
        self.assertIn("x - block.size * tilesize / 2f + 4", building_draw_team["exact_exprs"])
        self.assertIn("y - block.size * tilesize / 2f + 4", building_draw_team["exact_exprs"])
        self.assertIn("Draw.color();", building_draw_team["exact_exprs"])

        building_draw_team_top = source_symbols.source_slice(ledger, "N577")
        self.assertEqual(building_draw_team_top["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_draw_team_top["java_method"], "drawTeamTop()")
        self.assertEqual(building_draw_team_top["godot_owner"], "PortGame.source_building_draw_team_top_state")
        self.assertIn("public void drawTeamTop(){", building_draw_team_top["exact_exprs"])
        self.assertIn("if(block.teamRegion.found()){", building_draw_team_top["exact_exprs"])
        self.assertIn("if(block.teamRegions[team.id] == block.teamRegion) Draw.color(team.color);", building_draw_team_top["exact_exprs"])
        self.assertIn("Draw.rect(block.teamRegions[team.id], x, y);", building_draw_team_top["exact_exprs"])
        self.assertIn("Draw.color();", building_draw_team_top["exact_exprs"])

        building_drawrot = source_symbols.source_slice(ledger, "N578")
        self.assertEqual(building_drawrot["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_drawrot["java_method"], "drawrot()")
        self.assertEqual(building_drawrot["godot_owner"], "PortGame.source_building_drawrot_state")
        self.assertIn("public float drawrot(){", building_drawrot["exact_exprs"])
        self.assertIn("return block.rotate && block.rotateDraw ? rotation * 90 : 0f;", building_drawrot["exact_exprs"])

        building_edelta = source_symbols.source_slice(ledger, "N579")
        self.assertEqual(building_edelta["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_edelta["java_method"], "edelta()")
        self.assertEqual(building_edelta["godot_owner"], "PortGame.source_building_edelta")
        self.assertIn("public float edelta(){", building_edelta["exact_exprs"])
        self.assertIn("return efficiency * delta();", building_edelta["exact_exprs"])
        self.assertIn("delta()", building_edelta["deferred_exprs"][0])

        building_efficiency_scale = source_symbols.source_slice(ledger, "N580")
        self.assertEqual(building_efficiency_scale["java_source"], "core/src/mindustry/entities/comp/BuildingComp.java")
        self.assertEqual(building_efficiency_scale["java_method"], "efficiencyScale()")
        self.assertEqual(building_efficiency_scale["godot_owner"], "PortGame.source_building_efficiency_scale_state")
        self.assertIn("/** Calculate your own efficiency multiplier. By default, this is applied in updateEfficiencyMultiplier. */", building_efficiency_scale["exact_exprs"])
        self.assertIn("public float efficiencyScale(){", building_efficiency_scale["exact_exprs"])
        self.assertIn("return 1f;", building_efficiency_scale["exact_exprs"])

        arc_mathf_cos_scaled = source_symbols.source_slice(ledger, "N501")
        self.assertEqual(arc_mathf_cos_scaled["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_mathf_cos_scaled["java_method"], "cos(float radians, float scl, float mag)")
        self.assertEqual(arc_mathf_cos_scaled["godot_owner"], "PortGame.source_arc_mathf_cos_scaled")
        self.assertIn("public static float cos(float radians, float scl, float mag){\n        return cos(radians / scl) * mag;\n    }", arc_mathf_cos_scaled["exact_exprs"])
        self.assertIn("return cos(radians / scl) * mag;", arc_mathf_cos_scaled["exact_exprs"])

        arc_mathf_mod_float = source_symbols.source_slice(ledger, "N502")
        self.assertEqual(arc_mathf_mod_float["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_mathf_mod_float["java_method"], "mod(float f, float n)")
        self.assertEqual(arc_mathf_mod_float["godot_owner"], "PortGame.source_arc_mathf_mod_float")
        self.assertIn("public static float mod(float f, float n){\n        return ((f % n) + n) % n;\n    }", arc_mathf_mod_float["exact_exprs"])
        self.assertIn("return ((f % n) + n) % n;", arc_mathf_mod_float["exact_exprs"])

        arc_mathf_num = source_symbols.source_slice(ledger, "N503")
        self.assertEqual(arc_mathf_num["java_source"], "arc-core/src/arc/math/Mathf.java")
        self.assertEqual(arc_mathf_num["java_method"], "num(boolean b)")
        self.assertEqual(arc_mathf_num["godot_owner"], "PortGame.source_arc_mathf_num")
        self.assertIn("public static int num(boolean b){\n        return b ? 1 : 0;\n    }", arc_mathf_num["exact_exprs"])
        self.assertIn("return b ? 1 : 0;", arc_mathf_num["exact_exprs"])

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

        create_splash_damage_dispatch = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_splash_damage_damage_dispatch_state")
        self.assertEqual([param["name"] for param in create_splash_damage_dispatch["params"]], ["bullet_type_state", "bullet_state", "hit_splash_damage_dispatch_state", "damage_multiplier_state"])
        self.assertEqual(create_splash_damage_dispatch["params"][2]["schema"], "hit_splash_damage_dispatch_result")
        self.assertEqual(create_splash_damage_dispatch["params"][3]["schema"], "damage_multiplier_result")
        self.assertIn("splashDamageGatePassed", create_splash_damage_dispatch["return_keys"])
        self.assertIn("damageCall", create_splash_damage_dispatch["return_keys"])
        self.assertIn("statusBoundarySource", create_splash_damage_dispatch["return_keys"])
        self.assertEqual(create_splash_damage_dispatch["source_method"], "createSplashDamage(Bullet b, float x, float y)")

        create_splash_damage_status = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_splash_damage_status_dispatch_state")
        self.assertEqual([param["name"] for param in create_splash_damage_status["params"]], ["bullet_type_state", "bullet_state", "create_splash_damage_damage_dispatch_state"])
        self.assertEqual(create_splash_damage_status["params"][2]["schema"], "create_splash_damage_damage_dispatch_result")
        self.assertIn("statusGatePassed", create_splash_damage_status["return_keys"])
        self.assertIn("statusCall", create_splash_damage_status["return_keys"])
        self.assertIn("healsBoundarySource", create_splash_damage_status["return_keys"])
        self.assertEqual(create_splash_damage_status["source_method"], "createSplashDamage(Bullet b, float x, float y)")

        create_splash_damage_heal = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_splash_damage_heal_dispatch_state")
        self.assertEqual([param["name"] for param in create_splash_damage_heal["params"]], ["bullet_type_state", "bullet_state", "create_splash_damage_status_dispatch_state", "nearby_blocks_state"])
        self.assertEqual(create_splash_damage_heal["params"][2]["schema"], "create_splash_damage_status_dispatch_result")
        self.assertEqual(create_splash_damage_heal["params"][3]["schema"], "nearby_blocks_state")
        self.assertIn("healGatePassed", create_splash_damage_heal["return_keys"])
        self.assertIn("eachBlockCall", create_splash_damage_heal["return_keys"])
        self.assertIn("healApplications", create_splash_damage_heal["return_keys"])
        self.assertIn("makeFireBoundarySource", create_splash_damage_heal["return_keys"])
        self.assertEqual(create_splash_damage_heal["source_method"], "createSplashDamage(Bullet b, float x, float y)")

        create_splash_damage_make_fire = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_splash_damage_make_fire_dispatch_state")
        self.assertEqual([param["name"] for param in create_splash_damage_make_fire["params"]], ["bullet_type_state", "bullet_state", "create_splash_damage_heal_dispatch_state", "nearby_blocks_state"])
        self.assertEqual(create_splash_damage_make_fire["params"][2]["schema"], "create_splash_damage_heal_dispatch_result")
        self.assertEqual(create_splash_damage_make_fire["params"][3]["schema"], "nearby_blocks_state")
        self.assertIn("makeFireGatePassed", create_splash_damage_make_fire["return_keys"])
        self.assertIn("eachBlockCall", create_splash_damage_make_fire["return_keys"])
        self.assertIn("fireApplications", create_splash_damage_make_fire["return_keys"])
        self.assertIn("createFragsBoundarySource", create_splash_damage_make_fire["return_keys"])
        self.assertEqual(create_splash_damage_make_fire["source_method"], "createSplashDamage(Bullet b, float x, float y)")

        create_frags_initial = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_frags_initial_state")
        self.assertEqual([param["name"] for param in create_frags_initial["params"]], ["bullet_type_state", "bullet_state", "create_frags_state"])
        self.assertEqual(create_frags_initial["params"][2]["schema"], "create_frags_state")
        self.assertIn("fragGatePassed", create_frags_initial["return_keys"])
        self.assertIn("loopIterations", create_frags_initial["return_keys"])
        self.assertIn("loopBoundarySource", create_frags_initial["return_keys"])
        self.assertIn("randomLenBoundarySource", create_frags_initial["return_keys"])
        self.assertEqual(create_frags_initial["source_method"], "createFrags(Bullet b, float x, float y)")

        create_frags_random_geometry = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_frags_random_geometry_state")
        self.assertEqual([param["name"] for param in create_frags_random_geometry["params"]], ["bullet_type_state", "bullet_state", "create_frags_initial_state", "frag_random_state"])
        self.assertEqual(create_frags_random_geometry["params"][3]["schema"], "frag_random_state")
        self.assertIn("fragmentPlans", create_frags_random_geometry["return_keys"])
        self.assertIn("randomLenSource", create_frags_random_geometry["return_keys"])
        self.assertIn("angleFormulaSource", create_frags_random_geometry["return_keys"])
        self.assertIn("createCallBoundarySource", create_frags_random_geometry["return_keys"])
        self.assertEqual(create_frags_random_geometry["source_method"], "createFrags(Bullet b, float x, float y)")

        create_frags_create_call = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_frags_create_call_state")
        self.assertEqual([param["name"] for param in create_frags_create_call["params"]], ["bullet_type_state", "bullet_state", "create_frags_random_geometry_state", "frag_random_state"])
        self.assertEqual(create_frags_create_call["params"][2]["schema"], "create_frags_random_geometry_result")
        self.assertEqual(create_frags_create_call["params"][3]["schema"], "frag_random_state")
        self.assertIn("fragmentCreateCalls", create_frags_create_call["return_keys"])
        self.assertIn("velocityRandomSource", create_frags_create_call["return_keys"])
        self.assertIn("lifeRandomSource", create_frags_create_call["return_keys"])
        self.assertIn("createCallSource", create_frags_create_call["return_keys"])
        self.assertEqual(create_frags_create_call["source_method"], "createFrags(Bullet b, float x, float y)")

        create_frags_increment = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_frags_increment_state")
        self.assertEqual([param["name"] for param in create_frags_increment["params"]], ["bullet_state", "create_frags_create_call_state"])
        self.assertEqual(create_frags_increment["params"][1]["schema"], "create_frags_create_call_result")
        self.assertIn("bulletFragsBefore", create_frags_increment["return_keys"])
        self.assertIn("bulletFragsAfter", create_frags_increment["return_keys"])
        self.assertIn("fragsIncremented", create_frags_increment["return_keys"])
        self.assertIn("fragsIncrementSource", create_frags_increment["return_keys"])
        self.assertEqual(create_frags_increment["source_method"], "createFrags(Bullet b, float x, float y)")

        create_puddles_initial = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_puddles_initial_state")
        self.assertEqual([param["name"] for param in create_puddles_initial["params"]], ["bullet_type_state", "bullet_state", "create_puddles_state"])
        self.assertEqual(create_puddles_initial["params"][2]["schema"], "create_puddles_state")
        self.assertIn("puddleGatePassed", create_puddles_initial["return_keys"])
        self.assertIn("loopIterations", create_puddles_initial["return_keys"])
        self.assertIn("tileBoundarySource", create_puddles_initial["return_keys"])
        self.assertIn("depositBoundarySource", create_puddles_initial["return_keys"])
        self.assertEqual(create_puddles_initial["source_method"], "createPuddles(Bullet b, float x, float y)")

        create_puddles_tile_world = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_puddles_tile_world_state")
        self.assertEqual([param["name"] for param in create_puddles_tile_world["params"]], ["bullet_type_state", "bullet_state", "create_puddles_initial_state", "puddle_random_state"])
        self.assertEqual(create_puddles_tile_world["params"][2]["schema"], "create_puddles_initial_result")
        self.assertEqual(create_puddles_tile_world["params"][3]["schema"], "puddle_random_state")
        self.assertIn("tileWorldCalls", create_puddles_tile_world["return_keys"])
        self.assertIn("tileWorldSource", create_puddles_tile_world["return_keys"])
        self.assertIn("depositBoundarySource", create_puddles_tile_world["return_keys"])
        self.assertEqual(create_puddles_tile_world["source_method"], "createPuddles(Bullet b, float x, float y)")

        create_puddles_deposit = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_puddles_deposit_state")
        self.assertEqual([param["name"] for param in create_puddles_deposit["params"]], ["bullet_type_state", "bullet_state", "create_puddles_tile_world_state"])
        self.assertEqual(create_puddles_deposit["params"][2]["schema"], "create_puddles_tile_world_result")
        self.assertIn("depositCalls", create_puddles_deposit["return_keys"])
        self.assertIn("depositSource", create_puddles_deposit["return_keys"])
        self.assertEqual(create_puddles_deposit["source_method"], "createPuddles(Bullet b, float x, float y)")

        create_incend = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_incend_state")
        self.assertEqual([param["name"] for param in create_incend["params"]], ["bullet_type_state", "bullet_state", "create_incend_state", "incend_random_state"])
        self.assertEqual(create_incend["params"][2]["schema"], "create_incend_state")
        self.assertEqual(create_incend["params"][3]["schema"], "incend_random_state")
        self.assertIn("incendGatePassed", create_incend["return_keys"])
        self.assertIn("createIncendCall", create_incend["return_keys"])
        self.assertIn("createIncendSource", create_incend["return_keys"])
        self.assertEqual(create_incend["source_method"], "createIncend(Bullet b, float x, float y)")

        create_units_initial = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_units_initial_state")
        self.assertEqual([param["name"] for param in create_units_initial["params"]], ["bullet_type_state", "bullet_state", "create_units_state", "create_units_random_state", "net_state"])
        self.assertEqual(create_units_initial["params"][2]["schema"], "create_units_state")
        self.assertEqual(create_units_initial["params"][3]["schema"], "create_units_random_state")
        self.assertEqual(create_units_initial["params"][4]["schema"], "net_state")
        self.assertIn("createUnitsGatePassed", create_units_initial["return_keys"])
        self.assertIn("loopIterations", create_units_initial["return_keys"])
        self.assertIn("randomOffsetBoundarySource", create_units_initial["return_keys"])
        self.assertEqual(create_units_initial["source_method"], "createUnits(Bullet b, float x, float y)")

        create_units_random_offset = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_units_random_offset_state")
        self.assertEqual([param["name"] for param in create_units_random_offset["params"]], ["bullet_type_state", "bullet_state", "create_units_initial_state", "create_units_random_state"])
        self.assertEqual(create_units_random_offset["params"][2]["schema"], "create_units_initial_result")
        self.assertEqual(create_units_random_offset["params"][3]["schema"], "create_units_random_state")
        self.assertIn("unitOffsetPlans", create_units_random_offset["return_keys"])
        self.assertIn("randomDirectionSource", create_units_random_offset["return_keys"])
        self.assertIn("spawnBoundarySource", create_units_random_offset["return_keys"])
        self.assertEqual(create_units_random_offset["source_method"], "createUnits(Bullet b, float x, float y)")

        create_units_spawn = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_units_spawn_state")
        self.assertEqual([param["name"] for param in create_units_spawn["params"]], ["bullet_type_state", "bullet_state", "create_units_random_offset_state"])
        self.assertEqual(create_units_spawn["params"][2]["schema"], "create_units_random_offset_result")
        self.assertIn("spawnCalls", create_units_spawn["return_keys"])
        self.assertIn("rotationBoundarySource", create_units_spawn["return_keys"])
        self.assertIn("notifyBoundarySource", create_units_spawn["return_keys"])
        self.assertEqual(create_units_spawn["source_method"], "createUnits(Bullet b, float x, float y)")

        create_units_rotation = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_units_rotation_state")
        self.assertEqual([param["name"] for param in create_units_rotation["params"]], ["bullet_type_state", "bullet_state", "create_units_spawn_state"])
        self.assertEqual(create_units_rotation["params"][2]["schema"], "create_units_spawn_result")
        self.assertIn("rotationAssignments", create_units_rotation["return_keys"])
        self.assertIn("notifyBoundarySource", create_units_rotation["return_keys"])
        self.assertEqual(create_units_rotation["source_method"], "createUnits(Bullet b, float x, float y)")

        create_units_notify = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_units_notify_state")
        self.assertEqual([param["name"] for param in create_units_notify["params"]], ["bullet_type_state", "bullet_state", "create_units_rotation_state"])
        self.assertEqual(create_units_notify["params"][2]["schema"], "create_units_rotation_result")
        self.assertIn("notifyCalls", create_units_notify["return_keys"])
        self.assertIn("notifySource", create_units_notify["return_keys"])
        self.assertEqual(create_units_notify["source_method"], "createUnits(Bullet b, float x, float y)")

        despawned_dispatch = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_despawned_dispatch_state")
        self.assertEqual([param["name"] for param in despawned_dispatch["params"]], ["bullet_type_state", "bullet_state"])
        self.assertEqual(despawned_dispatch["params"][0]["schema"], "bullet_type_state")
        self.assertEqual(despawned_dispatch["params"][1]["schema"], "bullet_state")
        self.assertIn("hitCall", despawned_dispatch["return_keys"])
        self.assertIn("createUnitsCall", despawned_dispatch["return_keys"])
        self.assertIn("despawnEffectBoundarySource", despawned_dispatch["return_keys"])
        self.assertIn("despawnSoundBoundarySource", despawned_dispatch["return_keys"])
        self.assertIn("shakeBoundarySource", despawned_dispatch["return_keys"])
        self.assertEqual(despawned_dispatch["source_method"], "despawned(Bullet b)")

        despawned_effect = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_despawned_effect_state")
        self.assertEqual([param["name"] for param in despawned_effect["params"]], ["bullet_type_state", "bullet_state", "despawned_dispatch_state"])
        self.assertEqual(despawned_effect["params"][2]["schema"], "despawned_dispatch_result")
        self.assertIn("despawnEffectCall", despawned_effect["return_keys"])
        self.assertIn("despawnSoundBoundarySource", despawned_effect["return_keys"])
        self.assertIn("shakeBoundarySource", despawned_effect["return_keys"])
        self.assertEqual(despawned_effect["source_method"], "despawned(Bullet b)")

        despawned_sound = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_despawned_sound_state")
        self.assertEqual([param["name"] for param in despawned_sound["params"]], ["bullet_type_state", "bullet_state", "despawned_effect_state", "despawn_sound_random_state"])
        self.assertEqual(despawned_sound["params"][2]["schema"], "despawned_effect_result")
        self.assertEqual(despawned_sound["params"][3]["schema"], "despawn_sound_random_state")
        self.assertIn("despawnSoundCall", despawned_sound["return_keys"])
        self.assertIn("shakeBoundarySource", despawned_sound["return_keys"])
        self.assertEqual(despawned_sound["source_method"], "despawned(Bullet b)")

        despawned_shake = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_despawned_shake_state")
        self.assertEqual([param["name"] for param in despawned_shake["params"]], ["bullet_type_state", "bullet_state", "despawned_sound_state"])
        self.assertEqual(despawned_shake["params"][2]["schema"], "despawned_sound_result")
        self.assertIn("despawnShake", despawned_shake["return_keys"])
        self.assertIn("shakeCall", despawned_shake["return_keys"])
        self.assertIn("effectShakePositionSource", despawned_shake["return_keys"])
        self.assertIn("removedBoundarySource", despawned_shake["return_keys"])
        self.assertEqual(despawned_shake["source_method"], "despawned(Bullet b)")

        removed_trail_fade = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_removed_trail_fade_state")
        self.assertEqual([param["name"] for param in removed_trail_fade["params"]], ["bullet_type_state", "bullet_state"])
        self.assertIn("gatePassed", removed_trail_fade["return_keys"])
        self.assertIn("trailFadeCall", removed_trail_fade["return_keys"])
        self.assertIn("fragBoundarySource", removed_trail_fade["return_keys"])
        self.assertEqual(removed_trail_fade["source_method"], "removed(Bullet b)")

        removed_frag_dispatch = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_removed_frag_dispatch_state")
        self.assertEqual([param["name"] for param in removed_frag_dispatch["params"]], ["bullet_type_state", "bullet_state", "removed_trail_fade_state"])
        self.assertEqual(removed_frag_dispatch["params"][2]["schema"], "removed_trail_fade_result")
        self.assertIn("fragGatePassed", removed_frag_dispatch["return_keys"])
        self.assertIn("createFragsCall", removed_frag_dispatch["return_keys"])
        self.assertIn("buildingDamageBoundarySource", removed_frag_dispatch["return_keys"])
        self.assertEqual(removed_frag_dispatch["source_method"], "removed(Bullet b)")

        building_damage = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_building_damage_state")
        self.assertEqual([param["name"] for param in building_damage["params"]], ["bullet_state"])
        self.assertIn("buildingDamage", building_damage["return_keys"])
        self.assertIn("buildingDamageReturnSource", building_damage["return_keys"])
        self.assertIn("shieldDamageBoundarySource", building_damage["return_keys"])
        self.assertEqual(building_damage["source_method"], "buildingDamage(Bullet b)")

        shield_damage = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_shield_damage_state")
        self.assertEqual([param["name"] for param in shield_damage["params"]], ["bullet_type_state", "bullet_state"])
        self.assertIn("shieldDamage", shield_damage["return_keys"])
        self.assertIn("shieldDamageReturnSource", shield_damage["return_keys"])
        self.assertIn("drawBoundarySource", shield_damage["return_keys"])
        self.assertEqual(shield_damage["source_method"], "shieldDamage(Bullet b)")

        draw = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_draw_state")
        self.assertEqual([param["name"] for param in draw["params"]], ["bullet_state"])
        self.assertIn("drawCalls", draw["return_keys"])
        self.assertIn("drawTrailCalled", draw["return_keys"])
        self.assertIn("drawPartsCalled", draw["return_keys"])
        self.assertIn("drawReturnSource", draw["return_keys"])
        self.assertIn("drawTrailBoundarySource", draw["return_keys"])
        self.assertEqual(draw["source_method"], "draw(Bullet b)")

        draw_trail = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_draw_trail_state")
        self.assertEqual([param["name"] for param in draw_trail["params"]], ["bullet_type_state", "bullet_state", "current_draw_z"])
        self.assertIn("gatePassed", draw_trail["return_keys"])
        self.assertIn("trailDrawCall", draw_trail["return_keys"])
        self.assertIn("drawZBelow", draw_trail["return_keys"])
        self.assertIn("drawPartsBoundarySource", draw_trail["return_keys"])
        self.assertEqual(draw_trail["source_method"], "drawTrail(Bullet b)")

        draw_light = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_draw_light_state")
        self.assertEqual([param["name"] for param in draw_light["params"]], ["bullet_type_state", "bullet_state"])
        self.assertIn("gatePassed", draw_light["return_keys"])
        self.assertIn("lightDrawn", draw_light["return_keys"])
        self.assertIn("drawfLightCall", draw_light["return_keys"])
        self.assertIn("initBoundarySource", draw_light["return_keys"])
        self.assertEqual(draw_light["source_method"], "drawLight(Bullet b)")

        init_initial = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_init_initial_state")
        self.assertEqual([param["name"] for param in init_initial["params"]], ["bullet_state", "bullet_type_state", "owner_health_state"])
        self.assertIn("killShooterApplied", init_initial["return_keys"])
        self.assertIn("instantDisappearApplied", init_initial["return_keys"])
        self.assertIn("spawnBulletsDeferred", init_initial["return_keys"])
        self.assertEqual(init_initial["source_method"], "init(Bullet b)")

        init_spawn = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_init_spawn_bullets_state")
        self.assertEqual([param["name"] for param in init_spawn["params"]], ["init_initial_state", "bullet_type_state", "spawn_bullet_random_state"])
        self.assertIn("spawnBulletCalls", init_spawn["return_keys"])
        self.assertIn("spawnBulletsApplied", init_spawn["return_keys"])
        self.assertIn("spawnBulletRandomOffsets", init_spawn["return_keys"])
        self.assertIn("updateBoundarySource", init_spawn["return_keys"])
        self.assertEqual(init_spawn["source_method"], "init(Bullet b)")

        update_dispatch = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_update_dispatch_state")
        self.assertEqual([param["name"] for param in update_dispatch["params"]], ["bullet_state"])
        self.assertIn("callOrder", update_dispatch["return_keys"])
        self.assertIn("updateMethodSource", update_dispatch["return_keys"])
        self.assertIn("nextMethodReservedSource", update_dispatch["return_keys"])
        self.assertEqual(update_dispatch["source_method"], "update(Bullet b)")

        update_interval = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_update_bullet_interval_state")
        self.assertEqual([param["name"] for param in update_interval["params"]], ["bullet_state", "bullet_type_state", "timer_get_result", "interval_random_offsets"])
        self.assertIn("gatePassed", update_interval["return_keys"])
        self.assertIn("timerIndex", update_interval["return_keys"])
        self.assertIn("timerTime", update_interval["return_keys"])
        self.assertIn("intervalBulletCalls", update_interval["return_keys"])
        self.assertIn("intervalRandomOffsets", update_interval["return_keys"])
        self.assertIn("updateHomingBoundarySource", update_interval["return_keys"])
        self.assertEqual(update_interval["source_method"], "updateBulletInterval(Bullet b)")

        update_trail = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_update_trail_state")
        self.assertEqual([param["name"] for param in update_trail["params"]], ["bullet_state", "bullet_type_state", "headless_value", "trail_interp_value", "absin_value", "source_delta"])
        self.assertIn("gatePassed", update_trail["return_keys"])
        self.assertIn("trailCreated", update_trail["return_keys"])
        self.assertIn("trailUpdated", update_trail["return_keys"])
        self.assertIn("trail", update_trail["return_keys"])
        self.assertIn("width", update_trail["return_keys"])
        self.assertIn("initBoundarySource", update_trail["return_keys"])
        self.assertEqual(update_trail["source_method"], "updateTrail(Bullet b)")

        homing_initial = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_update_homing_initial_state")
        self.assertEqual([param["name"] for param in homing_initial["params"]], ["bullet_state", "bullet_type_state"])
        self.assertIn("gatePassed", homing_initial["return_keys"])
        self.assertIn("realAimComputed", homing_initial["return_keys"])
        self.assertIn("realAimX", homing_initial["return_keys"])
        self.assertIn("realAimY", homing_initial["return_keys"])
        self.assertIn("targetSelectionDeferred", homing_initial["return_keys"])
        self.assertIn("followAimDeferred", homing_initial["return_keys"])
        self.assertIn("targetReservedSource", homing_initial["return_keys"])
        self.assertIn("followAimReservedSource", homing_initial["return_keys"])
        self.assertEqual(homing_initial["source_method"], "updateHoming(Bullet b)")

        homing_target_velocity = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_update_homing_target_velocity_state")
        self.assertEqual([param["name"] for param in homing_target_velocity["params"]], ["homing_initial_state", "target_state", "source_delta"])
        self.assertEqual(homing_target_velocity["params"][0]["schema"], "update_homing_initial_result")
        self.assertEqual(homing_target_velocity["params"][1]["schema"], "target_state")
        self.assertEqual(homing_target_velocity["params"][2]["schema"], "time_state.delta")
        self.assertIn("homingVelocityApplied", homing_target_velocity["return_keys"])
        self.assertIn("targetGatePassed", homing_target_velocity["return_keys"])
        self.assertIn("currentRotation", homing_target_velocity["return_keys"])
        self.assertIn("targetAngle", homing_target_velocity["return_keys"])
        self.assertIn("maxTurn", homing_target_velocity["return_keys"])
        self.assertIn("nextAngle", homing_target_velocity["return_keys"])
        self.assertIn("velocity", homing_target_velocity["return_keys"])
        self.assertEqual(homing_target_velocity["source_method"], "updateHoming(Bullet b)")

        homing_follow_aim = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_update_homing_follow_aim_state")
        self.assertEqual([param["name"] for param in homing_follow_aim["params"]], ["homing_target_velocity_state", "bullet_type_state", "shooter_state", "source_delta"])
        self.assertEqual(homing_follow_aim["params"][0]["schema"], "update_homing_target_velocity_result")
        self.assertEqual(homing_follow_aim["params"][1]["schema"], "bullet_type_state")
        self.assertEqual(homing_follow_aim["params"][2]["schema"], "shooter_state")
        self.assertEqual(homing_follow_aim["params"][3]["schema"], "time_state.delta")
        self.assertIn("followAimApplied", homing_follow_aim["return_keys"])
        self.assertIn("followAimGatePassed", homing_follow_aim["return_keys"])
        self.assertIn("currentVelocityAngle", homing_follow_aim["return_keys"])
        self.assertIn("targetAngle", homing_follow_aim["return_keys"])
        self.assertIn("maxTurn", homing_follow_aim["return_keys"])
        self.assertIn("nextAngle", homing_follow_aim["return_keys"])
        self.assertIn("velocity", homing_follow_aim["return_keys"])
        self.assertEqual(homing_follow_aim["source_method"], "updateHoming(Bullet b)")

        update_weaving = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_update_weaving_state")
        self.assertEqual([param["name"] for param in update_weaving["params"]], ["bullet_state", "bullet_type_state", "random_seed_result", "source_delta"])
        self.assertEqual(update_weaving["params"][0]["schema"], "bullet_state")
        self.assertEqual(update_weaving["params"][1]["schema"], "bullet_type_state")
        self.assertEqual(update_weaving["params"][2]["schema"], "random_seed_state.randomSeedResult")
        self.assertEqual(update_weaving["params"][3]["schema"], "time_state.delta")
        self.assertIn("weaveApplied", update_weaving["return_keys"])
        self.assertIn("weaveGatePassed", update_weaving["return_keys"])
        self.assertIn("rotationRadians", update_weaving["return_keys"])
        self.assertIn("randomSign", update_weaving["return_keys"])
        self.assertIn("randomSeedResult", update_weaving["return_keys"])
        self.assertIn("velocity", update_weaving["return_keys"])
        self.assertEqual(update_weaving["source_method"], "updateWeaving(Bullet b)")

        update_weaving_rotate_speed = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_update_weaving_rotate_speed_state")
        self.assertEqual([param["name"] for param in update_weaving_rotate_speed["params"]], ["weaving_state", "bullet_type_state", "source_delta"])
        self.assertEqual(update_weaving_rotate_speed["params"][0]["schema"], "update_weaving_result")
        self.assertEqual(update_weaving_rotate_speed["params"][1]["schema"], "bullet_type_state")
        self.assertEqual(update_weaving_rotate_speed["params"][2]["schema"], "time_state.delta")
        self.assertIn("rotateSpeedApplied", update_weaving_rotate_speed["return_keys"])
        self.assertIn("rotateSpeedGatePassed", update_weaving_rotate_speed["return_keys"])
        self.assertIn("rotationRadians", update_weaving_rotate_speed["return_keys"])
        self.assertIn("velocity", update_weaving_rotate_speed["return_keys"])
        self.assertEqual(update_weaving_rotate_speed["source_method"], "updateWeaving(Bullet b)")

        update_weaving_circle_shooter = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_update_weaving_circle_shooter_state")
        self.assertEqual([param["name"] for param in update_weaving_circle_shooter["params"]], ["rotate_speed_state", "bullet_type_state", "owner_health_state", "source_delta"])
        self.assertEqual(update_weaving_circle_shooter["params"][0]["schema"], "update_weaving_rotate_speed_result")
        self.assertEqual(update_weaving_circle_shooter["params"][1]["schema"], "bullet_type_state")
        self.assertEqual(update_weaving_circle_shooter["params"][2]["schema"], "owner_health_state")
        self.assertEqual(update_weaving_circle_shooter["params"][3]["schema"], "time_state.delta")
        self.assertIn("circleShooterApplied", update_weaving_circle_shooter["return_keys"])
        self.assertIn("circleShooterGatePassed", update_weaving_circle_shooter["return_keys"])
        self.assertIn("tmpBeforeRotate", update_weaving_circle_shooter["return_keys"])
        self.assertIn("rotationDegrees", update_weaving_circle_shooter["return_keys"])
        self.assertIn("tmpLimit", update_weaving_circle_shooter["return_keys"])
        self.assertIn("limitedTmp", update_weaving_circle_shooter["return_keys"])
        self.assertIn("velocity", update_weaving_circle_shooter["return_keys"])
        self.assertEqual(update_weaving_circle_shooter["source_method"], "updateWeaving(Bullet b)")

        update_trail_effects_chance = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_update_trail_effects_chance_state")
        self.assertEqual([param["name"] for param in update_trail_effects_chance["params"]], ["bullet_state", "bullet_type_state", "chance_delta_result", "random_offset_state"])
        self.assertEqual(update_trail_effects_chance["params"][0]["schema"], "bullet_state")
        self.assertEqual(update_trail_effects_chance["params"][1]["schema"], "bullet_type_state")
        self.assertEqual(update_trail_effects_chance["params"][2]["schema"], "chance_delta_state.chanceDeltaResult")
        self.assertEqual(update_trail_effects_chance["params"][3]["schema"], "random_offset_state")
        self.assertIn("trailChanceEffectApplied", update_trail_effects_chance["return_keys"])
        self.assertIn("canSpawn", update_trail_effects_chance["return_keys"])
        self.assertIn("chanceGatePassed", update_trail_effects_chance["return_keys"])
        self.assertIn("chanceDeltaResult", update_trail_effects_chance["return_keys"])
        self.assertIn("tmpOffset", update_trail_effects_chance["return_keys"])
        self.assertIn("effectCalls", update_trail_effects_chance["return_keys"])
        self.assertEqual(update_trail_effects_chance["source_method"], "updateTrailEffects(Bullet b)")

        update_trail_effects_interval = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_update_trail_effects_interval_state")
        self.assertEqual([param["name"] for param in update_trail_effects_interval["params"]], ["chance_state", "bullet_type_state", "timer_get_result", "random_offset_state"])
        self.assertEqual(update_trail_effects_interval["params"][0]["schema"], "update_trail_effects_chance_result")
        self.assertEqual(update_trail_effects_interval["params"][1]["schema"], "bullet_type_state")
        self.assertEqual(update_trail_effects_interval["params"][2]["schema"], "trail_effects_timer_state.timerGetResult")
        self.assertEqual(update_trail_effects_interval["params"][3]["schema"], "random_offset_state")
        self.assertIn("trailIntervalEffectApplied", update_trail_effects_interval["return_keys"])
        self.assertIn("canSpawn", update_trail_effects_interval["return_keys"])
        self.assertIn("intervalGatePassed", update_trail_effects_interval["return_keys"])
        self.assertIn("timerGetResult", update_trail_effects_interval["return_keys"])
        self.assertIn("tmpOffset", update_trail_effects_interval["return_keys"])
        self.assertIn("effectCalls", update_trail_effects_interval["return_keys"])
        self.assertEqual(update_trail_effects_interval["source_method"], "updateTrailEffects(Bullet b)")

        init_type_defaults = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_init_type_defaults_state")
        self.assertEqual([param["name"] for param in init_type_defaults["params"]], ["bullet_type_state"])
        self.assertEqual(init_type_defaults["params"][0]["schema"], "bullet_type_state")
        self.assertIn("bulletType", init_type_defaults["return_keys"])
        self.assertIn("pierceApplied", init_type_defaults["return_keys"])
        self.assertIn("setDefaults", init_type_defaults["return_keys"])
        self.assertIn("lightning", init_type_defaults["return_keys"])
        self.assertIn("statusBefore", init_type_defaults["return_keys"])
        self.assertIn("statusShockedApplied", init_type_defaults["return_keys"])
        self.assertIn("despawnHitApplied", init_type_defaults["return_keys"])
        self.assertEqual(init_type_defaults["source_method"], "init()")

        init_frag_velocity = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_init_frag_velocity_state")
        self.assertEqual([param["name"] for param in init_frag_velocity["params"]], ["type_defaults_state"])
        self.assertEqual(init_frag_velocity["params"][0]["schema"], "init_type_defaults_result")
        self.assertIn("bulletType", init_frag_velocity["return_keys"])
        self.assertIn("fragBulletVelocityApplied", init_frag_velocity["return_keys"])
        self.assertIn("fragGatePassed", init_frag_velocity["return_keys"])
        self.assertIn("fragBullet", init_frag_velocity["return_keys"])
        self.assertEqual(init_frag_velocity["source_method"], "init()")

        init_lightning_type = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_init_lightning_type_state")
        self.assertEqual([param["name"] for param in init_lightning_type["params"]], ["frag_velocity_state"])
        self.assertEqual(init_lightning_type["params"][0]["schema"], "init_frag_velocity_result")
        self.assertIn("bulletType", init_lightning_type["return_keys"])
        self.assertIn("lightningTypeApplied", init_lightning_type["return_keys"])
        self.assertIn("lightningTypeGatePassed", init_lightning_type["return_keys"])
        self.assertIn("lightningType", init_lightning_type["return_keys"])
        self.assertIn("collidesAir", init_lightning_type["return_keys"])
        self.assertIn("collidesGround", init_lightning_type["return_keys"])
        self.assertEqual(init_lightning_type["source_method"], "init()")

        init_light_radius = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_init_light_radius_state")
        self.assertEqual([param["name"] for param in init_light_radius["params"]], ["lightning_type_state"])
        self.assertEqual(init_light_radius["params"][0]["schema"], "init_lightning_type_result")
        self.assertIn("bulletType", init_light_radius["return_keys"])
        self.assertIn("lightRadiusApplied", init_light_radius["return_keys"])
        self.assertIn("lightRadiusGatePassed", init_light_radius["return_keys"])
        self.assertIn("lightRadius", init_light_radius["return_keys"])
        self.assertIn("hitSize", init_light_radius["return_keys"])
        self.assertEqual(init_light_radius["source_method"], "init()")

        init_draw_size = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_init_draw_size_state")
        self.assertEqual([param["name"] for param in init_draw_size["params"]], ["light_radius_state"])
        self.assertEqual(init_draw_size["params"][0]["schema"], "init_light_radius_result")
        self.assertIn("bulletType", init_draw_size["return_keys"])
        self.assertIn("drawSize", init_draw_size["return_keys"])
        self.assertIn("drawSizeBefore", init_draw_size["return_keys"])
        self.assertIn("computedDrawSize", init_draw_size["return_keys"])
        self.assertIn("trailLength", init_draw_size["return_keys"])
        self.assertIn("speed", init_draw_size["return_keys"])
        self.assertEqual(init_draw_size["source_method"], "init()")

        init_range_assignment = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_init_range_assignment_state")
        self.assertEqual([param["name"] for param in init_range_assignment["params"]], ["draw_size_state", "calculate_range_result"])
        self.assertEqual(init_range_assignment["params"][0]["schema"], "init_draw_size_result")
        self.assertEqual(init_range_assignment["params"][1]["schema"], "calculate_range_result")
        self.assertIn("bulletType", init_range_assignment["return_keys"])
        self.assertIn("range", init_range_assignment["return_keys"])
        self.assertIn("rangeBefore", init_range_assignment["return_keys"])
        self.assertIn("rangeAssignSource", init_range_assignment["return_keys"])
        self.assertIn("calculateRangeDeferred", init_range_assignment["return_keys"])
        self.assertEqual(init_range_assignment["source_method"], "init()")

        calculate_range_override = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_calculate_range_override_state")
        self.assertEqual([param["name"] for param in calculate_range_override["params"]], ["bullet_type_state"])
        self.assertEqual(calculate_range_override["params"][0]["schema"], "bullet_type_state")
        self.assertIn("bulletType", calculate_range_override["return_keys"])
        self.assertIn("rangeOverride", calculate_range_override["return_keys"])
        self.assertIn("rangeOverrideGatePassed", calculate_range_override["return_keys"])
        self.assertIn("returnEarly", calculate_range_override["return_keys"])
        self.assertIn("range", calculate_range_override["return_keys"])
        self.assertIn("rangeOverrideReturnSource", calculate_range_override["return_keys"])
        self.assertEqual(calculate_range_override["source_method"], "calculateRange()")

        calculate_range_spawn_unit = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_calculate_range_spawn_unit_state")
        self.assertEqual([param["name"] for param in calculate_range_spawn_unit["params"]], ["override_state"])
        self.assertEqual(calculate_range_spawn_unit["params"][0]["schema"], "calculate_range_override_result")
        self.assertIn("bulletType", calculate_range_spawn_unit["return_keys"])
        self.assertIn("spawnUnitRangeGatePassed", calculate_range_spawn_unit["return_keys"])
        self.assertIn("returnEarly", calculate_range_spawn_unit["return_keys"])
        self.assertIn("range", calculate_range_spawn_unit["return_keys"])
        self.assertIn("spawnUnit", calculate_range_spawn_unit["return_keys"])
        self.assertIn("spawnUnitReturnSource", calculate_range_spawn_unit["return_keys"])
        self.assertEqual(calculate_range_spawn_unit["source_method"], "calculateRange()")

        calculate_range_despawn_unit = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_calculate_range_despawn_unit_state")
        self.assertEqual([param["name"] for param in calculate_range_despawn_unit["params"]], ["spawn_unit_state"])
        self.assertEqual(calculate_range_despawn_unit["params"][0]["schema"], "calculate_range_spawn_unit_result")
        self.assertIn("bulletType", calculate_range_despawn_unit["return_keys"])
        self.assertIn("despawnUnitRangeGatePassed", calculate_range_despawn_unit["return_keys"])
        self.assertIn("returnEarly", calculate_range_despawn_unit["return_keys"])
        self.assertIn("range", calculate_range_despawn_unit["return_keys"])
        self.assertIn("despawnUnit", calculate_range_despawn_unit["return_keys"])
        self.assertIn("despawnUnitReturnSource", calculate_range_despawn_unit["return_keys"])
        self.assertEqual(calculate_range_despawn_unit["source_method"], "calculateRange()")

        calculate_range_fallback = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_calculate_range_fallback_state")
        self.assertEqual([param["name"] for param in calculate_range_fallback["params"]], ["despawn_unit_state"])
        self.assertEqual(calculate_range_fallback["params"][0]["schema"], "calculate_range_despawn_unit_result")
        self.assertIn("bulletType", calculate_range_fallback["return_keys"])
        self.assertIn("fallbackRangeGatePassed", calculate_range_fallback["return_keys"])
        self.assertIn("returnEarly", calculate_range_fallback["return_keys"])
        self.assertIn("range", calculate_range_fallback["return_keys"])
        self.assertIn("fallbackRange", calculate_range_fallback["return_keys"])
        self.assertIn("zeroDrag", calculate_range_fallback["return_keys"])
        self.assertIn("drag", calculate_range_fallback["return_keys"])
        self.assertIn("maxRange", calculate_range_fallback["return_keys"])
        self.assertIn("fallbackReturnSource", calculate_range_fallback["return_keys"])
        self.assertEqual(calculate_range_fallback["source_method"], "calculateRange()")

        continuous_damage_default = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_continuous_damage_default_state")
        self.assertEqual([param["name"] for param in continuous_damage_default["params"]], ["bullet_type_state"])
        self.assertEqual(continuous_damage_default["params"][0]["schema"], "bullet_type_state")
        self.assertIn("bulletType", continuous_damage_default["return_keys"])
        self.assertIn("continuousDamage", continuous_damage_default["return_keys"])
        self.assertIn("continuousDamageReturnSource", continuous_damage_default["return_keys"])
        self.assertEqual(continuous_damage_default["source_method"], "continuousDamage()")

        heals = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_heals_state")
        self.assertEqual([param["name"] for param in heals["params"]], ["bullet_type_state"])
        self.assertEqual(heals["params"][0]["schema"], "bullet_type_state")
        self.assertIn("bulletType", heals["return_keys"])
        self.assertIn("healPercent", heals["return_keys"])
        self.assertIn("healAmount", heals["return_keys"])
        self.assertIn("heals", heals["return_keys"])
        self.assertIn("healsReturnSource", heals["return_keys"])
        self.assertEqual(heals["source_method"], "heals()")

        create_initial_gate = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_initial_gate_state")
        self.assertEqual([param["name"] for param in create_initial_gate["params"]], ["create_call_state", "bullet_type_state", "random_angle_offset", "create_chance_roll"])
        self.assertEqual(create_initial_gate["params"][0]["schema"], "create_call_state")
        self.assertEqual(create_initial_gate["params"][1]["schema"], "bullet_type_state")
        self.assertIn("bulletContinues", create_initial_gate["return_keys"])
        self.assertIn("bulletCreateCalled", create_initial_gate["return_keys"])
        self.assertIn("bulletCreateReturnsNull", create_initial_gate["return_keys"])
        self.assertIn("createChancePassed", create_initial_gate["return_keys"])
        self.assertIn("angle", create_initial_gate["return_keys"])
        self.assertIn("ignoreSpawnAngleApplied", create_initial_gate["return_keys"])
        self.assertIn("spawnUnitReservedSource", create_initial_gate["return_keys"])
        self.assertEqual(create_initial_gate["source_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")

        create_spawn_unit = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_spawn_unit_state")
        self.assertEqual([param["name"] for param in create_spawn_unit["params"]], ["initial_gate_state", "bullet_type_state", "net_client", "owner_health_state", "shooter_state"])
        self.assertEqual(create_spawn_unit["params"][0]["schema"], "create_initial_gate_result")
        self.assertEqual(create_spawn_unit["params"][1]["schema"], "bullet_type_state")
        self.assertEqual(create_spawn_unit["params"][3]["schema"], "owner_health_state")
        self.assertEqual(create_spawn_unit["params"][4]["schema"], "shooter_state")
        self.assertIn("spawnUnitBranchEntered", create_spawn_unit["return_keys"])
        self.assertIn("spawnSkippedClient", create_spawn_unit["return_keys"])
        self.assertIn("spawnedUnit", create_spawn_unit["return_keys"])
        self.assertIn("ownerKilled", create_spawn_unit["return_keys"])
        self.assertIn("bulletCreateReturnsNull", create_spawn_unit["return_keys"])
        self.assertIn("bulletCreationReservedSource", create_spawn_unit["return_keys"])
        self.assertEqual(create_spawn_unit["source_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")

        create_bullet_identity = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_bullet_identity_state")
        self.assertEqual([param["name"] for param in create_bullet_identity["params"]], ["create_call_state", "initial_gate_state", "spawn_unit_state", "bullet_type_state"])
        self.assertEqual(create_bullet_identity["params"][0]["schema"], "create_call_state")
        self.assertEqual(create_bullet_identity["params"][1]["schema"], "create_initial_gate_result")
        self.assertEqual(create_bullet_identity["params"][2]["schema"], "create_spawn_unit_result")
        self.assertEqual(create_bullet_identity["params"][3]["schema"], "bullet_type_state")
        self.assertIn("bulletAllocated", create_bullet_identity["return_keys"])
        self.assertIn("bullet", create_bullet_identity["return_keys"])
        self.assertIn("typeSource", create_bullet_identity["return_keys"])
        self.assertIn("shooterSource", create_bullet_identity["return_keys"])
        self.assertIn("aimTileReservedSource", create_bullet_identity["return_keys"])
        self.assertEqual(create_bullet_identity["source_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")

        create_aim = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_aim_state")
        self.assertEqual([param["name"] for param in create_aim["params"]], ["identity_state", "create_call_state", "target_state", "world_tile_from_aim"])
        self.assertEqual(create_aim["params"][0]["schema"], "create_bullet_identity_result")
        self.assertEqual(create_aim["params"][1]["schema"], "create_call_state")
        self.assertEqual(create_aim["params"][2]["schema"], "target_state")
        self.assertEqual(create_aim["params"][3]["schema"], "world.tileWorld(aimX, aimY)")
        self.assertIn("bulletAimApplied", create_aim["return_keys"])
        self.assertIn("hasAimTile", create_aim["return_keys"])
        self.assertIn("bullet", create_aim["return_keys"])
        self.assertIn("aimTileSource", create_aim["return_keys"])
        self.assertIn("worldTileWorldSource", create_aim["return_keys"])
        self.assertIn("initVelReservedSource", create_aim["return_keys"])
        self.assertEqual(create_aim["source_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")

        create_velocity_position = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_velocity_position_state")
        self.assertEqual([param["name"] for param in create_velocity_position["params"]], ["aim_state", "initial_gate_state", "create_call_state", "bullet_type_state", "velocity_scale_random_factor"])
        self.assertEqual(create_velocity_position["params"][0]["schema"], "create_aim_result")
        self.assertEqual(create_velocity_position["params"][1]["schema"], "create_initial_gate_result")
        self.assertEqual(create_velocity_position["params"][2]["schema"], "create_call_state")
        self.assertEqual(create_velocity_position["params"][3]["schema"], "bullet_type_state")
        self.assertEqual(create_velocity_position["params"][4]["schema"], "Mathf.random(velocityScaleRandMin, velocityScaleRandMax)")
        self.assertIn("bulletVelocityPositionApplied", create_velocity_position["return_keys"])
        self.assertIn("velocityScaleRandMin", create_velocity_position["return_keys"])
        self.assertIn("velocityScaleRandMax", create_velocity_position["return_keys"])
        self.assertIn("velocityScaleRandomFactor", create_velocity_position["return_keys"])
        self.assertIn("velocityRandomMultiplier", create_velocity_position["return_keys"])
        self.assertIn("velocityAmount", create_velocity_position["return_keys"])
        self.assertIn("bullet", create_velocity_position["return_keys"])
        self.assertIn("initVelSource", create_velocity_position["return_keys"])
        self.assertIn("bulletCompInitVelSource", create_velocity_position["return_keys"])
        self.assertIn("setSource", create_velocity_position["return_keys"])
        self.assertIn("lastXSource", create_velocity_position["return_keys"])
        self.assertIn("lastYSource", create_velocity_position["return_keys"])
        self.assertIn("lifetimeReservedSource", create_velocity_position["return_keys"])
        self.assertEqual(create_velocity_position["source_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")

        create_lifetime_payload_damage = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_lifetime_payload_damage_state")
        self.assertEqual([param["name"] for param in create_lifetime_payload_damage["params"]], ["velocity_position_state", "create_call_state", "bullet_type_state", "life_scale_random_factor", "damage_multiplier_factor"])
        self.assertEqual(create_lifetime_payload_damage["params"][0]["schema"], "create_velocity_position_result")
        self.assertEqual(create_lifetime_payload_damage["params"][1]["schema"], "create_call_state")
        self.assertEqual(create_lifetime_payload_damage["params"][2]["schema"], "bullet_type_state")
        self.assertEqual(create_lifetime_payload_damage["params"][3]["schema"], "Mathf.random(lifeScaleRandMin, lifeScaleRandMax)")
        self.assertEqual(create_lifetime_payload_damage["params"][4]["schema"], "bullet.damageMultiplier()")
        self.assertIn("bulletLifetimePayloadDamageApplied", create_lifetime_payload_damage["return_keys"])
        self.assertIn("lifeRandomMultiplier", create_lifetime_payload_damage["return_keys"])
        self.assertIn("lifetimeAmount", create_lifetime_payload_damage["return_keys"])
        self.assertIn("baseDamage", create_lifetime_payload_damage["return_keys"])
        self.assertIn("damageMultiplierFactor", create_lifetime_payload_damage["return_keys"])
        self.assertIn("damageAmount", create_lifetime_payload_damage["return_keys"])
        self.assertIn("bullet", create_lifetime_payload_damage["return_keys"])
        self.assertIn("lifetimeSource", create_lifetime_payload_damage["return_keys"])
        self.assertIn("damageMultiplierSource", create_lifetime_payload_damage["return_keys"])
        self.assertIn("trailClearReservedSource", create_lifetime_payload_damage["return_keys"])
        self.assertIn("addReservedSource", create_lifetime_payload_damage["return_keys"])
        self.assertEqual(create_lifetime_payload_damage["source_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")

        create_trail_add = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_trail_add_state")
        self.assertEqual([param["name"] for param in create_trail_add["params"]], ["lifetime_payload_damage_state"])
        self.assertEqual(create_trail_add["params"][0]["schema"], "create_lifetime_payload_damage_result")
        self.assertIn("bulletTrailAddApplied", create_trail_add["return_keys"])
        self.assertIn("trailCleared", create_trail_add["return_keys"])
        self.assertIn("bulletAdded", create_trail_add["return_keys"])
        self.assertIn("typeInitCalled", create_trail_add["return_keys"])
        self.assertIn("typeInitCall", create_trail_add["return_keys"])
        self.assertIn("bullet", create_trail_add["return_keys"])
        self.assertIn("trailNullGuardSource", create_trail_add["return_keys"])
        self.assertIn("trailClearSource", create_trail_add["return_keys"])
        self.assertIn("trailClearImplSource", create_trail_add["return_keys"])
        self.assertIn("bulletAddSource", create_trail_add["return_keys"])
        self.assertIn("bulletCompAddSource", create_trail_add["return_keys"])
        self.assertIn("keepVelocityReservedSource", create_trail_add["return_keys"])
        self.assertEqual(create_trail_add["source_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")

        create_keep_velocity = source_symbols.api_contract(contracts, "PortGame.source_bullet_type_create_keep_velocity_state")
        self.assertEqual([param["name"] for param in create_keep_velocity["params"]], ["trail_add_state", "bullet_type_state", "owner_state"])
        self.assertEqual(create_keep_velocity["params"][0]["schema"], "create_trail_add_result")
        self.assertEqual(create_keep_velocity["params"][1]["schema"], "bullet_type_state")
        self.assertEqual(create_keep_velocity["params"][2]["schema"], "create_keep_velocity_owner_state")
        self.assertIn("keepVelocityApplied", create_keep_velocity["return_keys"])
        self.assertIn("scaleKeepVelocityApplied", create_keep_velocity["return_keys"])
        self.assertIn("ownerIsVelc", create_keep_velocity["return_keys"])
        self.assertIn("ownerVel", create_keep_velocity["return_keys"])
        self.assertIn("lenBefore", create_keep_velocity["return_keys"])
        self.assertIn("lenAfter", create_keep_velocity["return_keys"])
        self.assertIn("bulletVelBefore", create_keep_velocity["return_keys"])
        self.assertIn("bulletVelAfter", create_keep_velocity["return_keys"])
        self.assertIn("returnedBullet", create_keep_velocity["return_keys"])
        self.assertIn("bullet", create_keep_velocity["return_keys"])
        self.assertIn("keepVelocitySource", create_keep_velocity["return_keys"])
        self.assertIn("vec2LenSource", create_keep_velocity["return_keys"])
        self.assertIn("vec2AddSource", create_keep_velocity["return_keys"])
        self.assertIn("lifetimeScaleSource", create_keep_velocity["return_keys"])
        self.assertIn("returnSource", create_keep_velocity["return_keys"])
        self.assertEqual(create_keep_velocity["source_method"], "create(Entityc owner, Entityc shooter, Team team, float x, float y, float angle, float damage, float velocityScl, float lifetimeScl, Object data, Mover mover, float aimX, float aimY, Teamc target)")

        arc_absin = source_symbols.api_contract(contracts, "PortGame.source_absin")
        self.assertEqual([param["name"] for param in arc_absin["params"]], ["value", "scl", "mag"])
        self.assertEqual(arc_absin["params"][0]["schema"], "source_absin_input.value")
        self.assertEqual(arc_absin["params"][1]["schema"], "source_absin_input.scl")
        self.assertEqual(arc_absin["params"][2]["schema"], "source_absin_input.mag")
        self.assertIn("absin", arc_absin["return_keys"])
        self.assertIn("sinScaled", arc_absin["return_keys"])
        self.assertEqual(arc_absin["source_method"], "absin(float in, float scl, float mag)")

        arc_approach = source_symbols.api_contract(contracts, "PortGame.source_approach")
        self.assertEqual([param["name"] for param in arc_approach["params"]], ["from_value", "to_value", "speed"])
        self.assertEqual(arc_approach["params"][0]["schema"], "source_approach_input.from")
        self.assertEqual(arc_approach["params"][1]["schema"], "source_approach_input.to")
        self.assertEqual(arc_approach["params"][2]["schema"], "source_approach_input.speed")
        self.assertIn("approach", arc_approach["return_keys"])
        self.assertIn("clampedDelta", arc_approach["return_keys"])
        self.assertEqual(arc_approach["source_method"], "approach(float from, float to, float speed)")

        arc_approach_delta = source_symbols.api_contract(contracts, "PortGame.source_approach_delta")
        self.assertEqual([param["name"] for param in arc_approach_delta["params"]], ["from_value", "to_value", "speed", "source_delta"])
        self.assertEqual(arc_approach_delta["params"][0]["schema"], "source_approach_delta_input.from")
        self.assertEqual(arc_approach_delta["params"][1]["schema"], "source_approach_delta_input.to")
        self.assertEqual(arc_approach_delta["params"][2]["schema"], "source_approach_delta_input.speed")
        self.assertEqual(arc_approach_delta["params"][3]["schema"], "source_approach_delta_input.sourceDelta")
        self.assertIn("scaledSpeed", arc_approach_delta["return_keys"])
        self.assertIn("approachDelta", arc_approach_delta["return_keys"])
        self.assertEqual(arc_approach_delta["source_method"], "approachDelta(float from, float to, float speed)")

        arc_angles_angle = source_symbols.api_contract(contracts, "PortGame.source_arc_angles_angle")
        self.assertEqual([param["name"] for param in arc_angles_angle["params"]], ["from_x", "from_y", "to_x", "to_y"])
        self.assertEqual(arc_angles_angle["params"][0]["schema"], "source_arc_angles_angle_input.fromX")
        self.assertEqual(arc_angles_angle["params"][1]["schema"], "source_arc_angles_angle_input.fromY")
        self.assertEqual(arc_angles_angle["params"][2]["schema"], "source_arc_angles_angle_input.toX")
        self.assertEqual(arc_angles_angle["params"][3]["schema"], "source_arc_angles_angle_input.toY")
        self.assertIn("angle", arc_angles_angle["return_keys"])
        self.assertIn("rawAngle", arc_angles_angle["return_keys"])
        self.assertEqual(arc_angles_angle["source_method"], "angle(float x, float y, float x2, float y2)")

        arc_angles_angle_dist = source_symbols.api_contract(contracts, "PortGame.source_arc_angles_angle_dist")
        self.assertEqual([param["name"] for param in arc_angles_angle_dist["params"]], ["angle_a", "angle_b"])
        self.assertEqual(arc_angles_angle_dist["params"][0]["schema"], "source_arc_angles_angle_dist_input.angleA")
        self.assertEqual(arc_angles_angle_dist["params"][1]["schema"], "source_arc_angles_angle_dist_input.angleB")
        self.assertIn("angleAMod", arc_angles_angle_dist["return_keys"])
        self.assertIn("angleBMod", arc_angles_angle_dist["return_keys"])
        self.assertIn("angleDistance", arc_angles_angle_dist["return_keys"])
        self.assertEqual(arc_angles_angle_dist["source_method"], "angleDist(float a, float b)")

        arc_angles_backward_distance = source_symbols.api_contract(contracts, "PortGame.source_arc_angles_backward_distance")
        self.assertEqual([param["name"] for param in arc_angles_backward_distance["params"]], ["angle1", "angle2"])
        self.assertEqual(arc_angles_backward_distance["params"][0]["schema"], "source_arc_angles_backward_distance_input.angle1")
        self.assertEqual(arc_angles_backward_distance["params"][1]["schema"], "source_arc_angles_backward_distance_input.angle2")
        self.assertIn("backwardDistance", arc_angles_backward_distance["return_keys"])
        self.assertEqual(arc_angles_backward_distance["source_method"], "backwardDistance(float angle1, float angle2)")

        arc_angles_forward_distance = source_symbols.api_contract(contracts, "PortGame.source_arc_angles_forward_distance")
        self.assertEqual([param["name"] for param in arc_angles_forward_distance["params"]], ["angle1", "angle2"])
        self.assertEqual(arc_angles_forward_distance["params"][0]["schema"], "source_arc_angles_forward_distance_input.angle1")
        self.assertEqual(arc_angles_forward_distance["params"][1]["schema"], "source_arc_angles_forward_distance_input.angle2")
        self.assertIn("forwardDistance", arc_angles_forward_distance["return_keys"])
        self.assertEqual(arc_angles_forward_distance["source_method"], "forwardDistance(float angle1, float angle2)")

        arc_angles_move_toward = source_symbols.api_contract(contracts, "PortGame.source_arc_angles_move_toward")
        self.assertEqual([param["name"] for param in arc_angles_move_toward["params"]], ["angle", "to", "speed"])
        self.assertEqual(arc_angles_move_toward["params"][0]["schema"], "source_arc_angles_move_toward_input.angle")
        self.assertEqual(arc_angles_move_toward["params"][1]["schema"], "source_arc_angles_move_toward_input.to")
        self.assertEqual(arc_angles_move_toward["params"][2]["schema"], "source_arc_angles_move_toward_input.speed")
        self.assertIn("moveToward", arc_angles_move_toward["return_keys"])
        self.assertIn("turnBackward", arc_angles_move_toward["return_keys"])
        self.assertEqual(arc_angles_move_toward["source_method"], "moveToward(float angle, float to, float speed)")

        arc_angles_trns_vec = source_symbols.api_contract(contracts, "PortGame.source_arc_angles_trns_vec")
        self.assertEqual([param["name"] for param in arc_angles_trns_vec["params"]], ["angle_degrees", "x_value", "y_value"])
        self.assertEqual(arc_angles_trns_vec["params"][0]["schema"], "source_arc_angles_trns_vec_input.angleDegrees")
        self.assertEqual(arc_angles_trns_vec["params"][1]["schema"], "source_arc_angles_trns_vec_input.x")
        self.assertEqual(arc_angles_trns_vec["params"][2]["schema"], "source_arc_angles_trns_vec_input.y")
        self.assertIn("x", arc_angles_trns_vec["return_keys"])
        self.assertIn("y", arc_angles_trns_vec["return_keys"])
        self.assertIn("vec2RotateSource", arc_angles_trns_vec["return_keys"])
        self.assertEqual(arc_angles_trns_vec["source_method"], "trnsx/trnsy(float angle, float x, float y)")

        arc_chance_delta_threshold = source_symbols.api_contract(contracts, "PortGame.source_arc_chance_delta_threshold")
        self.assertEqual([param["name"] for param in arc_chance_delta_threshold["params"]], ["chance", "source_delta"])
        self.assertEqual(arc_chance_delta_threshold["params"][0]["schema"], "source_arc_chance_delta_threshold_input.chance")
        self.assertEqual(arc_chance_delta_threshold["params"][1]["schema"], "source_arc_chance_delta_threshold_input.sourceDelta")
        self.assertIn("threshold", arc_chance_delta_threshold["return_keys"])
        self.assertEqual(arc_chance_delta_threshold["source_method"], "chanceDelta(double d)")

        arc_is_power_of_two = source_symbols.api_contract(contracts, "PortGame.source_arc_is_power_of_two")
        self.assertEqual([param["name"] for param in arc_is_power_of_two["params"]], ["value"])
        self.assertEqual(arc_is_power_of_two["params"][0]["schema"], "source_arc_is_power_of_two_input.value")
        self.assertIn("isPowerOfTwo", arc_is_power_of_two["return_keys"])
        self.assertIn("bitTest", arc_is_power_of_two["return_keys"])
        self.assertEqual(arc_is_power_of_two["source_method"], "isPowerOfTwo(int value)")

        arc_lerp_delta = source_symbols.api_contract(contracts, "PortGame.source_arc_lerp_delta")
        self.assertEqual([param["name"] for param in arc_lerp_delta["params"]], ["from_value", "to_value", "progress", "source_delta"])
        self.assertEqual(arc_lerp_delta["params"][0]["schema"], "source_arc_lerp_delta_input.fromValue")
        self.assertEqual(arc_lerp_delta["params"][3]["schema"], "source_arc_lerp_delta_input.sourceDelta")
        self.assertIn("clampedProgress", arc_lerp_delta["return_keys"])
        self.assertIn("lerpDelta", arc_lerp_delta["return_keys"])
        self.assertEqual(arc_lerp_delta["source_method"], "lerpDelta(float fromValue, float toValue, float progress)")

        arc_mathf_cos_lookup = source_symbols.api_contract(contracts, "PortGame.source_arc_mathf_cos_lookup")
        self.assertEqual([param["name"] for param in arc_mathf_cos_lookup["params"]], ["radians"])
        self.assertEqual(arc_mathf_cos_lookup["params"][0]["schema"], "source_arc_mathf_cos_lookup_input.radians")
        self.assertIn("index", arc_mathf_cos_lookup["return_keys"])
        self.assertIn("cos", arc_mathf_cos_lookup["return_keys"])
        self.assertEqual(arc_mathf_cos_lookup["source_method"], "cos(float radians)")

        arc_mathf_sin_lookup = source_symbols.api_contract(contracts, "PortGame.source_arc_mathf_sin_lookup")
        self.assertEqual([param["name"] for param in arc_mathf_sin_lookup["params"]], ["radians"])
        self.assertEqual(arc_mathf_sin_lookup["params"][0]["schema"], "source_arc_mathf_sin_lookup_input.radians")
        self.assertIn("index", arc_mathf_sin_lookup["return_keys"])
        self.assertIn("sin", arc_mathf_sin_lookup["return_keys"])
        self.assertEqual(arc_mathf_sin_lookup["source_method"], "sin(float radians)")

        arc_mathf_sin_scaled = source_symbols.api_contract(contracts, "PortGame.source_arc_mathf_sin_scaled")
        self.assertEqual([param["name"] for param in arc_mathf_sin_scaled["params"]], ["radians", "scl", "mag"])
        self.assertEqual(arc_mathf_sin_scaled["params"][0]["schema"], "source_arc_mathf_sin_scaled_input.radians")
        self.assertEqual(arc_mathf_sin_scaled["params"][2]["schema"], "source_arc_mathf_sin_scaled_input.mag")
        self.assertIn("scaledRadians", arc_mathf_sin_scaled["return_keys"])
        self.assertIn("sinScaled", arc_mathf_sin_scaled["return_keys"])
        self.assertEqual(arc_mathf_sin_scaled["source_method"], "sin(float radians, float scl, float mag)")

        arc_mathf_sin_table_value = source_symbols.api_contract(contracts, "PortGame.source_arc_mathf_sin_table_value")
        self.assertEqual([param["name"] for param in arc_mathf_sin_table_value["params"]], ["index"])
        self.assertEqual(arc_mathf_sin_table_value["params"][0]["schema"], "source_arc_mathf_sin_table_value_input.index")
        self.assertIn("tableValue", arc_mathf_sin_table_value["return_keys"])
        self.assertIn("cardinalNinety", arc_mathf_sin_table_value["return_keys"])
        self.assertEqual(arc_mathf_sin_table_value["source_method"], "static sinTable initializer")

        arc_random_seed_float_max = source_symbols.api_contract(contracts, "PortGame.source_arc_random_seed_float_max")
        self.assertEqual([param["name"] for param in arc_random_seed_float_max["params"]], ["source_seed", "max_value"])
        self.assertEqual(arc_random_seed_float_max["params"][0]["schema"], "source_arc_random_seed_float_max_input.seed")
        self.assertEqual(arc_random_seed_float_max["params"][1]["schema"], "source_arc_random_seed_float_max_input.max")
        self.assertIn("scaledSeed", arc_random_seed_float_max["return_keys"])
        self.assertIn("randomSeed", arc_random_seed_float_max["return_keys"])
        self.assertEqual(arc_random_seed_float_max["source_method"], "randomSeed(long seed, float max)")

        arc_random_seed_int = source_symbols.api_contract(contracts, "PortGame.source_arc_random_seed_int")
        self.assertEqual([param["name"] for param in arc_random_seed_int["params"]], ["source_seed", "min_value", "max_value"])
        self.assertEqual(arc_random_seed_int["params"][0]["schema"], "source_arc_random_seed_int_input.seed")
        self.assertEqual(arc_random_seed_int["params"][1]["schema"], "source_arc_random_seed_int_input.min")
        self.assertEqual(arc_random_seed_int["params"][2]["schema"], "source_arc_random_seed_int_input.max")
        self.assertIn("powerOfTwoGate", arc_random_seed_int["return_keys"])
        self.assertIn("randomSeed", arc_random_seed_int["return_keys"])
        self.assertEqual(arc_random_seed_int["source_method"], "randomSeed(long seed, int min, int max)")

        arc_strings_fixed_one_decimal = source_symbols.api_contract(contracts, "PortGame.source_arc_strings_fixed_one_decimal")
        self.assertEqual([param["name"] for param in arc_strings_fixed_one_decimal["params"]], ["value"])
        self.assertEqual(arc_strings_fixed_one_decimal["params"][0]["schema"], "source_arc_strings_fixed_one_decimal_input.value")
        self.assertIn("decimalPlaces", arc_strings_fixed_one_decimal["return_keys"])
        self.assertIn("fixed", arc_strings_fixed_one_decimal["return_keys"])
        self.assertEqual(arc_strings_fixed_one_decimal["source_method"], "fixed(float d, int decimalPlaces)")

        arc_vec2_limit = source_symbols.api_contract(contracts, "PortGame.source_arc_vec2_limit")
        self.assertEqual([param["name"] for param in arc_vec2_limit["params"]], ["vec", "limit"])
        self.assertEqual(arc_vec2_limit["params"][0]["schema"], "source_arc_vec2_limit_input.vec")
        self.assertEqual(arc_vec2_limit["params"][1]["schema"], "source_arc_vec2_limit_input.limit")
        self.assertIn("limit2", arc_vec2_limit["return_keys"])
        self.assertIn("scale", arc_vec2_limit["return_keys"])
        self.assertEqual(arc_vec2_limit["source_method"], "limit(float limit)")

        block_can_replace = source_symbols.api_contract(contracts, "PortGame.source_block_can_replace_state")
        self.assertEqual([param["name"] for param in block_can_replace["params"]], ["existing_always_replace", "existing_privileged", "existing_replaceable", "same_block", "new_rotate", "new_quick_rotate", "new_group_is_none", "same_group", "new_size", "existing_size", "same_subclass", "group_any_replace"])
        self.assertEqual(block_can_replace["params"][0]["schema"], "source_block_can_replace_input.otherAlwaysReplace")
        self.assertEqual(block_can_replace["params"][11]["schema"], "source_block_can_replace_input.groupAnyReplace")
        self.assertIn("replacementGate", block_can_replace["return_keys"])
        self.assertIn("sizeGate", block_can_replace["return_keys"])
        self.assertEqual(block_can_replace["source_method"], "canReplace(Block other)")

        block_dump_time = source_symbols.api_contract(contracts, "PortGame.source_block_dump_time")
        self.assertEqual([param["name"] for param in block_dump_time["params"]], ["block_id"])
        self.assertEqual(block_dump_time["params"][0]["schema"], "source_block_dump_time_input.blockId")
        self.assertIn("dumpTime", block_dump_time["return_keys"])
        self.assertIn("defaultDumpTime", block_dump_time["return_keys"])
        self.assertEqual(block_dump_time["source_method"], "field declaration")

        block_health = source_symbols.api_contract(contracts, "PortGame.source_block_health")
        self.assertEqual([param["name"] for param in block_health["params"]], ["block_id"])
        self.assertEqual(block_health["params"][0]["schema"], "source_block_health_input.blockId")
        self.assertIn("health", block_health["return_keys"])
        self.assertIn("scaledHealth", block_health["return_keys"])
        self.assertEqual(block_health["source_method"], "init()")

        block_health_at_cell = source_symbols.api_contract(contracts, "PortGame.source_block_health_at_cell")
        self.assertEqual([param["name"] for param in block_health_at_cell["params"]], ["x", "y"])
        self.assertEqual(block_health_at_cell["params"][0]["schema"], "source_block_health_at_cell_input.x")
        self.assertEqual(block_health_at_cell["params"][1]["schema"], "source_block_health_at_cell_input.y")
        self.assertIn("health", block_health_at_cell["return_keys"])
        self.assertIn("senseHealth", block_health_at_cell["return_keys"])
        self.assertEqual(block_health_at_cell["source_method"], "create(Block block, Team team)")

        block_is_damaged = source_symbols.api_contract(contracts, "PortGame.source_block_is_damaged")
        self.assertEqual([param["name"] for param in block_is_damaged["params"]], ["sprite"])
        self.assertEqual(block_is_damaged["params"][0]["schema"], "source_block_is_damaged_input.sprite")
        self.assertIn("damaged", block_is_damaged["return_keys"])
        self.assertIn("epsilon", block_is_damaged["return_keys"])
        self.assertEqual(block_is_damaged["source_method"], "damaged()")

        block_item_capacity = source_symbols.api_contract(contracts, "PortGame.source_block_item_capacity")
        self.assertEqual([param["name"] for param in block_item_capacity["params"]], ["block_id"])
        self.assertEqual(block_item_capacity["params"][0]["schema"], "source_block_item_capacity_input.blockId")
        self.assertIn("itemCapacity", block_item_capacity["return_keys"])
        self.assertIn("buildingSenseItemCapacity", block_item_capacity["return_keys"])
        self.assertEqual(block_item_capacity["source_method"], "field declaration")

        block_sprite_base_position = source_symbols.api_contract(contracts, "PortGame.source_block_sprite_base_position")
        self.assertEqual([param["name"] for param in block_sprite_base_position["params"]], ["block", "cell"])
        self.assertEqual(block_sprite_base_position["params"][1]["schema"], "source_block_sprite_base_position_input.cell")
        self.assertIn("drawX", block_sprite_base_position["return_keys"])
        self.assertIn("offset", block_sprite_base_position["return_keys"])
        self.assertEqual(block_sprite_base_position["source_method"], "create(Block block, Team team)")

        block_time_scale_at_cell = source_symbols.api_contract(contracts, "PortGame.source_block_time_scale_at_cell")
        self.assertEqual([param["name"] for param in block_time_scale_at_cell["params"]], ["x", "y"])
        self.assertEqual(block_time_scale_at_cell["params"][0]["schema"], "source_block_time_scale_at_cell_input.x")
        self.assertIn("timeScale", block_time_scale_at_cell["return_keys"])
        self.assertIn("senseTimeScale", block_time_scale_at_cell["return_keys"])
        self.assertEqual(block_time_scale_at_cell["source_method"], "timeScale()")

        block_time_scale_duration_at_cell = source_symbols.api_contract(contracts, "PortGame.source_block_time_scale_duration_at_cell")
        self.assertEqual([param["name"] for param in block_time_scale_duration_at_cell["params"]], ["x", "y"])
        self.assertEqual(block_time_scale_duration_at_cell["params"][1]["schema"], "source_block_time_scale_duration_at_cell_input.y")
        self.assertIn("timeScaleDuration", block_time_scale_duration_at_cell["return_keys"])
        self.assertIn("writeDuration", block_time_scale_duration_at_cell["return_keys"])
        self.assertIn("decayGate", block_time_scale_duration_at_cell["return_keys"])
        self.assertEqual(block_time_scale_duration_at_cell["source_method"], "field/read/write/update/apply duration state")

        building_absorb_lasers = source_symbols.api_contract(contracts, "PortGame.source_building_absorb_lasers_state")
        self.assertEqual([param["name"] for param in building_absorb_lasers["params"]], ["block_absorb_lasers"])
        self.assertEqual(building_absorb_lasers["params"][0]["schema"], "source_building_absorb_lasers_input.blockAbsorbLasers")
        self.assertIn("absorbLasers", building_absorb_lasers["return_keys"])
        self.assertIn("defaultAbsorbLasers", building_absorb_lasers["return_keys"])
        self.assertEqual(building_absorb_lasers["source_method"], "absorbLasers()")

        building_accept_item = source_symbols.api_contract(contracts, "PortGame.source_building_accept_item_state")
        self.assertEqual([param["name"] for param in building_accept_item["params"]], ["consumes_item", "item_count", "maximum_accepted"])
        self.assertEqual(building_accept_item["params"][0]["schema"], "source_building_accept_item_input.consumesItem")
        self.assertEqual(building_accept_item["params"][1]["schema"], "source_building_accept_item_input.itemCount")
        self.assertEqual(building_accept_item["params"][2]["schema"], "source_building_accept_item_input.maximumAccepted")
        self.assertIn("acceptItem", building_accept_item["return_keys"])
        self.assertEqual(building_accept_item["source_method"], "acceptItem(Building source, Item item)")

        building_accept_liquid = source_symbols.api_contract(contracts, "PortGame.source_building_accept_liquid_state")
        self.assertEqual([param["name"] for param in building_accept_liquid["params"]], ["has_liquids", "consumes_liquid"])
        self.assertEqual(building_accept_liquid["params"][0]["schema"], "source_building_accept_liquid_input.hasLiquids")
        self.assertEqual(building_accept_liquid["params"][1]["schema"], "source_building_accept_liquid_input.consumesLiquid")
        self.assertIn("acceptLiquid", building_accept_liquid["return_keys"])
        self.assertEqual(building_accept_liquid["source_method"], "acceptLiquid(Building source, Liquid liquid)")

        building_accept_payload = source_symbols.api_contract(contracts, "PortGame.source_building_accept_payload_state")
        self.assertEqual(building_accept_payload["params"], [])
        self.assertIn("acceptPayload", building_accept_payload["return_keys"])
        self.assertEqual(building_accept_payload["source_method"], "acceptPayload(Building source, Payload payload)")

        building_accept_stack = source_symbols.api_contract(contracts, "PortGame.source_building_accept_stack_state")
        self.assertEqual([param["name"] for param in building_accept_stack["params"]], ["accepts_item", "has_items", "same_team_or_null_source", "maximum_accepted", "item_count", "amount"])
        self.assertEqual(building_accept_stack["params"][0]["schema"], "source_building_accept_stack_input.acceptsItem")
        self.assertEqual(building_accept_stack["params"][5]["schema"], "source_building_accept_stack_input.amount")
        self.assertIn("acceptStack", building_accept_stack["return_keys"])
        self.assertIn("fallback", building_accept_stack["return_keys"])
        self.assertEqual(building_accept_stack["source_method"], "acceptStack(Item item, int amount, Teamc source)")

        building_after_destroyed = source_symbols.api_contract(contracts, "PortGame.source_building_after_destroyed_state")
        self.assertEqual([param["name"] for param in building_after_destroyed["params"]], ["has_destroy_bullet", "destroy_bullet_same_team", "team_id", "source_x", "source_y", "building_id"])
        self.assertEqual(building_after_destroyed["params"][0]["schema"], "source_building_after_destroyed_input.hasDestroyBullet")
        self.assertEqual(building_after_destroyed["params"][5]["schema"], "source_building_after_destroyed_input.buildingId")
        self.assertIn("createBullet", building_after_destroyed["return_keys"])
        self.assertIn("rotation", building_after_destroyed["return_keys"])
        self.assertEqual(building_after_destroyed["source_method"], "afterDestroyed()")

        building_after_picked_up = source_symbols.api_contract(contracts, "PortGame.source_building_after_picked_up_state")
        self.assertEqual([param["name"] for param in building_after_picked_up["params"]], ["power_present", "has_cons_power", "cons_power_buffered", "current_status"])
        self.assertEqual(building_after_picked_up["params"][0]["schema"], "source_building_after_picked_up_input.powerPresent")
        self.assertEqual(building_after_picked_up["params"][3]["schema"], "source_building_after_picked_up_input.currentStatus")
        self.assertIn("newPowerGraph", building_after_picked_up["return_keys"])
        self.assertIn("clearLinks", building_after_picked_up["return_keys"])
        self.assertIn("status", building_after_picked_up["return_keys"])
        self.assertEqual(building_after_picked_up["source_method"], "afterPickedUp()")

        building_ambient_volume = source_symbols.api_contract(contracts, "PortGame.source_building_ambient_volume")
        self.assertEqual([param["name"] for param in building_ambient_volume["params"]], ["efficiency"])
        self.assertEqual(building_ambient_volume["params"][0]["schema"], "source_building_ambient_volume_input.efficiency")
        self.assertIn("ambientVolume", building_ambient_volume["return_keys"])
        self.assertEqual(building_ambient_volume["source_method"], "ambientVolume()")

        building_apply_boost = source_symbols.api_contract(contracts, "PortGame.source_building_apply_boost_state")
        self.assertEqual([param["name"] for param in building_apply_boost["params"]], ["current_time_scale", "current_duration", "intensity", "duration", "can_overdrive"])
        self.assertEqual(building_apply_boost["params"][0]["schema"], "source_building_apply_boost_input.currentTimeScale")
        self.assertEqual(building_apply_boost["params"][4]["schema"], "source_building_apply_boost_input.canOverdrive")
        self.assertIn("timeScale", building_apply_boost["return_keys"])
        self.assertIn("timeScaleDuration", building_apply_boost["return_keys"])
        self.assertEqual(building_apply_boost["source_method"], "applyBoost(float intensity, float duration)")

        building_block_half_extent = source_symbols.api_contract(contracts, "PortGame.source_building_block_half_extent")
        self.assertEqual([param["name"] for param in building_block_half_extent["params"]], ["block_size_value", "source_tilesize"])
        self.assertEqual(building_block_half_extent["params"][0]["schema"], "source_building_block_half_extent_input.blockSize")
        self.assertEqual(building_block_half_extent["params"][1]["schema"], "source_building_block_half_extent_input.tilesize")
        self.assertIn("halfExtent", building_block_half_extent["return_keys"])
        self.assertEqual(building_block_half_extent["source_method"], "drawConfigure()")

        building_bullet_damage = source_symbols.api_contract(contracts, "PortGame.source_building_bullet_damage_state")
        self.assertEqual([param["name"] for param in building_bullet_damage["params"]], ["bullet", "source_team", "damage_amount"])
        self.assertEqual(building_bullet_damage["params"][0]["schema"], "source_building_bullet_damage_input.bullet")
        self.assertEqual(building_bullet_damage["params"][2]["schema"], "source_building_bullet_damage_input.damage")
        self.assertIn("delegatesToSourceDamage", building_bullet_damage["return_keys"])
        self.assertIn("firesBulletDamageEvent", building_bullet_damage["return_keys"])
        self.assertEqual(building_bullet_damage["source_method"], "damage(Bullet bullet, Team source, float damage)")

        building_can_be_replaced = source_symbols.api_contract(contracts, "PortGame.source_building_can_be_replaced_state")
        self.assertEqual([param["name"] for param in building_can_be_replaced["params"]], ["other_can_replace_block"])
        self.assertEqual(building_can_be_replaced["params"][0]["schema"], "source_building_can_be_replaced_input.otherCanReplaceBlock")
        self.assertIn("canBeReplaced", building_can_be_replaced["return_keys"])
        self.assertEqual(building_can_be_replaced["source_method"], "canBeReplaced(Block other)")

        building_can_consume = source_symbols.api_contract(contracts, "PortGame.source_building_can_consume_state")
        self.assertEqual([param["name"] for param in building_can_consume["params"]], ["potential_efficiency"])
        self.assertEqual(building_can_consume["params"][0]["schema"], "source_building_can_consume_input.potentialEfficiency")
        self.assertIn("canConsume", building_can_consume["return_keys"])
        self.assertEqual(building_can_consume["source_method"], "canConsume()")

        building_can_pickup = source_symbols.api_contract(contracts, "PortGame.source_building_can_pickup_state")
        self.assertEqual([param["name"] for param in building_can_pickup["params"]], ["block_can_pickup"])
        self.assertEqual(building_can_pickup["params"][0]["schema"], "source_building_can_pickup_input.blockCanPickup")
        self.assertIn("canPickup", building_can_pickup["return_keys"])
        self.assertEqual(building_can_pickup["source_method"], "canPickup()")

        building_change_team_delegate = source_symbols.api_contract(contracts, "PortGame.source_building_change_team_delegate_state")
        self.assertEqual([param["name"] for param in building_change_team_delegate["params"]], ["next_team"])
        self.assertEqual(building_change_team_delegate["params"][0]["schema"], "source_building_change_team_delegate_input.next_team")
        self.assertIn("delegates_to_change_team", building_change_team_delegate["return_keys"])
        self.assertIn("update_power", building_change_team_delegate["return_keys"])
        self.assertEqual(building_change_team_delegate["source_method"], "changeTeam(Team next)")

        building_change_team_final = source_symbols.api_contract(contracts, "PortGame.source_building_change_team_final_state")
        self.assertEqual([param["name"] for param in building_change_team_final["params"]], ["was", "last_team"])
        self.assertEqual(building_change_team_final["params"][1]["schema"], "source_building_change_team_final_input.last_team")
        self.assertIn("team_change_event", building_change_team_final["return_keys"])
        self.assertIn("check_allow_update", building_change_team_final["return_keys"])
        self.assertEqual(building_change_team_final["source_method"], "changeTeam(Team next, boolean updatePower)")

        building_change_team_initial = source_symbols.api_contract(contracts, "PortGame.source_building_change_team_initial_state")
        self.assertEqual([param["name"] for param in building_change_team_initial["params"]], ["current_team", "next_team", "force_team", "was_valid"])
        self.assertEqual(building_change_team_initial["params"][0]["schema"], "source_building_change_team_initial_input.current_team")
        self.assertEqual(building_change_team_initial["params"][3]["schema"], "source_building_change_team_initial_input.was_valid")
        self.assertIn("remove_index", building_change_team_initial["return_keys"])
        self.assertIn("assign_next", building_change_team_initial["return_keys"])
        self.assertEqual(building_change_team_initial["source_method"], "changeTeam(Team next, boolean updatePower)")

        building_change_team_power_links = source_symbols.api_contract(contracts, "PortGame.source_building_change_team_power_links_state")
        self.assertEqual([param["name"] for param in building_change_team_power_links["params"]], ["link_count", "team", "old_graph"])
        self.assertEqual(building_change_team_power_links["params"][0]["schema"], "source_building_change_team_power_links_input.link_count")
        self.assertEqual(building_change_team_power_links["params"][2]["schema"], "source_building_change_team_power_links_input.old_graph")
        self.assertIn("remove_index", building_change_team_power_links["return_keys"])
        self.assertIn("update_power_graph", building_change_team_power_links["return_keys"])
        self.assertEqual(building_change_team_power_links["source_method"], "changeTeam(Team next, boolean updatePower)")

        building_change_team_power_proximity = source_symbols.api_contract(contracts, "PortGame.source_building_change_team_power_proximity_state")
        self.assertEqual([param["name"] for param in building_change_team_power_proximity["params"]], ["power_present", "update_power", "old_graph", "team"])
        self.assertEqual(building_change_team_power_proximity["params"][0]["schema"], "source_building_change_team_power_proximity_input.power_present")
        self.assertEqual(building_change_team_power_proximity["params"][2]["schema"], "source_building_change_team_power_proximity_input.old_graph")
        self.assertIn("proximity_reflow", building_change_team_power_proximity["return_keys"])
        self.assertEqual(building_change_team_power_proximity["source_method"], "changeTeam(Team next, boolean updatePower)")

        building_check_allow_update = source_symbols.api_contract(contracts, "PortGame.source_building_check_allow_update_state")
        self.assertEqual([param["name"] for param in building_check_allow_update["params"]], ["current_enabled", "allow_update_result"])
        self.assertEqual(building_check_allow_update["params"][0]["schema"], "source_building_check_allow_update_input.current_enabled")
        self.assertEqual(building_check_allow_update["params"][1]["schema"], "source_building_check_allow_update_input.allow_update_result")
        self.assertIn("enabled", building_check_allow_update["return_keys"])
        self.assertIn("changed", building_check_allow_update["return_keys"])
        self.assertEqual(building_check_allow_update["source_method"], "checkAllowUpdate()")

        building_check_solid = source_symbols.api_contract(contracts, "PortGame.source_building_check_solid_state")
        self.assertEqual([param["name"] for param in building_check_solid["params"]], [])
        self.assertIn("checkSolid", building_check_solid["return_keys"])
        self.assertEqual(building_check_solid["source_method"], "checkSolid()")

        building_check_suppression = source_symbols.api_contract(contracts, "PortGame.source_building_check_suppression_state")
        self.assertEqual([param["name"] for param in building_check_suppression["params"]], ["block_suppressable", "source_time", "heal_suppression_time", "source_delta", "source_x", "source_y", "block_size_value", "source_tilesize", "suppress_color"])
        self.assertEqual(building_check_suppression["params"][0]["schema"], "source_building_check_suppression_input.block_suppressable")
        self.assertEqual(building_check_suppression["params"][2]["schema"], "source_building_check_suppression_input.heal_suppression_time")
        self.assertIn("suppressed", building_check_suppression["return_keys"])
        self.assertIn("chance_threshold", building_check_suppression["return_keys"])
        self.assertIn("particle_range", building_check_suppression["return_keys"])
        self.assertEqual(building_check_suppression["source_method"], "checkSuppression()")

        building_collide = source_symbols.api_contract(contracts, "PortGame.source_building_collide_state")
        self.assertEqual([param["name"] for param in building_collide["params"]], ["_other"])
        self.assertEqual(building_collide["params"][0]["schema"], "source_building_collide_input.other")
        self.assertIn("collide", building_collide["return_keys"])
        self.assertEqual(building_collide["source_method"], "collide(Bullet other)")

        building_collision_damage = source_symbols.api_contract(contracts, "PortGame.source_building_collision_damage_state")
        self.assertEqual([param["name"] for param in building_collision_damage["params"]], [
            "current_health",
            "bullet_building_damage",
            "block_armor",
            "bullet_pierce_armor",
            "bullet_armor_multiplier",
            "bullet_block_armor_multiplier",
        ])
        self.assertEqual(building_collision_damage["params"][0]["schema"], "source_building_collision_damage_input.current_health")
        self.assertEqual(building_collision_damage["params"][3]["schema"], "source_building_collision_damage_input.bullet_pierce_armor")
        self.assertIn("damage", building_collision_damage["return_keys"])
        self.assertIn("removed", building_collision_damage["return_keys"])
        self.assertEqual(building_collision_damage["source_method"], "collision(Bullet other)")

        building_config_default = source_symbols.api_contract(contracts, "PortGame.source_building_config_default")
        self.assertEqual([param["name"] for param in building_config_default["params"]], [])
        self.assertIn("config", building_config_default["return_keys"])
        self.assertEqual(building_config_default["source_method"], "config()")

        building_configure_menu_visibility = source_symbols.api_contract(contracts, "PortGame.source_building_configure_menu_visibility_state")
        self.assertEqual([param["name"] for param in building_configure_menu_visibility["params"]], ["_player"])
        self.assertEqual(building_configure_menu_visibility["params"][0]["schema"], "source_building_configure_menu_visibility_input.player")
        self.assertIn("should_show", building_configure_menu_visibility["return_keys"])
        self.assertIn("should_hide", building_configure_menu_visibility["return_keys"])
        self.assertEqual(building_configure_menu_visibility["source_method"], "shouldShowConfigure(Player player) / shouldHideConfigure(Player player)")

        building_configured_copy_config = source_symbols.api_contract(contracts, "PortGame.source_building_configured_copy_config_state")
        self.assertEqual([param["name"] for param in building_configured_copy_config["params"]], ["value_is_building", "copied_config", "copied_config_is_building"])
        self.assertEqual(building_configured_copy_config["params"][0]["schema"], "source_building_configured_copy_config_input.value_is_building")
        self.assertEqual(building_configured_copy_config["params"][1]["schema"], "source_building_configured_copy_config_input.copied_config")
        self.assertIn("copy_branch", building_configured_copy_config["return_keys"])
        self.assertIn("recurse", building_configured_copy_config["return_keys"])
        self.assertIn("config", building_configured_copy_config["return_keys"])
        self.assertEqual(building_configured_copy_config["source_method"], "configured(@Nullable Unit builder, @Nullable Object value)")

        building_configured_direct_handler = source_symbols.api_contract(contracts, "PortGame.source_building_configured_direct_handler_state")
        self.assertEqual([param["name"] for param in building_configured_direct_handler["params"]], ["has_configuration", "configured_type", "value_state"])
        self.assertEqual(building_configured_direct_handler["params"][0]["schema"], "source_building_configured_direct_handler_input.has_configuration")
        self.assertEqual(building_configured_direct_handler["params"][2]["schema"], "source_building_configured_direct_handler_input.value_state")
        self.assertIn("handled", building_configured_direct_handler["return_keys"])
        self.assertIn("handler_type", building_configured_direct_handler["return_keys"])
        self.assertIn("value", building_configured_direct_handler["return_keys"])
        self.assertEqual(building_configured_direct_handler["source_method"], "configured(@Nullable Unit builder, @Nullable Object value)")

        building_configured_last_access = source_symbols.api_contract(contracts, "PortGame.source_building_configured_last_access_state")
        self.assertEqual([param["name"] for param in building_configured_last_access["params"]], ["builder_state", "current_last_accessed"])
        self.assertEqual(building_configured_last_access["params"][0]["schema"], "source_building_configured_last_access_input.builder_state")
        self.assertEqual(building_configured_last_access["params"][1]["schema"], "source_building_configured_last_access_input.current_last_accessed")
        self.assertIn("last_accessed", building_configured_last_access["return_keys"])
        self.assertIn("updated", building_configured_last_access["return_keys"])
        self.assertEqual(building_configured_last_access["source_method"], "configured(@Nullable Unit builder, @Nullable Object value) / updateLastAccess(Player player)")

        building_configured_type = source_symbols.api_contract(contracts, "PortGame.source_building_configured_type_state")
        self.assertEqual([param["name"] for param in building_configured_type["params"]], ["value_state"])
        self.assertEqual(building_configured_type["params"][0]["schema"], "source_building_configured_type_input.value_state")
        self.assertIn("type_name", building_configured_type["return_keys"])
        self.assertEqual(building_configured_type["source_method"], "configured(@Nullable Unit builder, @Nullable Object value)")

        building_consume = source_symbols.api_contract(contracts, "PortGame.source_building_consume_state")
        self.assertEqual([param["name"] for param in building_consume["params"]], ["consumers", "self_state"])
        self.assertEqual(building_consume["params"][0]["schema"], "source_building_consume_input.consumers")
        self.assertEqual(building_consume["params"][1]["schema"], "source_building_consume_input.self_state")
        self.assertIn("triggered", building_consume["return_keys"])
        self.assertEqual(building_consume["source_method"], "consume()")

        building_consume_trigger_valid = source_symbols.api_contract(contracts, "PortGame.source_building_consume_trigger_valid_state")
        self.assertEqual([param["name"] for param in building_consume_trigger_valid["params"]], [])
        self.assertIn("consume_trigger_valid", building_consume_trigger_valid["return_keys"])
        self.assertEqual(building_consume_trigger_valid["source_method"], "consumeTriggerValid()")

        building_control_config = source_symbols.api_contract(contracts, "PortGame.source_building_control_config_state")
        self.assertEqual([param["name"] for param in building_control_config["params"]], ["control_type", "block_logic_configurable", "p1_is_logic_build", "p1_value"])
        self.assertEqual(building_control_config["params"][0]["schema"], "source_building_control_config_input.control_type")
        self.assertEqual(building_control_config["params"][3]["schema"], "source_building_control_config_input.p1_value")
        self.assertIn("configured_called", building_control_config["return_keys"])
        self.assertIn("builder", building_control_config["return_keys"])
        self.assertIn("value", building_control_config["return_keys"])
        self.assertEqual(building_control_config["source_method"], "control(LAccess type, Object p1, double p2, double p3, double p4)")

        building_control_enabled = source_symbols.api_contract(contracts, "PortGame.source_building_control_enabled_state")
        self.assertEqual([param["name"] for param in building_control_enabled["params"]], ["current_enabled", "control_type", "p1"])
        self.assertEqual(building_control_enabled["params"][0]["schema"], "source_building_control_enabled_input.current_enabled")
        self.assertEqual(building_control_enabled["params"][2]["schema"], "source_building_control_enabled_input.p1")
        self.assertIn("enabled", building_control_enabled["return_keys"])
        self.assertEqual(building_control_enabled["source_method"], "control(LAccess type, double p1, double p2, double p3, double p4)")

        building_cursor = source_symbols.api_contract(contracts, "PortGame.source_building_cursor_state")
        self.assertEqual([param["name"] for param in building_cursor["params"]], ["block_configurable", "interactable_player_team"])
        self.assertEqual(building_cursor["params"][0]["schema"], "source_building_cursor_input.block_configurable")
        self.assertEqual(building_cursor["params"][1]["schema"], "source_building_cursor_input.interactable_player_team")
        self.assertIn("cursor", building_cursor["return_keys"])
        self.assertEqual(building_cursor["source_method"], "getCursor()")

        building_damage_block_health_scale = source_symbols.api_contract(contracts, "PortGame.source_building_damage_block_health_scale_state")
        self.assertEqual([param["name"] for param in building_damage_block_health_scale["params"]], ["damage_amount", "health", "block_health_multiplier", "source_time"])
        self.assertEqual(building_damage_block_health_scale["params"][0]["schema"], "source_building_damage_block_health_scale_input.damage_amount")
        self.assertEqual(building_damage_block_health_scale["params"][2]["schema"], "source_building_damage_block_health_scale_input.block_health_multiplier")
        self.assertIn("damage", building_damage_block_health_scale["return_keys"])
        self.assertIn("last_damage_time", building_damage_block_health_scale["return_keys"])
        self.assertEqual(building_damage_block_health_scale["source_method"], "damage(float damage)")

        building_damage_dead_guard = source_symbols.api_contract(contracts, "PortGame.source_building_damage_dead_guard_state")
        self.assertEqual([param["name"] for param in building_damage_dead_guard["params"]], ["dead_state"])
        self.assertEqual(building_damage_dead_guard["params"][0]["schema"], "source_building_damage_dead_guard_input.dead_state")
        self.assertIn("returned", building_damage_dead_guard["return_keys"])
        self.assertIn("continues", building_damage_dead_guard["return_keys"])
        self.assertEqual(building_damage_dead_guard["source_method"], "damage(float damage)")

        building_damage_delegate = source_symbols.api_contract(contracts, "PortGame.source_building_damage_delegate_state")
        self.assertEqual([param["name"] for param in building_damage_delegate["params"]], ["source_team", "damage_amount"])
        self.assertEqual(building_damage_delegate["params"][0]["schema"], "source_building_damage_delegate_input.source_team")
        self.assertEqual(building_damage_delegate["params"][1]["schema"], "source_building_damage_delegate_input.damage")
        self.assertIn("source_team", building_damage_delegate["return_keys"])
        self.assertIn("damage", building_damage_delegate["return_keys"])
        self.assertIn("delegates_to_damage", building_damage_delegate["return_keys"])
        self.assertEqual(building_damage_delegate["source_method"], "damage(@Nullable Team source, float damage)")

        building_damage_handle_damage_gate = source_symbols.api_contract(contracts, "PortGame.source_building_damage_handle_damage_gate_state")
        self.assertEqual([param["name"] for param in building_damage_handle_damage_gate["params"]], ["net_client", "health", "damage_amount", "handled_damage"])
        self.assertEqual(building_damage_handle_damage_gate["params"][0]["schema"], "source_building_damage_handle_damage_gate_input.net_client")
        self.assertEqual(building_damage_handle_damage_gate["params"][3]["schema"], "source_building_damage_handle_damage_gate_input.handled_damage")
        self.assertIn("health", building_damage_handle_damage_gate["return_keys"])
        self.assertIn("damage", building_damage_handle_damage_gate["return_keys"])
        self.assertIn("handled_damage", building_damage_handle_damage_gate["return_keys"])
        self.assertIn("handle_damage_called", building_damage_handle_damage_gate["return_keys"])
        self.assertEqual(building_damage_handle_damage_gate["source_method"], "damage(float damage)")

        building_damage_health_changed_call = source_symbols.api_contract(contracts, "PortGame.source_building_damage_health_changed_call_state")
        self.assertEqual([param["name"] for param in building_damage_health_changed_call["params"]], [])
        self.assertIn("health_changed", building_damage_health_changed_call["return_keys"])
        self.assertEqual(building_damage_health_changed_call["source_method"], "damage(float damage)")

        building_delta = source_symbols.api_contract(contracts, "PortGame.source_building_delta")
        self.assertEqual([param["name"] for param in building_delta["params"]], ["source_delta", "time_scale"])
        self.assertEqual(building_delta["params"][0]["schema"], "source_building_delta_input.source_delta")
        self.assertEqual(building_delta["params"][1]["schema"], "source_building_delta_input.time_scale")
        self.assertIn("delta", building_delta["return_keys"])
        self.assertEqual(building_delta["source_method"], "delta()")

        building_display_efficiency = source_symbols.api_contract(contracts, "PortGame.source_building_display_efficiency")
        self.assertEqual([param["name"] for param in building_display_efficiency["params"]], ["edelta_value"])
        self.assertEqual(building_display_efficiency["params"][0]["schema"], "source_building_display_efficiency_input.edelta_value")
        self.assertIn("displayEfficiency", building_display_efficiency["return_keys"])
        self.assertIn("progressIncrease", building_display_efficiency["return_keys"])
        self.assertEqual(building_display_efficiency["source_method"], "getDisplayEfficiency()")

        building_display_flow_rate_label = source_symbols.api_contract(contracts, "PortGame.source_building_display_flow_rate_label")
        self.assertEqual([param["name"] for param in building_display_flow_rate_label["params"]], ["flow_rate", "per_second_label"])
        self.assertEqual(building_display_flow_rate_label["params"][0]["schema"], "source_building_display_flow_rate_label_input.flow_rate")
        self.assertEqual(building_display_flow_rate_label["params"][1]["schema"], "source_building_display_flow_rate_label_input.per_second_label")
        self.assertIn("unknown", building_display_flow_rate_label["return_keys"])
        self.assertIn("fixedLabel", building_display_flow_rate_label["return_keys"])
        self.assertEqual(building_display_flow_rate_label["source_method"], "display(Table table)")

        building_display_icon = source_symbols.api_contract(contracts, "PortGame.source_building_display_icon_state")
        self.assertEqual([param["name"] for param in building_display_icon["params"]], ["block_ui_icon"])
        self.assertEqual(building_display_icon["params"][0]["schema"], "source_building_display_icon_input.block_ui_icon")
        self.assertIn("icon", building_display_icon["return_keys"])
        self.assertIn("scaling", building_display_icon["return_keys"])
        self.assertIn("size", building_display_icon["return_keys"])
        self.assertEqual(building_display_icon["source_method"], "display(Table table)")

        building_display_name = source_symbols.api_contract(contracts, "PortGame.source_building_display_name_state")
        self.assertEqual([param["name"] for param in building_display_name["params"]], ["localized_name", "team_is_derelict", "team_is_player", "team_emoji", "derelict_label"])
        self.assertEqual(building_display_name["params"][0]["schema"], "source_building_display_name_input.localized_name")
        self.assertEqual(building_display_name["params"][4]["schema"], "source_building_display_name_input.derelict_label")
        self.assertIn("derelictName", building_display_name["return_keys"])
        self.assertIn("displayName", building_display_name["return_keys"])
        self.assertEqual(building_display_name["source_method"], "getDisplayName()")

        building_display_ui_gates = source_symbols.api_contract(contracts, "PortGame.source_building_display_ui_gates_state")
        self.assertEqual([param["name"] for param in building_display_ui_gates["params"]], ["team_is_player", "block_category", "block_display_flow", "net_active", "has_last_accessed"])
        self.assertEqual(building_display_ui_gates["params"][0]["schema"], "source_building_display_ui_gates_input.team_is_player")
        self.assertEqual(building_display_ui_gates["params"][1]["schema"], "source_building_display_ui_gates_input.block_category")
        self.assertEqual(building_display_ui_gates["params"][4]["schema"], "source_building_display_ui_gates_input.has_last_accessed")
        self.assertIn("displayHeader", building_display_ui_gates["return_keys"])
        self.assertIn("displayFlow", building_display_ui_gates["return_keys"])
        self.assertIn("displayLastAccessed", building_display_ui_gates["return_keys"])
        self.assertEqual(building_display_ui_gates["source_method"], "display(Table table)")

        building_draw_cached = source_symbols.api_contract(contracts, "PortGame.source_building_draw_cached_state")
        self.assertEqual([param["name"] for param in building_draw_cached["params"]], ["variants", "has_variant_regions", "variant_region_count", "tile_pos", "source_x", "source_y", "block_rotate", "block_rotate_draw", "rotation_quadrants"])
        self.assertEqual(building_draw_cached["params"][0]["schema"], "source_building_draw_cached_input.variants")
        self.assertEqual(building_draw_cached["params"][3]["schema"], "source_building_draw_cached_input.tile_pos")
        self.assertEqual(building_draw_cached["params"][8]["schema"], "source_building_draw_cached_input.rotation_quadrants")
        self.assertIn("drawDelegate", building_draw_cached["return_keys"])
        self.assertIn("drawrotFormula", building_draw_cached["return_keys"])
        self.assertIn("delegatedDraw", building_draw_cached["return_keys"])
        self.assertEqual(building_draw_cached["source_method"], "drawCached()")

        building_draw_configure = source_symbols.api_contract(contracts, "PortGame.source_building_draw_configure_state")
        self.assertEqual([param["name"] for param in building_draw_configure["params"]], ["source_x", "source_y", "block_size_value", "source_tilesize"])
        self.assertEqual(building_draw_configure["params"][0]["schema"], "source_building_draw_configure_input.source_x")
        self.assertEqual(building_draw_configure["params"][2]["schema"], "source_building_draw_configure_input.block_size_value")
        self.assertEqual(building_draw_configure["params"][3]["schema"], "source_building_draw_configure_input.source_tilesize")
        self.assertIn("color", building_draw_configure["return_keys"])
        self.assertIn("radius", building_draw_configure["return_keys"])
        self.assertIn("reset", building_draw_configure["return_keys"])
        self.assertEqual(building_draw_configure["source_method"], "drawConfigure()")

        building_draw_cracks = source_symbols.api_contract(contracts, "PortGame.source_building_draw_cracks_state")
        self.assertEqual([param["name"] for param in building_draw_cracks["params"]], ["draw_cracks", "damaged_state", "block_size_value", "max_crack_size", "health_fraction", "crack_regions", "position_id"])
        self.assertEqual(building_draw_cracks["params"][0]["schema"], "source_building_draw_cracks_input.draw_cracks")
        self.assertEqual(building_draw_cracks["params"][4]["schema"], "source_building_draw_cracks_input.health_fraction")
        self.assertEqual(building_draw_cracks["params"][6]["schema"], "source_building_draw_cracks_input.position_id")
        self.assertIn("visible", building_draw_cracks["return_keys"])
        self.assertIn("crackIndex", building_draw_cracks["return_keys"])
        self.assertIn("rotationDegrees", building_draw_cracks["return_keys"])
        self.assertEqual(building_draw_cracks["source_method"], "drawCracks()")

        building_draw_disabled = source_symbols.api_contract(contracts, "PortGame.source_building_draw_disabled_state")
        self.assertEqual([param["name"] for param in building_draw_disabled["params"]], ["source_x", "source_y"])
        self.assertEqual(building_draw_disabled["params"][0]["schema"], "source_building_draw_disabled_input.source_x")
        self.assertEqual(building_draw_disabled["params"][1]["schema"], "source_building_draw_disabled_input.source_y")
        self.assertIn("icon", building_draw_disabled["return_keys"])
        self.assertIn("size", building_draw_disabled["return_keys"])
        self.assertIn("reset", building_draw_disabled["return_keys"])
        self.assertEqual(building_draw_disabled["source_method"], "drawDisabled()")

        building_draw_item_selection = source_symbols.api_contract(contracts, "PortGame.source_building_draw_item_selection_state")
        self.assertEqual([param["name"] for param in building_draw_item_selection["params"]], ["has_selection", "source_x", "source_y", "block_size_value", "source_tilesize", "icon_small", "selection_icon_ratio"])
        self.assertEqual(building_draw_item_selection["params"][0]["schema"], "source_building_draw_item_selection_input.has_selection")
        self.assertEqual(building_draw_item_selection["params"][3]["schema"], "source_building_draw_item_selection_input.block_size_value")
        self.assertEqual(building_draw_item_selection["params"][6]["schema"], "source_building_draw_item_selection_input.selection_icon_ratio")
        self.assertIn("visible", building_draw_item_selection["return_keys"])
        self.assertIn("selection_width", building_draw_item_selection["return_keys"])
        self.assertIn("shadow_y", building_draw_item_selection["return_keys"])
        self.assertEqual(building_draw_item_selection["source_method"], "drawItemSelection(@Nullable UnlockableContent selection)")

        building_draw_light = source_symbols.api_contract(contracts, "PortGame.source_building_draw_light_state")
        self.assertEqual([param["name"] for param in building_draw_light["params"]], ["has_liquids", "draw_liquid_light", "light_liquid_is_null", "current_liquid_color", "current_liquid_alpha", "light_liquid_color", "light_liquid_alpha", "selected_liquid_amount", "visual_liquid", "source_delta", "source_x", "source_y", "block_size_value"])
        self.assertEqual(building_draw_light["params"][0]["schema"], "source_building_draw_light_input.has_liquids")
        self.assertEqual(building_draw_light["params"][7]["schema"], "source_building_draw_light_input.selected_liquid_amount")
        self.assertEqual(building_draw_light["params"][12]["schema"], "source_building_draw_light_input.block_size_value")
        self.assertIn("visible", building_draw_light["return_keys"])
        self.assertIn("visual_liquid", building_draw_light["return_keys"])
        self.assertIn("drawLiquidLightCall", building_draw_light["return_keys"])
        self.assertEqual(building_draw_light["source_method"], "drawLight()")

        building_draw_liquid_light = source_symbols.api_contract(contracts, "PortGame.source_building_draw_liquid_light_state")
        self.assertEqual([param["name"] for param in building_draw_liquid_light["params"]], ["source_x", "source_y", "block_size_value", "light_color", "light_alpha", "amount"])
        self.assertEqual(building_draw_liquid_light["params"][0]["schema"], "source_building_draw_liquid_light_input.source_x")
        self.assertEqual(building_draw_liquid_light["params"][4]["schema"], "source_building_draw_liquid_light_input.light_alpha")
        self.assertEqual(building_draw_liquid_light["params"][5]["schema"], "source_building_draw_liquid_light_input.amount")
        self.assertIn("radius", building_draw_liquid_light["return_keys"])
        self.assertIn("opacity", building_draw_liquid_light["return_keys"])
        self.assertIn("alpha", building_draw_liquid_light["return_keys"])
        self.assertEqual(building_draw_liquid_light["source_method"], "drawLiquidLight(Liquid liquid, float amount)")

        building_draw_select = source_symbols.api_contract(contracts, "PortGame.source_building_draw_select_state")
        self.assertEqual([param["name"] for param in building_draw_select["params"]], ["block_status", "source_x", "source_y", "source_rotation", "tile_x", "tile_y", "unit_activation_delay", "state_tick"])
        self.assertEqual(building_draw_select["params"][0]["schema"], "source_building_draw_select_input.block_status")
        self.assertEqual(building_draw_select["params"][3]["schema"], "source_building_draw_select_input.source_rotation")
        self.assertEqual(building_draw_select["params"][6]["schema"], "source_building_draw_select_input.unit_activation_delay")
        self.assertIn("overlay_visible", building_draw_select["return_keys"])
        self.assertIn("place_text_visible", building_draw_select["return_keys"])
        self.assertIn("place_text_time", building_draw_select["return_keys"])
        self.assertEqual(building_draw_select["source_method"], "drawSelect()")

        building_draw = source_symbols.api_contract(contracts, "PortGame.source_building_draw_state")
        self.assertEqual([param["name"] for param in building_draw["params"]], ["variants", "has_variant_regions", "variant_region_count", "tile_pos", "source_x", "source_y", "block_rotate", "block_rotate_draw", "rotation_quadrants"])
        self.assertEqual(building_draw["params"][0]["schema"], "source_building_draw_input.variants")
        self.assertEqual(building_draw["params"][3]["schema"], "source_building_draw_input.tile_pos")
        self.assertEqual(building_draw["params"][8]["schema"], "source_building_draw_input.rotation_quadrants")
        self.assertIn("region_kind", building_draw["return_keys"])
        self.assertIn("variant_index", building_draw["return_keys"])
        self.assertIn("rotation_degrees", building_draw["return_keys"])
        self.assertIn("draw_team_top", building_draw["return_keys"])
        self.assertEqual(building_draw["source_method"], "draw()")

        building_draw_status = source_symbols.api_contract(contracts, "PortGame.source_building_draw_status_state")
        self.assertEqual([param["name"] for param in building_draw_status["params"]], ["enable_draw_status", "consumers_length", "block_size_value", "source_x", "source_y", "source_tilesize"])
        self.assertEqual(building_draw_status["params"][0]["schema"], "source_building_draw_status_input.enable_draw_status")
        self.assertEqual(building_draw_status["params"][1]["schema"], "source_building_draw_status_input.consumers_length")
        self.assertEqual(building_draw_status["params"][5]["schema"], "source_building_draw_status_input.source_tilesize")
        self.assertIn("visible", building_draw_status["return_keys"])
        self.assertIn("multiplier", building_draw_status["return_keys"])
        self.assertIn("brcx", building_draw_status["return_keys"])
        self.assertIn("gray_square_size", building_draw_status["return_keys"])
        self.assertIn("status_square_size", building_draw_status["return_keys"])
        self.assertEqual(building_draw_status["source_method"], "drawStatus()")

        building_draw_team = source_symbols.api_contract(contracts, "PortGame.source_building_draw_team_state")
        self.assertEqual([param["name"] for param in building_draw_team["params"]], ["team_color", "source_x", "source_y", "block_size_value", "source_tilesize"])
        self.assertEqual(building_draw_team["params"][0]["schema"], "source_building_draw_team_input.team_color")
        self.assertEqual(building_draw_team["params"][3]["schema"], "source_building_draw_team_input.block_size_value")
        self.assertEqual(building_draw_team["params"][4]["schema"], "source_building_draw_team_input.source_tilesize")
        self.assertIn("region", building_draw_team["return_keys"])
        self.assertIn("color", building_draw_team["return_keys"])
        self.assertIn("x", building_draw_team["return_keys"])
        self.assertIn("y", building_draw_team["return_keys"])
        self.assertIn("color_reset", building_draw_team["return_keys"])
        self.assertEqual(building_draw_team["source_method"], "drawTeam()")

        building_draw_team_top = source_symbols.api_contract(contracts, "PortGame.source_building_draw_team_top_state")
        self.assertEqual([param["name"] for param in building_draw_team_top["params"]], ["team_region_found", "team_region_matches_team", "team_color", "source_x", "source_y"])
        self.assertEqual(building_draw_team_top["params"][0]["schema"], "source_building_draw_team_top_input.team_region_found")
        self.assertEqual(building_draw_team_top["params"][1]["schema"], "source_building_draw_team_top_input.team_region_matches_team")
        self.assertEqual(building_draw_team_top["params"][4]["schema"], "source_building_draw_team_top_input.source_y")
        self.assertIn("visible", building_draw_team_top["return_keys"])
        self.assertIn("tint_color", building_draw_team_top["return_keys"])
        self.assertIn("x", building_draw_team_top["return_keys"])
        self.assertIn("y", building_draw_team_top["return_keys"])
        self.assertIn("color_reset", building_draw_team_top["return_keys"])
        self.assertEqual(building_draw_team_top["source_method"], "drawTeamTop()")

        building_drawrot = source_symbols.api_contract(contracts, "PortGame.source_building_drawrot_state")
        self.assertEqual([param["name"] for param in building_drawrot["params"]], ["block_rotate", "block_rotate_draw", "rotation_quadrants"])
        self.assertEqual(building_drawrot["params"][0]["schema"], "source_building_drawrot_input.block_rotate")
        self.assertEqual(building_drawrot["params"][1]["schema"], "source_building_drawrot_input.block_rotate_draw")
        self.assertEqual(building_drawrot["params"][2]["schema"], "source_building_drawrot_input.rotation_quadrants")
        self.assertIn("rotation_degrees", building_drawrot["return_keys"])
        self.assertEqual(building_drawrot["source_method"], "drawrot()")

        building_edelta = source_symbols.api_contract(contracts, "PortGame.source_building_edelta")
        self.assertEqual([param["name"] for param in building_edelta["params"]], ["source_delta", "time_scale", "efficiency"])
        self.assertEqual(building_edelta["params"][0]["schema"], "source_building_edelta_input.source_delta")
        self.assertEqual(building_edelta["params"][1]["schema"], "source_building_edelta_input.time_scale")
        self.assertEqual(building_edelta["params"][2]["schema"], "source_building_edelta_input.efficiency")
        self.assertIn("edelta", building_edelta["return_keys"])
        self.assertEqual(building_edelta["source_method"], "edelta()")

        building_efficiency_scale = source_symbols.api_contract(contracts, "PortGame.source_building_efficiency_scale_state")
        self.assertEqual([param["name"] for param in building_efficiency_scale["params"]], [])
        self.assertIn("efficiency_scale", building_efficiency_scale["return_keys"])
        self.assertEqual(building_efficiency_scale["source_method"], "efficiencyScale()")

        arc_mathf_cos_scaled = source_symbols.api_contract(contracts, "PortGame.source_arc_mathf_cos_scaled")
        self.assertEqual([param["name"] for param in arc_mathf_cos_scaled["params"]], ["radians", "scl", "mag"])
        self.assertEqual(arc_mathf_cos_scaled["params"][0]["schema"], "source_arc_mathf_cos_scaled_input.radians")
        self.assertEqual(arc_mathf_cos_scaled["params"][2]["schema"], "source_arc_mathf_cos_scaled_input.mag")
        self.assertIn("scaledRadians", arc_mathf_cos_scaled["return_keys"])
        self.assertIn("cosScaled", arc_mathf_cos_scaled["return_keys"])
        self.assertEqual(arc_mathf_cos_scaled["source_method"], "cos(float radians, float scl, float mag)")

        arc_mathf_mod_float = source_symbols.api_contract(contracts, "PortGame.source_arc_mathf_mod_float")
        self.assertEqual([param["name"] for param in arc_mathf_mod_float["params"]], ["value", "divisor"])
        self.assertEqual(arc_mathf_mod_float["params"][0]["schema"], "source_arc_mathf_mod_float_input.value")
        self.assertEqual(arc_mathf_mod_float["params"][1]["schema"], "source_arc_mathf_mod_float_input.divisor")
        self.assertIn("rawMod", arc_mathf_mod_float["return_keys"])
        self.assertIn("offsetMod", arc_mathf_mod_float["return_keys"])
        self.assertIn("mod", arc_mathf_mod_float["return_keys"])
        self.assertEqual(arc_mathf_mod_float["source_method"], "mod(float f, float n)")

        arc_mathf_num = source_symbols.api_contract(contracts, "PortGame.source_arc_mathf_num")
        self.assertEqual([param["name"] for param in arc_mathf_num["params"]], ["value"])
        self.assertEqual(arc_mathf_num["params"][0]["schema"], "source_arc_mathf_num_input.value")
        self.assertIn("trueValue", arc_mathf_num["return_keys"])
        self.assertIn("falseValue", arc_mathf_num["return_keys"])
        self.assertIn("num", arc_mathf_num["return_keys"])
        self.assertEqual(arc_mathf_num["source_method"], "num(boolean b)")

        angle_distance = source_symbols.api_contract(contracts, "PortGame.source_angle_distance")
        self.assertEqual([param["name"] for param in angle_distance["params"]], ["current_degrees", "target_degrees"])
        self.assertEqual(angle_distance["params"][0]["schema"], "source_angle_distance_input.currentDegrees")
        self.assertEqual(angle_distance["params"][1]["schema"], "source_angle_distance_input.targetDegrees")
        self.assertIn("currentMod", angle_distance["return_keys"])
        self.assertIn("targetMod", angle_distance["return_keys"])
        self.assertIn("angleDistance", angle_distance["return_keys"])
        self.assertEqual(angle_distance["source_method"], "angleDist(float a, float b)")

        source_angles_angle_dist = source_symbols.api_contract(contracts, "PortGame.source_angles_angle_dist")
        self.assertEqual([param["name"] for param in source_angles_angle_dist["params"]], ["a", "b"])
        self.assertEqual(source_angles_angle_dist["params"][0]["schema"], "source_angles_angle_dist_input.a")
        self.assertEqual(source_angles_angle_dist["params"][1]["schema"], "source_angles_angle_dist_input.b")
        self.assertIn("angleDistance", source_angles_angle_dist["return_keys"])
        self.assertEqual(source_angles_angle_dist["source_method"], "angleDist(float a, float b)")

        angle_to_target = source_symbols.api_contract(contracts, "PortGame.source_angle_to_target")
        self.assertEqual([param["name"] for param in angle_to_target["params"]], ["origin", "target"])
        self.assertEqual(angle_to_target["params"][0]["schema"], "source_angle_to_target_input.origin")
        self.assertEqual(angle_to_target["params"][1]["schema"], "source_angle_to_target_input.target")
        self.assertIn("targetAngle", angle_to_target["return_keys"])
        self.assertIn("originX", angle_to_target["return_keys"])
        self.assertIn("targetY", angle_to_target["return_keys"])
        self.assertEqual(angle_to_target["source_method"], "angleTo(Position other)")

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

        create_splash_damage_output = source_symbols.state_schema(schema, "create_splash_damage_damage_dispatch_result")
        self.assertEqual(create_splash_damage_output["keys"]["splashDamageGatePassed"]["java_expr"], "splashDamageRadius > 0 && !b.absorbed")
        self.assertEqual(create_splash_damage_output["keys"]["damageCall"]["java_expr"], "Damage.damage(b.team, x, y, splashDamageRadius, splashDamage * b.damageMultiplier(), splashDamagePierce, collidesAir, collidesGround, scaledSplashDamage, b, armorMultiplier)")
        self.assertEqual(create_splash_damage_output["keys"]["statusBoundarySource"]["java_expr"], "if(status != StatusEffects.none)")

        create_splash_damage_status_output = source_symbols.state_schema(schema, "create_splash_damage_status_dispatch_result")
        self.assertEqual(create_splash_damage_status_output["keys"]["statusGatePassed"]["java_expr"], "status != StatusEffects.none")
        self.assertEqual(create_splash_damage_status_output["keys"]["statusCall"]["java_expr"], "Damage.status(b.team, x, y, splashDamageRadius, status, statusDuration, collidesAir, collidesGround)")
        self.assertEqual(create_splash_damage_status_output["keys"]["healsBoundarySource"]["java_expr"], "if(heals())")

        nearby_blocks_state = source_symbols.state_schema(schema, "nearby_blocks_state")
        self.assertEqual(nearby_blocks_state["keys"]["blocks"]["java_expr"], "indexer.eachBlock(b.team, x, y, splashDamageRadius, Building::damaged, other -> {...})")
        self.assertEqual(nearby_blocks_state["keys"]["blocks"]["status"], "explicit-input")

        create_splash_damage_heal_output = source_symbols.state_schema(schema, "create_splash_damage_heal_dispatch_result")
        self.assertEqual(create_splash_damage_heal_output["keys"]["healGatePassed"]["java_expr"], "heals()")
        self.assertEqual(create_splash_damage_heal_output["keys"]["eachBlockCall"]["java_expr"], "indexer.eachBlock(b.team, x, y, splashDamageRadius, Building::damaged, other -> {...})")
        self.assertEqual(create_splash_damage_heal_output["keys"]["healApplications"]["java_expr"], "other.heal(healPercent / 100f * other.maxHealth() + healAmount)")
        self.assertEqual(create_splash_damage_heal_output["keys"]["makeFireBoundarySource"]["java_expr"], "if(makeFire)")

        create_splash_damage_make_fire_output = source_symbols.state_schema(schema, "create_splash_damage_make_fire_dispatch_result")
        self.assertEqual(create_splash_damage_make_fire_output["keys"]["makeFireGatePassed"]["java_expr"], "makeFire")
        self.assertEqual(create_splash_damage_make_fire_output["keys"]["eachBlockCall"]["java_expr"], "indexer.eachBlock(null, x, y, splashDamageRadius, other -> other.team != b.team, other -> Fires.create(other.tile))")
        self.assertEqual(create_splash_damage_make_fire_output["keys"]["fireApplications"]["java_expr"], "Fires.create(other.tile)")
        self.assertEqual(create_splash_damage_make_fire_output["keys"]["createFragsBoundarySource"]["java_expr"], "public void createFrags(Bullet b, float x, float y){")

        create_frags_state = source_symbols.state_schema(schema, "create_frags_state")
        self.assertEqual(create_frags_state["keys"]["x"]["java_expr"], "x")
        self.assertEqual(create_frags_state["keys"]["x"]["status"], "explicit-input")

        create_frags_initial_output = source_symbols.state_schema(schema, "create_frags_initial_result")
        self.assertEqual(create_frags_initial_output["keys"]["fragGatePassed"]["java_expr"], "fragBullet != null && (fragOnAbsorb || !b.absorbed) && (pierceFragCap < 0 || b.frags < pierceFragCap)")
        self.assertEqual(create_frags_initial_output["keys"]["loopIterations"]["java_expr"], "for(int i = 0; i < fragBullets; i++)")
        self.assertEqual(create_frags_initial_output["keys"]["randomLenBoundarySource"]["java_expr"], "float len = Mathf.random(fragOffsetMin, fragOffsetMax)")
        self.assertEqual(create_frags_initial_output["keys"]["bulletFrags"]["alias_of"], "bullet_state.frags")

        frag_random_state = source_symbols.state_schema(schema, "frag_random_state")
        self.assertEqual(frag_random_state["keys"]["lenSamples"]["java_expr"], "Mathf.random(fragOffsetMin, fragOffsetMax)")
        self.assertEqual(frag_random_state["keys"]["lenSamples"]["status"], "explicit-input")
        self.assertEqual(frag_random_state["keys"]["rangeSamples"]["java_expr"], "Mathf.range(fragRandomSpread / 2)")
        self.assertEqual(frag_random_state["keys"]["velocitySamples"]["java_expr"], "Mathf.random(fragVelocityMin, fragVelocityMax)")
        self.assertEqual(frag_random_state["keys"]["lifeSamples"]["java_expr"], "Mathf.random(fragLifeMin, fragLifeMax)")

        create_frags_random_geometry_output = source_symbols.state_schema(schema, "create_frags_random_geometry_result")
        self.assertEqual(create_frags_random_geometry_output["keys"]["fragmentPlans"]["java_expr"], "float len = Mathf.random(fragOffsetMin, fragOffsetMax); float a = b.rotation() + Mathf.range(fragRandomSpread / 2) + fragAngle + fragSpread * i - (fragBullets - 1) * fragSpread / 2f;")
        self.assertEqual(create_frags_random_geometry_output["keys"]["fragmentPlans"]["status"], "source-backed")
        self.assertEqual(create_frags_random_geometry_output["keys"]["createFragsInitial"]["alias_of"], "create_frags_initial_result")

        create_frags_create_call_output = source_symbols.state_schema(schema, "create_frags_create_call_result")
        self.assertEqual(create_frags_create_call_output["keys"]["fragmentCreateCalls"]["java_expr"], "fragBullet.create(b, x + Angles.trnsx(a, len), y + Angles.trnsy(a, len), a, Mathf.random(fragVelocityMin, fragVelocityMax), Mathf.random(fragLifeMin, fragLifeMax))")
        self.assertEqual(create_frags_create_call_output["keys"]["fragmentCreateCalls"]["status"], "source-backed")
        self.assertEqual(create_frags_create_call_output["keys"]["createFragsRandomGeometry"]["alias_of"], "create_frags_random_geometry_result")

        create_frags_increment_output = source_symbols.state_schema(schema, "create_frags_increment_result")
        self.assertEqual(create_frags_increment_output["keys"]["bulletFragsAfter"]["java_expr"], "b.frags++")
        self.assertEqual(create_frags_increment_output["keys"]["bulletFragsAfter"]["status"], "source-backed")
        self.assertEqual(create_frags_increment_output["keys"]["createFragsCreateCall"]["alias_of"], "create_frags_create_call_result")

        create_puddles_state = source_symbols.state_schema(schema, "create_puddles_state")
        self.assertEqual(create_puddles_state["keys"]["x"]["java_expr"], "x")
        self.assertEqual(create_puddles_state["keys"]["y"]["java_expr"], "y")

        create_puddles_initial_output = source_symbols.state_schema(schema, "create_puddles_initial_result")
        self.assertEqual(create_puddles_initial_output["keys"]["puddleGatePassed"]["java_expr"], "puddleLiquid != null && puddles > 0")
        self.assertEqual(create_puddles_initial_output["keys"]["loopIterations"]["java_expr"], "for(int i = 0; i < puddles; i++)")
        self.assertEqual(create_puddles_initial_output["keys"]["tileBoundarySource"]["java_expr"], "Tile tile = world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange));")

        puddle_random_state = source_symbols.state_schema(schema, "puddle_random_state")
        self.assertEqual(puddle_random_state["keys"]["xRangeSamples"]["java_expr"], "Mathf.range(puddleRange)")
        self.assertEqual(puddle_random_state["keys"]["xRangeSamples"]["status"], "explicit-input")
        self.assertEqual(puddle_random_state["keys"]["yRangeSamples"]["java_expr"], "Mathf.range(puddleRange)")

        create_puddles_tile_world_output = source_symbols.state_schema(schema, "create_puddles_tile_world_result")
        self.assertEqual(create_puddles_tile_world_output["keys"]["tileWorldCalls"]["java_expr"], "Tile tile = world.tileWorld(x + Mathf.range(puddleRange), y + Mathf.range(puddleRange))")
        self.assertEqual(create_puddles_tile_world_output["keys"]["tileWorldCalls"]["status"], "source-backed")
        self.assertEqual(create_puddles_tile_world_output["keys"]["createPuddlesInitial"]["alias_of"], "create_puddles_initial_result")

        create_puddles_deposit_output = source_symbols.state_schema(schema, "create_puddles_deposit_result")
        self.assertEqual(create_puddles_deposit_output["keys"]["depositCalls"]["java_expr"], "Puddles.deposit(tile, puddleLiquid, puddleAmount)")
        self.assertEqual(create_puddles_deposit_output["keys"]["depositCalls"]["status"], "source-backed")
        self.assertEqual(create_puddles_deposit_output["keys"]["createPuddlesTileWorld"]["alias_of"], "create_puddles_tile_world_result")

        create_incend_state = source_symbols.state_schema(schema, "create_incend_state")
        self.assertEqual(create_incend_state["keys"]["x"]["java_expr"], "x")
        self.assertEqual(create_incend_state["keys"]["y"]["java_expr"], "y")

        incend_random_state = source_symbols.state_schema(schema, "incend_random_state")
        self.assertEqual(incend_random_state["keys"]["chancePassed"]["java_expr"], "Mathf.chance(incendChance)")
        self.assertEqual(incend_random_state["keys"]["chancePassed"]["status"], "explicit-input")

        create_incend_output = source_symbols.state_schema(schema, "create_incend_result")
        self.assertEqual(create_incend_output["keys"]["incendGatePassed"]["java_expr"], "incendChance > 0 && Mathf.chance(incendChance)")
        self.assertEqual(create_incend_output["keys"]["createIncendCall"]["java_expr"], "Damage.createIncend(x, y, incendSpread, incendAmount)")
        self.assertEqual(create_incend_output["keys"]["createIncendCall"]["status"], "source-backed")
        self.assertEqual(create_incend_output["keys"]["createIncend"]["alias_of"], "create_incend_state")

        create_units_state = source_symbols.state_schema(schema, "create_units_state")
        self.assertEqual(create_units_state["keys"]["x"]["java_expr"], "x")
        self.assertEqual(create_units_state["keys"]["y"]["java_expr"], "y")

        create_units_random_state = source_symbols.state_schema(schema, "create_units_random_state")
        self.assertEqual(create_units_random_state["keys"]["chancePassed"]["java_expr"], "Mathf.chance(despawnUnitChance)")
        self.assertEqual(create_units_random_state["keys"]["chancePassed"]["status"], "explicit-input")
        self.assertEqual(create_units_random_state["keys"]["lengthSamples"]["java_expr"], "Mathf.random(despawnUnitRadius)")
        self.assertEqual(create_units_random_state["keys"]["lengthSamples"]["status"], "explicit-input")
        self.assertEqual(create_units_random_state["keys"]["thetaSamples"]["java_expr"], "Mathf.random(0f, Mathf.PI2)")

        net_state = source_symbols.state_schema(schema, "net_state")
        self.assertEqual(net_state["keys"]["client"]["java_expr"], "net.client()")
        self.assertEqual(net_state["keys"]["client"]["status"], "explicit-input")

        create_units_initial_output = source_symbols.state_schema(schema, "create_units_initial_result")
        self.assertEqual(create_units_initial_output["keys"]["createUnitsGatePassed"]["java_expr"], "!net.client() && despawnUnit != null && Mathf.chance(despawnUnitChance)")
        self.assertEqual(create_units_initial_output["keys"]["loopIterations"]["java_expr"], "for(int i = 0; i < despawnUnitCount; i++)")
        self.assertEqual(create_units_initial_output["keys"]["randomOffsetBoundarySource"]["java_expr"], "Tmp.v1.rnd(Mathf.random(despawnUnitRadius));")
        self.assertEqual(create_units_initial_output["keys"]["createUnits"]["alias_of"], "create_units_state")

        create_units_random_offset_output = source_symbols.state_schema(schema, "create_units_random_offset_result")
        self.assertEqual(create_units_random_offset_output["keys"]["unitOffsetPlans"]["java_expr"], "Tmp.v1.rnd(Mathf.random(despawnUnitRadius))")
        self.assertEqual(create_units_random_offset_output["keys"]["unitOffsetPlans"]["status"], "source-backed")
        self.assertEqual(create_units_random_offset_output["keys"]["createUnitsInitial"]["alias_of"], "create_units_initial_result")

        create_units_spawn_output = source_symbols.state_schema(schema, "create_units_spawn_result")
        self.assertEqual(create_units_spawn_output["keys"]["spawnCalls"]["java_expr"], "despawnUnit.spawn(b.team, x + Tmp.v1.x, y + Tmp.v1.y)")
        self.assertEqual(create_units_spawn_output["keys"]["spawnCalls"]["status"], "source-backed")
        self.assertEqual(create_units_spawn_output["keys"]["createUnitsRandomOffset"]["alias_of"], "create_units_random_offset_result")

        create_units_rotation_output = source_symbols.state_schema(schema, "create_units_rotation_result")
        self.assertEqual(create_units_rotation_output["keys"]["rotationAssignments"]["java_expr"], "u.rotation = faceOutwards ? Tmp.v1.angle() : b.rotation()")
        self.assertEqual(create_units_rotation_output["keys"]["rotationAssignments"]["status"], "source-backed")
        self.assertEqual(create_units_rotation_output["keys"]["createUnitsSpawn"]["alias_of"], "create_units_spawn_result")

        create_units_notify_output = source_symbols.state_schema(schema, "create_units_notify_result")
        self.assertEqual(create_units_notify_output["keys"]["notifyCalls"]["java_expr"], "Units.notifyUnitSpawn(u)")
        self.assertEqual(create_units_notify_output["keys"]["notifyCalls"]["status"], "source-backed")
        self.assertEqual(create_units_notify_output["keys"]["createUnitsRotation"]["alias_of"], "create_units_rotation_result")

        despawned_dispatch_output = source_symbols.state_schema(schema, "despawned_dispatch_result")
        self.assertEqual(despawned_dispatch_output["keys"]["hitCall"]["java_expr"], "hit(b, b.x, b.y, false)")
        self.assertEqual(despawned_dispatch_output["keys"]["hitCall"]["status"], "source-backed")
        self.assertEqual(despawned_dispatch_output["keys"]["createUnitsCall"]["java_expr"], "createUnits(b, b.x, b.y)")
        self.assertEqual(despawned_dispatch_output["keys"]["createUnitsCall"]["status"], "source-backed")
        self.assertEqual(despawned_dispatch_output["keys"]["despawnHit"]["java_expr"], "despawnHit")

        despawned_effect_output = source_symbols.state_schema(schema, "despawned_effect_result")
        self.assertEqual(despawned_effect_output["keys"]["despawnEffectCall"]["java_expr"], "despawnEffect.at(b.x, b.y, b.rotation(), hitColor)")
        self.assertEqual(despawned_effect_output["keys"]["despawnEffectCall"]["status"], "source-backed")
        self.assertEqual(despawned_effect_output["keys"]["despawnedDispatch"]["alias_of"], "despawned_dispatch_result")

        despawn_sound_random_state = source_symbols.state_schema(schema, "despawn_sound_random_state")
        self.assertEqual(despawn_sound_random_state["keys"]["rangeSample"]["java_expr"], "Mathf.range(hitSoundPitchRange)")
        self.assertEqual(despawn_sound_random_state["keys"]["rangeSample"]["status"], "explicit-input")

        despawned_sound_output = source_symbols.state_schema(schema, "despawned_sound_result")
        self.assertEqual(despawned_sound_output["keys"]["despawnSoundCall"]["java_expr"], "despawnSound.at(b, 1f + Mathf.range(hitSoundPitchRange))")
        self.assertEqual(despawned_sound_output["keys"]["despawnSoundCall"]["status"], "source-backed")
        self.assertEqual(despawned_sound_output["keys"]["despawnedEffect"]["alias_of"], "despawned_effect_result")

        bullet_type_state = source_symbols.state_schema(schema, "bullet_type_state")
        self.assertEqual(bullet_type_state["keys"]["despawnShake"]["java_expr"], "despawnShake")
        self.assertEqual(bullet_type_state["keys"]["despawnShake"]["godot_symbol"], "bullet_type_state.despawnShake")
        self.assertEqual(bullet_type_state["keys"]["trailLength"]["java_expr"], "trailLength")
        self.assertEqual(bullet_type_state["keys"]["trailWidth"]["java_expr"], "trailWidth")
        self.assertEqual(bullet_type_state["keys"]["trailColor"]["java_expr"], "trailColor")
        self.assertEqual(bullet_type_state["keys"]["fragOnDespawn"]["java_expr"], "fragOnDespawn")
        self.assertEqual(bullet_type_state["keys"]["lightOpacity"]["java_expr"], "lightOpacity")
        self.assertEqual(bullet_type_state["keys"]["lightRadius"]["java_expr"], "lightRadius")
        self.assertEqual(bullet_type_state["keys"]["lightColor"]["java_expr"], "lightColor")
        self.assertEqual(bullet_type_state["keys"]["killShooter"]["java_expr"], "killShooter")
        self.assertEqual(bullet_type_state["keys"]["instantDisappear"]["java_expr"], "instantDisappear")
        self.assertEqual(bullet_type_state["keys"]["lifetime"]["java_expr"], "lifetime")
        self.assertEqual(bullet_type_state["keys"]["spawnBullets"]["java_expr"], "spawnBullets")
        self.assertEqual(bullet_type_state["keys"]["spawnBulletRandomSpread"]["java_expr"], "spawnBulletRandomSpread")

        owner_health_state = source_symbols.state_schema(schema, "owner_health_state")
        self.assertEqual(owner_health_state["keys"]["isHealthc"]["java_expr"], "b.owner instanceof Healthc o")
        self.assertIn("PortGame.source_bullet_type_init_initial_state", owner_health_state["keys"]["isHealthc"]["used_by"])
        self.assertEqual(owner_health_state["keys"]["dead"]["java_expr"], "h.dead()")

        init_initial_output = source_symbols.state_schema(schema, "init_initial_result")
        self.assertEqual(init_initial_output["keys"]["killShooterApplied"]["java_expr"], "killShooter && b.owner() instanceof Healthc h && !h.dead()")
        self.assertEqual(init_initial_output["keys"]["instantDisappearApplied"]["java_expr"], "instantDisappear")
        self.assertEqual(init_initial_output["keys"]["spawnBulletsDeferred"]["status"], "deferred")

        spawn_random_state = source_symbols.state_schema(schema, "spawn_bullet_random_state")
        self.assertEqual(spawn_random_state["keys"]["offsets"]["java_expr"], "Mathf.range(spawnBulletRandomSpread)")
        self.assertEqual(spawn_random_state["keys"]["offsets"]["status"], "explicit-input")

        init_spawn_output = source_symbols.state_schema(schema, "init_spawn_bullets_result")
        self.assertEqual(init_spawn_output["keys"]["spawnBulletsApplied"]["java_expr"], "spawnBullets.size > 0")
        self.assertEqual(init_spawn_output["keys"]["spawnBulletCalls"]["java_expr"], "bullet.create(b, b.x, b.y, b.rotation() + Mathf.range(spawnBulletRandomSpread))")
        self.assertEqual(init_spawn_output["keys"]["updateBoundarySource"]["status"], "deferred")

        update_dispatch_output = source_symbols.state_schema(schema, "update_dispatch_result")
        self.assertEqual(update_dispatch_output["keys"]["callOrder"]["java_expr"], "updateTrail(b); updateHoming(b); updateWeaving(b); updateTrailEffects(b); updateBulletInterval(b);")
        self.assertEqual(update_dispatch_output["keys"]["updateMethodSource"]["java_expr"], "public void update(Bullet b){")
        self.assertEqual(update_dispatch_output["keys"]["nextMethodReservedSource"]["java_expr"], "public void updateBulletInterval(Bullet b){")
        self.assertEqual(update_dispatch_output["keys"]["nextMethodReservedSource"]["status"], "deferred")

        interval_timer_state = source_symbols.state_schema(schema, "interval_timer_state")
        self.assertEqual(interval_timer_state["keys"]["timerGetResult"]["java_expr"], "b.timer.get(2, bulletInterval)")
        self.assertEqual(interval_timer_state["keys"]["timerGetResult"]["status"], "explicit-input")

        interval_random_state = source_symbols.state_schema(schema, "interval_random_state")
        self.assertEqual(interval_random_state["keys"]["offsets"]["java_expr"], "Mathf.range(intervalRandomSpread)")
        self.assertEqual(interval_random_state["keys"]["offsets"]["status"], "explicit-input")

        update_interval_output = source_symbols.state_schema(schema, "update_bullet_interval_result")
        self.assertEqual(update_interval_output["keys"]["gatePassed"]["java_expr"], "intervalBullet != null && b.time >= intervalDelay && b.timer.get(2, bulletInterval)")
        self.assertEqual(update_interval_output["keys"]["timerIndex"]["java_expr"], "b.timer.get(2, bulletInterval)")
        self.assertEqual(update_interval_output["keys"]["timerTime"]["java_expr"], "bulletInterval")
        self.assertEqual(update_interval_output["keys"]["baseAngle"]["java_expr"], "float ang = b.rotation()")
        self.assertEqual(update_interval_output["keys"]["intervalBulletCount"]["java_expr"], "for(int i = 0; i < intervalBullets; i++)")
        self.assertEqual(update_interval_output["keys"]["intervalBulletCalls"]["java_expr"], "intervalBullet.create(b, b.x, b.y, ang + Mathf.range(intervalRandomSpread) + intervalAngle + ((i - (intervalBullets - 1f)/2f) * intervalSpread))")
        self.assertEqual(update_interval_output["keys"]["updateHomingBoundarySource"]["status"], "deferred")

        bullet_state = source_symbols.state_schema(schema, "bullet_state")
        self.assertIn("PortGame.source_bullet_type_update_bullet_interval_state", bullet_state["keys"]["time"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_bullet_interval_state", bullet_state["keys"]["rotation"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_bullet_interval_state", bullet_state["keys"]["x"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_bullet_interval_state", bullet_state["keys"]["y"]["used_by"])

        bullet_type_state = source_symbols.state_schema(schema, "bullet_type_state")
        self.assertEqual(bullet_type_state["keys"]["intervalBullet"]["java_expr"], "intervalBullet")
        self.assertEqual(bullet_type_state["keys"]["intervalDelay"]["java_expr"], "intervalDelay")
        self.assertEqual(bullet_type_state["keys"]["bulletInterval"]["java_expr"], "bulletInterval")
        self.assertEqual(bullet_type_state["keys"]["intervalBullets"]["java_expr"], "intervalBullets")
        self.assertEqual(bullet_type_state["keys"]["intervalRandomSpread"]["java_expr"], "intervalRandomSpread")
        self.assertEqual(bullet_type_state["keys"]["intervalAngle"]["java_expr"], "intervalAngle")
        self.assertEqual(bullet_type_state["keys"]["intervalSpread"]["java_expr"], "intervalSpread")

        headless_state = source_symbols.state_schema(schema, "headless_state")
        self.assertEqual(headless_state["keys"]["headless"]["java_expr"], "headless")
        self.assertEqual(headless_state["keys"]["headless"]["status"], "explicit-input")

        trail_interp_state = source_symbols.state_schema(schema, "trail_interp_state")
        self.assertEqual(trail_interp_state["keys"]["trailInterpValue"]["java_expr"], "trailInterp.apply(b.fin())")
        self.assertEqual(trail_interp_state["keys"]["trailInterpValue"]["status"], "explicit-input")

        trail_absin_state = source_symbols.state_schema(schema, "trail_absin_state")
        self.assertEqual(trail_absin_state["keys"]["absinValue"]["java_expr"], "Mathf.absin(Time.time, trailSinScl, trailSinMag)")
        self.assertEqual(trail_absin_state["keys"]["absinValue"]["status"], "explicit-input")

        time_state = source_symbols.state_schema(schema, "time_state")
        self.assertEqual(time_state["keys"]["delta"]["java_expr"], "Time.delta")
        self.assertEqual(time_state["keys"]["delta"]["status"], "explicit-input")

        update_trail_output = source_symbols.state_schema(schema, "update_trail_result")
        self.assertEqual(update_trail_output["keys"]["gatePassed"]["java_expr"], "!headless && trailLength > 0")
        self.assertEqual(update_trail_output["keys"]["trailCreated"]["java_expr"], "b.trail == null")
        self.assertEqual(update_trail_output["keys"]["trail"]["java_expr"], "b.trail.update(b.x, b.y, trailInterp.apply(b.fin()) * (1f + (trailSinMag > 0 ? Mathf.absin(Time.time, trailSinScl, trailSinMag) : 0f)))")
        self.assertEqual(update_trail_output["keys"]["width"]["java_expr"], "trailInterp.apply(b.fin()) * (1f + (trailSinMag > 0 ? Mathf.absin(Time.time, trailSinScl, trailSinMag) : 0f))")
        self.assertEqual(update_trail_output["keys"]["initBoundarySource"]["status"], "deferred")

        self.assertIn("PortGame.source_bullet_type_update_trail_state", bullet_state["keys"]["fin"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_trail_state", bullet_state["keys"]["trail"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_trail_state", bullet_state["keys"]["x"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_trail_state", bullet_state["keys"]["y"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_trail_state", bullet_type_state["keys"]["trailLength"]["used_by"])
        self.assertEqual(bullet_type_state["keys"]["trailInterp"]["java_expr"], "trailInterp")
        self.assertEqual(bullet_type_state["keys"]["trailSinMag"]["java_expr"], "trailSinMag")
        self.assertEqual(bullet_type_state["keys"]["trailSinScl"]["java_expr"], "trailSinScl")

        homing_output = source_symbols.state_schema(schema, "update_homing_initial_result")
        self.assertEqual(homing_output["keys"]["gatePassed"]["java_expr"], "homingPower > 0.0001f && b.time >= homingDelay")
        self.assertEqual(homing_output["keys"]["realAimX"]["java_expr"], "float realAimX = b.aimX < 0 ? b.x : b.aimX")
        self.assertEqual(homing_output["keys"]["realAimY"]["java_expr"], "float realAimY = b.aimY < 0 ? b.y : b.aimY")
        self.assertEqual(homing_output["keys"]["targetSelectionDeferred"]["status"], "deferred")
        self.assertEqual(homing_output["keys"]["followAimDeferred"]["status"], "deferred")

        self.assertIn("PortGame.source_bullet_type_update_homing_initial_state", bullet_state["keys"]["time"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_homing_initial_state", bullet_state["keys"]["x"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_homing_initial_state", bullet_state["keys"]["y"]["used_by"])
        self.assertEqual(bullet_state["keys"]["aimX"]["java_expr"], "b.aimX")
        self.assertEqual(bullet_state["keys"]["aimY"]["java_expr"], "b.aimY")
        self.assertEqual(bullet_type_state["keys"]["homingPower"]["java_expr"], "homingPower")
        self.assertEqual(bullet_type_state["keys"]["homingDelay"]["java_expr"], "homingDelay")
        self.assertEqual(bullet_type_state["keys"]["homingRange"]["java_expr"], "homingRange")
        self.assertEqual(bullet_type_state["keys"]["followAimSpeed"]["java_expr"], "followAimSpeed")

        target_state = source_symbols.state_schema(schema, "target_state")
        self.assertEqual(target_state["keys"]["x"]["java_expr"], "target.getX()")
        self.assertEqual(target_state["keys"]["y"]["java_expr"], "target.getY()")

        homing_target_velocity_output = source_symbols.state_schema(schema, "update_homing_target_velocity_result")
        self.assertEqual(homing_target_velocity_output["keys"]["targetGatePassed"]["java_expr"], "target != null")
        self.assertEqual(homing_target_velocity_output["keys"]["currentRotation"]["java_expr"], "b.rotation()")
        self.assertEqual(homing_target_velocity_output["keys"]["targetAngle"]["java_expr"], "b.angleTo(target)")
        self.assertEqual(homing_target_velocity_output["keys"]["maxTurn"]["java_expr"], "homingPower * Time.delta * 50f")
        self.assertEqual(homing_target_velocity_output["keys"]["nextAngle"]["java_expr"], "Angles.moveToward(b.rotation(), b.angleTo(target), homingPower * Time.delta * 50f)")
        self.assertEqual(homing_target_velocity_output["keys"]["velocity"]["java_expr"], "b.vel.setAngle(Angles.moveToward(b.rotation(), b.angleTo(target), homingPower * Time.delta * 50f))")
        self.assertEqual(homing_target_velocity_output["keys"]["targetGateSource"]["alias_of"], "source_line.update_homing_target_velocity.target_gate")

        self.assertIn("PortGame.source_bullet_type_update_homing_target_velocity_state", bullet_state["keys"]["x"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_homing_target_velocity_state", bullet_state["keys"]["y"]["used_by"])
        self.assertEqual(bullet_state["keys"]["velocity"]["java_expr"], "b.vel")
        self.assertEqual(bullet_state["keys"]["rotation"]["java_expr"], "b.rotation()")

        shooter_state = source_symbols.state_schema(schema, "shooter_state")
        self.assertEqual(shooter_state["keys"]["isUnit"]["java_expr"], "b.shooter instanceof Unit u")
        self.assertEqual(shooter_state["keys"]["aimX"]["java_expr"], "u.aimX")
        self.assertEqual(shooter_state["keys"]["aimY"]["java_expr"], "u.aimY")

        homing_follow_aim_output = source_symbols.state_schema(schema, "update_homing_follow_aim_result")
        self.assertEqual(homing_follow_aim_output["keys"]["followAimGatePassed"]["java_expr"], "followAimSpeed > 0f && b.shooter instanceof Unit u")
        self.assertEqual(homing_follow_aim_output["keys"]["currentVelocityAngle"]["java_expr"], "b.vel.angle()")
        self.assertEqual(homing_follow_aim_output["keys"]["targetAngle"]["java_expr"], "float angle = b.angleTo(u.aimX, u.aimY)")
        self.assertEqual(homing_follow_aim_output["keys"]["maxTurn"]["java_expr"], "followAimSpeed * Time.delta")
        self.assertEqual(homing_follow_aim_output["keys"]["nextAngle"]["java_expr"], "Angles.moveToward(b.vel.angle(), angle, followAimSpeed * Time.delta)")
        self.assertEqual(homing_follow_aim_output["keys"]["velocity"]["java_expr"], "b.vel.setAngle(Angles.moveToward(b.vel.angle(), angle, followAimSpeed * Time.delta))")
        self.assertEqual(homing_follow_aim_output["keys"]["followAimGateSource"]["alias_of"], "source_line.update_homing_follow_aim.gate")

        self.assertIn("PortGame.source_bullet_type_update_homing_follow_aim_state", bullet_type_state["keys"]["followAimSpeed"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_homing_follow_aim_state", bullet_state["keys"]["x"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_homing_follow_aim_state", bullet_state["keys"]["y"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_homing_follow_aim_state", bullet_state["keys"]["velocity"]["used_by"])

        random_seed_state = source_symbols.state_schema(schema, "random_seed_state")
        self.assertEqual(random_seed_state["keys"]["randomSeedResult"]["java_expr"], "Mathf.randomSeed(b.id, 0, 1)")

        update_weaving_output = source_symbols.state_schema(schema, "update_weaving_result")
        self.assertEqual(update_weaving_output["keys"]["weaveGatePassed"]["java_expr"], "weaveMag != 0")
        self.assertEqual(update_weaving_output["keys"]["rotationRadians"]["java_expr"], "(float)Math.sin((b.time + Math.PI * weaveScale/2f) / weaveScale) * weaveMag * (weaveRandom ? (Mathf.randomSeed(b.id, 0, 1) == 1 ? -1 : 1) : 1f) * Time.delta * Mathf.degRad")
        self.assertEqual(update_weaving_output["keys"]["velocity"]["java_expr"], "b.vel.rotateRadExact((float)Math.sin((b.time + Math.PI * weaveScale/2f) / weaveScale) * weaveMag * (weaveRandom ? (Mathf.randomSeed(b.id, 0, 1) == 1 ? -1 : 1) : 1f) * Time.delta * Mathf.degRad)")
        self.assertEqual(update_weaving_output["keys"]["weaveGateSource"]["alias_of"], "source_line.update_weaving.gate")

        self.assertIn("PortGame.source_bullet_type_update_weaving_state", bullet_state["keys"]["id"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_weaving_state", bullet_state["keys"]["time"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_weaving_state", bullet_state["keys"]["velocity"]["used_by"])
        self.assertEqual(bullet_type_state["keys"]["weaveMag"]["java_expr"], "weaveMag")
        self.assertEqual(bullet_type_state["keys"]["weaveScale"]["java_expr"], "weaveScale")
        self.assertEqual(bullet_type_state["keys"]["weaveRandom"]["java_expr"], "weaveRandom")

        update_weaving_rotate_speed_output = source_symbols.state_schema(schema, "update_weaving_rotate_speed_result")
        self.assertEqual(update_weaving_rotate_speed_output["keys"]["rotateSpeedGatePassed"]["java_expr"], "rotateSpeed != 0")
        self.assertEqual(update_weaving_rotate_speed_output["keys"]["rotationRadians"]["java_expr"], "rotateSpeed * Time.delta")
        self.assertEqual(update_weaving_rotate_speed_output["keys"]["velocity"]["java_expr"], "b.vel.rotate(rotateSpeed * Time.delta)")
        self.assertEqual(update_weaving_rotate_speed_output["keys"]["rotateSpeedGateSource"]["alias_of"], "source_line.update_weaving_rotate_speed.gate")

        self.assertIn("PortGame.source_bullet_type_update_weaving_rotate_speed_state", bullet_state["keys"]["velocity"]["used_by"])
        self.assertEqual(bullet_type_state["keys"]["rotateSpeed"]["java_expr"], "rotateSpeed")

        owner_health_state = source_symbols.state_schema(schema, "owner_health_state")
        update_weaving_circle_shooter_output = source_symbols.state_schema(schema, "update_weaving_circle_shooter_result")
        self.assertEqual(update_weaving_circle_shooter_output["keys"]["circleShooterGatePassed"]["java_expr"], "circleShooter && b.owner instanceof Healthc h && h.isValid()")
        self.assertEqual(update_weaving_circle_shooter_output["keys"]["tmpBeforeRotate"]["java_expr"], "Tmp.v1.set(h).sub(b)")
        self.assertEqual(update_weaving_circle_shooter_output["keys"]["rotationDegrees"]["java_expr"], "90f * Mathf.lerp(0f, 1f, 1f - Mathf.clamp((Tmp.v1.len() - circleShooterRadius) / circleShooterRadiusSmooth))")
        self.assertEqual(update_weaving_circle_shooter_output["keys"]["tmpLimit"]["java_expr"], "speed * circleShooterRotateSpeed * Time.delta")
        self.assertEqual(update_weaving_circle_shooter_output["keys"]["velocity"]["java_expr"], "b.vel.add(Tmp.v1.limit(speed * circleShooterRotateSpeed * Time.delta)).limit(speed)")
        self.assertEqual(update_weaving_circle_shooter_output["keys"]["circleShooterGateSource"]["alias_of"], "source_line.update_weaving_circle_shooter.gate")

        self.assertIn("PortGame.source_bullet_type_update_weaving_circle_shooter_state", bullet_state["keys"]["x"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_weaving_circle_shooter_state", bullet_state["keys"]["y"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_weaving_circle_shooter_state", bullet_state["keys"]["velocity"]["used_by"])
        self.assertEqual(bullet_type_state["keys"]["circleShooter"]["java_expr"], "circleShooter")
        self.assertEqual(bullet_type_state["keys"]["circleShooterRadius"]["java_expr"], "circleShooterRadius")
        self.assertEqual(bullet_type_state["keys"]["circleShooterRadiusSmooth"]["java_expr"], "circleShooterRadiusSmooth")
        self.assertEqual(bullet_type_state["keys"]["circleShooterRotateSpeed"]["java_expr"], "circleShooterRotateSpeed")
        self.assertIn("PortGame.source_bullet_type_update_weaving_circle_shooter_state", owner_health_state["keys"]["isHealthc"]["used_by"])
        self.assertEqual(owner_health_state["keys"]["isValid"]["java_expr"], "h.isValid()")
        self.assertEqual(owner_health_state["keys"]["x"]["java_expr"], "h.getX()")
        self.assertEqual(owner_health_state["keys"]["y"]["java_expr"], "h.getY()")

        chance_delta_state = source_symbols.state_schema(schema, "chance_delta_state")
        self.assertEqual(chance_delta_state["keys"]["chanceDeltaResult"]["java_expr"], "Mathf.chanceDelta(trailChance)")
        self.assertEqual(chance_delta_state["keys"]["chanceDeltaResult"]["status"], "explicit-input")

        random_offset_state = source_symbols.state_schema(schema, "random_offset_state")
        self.assertEqual(random_offset_state["keys"]["x"]["java_expr"], "Tmp.v1.x")
        self.assertEqual(random_offset_state["keys"]["y"]["java_expr"], "Tmp.v1.y")

        update_trail_effects_chance_output = source_symbols.state_schema(schema, "update_trail_effects_chance_result")
        self.assertEqual(update_trail_effects_chance_output["keys"]["canSpawn"]["java_expr"], "trailMinVelocity <= 0f || b.vel.len2() >= trailMinVelocity * trailMinVelocity")
        self.assertEqual(update_trail_effects_chance_output["keys"]["chanceGatePassed"]["java_expr"], "trailChance > 0 && canSpawn")
        self.assertEqual(update_trail_effects_chance_output["keys"]["chanceDeltaResult"]["alias_of"], "chance_delta_state.chanceDeltaResult")
        self.assertEqual(update_trail_effects_chance_output["keys"]["tmpOffset"]["java_expr"], "Tmp.v1.rnd(Mathf.random(trailSpread)) or Tmp.v1.setZero()")
        self.assertEqual(update_trail_effects_chance_output["keys"]["effectCalls"]["java_expr"], "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor)")
        self.assertEqual(update_trail_effects_chance_output["keys"]["chanceGateSource"]["alias_of"], "source_line.update_trail_effects_chance.chance_gate")

        self.assertIn("PortGame.source_bullet_type_update_trail_effects_chance_state", bullet_state["keys"]["x"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_trail_effects_chance_state", bullet_state["keys"]["y"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_trail_effects_chance_state", bullet_state["keys"]["velocity"]["used_by"])
        self.assertEqual(bullet_type_state["keys"]["trailChance"]["java_expr"], "trailChance")
        self.assertEqual(bullet_type_state["keys"]["trailMinVelocity"]["java_expr"], "trailMinVelocity")
        self.assertEqual(bullet_type_state["keys"]["trailEffect"]["java_expr"], "trailEffect")
        self.assertEqual(bullet_type_state["keys"]["trailSpread"]["java_expr"], "trailSpread")
        self.assertEqual(bullet_type_state["keys"]["trailParam"]["java_expr"], "trailParam")
        self.assertEqual(bullet_type_state["keys"]["trailRotation"]["java_expr"], "trailRotation")
        self.assertEqual(bullet_type_state["keys"]["trailColor"]["java_expr"], "trailColor")

        trail_effects_timer_state = source_symbols.state_schema(schema, "trail_effects_timer_state")
        self.assertEqual(trail_effects_timer_state["keys"]["timerGetResult"]["java_expr"], "b.timer(0, trailInterval)")
        self.assertEqual(trail_effects_timer_state["keys"]["timerGetResult"]["status"], "explicit-input")

        update_trail_effects_interval_output = source_symbols.state_schema(schema, "update_trail_effects_interval_result")
        self.assertEqual(update_trail_effects_interval_output["keys"]["intervalGatePassed"]["java_expr"], "trailInterval > 0f && canSpawn")
        self.assertEqual(update_trail_effects_interval_output["keys"]["timerGetResult"]["alias_of"], "trail_effects_timer_state.timerGetResult")
        self.assertEqual(update_trail_effects_interval_output["keys"]["tmpOffset"]["java_expr"], "Tmp.v1.rnd(Mathf.random(trailSpread)) or Tmp.v1.setZero()")
        self.assertEqual(update_trail_effects_interval_output["keys"]["effectCalls"]["java_expr"], "trailEffect.at(b.x + Tmp.v1.x, b.y + Tmp.v1.y, trailRotation ? b.rotation() : trailParam, trailColor)")
        self.assertEqual(update_trail_effects_interval_output["keys"]["intervalGateSource"]["alias_of"], "source_line.update_trail_effects_interval.interval_gate")
        self.assertEqual(update_trail_effects_interval_output["keys"]["timerSource"]["alias_of"], "source_line.update_trail_effects_interval.timer_call")

        self.assertEqual(bullet_type_state["keys"]["trailInterval"]["java_expr"], "trailInterval")
        self.assertIn("PortGame.source_bullet_type_update_trail_effects_interval_state", bullet_type_state["keys"]["trailSpread"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_trail_effects_interval_state", bullet_type_state["keys"]["trailParam"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_trail_effects_interval_state", bullet_type_state["keys"]["trailRotation"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_update_trail_effects_interval_state", bullet_type_state["keys"]["trailColor"]["used_by"])

        init_type_defaults_output = source_symbols.state_schema(schema, "init_type_defaults_result")
        self.assertEqual(init_type_defaults_output["keys"]["pierceApplied"]["java_expr"], "pierceCap >= 1")
        self.assertEqual(init_type_defaults_output["keys"]["setDefaults"]["alias_of"], "bullet_type_state.setDefaults")
        self.assertEqual(init_type_defaults_output["keys"]["lightning"]["alias_of"], "bullet_type_state.lightning")
        self.assertEqual(init_type_defaults_output["keys"]["statusBefore"]["alias_of"], "bullet_type_state.status")
        self.assertEqual(init_type_defaults_output["keys"]["statusShockedApplied"]["java_expr"], "setDefaults && lightning > 0 && status == StatusEffects.none")
        self.assertEqual(init_type_defaults_output["keys"]["despawnHitApplied"]["java_expr"], "setDefaults && (fragBullet != null || splashDamageRadius > 0 || lightning > 0)")
        self.assertEqual(init_type_defaults_output["keys"]["pierceGateSource"]["alias_of"], "source_line.init_type_defaults.pierce_gate")
        self.assertEqual(init_type_defaults_output["keys"]["despawnHitAssignSource"]["alias_of"], "source_line.init_type_defaults.despawn_hit_assign")

        self.assertEqual(bullet_type_state["keys"]["pierceCap"]["java_expr"], "pierceCap")
        self.assertEqual(bullet_type_state["keys"]["setDefaults"]["java_expr"], "setDefaults")
        self.assertEqual(bullet_type_state["keys"]["lightning"]["java_expr"], "lightning")
        self.assertIn("PortGame.source_bullet_type_init_type_defaults_state", bullet_type_state["keys"]["status"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_init_type_defaults_state", bullet_type_state["keys"]["fragBullet"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_init_type_defaults_state", bullet_type_state["keys"]["splashDamageRadius"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_init_type_defaults_state", bullet_type_state["keys"]["despawnHit"]["used_by"])

        init_frag_velocity_output = source_symbols.state_schema(schema, "init_frag_velocity_result")
        self.assertEqual(init_frag_velocity_output["keys"]["fragGatePassed"]["java_expr"], "fragBullet != null")
        self.assertEqual(init_frag_velocity_output["keys"]["fragBulletVelocityApplied"]["alias_of"], "init_frag_velocity_result.fragBullet")
        self.assertEqual(init_frag_velocity_output["keys"]["fragBullet"]["java_expr"], "fragBullet.keepVelocity = false; fragBullet.scaleKeepVelocity = false;")
        self.assertEqual(init_frag_velocity_output["keys"]["fragGateSource"]["alias_of"], "source_line.init_frag_velocity.frag_gate")
        self.assertEqual(init_frag_velocity_output["keys"]["fragScaleKeepVelocitySource"]["alias_of"], "source_line.init_frag_velocity.frag_scale_keep_velocity_assign")

        self.assertEqual(bullet_type_state["keys"]["keepVelocity"]["java_expr"], "keepVelocity")
        self.assertEqual(bullet_type_state["keys"]["scaleKeepVelocity"]["java_expr"], "scaleKeepVelocity")
        self.assertIn("PortGame.source_bullet_type_init_frag_velocity_state", bullet_type_state["keys"]["fragBullet"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_init_frag_velocity_state", bullet_type_state["keys"]["keepVelocity"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_init_frag_velocity_state", bullet_type_state["keys"]["scaleKeepVelocity"]["used_by"])

        init_lightning_type_output = source_symbols.state_schema(schema, "init_lightning_type_result")
        self.assertEqual(init_lightning_type_output["keys"]["lightningTypeGatePassed"]["java_expr"], "lightningType == null")
        self.assertEqual(init_lightning_type_output["keys"]["lightningType"]["java_expr"], "!collidesAir ? Bullets.damageLightningGround : !collidesGround ? Bullets.damageLightningAir : Bullets.damageLightning")
        self.assertEqual(init_lightning_type_output["keys"]["collidesAir"]["alias_of"], "bullet_type_state.collidesAir")
        self.assertEqual(init_lightning_type_output["keys"]["collidesGround"]["alias_of"], "bullet_type_state.collidesGround")
        self.assertEqual(init_lightning_type_output["keys"]["lightningTypeChoiceSource"]["alias_of"], "source_line.init_lightning_type.choice")

        self.assertEqual(bullet_type_state["keys"]["lightningType"]["java_expr"], "lightningType")
        self.assertEqual(bullet_type_state["keys"]["collidesAir"]["java_expr"], "collidesAir")
        self.assertEqual(bullet_type_state["keys"]["collidesGround"]["java_expr"], "collidesGround")
        self.assertIn("PortGame.source_bullet_type_init_lightning_type_state", bullet_type_state["keys"]["lightningType"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_init_lightning_type_state", bullet_type_state["keys"]["collidesAir"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_init_lightning_type_state", bullet_type_state["keys"]["collidesGround"]["used_by"])

        init_light_radius_output = source_symbols.state_schema(schema, "init_light_radius_result")
        self.assertEqual(init_light_radius_output["keys"]["lightRadiusGatePassed"]["java_expr"], "lightRadius <= -1")
        self.assertEqual(init_light_radius_output["keys"]["lightRadius"]["java_expr"], "Math.max(18, hitSize * 5f)")
        self.assertEqual(init_light_radius_output["keys"]["hitSize"]["alias_of"], "bullet_type_state.hitSize")
        self.assertEqual(init_light_radius_output["keys"]["lightRadiusGateSource"]["alias_of"], "source_line.init_light_radius.gate")
        self.assertEqual(init_light_radius_output["keys"]["lightRadiusAssignSource"]["alias_of"], "source_line.init_light_radius.assign")

        self.assertEqual(bullet_type_state["keys"]["hitSize"]["java_expr"], "hitSize")
        self.assertEqual(bullet_type_state["keys"]["lightRadius"]["java_expr"], "lightRadius")
        self.assertIn("PortGame.source_bullet_type_init_light_radius_state", bullet_type_state["keys"]["hitSize"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_init_light_radius_state", bullet_type_state["keys"]["lightRadius"]["used_by"])

        init_draw_size_output = source_symbols.state_schema(schema, "init_draw_size_result")
        self.assertEqual(init_draw_size_output["keys"]["drawSize"]["java_expr"], "Math.max(drawSize, trailLength * speed * 2f)")
        self.assertEqual(init_draw_size_output["keys"]["drawSizeBefore"]["alias_of"], "bullet_type_state.drawSize")
        self.assertEqual(init_draw_size_output["keys"]["computedDrawSize"]["java_expr"], "trailLength * speed * 2f")
        self.assertEqual(init_draw_size_output["keys"]["trailLength"]["alias_of"], "bullet_type_state.trailLength")
        self.assertEqual(init_draw_size_output["keys"]["speed"]["alias_of"], "bullet_type_state.speed")
        self.assertEqual(init_draw_size_output["keys"]["drawSizeAssignSource"]["alias_of"], "source_line.init_draw_size.assign")

        self.assertEqual(bullet_type_state["keys"]["drawSize"]["java_expr"], "drawSize")
        self.assertEqual(bullet_type_state["keys"]["trailLength"]["java_expr"], "trailLength")
        self.assertEqual(bullet_type_state["keys"]["speed"]["java_expr"], "speed")
        self.assertIn("PortGame.source_bullet_type_init_draw_size_state", bullet_type_state["keys"]["drawSize"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_init_draw_size_state", bullet_type_state["keys"]["trailLength"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_init_draw_size_state", bullet_type_state["keys"]["speed"]["used_by"])

        init_range_assignment_output = source_symbols.state_schema(schema, "init_range_assignment_result")
        self.assertEqual(init_range_assignment_output["keys"]["range"]["java_expr"], "calculateRange()")
        self.assertEqual(init_range_assignment_output["keys"]["rangeBefore"]["alias_of"], "bullet_type_state.range")
        self.assertEqual(init_range_assignment_output["keys"]["calculateRangeDeferred"]["alias_of"], "source_line.init_range_assignment.calculate_range_method")
        self.assertEqual(init_range_assignment_output["keys"]["rangeAssignSource"]["alias_of"], "source_line.init_range_assignment.assign")

        calculate_range_result = source_symbols.state_schema(schema, "calculate_range_result")
        self.assertEqual(calculate_range_result["keys"]["range"]["java_expr"], "calculateRange()")
        self.assertEqual(calculate_range_result["keys"]["range"]["status"], "explicit-input")

        self.assertEqual(bullet_type_state["keys"]["range"]["java_expr"], "range")
        self.assertIn("PortGame.source_bullet_type_init_range_assignment_state", bullet_type_state["keys"]["range"]["used_by"])

        calculate_range_override_output = source_symbols.state_schema(schema, "calculate_range_override_result")
        self.assertEqual(calculate_range_override_output["keys"]["rangeOverride"]["alias_of"], "bullet_type_state.rangeOverride")
        self.assertEqual(calculate_range_override_output["keys"]["rangeOverrideGatePassed"]["java_expr"], "rangeOverride > 0")
        self.assertEqual(calculate_range_override_output["keys"]["returnEarly"]["java_expr"], "rangeOverride > 0")
        self.assertEqual(calculate_range_override_output["keys"]["range"]["java_expr"], "rangeOverride")
        self.assertEqual(calculate_range_override_output["keys"]["rangeOverrideReturnSource"]["alias_of"], "source_line.calculate_range_override.gate_return")

        self.assertEqual(bullet_type_state["keys"]["rangeOverride"]["java_expr"], "rangeOverride")
        self.assertIn("PortGame.source_bullet_type_calculate_range_override_state", bullet_type_state["keys"]["rangeOverride"]["used_by"])

        calculate_range_spawn_unit_output = source_symbols.state_schema(schema, "calculate_range_spawn_unit_result")
        self.assertEqual(calculate_range_spawn_unit_output["keys"]["spawnUnitRangeGatePassed"]["java_expr"], "spawnUnit != null")
        self.assertEqual(calculate_range_spawn_unit_output["keys"]["returnEarly"]["java_expr"], "spawnUnit != null")
        self.assertEqual(calculate_range_spawn_unit_output["keys"]["range"]["java_expr"], "spawnUnit.lifetime * spawnUnit.speed")
        self.assertEqual(calculate_range_spawn_unit_output["keys"]["spawnUnit"]["alias_of"], "bullet_type_state.spawnUnit")
        self.assertEqual(calculate_range_spawn_unit_output["keys"]["spawnUnitReturnSource"]["alias_of"], "source_line.calculate_range_spawn_unit.gate_return")

        unit_type_state = source_symbols.state_schema(schema, "unit_type_state")
        self.assertEqual(unit_type_state["keys"]["lifetime"]["java_expr"], "lifetime")
        self.assertEqual(unit_type_state["keys"]["speed"]["java_expr"], "speed")

        self.assertEqual(bullet_type_state["keys"]["spawnUnit"]["java_expr"], "spawnUnit")
        self.assertIn("PortGame.source_bullet_type_calculate_range_spawn_unit_state", bullet_type_state["keys"]["spawnUnit"]["used_by"])

        calculate_range_despawn_unit_output = source_symbols.state_schema(schema, "calculate_range_despawn_unit_result")
        self.assertEqual(calculate_range_despawn_unit_output["keys"]["despawnUnitRangeGatePassed"]["java_expr"], "despawnUnit != null")
        self.assertEqual(calculate_range_despawn_unit_output["keys"]["returnEarly"]["java_expr"], "despawnUnit != null")
        self.assertEqual(calculate_range_despawn_unit_output["keys"]["range"]["java_expr"], "despawnUnit.lifetime * despawnUnit.speed")
        self.assertEqual(calculate_range_despawn_unit_output["keys"]["despawnUnit"]["alias_of"], "bullet_type_state.despawnUnit")
        self.assertEqual(calculate_range_despawn_unit_output["keys"]["despawnUnitReturnSource"]["alias_of"], "source_line.calculate_range_despawn_unit.gate_return")

        self.assertEqual(bullet_type_state["keys"]["despawnUnit"]["java_expr"], "despawnUnit")
        self.assertIn("PortGame.source_bullet_type_calculate_range_despawn_unit_state", bullet_type_state["keys"]["despawnUnit"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_calculate_range_despawn_unit_state", unit_type_state["keys"]["lifetime"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_calculate_range_despawn_unit_state", unit_type_state["keys"]["speed"]["used_by"])

        calculate_range_fallback_output = source_symbols.state_schema(schema, "calculate_range_fallback_result")
        self.assertEqual(calculate_range_fallback_output["keys"]["fallbackRangeGatePassed"]["java_expr"], "rangeOverride <= 0 && spawnUnit == null && despawnUnit == null")
        self.assertEqual(calculate_range_fallback_output["keys"]["zeroDrag"]["java_expr"], "Mathf.zero(drag)")
        self.assertEqual(calculate_range_fallback_output["keys"]["fallbackRange"]["java_expr"], "Mathf.zero(drag) ? speed * lifetime : speed * (1f - Mathf.pow(1f - drag, lifetime)) / drag")
        self.assertEqual(calculate_range_fallback_output["keys"]["range"]["java_expr"], "Math.max(fallbackRange, maxRange)")
        self.assertEqual(calculate_range_fallback_output["keys"]["drag"]["alias_of"], "bullet_type_state.drag")
        self.assertEqual(calculate_range_fallback_output["keys"]["maxRange"]["alias_of"], "bullet_type_state.maxRange")
        self.assertEqual(calculate_range_fallback_output["keys"]["fallbackReturnSource"]["alias_of"], "source_line.calculate_range_fallback.return_expr")

        self.assertEqual(bullet_type_state["keys"]["drag"]["java_expr"], "drag")
        self.assertEqual(bullet_type_state["keys"]["maxRange"]["java_expr"], "maxRange")
        self.assertIn("PortGame.source_bullet_type_calculate_range_fallback_state", bullet_type_state["keys"]["speed"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_calculate_range_fallback_state", bullet_type_state["keys"]["lifetime"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_calculate_range_fallback_state", bullet_type_state["keys"]["drag"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_calculate_range_fallback_state", bullet_type_state["keys"]["maxRange"]["used_by"])

        continuous_damage_default_output = source_symbols.state_schema(schema, "continuous_damage_default_result")
        self.assertEqual(continuous_damage_default_output["keys"]["continuousDamage"]["java_expr"], "return -1f;")
        self.assertEqual(continuous_damage_default_output["keys"]["continuousDamageReturnSource"]["alias_of"], "source_line.continuous_damage_default.return_expr")
        self.assertEqual(continuous_damage_default_output["keys"]["bulletType"]["alias_of"], "bullet_type_state")

        heals_output = source_symbols.state_schema(schema, "heals_result")
        self.assertEqual(heals_output["keys"]["heals"]["java_expr"], "healPercent > 0 || healAmount > 0")
        self.assertEqual(heals_output["keys"]["healPercent"]["alias_of"], "bullet_type_state.healPercent")
        self.assertEqual(heals_output["keys"]["healAmount"]["alias_of"], "bullet_type_state.healAmount")
        self.assertEqual(heals_output["keys"]["healsReturnSource"]["alias_of"], "source_line.heals.return_expr")
        self.assertEqual(heals_output["keys"]["bulletType"]["alias_of"], "bullet_type_state")

        self.assertEqual(bullet_type_state["keys"]["healPercent"]["java_expr"], "healPercent")
        self.assertEqual(bullet_type_state["keys"]["healAmount"]["java_expr"], "healAmount")
        self.assertIn("PortGame.source_bullet_type_heals_state", bullet_type_state["keys"]["healPercent"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_heals_state", bullet_type_state["keys"]["healAmount"]["used_by"])

        create_call_state = source_symbols.state_schema(schema, "create_call_state")
        self.assertEqual(create_call_state["keys"]["bulletContinues"]["status"], "explicit-input")
        self.assertEqual(create_call_state["keys"]["bulletCreateCall"]["status"], "explicit-input")

        create_initial_gate_output = source_symbols.state_schema(schema, "create_initial_gate_result")
        self.assertEqual(create_initial_gate_output["keys"]["angle"]["java_expr"], "angle += angleOffset + Mathf.range(randomAngleOffset)")
        self.assertEqual(create_initial_gate_output["keys"]["createChancePassed"]["java_expr"], "Mathf.chance(createChance)")
        self.assertEqual(create_initial_gate_output["keys"]["ignoreSpawnAngleApplied"]["java_expr"], "ignoreSpawnAngle")
        self.assertEqual(create_initial_gate_output["keys"]["bulletCreateReturnsNull"]["java_expr"], "!Mathf.chance(createChance)")
        self.assertEqual(create_initial_gate_output["keys"]["angleOffset"]["alias_of"], "bullet_type_state.angleOffset")
        self.assertEqual(create_initial_gate_output["keys"]["randomAngleOffset"]["alias_of"], "create_initial_gate_input.randomAngleOffsetSample")
        self.assertEqual(create_initial_gate_output["keys"]["createChance"]["alias_of"], "bullet_type_state.createChance")
        self.assertEqual(create_initial_gate_output["keys"]["angleOffsetSource"]["alias_of"], "source_line.create_initial_gate.angle_offset_assignment")
        self.assertEqual(create_initial_gate_output["keys"]["spawnUnitReservedSource"]["alias_of"], "source_line.create_initial_gate.spawn_unit_boundary")

        self.assertEqual(bullet_type_state["keys"]["angleOffset"]["java_expr"], "angleOffset")
        self.assertEqual(bullet_type_state["keys"]["randomAngleOffset"]["java_expr"], "randomAngleOffset")
        self.assertEqual(bullet_type_state["keys"]["createChance"]["java_expr"], "createChance")
        self.assertEqual(bullet_type_state["keys"]["ignoreSpawnAngle"]["java_expr"], "ignoreSpawnAngle")
        self.assertIn("PortGame.source_bullet_type_create_initial_gate_state", bullet_type_state["keys"]["angleOffset"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_create_initial_gate_state", bullet_type_state["keys"]["randomAngleOffset"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_create_initial_gate_state", bullet_type_state["keys"]["createChance"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_create_initial_gate_state", bullet_type_state["keys"]["ignoreSpawnAngle"]["used_by"])

        create_spawn_unit_output = source_symbols.state_schema(schema, "create_spawn_unit_result")
        self.assertEqual(create_spawn_unit_output["keys"]["spawnUnitBranchEntered"]["java_expr"], "spawnUnit != null")
        self.assertEqual(create_spawn_unit_output["keys"]["spawnSkippedClient"]["java_expr"], "net.client()")
        self.assertEqual(create_spawn_unit_output["keys"]["spawnedUnit"]["java_expr"], "Unit spawned = spawnUnit.create(team)")
        self.assertEqual(create_spawn_unit_output["keys"]["ownerKilled"]["java_expr"], "killShooter && owner instanceof Healthc h && !h.dead()")
        self.assertEqual(create_spawn_unit_output["keys"]["bulletCreateReturnsNull"]["java_expr"], "return null;")
        self.assertEqual(create_spawn_unit_output["keys"]["bulletCreationReservedSource"]["alias_of"], "source_line.create_spawn_unit.bullet_create_boundary")

        self.assertIn("PortGame.source_bullet_type_create_spawn_unit_state", bullet_type_state["keys"]["spawnUnit"]["used_by"])
        self.assertEqual(bullet_type_state["keys"]["killShooter"]["java_expr"], "killShooter")
        self.assertIn("PortGame.source_bullet_type_create_spawn_unit_state", bullet_type_state["keys"]["killShooter"]["used_by"])
        self.assertEqual(owner_health_state["keys"]["dead"]["java_expr"], "h.dead()")
        self.assertIn("PortGame.source_bullet_type_create_spawn_unit_state", owner_health_state["keys"]["isHealthc"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_create_spawn_unit_state", owner_health_state["keys"]["dead"]["used_by"])

        create_bullet_identity_output = source_symbols.state_schema(schema, "create_bullet_identity_result")
        self.assertEqual(create_bullet_identity_output["keys"]["bullet"]["java_expr"], "Bullet bullet = Bullet.create()")
        self.assertEqual(create_bullet_identity_output["keys"]["bulletAllocated"]["alias_of"], "Bullet bullet = Bullet.create()")
        self.assertEqual(create_bullet_identity_output["keys"]["typeSource"]["alias_of"], "source_line.create_bullet_identity.type_assignment")
        self.assertEqual(create_bullet_identity_output["keys"]["ownerSource"]["alias_of"], "source_line.create_bullet_identity.owner_assignment")
        self.assertEqual(create_bullet_identity_output["keys"]["shooterSource"]["alias_of"], "source_line.create_bullet_identity.shooter_assignment")
        self.assertEqual(create_bullet_identity_output["keys"]["teamSource"]["alias_of"], "source_line.create_bullet_identity.team_assignment")
        self.assertEqual(create_bullet_identity_output["keys"]["timeSource"]["alias_of"], "source_line.create_bullet_identity.time_assignment")
        self.assertEqual(create_bullet_identity_output["keys"]["originXSource"]["alias_of"], "source_line.create_bullet_identity.origin_x_assignment")
        self.assertEqual(create_bullet_identity_output["keys"]["originYSource"]["alias_of"], "source_line.create_bullet_identity.origin_y_assignment")
        self.assertEqual(create_bullet_identity_output["keys"]["aimTileReservedSource"]["alias_of"], "source_line.create_bullet_identity.aim_tile_boundary")

        create_aim_output = source_symbols.state_schema(schema, "create_aim_result")
        self.assertEqual(create_aim_output["keys"]["hasAimTile"]["java_expr"], "!(aimX == -1f && aimY == -1f)")
        self.assertEqual(create_aim_output["keys"]["bullet"]["alias_of"], "create_bullet_identity_result.bullet")
        self.assertEqual(create_aim_output["keys"]["bulletAimApplied"]["alias_of"], "bullet.aimX = aimX; bullet.aimY = aimY;")
        self.assertEqual(create_aim_output["keys"]["aimTileSource"]["alias_of"], "source_line.create_aim.aim_tile_assignment")
        self.assertEqual(create_aim_output["keys"]["aimXSource"]["alias_of"], "source_line.create_aim.aim_x_assignment")
        self.assertEqual(create_aim_output["keys"]["aimYSource"]["alias_of"], "source_line.create_aim.aim_y_assignment")
        self.assertEqual(create_aim_output["keys"]["worldTileWorldSource"]["alias_of"], "source_line.create_aim.world_tile_world")
        self.assertEqual(create_aim_output["keys"]["initVelReservedSource"]["alias_of"], "source_line.create_aim.init_vel_boundary")

        create_velocity_position_output = source_symbols.state_schema(schema, "create_velocity_position_result")
        self.assertEqual(create_velocity_position_output["keys"]["bulletVelocityPositionApplied"]["alias_of"], "bullet.initVel(...); bullet.set(x, y); bullet.lastX = x; bullet.lastY = y;")
        self.assertEqual(create_velocity_position_output["keys"]["velocityAmount"]["java_expr"], "speed * velocityScl * (velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f)")
        self.assertEqual(create_velocity_position_output["keys"]["velocityRandomMultiplier"]["java_expr"], "velocityScaleRandMin != 1f || velocityScaleRandMax != 1f ? Mathf.random(velocityScaleRandMin, velocityScaleRandMax) : 1f")
        self.assertEqual(create_velocity_position_output["keys"]["bullet"]["alias_of"], "create_aim_result.bullet")
        self.assertEqual(create_velocity_position_output["keys"]["initVelSource"]["alias_of"], "source_line.create_velocity_position.init_vel_call")
        self.assertEqual(create_velocity_position_output["keys"]["bulletCompInitVelSource"]["alias_of"], "source_line.create_velocity_position.bullet_comp_init_vel")
        self.assertEqual(create_velocity_position_output["keys"]["setSource"]["alias_of"], "source_line.create_velocity_position.set_call")
        self.assertEqual(create_velocity_position_output["keys"]["lastXSource"]["alias_of"], "source_line.create_velocity_position.last_x_assignment")
        self.assertEqual(create_velocity_position_output["keys"]["lastYSource"]["alias_of"], "source_line.create_velocity_position.last_y_assignment")
        self.assertEqual(create_velocity_position_output["keys"]["lifetimeReservedSource"]["alias_of"], "source_line.create_velocity_position.lifetime_boundary")

        self.assertEqual(bullet_type_state["keys"]["velocityScaleRandMin"]["java_expr"], "velocityScaleRandMin")
        self.assertEqual(bullet_type_state["keys"]["velocityScaleRandMax"]["java_expr"], "velocityScaleRandMax")
        self.assertIn("PortGame.source_bullet_type_create_velocity_position_state", bullet_type_state["keys"]["speed"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_create_velocity_position_state", bullet_type_state["keys"]["velocityScaleRandMin"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_create_velocity_position_state", bullet_type_state["keys"]["velocityScaleRandMax"]["used_by"])

        create_lifetime_payload_damage_output = source_symbols.state_schema(schema, "create_lifetime_payload_damage_result")
        self.assertEqual(create_lifetime_payload_damage_output["keys"]["bulletLifetimePayloadDamageApplied"]["alias_of"], "bullet.lifetime = ...; bullet.data = data; bullet.hitSize = hitSize; bullet.mover = mover; bullet.damage = ...; bullet.buildingDamageMultiplier = buildingDamageMultiplier;")
        self.assertEqual(create_lifetime_payload_damage_output["keys"]["lifetimeAmount"]["java_expr"], "lifetime * lifetimeScl * (lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f)")
        self.assertEqual(create_lifetime_payload_damage_output["keys"]["lifeRandomMultiplier"]["java_expr"], "lifeScaleRandMin != 1f || lifeScaleRandMax != 1f ? Mathf.random(lifeScaleRandMin, lifeScaleRandMax) : 1f")
        self.assertEqual(create_lifetime_payload_damage_output["keys"]["baseDamage"]["java_expr"], "damage < 0 ? this.damage : damage")
        self.assertEqual(create_lifetime_payload_damage_output["keys"]["damageAmount"]["java_expr"], "(damage < 0 ? this.damage : damage) * bullet.damageMultiplier()")
        self.assertEqual(create_lifetime_payload_damage_output["keys"]["bullet"]["alias_of"], "create_velocity_position_result.bullet")
        self.assertEqual(create_lifetime_payload_damage_output["keys"]["lifetimeSource"]["alias_of"], "source_line.create_lifetime_payload_damage.lifetime_assignment")
        self.assertEqual(create_lifetime_payload_damage_output["keys"]["damageMultiplierSource"]["alias_of"], "source_line.create_lifetime_payload_damage.bullet_comp_damage_multiplier")
        self.assertEqual(create_lifetime_payload_damage_output["keys"]["trailClearReservedSource"]["alias_of"], "source_line.create_lifetime_payload_damage.trail_clear_boundary")

        create_trail_add_output = source_symbols.state_schema(schema, "create_trail_add_result")
        self.assertEqual(create_trail_add_output["keys"]["bulletTrailAddApplied"]["alias_of"], "if(bullet.trail != null){ bullet.trail.clear(); } bullet.add();")
        self.assertEqual(create_trail_add_output["keys"]["trailCleared"]["java_expr"], "bullet.trail.clear();")
        self.assertEqual(create_trail_add_output["keys"]["bulletAdded"]["java_expr"], "bullet.add();")
        self.assertEqual(create_trail_add_output["keys"]["typeInitCalled"]["java_expr"], "type.init(self());")
        self.assertEqual(create_trail_add_output["keys"]["bullet"]["alias_of"], "create_lifetime_payload_damage_result.bullet")
        self.assertEqual(create_trail_add_output["keys"]["trailNullGuardSource"]["alias_of"], "source_line.create_trail_add.trail_null_guard")
        self.assertEqual(create_trail_add_output["keys"]["trailClearSource"]["alias_of"], "source_line.create_trail_add.trail_clear_call")
        self.assertEqual(create_trail_add_output["keys"]["trailClearImplSource"]["alias_of"], "source_line.create_trail_add.trail_clear_impl")
        self.assertEqual(create_trail_add_output["keys"]["bulletAddSource"]["alias_of"], "source_line.create_trail_add.bullet_add_call")
        self.assertEqual(create_trail_add_output["keys"]["bulletCompAddSource"]["alias_of"], "source_line.create_trail_add.bullet_comp_add")
        self.assertEqual(create_trail_add_output["keys"]["keepVelocityReservedSource"]["alias_of"], "source_line.create_trail_add.keep_velocity_boundary")

        self.assertEqual(bullet_state["keys"]["trail"]["godot_symbol"], "bullet_state.trail")
        self.assertIn("PortGame.source_bullet_type_create_trail_add_state", bullet_state["keys"]["trail"]["used_by"])

        create_keep_velocity_output = source_symbols.state_schema(schema, "create_keep_velocity_result")
        self.assertEqual(create_keep_velocity_output["keys"]["keepVelocityApplied"]["java_expr"], "if(keepVelocity && owner instanceof Velc v){")
        self.assertEqual(create_keep_velocity_output["keys"]["scaleKeepVelocityApplied"]["java_expr"], "if(scaleKeepVelocity){")
        self.assertEqual(create_keep_velocity_output["keys"]["lenBefore"]["java_expr"], "float len = bullet.vel.len();")
        self.assertEqual(create_keep_velocity_output["keys"]["lenAfter"]["java_expr"], "float newLen = bullet.vel.len();")
        self.assertEqual(create_keep_velocity_output["keys"]["bulletVelBefore"]["java_expr"], "bullet.vel")
        self.assertEqual(create_keep_velocity_output["keys"]["bulletVelAfter"]["java_expr"], "bullet.vel.add(v.vel());")
        self.assertEqual(create_keep_velocity_output["keys"]["returnedBullet"]["java_expr"], "return bullet;")
        self.assertEqual(create_keep_velocity_output["keys"]["bullet"]["alias_of"], "create_trail_add_result.bullet")
        self.assertEqual(create_keep_velocity_output["keys"]["keepVelocitySource"]["alias_of"], "source_line.create_keep_velocity.keep_velocity_gate")
        self.assertEqual(create_keep_velocity_output["keys"]["vec2LenSource"]["alias_of"], "source_line.create_keep_velocity.vec2_len")
        self.assertEqual(create_keep_velocity_output["keys"]["vec2AddSource"]["alias_of"], "source_line.create_keep_velocity.vec2_add")
        self.assertEqual(create_keep_velocity_output["keys"]["lifetimeScaleSource"]["alias_of"], "source_line.create_keep_velocity.lifetime_scale")
        self.assertEqual(create_keep_velocity_output["keys"]["returnSource"]["alias_of"], "source_line.create_keep_velocity.return_bullet")

        create_keep_velocity_owner_state = source_symbols.state_schema(schema, "create_keep_velocity_owner_state")
        self.assertEqual(create_keep_velocity_owner_state["keys"]["isVelc"]["java_expr"], "owner instanceof Velc v")
        self.assertEqual(create_keep_velocity_owner_state["keys"]["isVelc"]["status"], "explicit-input")
        self.assertEqual(create_keep_velocity_owner_state["keys"]["vel"]["java_expr"], "v.vel()")
        self.assertEqual(create_keep_velocity_owner_state["keys"]["vel"]["status"], "explicit-input")

        source_absin_input = source_symbols.state_schema(schema, "source_absin_input")
        self.assertEqual(source_absin_input["keys"]["value"]["java_expr"], "in")
        self.assertEqual(source_absin_input["keys"]["value"]["status"], "explicit-input")
        self.assertEqual(source_absin_input["keys"]["scl"]["java_expr"], "scl")
        self.assertEqual(source_absin_input["keys"]["mag"]["java_expr"], "mag")

        source_absin_result = source_symbols.state_schema(schema, "source_absin_result")
        self.assertEqual(source_absin_result["keys"]["sinScaled"]["java_expr"], "sin(in, scl * 2f, mag)")
        self.assertEqual(source_absin_result["keys"]["absin"]["java_expr"], "(sin(in, scl * 2f, mag) + mag) / 2f")
        self.assertEqual(source_absin_result["keys"]["value"]["alias_of"], "source_absin_input.value")
        self.assertEqual(source_absin_result["keys"]["scl"]["alias_of"], "source_absin_input.scl")
        self.assertEqual(source_absin_result["keys"]["mag"]["alias_of"], "source_absin_input.mag")

        source_approach_input = source_symbols.state_schema(schema, "source_approach_input")
        self.assertEqual(source_approach_input["keys"]["from"]["java_expr"], "from")
        self.assertEqual(source_approach_input["keys"]["to"]["java_expr"], "to")
        self.assertEqual(source_approach_input["keys"]["speed"]["java_expr"], "speed")

        source_approach_result = source_symbols.state_schema(schema, "source_approach_result")
        self.assertEqual(source_approach_result["keys"]["clampedDelta"]["java_expr"], "Mathf.clamp(to - from, -speed, speed)")
        self.assertEqual(source_approach_result["keys"]["approach"]["java_expr"], "from + Mathf.clamp(to - from, -speed, speed)")
        self.assertEqual(source_approach_result["keys"]["from"]["alias_of"], "source_approach_input.from")
        self.assertEqual(source_approach_result["keys"]["to"]["alias_of"], "source_approach_input.to")
        self.assertEqual(source_approach_result["keys"]["speed"]["alias_of"], "source_approach_input.speed")

        source_approach_delta_input = source_symbols.state_schema(schema, "source_approach_delta_input")
        self.assertEqual(source_approach_delta_input["keys"]["from"]["java_expr"], "from")
        self.assertEqual(source_approach_delta_input["keys"]["to"]["java_expr"], "to")
        self.assertEqual(source_approach_delta_input["keys"]["speed"]["java_expr"], "speed")
        self.assertEqual(source_approach_delta_input["keys"]["sourceDelta"]["java_expr"], "Time.delta")

        source_approach_delta_result = source_symbols.state_schema(schema, "source_approach_delta_result")
        self.assertEqual(source_approach_delta_result["keys"]["scaledSpeed"]["java_expr"], "Time.delta * speed")
        self.assertEqual(source_approach_delta_result["keys"]["approachDelta"]["java_expr"], "approach(from, to, Time.delta * speed)")
        self.assertEqual(source_approach_delta_result["keys"]["from"]["alias_of"], "source_approach_delta_input.from")
        self.assertEqual(source_approach_delta_result["keys"]["sourceDelta"]["alias_of"], "source_approach_delta_input.sourceDelta")

        source_arc_angles_angle_input = source_symbols.state_schema(schema, "source_arc_angles_angle_input")
        self.assertEqual(source_arc_angles_angle_input["keys"]["fromX"]["java_expr"], "x")
        self.assertEqual(source_arc_angles_angle_input["keys"]["fromY"]["java_expr"], "y")
        self.assertEqual(source_arc_angles_angle_input["keys"]["toX"]["java_expr"], "x2")
        self.assertEqual(source_arc_angles_angle_input["keys"]["toY"]["java_expr"], "y2")

        source_arc_angles_angle_result = source_symbols.state_schema(schema, "source_arc_angles_angle_result")
        self.assertEqual(source_arc_angles_angle_result["keys"]["rawAngle"]["java_expr"], "float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;")
        self.assertEqual(source_arc_angles_angle_result["keys"]["negativeWrap"]["java_expr"], "if(ang < 0) ang += 360f;")
        self.assertEqual(source_arc_angles_angle_result["keys"]["angle"]["java_expr"], "return ang;")
        self.assertEqual(source_arc_angles_angle_result["keys"]["fromX"]["alias_of"], "source_arc_angles_angle_input.fromX")
        self.assertEqual(source_arc_angles_angle_result["keys"]["toY"]["alias_of"], "source_arc_angles_angle_input.toY")

        source_arc_angles_angle_dist_input = source_symbols.state_schema(schema, "source_arc_angles_angle_dist_input")
        self.assertEqual(source_arc_angles_angle_dist_input["keys"]["angleA"]["java_expr"], "a")
        self.assertEqual(source_arc_angles_angle_dist_input["keys"]["angleB"]["java_expr"], "b")

        source_arc_angles_angle_dist_result = source_symbols.state_schema(schema, "source_arc_angles_angle_dist_result")
        self.assertEqual(source_arc_angles_angle_dist_result["keys"]["angleAMod"]["java_expr"], "a = Mathf.mod(a, 360f);")
        self.assertEqual(source_arc_angles_angle_dist_result["keys"]["angleBMod"]["java_expr"], "b = Mathf.mod(b, 360f);")
        self.assertEqual(source_arc_angles_angle_dist_result["keys"]["angleDistance"]["java_expr"], "Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a)")
        self.assertEqual(source_arc_angles_angle_dist_result["keys"]["angleA"]["alias_of"], "source_arc_angles_angle_dist_input.angleA")
        self.assertEqual(source_arc_angles_angle_dist_result["keys"]["angleB"]["alias_of"], "source_arc_angles_angle_dist_input.angleB")

        source_arc_angles_backward_distance_input = source_symbols.state_schema(schema, "source_arc_angles_backward_distance_input")
        self.assertEqual(source_arc_angles_backward_distance_input["keys"]["angle1"]["java_expr"], "angle1")
        self.assertEqual(source_arc_angles_backward_distance_input["keys"]["angle2"]["java_expr"], "angle2")

        source_arc_angles_backward_distance_result = source_symbols.state_schema(schema, "source_arc_angles_backward_distance_result")
        self.assertEqual(source_arc_angles_backward_distance_result["keys"]["backwardDistance"]["java_expr"], "return 360 - Math.abs(angle1 - angle2);")
        self.assertEqual(source_arc_angles_backward_distance_result["keys"]["angle1"]["alias_of"], "source_arc_angles_backward_distance_input.angle1")
        self.assertEqual(source_arc_angles_backward_distance_result["keys"]["angle2"]["alias_of"], "source_arc_angles_backward_distance_input.angle2")

        source_arc_angles_forward_distance_input = source_symbols.state_schema(schema, "source_arc_angles_forward_distance_input")
        self.assertEqual(source_arc_angles_forward_distance_input["keys"]["angle1"]["java_expr"], "angle1")
        self.assertEqual(source_arc_angles_forward_distance_input["keys"]["angle2"]["java_expr"], "angle2")

        source_arc_angles_forward_distance_result = source_symbols.state_schema(schema, "source_arc_angles_forward_distance_result")
        self.assertEqual(source_arc_angles_forward_distance_result["keys"]["forwardDistance"]["java_expr"], "return Math.abs(angle1 - angle2);")
        self.assertEqual(source_arc_angles_forward_distance_result["keys"]["angle1"]["alias_of"], "source_arc_angles_forward_distance_input.angle1")
        self.assertEqual(source_arc_angles_forward_distance_result["keys"]["angle2"]["alias_of"], "source_arc_angles_forward_distance_input.angle2")

        source_arc_angles_move_toward_input = source_symbols.state_schema(schema, "source_arc_angles_move_toward_input")
        self.assertEqual(source_arc_angles_move_toward_input["keys"]["angle"]["java_expr"], "angle")
        self.assertEqual(source_arc_angles_move_toward_input["keys"]["to"]["java_expr"], "to")
        self.assertEqual(source_arc_angles_move_toward_input["keys"]["speed"]["java_expr"], "speed")

        source_arc_angles_move_toward_result = source_symbols.state_schema(schema, "source_arc_angles_move_toward_result")
        self.assertEqual(source_arc_angles_move_toward_result["keys"]["snapToTarget"]["java_expr"], "if(Math.abs(angleDist(angle, to)) < speed) return to;")
        self.assertEqual(source_arc_angles_move_toward_result["keys"]["turnBackward"]["java_expr"], "angle > to == backwardDistance(angle, to) > forwardDistance(angle, to)")
        self.assertEqual(source_arc_angles_move_toward_result["keys"]["moveToward"]["java_expr"], "return angle;")
        self.assertEqual(source_arc_angles_move_toward_result["keys"]["angle"]["alias_of"], "source_arc_angles_move_toward_input.angle")
        self.assertEqual(source_arc_angles_move_toward_result["keys"]["speed"]["alias_of"], "source_arc_angles_move_toward_input.speed")

        source_arc_angles_trns_vec_input = source_symbols.state_schema(schema, "source_arc_angles_trns_vec_input")
        self.assertEqual(source_arc_angles_trns_vec_input["keys"]["angleDegrees"]["java_expr"], "angle")
        self.assertEqual(source_arc_angles_trns_vec_input["keys"]["x"]["java_expr"], "x")
        self.assertEqual(source_arc_angles_trns_vec_input["keys"]["y"]["java_expr"], "y")

        source_arc_angles_trns_vec_result = source_symbols.state_schema(schema, "source_arc_angles_trns_vec_result")
        self.assertEqual(source_arc_angles_trns_vec_result["keys"]["x"]["java_expr"], "return rv.set(x, y).rotate(angle).x;")
        self.assertEqual(source_arc_angles_trns_vec_result["keys"]["y"]["java_expr"], "return rv.set(x, y).rotate(angle).y;")
        self.assertEqual(source_arc_angles_trns_vec_result["keys"]["vec2RotateSource"]["java_expr"], "float newX = this.x * cos - this.y * sin;\n        float newY = this.x * sin + this.y * cos;")
        self.assertEqual(source_arc_angles_trns_vec_result["keys"]["angle"]["alias_of"], "source_arc_angles_trns_vec_input.angleDegrees")

        source_arc_chance_delta_threshold_input = source_symbols.state_schema(schema, "source_arc_chance_delta_threshold_input")
        self.assertEqual(source_arc_chance_delta_threshold_input["keys"]["chance"]["java_expr"], "d")
        self.assertEqual(source_arc_chance_delta_threshold_input["keys"]["sourceDelta"]["java_expr"], "Time.delta")

        source_arc_chance_delta_threshold_result = source_symbols.state_schema(schema, "source_arc_chance_delta_threshold_result")
        self.assertEqual(source_arc_chance_delta_threshold_result["keys"]["threshold"]["java_expr"], "d * Time.delta")
        self.assertEqual(source_arc_chance_delta_threshold_result["keys"]["chance"]["alias_of"], "source_arc_chance_delta_threshold_input.chance")
        self.assertEqual(source_arc_chance_delta_threshold_result["keys"]["sourceDelta"]["alias_of"], "source_arc_chance_delta_threshold_input.sourceDelta")

        source_arc_is_power_of_two_input = source_symbols.state_schema(schema, "source_arc_is_power_of_two_input")
        self.assertEqual(source_arc_is_power_of_two_input["keys"]["value"]["java_expr"], "value")
        self.assertEqual(source_arc_is_power_of_two_input["keys"]["value"]["status"], "explicit-input")

        source_arc_is_power_of_two_result = source_symbols.state_schema(schema, "source_arc_is_power_of_two_result")
        self.assertEqual(source_arc_is_power_of_two_result["keys"]["nonzero"]["java_expr"], "value != 0")
        self.assertEqual(source_arc_is_power_of_two_result["keys"]["bitTest"]["java_expr"], "(value & value - 1) == 0")
        self.assertEqual(source_arc_is_power_of_two_result["keys"]["isPowerOfTwo"]["java_expr"], "return value != 0 && (value & value - 1) == 0;")
        self.assertEqual(source_arc_is_power_of_two_result["keys"]["value"]["alias_of"], "source_arc_is_power_of_two_input.value")

        source_arc_lerp_delta_input = source_symbols.state_schema(schema, "source_arc_lerp_delta_input")
        self.assertEqual(source_arc_lerp_delta_input["keys"]["fromValue"]["java_expr"], "fromValue")
        self.assertEqual(source_arc_lerp_delta_input["keys"]["toValue"]["java_expr"], "toValue")
        self.assertEqual(source_arc_lerp_delta_input["keys"]["progress"]["java_expr"], "progress")
        self.assertEqual(source_arc_lerp_delta_input["keys"]["sourceDelta"]["java_expr"], "Time.delta")

        source_arc_lerp_delta_result = source_symbols.state_schema(schema, "source_arc_lerp_delta_result")
        self.assertEqual(source_arc_lerp_delta_result["keys"]["scaledProgress"]["java_expr"], "progress * Time.delta")
        self.assertEqual(source_arc_lerp_delta_result["keys"]["clampedProgress"]["java_expr"], "clamp(progress * Time.delta)")
        self.assertEqual(source_arc_lerp_delta_result["keys"]["lerpDelta"]["java_expr"], "return lerp(fromValue, toValue, clamp(progress * Time.delta));")
        self.assertEqual(source_arc_lerp_delta_result["keys"]["fromValue"]["alias_of"], "source_arc_lerp_delta_input.fromValue")
        self.assertEqual(source_arc_lerp_delta_result["keys"]["sourceDelta"]["alias_of"], "source_arc_lerp_delta_input.sourceDelta")

        source_arc_mathf_cos_lookup_input = source_symbols.state_schema(schema, "source_arc_mathf_cos_lookup_input")
        self.assertEqual(source_arc_mathf_cos_lookup_input["keys"]["radians"]["java_expr"], "radians")
        self.assertEqual(source_arc_mathf_cos_lookup_input["keys"]["radians"]["status"], "explicit-input")

        source_arc_mathf_cos_lookup_result = source_symbols.state_schema(schema, "source_arc_mathf_cos_lookup_result")
        self.assertEqual(source_arc_mathf_cos_lookup_result["keys"]["index"]["java_expr"], "(int)((radians + PI / 2) * radToIndex) & sinMask")
        self.assertEqual(source_arc_mathf_cos_lookup_result["keys"]["cos"]["java_expr"], "return sinTable[(int)((radians + PI / 2) * radToIndex) & sinMask];")
        self.assertEqual(source_arc_mathf_cos_lookup_result["keys"]["tableValueSource"]["java_expr"], "sinTable[i] = (float)Math.sin((i + 0.5f) / sinCount * radFull);")
        self.assertEqual(source_arc_mathf_cos_lookup_result["keys"]["radians"]["alias_of"], "source_arc_mathf_cos_lookup_input.radians")

        source_arc_mathf_sin_lookup_input = source_symbols.state_schema(schema, "source_arc_mathf_sin_lookup_input")
        self.assertEqual(source_arc_mathf_sin_lookup_input["keys"]["radians"]["java_expr"], "radians")
        self.assertEqual(source_arc_mathf_sin_lookup_input["keys"]["radians"]["status"], "explicit-input")

        source_arc_mathf_sin_lookup_result = source_symbols.state_schema(schema, "source_arc_mathf_sin_lookup_result")
        self.assertEqual(source_arc_mathf_sin_lookup_result["keys"]["index"]["java_expr"], "(int)(radians * radToIndex) & sinMask")
        self.assertEqual(source_arc_mathf_sin_lookup_result["keys"]["sin"]["java_expr"], "return sinTable[(int)(radians * radToIndex) & sinMask];")
        self.assertEqual(source_arc_mathf_sin_lookup_result["keys"]["tableValueSource"]["java_expr"], "sinTable[i] = (float)Math.sin((i + 0.5f) / sinCount * radFull);")
        self.assertEqual(source_arc_mathf_sin_lookup_result["keys"]["radians"]["alias_of"], "source_arc_mathf_sin_lookup_input.radians")

        source_arc_mathf_sin_scaled_input = source_symbols.state_schema(schema, "source_arc_mathf_sin_scaled_input")
        self.assertEqual(source_arc_mathf_sin_scaled_input["keys"]["radians"]["java_expr"], "radians")
        self.assertEqual(source_arc_mathf_sin_scaled_input["keys"]["scl"]["java_expr"], "scl")
        self.assertEqual(source_arc_mathf_sin_scaled_input["keys"]["mag"]["java_expr"], "mag")

        source_arc_mathf_sin_scaled_result = source_symbols.state_schema(schema, "source_arc_mathf_sin_scaled_result")
        self.assertEqual(source_arc_mathf_sin_scaled_result["keys"]["scaledRadians"]["java_expr"], "radians / scl")
        self.assertEqual(source_arc_mathf_sin_scaled_result["keys"]["sinLookup"]["java_expr"], "sin(radians / scl)")
        self.assertEqual(source_arc_mathf_sin_scaled_result["keys"]["sinScaled"]["java_expr"], "return sin(radians / scl) * mag;")
        self.assertEqual(source_arc_mathf_sin_scaled_result["keys"]["mag"]["alias_of"], "source_arc_mathf_sin_scaled_input.mag")

        source_arc_mathf_sin_table_value_input = source_symbols.state_schema(schema, "source_arc_mathf_sin_table_value_input")
        self.assertEqual(source_arc_mathf_sin_table_value_input["keys"]["index"]["java_expr"], "i")
        self.assertEqual(source_arc_mathf_sin_table_value_input["keys"]["index"]["status"], "explicit-input")

        source_arc_mathf_sin_table_value_result = source_symbols.state_schema(schema, "source_arc_mathf_sin_table_value_result")
        self.assertEqual(source_arc_mathf_sin_table_value_result["keys"]["tableValue"]["java_expr"], "sinTable[i] = (float)Math.sin((i + 0.5f) / sinCount * radFull);")
        self.assertEqual(source_arc_mathf_sin_table_value_result["keys"]["cardinalZero"]["java_expr"], "sinTable[0] = 0f;")
        self.assertEqual(source_arc_mathf_sin_table_value_result["keys"]["cardinalNinety"]["java_expr"], "sinTable[(int)(90 * degToIndex) & sinMask] = 1f;")
        self.assertEqual(source_arc_mathf_sin_table_value_result["keys"]["index"]["alias_of"], "source_arc_mathf_sin_table_value_input.index")

        source_arc_random_seed_float_max_input = source_symbols.state_schema(schema, "source_arc_random_seed_float_max_input")
        self.assertEqual(source_arc_random_seed_float_max_input["keys"]["seed"]["java_expr"], "seed")
        self.assertEqual(source_arc_random_seed_float_max_input["keys"]["seed"]["status"], "explicit-input")
        self.assertEqual(source_arc_random_seed_float_max_input["keys"]["max"]["java_expr"], "max")
        self.assertEqual(source_arc_random_seed_float_max_input["keys"]["max"]["status"], "explicit-input")

        source_arc_random_seed_float_max_result = source_symbols.state_schema(schema, "source_arc_random_seed_float_max_result")
        self.assertEqual(source_arc_random_seed_float_max_result["keys"]["scaledSeed"]["java_expr"], "seed * 99999")
        self.assertEqual(source_arc_random_seed_float_max_result["keys"]["setSeed"]["java_expr"], "seedr.setSeed(seed * 99999);")
        self.assertEqual(source_arc_random_seed_float_max_result["keys"]["nextFloat"]["java_expr"], "seedr.nextFloat()")
        self.assertEqual(source_arc_random_seed_float_max_result["keys"]["randomSeed"]["java_expr"], "return seedr.nextFloat() * max;")
        self.assertEqual(source_arc_random_seed_float_max_result["keys"]["max"]["alias_of"], "source_arc_random_seed_float_max_input.max")

        source_arc_random_seed_int_input = source_symbols.state_schema(schema, "source_arc_random_seed_int_input")
        self.assertEqual(source_arc_random_seed_int_input["keys"]["seed"]["java_expr"], "seed")
        self.assertEqual(source_arc_random_seed_int_input["keys"]["min"]["java_expr"], "min")
        self.assertEqual(source_arc_random_seed_int_input["keys"]["max"]["java_expr"], "max")

        source_arc_random_seed_int_result = source_symbols.state_schema(schema, "source_arc_random_seed_int_result")
        self.assertEqual(source_arc_random_seed_int_result["keys"]["setSeed"]["java_expr"], "seedr.setSeed(seed);")
        self.assertEqual(source_arc_random_seed_int_result["keys"]["powerOfTwoGate"]["java_expr"], "if(isPowerOfTwo(max))")
        self.assertEqual(source_arc_random_seed_int_result["keys"]["powerOfTwoNextInt"]["java_expr"], "seedr.nextInt();")
        self.assertEqual(source_arc_random_seed_int_result["keys"]["bound"]["java_expr"], "max - min + 1")
        self.assertEqual(source_arc_random_seed_int_result["keys"]["randomSeed"]["java_expr"], "return seedr.nextInt(max - min + 1) + min;")
        self.assertEqual(source_arc_random_seed_int_result["keys"]["min"]["alias_of"], "source_arc_random_seed_int_input.min")

        source_arc_strings_fixed_one_decimal_input = source_symbols.state_schema(schema, "source_arc_strings_fixed_one_decimal_input")
        self.assertEqual(source_arc_strings_fixed_one_decimal_input["keys"]["value"]["java_expr"], "d")
        self.assertEqual(source_arc_strings_fixed_one_decimal_input["keys"]["value"]["status"], "explicit-input")

        source_arc_strings_fixed_one_decimal_result = source_symbols.state_schema(schema, "source_arc_strings_fixed_one_decimal_result")
        self.assertEqual(source_arc_strings_fixed_one_decimal_result["keys"]["decimalPlaces"]["java_expr"], "decimalPlaces = 1")
        self.assertEqual(source_arc_strings_fixed_one_decimal_result["keys"]["negative"]["java_expr"], "boolean negative = d < 0;")
        self.assertEqual(source_arc_strings_fixed_one_decimal_result["keys"]["absoluteValue"]["java_expr"], "d = Math.abs(d);")
        self.assertEqual(source_arc_strings_fixed_one_decimal_result["keys"]["scaled"]["java_expr"], "dec.append((int)(float)(d * Math.pow(10, decimalPlaces) + 0.0001f));")
        self.assertEqual(source_arc_strings_fixed_one_decimal_result["keys"]["dotInserted"]["java_expr"], "result.append(\".\");")
        self.assertEqual(source_arc_strings_fixed_one_decimal_result["keys"]["fixed"]["java_expr"], "return fixedBuilder(d, decimalPlaces).toString();")
        self.assertEqual(source_arc_strings_fixed_one_decimal_result["keys"]["value"]["alias_of"], "source_arc_strings_fixed_one_decimal_input.value")

        source_arc_vec2_limit_input = source_symbols.state_schema(schema, "source_arc_vec2_limit_input")
        self.assertEqual(source_arc_vec2_limit_input["keys"]["vec"]["java_expr"], "this")
        self.assertEqual(source_arc_vec2_limit_input["keys"]["vec"]["status"], "explicit-input")
        self.assertEqual(source_arc_vec2_limit_input["keys"]["limit"]["java_expr"], "limit")

        source_arc_vec2_limit_result = source_symbols.state_schema(schema, "source_arc_vec2_limit_result")
        self.assertEqual(source_arc_vec2_limit_result["keys"]["limit2"]["java_expr"], "limit * limit")
        self.assertEqual(source_arc_vec2_limit_result["keys"]["len2"]["java_expr"], "return x * x + y * y;")
        self.assertEqual(source_arc_vec2_limit_result["keys"]["limitGate"]["java_expr"], "if(len2 > limit2)")
        self.assertEqual(source_arc_vec2_limit_result["keys"]["scale"]["java_expr"], "(float)Math.sqrt(limit2 / len2)")
        self.assertEqual(source_arc_vec2_limit_result["keys"]["x"]["java_expr"], "x *= scalar;")
        self.assertEqual(source_arc_vec2_limit_result["keys"]["vec"]["alias_of"], "source_arc_vec2_limit_input.vec")

        source_block_can_replace_input = source_symbols.state_schema(schema, "source_block_can_replace_input")
        self.assertEqual(source_block_can_replace_input["keys"]["otherAlwaysReplace"]["java_expr"], "other.alwaysReplace")
        self.assertEqual(source_block_can_replace_input["keys"]["otherReplaceable"]["status"], "explicit-input")
        self.assertEqual(source_block_can_replace_input["keys"]["groupAnyReplace"]["java_expr"], "group.anyReplace")

        source_block_can_replace_result = source_symbols.state_schema(schema, "source_block_can_replace_result")
        self.assertEqual(source_block_can_replace_result["keys"]["otherAlwaysReplace"]["java_expr"], "if(other.alwaysReplace) return true;")
        self.assertEqual(source_block_can_replace_result["keys"]["otherPrivileged"]["java_expr"], "if(other.privileged) return false;")
        self.assertEqual(source_block_can_replace_result["keys"]["replacementGate"]["java_expr"], "other.replaceable && (other != this || (rotate && quickRotate)) && ((this.group != BlockGroup.none && other.group == this.group) || other == this)")
        self.assertEqual(source_block_can_replace_result["keys"]["sizeGate"]["java_expr"], "size == other.size || (size >= other.size && ((subclass != null && subclass == other.subclass) || group.anyReplace))")
        self.assertEqual(source_block_can_replace_result["keys"]["canReplace"]["java_expr"], "return other.replaceable && (other != this || (rotate && quickRotate)) && ((this.group != BlockGroup.none && other.group == this.group) || other == this) &&\n            (size == other.size || (size >= other.size && ((subclass != null && subclass == other.subclass) || group.anyReplace)));")

        source_block_dump_time_input = source_symbols.state_schema(schema, "source_block_dump_time_input")
        self.assertEqual(source_block_dump_time_input["keys"]["blockId"]["java_expr"], "name")
        self.assertEqual(source_block_dump_time_input["keys"]["blockId"]["status"], "explicit-input")

        source_block_dump_time_result = source_symbols.state_schema(schema, "source_block_dump_time_result")
        self.assertEqual(source_block_dump_time_result["keys"]["dumpTime"]["java_expr"], "public int dumpTime = 5;")
        self.assertEqual(source_block_dump_time_result["keys"]["defaultDumpTime"]["java_expr"], "5")
        self.assertEqual(source_block_dump_time_result["keys"]["blockId"]["alias_of"], "source_block_dump_time_input.blockId")

        source_block_health_input = source_symbols.state_schema(schema, "source_block_health_input")
        self.assertEqual(source_block_health_input["keys"]["blockId"]["java_expr"], "name")
        self.assertEqual(source_block_health_input["keys"]["blockId"]["status"], "explicit-input")

        source_block_health_result = source_symbols.state_schema(schema, "source_block_health_result")
        self.assertEqual(source_block_health_result["keys"]["declaredHealth"]["java_expr"], "public int health = -1;")
        self.assertEqual(source_block_health_result["keys"]["scaledHealth"]["java_expr"], "public float scaledHealth = -1;")
        self.assertEqual(source_block_health_result["keys"]["defaultScaledHealth"]["java_expr"], "scaledHealth = 40;")
        self.assertEqual(source_block_health_result["keys"]["health"]["java_expr"], "health = round ?\n                Mathf.round(size * size * scaledHealth, 5) :\n                (int)(size * size * scaledHealth);")
        self.assertEqual(source_block_health_result["keys"]["blockId"]["alias_of"], "source_block_health_input.blockId")

        source_block_health_at_cell_input = source_symbols.state_schema(schema, "source_block_health_at_cell_input")
        self.assertEqual(source_block_health_at_cell_input["keys"]["x"]["java_expr"], "tile.x")
        self.assertEqual(source_block_health_at_cell_input["keys"]["x"]["status"], "explicit-input")
        self.assertEqual(source_block_health_at_cell_input["keys"]["y"]["java_expr"], "tile.y")

        source_block_health_at_cell_result = source_symbols.state_schema(schema, "source_block_health_at_cell_result")
        self.assertEqual(source_block_health_at_cell_result["keys"]["health"]["java_expr"], "health = block.health;")
        self.assertEqual(source_block_health_at_cell_result["keys"]["senseHealth"]["java_expr"], "case health -> health;")
        self.assertEqual(source_block_health_at_cell_result["keys"]["clampHealth"]["java_expr"], "health = (float)Mathf.clamp(value, 0, maxHealth);")
        self.assertEqual(source_block_health_at_cell_result["keys"]["x"]["alias_of"], "source_block_health_at_cell_input.x")

        source_block_is_damaged_input = source_symbols.state_schema(schema, "source_block_is_damaged_input")
        self.assertEqual(source_block_is_damaged_input["keys"]["sprite"]["java_expr"], "this")
        self.assertEqual(source_block_is_damaged_input["keys"]["sprite"]["status"], "explicit-input")

        source_block_is_damaged_result = source_symbols.state_schema(schema, "source_block_is_damaged_result")
        self.assertEqual(source_block_is_damaged_result["keys"]["health"]["java_expr"], "health")
        self.assertEqual(source_block_is_damaged_result["keys"]["maxHealth"]["java_expr"], "maxHealth")
        self.assertEqual(source_block_is_damaged_result["keys"]["epsilon"]["java_expr"], "0.001f")
        self.assertEqual(source_block_is_damaged_result["keys"]["damaged"]["java_expr"], "return health < maxHealth - 0.001f;")
        self.assertEqual(source_block_is_damaged_result["keys"]["sprite"]["alias_of"], "source_block_is_damaged_input.sprite")

        source_block_item_capacity_input = source_symbols.state_schema(schema, "source_block_item_capacity_input")
        self.assertEqual(source_block_item_capacity_input["keys"]["blockId"]["java_expr"], "name")
        self.assertEqual(source_block_item_capacity_input["keys"]["blockId"]["status"], "explicit-input")

        source_block_item_capacity_result = source_symbols.state_schema(schema, "source_block_item_capacity_result")
        self.assertEqual(source_block_item_capacity_result["keys"]["itemCapacity"]["java_expr"], "public int itemCapacity = 10;")
        self.assertEqual(source_block_item_capacity_result["keys"]["buildingSenseItemCapacity"]["java_expr"], "case itemCapacity -> block.hasItems ? block.itemCapacity : 0;")
        self.assertEqual(source_block_item_capacity_result["keys"]["coreStorageCapacity"]["java_expr"], "if(sensor == LAccess.itemCapacity) return storageCapacity;")
        self.assertEqual(source_block_item_capacity_result["keys"]["blockId"]["alias_of"], "source_block_item_capacity_input.blockId")

        source_block_sprite_base_position_input = source_symbols.state_schema(schema, "source_block_sprite_base_position_input")
        self.assertEqual(source_block_sprite_base_position_input["keys"]["block"]["java_expr"], "block")
        self.assertEqual(source_block_sprite_base_position_input["keys"]["cell"]["java_expr"], "tile.x, tile.y")
        self.assertEqual(source_block_sprite_base_position_input["keys"]["cell"]["status"], "explicit-input")

        source_block_sprite_base_position_result = source_symbols.state_schema(schema, "source_block_sprite_base_position_result")
        self.assertEqual(source_block_sprite_base_position_result["keys"]["worldX"]["java_expr"], "return x * tilesize;")
        self.assertEqual(source_block_sprite_base_position_result["keys"]["worldY"]["java_expr"], "return y * tilesize;")
        self.assertEqual(source_block_sprite_base_position_result["keys"]["offset"]["java_expr"], "offset = ((size + 1) % 2) * tilesize / 2f;")
        self.assertEqual(source_block_sprite_base_position_result["keys"]["drawX"]["java_expr"], "return block().offset + worldx();")
        self.assertEqual(source_block_sprite_base_position_result["keys"]["cell"]["alias_of"], "source_block_sprite_base_position_input.cell")

        source_block_time_scale_at_cell_input = source_symbols.state_schema(schema, "source_block_time_scale_at_cell_input")
        self.assertEqual(source_block_time_scale_at_cell_input["keys"]["x"]["java_expr"], "tile.x")
        self.assertEqual(source_block_time_scale_at_cell_input["keys"]["y"]["java_expr"], "tile.y")
        self.assertEqual(source_block_time_scale_at_cell_input["keys"]["cell"]["java_expr"], "tile.x, tile.y")

        source_block_time_scale_at_cell_result = source_symbols.state_schema(schema, "source_block_time_scale_at_cell_result")
        self.assertEqual(source_block_time_scale_at_cell_result["keys"]["defaultTimeScale"]["java_expr"], "private transient float timeScale = 1f, timeScaleDuration;")
        self.assertEqual(source_block_time_scale_at_cell_result["keys"]["timeScale"]["java_expr"], "return timeScale;")
        self.assertEqual(source_block_time_scale_at_cell_result["keys"]["senseTimeScale"]["java_expr"], "case timescale -> timeScale;")
        self.assertEqual(source_block_time_scale_at_cell_result["keys"]["x"]["alias_of"], "source_block_time_scale_at_cell_input.x")

        source_block_time_scale_duration_at_cell_input = source_symbols.state_schema(schema, "source_block_time_scale_duration_at_cell_input")
        self.assertEqual(source_block_time_scale_duration_at_cell_input["keys"]["x"]["java_expr"], "tile.x")
        self.assertEqual(source_block_time_scale_duration_at_cell_input["keys"]["y"]["java_expr"], "tile.y")

        source_block_time_scale_duration_at_cell_result = source_symbols.state_schema(schema, "source_block_time_scale_duration_at_cell_result")
        self.assertEqual(source_block_time_scale_duration_at_cell_result["keys"]["defaultTimeScaleDuration"]["java_expr"], "private transient float timeScale = 1f, timeScaleDuration;")
        self.assertEqual(source_block_time_scale_duration_at_cell_result["keys"]["writeDuration"]["java_expr"], "write.f(timeScaleDuration);")
        self.assertEqual(source_block_time_scale_duration_at_cell_result["keys"]["readDuration"]["java_expr"], "timeScaleDuration = read.f();")
        self.assertEqual(source_block_time_scale_duration_at_cell_result["keys"]["decayGate"]["java_expr"], "if((timeScaleDuration -= Time.delta) <= 0f){")

        source_building_absorb_lasers_input = source_symbols.state_schema(schema, "source_building_absorb_lasers_input")
        self.assertEqual(source_building_absorb_lasers_input["keys"]["blockAbsorbLasers"]["java_expr"], "block.absorbLasers")
        self.assertEqual(source_building_absorb_lasers_input["keys"]["blockAbsorbLasers"]["status"], "explicit-input")

        source_building_absorb_lasers_result = source_symbols.state_schema(schema, "source_building_absorb_lasers_result")
        self.assertEqual(source_building_absorb_lasers_result["keys"]["defaultAbsorbLasers"]["java_expr"], "public boolean absorbLasers = false;")
        self.assertEqual(source_building_absorb_lasers_result["keys"]["absorbLasers"]["java_expr"], "return block.absorbLasers;")
        self.assertEqual(source_building_absorb_lasers_result["keys"]["blockAbsorbLasers"]["alias_of"], "source_building_absorb_lasers_input.blockAbsorbLasers")

        source_building_accept_item_input = source_symbols.state_schema(schema, "source_building_accept_item_input")
        self.assertEqual(source_building_accept_item_input["keys"]["consumesItem"]["java_expr"], "block.consumesItem(item)")
        self.assertEqual(source_building_accept_item_input["keys"]["consumesItem"]["status"], "explicit-input")
        self.assertEqual(source_building_accept_item_input["keys"]["itemCount"]["java_expr"], "items.get(item)")
        self.assertEqual(source_building_accept_item_input["keys"]["maximumAccepted"]["java_expr"], "getMaximumAccepted(item)")

        source_building_accept_item_result = source_symbols.state_schema(schema, "source_building_accept_item_result")
        self.assertEqual(source_building_accept_item_result["keys"]["acceptItem"]["java_expr"], "return block.consumesItem(item) && items.get(item) < getMaximumAccepted(item);")
        self.assertEqual(source_building_accept_item_result["keys"]["consumesItem"]["alias_of"], "source_building_accept_item_input.consumesItem")
        self.assertEqual(source_building_accept_item_result["keys"]["itemCount"]["alias_of"], "source_building_accept_item_input.itemCount")
        self.assertEqual(source_building_accept_item_result["keys"]["maximumAccepted"]["alias_of"], "source_building_accept_item_input.maximumAccepted")

        source_building_accept_liquid_input = source_symbols.state_schema(schema, "source_building_accept_liquid_input")
        self.assertEqual(source_building_accept_liquid_input["keys"]["hasLiquids"]["java_expr"], "block.hasLiquids")
        self.assertEqual(source_building_accept_liquid_input["keys"]["hasLiquids"]["status"], "explicit-input")
        self.assertEqual(source_building_accept_liquid_input["keys"]["consumesLiquid"]["java_expr"], "block.consumesLiquid(liquid)")

        source_building_accept_liquid_result = source_symbols.state_schema(schema, "source_building_accept_liquid_result")
        self.assertEqual(source_building_accept_liquid_result["keys"]["acceptLiquid"]["java_expr"], "return block.hasLiquids && block.consumesLiquid(liquid);")
        self.assertEqual(source_building_accept_liquid_result["keys"]["hasLiquids"]["alias_of"], "source_building_accept_liquid_input.hasLiquids")
        self.assertEqual(source_building_accept_liquid_result["keys"]["consumesLiquid"]["alias_of"], "source_building_accept_liquid_input.consumesLiquid")

        source_building_accept_payload_result = source_symbols.state_schema(schema, "source_building_accept_payload_result")
        self.assertEqual(source_building_accept_payload_result["keys"]["acceptPayload"]["java_expr"], "return false;")
        self.assertEqual(source_building_accept_payload_result["keys"]["acceptPayload"]["status"], "source-backed")

        source_building_accept_stack_input = source_symbols.state_schema(schema, "source_building_accept_stack_input")
        self.assertEqual(source_building_accept_stack_input["keys"]["acceptsItem"]["java_expr"], "acceptItem(self(), item)")
        self.assertEqual(source_building_accept_stack_input["keys"]["hasItems"]["java_expr"], "block.hasItems")
        self.assertEqual(source_building_accept_stack_input["keys"]["sameTeamOrNullSource"]["java_expr"], "source == null || source.team() == team")
        self.assertEqual(source_building_accept_stack_input["keys"]["maximumAccepted"]["java_expr"], "getMaximumAccepted(item)")
        self.assertEqual(source_building_accept_stack_input["keys"]["itemCount"]["java_expr"], "items.get(item)")
        self.assertEqual(source_building_accept_stack_input["keys"]["amount"]["java_expr"], "amount")

        source_building_accept_stack_result = source_symbols.state_schema(schema, "source_building_accept_stack_result")
        self.assertEqual(source_building_accept_stack_result["keys"]["acceptStackGate"]["java_expr"], "if(acceptItem(self(), item) && block.hasItems && (source == null || source.team() == team)){")
        self.assertEqual(source_building_accept_stack_result["keys"]["acceptStack"]["java_expr"], "return Math.min(getMaximumAccepted(item) - items.get(item), amount);")
        self.assertEqual(source_building_accept_stack_result["keys"]["fallback"]["java_expr"], "return 0;")
        self.assertEqual(source_building_accept_stack_result["keys"]["acceptsItem"]["alias_of"], "source_building_accept_stack_input.acceptsItem")

        source_building_after_destroyed_input = source_symbols.state_schema(schema, "source_building_after_destroyed_input")
        self.assertEqual(source_building_after_destroyed_input["keys"]["hasDestroyBullet"]["java_expr"], "block.destroyBullet != null")
        self.assertEqual(source_building_after_destroyed_input["keys"]["destroyBulletSameTeam"]["java_expr"], "block.destroyBulletSameTeam")
        self.assertEqual(source_building_after_destroyed_input["keys"]["teamId"]["java_expr"], "team")
        self.assertEqual(source_building_after_destroyed_input["keys"]["sourceX"]["java_expr"], "x")
        self.assertEqual(source_building_after_destroyed_input["keys"]["sourceY"]["java_expr"], "y")
        self.assertEqual(source_building_after_destroyed_input["keys"]["buildingId"]["java_expr"], "id()")

        source_building_after_destroyed_result = source_symbols.state_schema(schema, "source_building_after_destroyed_result")
        self.assertEqual(source_building_after_destroyed_result["keys"]["createBulletGate"]["java_expr"], "if(block.destroyBullet != null){")
        self.assertEqual(source_building_after_destroyed_result["keys"]["createBullet"]["java_expr"], "block.destroyBullet.create(this, block.destroyBulletSameTeam ? team : Team.derelict, x, y, Mathf.randomSeed(id(), 360f));")
        self.assertEqual(source_building_after_destroyed_result["keys"]["team"]["java_expr"], "block.destroyBulletSameTeam ? team : Team.derelict")
        self.assertEqual(source_building_after_destroyed_result["keys"]["rotation"]["java_expr"], "Mathf.randomSeed(id(), 360f)")
        self.assertEqual(source_building_after_destroyed_result["keys"]["buildingId"]["alias_of"], "source_building_after_destroyed_input.buildingId")

        source_building_after_picked_up_input = source_symbols.state_schema(schema, "source_building_after_picked_up_input")
        self.assertEqual(source_building_after_picked_up_input["keys"]["powerPresent"]["java_expr"], "power != null")
        self.assertEqual(source_building_after_picked_up_input["keys"]["hasConsPower"]["java_expr"], "block.consPower != null")
        self.assertEqual(source_building_after_picked_up_input["keys"]["consPowerBuffered"]["java_expr"], "block.consPower.buffered")
        self.assertEqual(source_building_after_picked_up_input["keys"]["currentStatus"]["java_expr"], "power.status")

        source_building_after_picked_up_result = source_symbols.state_schema(schema, "source_building_after_picked_up_result")
        self.assertEqual(source_building_after_picked_up_result["keys"]["powerGuard"]["java_expr"], "if(power != null){")
        self.assertEqual(source_building_after_picked_up_result["keys"]["newPowerGraph"]["java_expr"], "power.graph = new PowerGraph();")
        self.assertEqual(source_building_after_picked_up_result["keys"]["clearLinks"]["java_expr"], "power.links.clear();")
        self.assertEqual(source_building_after_picked_up_result["keys"]["statusResetGate"]["java_expr"], "if(block.consPower != null && !block.consPower.buffered){")
        self.assertEqual(source_building_after_picked_up_result["keys"]["status"]["java_expr"], "power.status = 0f;")
        self.assertEqual(source_building_after_picked_up_result["keys"]["currentStatus"]["alias_of"], "source_building_after_picked_up_input.currentStatus")

        source_building_ambient_volume_input = source_symbols.state_schema(schema, "source_building_ambient_volume_input")
        self.assertEqual(source_building_ambient_volume_input["keys"]["efficiency"]["java_expr"], "efficiency")
        self.assertEqual(source_building_ambient_volume_input["keys"]["efficiency"]["status"], "explicit-input")

        source_building_ambient_volume_result = source_symbols.state_schema(schema, "source_building_ambient_volume_result")
        self.assertEqual(source_building_ambient_volume_result["keys"]["method"]["java_expr"], "public float ambientVolume(){")
        self.assertEqual(source_building_ambient_volume_result["keys"]["ambientVolume"]["java_expr"], "return efficiency;")
        self.assertEqual(source_building_ambient_volume_result["keys"]["efficiency"]["alias_of"], "source_building_ambient_volume_input.efficiency")

        source_building_apply_boost_input = source_symbols.state_schema(schema, "source_building_apply_boost_input")
        self.assertEqual(source_building_apply_boost_input["keys"]["currentTimeScale"]["java_expr"], "this.timeScale")
        self.assertEqual(source_building_apply_boost_input["keys"]["currentDuration"]["java_expr"], "timeScaleDuration")
        self.assertEqual(source_building_apply_boost_input["keys"]["intensity"]["java_expr"], "intensity")
        self.assertEqual(source_building_apply_boost_input["keys"]["duration"]["java_expr"], "duration")
        self.assertEqual(source_building_apply_boost_input["keys"]["canOverdrive"]["java_expr"], "block.canOverdrive")

        source_building_apply_boost_result = source_symbols.state_schema(schema, "source_building_apply_boost_result")
        self.assertEqual(source_building_apply_boost_result["keys"]["canOverdriveGate"]["java_expr"], "if(!block.canOverdrive) return;")
        self.assertEqual(source_building_apply_boost_result["keys"]["refreshDurationGate"]["java_expr"], "if(intensity >= this.timeScale - 0.001f){")
        self.assertEqual(source_building_apply_boost_result["keys"]["timeScaleDuration"]["java_expr"], "timeScaleDuration = Math.max(timeScaleDuration, duration);")
        self.assertEqual(source_building_apply_boost_result["keys"]["timeScale"]["java_expr"], "timeScale = Math.max(timeScale, intensity);")
        self.assertEqual(source_building_apply_boost_result["keys"]["currentTimeScale"]["alias_of"], "source_building_apply_boost_input.currentTimeScale")

        source_building_block_half_extent_input = source_symbols.state_schema(schema, "source_building_block_half_extent_input")
        self.assertEqual(source_building_block_half_extent_input["keys"]["blockSize"]["java_expr"], "block.size")
        self.assertEqual(source_building_block_half_extent_input["keys"]["tilesize"]["java_expr"], "tilesize")

        source_building_block_half_extent_result = source_symbols.state_schema(schema, "source_building_block_half_extent_result")
        self.assertEqual(source_building_block_half_extent_result["keys"]["drawConfigureSquare"]["java_expr"], "Lines.square(x, y, block.size * tilesize / 2f + 1f);")
        self.assertEqual(source_building_block_half_extent_result["keys"]["halfExtent"]["java_expr"], "block.size * tilesize / 2f")
        self.assertEqual(source_building_block_half_extent_result["keys"]["blockSize"]["alias_of"], "source_building_block_half_extent_input.blockSize")

        source_building_bullet_damage_input = source_symbols.state_schema(schema, "source_building_bullet_damage_input")
        self.assertEqual(source_building_bullet_damage_input["keys"]["bullet"]["java_expr"], "bullet")
        self.assertEqual(source_building_bullet_damage_input["keys"]["sourceTeam"]["java_expr"], "source")
        self.assertEqual(source_building_bullet_damage_input["keys"]["damage"]["java_expr"], "damage")

        source_building_bullet_damage_result = source_symbols.state_schema(schema, "source_building_bullet_damage_result")
        self.assertEqual(source_building_bullet_damage_result["keys"]["delegatesToSourceDamage"]["java_expr"], "damage(source, damage);")
        self.assertEqual(source_building_bullet_damage_result["keys"]["firesBulletDamageEvent"]["java_expr"], "Events.fire(bulletDamageEvent.set(self(), bullet));")
        self.assertEqual(source_building_bullet_damage_result["keys"]["bulletDamageEvent"]["java_expr"], "static final BuildDamageEvent bulletDamageEvent = new BuildDamageEvent();")
        self.assertEqual(source_building_bullet_damage_result["keys"]["bullet"]["alias_of"], "source_building_bullet_damage_input.bullet")

        source_building_can_be_replaced_input = source_symbols.state_schema(schema, "source_building_can_be_replaced_input")
        self.assertEqual(source_building_can_be_replaced_input["keys"]["otherCanReplaceBlock"]["java_expr"], "other.canReplace(block)")
        self.assertEqual(source_building_can_be_replaced_input["keys"]["otherCanReplaceBlock"]["status"], "explicit-input")

        source_building_can_be_replaced_result = source_symbols.state_schema(schema, "source_building_can_be_replaced_result")
        self.assertEqual(source_building_can_be_replaced_result["keys"]["method"]["java_expr"], "public boolean canBeReplaced(Block other){")
        self.assertEqual(source_building_can_be_replaced_result["keys"]["canBeReplaced"]["java_expr"], "return other.canReplace(block);")
        self.assertEqual(source_building_can_be_replaced_result["keys"]["otherCanReplaceBlock"]["alias_of"], "source_building_can_be_replaced_input.otherCanReplaceBlock")

        source_building_can_consume_input = source_symbols.state_schema(schema, "source_building_can_consume_input")
        self.assertEqual(source_building_can_consume_input["keys"]["potentialEfficiency"]["java_expr"], "potentialEfficiency")
        self.assertEqual(source_building_can_consume_input["keys"]["potentialEfficiency"]["status"], "explicit-input")

        source_building_can_consume_result = source_symbols.state_schema(schema, "source_building_can_consume_result")
        self.assertEqual(source_building_can_consume_result["keys"]["method"]["java_expr"], "public boolean canConsume(){")
        self.assertEqual(source_building_can_consume_result["keys"]["canConsume"]["java_expr"], "return potentialEfficiency > 0;")
        self.assertEqual(source_building_can_consume_result["keys"]["potentialEfficiency"]["alias_of"], "source_building_can_consume_input.potentialEfficiency")

        source_building_can_pickup_input = source_symbols.state_schema(schema, "source_building_can_pickup_input")
        self.assertEqual(source_building_can_pickup_input["keys"]["blockCanPickup"]["java_expr"], "block.canPickup")
        self.assertEqual(source_building_can_pickup_input["keys"]["blockCanPickup"]["status"], "explicit-input")

        source_building_can_pickup_result = source_symbols.state_schema(schema, "source_building_can_pickup_result")
        self.assertEqual(source_building_can_pickup_result["keys"]["method"]["java_expr"], "public boolean canPickup(){")
        self.assertEqual(source_building_can_pickup_result["keys"]["canPickup"]["java_expr"], "return block.canPickup;")
        self.assertEqual(source_building_can_pickup_result["keys"]["blockCanPickup"]["alias_of"], "source_building_can_pickup_input.blockCanPickup")

        source_building_change_team_delegate_input = source_symbols.state_schema(schema, "source_building_change_team_delegate_input")
        self.assertEqual(source_building_change_team_delegate_input["keys"]["next_team"]["java_expr"], "next")
        self.assertEqual(source_building_change_team_delegate_input["keys"]["next_team"]["status"], "explicit-input")

        source_building_change_team_delegate_result = source_symbols.state_schema(schema, "source_building_change_team_delegate_result")
        self.assertEqual(source_building_change_team_delegate_result["keys"]["delegates_to_change_team"]["java_expr"], "changeTeam(next, true);")
        self.assertEqual(source_building_change_team_delegate_result["keys"]["update_power"]["java_expr"], "true")
        self.assertEqual(source_building_change_team_delegate_result["keys"]["next_team"]["alias_of"], "source_building_change_team_delegate_input.next_team")

        source_building_change_team_final_input = source_symbols.state_schema(schema, "source_building_change_team_final_input")
        self.assertEqual(source_building_change_team_final_input["keys"]["was"]["java_expr"], "was")
        self.assertEqual(source_building_change_team_final_input["keys"]["was"]["status"], "explicit-input")
        self.assertEqual(source_building_change_team_final_input["keys"]["last_team"]["java_expr"], "last")

        source_building_change_team_final_result = source_symbols.state_schema(schema, "source_building_change_team_final_result")
        self.assertEqual(source_building_change_team_final_result["keys"]["add_index"]["java_expr"], "indexer.addIndex(tile);")
        self.assertEqual(source_building_change_team_final_result["keys"]["team_change_event"]["java_expr"], "Events.fire(teamChangeEvent.set(last, self()));")
        self.assertEqual(source_building_change_team_final_result["keys"]["check_allow_update"]["java_expr"], "checkAllowUpdate();")
        self.assertEqual(source_building_change_team_final_result["keys"]["last_team"]["alias_of"], "source_building_change_team_final_input.last_team")

        source_building_change_team_initial_input = source_symbols.state_schema(schema, "source_building_change_team_initial_input")
        self.assertEqual(source_building_change_team_initial_input["keys"]["current_team"]["java_expr"], "this.team")
        self.assertEqual(source_building_change_team_initial_input["keys"]["next_team"]["java_expr"], "next")
        self.assertEqual(source_building_change_team_initial_input["keys"]["force_team"]["java_expr"], "block.forceTeam")
        self.assertEqual(source_building_change_team_initial_input["keys"]["was_valid"]["java_expr"], "isValid()")

        source_building_change_team_initial_result = source_symbols.state_schema(schema, "source_building_change_team_initial_result")
        self.assertEqual(source_building_change_team_initial_result["keys"]["returned"]["java_expr"], "if(this.team == next) return;")
        self.assertEqual(source_building_change_team_initial_result["keys"]["team"]["java_expr"], "this.team = next;")
        self.assertEqual(source_building_change_team_initial_result["keys"]["remove_index"]["java_expr"], "if(was) indexer.removeIndex(tile);")
        self.assertEqual(source_building_change_team_initial_result["keys"]["next_team"]["alias_of"], "source_building_change_team_initial_input.next_team")

        source_building_change_team_power_links_input = source_symbols.state_schema(schema, "source_building_change_team_power_links_input")
        self.assertEqual(source_building_change_team_power_links_input["keys"]["link_count"]["java_expr"], "power.links.size")
        self.assertEqual(source_building_change_team_power_links_input["keys"]["team"]["java_expr"], "team")
        self.assertEqual(source_building_change_team_power_links_input["keys"]["old_graph"]["java_expr"], "var oldGraph = power.graph;")

        source_building_change_team_power_links_result = source_symbols.state_schema(schema, "source_building_change_team_power_links_result")
        self.assertEqual(source_building_change_team_power_links_result["keys"]["remove_index"]["java_expr"], "power.links.removeIndex(i);")
        self.assertEqual(source_building_change_team_power_links_result["keys"]["reflow_self"]["java_expr"], "new PowerGraph().reflow(self());")
        self.assertEqual(source_building_change_team_power_links_result["keys"]["update_power_graph"]["java_expr"], "updatePowerGraph();")
        self.assertEqual(source_building_change_team_power_links_result["keys"]["old_graph"]["alias_of"], "source_building_change_team_power_links_input.old_graph")

        source_building_change_team_power_proximity_input = source_symbols.state_schema(schema, "source_building_change_team_power_proximity_input")
        self.assertEqual(source_building_change_team_power_proximity_input["keys"]["power_present"]["java_expr"], "power != null")
        self.assertEqual(source_building_change_team_power_proximity_input["keys"]["update_power"]["java_expr"], "updatePower")
        self.assertEqual(source_building_change_team_power_proximity_input["keys"]["old_graph"]["java_expr"], "var oldGraph = power.graph;")

        source_building_change_team_power_proximity_result = source_symbols.state_schema(schema, "source_building_change_team_power_proximity_result")
        self.assertEqual(source_building_change_team_power_proximity_result["keys"]["proximity_reflow"]["java_expr"], "new PowerGraph().reflow(other);")
        self.assertEqual(source_building_change_team_power_proximity_result["keys"]["old_graph"]["alias_of"], "source_building_change_team_power_proximity_input.old_graph")
        self.assertEqual(source_building_change_team_power_proximity_result["keys"]["team"]["alias_of"], "source_building_change_team_power_proximity_input.team")

        source_building_check_allow_update_input = source_symbols.state_schema(schema, "source_building_check_allow_update_input")
        self.assertEqual(source_building_check_allow_update_input["keys"]["current_enabled"]["java_expr"], "enabled")
        self.assertEqual(source_building_check_allow_update_input["keys"]["allow_update_result"]["java_expr"], "allowUpdate()")
        self.assertEqual(source_building_check_allow_update_input["keys"]["allow_update_result"]["status"], "explicit-input")

        source_building_check_allow_update_result = source_symbols.state_schema(schema, "source_building_check_allow_update_result")
        self.assertEqual(source_building_check_allow_update_result["keys"]["enabled"]["java_expr"], "enabled = false;")
        self.assertEqual(source_building_check_allow_update_result["keys"]["changed"]["alias_of"], "source_building_check_allow_update_input.current_enabled")
        self.assertEqual(source_building_check_allow_update_result["keys"]["allow_update_result"]["alias_of"], "source_building_check_allow_update_input.allow_update_result")

        source_building_check_solid_result = source_symbols.state_schema(schema, "source_building_check_solid_result")
        self.assertEqual(source_building_check_solid_result["keys"]["method"]["java_expr"], "public boolean checkSolid(){")
        self.assertEqual(source_building_check_solid_result["keys"]["checkSolid"]["java_expr"], "return false;")

        source_building_check_suppression_input = source_symbols.state_schema(schema, "source_building_check_suppression_input")
        self.assertEqual(source_building_check_suppression_input["keys"]["block_suppressable"]["java_expr"], "block.suppressable")
        self.assertEqual(source_building_check_suppression_input["keys"]["source_time"]["java_expr"], "Time.time")
        self.assertEqual(source_building_check_suppression_input["keys"]["heal_suppression_time"]["java_expr"], "healSuppressionTime")
        self.assertEqual(source_building_check_suppression_input["keys"]["source_delta"]["java_expr"], "Time.delta")
        self.assertEqual(source_building_check_suppression_input["keys"]["suppress_color"]["java_expr"], "suppressColor")

        source_building_check_suppression_result = source_symbols.state_schema(schema, "source_building_check_suppression_result")
        self.assertEqual(source_building_check_suppression_result["keys"]["suppressed"]["java_expr"], "if(isHealSuppressed()){")
        self.assertEqual(source_building_check_suppression_result["keys"]["chance_threshold"]["java_expr"], "Mathf.chanceDelta(0.03)")
        self.assertEqual(source_building_check_suppression_result["keys"]["effect"]["java_expr"], "Fx.regenSuppressParticle.at(x + Mathf.range(block.size * tilesize/2f - 1f), y + Mathf.range(block.size * tilesize/2f - 1f), suppressColor);")
        self.assertEqual(source_building_check_suppression_result["keys"]["particle_range"]["java_expr"], "block.size * tilesize/2f - 1f")
        self.assertEqual(source_building_check_suppression_result["keys"]["suppress_color"]["alias_of"], "source_building_check_suppression_input.suppress_color")

        source_building_collide_input = source_symbols.state_schema(schema, "source_building_collide_input")
        self.assertEqual(source_building_collide_input["keys"]["other"]["java_expr"], "other")
        self.assertEqual(source_building_collide_input["keys"]["other"]["status"], "explicit-input")

        source_building_collide_result = source_symbols.state_schema(schema, "source_building_collide_result")
        self.assertEqual(source_building_collide_result["keys"]["method"]["java_expr"], "public boolean collide(Bullet other){")
        self.assertEqual(source_building_collide_result["keys"]["collide"]["java_expr"], "return true;")
        self.assertEqual(source_building_collide_result["keys"]["other"]["alias_of"], "source_building_collide_input.other")

        source_building_collision_damage_input = source_symbols.state_schema(schema, "source_building_collision_damage_input")
        self.assertEqual(source_building_collision_damage_input["keys"]["current_health"]["java_expr"], "health")
        self.assertEqual(source_building_collision_damage_input["keys"]["bullet_building_damage"]["java_expr"], "other.type.buildingDamage(other)")
        self.assertEqual(source_building_collision_damage_input["keys"]["block_armor"]["java_expr"], "block.armor")
        self.assertEqual(source_building_collision_damage_input["keys"]["bullet_pierce_armor"]["java_expr"], "t.pierceArmor")

        source_building_collision_damage_result = source_symbols.state_schema(schema, "source_building_collision_damage_result")
        self.assertEqual(source_building_collision_damage_result["keys"]["method"]["java_expr"], "public boolean collision(Bullet other){")
        self.assertEqual(source_building_collision_damage_result["keys"]["was_dead"]["java_expr"], "boolean wasDead = health <= 0;")
        self.assertEqual(source_building_collision_damage_result["keys"]["raw_damage"]["alias_of"], "source_building_collision_damage_input.bullet_building_damage")
        self.assertEqual(source_building_collision_damage_result["keys"]["armor"]["java_expr"], "block.armor * t.armorMultiplier * t.blockArmorMultiplier")
        self.assertEqual(source_building_collision_damage_result["keys"]["damage"]["java_expr"], "Damage.applyArmor(damage, block.armor * t.armorMultiplier * t.blockArmorMultiplier)")
        self.assertEqual(source_building_collision_damage_result["keys"]["removed"]["java_expr"], "return true;")

        source_building_config_default_result = source_symbols.state_schema(schema, "source_building_config_default_result")
        self.assertEqual(source_building_config_default_result["keys"]["comment"]["java_expr"], "/** Tile configuration. Defaults to null. Used for block rebuilding. */")
        self.assertEqual(source_building_config_default_result["keys"]["nullable"]["java_expr"], "@Nullable")
        self.assertEqual(source_building_config_default_result["keys"]["method"]["java_expr"], "public Object config(){")
        self.assertEqual(source_building_config_default_result["keys"]["config"]["java_expr"], "return null;")

        source_building_configure_menu_visibility_input = source_symbols.state_schema(schema, "source_building_configure_menu_visibility_input")
        self.assertEqual(source_building_configure_menu_visibility_input["keys"]["player"]["java_expr"], "player")
        self.assertEqual(source_building_configure_menu_visibility_input["keys"]["player"]["status"], "explicit-input")

        source_building_configure_menu_visibility_result = source_symbols.state_schema(schema, "source_building_configure_menu_visibility_result")
        self.assertEqual(source_building_configure_menu_visibility_result["keys"]["show_method"]["java_expr"], "public boolean shouldShowConfigure(Player player){")
        self.assertEqual(source_building_configure_menu_visibility_result["keys"]["should_show"]["java_expr"], "return true;")
        self.assertEqual(source_building_configure_menu_visibility_result["keys"]["hide_method"]["java_expr"], "public boolean shouldHideConfigure(Player player){")
        self.assertEqual(source_building_configure_menu_visibility_result["keys"]["should_hide"]["java_expr"], "return false;")
        self.assertEqual(source_building_configure_menu_visibility_result["keys"]["player"]["alias_of"], "source_building_configure_menu_visibility_input.player")

        source_building_configured_copy_config_input = source_symbols.state_schema(schema, "source_building_configured_copy_config_input")
        self.assertEqual(source_building_configured_copy_config_input["keys"]["value_is_building"]["java_expr"], "value instanceof Building build")
        self.assertEqual(source_building_configured_copy_config_input["keys"]["copied_config"]["java_expr"], "build.config()")
        self.assertEqual(source_building_configured_copy_config_input["keys"]["copied_config_is_building"]["java_expr"], "conf instanceof Building")

        source_building_configured_copy_config_result = source_symbols.state_schema(schema, "source_building_configured_copy_config_result")
        self.assertEqual(source_building_configured_copy_config_result["keys"]["copy_branch"]["java_expr"], "}else if(value instanceof Building build){")
        self.assertEqual(source_building_configured_copy_config_result["keys"]["comment"]["java_expr"], "//copy config of another building")
        self.assertEqual(source_building_configured_copy_config_result["keys"]["config"]["alias_of"], "source_building_configured_copy_config_input.copied_config")
        self.assertEqual(source_building_configured_copy_config_result["keys"]["recurse"]["java_expr"], "configured(builder, conf);")

        source_building_configured_direct_handler_input = source_symbols.state_schema(schema, "source_building_configured_direct_handler_input")
        self.assertEqual(source_building_configured_direct_handler_input["keys"]["has_configuration"]["java_expr"], "block.configurations.containsKey(type)")
        self.assertEqual(source_building_configured_direct_handler_input["keys"]["configured_type"]["java_expr"], "type")
        self.assertEqual(source_building_configured_direct_handler_input["keys"]["value_state"]["java_expr"], "value")

        source_building_configured_direct_handler_result = source_symbols.state_schema(schema, "source_building_configured_direct_handler_result")
        self.assertEqual(source_building_configured_direct_handler_result["keys"]["handled"]["java_expr"], "block.configurations.get(type).get(this, value);")
        self.assertEqual(source_building_configured_direct_handler_result["keys"]["copy_boundary"]["java_expr"], "}else if(value instanceof Building build){")
        self.assertEqual(source_building_configured_direct_handler_result["keys"]["handler_type"]["alias_of"], "source_building_configured_direct_handler_input.configured_type")
        self.assertEqual(source_building_configured_direct_handler_result["keys"]["value"]["alias_of"], "source_building_configured_direct_handler_input.value_state")

        source_building_configured_last_access_input = source_symbols.state_schema(schema, "source_building_configured_last_access_input")
        self.assertEqual(source_building_configured_last_access_input["keys"]["builder_state"]["java_expr"], "builder")
        self.assertEqual(source_building_configured_last_access_input["keys"]["current_last_accessed"]["java_expr"], "lastAccessed")

        source_building_configured_last_access_result = source_symbols.state_schema(schema, "source_building_configured_last_access_result")
        self.assertEqual(source_building_configured_last_access_result["keys"]["updated"]["java_expr"], "updateLastAccess(builder.getPlayer());")
        self.assertEqual(source_building_configured_last_access_result["keys"]["method"]["java_expr"], "public void updateLastAccess(Player player){")
        self.assertEqual(source_building_configured_last_access_result["keys"]["last_accessed"]["java_expr"], "lastAccessed = player.coloredName();")
        self.assertEqual(source_building_configured_last_access_result["keys"]["current_last_accessed"]["alias_of"], "source_building_configured_last_access_input.current_last_accessed")

        source_building_configured_type_input = source_symbols.state_schema(schema, "source_building_configured_type_input")
        self.assertEqual(source_building_configured_type_input["keys"]["value_state"]["java_expr"], "value")
        self.assertEqual(source_building_configured_type_input["keys"]["value_state"]["status"], "explicit-input")
        self.assertEqual(source_building_configured_type_input["keys"]["is_null"]["java_expr"], "value == null")
        self.assertEqual(source_building_configured_type_input["keys"]["is_anonymous_class"]["java_expr"], "value.getClass().isAnonymousClass()")
        self.assertEqual(source_building_configured_type_input["keys"]["class"]["java_expr"], "value.getClass()")
        self.assertEqual(source_building_configured_type_input["keys"]["superclass"]["java_expr"], "value.getClass().getSuperclass()")
        self.assertEqual(source_building_configured_type_input["keys"]["kind"]["java_expr"], "value instanceof Item / Block / Liquid / UnitType")

        source_building_configured_type_result = source_symbols.state_schema(schema, "source_building_configured_type_result")
        self.assertEqual(source_building_configured_type_result["keys"]["assignment"]["java_expr"], "Class<?> type = value == null ? void.class : value.getClass().isAnonymousClass() ? value.getClass().getSuperclass() : value.getClass();")
        self.assertEqual(source_building_configured_type_result["keys"]["item_override"]["java_expr"], "if(value instanceof Item) type = Item.class;")
        self.assertEqual(source_building_configured_type_result["keys"]["block_override"]["java_expr"], "if(value instanceof Block) type = Block.class;")
        self.assertEqual(source_building_configured_type_result["keys"]["liquid_override"]["java_expr"], "if(value instanceof Liquid) type = Liquid.class;")
        self.assertEqual(source_building_configured_type_result["keys"]["unit_type_override"]["java_expr"], "if(value instanceof UnitType) type = UnitType.class;")
        self.assertEqual(source_building_configured_type_result["keys"]["value_state"]["alias_of"], "source_building_configured_type_input.value_state")

        source_building_consume_input = source_symbols.state_schema(schema, "source_building_consume_input")
        self.assertEqual(source_building_consume_input["keys"]["consumers"]["java_expr"], "block.consumers")
        self.assertEqual(source_building_consume_input["keys"]["consumers"]["status"], "explicit-input")
        self.assertEqual(source_building_consume_input["keys"]["self_state"]["java_expr"], "self()")

        source_building_consume_result = source_symbols.state_schema(schema, "source_building_consume_result")
        self.assertEqual(source_building_consume_result["keys"]["method"]["java_expr"], "public void consume(){")
        self.assertEqual(source_building_consume_result["keys"]["loop"]["java_expr"], "for(Consume cons : block.consumers){")
        self.assertEqual(source_building_consume_result["keys"]["triggered"]["java_expr"], "cons.trigger(self());")
        self.assertEqual(source_building_consume_result["keys"]["consumers"]["alias_of"], "source_building_consume_input.consumers")
        self.assertEqual(source_building_consume_result["keys"]["self_state"]["alias_of"], "source_building_consume_input.self_state")

        source_building_consume_trigger_valid_result = source_symbols.state_schema(schema, "source_building_consume_trigger_valid_result")
        self.assertEqual(source_building_consume_trigger_valid_result["keys"]["comment"]["java_expr"], "/** @return whether this building is currently \"burning\" a trigger consumer (an item) - if true, valid() on those will return true. */")
        self.assertEqual(source_building_consume_trigger_valid_result["keys"]["method"]["java_expr"], "public boolean consumeTriggerValid(){")
        self.assertEqual(source_building_consume_trigger_valid_result["keys"]["consume_trigger_valid"]["java_expr"], "return false;")

        source_building_control_config_input = source_symbols.state_schema(schema, "source_building_control_config_input")
        self.assertEqual(source_building_control_config_input["keys"]["control_type"]["java_expr"], "type")
        self.assertEqual(source_building_control_config_input["keys"]["block_logic_configurable"]["java_expr"], "block.logicConfigurable")
        self.assertEqual(source_building_control_config_input["keys"]["p1_is_logic_build"]["java_expr"], "p1 instanceof LogicBuild")
        self.assertEqual(source_building_control_config_input["keys"]["p1_value"]["java_expr"], "p1")

        source_building_control_config_result = source_symbols.state_schema(schema, "source_building_control_config_result")
        self.assertEqual(source_building_control_config_result["keys"]["method"]["java_expr"], "public void control(LAccess type, Object p1, double p2, double p3, double p4){")
        self.assertEqual(source_building_control_config_result["keys"]["lag_comment"]["java_expr"], "//don't execute configure instructions that copy logic building configures; this can cause extreme lag")
        self.assertEqual(source_building_control_config_result["keys"]["configured_called"]["java_expr"], "if(type == LAccess.config && block.logicConfigurable && !(p1 instanceof LogicBuild)){")
        self.assertEqual(source_building_control_config_result["keys"]["value"]["java_expr"], "configured(null, p1);")

        source_building_control_enabled_input = source_symbols.state_schema(schema, "source_building_control_enabled_input")
        self.assertEqual(source_building_control_enabled_input["keys"]["current_enabled"]["java_expr"], "enabled")
        self.assertEqual(source_building_control_enabled_input["keys"]["control_type"]["java_expr"], "type")
        self.assertEqual(source_building_control_enabled_input["keys"]["p1"]["java_expr"], "p1")

        source_building_control_enabled_result = source_symbols.state_schema(schema, "source_building_control_enabled_result")
        self.assertEqual(source_building_control_enabled_result["keys"]["method"]["java_expr"], "public void control(LAccess type, double p1, double p2, double p3, double p4){")
        self.assertEqual(source_building_control_enabled_result["keys"]["guard"]["java_expr"], "if(type == LAccess.enabled){")
        self.assertEqual(source_building_control_enabled_result["keys"]["enabled"]["java_expr"], "enabled = !Mathf.zero((float)p1);")
        self.assertEqual(source_building_control_enabled_result["keys"]["current_enabled"]["alias_of"], "source_building_control_enabled_input.current_enabled")

        source_building_cursor_input = source_symbols.state_schema(schema, "source_building_cursor_input")
        self.assertEqual(source_building_cursor_input["keys"]["block_configurable"]["java_expr"], "block.configurable")
        self.assertEqual(source_building_cursor_input["keys"]["interactable_player_team"]["java_expr"], "interactable(player.team())")

        source_building_cursor_result = source_symbols.state_schema(schema, "source_building_cursor_result")
        self.assertEqual(source_building_cursor_result["keys"]["comment"]["java_expr"], "/** Returns whether a hand cursor should be shown over this block. */")
        self.assertEqual(source_building_cursor_result["keys"]["method"]["java_expr"], "public Cursor getCursor(){")
        self.assertEqual(source_building_cursor_result["keys"]["cursor"]["java_expr"], "return block.configurable && interactable(player.team()) ? SystemCursor.hand : SystemCursor.arrow;")
        self.assertEqual(source_building_cursor_result["keys"]["block_configurable"]["alias_of"], "source_building_cursor_input.block_configurable")

        source_building_damage_block_health_scale_input = source_symbols.state_schema(schema, "source_building_damage_block_health_scale_input")
        self.assertEqual(source_building_damage_block_health_scale_input["keys"]["damage_amount"]["java_expr"], "damage")
        self.assertEqual(source_building_damage_block_health_scale_input["keys"]["health"]["java_expr"], "health")
        self.assertEqual(source_building_damage_block_health_scale_input["keys"]["block_health_multiplier"]["java_expr"], "state.rules.blockHealth(team)")
        self.assertEqual(source_building_damage_block_health_scale_input["keys"]["source_time"]["java_expr"], "Time.time")

        source_building_damage_block_health_scale_result = source_symbols.state_schema(schema, "source_building_damage_block_health_scale_result")
        self.assertEqual(source_building_damage_block_health_scale_result["keys"]["block_health"]["java_expr"], "float dm = state.rules.blockHealth(team);")
        self.assertEqual(source_building_damage_block_health_scale_result["keys"]["last_damage_time"]["java_expr"], "lastDamageTime = Time.time;")
        self.assertEqual(source_building_damage_block_health_scale_result["keys"]["zero_guard"]["java_expr"], "if(Mathf.zero(dm)){")
        self.assertEqual(source_building_damage_block_health_scale_result["keys"]["damage"]["java_expr"], "damage /= dm;")
        self.assertEqual(source_building_damage_block_health_scale_result["keys"]["health"]["alias_of"], "source_building_damage_block_health_scale_input.health")

        source_building_damage_dead_guard_input = source_symbols.state_schema(schema, "source_building_damage_dead_guard_input")
        self.assertEqual(source_building_damage_dead_guard_input["keys"]["dead_state"]["java_expr"], "dead()")

        source_building_damage_dead_guard_result = source_symbols.state_schema(schema, "source_building_damage_dead_guard_result")
        self.assertEqual(source_building_damage_dead_guard_result["keys"]["returned"]["java_expr"], "if(dead()) return;")
        self.assertEqual(source_building_damage_dead_guard_result["keys"]["continues"]["java_expr"], "if(dead()) return;")
        self.assertEqual(source_building_damage_dead_guard_result["keys"]["dead_state"]["alias_of"], "source_building_damage_dead_guard_input.dead_state")

        source_building_damage_delegate_input = source_symbols.state_schema(schema, "source_building_damage_delegate_input")
        self.assertEqual(source_building_damage_delegate_input["keys"]["source_team"]["java_expr"], "source")
        self.assertEqual(source_building_damage_delegate_input["keys"]["damage"]["java_expr"], "damage")

        source_building_damage_delegate_result = source_symbols.state_schema(schema, "source_building_damage_delegate_result")
        self.assertEqual(source_building_damage_delegate_result["keys"]["comment"]["java_expr"], "/** Used to handle damage from splash damage for certain types of blocks. */")
        self.assertEqual(source_building_damage_delegate_result["keys"]["method"]["java_expr"], "public void damage(@Nullable Team source, float damage){")
        self.assertEqual(source_building_damage_delegate_result["keys"]["delegates_to_damage"]["java_expr"], "damage(damage);")
        self.assertEqual(source_building_damage_delegate_result["keys"]["source_team"]["alias_of"], "source_building_damage_delegate_input.source_team")
        self.assertEqual(source_building_damage_delegate_result["keys"]["damage"]["alias_of"], "source_building_damage_delegate_input.damage")

        source_building_damage_handle_damage_gate_input = source_symbols.state_schema(schema, "source_building_damage_handle_damage_gate_input")
        self.assertEqual(source_building_damage_handle_damage_gate_input["keys"]["net_client"]["java_expr"], "net.client()")
        self.assertEqual(source_building_damage_handle_damage_gate_input["keys"]["health"]["java_expr"], "health")
        self.assertEqual(source_building_damage_handle_damage_gate_input["keys"]["damage"]["java_expr"], "damage")
        self.assertEqual(source_building_damage_handle_damage_gate_input["keys"]["handled_damage"]["java_expr"], "handleDamage(damage)")

        source_building_damage_handle_damage_gate_result = source_symbols.state_schema(schema, "source_building_damage_handle_damage_gate_result")
        self.assertEqual(source_building_damage_handle_damage_gate_result["keys"]["client_comment"]["java_expr"], "//TODO handle this better on the client.")
        self.assertEqual(source_building_damage_handle_damage_gate_result["keys"]["handle_damage_called"]["java_expr"], "if(!net.client()){")
        self.assertEqual(source_building_damage_handle_damage_gate_result["keys"]["health"]["java_expr"], "health -= handleDamage(damage);")
        self.assertEqual(source_building_damage_handle_damage_gate_result["keys"]["damage"]["alias_of"], "source_building_damage_handle_damage_gate_input.damage")
        self.assertEqual(source_building_damage_handle_damage_gate_result["keys"]["handled_damage"]["alias_of"], "source_building_damage_handle_damage_gate_input.handled_damage")

        source_building_damage_health_changed_call_result = source_symbols.state_schema(schema, "source_building_damage_health_changed_call_result")
        self.assertEqual(source_building_damage_health_changed_call_result["keys"]["health_changed"]["java_expr"], "healthChanged();")

        source_building_delta_input = source_symbols.state_schema(schema, "source_building_delta_input")
        self.assertEqual(source_building_delta_input["keys"]["source_delta"]["java_expr"], "Time.delta")
        self.assertEqual(source_building_delta_input["keys"]["source_delta"]["status"], "explicit-input")
        self.assertEqual(source_building_delta_input["keys"]["time_scale"]["java_expr"], "timeScale")
        self.assertEqual(source_building_delta_input["keys"]["time_scale"]["status"], "explicit-input")

        source_building_delta_result = source_symbols.state_schema(schema, "source_building_delta_result")
        self.assertEqual(source_building_delta_result["keys"]["comment"]["java_expr"], "/** Scaled delta. */")
        self.assertEqual(source_building_delta_result["keys"]["method"]["java_expr"], "public float delta(){")
        self.assertEqual(source_building_delta_result["keys"]["delta"]["java_expr"], "return Time.delta * timeScale;")
        self.assertEqual(source_building_delta_result["keys"]["source_delta"]["alias_of"], "source_building_delta_input.source_delta")
        self.assertEqual(source_building_delta_result["keys"]["time_scale"]["alias_of"], "source_building_delta_input.time_scale")

        source_building_display_efficiency_input = source_symbols.state_schema(schema, "source_building_display_efficiency_input")
        self.assertEqual(source_building_display_efficiency_input["keys"]["edelta_value"]["java_expr"], "edelta()")
        self.assertEqual(source_building_display_efficiency_input["keys"]["edelta_value"]["status"], "explicit-input")

        source_building_display_efficiency_result = source_symbols.state_schema(schema, "source_building_display_efficiency_result")
        self.assertEqual(source_building_display_efficiency_result["keys"]["method"]["java_expr"], "public float getDisplayEfficiency(){")
        self.assertEqual(source_building_display_efficiency_result["keys"]["progressIncrease"]["java_expr"], "getProgressIncrease(1f)")
        self.assertEqual(source_building_display_efficiency_result["keys"]["baseTime"]["java_expr"], "1f")
        self.assertEqual(source_building_display_efficiency_result["keys"]["displayEfficiency"]["java_expr"], "return getProgressIncrease(1f) / edelta();")
        self.assertEqual(source_building_display_efficiency_result["keys"]["edelta_value"]["alias_of"], "source_building_display_efficiency_input.edelta_value")

        source_building_display_flow_rate_label_input = source_symbols.state_schema(schema, "source_building_display_flow_rate_label_input")
        self.assertEqual(source_building_display_flow_rate_label_input["keys"]["flow_rate"]["java_expr"], "flowItems.getFlowRate(item)")
        self.assertEqual(source_building_display_flow_rate_label_input["keys"]["flow_rate"]["status"], "explicit-input")
        self.assertEqual(source_building_display_flow_rate_label_input["keys"]["per_second_label"]["java_expr"], "StatUnit.perSecond.localized()")
        self.assertEqual(source_building_display_flow_rate_label_input["keys"]["per_second_label"]["status"], "explicit-input")

        source_building_display_flow_rate_label_result = source_symbols.state_schema(schema, "source_building_display_flow_rate_label_result")
        self.assertEqual(source_building_display_flow_rate_label_result["keys"]["displayFlowGate"]["java_expr"], "if(displayFlow){")
        self.assertEqual(source_building_display_flow_rate_label_result["keys"]["ps"]["java_expr"], "String ps = \" \" + StatUnit.perSecond.localized();")
        self.assertEqual(source_building_display_flow_rate_label_result["keys"]["unknown"]["java_expr"], "flowItems.getFlowRate(item) < 0 ? \"...\"")
        self.assertEqual(source_building_display_flow_rate_label_result["keys"]["fixedLabel"]["java_expr"], "Strings.fixed(flowItems.getFlowRate(item), 1) + ps")
        self.assertEqual(source_building_display_flow_rate_label_result["keys"]["flow_rate"]["alias_of"], "source_building_display_flow_rate_label_input.flow_rate")
        self.assertEqual(source_building_display_flow_rate_label_result["keys"]["per_second_label"]["alias_of"], "source_building_display_flow_rate_label_input.per_second_label")

        source_building_display_icon_input = source_symbols.state_schema(schema, "source_building_display_icon_input")
        self.assertEqual(source_building_display_icon_input["keys"]["block_ui_icon"]["java_expr"], "block.getDisplayIcon(tile)")
        self.assertEqual(source_building_display_icon_input["keys"]["block_ui_icon"]["status"], "explicit-input")

        source_building_display_icon_result = source_symbols.state_schema(schema, "source_building_display_icon_result")
        self.assertEqual(source_building_display_icon_result["keys"]["method"]["java_expr"], "public void display(Table table){")
        self.assertEqual(source_building_display_icon_result["keys"]["imageCall"]["java_expr"], "t.add(new Image(block.getDisplayIcon(tile))).scaling(Scaling.fit).size(8 * 4);")
        self.assertEqual(source_building_display_icon_result["keys"]["icon"]["java_expr"], "block.getDisplayIcon(tile)")
        self.assertEqual(source_building_display_icon_result["keys"]["scaling"]["java_expr"], "Scaling.fit")
        self.assertEqual(source_building_display_icon_result["keys"]["size"]["java_expr"], "8 * 4")
        self.assertEqual(source_building_display_icon_result["keys"]["block_ui_icon"]["alias_of"], "source_building_display_icon_input.block_ui_icon")

        source_building_display_name_input = source_symbols.state_schema(schema, "source_building_display_name_input")
        self.assertEqual(source_building_display_name_input["keys"]["localized_name"]["java_expr"], "block.localizedName")
        self.assertEqual(source_building_display_name_input["keys"]["localized_name"]["status"], "explicit-input")
        self.assertEqual(source_building_display_name_input["keys"]["team_is_derelict"]["java_expr"], "team == Team.derelict")
        self.assertEqual(source_building_display_name_input["keys"]["team_is_player"]["java_expr"], "team == player.team()")
        self.assertEqual(source_building_display_name_input["keys"]["team_emoji"]["java_expr"], "team.emoji")
        self.assertEqual(source_building_display_name_input["keys"]["derelict_label"]["java_expr"], "Core.bundle.get(\"block.derelict\")")

        source_building_display_name_result = source_symbols.state_schema(schema, "source_building_display_name_result")
        self.assertEqual(source_building_display_name_result["keys"]["method"]["java_expr"], "public String getDisplayName(){")
        self.assertEqual(source_building_display_name_result["keys"]["derelictComment"]["java_expr"], "//derelict team icon currently doesn't display")
        self.assertEqual(source_building_display_name_result["keys"]["derelictName"]["java_expr"], "block.localizedName + \"\\n\" + Core.bundle.get(\"block.derelict\")")
        self.assertEqual(source_building_display_name_result["keys"]["displayName"]["java_expr"], "block.localizedName + (team == player.team() || team.emoji.isEmpty() ? \"\" : \" \" + team.emoji)")
        self.assertEqual(source_building_display_name_result["keys"]["labelWrap"]["java_expr"], "t.labelWrap(block.getDisplayName(tile)).left().width(190f).padLeft(5);")
        self.assertEqual(source_building_display_name_result["keys"]["localized_name"]["alias_of"], "source_building_display_name_input.localized_name")

        source_building_display_ui_gates_input = source_symbols.state_schema(schema, "source_building_display_ui_gates_input")
        self.assertEqual(source_building_display_ui_gates_input["keys"]["team_is_player"]["java_expr"], "team == player.team()")
        self.assertEqual(source_building_display_ui_gates_input["keys"]["team_is_player"]["status"], "explicit-input")
        self.assertEqual(source_building_display_ui_gates_input["keys"]["block_category"]["java_expr"], "block.category")
        self.assertEqual(source_building_display_ui_gates_input["keys"]["block_display_flow"]["java_expr"], "block.displayFlow")
        self.assertEqual(source_building_display_ui_gates_input["keys"]["net_active"]["java_expr"], "net.active()")
        self.assertEqual(source_building_display_ui_gates_input["keys"]["has_last_accessed"]["java_expr"], "lastAccessed != null")

        source_building_display_ui_gates_result = source_symbols.state_schema(schema, "source_building_display_ui_gates_result")
        self.assertEqual(source_building_display_ui_gates_result["keys"]["method"]["java_expr"], "public void display(Table table){")
        self.assertEqual(source_building_display_ui_gates_result["keys"]["displayHeader"]["java_expr"], "table.table(t -> {")
        self.assertEqual(source_building_display_ui_gates_result["keys"]["sameTeamDetails"]["java_expr"], "if(team == player.team()){")
        self.assertEqual(source_building_display_ui_gates_result["keys"]["displayBars"]["java_expr"], "displayBars(bars);")
        self.assertEqual(source_building_display_ui_gates_result["keys"]["displayConsumption"]["java_expr"], "table.table(this::displayConsumption).growX();")
        self.assertEqual(source_building_display_ui_gates_result["keys"]["displayFlowFormula"]["java_expr"], "boolean displayFlow = (block.category == Category.distribution || block.category == Category.liquid) && block.displayFlow;")
        self.assertEqual(source_building_display_ui_gates_result["keys"]["displayFlow"]["java_expr"], "if(displayFlow){")
        self.assertEqual(source_building_display_ui_gates_result["keys"]["displayLastAccessed"]["java_expr"], "if(net.active() && lastAccessed != null){")
        self.assertEqual(source_building_display_ui_gates_result["keys"]["block_category"]["alias_of"], "source_building_display_ui_gates_input.block_category")

        source_building_draw_cached_input = source_symbols.state_schema(schema, "source_building_draw_cached_input")
        self.assertEqual(source_building_draw_cached_input["keys"]["variants"]["java_expr"], "block.variants")
        self.assertEqual(source_building_draw_cached_input["keys"]["variants"]["status"], "explicit-input")
        self.assertEqual(source_building_draw_cached_input["keys"]["has_variant_regions"]["java_expr"], "block.variantRegions != null")
        self.assertEqual(source_building_draw_cached_input["keys"]["variant_region_count"]["java_expr"], "block.variantRegions.length")
        self.assertEqual(source_building_draw_cached_input["keys"]["tile_pos"]["java_expr"], "tile.pos()")
        self.assertEqual(source_building_draw_cached_input["keys"]["source_x"]["java_expr"], "x")
        self.assertEqual(source_building_draw_cached_input["keys"]["source_y"]["java_expr"], "y")
        self.assertEqual(source_building_draw_cached_input["keys"]["block_rotate"]["java_expr"], "block.rotate")
        self.assertEqual(source_building_draw_cached_input["keys"]["block_rotate_draw"]["java_expr"], "block.rotateDraw")
        self.assertEqual(source_building_draw_cached_input["keys"]["rotation_quadrants"]["java_expr"], "rotation")

        source_building_draw_cached_result = source_symbols.state_schema(schema, "source_building_draw_cached_result")
        self.assertEqual(source_building_draw_cached_result["keys"]["comment"]["java_expr"], "/** Called only if {@link Block#drawCached} is true (off by default). */")
        self.assertEqual(source_building_draw_cached_result["keys"]["method"]["java_expr"], "public void drawCached(){")
        self.assertEqual(source_building_draw_cached_result["keys"]["drawDelegate"]["java_expr"], "draw();")
        self.assertEqual(source_building_draw_cached_result["keys"]["regionDraw"]["java_expr"], "Draw.rect(block.region, x, y, drawrot());")
        self.assertEqual(source_building_draw_cached_result["keys"]["variantDraw"]["java_expr"], "Draw.rect(block.variantRegions[Mathf.randomSeed(tile.pos(), 0, Math.max(0, block.variantRegions.length - 1))], x, y, drawrot());")
        self.assertEqual(source_building_draw_cached_result["keys"]["drawTeamTop"]["java_expr"], "drawTeamTop();")
        self.assertEqual(source_building_draw_cached_result["keys"]["drawrotFormula"]["java_expr"], "return block.rotate && block.rotateDraw ? rotation * 90 : 0f;")
        self.assertEqual(source_building_draw_cached_result["keys"]["tile_pos"]["alias_of"], "source_building_draw_cached_input.tile_pos")

        source_building_draw_configure_input = source_symbols.state_schema(schema, "source_building_draw_configure_input")
        self.assertEqual(source_building_draw_configure_input["keys"]["source_x"]["java_expr"], "x")
        self.assertEqual(source_building_draw_configure_input["keys"]["source_x"]["status"], "explicit-input")
        self.assertEqual(source_building_draw_configure_input["keys"]["source_y"]["java_expr"], "y")
        self.assertEqual(source_building_draw_configure_input["keys"]["block_size_value"]["java_expr"], "block.size")
        self.assertEqual(source_building_draw_configure_input["keys"]["source_tilesize"]["java_expr"], "tilesize")

        source_building_draw_configure_result = source_symbols.state_schema(schema, "source_building_draw_configure_result")
        self.assertEqual(source_building_draw_configure_result["keys"]["method"]["java_expr"], "public void drawConfigure(){")
        self.assertEqual(source_building_draw_configure_result["keys"]["color"]["java_expr"], "Draw.color(Pal.accent);")
        self.assertEqual(source_building_draw_configure_result["keys"]["stroke"]["java_expr"], "Lines.stroke(1f);")
        self.assertEqual(source_building_draw_configure_result["keys"]["square"]["java_expr"], "Lines.square(x, y, block.size * tilesize / 2f + 1f);")
        self.assertEqual(source_building_draw_configure_result["keys"]["radiusOffset"]["java_expr"], "+ 1f")
        self.assertEqual(source_building_draw_configure_result["keys"]["reset"]["java_expr"], "Draw.reset();")
        self.assertEqual(source_building_draw_configure_result["keys"]["halfExtent"]["alias_of"], "source_building_block_half_extent_result.halfExtent")
        self.assertEqual(source_building_draw_configure_result["keys"]["block_size_value"]["alias_of"], "source_building_draw_configure_input.block_size_value")

        source_building_draw_cracks_input = source_symbols.state_schema(schema, "source_building_draw_cracks_input")
        self.assertEqual(source_building_draw_cracks_input["keys"]["draw_cracks"]["java_expr"], "block.drawCracks")
        self.assertEqual(source_building_draw_cracks_input["keys"]["draw_cracks"]["status"], "explicit-input")
        self.assertEqual(source_building_draw_cracks_input["keys"]["damaged_state"]["java_expr"], "damaged()")
        self.assertEqual(source_building_draw_cracks_input["keys"]["block_size_value"]["java_expr"], "block.size")
        self.assertEqual(source_building_draw_cracks_input["keys"]["max_crack_size"]["java_expr"], "BlockRenderer.maxCrackSize")
        self.assertEqual(source_building_draw_cracks_input["keys"]["health_fraction"]["java_expr"], "healthf()")
        self.assertEqual(source_building_draw_cracks_input["keys"]["crack_regions"]["java_expr"], "BlockRenderer.crackRegions")
        self.assertEqual(source_building_draw_cracks_input["keys"]["position_id"]["java_expr"], "pos()")

        source_building_draw_cracks_result = source_symbols.state_schema(schema, "source_building_draw_cracks_result")
        self.assertEqual(source_building_draw_cracks_result["keys"]["method"]["java_expr"], "public void drawCracks(){")
        self.assertEqual(source_building_draw_cracks_result["keys"]["visible"]["java_expr"], "if(!block.drawCracks || !damaged() || block.size > BlockRenderer.maxCrackSize) return;")
        self.assertEqual(source_building_draw_cracks_result["keys"]["id"]["java_expr"], "int id = pos();")
        self.assertEqual(source_building_draw_cracks_result["keys"]["crackIndex"]["java_expr"], "Mathf.clamp((int)((1f - healthf()) * BlockRenderer.crackRegions), 0, BlockRenderer.crackRegions-1)")
        self.assertEqual(source_building_draw_cracks_result["keys"]["lightness"]["java_expr"], "0.1f + (1f - healthf())* 0.6f")
        self.assertEqual(source_building_draw_cracks_result["keys"]["todo"]["java_expr"], "//TODO could be random, flipped, pseudorandom, etc")
        self.assertEqual(source_building_draw_cracks_result["keys"]["rotationDegrees"]["java_expr"], "(id%4)*90")
        self.assertEqual(source_building_draw_cracks_result["keys"]["colorReset"]["java_expr"], "Draw.color();")
        self.assertEqual(source_building_draw_cracks_result["keys"]["position_id"]["alias_of"], "source_building_draw_cracks_input.position_id")

        source_building_draw_disabled_input = source_symbols.state_schema(schema, "source_building_draw_disabled_input")
        self.assertEqual(source_building_draw_disabled_input["keys"]["source_x"]["java_expr"], "x")
        self.assertEqual(source_building_draw_disabled_input["keys"]["source_x"]["status"], "explicit-input")
        self.assertEqual(source_building_draw_disabled_input["keys"]["source_y"]["java_expr"], "y")

        source_building_draw_disabled_result = source_symbols.state_schema(schema, "source_building_draw_disabled_result")
        self.assertEqual(source_building_draw_disabled_result["keys"]["method"]["java_expr"], "public void drawDisabled(){")
        self.assertEqual(source_building_draw_disabled_result["keys"]["color"]["java_expr"], "Draw.color(Color.scarlet);")
        self.assertEqual(source_building_draw_disabled_result["keys"]["alpha"]["java_expr"], "Draw.alpha(0.8f);")
        self.assertEqual(source_building_draw_disabled_result["keys"]["size"]["java_expr"], "float size = 6f;")
        self.assertEqual(source_building_draw_disabled_result["keys"]["rect"]["java_expr"], "Draw.rect(Icon.cancel.getRegion(), x, y, size, size);")
        self.assertEqual(source_building_draw_disabled_result["keys"]["reset"]["java_expr"], "Draw.reset();")
        self.assertEqual(source_building_draw_disabled_result["keys"]["source_x"]["alias_of"], "source_building_draw_disabled_input.source_x")

        source_building_draw_item_selection_input = source_symbols.state_schema(schema, "source_building_draw_item_selection_input")
        self.assertEqual(source_building_draw_item_selection_input["keys"]["has_selection"]["java_expr"], "selection != null")
        self.assertEqual(source_building_draw_item_selection_input["keys"]["has_selection"]["status"], "explicit-input")
        self.assertEqual(source_building_draw_item_selection_input["keys"]["source_x"]["java_expr"], "x")
        self.assertEqual(source_building_draw_item_selection_input["keys"]["block_size_value"]["java_expr"], "block.size")
        self.assertEqual(source_building_draw_item_selection_input["keys"]["selection_icon_ratio"]["java_expr"], "selection.fullIcon.ratio()")

        source_building_draw_item_selection_result = source_symbols.state_schema(schema, "source_building_draw_item_selection_result")
        self.assertEqual(source_building_draw_item_selection_result["keys"]["method"]["java_expr"], "public void drawItemSelection(@Nullable UnlockableContent selection){")
        self.assertEqual(source_building_draw_item_selection_result["keys"]["visible"]["java_expr"], "if(selection != null){")
        self.assertEqual(source_building_draw_item_selection_result["keys"]["geometry"]["java_expr"], "float dx = x - block.size * tilesize/2f, dy = y + block.size * tilesize/2f, s = iconSmall / 4f * selection.fullIcon.ratio(), h = iconSmall / 4f;")
        self.assertEqual(source_building_draw_item_selection_result["keys"]["dx"]["java_expr"], "x - block.size * tilesize/2f")
        self.assertEqual(source_building_draw_item_selection_result["keys"]["dy"]["java_expr"], "y + block.size * tilesize/2f")
        self.assertEqual(source_building_draw_item_selection_result["keys"]["selection_width"]["java_expr"], "iconSmall / 4f * selection.fullIcon.ratio()")
        self.assertEqual(source_building_draw_item_selection_result["keys"]["selection_height"]["java_expr"], "iconSmall / 4f")
        self.assertEqual(source_building_draw_item_selection_result["keys"]["shadow_color"]["java_expr"], "Draw.mixcol(Color.darkGray, 1f);")
        self.assertEqual(source_building_draw_item_selection_result["keys"]["shadow_rect"]["java_expr"], "Draw.rect(selection.fullIcon, dx, dy - 1, s, h);")
        self.assertEqual(source_building_draw_item_selection_result["keys"]["foreground_rect"]["java_expr"], "Draw.rect(selection.fullIcon, dx, dy, s, h);")
        self.assertEqual(source_building_draw_item_selection_result["keys"]["source_x"]["alias_of"], "source_building_draw_item_selection_input.source_x")

        source_building_draw_light_input = source_symbols.state_schema(schema, "source_building_draw_light_input")
        self.assertEqual(source_building_draw_light_input["keys"]["has_liquids"]["java_expr"], "block.hasLiquids")
        self.assertEqual(source_building_draw_light_input["keys"]["has_liquids"]["status"], "explicit-input")
        self.assertEqual(source_building_draw_light_input["keys"]["draw_liquid_light"]["java_expr"], "block.drawLiquidLight")
        self.assertEqual(source_building_draw_light_input["keys"]["light_liquid_is_null"]["java_expr"], "block.lightLiquid == null")
        self.assertEqual(source_building_draw_light_input["keys"]["selected_liquid_amount"]["java_expr"], "liquids.get(liq)")
        self.assertEqual(source_building_draw_light_input["keys"]["source_delta"]["java_expr"], "Time.delta")

        source_building_draw_light_result = source_symbols.state_schema(schema, "source_building_draw_light_result")
        self.assertEqual(source_building_draw_light_result["keys"]["method"]["java_expr"], "public void drawLight(){")
        self.assertEqual(source_building_draw_light_result["keys"]["liquidSelect"]["java_expr"], "Liquid liq = block.hasLiquids && block.lightLiquid == null ? liquids.current() : block.lightLiquid;")
        self.assertEqual(source_building_draw_light_result["keys"]["visible"]["java_expr"], "if(block.hasLiquids && block.drawLiquidLight && liq.lightColor.a > 0.001f){")
        self.assertEqual(source_building_draw_light_result["keys"]["visualComment"]["java_expr"], "//yes, I am updating in draw()... but this is purely visual anyway, better have it here than in update() where it wastes time")
        self.assertEqual(source_building_draw_light_result["keys"]["visualLiquid"]["java_expr"], "visualLiquid = Mathf.lerpDelta(visualLiquid, liquids.get(liq)>= 0.01f ? 1f : 0f, 0.06f);")
        self.assertEqual(source_building_draw_light_result["keys"]["amountGate"]["java_expr"], "liquids.get(liq)>= 0.01f ? 1f : 0f")
        self.assertEqual(source_building_draw_light_result["keys"]["drawLiquidLightCall"]["java_expr"], "drawLiquidLight(liq, visualLiquid);")
        self.assertEqual(source_building_draw_light_result["keys"]["has_liquids"]["alias_of"], "source_building_draw_light_input.has_liquids")

        source_building_draw_liquid_light_input = source_symbols.state_schema(schema, "source_building_draw_liquid_light_input")
        self.assertEqual(source_building_draw_liquid_light_input["keys"]["source_x"]["java_expr"], "x")
        self.assertEqual(source_building_draw_liquid_light_input["keys"]["source_x"]["status"], "explicit-input")
        self.assertEqual(source_building_draw_liquid_light_input["keys"]["light_color"]["java_expr"], "liquid.lightColor")
        self.assertEqual(source_building_draw_liquid_light_input["keys"]["light_alpha"]["java_expr"], "liquid.lightColor.a")
        self.assertEqual(source_building_draw_liquid_light_input["keys"]["amount"]["java_expr"], "amount")

        source_building_draw_liquid_light_result = source_symbols.state_schema(schema, "source_building_draw_liquid_light_result")
        self.assertEqual(source_building_draw_liquid_light_result["keys"]["method"]["java_expr"], "public void drawLiquidLight(Liquid liquid, float amount){")
        self.assertEqual(source_building_draw_liquid_light_result["keys"]["visible"]["java_expr"], "if(amount > 0.01f){")
        self.assertEqual(source_building_draw_liquid_light_result["keys"]["color"]["java_expr"], "Color color = liquid.lightColor;")
        self.assertEqual(source_building_draw_liquid_light_result["keys"]["fract"]["java_expr"], "float fract = 1f;")
        self.assertEqual(source_building_draw_liquid_light_result["keys"]["opacity"]["java_expr"], "float opacity = color.a * fract;")
        self.assertEqual(source_building_draw_liquid_light_result["keys"]["opacityGate"]["java_expr"], "if(opacity > 0.001f){")
        self.assertEqual(source_building_draw_liquid_light_result["keys"]["radius"]["java_expr"], "block.size * 30f * fract")
        self.assertEqual(source_building_draw_liquid_light_result["keys"]["alpha"]["java_expr"], "opacity * amount")
        self.assertEqual(source_building_draw_liquid_light_result["keys"]["drawfLightCall"]["java_expr"], "Drawf.light(x, y, block.size * 30f * fract, color, opacity * amount);")
        self.assertEqual(source_building_draw_liquid_light_result["keys"]["amount"]["alias_of"], "source_building_draw_liquid_light_input.amount")

        source_building_draw_select_input = source_symbols.state_schema(schema, "source_building_draw_select_input")
        self.assertEqual(source_building_draw_select_input["keys"]["block_status"]["java_expr"], "status()")
        self.assertEqual(source_building_draw_select_input["keys"]["block_status"]["status"], "explicit-input")
        self.assertEqual(source_building_draw_select_input["keys"]["source_x"]["java_expr"], "x")
        self.assertEqual(source_building_draw_select_input["keys"]["source_y"]["java_expr"], "y")
        self.assertEqual(source_building_draw_select_input["keys"]["source_rotation"]["java_expr"], "rotation")
        self.assertEqual(source_building_draw_select_input["keys"]["tile_x"]["java_expr"], "tile.x")
        self.assertEqual(source_building_draw_select_input["keys"]["tile_y"]["java_expr"], "tile.y")
        self.assertEqual(source_building_draw_select_input["keys"]["unit_activation_delay"]["java_expr"], "state.rules.unitActivationDelay(team)")
        self.assertEqual(source_building_draw_select_input["keys"]["state_tick"]["java_expr"], "state.tick")

        source_building_draw_select_result = source_symbols.state_schema(schema, "source_building_draw_select_result")
        self.assertEqual(source_building_draw_select_result["keys"]["comment"]["java_expr"], "/** Draw the block overlay that is shown when a cursor is over the block. */")
        self.assertEqual(source_building_draw_select_result["keys"]["method"]["java_expr"], "public void drawSelect(){")
        self.assertEqual(source_building_draw_select_result["keys"]["overlay"]["java_expr"], "block.drawOverlay(x, y, rotation);")
        self.assertEqual(source_building_draw_select_result["keys"]["placeTextVisible"]["java_expr"], "if(status() == BlockStatus.inactiveUnitFactory){")
        self.assertEqual(source_building_draw_select_result["keys"]["placeText"]["java_expr"], "block.drawPlaceText(Core.bundle.format(\"rules.unitfactoryactivation.objective\", UI.formatTime((float)Math.max(0f, state.rules.unitActivationDelay(team) - state.tick))), tile.x, tile.y, false);")
        self.assertEqual(source_building_draw_select_result["keys"]["place_text_time"]["java_expr"], "Math.max(0f, state.rules.unitActivationDelay(team) - state.tick)")
        self.assertEqual(source_building_draw_select_result["keys"]["block_status"]["alias_of"], "source_building_draw_select_input.block_status")

        source_building_draw_input = source_symbols.state_schema(schema, "source_building_draw_input")
        self.assertEqual(source_building_draw_input["keys"]["variants"]["java_expr"], "block.variants")
        self.assertEqual(source_building_draw_input["keys"]["variants"]["status"], "explicit-input")
        self.assertEqual(source_building_draw_input["keys"]["has_variant_regions"]["java_expr"], "block.variantRegions != null")
        self.assertEqual(source_building_draw_input["keys"]["variant_region_count"]["java_expr"], "block.variantRegions.length")
        self.assertEqual(source_building_draw_input["keys"]["tile_pos"]["java_expr"], "tile.pos()")
        self.assertEqual(source_building_draw_input["keys"]["source_x"]["java_expr"], "x")
        self.assertEqual(source_building_draw_input["keys"]["source_y"]["java_expr"], "y")
        self.assertEqual(source_building_draw_input["keys"]["block_rotate"]["java_expr"], "block.rotate")
        self.assertEqual(source_building_draw_input["keys"]["block_rotate_draw"]["java_expr"], "block.rotateDraw")
        self.assertEqual(source_building_draw_input["keys"]["rotation_quadrants"]["java_expr"], "rotation")

        source_building_draw_result = source_symbols.state_schema(schema, "source_building_draw_result")
        self.assertEqual(source_building_draw_result["keys"]["comment"]["java_expr"], "/** Called only if {@link Block#drawDynamic} is true (on by default). */")
        self.assertEqual(source_building_draw_result["keys"]["method"]["java_expr"], "public void draw(){")
        self.assertEqual(source_building_draw_result["keys"]["baseRegionGuard"]["java_expr"], "if(block.variants == 0 || block.variantRegions == null){")
        self.assertEqual(source_building_draw_result["keys"]["regionDraw"]["java_expr"], "Draw.rect(block.region, x, y, drawrot());")
        self.assertEqual(source_building_draw_result["keys"]["variantDraw"]["java_expr"], "Draw.rect(block.variantRegions[Mathf.randomSeed(tile.pos(), 0, Math.max(0, block.variantRegions.length - 1))], x, y, drawrot());")
        self.assertEqual(source_building_draw_result["keys"]["randomSeed"]["java_expr"], "Mathf.randomSeed(tile.pos(), 0, Math.max(0, block.variantRegions.length - 1))")
        self.assertEqual(source_building_draw_result["keys"]["drawTeamTop"]["java_expr"], "drawTeamTop();")
        self.assertEqual(source_building_draw_result["keys"]["rotation_degrees"]["java_expr"], "drawrot()")
        self.assertEqual(source_building_draw_result["keys"]["variants"]["alias_of"], "source_building_draw_input.variants")
        self.assertEqual(source_building_draw_cached_result["keys"]["delegatedDraw"]["alias_of"], "source_building_draw_result")

        source_building_draw_status_input = source_symbols.state_schema(schema, "source_building_draw_status_input")
        self.assertEqual(source_building_draw_status_input["keys"]["enable_draw_status"]["java_expr"], "block.enableDrawStatus")
        self.assertEqual(source_building_draw_status_input["keys"]["enable_draw_status"]["status"], "explicit-input")
        self.assertEqual(source_building_draw_status_input["keys"]["consumers_length"]["java_expr"], "block.consumers.length")
        self.assertEqual(source_building_draw_status_input["keys"]["block_size_value"]["java_expr"], "block.size")
        self.assertEqual(source_building_draw_status_input["keys"]["source_x"]["java_expr"], "x")
        self.assertEqual(source_building_draw_status_input["keys"]["source_y"]["java_expr"], "y")
        self.assertEqual(source_building_draw_status_input["keys"]["source_tilesize"]["java_expr"], "tilesize")

        source_building_draw_status_result = source_symbols.state_schema(schema, "source_building_draw_status_result")
        self.assertEqual(source_building_draw_status_result["keys"]["method"]["java_expr"], "public void drawStatus(){")
        self.assertEqual(source_building_draw_status_result["keys"]["visible"]["java_expr"], "if(block.enableDrawStatus && block.consumers.length > 0){")
        self.assertEqual(source_building_draw_status_result["keys"]["multiplier"]["java_expr"], "float multiplier = block.size > 1 ? 1 : 0.64f;")
        self.assertEqual(source_building_draw_status_result["keys"]["brcx"]["java_expr"], "float brcx = x + (block.size * tilesize / 2f) - (tilesize * multiplier / 2f);")
        self.assertEqual(source_building_draw_status_result["keys"]["brcy"]["java_expr"], "float brcy = y - (block.size * tilesize / 2f) + (tilesize * multiplier / 2f);")
        self.assertEqual(source_building_draw_status_result["keys"]["layer"]["java_expr"], "Draw.z(Layer.power + 1);")
        self.assertEqual(source_building_draw_status_result["keys"]["graySquare"]["java_expr"], "Fill.square(brcx, brcy, 2.5f * multiplier, 45);")
        self.assertEqual(source_building_draw_status_result["keys"]["statusSquare"]["java_expr"], "Fill.square(brcx, brcy, 1.5f * multiplier, 45);")
        self.assertEqual(source_building_draw_status_result["keys"]["source_x"]["alias_of"], "source_building_draw_status_input.source_x")

        source_building_draw_team_input = source_symbols.state_schema(schema, "source_building_draw_team_input")
        self.assertEqual(source_building_draw_team_input["keys"]["team_color"]["java_expr"], "team.color")
        self.assertEqual(source_building_draw_team_input["keys"]["team_color"]["status"], "explicit-input")
        self.assertEqual(source_building_draw_team_input["keys"]["source_x"]["java_expr"], "x")
        self.assertEqual(source_building_draw_team_input["keys"]["source_y"]["java_expr"], "y")
        self.assertEqual(source_building_draw_team_input["keys"]["block_size_value"]["java_expr"], "block.size")
        self.assertEqual(source_building_draw_team_input["keys"]["source_tilesize"]["java_expr"], "tilesize")

        source_building_draw_team_result = source_symbols.state_schema(schema, "source_building_draw_team_result")
        self.assertEqual(source_building_draw_team_result["keys"]["method"]["java_expr"], "public void drawTeam(){")
        self.assertEqual(source_building_draw_team_result["keys"]["color"]["java_expr"], "Draw.color(team.color);")
        self.assertEqual(source_building_draw_team_result["keys"]["rect"]["java_expr"], "Draw.rect(\"block-border\", x - block.size * tilesize / 2f + 4, y - block.size * tilesize / 2f + 4);")
        self.assertEqual(source_building_draw_team_result["keys"]["x"]["java_expr"], "x - block.size * tilesize / 2f + 4")
        self.assertEqual(source_building_draw_team_result["keys"]["y"]["java_expr"], "y - block.size * tilesize / 2f + 4")
        self.assertEqual(source_building_draw_team_result["keys"]["color_reset"]["java_expr"], "Draw.color();")
        self.assertEqual(source_building_draw_team_result["keys"]["team_color"]["alias_of"], "source_building_draw_team_input.team_color")

        source_building_draw_team_top_input = source_symbols.state_schema(schema, "source_building_draw_team_top_input")
        self.assertEqual(source_building_draw_team_top_input["keys"]["team_region_found"]["java_expr"], "block.teamRegion.found()")
        self.assertEqual(source_building_draw_team_top_input["keys"]["team_region_found"]["status"], "explicit-input")
        self.assertEqual(source_building_draw_team_top_input["keys"]["team_region_matches_team"]["java_expr"], "block.teamRegions[team.id] == block.teamRegion")
        self.assertEqual(source_building_draw_team_top_input["keys"]["team_color"]["java_expr"], "team.color")
        self.assertEqual(source_building_draw_team_top_input["keys"]["source_x"]["java_expr"], "x")
        self.assertEqual(source_building_draw_team_top_input["keys"]["source_y"]["java_expr"], "y")

        source_building_draw_team_top_result = source_symbols.state_schema(schema, "source_building_draw_team_top_result")
        self.assertEqual(source_building_draw_team_top_result["keys"]["method"]["java_expr"], "public void drawTeamTop(){")
        self.assertEqual(source_building_draw_team_top_result["keys"]["visible"]["java_expr"], "if(block.teamRegion.found()){")
        self.assertEqual(source_building_draw_team_top_result["keys"]["tint_color"]["java_expr"], "if(block.teamRegions[team.id] == block.teamRegion) Draw.color(team.color);")
        self.assertEqual(source_building_draw_team_top_result["keys"]["rect"]["java_expr"], "Draw.rect(block.teamRegions[team.id], x, y);")
        self.assertEqual(source_building_draw_team_top_result["keys"]["color_reset"]["java_expr"], "Draw.color();")
        self.assertEqual(source_building_draw_team_top_result["keys"]["team_region_found"]["alias_of"], "source_building_draw_team_top_input.team_region_found")

        source_building_drawrot_input = source_symbols.state_schema(schema, "source_building_drawrot_input")
        self.assertEqual(source_building_drawrot_input["keys"]["block_rotate"]["java_expr"], "block.rotate")
        self.assertEqual(source_building_drawrot_input["keys"]["block_rotate_draw"]["java_expr"], "block.rotateDraw")
        self.assertEqual(source_building_drawrot_input["keys"]["rotation_quadrants"]["java_expr"], "rotation")

        source_building_drawrot_result = source_symbols.state_schema(schema, "source_building_drawrot_result")
        self.assertEqual(source_building_drawrot_result["keys"]["method"]["java_expr"], "public float drawrot(){")
        self.assertEqual(source_building_drawrot_result["keys"]["rotation_degrees"]["java_expr"], "return block.rotate && block.rotateDraw ? rotation * 90 : 0f;")
        self.assertEqual(source_building_drawrot_result["keys"]["block_rotate"]["alias_of"], "source_building_drawrot_input.block_rotate")

        source_building_edelta_input = source_symbols.state_schema(schema, "source_building_edelta_input")
        self.assertEqual(source_building_edelta_input["keys"]["source_delta"]["java_expr"], "Time.delta")
        self.assertEqual(source_building_edelta_input["keys"]["time_scale"]["java_expr"], "timeScale")
        self.assertEqual(source_building_edelta_input["keys"]["efficiency"]["java_expr"], "efficiency")

        source_building_edelta_result = source_symbols.state_schema(schema, "source_building_edelta_result")
        self.assertEqual(source_building_edelta_result["keys"]["method"]["java_expr"], "public float edelta(){")
        self.assertEqual(source_building_edelta_result["keys"]["edelta"]["java_expr"], "return efficiency * delta();")
        self.assertEqual(source_building_edelta_result["keys"]["delta_call"]["alias_of"], "source_building_delta_result.delta")
        self.assertEqual(source_building_edelta_result["keys"]["efficiency"]["alias_of"], "source_building_edelta_input.efficiency")

        source_building_efficiency_scale_result = source_symbols.state_schema(schema, "source_building_efficiency_scale_result")
        self.assertEqual(source_building_efficiency_scale_result["keys"]["comment"]["java_expr"], "/** Calculate your own efficiency multiplier. By default, this is applied in updateEfficiencyMultiplier. */")
        self.assertEqual(source_building_efficiency_scale_result["keys"]["method"]["java_expr"], "public float efficiencyScale(){")
        self.assertEqual(source_building_efficiency_scale_result["keys"]["efficiency_scale"]["java_expr"], "return 1f;")

        source_arc_mathf_cos_scaled_input = source_symbols.state_schema(schema, "source_arc_mathf_cos_scaled_input")
        self.assertEqual(source_arc_mathf_cos_scaled_input["keys"]["radians"]["java_expr"], "radians")
        self.assertEqual(source_arc_mathf_cos_scaled_input["keys"]["scl"]["java_expr"], "scl")
        self.assertEqual(source_arc_mathf_cos_scaled_input["keys"]["mag"]["java_expr"], "mag")

        source_arc_mathf_cos_scaled_result = source_symbols.state_schema(schema, "source_arc_mathf_cos_scaled_result")
        self.assertEqual(source_arc_mathf_cos_scaled_result["keys"]["scaledRadians"]["java_expr"], "radians / scl")
        self.assertEqual(source_arc_mathf_cos_scaled_result["keys"]["cosLookup"]["java_expr"], "cos(radians / scl)")
        self.assertEqual(source_arc_mathf_cos_scaled_result["keys"]["cosScaled"]["java_expr"], "return cos(radians / scl) * mag;")
        self.assertEqual(source_arc_mathf_cos_scaled_result["keys"]["mag"]["alias_of"], "source_arc_mathf_cos_scaled_input.mag")

        source_arc_mathf_mod_float_input = source_symbols.state_schema(schema, "source_arc_mathf_mod_float_input")
        self.assertEqual(source_arc_mathf_mod_float_input["keys"]["value"]["java_expr"], "f")
        self.assertEqual(source_arc_mathf_mod_float_input["keys"]["value"]["status"], "explicit-input")
        self.assertEqual(source_arc_mathf_mod_float_input["keys"]["divisor"]["java_expr"], "n")
        self.assertEqual(source_arc_mathf_mod_float_input["keys"]["divisor"]["status"], "explicit-input")

        source_arc_mathf_mod_float_result = source_symbols.state_schema(schema, "source_arc_mathf_mod_float_result")
        self.assertEqual(source_arc_mathf_mod_float_result["keys"]["rawMod"]["java_expr"], "f % n")
        self.assertEqual(source_arc_mathf_mod_float_result["keys"]["offsetMod"]["java_expr"], "(f % n) + n")
        self.assertEqual(source_arc_mathf_mod_float_result["keys"]["mod"]["java_expr"], "return ((f % n) + n) % n;")
        self.assertEqual(source_arc_mathf_mod_float_result["keys"]["value"]["alias_of"], "source_arc_mathf_mod_float_input.value")
        self.assertEqual(source_arc_mathf_mod_float_result["keys"]["divisor"]["alias_of"], "source_arc_mathf_mod_float_input.divisor")

        source_arc_mathf_num_input = source_symbols.state_schema(schema, "source_arc_mathf_num_input")
        self.assertEqual(source_arc_mathf_num_input["keys"]["value"]["java_expr"], "b")
        self.assertEqual(source_arc_mathf_num_input["keys"]["value"]["status"], "explicit-input")

        source_arc_mathf_num_result = source_symbols.state_schema(schema, "source_arc_mathf_num_result")
        self.assertEqual(source_arc_mathf_num_result["keys"]["trueValue"]["java_expr"], "1")
        self.assertEqual(source_arc_mathf_num_result["keys"]["falseValue"]["java_expr"], "0")
        self.assertEqual(source_arc_mathf_num_result["keys"]["num"]["java_expr"], "return b ? 1 : 0;")
        self.assertEqual(source_arc_mathf_num_result["keys"]["value"]["alias_of"], "source_arc_mathf_num_input.value")

        source_angle_distance_input = source_symbols.state_schema(schema, "source_angle_distance_input")
        self.assertEqual(source_angle_distance_input["keys"]["currentDegrees"]["java_expr"], "a")
        self.assertEqual(source_angle_distance_input["keys"]["currentDegrees"]["status"], "explicit-input")
        self.assertEqual(source_angle_distance_input["keys"]["targetDegrees"]["java_expr"], "b")
        self.assertEqual(source_angle_distance_input["keys"]["targetDegrees"]["status"], "explicit-input")

        source_angle_distance_result = source_symbols.state_schema(schema, "source_angle_distance_result")
        self.assertEqual(source_angle_distance_result["keys"]["currentMod"]["java_expr"], "a = Mathf.mod(a, 360f);")
        self.assertEqual(source_angle_distance_result["keys"]["targetMod"]["java_expr"], "b = Mathf.mod(b, 360f);")
        self.assertEqual(source_angle_distance_result["keys"]["angleDistance"]["java_expr"], "Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a)")
        self.assertEqual(source_angle_distance_result["keys"]["currentDegrees"]["alias_of"], "source_angle_distance_input.currentDegrees")
        self.assertEqual(source_angle_distance_result["keys"]["targetDegrees"]["alias_of"], "source_angle_distance_input.targetDegrees")

        source_angles_angle_dist_input = source_symbols.state_schema(schema, "source_angles_angle_dist_input")
        self.assertEqual(source_angles_angle_dist_input["keys"]["a"]["java_expr"], "a")
        self.assertEqual(source_angles_angle_dist_input["keys"]["b"]["java_expr"], "b")

        source_angles_angle_dist_result = source_symbols.state_schema(schema, "source_angles_angle_dist_result")
        self.assertEqual(source_angles_angle_dist_result["keys"]["angleDistance"]["java_expr"], "Math.min((a - b) < 0 ? a - b + 360 : a - b, (b - a) < 0 ? b - a + 360 : b - a)")
        self.assertEqual(source_angles_angle_dist_result["keys"]["a"]["alias_of"], "source_angles_angle_dist_input.a")
        self.assertEqual(source_angles_angle_dist_result["keys"]["b"]["alias_of"], "source_angles_angle_dist_input.b")

        source_angle_to_target_input = source_symbols.state_schema(schema, "source_angle_to_target_input")
        self.assertEqual(source_angle_to_target_input["keys"]["originX"]["java_expr"], "getX()")
        self.assertEqual(source_angle_to_target_input["keys"]["originY"]["java_expr"], "getY()")
        self.assertEqual(source_angle_to_target_input["keys"]["targetX"]["java_expr"], "other.getX()")
        self.assertEqual(source_angle_to_target_input["keys"]["targetY"]["java_expr"], "other.getY()")

        source_angle_to_target_result = source_symbols.state_schema(schema, "source_angle_to_target_result")
        self.assertEqual(source_angle_to_target_result["keys"]["targetAngle"]["java_expr"], "Angles.angle(getX(), getY(), other.getX(), other.getY())")
        self.assertEqual(source_angle_to_target_result["keys"]["angleFormula"]["java_expr"], "float ang = Mathf.atan2(x2 - x, y2 - y) * Mathf.radDeg;")
        self.assertEqual(source_angle_to_target_result["keys"]["originX"]["alias_of"], "source_angle_to_target_input.originX")
        self.assertEqual(source_angle_to_target_result["keys"]["targetY"]["alias_of"], "source_angle_to_target_input.targetY")

        self.assertEqual(bullet_type_state["keys"]["lifeScaleRandMin"]["java_expr"], "lifeScaleRandMin")
        self.assertEqual(bullet_type_state["keys"]["lifeScaleRandMax"]["java_expr"], "lifeScaleRandMax")
        self.assertEqual(bullet_type_state["keys"]["buildingDamageMultiplier"]["java_expr"], "buildingDamageMultiplier")
        self.assertIn("PortGame.source_bullet_type_create_keep_velocity_state", bullet_type_state["keys"]["keepVelocity"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_create_keep_velocity_state", bullet_type_state["keys"]["scaleKeepVelocity"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_create_lifetime_payload_damage_state", bullet_type_state["keys"]["lifetime"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_create_lifetime_payload_damage_state", bullet_type_state["keys"]["lifeScaleRandMin"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_create_lifetime_payload_damage_state", bullet_type_state["keys"]["lifeScaleRandMax"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_create_lifetime_payload_damage_state", bullet_type_state["keys"]["damage"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_create_lifetime_payload_damage_state", bullet_type_state["keys"]["hitSize"]["used_by"])
        self.assertIn("PortGame.source_bullet_type_create_lifetime_payload_damage_state", bullet_type_state["keys"]["buildingDamageMultiplier"]["used_by"])

        despawned_shake_output = source_symbols.state_schema(schema, "despawned_shake_result")
        self.assertEqual(despawned_shake_output["keys"]["shakeCall"]["java_expr"], "Effect.shake(despawnShake, despawnShake, b)")
        self.assertEqual(despawned_shake_output["keys"]["shakeCall"]["status"], "source-backed")
        self.assertEqual(despawned_shake_output["keys"]["despawnedSound"]["alias_of"], "despawned_sound_result")

        removed_trail_fade_output = source_symbols.state_schema(schema, "removed_trail_fade_result")
        self.assertEqual(removed_trail_fade_output["keys"]["gatePassed"]["java_expr"], "trailLength > 0 && b.trail != null && b.trail.size() > 0")
        self.assertEqual(removed_trail_fade_output["keys"]["trailFadeCall"]["java_expr"], "Fx.trailFade.at(b.x, b.y, trailWidth, trailColor, b.trail.copy())")
        self.assertEqual(removed_trail_fade_output["keys"]["trailFadeCall"]["status"], "source-backed")
        self.assertEqual(removed_trail_fade_output["keys"]["fragBoundarySource"]["status"], "deferred")

        removed_frag_dispatch_output = source_symbols.state_schema(schema, "removed_frag_dispatch_result")
        self.assertEqual(removed_frag_dispatch_output["keys"]["fragGatePassed"]["java_expr"], "b.frags == 0 && fragOnDespawn && fragBullet != null")
        self.assertEqual(removed_frag_dispatch_output["keys"]["createFragsCall"]["java_expr"], "createFrags(b, b.x, b.y)")
        self.assertEqual(removed_frag_dispatch_output["keys"]["createFragsCall"]["status"], "source-backed")
        self.assertEqual(removed_frag_dispatch_output["keys"]["removedTrailFade"]["alias_of"], "removed_trail_fade_result")

        draw_output = source_symbols.state_schema(schema, "draw_result")
        self.assertEqual(draw_output["keys"]["drawTrailCalled"]["java_expr"], "drawTrail(b);")
        self.assertEqual(draw_output["keys"]["drawPartsCalled"]["java_expr"], "drawParts(b);")
        self.assertEqual(draw_output["keys"]["drawReturnSource"]["java_expr"], "drawTrail(b); drawParts(b);")
        self.assertEqual(draw_output["keys"]["drawTrailBoundarySource"]["status"], "deferred")

        current_draw_z_state = source_symbols.state_schema(schema, "current_draw_z_state")
        self.assertEqual(current_draw_z_state["keys"]["current_draw_z"]["java_expr"], "Draw.z()")
        self.assertEqual(current_draw_z_state["keys"]["current_draw_z"]["status"], "explicit-input")

        draw_trail_output = source_symbols.state_schema(schema, "draw_trail_result")
        self.assertEqual(draw_trail_output["keys"]["gatePassed"]["java_expr"], "trailLength > 0 && b.trail != null")
        self.assertEqual(draw_trail_output["keys"]["trailDrawCall"]["java_expr"], "b.trail.draw(trailColor, trailWidth)")
        self.assertEqual(draw_trail_output["keys"]["drawZBelow"]["java_expr"], "Draw.z(z - 0.0001f)")
        self.assertEqual(draw_trail_output["keys"]["drawPartsBoundarySource"]["status"], "deferred")

        draw_light_output = source_symbols.state_schema(schema, "draw_light_result")
        self.assertEqual(draw_light_output["keys"]["gatePassed"]["java_expr"], "lightOpacity > 0f && lightRadius > 0f")
        self.assertEqual(draw_light_output["keys"]["drawfLightCall"]["java_expr"], "Drawf.light(b, lightRadius, lightColor, lightOpacity)")
        self.assertEqual(draw_light_output["keys"]["lightColor"]["java_expr"], "lightColor")
        self.assertEqual(draw_light_output["keys"]["initBoundarySource"]["status"], "deferred")

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
