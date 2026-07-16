# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/TractorBeamTurret.java
# Do not edit by hand.
extends RefCounted

const SourceTimeDefaults := preload("res://src/game/SourceTimeDefaults.gd")
const SOURCE_TICK_RATE := SourceTimeDefaults.TICK_RATE

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "TractorBeamTurret"
const JAVA_EXTENDS := "BaseTurret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "timerTarget", "type": "int"}, {"modifiers": ["public"], "name": "retargetTime", "type": "float"}, {"modifiers": ["public"], "name": "shootCone", "type": "float"}, {"modifiers": ["public"], "name": "shootLength", "type": "float"}, {"modifiers": ["public"], "name": "laserWidth", "type": "float"}, {"modifiers": ["public"], "name": "force", "type": "float"}, {"modifiers": ["public"], "name": "scaledForce", "type": "float"}, {"modifiers": ["public"], "name": "damage", "type": "float"}, {"modifiers": ["public"], "name": "targetAir", "type": "boolean"}, {"modifiers": ["public"], "name": "targetGround", "type": "boolean"}, {"modifiers": ["public"], "name": "laserColor", "type": "Color"}, {"modifiers": ["public"], "name": "status", "type": "StatusEffect"}, {"modifiers": ["public"], "name": "statusDuration", "type": "float"}, {"modifiers": ["public"], "name": "shootSound", "type": "Sound"}, {"modifiers": ["public"], "name": "shootSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "baseRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laser", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserStart", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserEnd", "type": "TextureRegion"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "TractorBeamTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_icons_0(_args: Array = []) -> Variant:
	var base_region: Variant = _args[0] if _args.size() > 0 else null
	var region: Variant = _args[1] if _args.size() > 1 else null
	var icons: Array = [base_region, region]
	return {"source_owner": "PortGame.source_tractor_beam_turret_icons_state", "method": "public TextureRegion[] icons(){", "override_expr": "@Override", "return_expr": "return new TextureRegion[]{baseRegion, region};", "base_region": base_region, "region": region, "icons": icons}

func java_method_setStats_1(_args: Array = []) -> Variant:
	var target_air: bool = bool(_args[0] if _args.size() > 0 else true)
	var target_ground: bool = bool(_args[1] if _args.size() > 1 else false)
	var damage: float = float(_args[2] if _args.size() > 2 else 0.0)
	var source_tick_rate: float = float(_args[3] if _args.size() > 3 else SOURCE_TICK_RATE)
	var targets_air_stat_call: Dictionary = {"call": "stats.add(Stat.targetsAir, targetAir);", "stat": "Stat.targetsAir", "value": target_air}
	var targets_ground_stat_call: Dictionary = {"call": "stats.add(Stat.targetsGround, targetGround);", "stat": "Stat.targetsGround", "value": target_ground}
	var damage_per_second: float = damage * source_tick_rate
	var damage_stat_added: bool = damage > 0.0
	var damage_stat_call: Dictionary = {}
	if damage_stat_added:
		damage_stat_call = {"call": "stats.add(Stat.damage, damage * 60f, StatUnit.perSecond);", "stat": "Stat.damage", "value": damage_per_second, "unit": "StatUnit.perSecond"}
	return {"source_owner": "PortGame.source_tractor_beam_turret_set_stats_state", "method": "public void setStats(){", "override_expr": "@Override", "super_set_stats_expr": "super.setStats();", "targets_air_stat_expr": "stats.add(Stat.targetsAir, targetAir);", "targets_ground_stat_expr": "stats.add(Stat.targetsGround, targetGround);", "damage_stat_expr": "if(damage > 0) stats.add(Stat.damage, damage * 60f, StatUnit.perSecond);", "target_air": target_air, "target_ground": target_ground, "damage": damage, "super_set_stats_called": true, "targets_air_stat_call": targets_air_stat_call, "targets_ground_stat_call": targets_ground_stat_call, "damage_per_second": damage_per_second, "damage_stat_added": damage_stat_added, "damage_stat_call": damage_stat_call}

func java_method_init_2(_args: Array = []) -> Variant:
	var range_value: float = float(_args[0] if _args.size() > 0 else 0.0)
	var source_tilesize: float = float(_args[1] if _args.size() > 1 else 8.0)
	var clip_radius: float = range_value + source_tilesize
	var update_clip_radius_call: Dictionary = {"call": "updateClipRadius(range + tilesize);", "radius": clip_radius}
	return {"source_owner": "PortGame.source_tractor_beam_turret_init_state", "method": "public void init(){", "override_expr": "@Override", "super_init_expr": "super.init();", "update_clip_radius_expr": "updateClipRadius(range + tilesize);", "range": range_value, "tilesize": source_tilesize, "clip_radius": clip_radius, "super_init_called": true, "update_clip_radius_called": true, "update_clip_radius_call": update_clip_radius_call}

func java_inner_class_TractorBeamBuild_method_updateTile_0(_args: Array = []) -> Variant:
	var activation_timer: float = float(_args[0] if _args.size() > 0 else 0.0)
	var time_delta: float = float(_args[1] if _args.size() > 1 else 0.0)
	var activation_guard: bool = activation_timer > 0.0
	var activation_timer_after: float = activation_timer - time_delta if activation_guard else activation_timer
	var returned_early: bool = activation_guard
	var activation_returned_early: bool = activation_guard
	var efficiency: float = float(_args[2] if _args.size() > 2 else 0.0)
	var coolant_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)
	var delta_value: float = float(_args[4] if _args.size() > 4 else 0.0)
	var eff_calculated: bool = not activation_returned_early
	var eff: float = efficiency * coolant_multiplier if eff_calculated else 0.0
	var edelta: float = eff * delta_value if eff_calculated else 0.0
	var timer_target_ready: bool = bool(_args[5] if _args.size() > 5 else false)
	var existing_target: Variant = _args[6] if _args.size() > 6 else null
	var closest_enemy_result: Variant = _args[7] if _args.size() > 7 else null
	var team: Variant = _args[8] if _args.size() > 8 else null
	var x: float = float(_args[9] if _args.size() > 9 else 0.0)
	var y: float = float(_args[10] if _args.size() > 10 else 0.0)
	var range_value: float = float(_args[11] if _args.size() > 11 else 0.0)
	var target_air: bool = bool(_args[12] if _args.size() > 12 else false)
	var target_ground: bool = bool(_args[13] if _args.size() > 13 else false)
	var retarget_evaluated: bool = not activation_returned_early
	var retarget_called: bool = retarget_evaluated and timer_target_ready
	var target_after: Variant = closest_enemy_result if retarget_called else existing_target
	var closest_enemy_call: Dictionary = {}
	if retarget_called:
		closest_enemy_call = {"call": "Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));", "team": team, "x": x, "y": y, "range": range_value, "target_air": target_air, "target_ground": target_ground, "result": closest_enemy_result}
	var coolant_present: bool = bool(_args[14] if _args.size() > 14 else false)
	var coolant_amount: float = float(_args[15] if _args.size() > 15 else 0.0)
	var current_liquid: Variant = _args[16] if _args.size() > 16 else null
	var coolant_evaluated: bool = not activation_returned_early
	var coolant_guard: bool = coolant_evaluated and target_after != null and coolant_present
	var max_used: float = coolant_amount if coolant_guard else 0.0
	var liquid: Variant = current_liquid if coolant_guard else null
	var liquid_amount: float = float(_args[17] if _args.size() > 17 else 0.0)
	var liquid_heat_capacity: float = float(_args[18] if _args.size() > 18 else 1.0)
	var max_used_time_delta: float = max_used * time_delta if coolant_guard else 0.0
	var heat_capacity_limit: float = (1.0 / coolant_multiplier) / liquid_heat_capacity if coolant_guard else 0.0
	var nonnegative_heat_capacity_limit: float = max(0.0, heat_capacity_limit) if coolant_guard else 0.0
	var used: float = min(min(liquid_amount, max_used_time_delta), nonnegative_heat_capacity_limit) if coolant_guard else 0.0
	var remove_called: bool = coolant_guard
	var remove_call: Dictionary = {}
	if remove_called:
		remove_call = {"call": "liquids.remove(liquid, used);", "liquid": liquid, "amount": used}
	var chance_result: bool = bool(_args[19] if _args.size() > 19 else false)
	var size: float = float(_args[20] if _args.size() > 20 else 0.0)
	var source_tilesize: float = float(_args[21] if _args.size() > 21 else 8.0)
	var range_x: float = float(_args[22] if _args.size() > 22 else 0.0)
	var range_y: float = float(_args[23] if _args.size() > 23 else 0.0)
	var chance_threshold: float = 0.06 * used if coolant_guard else 0.0
	var particle_range: float = size * source_tilesize / 2.0 if coolant_guard else 0.0
	var chance_called: bool = coolant_guard
	var cool_effect_called: bool = coolant_guard and chance_result
	var cool_effect_call: Dictionary = {}
	if cool_effect_called:
		cool_effect_call = {"call": "coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));", "x": x + range_x, "y": y + range_y, "range": particle_range}
	var coolant_multiplier_assign_called: bool = coolant_guard
	var coolant_multiplier_after: float = 1.0 + (used * liquid_heat_capacity * coolant_multiplier) if coolant_guard else coolant_multiplier
	var coolant_multiplier_assign_call: Dictionary = {}
	if coolant_multiplier_assign_called:
		coolant_multiplier_assign_call = {"call": "coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);", "value": coolant_multiplier_after}
	var any_before: bool = bool(_args[24] if _args.size() > 24 else false)
	var any_reset_evaluated: bool = not activation_returned_early
	var any_reset_called: bool = any_reset_evaluated
	var any_after: bool = false if any_reset_evaluated else any_before
	var any_reset_call: Dictionary = {}
	if any_reset_called:
		any_reset_call = {"call": "any = false;", "value": any_after}
	var target_within_result: bool = bool(_args[25] if _args.size() > 25 else false)
	var target_team: Variant = _args[26] if _args.size() > 26 else null
	var target_check_result: bool = bool(_args[27] if _args.size() > 27 else false)
	var target_hit_size: float = float(_args[28] if _args.size() > 28 else 0.0)
	var look_target_evaluated: bool = not activation_returned_early
	var target_exists_for_look: bool = look_target_evaluated and target_after != null
	var target_within_radius: float = range_value + target_hit_size / 2.0 if target_exists_for_look else 0.0
	var target_within_evaluated: bool = target_exists_for_look
	var target_within_call: Dictionary = {}
	if target_within_evaluated:
		target_within_call = {"call": "target.within(this, range + target.hitSize/2f)", "target": target_after, "radius": target_within_radius, "result": target_within_result}
	var target_team_evaluated: bool = target_within_evaluated and target_within_result
	var target_enemy: bool = target_team != team if target_team_evaluated else false
	var target_check_evaluated: bool = target_team_evaluated and target_enemy
	var target_check_call: Dictionary = {}
	if target_check_evaluated:
		target_check_call = {"call": "target.checkTarget(targetAir, targetGround)", "target_air": target_air, "target_ground": target_ground, "result": target_check_result}
	var efficiency_gate_evaluated: bool = target_check_evaluated and target_check_result
	var look_target_guard: bool = efficiency_gate_evaluated and efficiency > 0.02
	var headless: bool = bool(_args[29] if _args.size() > 29 else false)
	var shoot_sound: Variant = _args[30] if _args.size() > 30 else null
	var shoot_sound_volume: float = float(_args[31] if _args.size() > 31 else 1.0)
	var sound_loop_evaluated: bool = look_target_guard
	var sound_loop_called: bool = sound_loop_evaluated and not headless
	var shoot_sound_loop_call: Dictionary = {}
	if sound_loop_called:
		shoot_sound_loop_call = {"call": "control.sound.loop(shootSound, this, shootSoundVolume);", "sound": shoot_sound, "target": "this", "volume": shoot_sound_volume}
	var angle_to_target_evaluated: bool = look_target_guard
	var dest: float = 0.0
	if angle_to_target_evaluated and target_after is Dictionary:
		dest = rad_to_deg(atan2(float(target_after.get("y", 0.0)) - y, float(target_after.get("x", 0.0)) - x))
		if dest < 0.0:
			dest += 360.0
	var angle_to_target_call: Dictionary = {}
	if angle_to_target_evaluated:
		angle_to_target_call = {"call": "angleTo(target)", "origin": {"x": x, "y": y}, "target": target_after, "result": dest}
	var rotation_before: float = float(_args[32] if _args.size() > 32 else 0.0)
	var rotate_speed: float = float(_args[33] if _args.size() > 33 else 0.0)
	var rotation_move_evaluated: bool = angle_to_target_evaluated
	var rotation_max_delta: float = rotate_speed * edelta if rotation_move_evaluated else 0.0
	var rotation_after: float = rotation_before
	var rotation_move_call: Dictionary = {}
	if rotation_move_evaluated:
		var rotation_angle_mod: float = fmod(fmod(rotation_before, 360.0) + 360.0, 360.0)
		var rotation_to_mod: float = fmod(fmod(dest, 360.0) + 360.0, 360.0)
		var rotation_forward_delta: float = rotation_angle_mod - rotation_to_mod + 360.0 if (rotation_angle_mod - rotation_to_mod) < 0.0 else rotation_angle_mod - rotation_to_mod
		var rotation_backward_delta: float = rotation_to_mod - rotation_angle_mod + 360.0 if (rotation_to_mod - rotation_angle_mod) < 0.0 else rotation_to_mod - rotation_angle_mod
		var rotation_angle_dist: float = min(rotation_forward_delta, rotation_backward_delta)
		if abs(rotation_angle_dist) < rotation_max_delta:
			rotation_after = dest
		elif (rotation_angle_mod > rotation_to_mod) == ((360.0 - abs(rotation_angle_mod - rotation_to_mod)) > abs(rotation_angle_mod - rotation_to_mod)):
			rotation_after = rotation_angle_mod - rotation_max_delta
		else:
			rotation_after = rotation_angle_mod + rotation_max_delta
		rotation_move_call = {"call": "Angles.moveToward(rotation, dest, rotateSpeed * edelta)", "rotation": rotation_before, "dest": dest, "speed": rotation_max_delta, "result": rotation_after}
	var last_x_before: float = float(_args[34] if _args.size() > 34 else 0.0)
	var last_y_before: float = float(_args[35] if _args.size() > 35 else 0.0)
	var last_target_position_evaluated: bool = rotation_move_evaluated
	var last_x_after: float = last_x_before
	var last_y_after: float = last_y_before
	var last_target_position_call: Dictionary = {}
	if last_target_position_evaluated and target_after is Dictionary:
		last_x_after = float(target_after.get("x", last_x_before))
		last_y_after = float(target_after.get("y", last_y_before))
		last_target_position_call = {"call": "lastX = target.x; lastY = target.y;", "target": target_after, "last_x": last_x_after, "last_y": last_y_after}
	var strength_before: float = float(_args[36] if _args.size() > 36 else 0.0)
	var strength_lerp_evaluated: bool = last_target_position_evaluated
	var strength_lerp_progress: float = 0.1
	var strength_lerp_scaled_progress: float = strength_lerp_progress * time_delta if strength_lerp_evaluated else 0.0
	var strength_lerp_clamped_progress: float = clampf(strength_lerp_scaled_progress, 0.0, 1.0)
	var strength_after: float = strength_before + (1.0 - strength_before) * strength_lerp_clamped_progress if strength_lerp_evaluated else strength_before
	var strength_lerp_call: Dictionary = {}
	if strength_lerp_evaluated:
		strength_lerp_call = {"call": "strength = Mathf.lerpDelta(strength, 1f, 0.1f);", "from": strength_before, "to": 1.0, "progress": strength_lerp_progress, "time_delta": time_delta, "result": strength_after}
	var inactive_strength_evaluated: bool = not activation_returned_early and not look_target_guard
	var inactive_strength_lerp_progress: float = 0.1
	var inactive_strength_lerp_scaled_progress: float = inactive_strength_lerp_progress * time_delta if inactive_strength_evaluated else 0.0
	var inactive_strength_lerp_clamped_progress: float = clampf(inactive_strength_lerp_scaled_progress, 0.0, 1.0)
	var inactive_strength_after: float = strength_before + (0.0 - strength_before) * inactive_strength_lerp_clamped_progress if inactive_strength_evaluated else strength_after
	var inactive_strength_lerp_call: Dictionary = {}
	if inactive_strength_evaluated:
		strength_after = inactive_strength_after
		inactive_strength_lerp_call = {"call": "strength = Mathf.lerpDelta(strength, 0, 0.1f);", "from": strength_before, "to": 0.0, "progress": inactive_strength_lerp_progress, "time_delta": time_delta, "result": inactive_strength_after}
	var shoot_cone: float = float(_args[37] if _args.size() > 37 else 0.0)
	var shoot_when_possible_evaluated: bool = strength_lerp_evaluated
	var shoot_within_angle_dist: float = 0.0
	if shoot_when_possible_evaluated:
		var shoot_rotation_mod: float = fmod(fmod(rotation_after, 360.0) + 360.0, 360.0)
		var shoot_dest_mod: float = fmod(fmod(dest, 360.0) + 360.0, 360.0)
		var shoot_forward_delta: float = shoot_rotation_mod - shoot_dest_mod + 360.0 if (shoot_rotation_mod - shoot_dest_mod) < 0.0 else shoot_rotation_mod - shoot_dest_mod
		var shoot_backward_delta: float = shoot_dest_mod - shoot_rotation_mod + 360.0 if (shoot_dest_mod - shoot_rotation_mod) < 0.0 else shoot_dest_mod - shoot_rotation_mod
		shoot_within_angle_dist = min(shoot_forward_delta, shoot_backward_delta)
	var shoot_within_guard: bool = shoot_when_possible_evaluated and shoot_within_angle_dist <= shoot_cone
	var shoot_within_call: Dictionary = {}
	if shoot_when_possible_evaluated:
		shoot_within_call = {"call": "Angles.within(rotation, dest, shootCone)", "rotation": rotation_after, "dest": dest, "shoot_cone": shoot_cone, "angle_dist": shoot_within_angle_dist, "result": shoot_within_guard}
	var damage: float = float(_args[38] if _args.size() > 38 else 0.0)
	var time_scale: float = float(_args[39] if _args.size() > 39 else 1.0)
	var rules_block_damage: float = float(_args[40] if _args.size() > 40 else 1.0)
	var damage_gate_evaluated: bool = shoot_within_guard
	var damage_gate: bool = damage_gate_evaluated and damage > 0.0
	var damage_amount: float = damage * eff * time_scale * rules_block_damage if damage_gate else 0.0
	var block_damage_call: Dictionary = {}
	if damage_gate:
		block_damage_call = {"call": "state.rules.blockDamage(team)", "team": team, "result": rules_block_damage}
	var damage_continuous_pierce_call: Dictionary = {}
	if damage_gate:
		damage_continuous_pierce_call = {"call": "target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));", "target": target_after, "amount": damage_amount}
	var status: Variant = _args[41] if _args.size() > 41 else "StatusEffects.none"
	var status_duration: float = float(_args[42] if _args.size() > 42 else 300.0)
	var status_gate_evaluated: bool = shoot_within_guard
	var status_is_none: bool = status is String and status == "StatusEffects.none"
	var status_gate: bool = status_gate_evaluated and not status_is_none
	var status_apply_call: Dictionary = {}
	if status_gate:
		status_apply_call = {"call": "target.apply(status, statusDuration);", "target": target_after, "status": status, "duration": status_duration}
	var any_before_shoot: bool = any_after
	var any_true_evaluated: bool = shoot_within_guard
	var any_true_called: bool = any_true_evaluated
	var any_true_call: Dictionary = {}
	if any_true_called:
		any_after = true
		any_true_call = {"call": "any = true;", "value": any_after}
	var force_value: float = float(_args[43]) if _args.size() > 43 else 0.3
	var scaled_force: float = float(_args[44]) if _args.size() > 44 else 0.0
	var target_x_for_impulse: float = x
	var target_y_for_impulse: float = y
	if target_after is Dictionary:
		target_x_for_impulse = float(target_after.get("x", x))
		target_y_for_impulse = float(target_after.get("y", y))
	var impulse_vector_x: float = x - target_x_for_impulse
	var impulse_vector_y: float = y - target_y_for_impulse
	var target_dst_to_building: float = sqrt(pow(target_x_for_impulse - x, 2) + pow(target_y_for_impulse - y, 2))
	var impulse_limit: float = (force_value + (1.0 - target_dst_to_building / range_value) * scaled_force) * edelta
	var impulse_net_called: bool = any_true_called
	if impulse_net_called:
		var impulse_len2: float = impulse_vector_x * impulse_vector_x + impulse_vector_y * impulse_vector_y
		var impulse_limit2: float = impulse_limit * impulse_limit
		if impulse_len2 > impulse_limit2:
			var impulse_scale: float = sqrt(impulse_limit2 / impulse_len2)
			impulse_vector_x *= impulse_scale
			impulse_vector_y *= impulse_scale
	var impulse_net_call: Dictionary = {}
	if impulse_net_called:
		impulse_net_call = {"call": "target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));", "target": target_after, "x": impulse_vector_x, "y": impulse_vector_y, "limit": impulse_limit, "target_dst_to_building": target_dst_to_building, "force": force_value, "scaled_force": scaled_force}
	return {"source_owner": "PortGame.source_tractor_beam_turret_build_update_tile_activation_state", "inner_class": "public class TractorBeamBuild extends BaseTurretBuild{", "method": "public void updateTile(){", "override_expr": "@Override", "activation_guard_expr": "if(activationTimer > 0){", "activation_decrement_expr": "activationTimer -= Time.delta;", "return_expr": "return;", "next_expr": "float eff = efficiency * coolantMultiplier, edelta = eff * delta();", "eff_expr": "float eff = efficiency * coolantMultiplier, edelta = eff * delta();", "retarget_comment_expr": "//retarget", "retarget_guard_expr": "if(timer(timerTarget, retargetTime)){", "retarget_assign_expr": "target = Units.closestEnemy(team, x, y, range, u -> u.checkTarget(targetAir, targetGround));", "target_check_filter_expr": "u -> u.checkTarget(targetAir, targetGround)", "coolant_comment_expr": "//consume coolant", "coolant_guard_expr": "if(target != null && coolant != null){", "max_used_expr": "float maxUsed = coolant.amount;", "current_liquid_expr": "Liquid liquid = liquids.current();", "liquids_get_expr": "liquids.get(liquid)", "max_used_time_delta_expr": "maxUsed * Time.delta", "heat_capacity_limit_expr": "(1f / coolantMultiplier) / liquid.heatCapacity", "used_expr": "float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));", "remove_next_expr": "liquids.remove(liquid, used);", "remove_expr": "liquids.remove(liquid, used);", "chance_expr": "Mathf.chance(0.06 * used)", "cool_effect_expr": "coolEffect.at(x + Mathf.range(size * tilesize / 2f), y + Mathf.range(size * tilesize / 2f));", "coolant_multiplier_assign_expr": "coolantMultiplier = 1f + (used * liquid.heatCapacity * coolantMultiplier);", "any_reset_expr": "any = false;", "look_target_comment_expr": "//look at target", "look_target_guard_expr": "if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){", "sound_loop_guard_expr": "if(!headless){", "shoot_sound_loop_expr": "control.sound.loop(shootSound, this, shootSoundVolume);", "dest_expr": "float dest = angleTo(target);", "rotation_move_expr": "rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);", "last_x_expr": "lastX = target.x;", "last_y_expr": "lastY = target.y;", "strength_next_expr": "strength = Mathf.lerpDelta(strength, 1f, 0.1f);", "strength_lerp_expr": "strength = Mathf.lerpDelta(strength, 1f, 0.1f);", "inactive_strength_lerp_expr": "strength = Mathf.lerpDelta(strength, 0, 0.1f);", "shoot_when_possible_next_expr": "if(Angles.within(rotation, dest, shootCone)){", "shoot_when_possible_comment_expr": "//shoot when possible", "shoot_when_possible_guard_expr": "if(Angles.within(rotation, dest, shootCone)){", "angles_within_method": "public static boolean within(float a, float b, float margin){\n        return angleDist(a, b) <= margin;\n    }", "damage_next_expr": "if(damage > 0){", "damage_gate_expr": "if(damage > 0){", "damage_continuous_pierce_expr": "target.damageContinuousPierce(damage * eff * timeScale * state.rules.blockDamage(team));", "rules_block_damage_method": "public float blockDamage(Team team){\n        return blockDamageMultiplier * teams.get(team).blockDamageMultiplier;\n    }", "damage_continuous_pierce_method": "void damageContinuousPierce(float amount){\n        damagePierce(amount * Time.delta, hitTime <= -20 + hitDuration);\n    }", "status_next_expr": "if(status != StatusEffects.none){", "status_gate_expr": "if(status != StatusEffects.none){", "status_apply_expr": "target.apply(status, statusDuration);", "status_field_expr": "public StatusEffect status = StatusEffects.none;", "status_duration_field_expr": "public float statusDuration = 300;", "status_apply_method": "public void apply(StatusEffect effect, float duration){\n        if(effect == StatusEffects.none || effect == null || isImmune(effect)) return; //don't apply empty or immune effects\n    }", "any_next_expr": "any = true;", "any_true_expr": "any = true;", "force_expr": "public float force = 0.3f;", "scaled_force_expr": "public float scaledForce = 0f;", "impulse_next_expr": "target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));", "impulse_net_expr": "target.impulseNet(Tmp.v1.set(this).sub(target).limit((force + (1f - target.dst(this) / range) * scaledForce) * edelta));", "used_next_expr": "float used = Math.min(Math.min(liquids.get(liquid), maxUsed * Time.delta), Math.max(0, (1f / coolantMultiplier) / liquid.heatCapacity));", "activation_timer": activation_timer, "time_delta": time_delta, "activation_guard": activation_guard, "activation_timer_after": activation_timer_after, "returned_early": returned_early, "activation_returned_early": activation_returned_early, "efficiency": efficiency, "coolant_multiplier": coolant_multiplier, "delta_value": delta_value, "eff_calculated": eff_calculated, "eff": eff, "edelta": edelta, "timer_target_ready": timer_target_ready, "existing_target": existing_target, "closest_enemy_result": closest_enemy_result, "team": team, "x": x, "y": y, "range_value": range_value, "target_air": target_air, "target_ground": target_ground, "retarget_evaluated": retarget_evaluated, "retarget_called": retarget_called, "target_after": target_after, "closest_enemy_call": closest_enemy_call, "coolant_present": coolant_present, "coolant_amount": coolant_amount, "current_liquid": current_liquid, "coolant_evaluated": coolant_evaluated, "coolant_guard": coolant_guard, "max_used": max_used, "liquid": liquid, "liquid_amount": liquid_amount, "liquid_heat_capacity": liquid_heat_capacity, "max_used_time_delta": max_used_time_delta, "heat_capacity_limit": heat_capacity_limit, "nonnegative_heat_capacity_limit": nonnegative_heat_capacity_limit, "used": used, "remove_called": remove_called, "remove_call": remove_call, "chance_result": chance_result, "size": size, "source_tilesize": source_tilesize, "range_x": range_x, "range_y": range_y, "chance_threshold": chance_threshold, "particle_range": particle_range, "chance_called": chance_called, "cool_effect_called": cool_effect_called, "cool_effect_call": cool_effect_call, "coolant_multiplier_assign_called": coolant_multiplier_assign_called, "coolant_multiplier_after": coolant_multiplier_after, "coolant_multiplier_assign_call": coolant_multiplier_assign_call, "any_before": any_before, "any_reset_evaluated": any_reset_evaluated, "any_reset_called": any_reset_called, "any_after": any_after, "any_reset_call": any_reset_call, "target_within_result": target_within_result, "target_team": target_team, "target_check_result": target_check_result, "target_hit_size": target_hit_size, "look_target_evaluated": look_target_evaluated, "target_exists_for_look": target_exists_for_look, "target_within_radius": target_within_radius, "target_within_evaluated": target_within_evaluated, "target_within_call": target_within_call, "target_team_evaluated": target_team_evaluated, "target_enemy": target_enemy, "target_check_evaluated": target_check_evaluated, "target_check_call": target_check_call, "efficiency_gate_evaluated": efficiency_gate_evaluated, "look_target_guard": look_target_guard, "headless": headless, "shoot_sound": shoot_sound, "shoot_sound_volume": shoot_sound_volume, "sound_loop_evaluated": sound_loop_evaluated, "sound_loop_called": sound_loop_called, "shoot_sound_loop_call": shoot_sound_loop_call, "angle_to_target_evaluated": angle_to_target_evaluated, "dest": dest, "angle_to_target_call": angle_to_target_call, "rotation_before": rotation_before, "rotate_speed": rotate_speed, "rotation_move_evaluated": rotation_move_evaluated, "rotation_max_delta": rotation_max_delta, "rotation_after": rotation_after, "rotation_move_call": rotation_move_call, "last_x_before": last_x_before, "last_y_before": last_y_before, "last_target_position_evaluated": last_target_position_evaluated, "last_x_after": last_x_after, "last_y_after": last_y_after, "last_target_position_call": last_target_position_call, "strength_before": strength_before, "strength_lerp_evaluated": strength_lerp_evaluated, "strength_lerp_progress": strength_lerp_progress, "strength_lerp_scaled_progress": strength_lerp_scaled_progress, "strength_lerp_clamped_progress": strength_lerp_clamped_progress, "strength_after": strength_after, "strength_lerp_call": strength_lerp_call, "inactive_strength_evaluated": inactive_strength_evaluated, "inactive_strength_lerp_progress": inactive_strength_lerp_progress, "inactive_strength_lerp_scaled_progress": inactive_strength_lerp_scaled_progress, "inactive_strength_lerp_clamped_progress": inactive_strength_lerp_clamped_progress, "inactive_strength_after": inactive_strength_after, "inactive_strength_lerp_call": inactive_strength_lerp_call, "shoot_cone": shoot_cone, "shoot_when_possible_evaluated": shoot_when_possible_evaluated, "shoot_within_angle_dist": shoot_within_angle_dist, "shoot_within_guard": shoot_within_guard, "shoot_within_call": shoot_within_call, "damage": damage, "time_scale": time_scale, "rules_block_damage": rules_block_damage, "damage_gate_evaluated": damage_gate_evaluated, "damage_gate": damage_gate, "damage_amount": damage_amount, "block_damage_call": block_damage_call, "damage_continuous_pierce_call": damage_continuous_pierce_call, "status": status, "status_duration": status_duration, "status_is_none": status_is_none, "status_gate_evaluated": status_gate_evaluated, "status_gate": status_gate, "status_apply_call": status_apply_call, "any_before_shoot": any_before_shoot, "any_true_evaluated": any_true_evaluated, "any_true_called": any_true_called, "any_true_call": any_true_call, "force_value": force_value, "scaled_force": scaled_force, "target_x_for_impulse": target_x_for_impulse, "target_y_for_impulse": target_y_for_impulse, "target_dst_to_building": target_dst_to_building, "impulse_limit": impulse_limit, "impulse_vector_x": impulse_vector_x, "impulse_vector_y": impulse_vector_y, "impulse_net_called": impulse_net_called, "impulse_net_call": impulse_net_call}

func java_inner_class_TractorBeamBuild_method_shouldConsume_1(_args: Array = []) -> Variant:
	var super_should_consume: bool = bool(_args[0] if _args.size() > 0 else false)
	var target: Variant = _args[1] if _args.size() > 1 else null
	var target_present: bool = target != null
	var should_consume: bool = super_should_consume and target_present
	return {"source_owner": "PortGame.source_tractor_beam_turret_build_should_consume_state", "inner_class": "public class TractorBeamBuild extends BaseTurretBuild{", "field": "public @Nullable Unit target;", "method": "public boolean shouldConsume(){", "override_expr": "@Override", "return_expr": "return super.shouldConsume() && target != null;", "super_should_consume": super_should_consume, "target": target, "target_present": target_present, "should_consume": should_consume}

func java_inner_class_TractorBeamBuild_method_estimateDps_2(_args: Array = []) -> Variant:
	var any_state: bool = bool(_args[0] if _args.size() > 0 else false)
	var damage: float = float(_args[1] if _args.size() > 1 else 0.0)
	var efficiency: float = float(_args[2] if _args.size() > 2 else 0.0)
	var coolant_multiplier: float = float(_args[3] if _args.size() > 3 else 1.0)
	var zero_guard: bool = (not any_state) or damage <= 0.0
	var estimate_dps: float = 0.0 if zero_guard else damage * 60.0 * efficiency * coolant_multiplier
	return {"source_owner": "PortGame.source_tractor_beam_turret_build_estimate_dps_state", "inner_class": "public class TractorBeamBuild extends BaseTurretBuild{", "method": "public float estimateDps(){", "override_expr": "@Override", "zero_guard_expr": "if(!any || damage <= 0) return 0f;", "return_expr": "return damage * 60f * efficiency * coolantMultiplier;", "any_state": any_state, "damage": damage, "efficiency": efficiency, "coolant_multiplier": coolant_multiplier, "zero_guard": zero_guard, "estimate_dps": estimate_dps}

func java_inner_class_TractorBeamBuild_method_draw_3(_args: Array = []) -> Variant:
	var base_region: Variant = _args[0] if _args.size() > 0 else null
	var region: Variant = _args[1] if _args.size() > 1 else null
	var x: float = float(_args[2] if _args.size() > 2 else 0.0)
	var y: float = float(_args[3] if _args.size() > 3 else 0.0)
	var rotation_value: float = float(_args[4] if _args.size() > 4 else 0.0)
	var size: float = float(_args[5] if _args.size() > 5 else 0.0)
	var any_state: bool = bool(_args[6] if _args.size() > 6 else false)
	var is_payload: bool = bool(_args[7] if _args.size() > 7 else false)
	var last_x: float = float(_args[8] if _args.size() > 8 else 0.0)
	var last_y: float = float(_args[9] if _args.size() > 9 else 0.0)
	var laser_color: Variant = _args[10] if _args.size() > 10 else null
	var mathf_absin_4_0_6: float = float(_args[11] if _args.size() > 11 else 0.0)
	var laser: Variant = _args[12] if _args.size() > 12 else null
	var laser_start: Variant = _args[13] if _args.size() > 13 else null
	var laser_end: Variant = _args[14] if _args.size() > 14 else null
	var shoot_length: float = float(_args[15] if _args.size() > 15 else 0.0)
	var strength: float = float(_args[16] if _args.size() > 16 else 0.0)
	var efficiency: float = float(_args[17] if _args.size() > 17 else 0.0)
	var laser_width: float = float(_args[18] if _args.size() > 18 else 0.0)
	var draw_rotation: float = rotation_value - 90.0
	var base_rect_call: Dictionary = {"call": "Draw.rect(baseRegion, x, y);", "region": base_region, "x": x, "y": y}
	var shadow_call: Dictionary = {"call": "Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);", "region": region, "x": x - size / 2.0, "y": y - size / 2.0, "rotation": draw_rotation}
	var region_rect_call: Dictionary = {"call": "Draw.rect(region, x, y, rotation - 90);", "region": region, "x": x, "y": y, "rotation": draw_rotation}
	var laser_guard: bool = any_state and not is_payload
	var angle_to_last: float = rad_to_deg(atan2(last_y - y, last_x - x))
	var laser_start_x: float = x + cos(deg_to_rad(angle_to_last)) * shoot_length
	var laser_start_y: float = y + sin(deg_to_rad(angle_to_last)) * shoot_length
	var laser_width_value: float = strength * efficiency * laser_width
	var draw_z_call: Dictionary = {}
	var mixcol_call: Dictionary = {}
	var laser_call: Dictionary = {}
	var mixcol_reset_called: bool = false
	if laser_guard:
		draw_z_call = {"call": "Draw.z(Layer.bullet);", "layer": "Layer.bullet"}
		mixcol_call = {"call": "Draw.mixcol(laserColor, Mathf.absin(4f, 0.6f));", "color": laser_color, "alpha": mathf_absin_4_0_6}
		laser_call = {"call": "Drawf.laser(laser, laserStart, laserEnd, x + Angles.trnsx(ang, shootLength), y + Angles.trnsy(ang, shootLength), lastX, lastY, strength * efficiency * laserWidth);", "laser": laser, "laser_start": laser_start, "laser_end": laser_end, "start_x": laser_start_x, "start_y": laser_start_y, "end_x": last_x, "end_y": last_y, "width": laser_width_value}
		mixcol_reset_called = true
	return {"source_owner": "PortGame.source_tractor_beam_turret_build_draw_state", "inner_class": "public class TractorBeamBuild extends BaseTurretBuild{", "method": "public void draw(){", "override_expr": "@Override", "base_rect_expr": "Draw.rect(baseRegion, x, y);", "shadow_expr": "Drawf.shadow(region, x - (size / 2f), y - (size / 2f), rotation - 90);", "region_rect_expr": "Draw.rect(region, x, y, rotation - 90);", "laser_guard_expr": "if(any && !isPayload()){", "draw_z_expr": "Draw.z(Layer.bullet);", "angle_expr": "float ang = angleTo(lastX, lastY);", "mixcol_expr": "Draw.mixcol(laserColor, Mathf.absin(4f, 0.6f));", "laser_expr": "Drawf.laser(laser, laserStart, laserEnd, x + Angles.trnsx(ang, shootLength), y + Angles.trnsy(ang, shootLength), lastX, lastY, strength * efficiency * laserWidth);", "mixcol_reset_expr": "Draw.mixcol();", "base_region": base_region, "region": region, "x": x, "y": y, "rotation": rotation_value, "size": size, "any_state": any_state, "is_payload": is_payload, "last_x": last_x, "last_y": last_y, "laser_color": laser_color, "mathf_absin_4_0_6": mathf_absin_4_0_6, "laser": laser, "laser_start": laser_start, "laser_end": laser_end, "shoot_length": shoot_length, "strength": strength, "efficiency": efficiency, "laser_width": laser_width, "draw_rotation": draw_rotation, "base_rect_call": base_rect_call, "shadow_call": shadow_call, "region_rect_call": region_rect_call, "laser_guard": laser_guard, "angle_to_last": angle_to_last, "laser_start_x": laser_start_x, "laser_start_y": laser_start_y, "laser_width_value": laser_width_value, "draw_z_call": draw_z_call, "mixcol_call": mixcol_call, "laser_call": laser_call, "mixcol_reset_called": mixcol_reset_called}

func java_inner_class_TractorBeamBuild_method_write_4(_args: Array = []) -> Variant:
	var rotation: float = float(_args[0] if _args.size() > 0 else 0.0)
	var write_f_call: Dictionary = {"call": "write.f(rotation);", "value": rotation}
	return {"source_owner": "PortGame.source_tractor_beam_turret_build_write_state", "inner_class": "public class TractorBeamBuild extends BaseTurretBuild{", "method": "public void write(Writes write){", "override_expr": "@Override", "super_write_expr": "super.write(write);", "write_rotation_expr": "write.f(rotation);", "rotation": rotation, "super_write_called": true, "write_f_call": write_f_call}

func java_inner_class_TractorBeamBuild_method_read_5(_args: Array = []) -> Variant:
	var read_f_value: float = float(_args[0] if _args.size() > 0 else 0.0)
	var revision_value: int = int(_args[1] if _args.size() > 1 else 0)
	var super_read_call: Dictionary = {"call": "super.read(read, revision);", "revision": revision_value}
	var read_f_call: Dictionary = {"call": "read.f();", "value": read_f_value}
	var rotation_after: float = read_f_value
	return {"source_owner": "PortGame.source_tractor_beam_turret_build_read_state", "inner_class": "public class TractorBeamBuild extends BaseTurretBuild{", "method": "public void read(Reads read, byte revision){", "override_expr": "@Override", "super_read_expr": "super.read(read, revision);", "read_rotation_expr": "rotation = read.f();", "read_f_value": read_f_value, "revision_value": revision_value, "super_read_call": super_read_call, "read_f_call": read_f_call, "rotation_after": rotation_after}
