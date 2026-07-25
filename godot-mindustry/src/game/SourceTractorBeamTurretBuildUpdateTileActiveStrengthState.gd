extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileActiveStrengthState

const SourceMathDefaults := preload("res://src/game/SourceMathDefaults.gd")
const SourceTurretDefaults := preload("res://src/game/SourceTurretDefaults.gd")

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"lerp_delta": Callable(game, "source_mathf_lerp_delta"),
	}

static func active_strength_state(last_target_position_evaluated: bool, strength_before: float, time_delta: float, lerp_delta: Callable) -> Dictionary:
	var strength_lerp_evaluated: bool = last_target_position_evaluated
	var strength_lerp_progress: float = SourceTurretDefaults.TRACTOR_BEAM_STRENGTH_LERP_PROGRESS
	var strength_lerp_scaled_progress: float = strength_lerp_progress * time_delta if strength_lerp_evaluated else 0.0
	var strength_lerp_clamped_progress: float = clampf(strength_lerp_scaled_progress, 0.0, 1.0)
	var strength_after: float = float(lerp_delta.call(strength_before, 1.0, strength_lerp_progress, time_delta)) if strength_lerp_evaluated else strength_before
	var strength_lerp_call: Dictionary = {}
	if strength_lerp_evaluated:
		strength_lerp_call = {"call": "strength = Mathf.lerpDelta(strength, 1f, 0.1f);", "from": strength_before, "to": 1.0, "progress": strength_lerp_progress, "time_delta": time_delta, "result": strength_after}
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_update_tile_active_strength_state",
		"method": "public void updateTile(){",
		"last_y_expr": "lastY = target.y;",
		"strength_lerp_expr": "strength = Mathf.lerpDelta(strength, 1f, 0.1f);",
		"shoot_when_possible_next_expr": "if(Angles.within(rotation, dest, shootCone)){",
		"mathf_lerp_delta_method": SourceMathDefaults.LERP_DELTA_METHOD,
		"mathf_lerp_delta_clamp_expr": SourceMathDefaults.LERP_DELTA_CLAMP_EXPR,
		"mathf_lerp_delta_lerp_expr": SourceMathDefaults.LERP_DELTA_LERP_EXPR,
		"last_target_position_evaluated": last_target_position_evaluated,
		"strength_before": strength_before,
		"time_delta": time_delta,
		"strength_lerp_evaluated": strength_lerp_evaluated,
		"strength_lerp_progress": strength_lerp_progress,
		"strength_lerp_scaled_progress": strength_lerp_scaled_progress,
		"strength_lerp_clamped_progress": strength_lerp_clamped_progress,
		"strength_after": strength_after,
		"strength_lerp_call": strength_lerp_call,
	}

static func generated_active_strength_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, lerp_delta: Callable) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd")
	var instance = script.new()
	var result = instance.java_inner_class_TractorBeamBuild_method_updateTile_0([activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before])
	var canonical = active_strength_state(result.get("last_target_position_evaluated", false), strength_before, time_delta, lerp_delta)
	var active_strength_result := {
		"last_target_position_evaluated": result.get("last_target_position_evaluated", false),
		"strength_before": strength_before,
		"time_delta": time_delta,
		"strength_lerp_evaluated": result.get("strength_lerp_evaluated", false),
		"strength_lerp_progress": result.get("strength_lerp_progress", SourceTurretDefaults.TRACTOR_BEAM_STRENGTH_LERP_PROGRESS),
		"strength_lerp_scaled_progress": result.get("strength_lerp_scaled_progress", 0.0),
		"strength_lerp_clamped_progress": result.get("strength_lerp_clamped_progress", 0.0),
		"strength_after": result.get("strength_after", strength_before) if result.get("strength_lerp_evaluated", false) else strength_before,
		"strength_lerp_call": result.get("strength_lerp_call", {}),
	}
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_update_tile_active_strength_state",
		"generated_owner": "TractorBeamTurret.TractorBeamBuild.updateTile.active_strength",
		"result": active_strength_result,
		"canonical": canonical,
		"matches": active_strength_result.get("strength_after", null) == canonical.get("strength_after", null)
			and active_strength_result.get("strength_lerp_call", null) == canonical.get("strength_lerp_call", null)
			and active_strength_result.get("strength_lerp_clamped_progress", null) == canonical.get("strength_lerp_clamped_progress", null),
	}
