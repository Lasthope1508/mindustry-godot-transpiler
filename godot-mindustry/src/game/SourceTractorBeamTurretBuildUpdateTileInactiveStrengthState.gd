extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileInactiveStrengthState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_tractor_beam_callback_registry := preload("res://src/game/SourceTractorBeamCallbackRegistry.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS
const SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY := source_tractor_beam_callback_registry.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY
const SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_FALLBACK := source_tractor_beam_callback_registry.SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_FALLBACK

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_tractor_beam_inactive_strength_method_names"):
		var names = game.call("_tractor_beam_inactive_strength_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY, SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_FALLBACK)),
	}

static func inactive_strength_state(activation_returned_early: bool, look_target_guard: bool, strength_before: float, time_delta: float, lerp_delta: Callable) -> Dictionary:
	var inactive_strength_evaluated: bool = not activation_returned_early and not look_target_guard
	var inactive_strength_lerp_progress: float = source_turret_defaults.TRACTOR_BEAM_STRENGTH_LERP_PROGRESS
	var inactive_strength_lerp_scaled_progress: float = inactive_strength_lerp_progress * time_delta if inactive_strength_evaluated else 0.0
	var inactive_strength_lerp_clamped_progress: float = clampf(inactive_strength_lerp_scaled_progress, 0.0, 1.0)
	var inactive_strength_after: float = float(lerp_delta.call(strength_before, 0.0, inactive_strength_lerp_progress, time_delta)) if inactive_strength_evaluated else strength_before
	var inactive_strength_lerp_call: Dictionary = {}
	if inactive_strength_evaluated:
		inactive_strength_lerp_call = {"call": "strength = Mathf.lerpDelta(strength, 0, 0.1f);", "from": strength_before, "to": 0.0, "progress": inactive_strength_lerp_progress, "time_delta": time_delta, "result": inactive_strength_after}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_INACTIVE_STRENGTH_STATE,
		"method": "public void updateTile(){",
		"look_target_guard_expr": "if(target != null && target.within(this, range + target.hitSize/2f) && target.team() != team && target.checkTarget(targetAir, targetGround) && efficiency > 0.02f){",
		"else_expr": "}else{",
		"inactive_strength_lerp_expr": "strength = Mathf.lerpDelta(strength, 0, 0.1f);",
		"mathf_lerp_delta_method": source_math_defaults.LERP_DELTA_METHOD,
		"mathf_lerp_delta_clamp_expr": source_math_defaults.LERP_DELTA_CLAMP_EXPR,
		"mathf_lerp_delta_lerp_expr": source_math_defaults.LERP_DELTA_LERP_EXPR,
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

static func game_inactive_strength_state(game: Object, activation_returned_early: bool, look_target_guard: bool, strength_before: float, time_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return inactive_strength_state(activation_returned_early, look_target_guard, strength_before, time_delta, callbacks.get(SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY, Callable()))

static func generated_inactive_strength_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, lerp_delta: Callable) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before])
	var canonical = inactive_strength_state(result.get("activation_returned_early", false), result.get("look_target_guard", false), strength_before, time_delta, lerp_delta)
	var inactive_strength_result := {
		"activation_returned_early": result.get("activation_returned_early", false),
		"look_target_guard": result.get("look_target_guard", false),
		"strength_before": strength_before,
		"time_delta": time_delta,
		"inactive_strength_evaluated": result.get("inactive_strength_evaluated", false),
		"inactive_strength_lerp_progress": result.get("inactive_strength_lerp_progress", source_turret_defaults.TRACTOR_BEAM_STRENGTH_LERP_PROGRESS),
		"inactive_strength_lerp_scaled_progress": result.get("inactive_strength_lerp_scaled_progress", 0.0),
		"inactive_strength_lerp_clamped_progress": result.get("inactive_strength_lerp_clamped_progress", 0.0),
		"inactive_strength_after": result.get("inactive_strength_after", strength_before) if result.get("inactive_strength_evaluated", false) else strength_before,
		"inactive_strength_lerp_call": result.get("inactive_strength_lerp_call", {}) if result.get("inactive_strength_evaluated", false) else {},
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_INACTIVE_STRENGTH_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.inactive_strength",
		"result": inactive_strength_result,
		"canonical": canonical,
		"matches": inactive_strength_result.get("inactive_strength_after", null) == canonical.get("inactive_strength_after", null)
			and inactive_strength_result.get("inactive_strength_lerp_call", null) == canonical.get("inactive_strength_lerp_call", null)
			and inactive_strength_result.get("inactive_strength_lerp_clamped_progress", null) == canonical.get("inactive_strength_lerp_clamped_progress", null),
	}

static func game_generated_inactive_strength_bridge_state(game: Object, activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return generated_inactive_strength_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, callbacks.get(SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY, Callable()))
