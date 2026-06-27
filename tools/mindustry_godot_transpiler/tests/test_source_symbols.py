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

    def test_audit_reports_whole_godot_source_surface(self):
        registry = source_symbols.load_source_symbol_registry(ROOT / "godot-mindustry")
        audit = source_symbols.audit_godot_source_symbol_coverage(ROOT / "godot-mindustry", registry)

        self.assertGreater(audit["totalSourceFunctions"], 400)
        self.assertEqual(audit["registeredSourceOwnerCount"], 59)
        self.assertEqual(audit["exemptSourceOwnerCount"], 5)
        self.assertEqual(audit["legacyUnregisteredOwnerCount"], audit["totalSourceFunctions"] - 64)
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
