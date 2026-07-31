extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileActiveStrengthState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := "res://src/generated/classes/mindustry/world/blocks/defense/turrets/TractorBeamTurret.gd"
const SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY := "lerp_delta"
const SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_FALLBACK := "source_mathf_lerp_delta"

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_tractor_beam_active_strength_method_names"):
		var names = game.call("_tractor_beam_active_strength_method_names")
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

static func active_strength_state(last_target_position_evaluated: bool, strength_before: float, time_delta: float, lerp_delta: Callable) -> Dictionary:
	var strength_lerp_evaluated: bool = last_target_position_evaluated
	var strength_lerp_progress: float = source_turret_defaults.TRACTOR_BEAM_STRENGTH_LERP_PROGRESS
	var strength_lerp_scaled_progress: float = strength_lerp_progress * time_delta if strength_lerp_evaluated else 0.0
	var strength_lerp_clamped_progress: float = clampf(strength_lerp_scaled_progress, 0.0, 1.0)
	var strength_after: float = float(lerp_delta.call(strength_before, 1.0, strength_lerp_progress, time_delta)) if strength_lerp_evaluated else strength_before
	var strength_lerp_call: Dictionary = {}
	if strength_lerp_evaluated:
		strength_lerp_call = {"call": "strength = Mathf.lerpDelta(strength, 1f, 0.1f);", "from": strength_before, "to": 1.0, "progress": strength_lerp_progress, "time_delta": time_delta, "result": strength_after}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_ACTIVE_STRENGTH_STATE,
		"method": "public void updateTile(){",
		"last_y_expr": "lastY = target.y;",
		"strength_lerp_expr": "strength = Mathf.lerpDelta(strength, 1f, 0.1f);",
		"shoot_when_possible_next_expr": "if(Angles.within(rotation, dest, shootCone)){",
		"mathf_lerp_delta_method": source_math_defaults.LERP_DELTA_METHOD,
		"mathf_lerp_delta_clamp_expr": source_math_defaults.LERP_DELTA_CLAMP_EXPR,
		"mathf_lerp_delta_lerp_expr": source_math_defaults.LERP_DELTA_LERP_EXPR,
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

static func game_active_strength_state(game: Object, last_target_position_evaluated: bool, strength_before: float, time_delta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return active_strength_state(last_target_position_evaluated, strength_before, time_delta, callbacks.get(SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY, Callable()))

static func generated_active_strength_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float, lerp_delta: Callable) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before])
	var canonical = active_strength_state(result.get("last_target_position_evaluated", false), strength_before, time_delta, lerp_delta)
	var active_strength_result := {
		"last_target_position_evaluated": result.get("last_target_position_evaluated", false),
		"strength_before": strength_before,
		"time_delta": time_delta,
		"strength_lerp_evaluated": result.get("strength_lerp_evaluated", false),
		"strength_lerp_progress": result.get("strength_lerp_progress", source_turret_defaults.TRACTOR_BEAM_STRENGTH_LERP_PROGRESS),
		"strength_lerp_scaled_progress": result.get("strength_lerp_scaled_progress", 0.0),
		"strength_lerp_clamped_progress": result.get("strength_lerp_clamped_progress", 0.0),
		"strength_after": result.get("strength_after", strength_before) if result.get("strength_lerp_evaluated", false) else strength_before,
		"strength_lerp_call": result.get("strength_lerp_call", {}),
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_ACTIVE_STRENGTH_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.active_strength",
		"result": active_strength_result,
		"canonical": canonical,
		"matches": active_strength_result.get("strength_after", null) == canonical.get("strength_after", null)
			and active_strength_result.get("strength_lerp_call", null) == canonical.get("strength_lerp_call", null)
			and active_strength_result.get("strength_lerp_clamped_progress", null) == canonical.get("strength_lerp_clamped_progress", null),
	}

static func game_generated_active_strength_bridge_state(game: Object, activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float, strength_before: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return generated_active_strength_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before, strength_before, callbacks.get(SOURCE_TRACTOR_BEAM_STRENGTH_LERP_DELTA_KEY, Callable()))
