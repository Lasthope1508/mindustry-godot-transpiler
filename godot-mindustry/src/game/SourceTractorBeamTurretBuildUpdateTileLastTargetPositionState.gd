extends RefCounted
class_name SourceTractorBeamTurretBuildUpdateTileLastTargetPositionState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS

static func _tractor_beam_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func last_target_position_state(rotation_move_evaluated: bool, target_after: Variant, last_x_before: float, last_y_before: float) -> Dictionary:
	var last_target_position_evaluated: bool = rotation_move_evaluated
	var last_x_after: float = last_x_before
	var last_y_after: float = last_y_before
	if last_target_position_evaluated and target_after is Dictionary:
		last_x_after = float(target_after.get("x", last_x_before))
		last_y_after = float(target_after.get("y", last_y_before))
	var last_target_position_call: Dictionary = {}
	if last_target_position_evaluated:
		last_target_position_call = {"call": "lastX = target.x; lastY = target.y;", "target": target_after, "last_x": last_x_after, "last_y": last_y_after}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_LAST_TARGET_POSITION_STATE,
		"method": "public void updateTile(){",
		"last_x_expr": "lastX = target.x;",
		"last_y_expr": "lastY = target.y;",
		"rotation_move_evaluated": rotation_move_evaluated,
		"target_after": target_after,
		"last_x_before": last_x_before,
		"last_y_before": last_y_before,
		"last_target_position_evaluated": last_target_position_evaluated,
		"last_x_after": last_x_after,
		"last_y_after": last_y_after,
		"last_target_position_call": last_target_position_call,
	}


static func generated_last_target_position_bridge_state(activation_timer: float, time_delta: float, efficiency: float, coolant_multiplier: float, delta_value: float, timer_target_ready: bool, existing_target: Variant, closest_enemy_result: Variant, team: Variant, x: float, y: float, range_value: float, target_air: bool, target_ground: bool, coolant_present: bool, coolant_amount: float, current_liquid: Variant, liquid_amount: float, liquid_heat_capacity: float, chance_result: bool, size: float, source_tilesize: float, range_x: float, range_y: float, any_before: bool, target_within_result: bool, target_team: Variant, target_check_result: bool, target_hit_size: float, headless: bool, shoot_sound: Variant, shoot_sound_volume: float, rotation_before: float, rotate_speed: float, last_x_before: float, last_y_before: float) -> Dictionary:
	var result = _tractor_beam_turret_call("java_inner_class_TractorBeamBuild_method_updateTile_0", [activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before, target_within_result, target_team, target_check_result, target_hit_size, headless, shoot_sound, shoot_sound_volume, rotation_before, rotate_speed, last_x_before, last_y_before])
	var last_target_position_result := {
		"rotation_move_evaluated": result.get("rotation_move_evaluated", false),
		"target_after": result.get("target_after", null),
		"last_x_after": result.get("last_x_after", last_x_before),
		"last_y_after": result.get("last_y_after", last_y_before),
		"last_target_position_call": result.get("last_target_position_call", {}) if result.get("last_target_position_evaluated", false) else {},
	}
	var canonical = last_target_position_state(result.get("rotation_move_evaluated", false), result.get("target_after", null), last_x_before, last_y_before)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TRACTOR_BEAM_TURRET_BUILD_UPDATE_TILE_LAST_TARGET_POSITION_STATE,
		"generated_owner": "tractor_beam_turret.TractorBeamBuild.updateTile.last_target_position",
		"result": last_target_position_result,
		"canonical": canonical,
		"matches": last_target_position_result.get("last_x_after", null) == canonical.get("last_x_after", null) and last_target_position_result.get("last_y_after", null) == canonical.get("last_y_after", null),
	}
