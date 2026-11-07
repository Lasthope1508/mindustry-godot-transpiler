extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileRotationMoveState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_tractor_beam_callback_registry := preload("res://src/game/SourceTractorBeamCallbackRegistry.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS
const SOURCE_TRACTOR_BEAM_ROTATION_MOVE_TOWARD_ANGLE_KEY := source_tractor_beam_callback_registry.SOURCE_TRACTOR_BEAM_ROTATION_MOVE_TOWARD_ANGLE_KEY
const SOURCE_TRACTOR_BEAM_ROTATION_MOVE_TOWARD_ANGLE_FALLBACK := source_tractor_beam_callback_registry.SOURCE_TRACTOR_BEAM_ROTATION_MOVE_TOWARD_ANGLE_FALLBACK

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_tractor_beam_rotation_method_names"):
		var names = game.call("_tractor_beam_rotation_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_TRACTOR_BEAM_ROTATION_MOVE_TOWARD_ANGLE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_TRACTOR_BEAM_ROTATION_MOVE_TOWARD_ANGLE_KEY, SOURCE_TRACTOR_BEAM_ROTATION_MOVE_TOWARD_ANGLE_FALLBACK)),
	}

static func rotation_move_state(angle_to_target_evaluated: bool, rotation_before: float, dest: float, rotate_speed: float, edelta: float, move_toward_angle: Callable) -> Dictionary:
	var rotation_move_evaluated: bool = angle_to_target_evaluated
	var rotation_max_delta: float = rotate_speed * edelta if rotation_move_evaluated else 0.0
	var rotation_after: float = float(move_toward_angle.call(rotation_before, dest, rotation_max_delta)) if rotation_move_evaluated else rotation_before
	var rotation_move_call: Dictionary = {}
	if rotation_move_evaluated:
		rotation_move_call = {"call": "Angles.moveToward(rotation, dest, rotateSpeed * edelta)", "rotation": rotation_before, "dest": dest, "speed": rotation_max_delta, "result": rotation_after}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_ROTATION_MOVE_STATE,
		"method": "public void updateTile(){",
		"dest_expr": "float dest = angleTo(target);",
		"rotation_move_expr": "rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta);",
		"angle_to_target_evaluated": angle_to_target_evaluated,
		"rotation_before": rotation_before,
		"dest": dest,
		"rotate_speed": rotate_speed,
		"edelta": edelta,
		"rotation_move_evaluated": rotation_move_evaluated,
		"rotation_max_delta": rotation_max_delta,
		"rotation_after": rotation_after,
		"rotation_move_call": rotation_move_call,
	}

static func game_rotation_move_state(game: Object, angle_to_target_evaluated: bool, rotation_before: float, dest: float, rotate_speed: float, edelta: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return rotation_move_state(angle_to_target_evaluated, rotation_before, dest, rotate_speed, edelta, callbacks.get(SOURCE_TRACTOR_BEAM_ROTATION_MOVE_TOWARD_ANGLE_KEY, Callable()))

static func generated_rotation_move_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, move_toward_angle: Callable) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed])
	var canonical = rotation_move_state(result.get("angle_to_target_evaluated", false), rotation_before, result.get("dest", 0.0), rotate_speed, result.get("edelta", 0.0), move_toward_angle)
	var rotation_move_result := {
		"angle_to_target_evaluated": result.get("angle_to_target_evaluated", false),
		"rotation_before": rotation_before,
		"dest": result.get("dest", 0.0),
		"rotate_speed": rotate_speed,
		"edelta": result.get("edelta", 0.0),
		"rotation_move_evaluated": result.get("rotation_move_evaluated", false),
		"rotation_max_delta": result.get("rotation_max_delta", 0.0),
		"rotation_after": result.get("rotation_after", rotation_before),
		"rotation_move_call": result.get("rotation_move_call", {}),
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_ROTATION_MOVE_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.rotation_move",
		"result": rotation_move_result,
		"canonical": canonical,
		"matches": rotation_move_result.get("rotation_after", null) == canonical.get("rotation_after", null)
			and rotation_move_result.get("rotation_move_call", null) == canonical.get("rotation_move_call", null)
			and rotation_move_result.get("rotation_max_delta", null) == canonical.get("rotation_max_delta", null),
	}

static func game_generated_rotation_move_bridge_state(game: Object, activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return generated_rotation_move_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, callbacks.get(SOURCE_TRACTOR_BEAM_ROTATION_MOVE_TOWARD_ANGLE_KEY, Callable()))
