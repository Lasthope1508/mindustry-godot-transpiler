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
        self.assertEqual(audit["registeredSourceOwnerCount"], 106)
        self.assertEqual(audit["exemptSourceOwnerCount"], 5)
        self.assertEqual(audit["legacyUnregisteredOwnerCount"], audit["totalSourceFunctions"] - 111)
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
