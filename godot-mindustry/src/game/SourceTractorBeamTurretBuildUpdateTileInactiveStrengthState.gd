extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileInactiveStrengthState

const SourceMathDefaults := preload("res://src/game/SourceMathDefaults.gd")
const SourceTurretDefaults := preload("res://src/game/SourceTurretDefaults.gd")

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"lerp_delta": Callable(game, "source_mathf_lerp_delta"),
	}

static func inactive_strength_state(activation_returned_early: bool, look_target_guard: bool, strength_before: float, time_delta: float, lerp_delta: Callable) -> Dictionary:
	var inactive_strength_evaluated: bool = not activation_returned_early and not look_target_guard
	var inactive_strength_lerp_progress: float = SourceTurretDefaults.TRACTOR_BEAM_STRENGTH_LERP_PROGRESS
	var inactive_strength_lerp_scaled_progress: float = inactive_strength_lerp_progress * time_delta if inactive_strength_evaluated else 0.0
	var inactive_strength_lerp_clamped_progress: float = clampf(inactive_strength_lerp_scaled_progress, 0.0, 1.0)
	var inactive_strength_after: float = float(lerp_delta.call(strength_before, 0.0, inactive_strength_lerp_progress, time_delta)) if inactive_strength_evaluated else strength_before
	var inactive_strength_lerp_call: Dictionary = {}
	if inactive_strength_evaluated:
		inactive_strength_lerp_call = {"call": "strength = Mathf.lerpDelta(strength, 0, 0.1f);", "from": strength_before, "to": 0.0, "progress": inactive_strength_lerp_progress, "time_delta": time_delta, "result": inactive_strength_after}
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_update_tile_inactive_strength_state",
		"method": "public void updateTile(){",
		"look_target_guard_expr": "if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){",
		"else_expr": "}else{",
		"inactive_strength_lerp_expr": "strength = Mathf.lerpDelta(strength, 0, 0.1f);",
		"mathf_lerp_delta_method": SourceMathDefaults.LERP_DELTA_METHOD,
		"mathf_lerp_delta_clamp_expr": SourceMathDefaults.LERP_DELTA_CLAMP_EXPR,
		"mathf_lerp_delta_lerp_expr": SourceMathDefaults.LERP_DELTA_LERP_EXPR,
		"activation_returned_early": activation_returned_early,
		"look_target_guard": look_target_guard,
		"strength_before": strength_before,
		"time_delta": time_delta,
		"inactive_strength_evaluated": inactive_strength_evaluated,
		"inactive_strength_lerp_progress": inactive_strength_lerp_progress,
		"inactive_strength_lerp_scaled_progress": inactive_strength_lerp_scaled_progress,
		"inactive_strength_lerp_clamped_progress": inactive_strength_lerp_clamped_progress,
		"inactive_strength_after": inactive_strength_after,
		"inactive_strength_lerp_call": inactive_strength_lerp_call,
	}

static func generated_inactive_strength_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, lerp_delta: Callable) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd")
	var instance = script.new()
	var result = instance.java_inner_class_TractorBeamBuild_method_updateTile_0([activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before])
	var canonical = inactive_strength_state(result.get("activation_returned_early", false), result.get("look_target_guard", false), strength_before, time_delta, lerp_delta)
	var inactive_strength_result := {
		"activation_returned_early": result.get("activation_returned_early", false),
		"look_target_guard": result.get("look_target_guard", false),
		"strength_before": strength_before,
		"time_delta": time_delta,
		"inactive_strength_evaluated": result.get("inactive_strength_evaluated", false),
		"inactive_strength_lerp_progress": result.get("inactive_strength_lerp_progress", SourceTurretDefaults.TRACTOR_BEAM_STRENGTH_LERP_PROGRESS),
		"inactive_strength_lerp_scaled_progress": result.get("inactive_strength_lerp_scaled_progress", 0.0),
		"inactive_strength_lerp_clamped_progress": result.get("inactive_strength_lerp_clamped_progress", 0.0),
		"inactive_strength_after": result.get("inactive_strength_after", strength_before) if result.get("inactive_strength_evaluated", false) else strength_before,
		"inactive_strength_lerp_call": result.get("inactive_strength_lerp_call", {}) if result.get("inactive_strength_evaluated", false) else {},
	}
	return {
		"source_owner": "PortGame.source_tractor_beam_turret_build_update_tile_inactive_strength_state",
		"generated_owner": "TractorBeamTurret.TractorBeamBuild.updateTile.inactive_strength",
		"result": inactive_strength_result,
		"canonical": canonical,
		"matches": inactive_strength_result.get("inactive_strength_after", null) == canonical.get("inactive_strength_after", null)
			and inactive_strength_result.get("inactive_strength_lerp_call", null) == canonical.get("inactive_strength_lerp_call", null)
			and inactive_strength_result.get("inactive_strength_lerp_clamped_progress", null) == canonical.get("inactive_strength_lerp_clamped_progress", null),
	}
