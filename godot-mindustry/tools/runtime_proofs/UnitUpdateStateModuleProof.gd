extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_unit_update_state := preload("res://src/game/SourceUnitUpdateState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_unit_update_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_unit_update_state.SOURCE_UNIT_UPDATE_SIN_SCALED_KEY: Callable(game, source_unit_update_state.SOURCE_UNIT_UPDATE_SIN_SCALED_FALLBACK),
		source_unit_update_state.SOURCE_UNIT_UPDATE_COS_SCALED_KEY: Callable(game, source_unit_update_state.SOURCE_UNIT_UPDATE_COS_SCALED_FALLBACK),
		source_unit_update_state.SOURCE_UNIT_UPDATE_VEC2_LIMIT_KEY: Callable(game, source_unit_update_state.SOURCE_UNIT_UPDATE_VEC2_LIMIT_FALLBACK),
		source_unit_update_state.SOURCE_UNIT_UPDATE_VEC2_ANGLE_KEY: Callable(game, source_unit_update_state.SOURCE_UNIT_UPDATE_VEC2_ANGLE_FALLBACK),
		source_unit_update_state.SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY: Callable(game, source_unit_update_state.SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_FALLBACK),
		source_unit_update_state.SOURCE_UNIT_UPDATE_ANGLES_ANGLE_KEY: Callable(game, source_unit_update_state.SOURCE_UNIT_UPDATE_ANGLES_ANGLE_FALLBACK),
	}
	var override_callbacks := source_unit_update_state.default_callbacks_state(self)
	var override_sin_fn: Callable = override_callbacks.get(source_unit_update_state.SOURCE_UNIT_UPDATE_SIN_SCALED_KEY, Callable())
	var override_sin_value := float(override_sin_fn.call(1.0, 2.0, 3.0)) if override_sin_fn.is_valid() else 0.0
	var override_callbacks_match := override_sin_fn == Callable(self, "_proof_sin_scaled") and override_sin_value == 6.0
	var wobble_wrapper := game.source_unit_wobble_state(12.0, 24.0, 30.0, 0.5, 0.75, 17)
	var wobble_module_bridge := source_unit_update_state.game_wobble_state(game, 12.0, 24.0, 30.0, 0.5, 0.75, 17)
	var wobble_module := source_unit_update_state.wobble_state(12.0, 24.0, 30.0, 0.5, 0.75, 17, callbacks.get(source_unit_update_state.SOURCE_UNIT_UPDATE_SIN_SCALED_KEY, Callable()), callbacks.get(source_unit_update_state.SOURCE_UNIT_UPDATE_COS_SCALED_KEY, Callable()))
	var move_at_wrapper := game.source_unit_move_at_state(1.0, 2.0, 4.0, 8.0, 0.6, 0.5)
	var move_at_module_bridge := source_unit_update_state.game_move_at_state(game, 1.0, 2.0, 4.0, 8.0, 0.6, 0.5)
	var move_at_module := source_unit_update_state.move_at_state(1.0, 2.0, 4.0, 8.0, 0.6, 0.5, callbacks.get(source_unit_update_state.SOURCE_UNIT_UPDATE_VEC2_LIMIT_KEY, Callable()))
	var rotate_motion_wrapper := game.source_unit_rotate_move_motion_state(20.0, 3.0, 4.0)
	var rotate_motion_module_bridge := source_unit_update_state.game_rotate_move_motion_state(game, 20.0, 3.0, 4.0)
	var rotate_motion_module := source_unit_update_state.rotate_move_motion_state(20.0, 3.0, 4.0)
	var rotate_wrapper := game.source_unit_rotate_move_rotation_state(20.0, 3.0, 4.0, 5.0, 1.25, 0.5)
	var rotate_module_bridge := source_unit_update_state.game_rotate_move_rotation_state(game, 20.0, 3.0, 4.0, 5.0, 1.25, 0.5)
	var rotate_module := source_unit_update_state.rotate_move_rotation_state(20.0, 3.0, 4.0, 5.0, 1.25, 0.5, callbacks.get(source_unit_update_state.SOURCE_UNIT_UPDATE_VEC2_ANGLE_KEY, Callable()), callbacks.get(source_unit_update_state.SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY, Callable()))
	var look_angle_wrapper := game.source_unit_look_at_angle_state(20.0, 90.0, 5.0, 1.25, 0.5)
	var look_angle_module_bridge := source_unit_update_state.game_look_at_angle_state(game, 20.0, 90.0, 5.0, 1.25, 0.5)
	var look_angle_module := source_unit_update_state.look_at_angle_state(20.0, 90.0, 5.0, 1.25, 0.5, callbacks.get(source_unit_update_state.SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY, Callable()))
	var look_position_wrapper := game.source_unit_look_at_position_state(20.0, 1.0, 2.0, 4.0, 8.0, 5.0, 1.25, 0.5)
	var look_position_module_bridge := source_unit_update_state.game_look_at_position_state(game, 20.0, 1.0, 2.0, 4.0, 8.0, 5.0, 1.25, 0.5)
	var look_position_module := source_unit_update_state.look_at_position_state(20.0, 1.0, 2.0, 4.0, 8.0, 5.0, 1.25, 0.5, callbacks.get(source_unit_update_state.SOURCE_UNIT_UPDATE_ANGLES_ANGLE_KEY, Callable()), callbacks.get(source_unit_update_state.SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY, Callable()))
	var look_xy_wrapper := game.source_unit_look_at_xy_state(20.0, 1.0, 2.0, 4.0, 8.0, 5.0, 1.25, 0.5)
	var look_xy_module_bridge := source_unit_update_state.game_look_at_xy_state(game, 20.0, 1.0, 2.0, 4.0, 8.0, 5.0, 1.25, 0.5)
	var look_xy_module := source_unit_update_state.look_at_xy_state(20.0, 1.0, 2.0, 4.0, 8.0, 5.0, 1.25, 0.5, callbacks.get(source_unit_update_state.SOURCE_UNIT_UPDATE_ANGLES_ANGLE_KEY, Callable()), callbacks.get(source_unit_update_state.SOURCE_UNIT_UPDATE_ANGLES_MOVE_TOWARD_KEY, Callable()))
	var trail_wrapper := game.source_unit_update_trail_position_state(true, 6, true, 0.5, 8.0, 4.0, 5.0, 35.0)
	var trail_module := source_unit_update_state.trail_position_state(true, 6, true, 0.5, 8.0, 4.0, 5.0, 35.0)
	var falling_engine_wrapper := game.source_unit_update_falling_engine_trail_state(true, 0.0, true, 4.0, 5.0, 35.0, 0.5, 8.0, 3.0, 1.0, 0.25, 0.5, 0.75)
	var falling_engine_module := source_unit_update_state.falling_engine_trail_state(true, 0.0, true, 4.0, 5.0, 35.0, 0.5, 8.0, 3.0, 1.0, 0.25, 0.5, 0.75)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceUnitUpdateState",
		"wobble_matches": wobble_wrapper == wobble_module,
		"wobble_bridge_matches": wobble_wrapper == wobble_module_bridge,
		"move_at_matches": move_at_wrapper == move_at_module,
		"move_at_bridge_matches": move_at_wrapper == move_at_module_bridge,
		"rotate_motion_matches": rotate_motion_wrapper == rotate_motion_module,
		"rotate_motion_bridge_matches": rotate_motion_wrapper == rotate_motion_module_bridge,
		"rotate_matches": rotate_wrapper == rotate_module,
		"rotate_bridge_matches": rotate_wrapper == rotate_module_bridge,
		"look_angle_matches": look_angle_wrapper == look_angle_module,
		"look_angle_bridge_matches": look_angle_wrapper == look_angle_module_bridge,
		"look_position_matches": look_position_wrapper == look_position_module,
		"look_position_bridge_matches": look_position_wrapper == look_position_module_bridge,
		"look_xy_matches": look_xy_wrapper == look_xy_module,
		"look_xy_bridge_matches": look_xy_wrapper == look_xy_module_bridge,
		"trail_position_matches": trail_wrapper == trail_module,
		"falling_engine_trail_matches": falling_engine_wrapper == falling_engine_module,
		"half_circle_matches": source_unit_defaults.FALL_ENGINE_ROTATION_OFFSET == source_math_defaults.HALF_CIRCLE_DEGREES and float(falling_engine_module.get("angle", 0.0)) == 35.0 + source_math_defaults.HALF_CIRCLE_DEGREES,
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"player_controllable_matches": game.source_unit_player_controllable_state(true, true, true, true) == source_unit_update_state.player_controllable_state(true, true, true, true),
		"targetable_matches": game.source_unit_targetable_state(true, true, true, true, 3) == source_unit_update_state.targetable_state(true, true, true, true, 3),
		"killable_matches": game.source_unit_killable_state(true) == source_unit_update_state.killable_state(true),
		"hittable_matches": game.source_unit_hittable_state(true, true, true, true) == source_unit_update_state.hittable_state(true, true, true, true),
		"after_sync_matches": game.source_unit_after_sync_state(4, true) == source_unit_update_state.after_sync_state(4, true),
		"after_read_matches": game.source_unit_after_read_state(5, true, false, true) == source_unit_update_state.after_read_state(5, true, false, true),
		"after_read_all_matches": game.source_unit_after_read_all_state(true) == source_unit_update_state.after_read_all_state(true),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["wobble_matches"] and proof["wobble_bridge_matches"] and proof["move_at_matches"] and proof["move_at_bridge_matches"] and proof["rotate_motion_matches"] and proof["rotate_motion_bridge_matches"] and proof["rotate_matches"] and proof["rotate_bridge_matches"] and proof["look_angle_matches"] and proof["look_angle_bridge_matches"] and proof["look_position_matches"] and proof["look_position_bridge_matches"] and proof["look_xy_matches"] and proof["look_xy_bridge_matches"] and proof["trail_position_matches"] and proof["falling_engine_trail_matches"] and proof["half_circle_matches"] and proof["player_controllable_matches"] and proof["targetable_matches"] and proof["killable_matches"] and proof["hittable_matches"] and proof["after_sync_matches"] and proof["after_read_matches"] and proof["after_read_all_matches"]
	print("UNIT_UPDATE_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func _unit_update_method_names() -> Dictionary:
	return {
		source_unit_update_state.SOURCE_UNIT_UPDATE_SIN_SCALED_KEY: "_proof_sin_scaled",
	}

func _proof_sin_scaled(radians: float, scl: float, mag: float) -> float:
	return radians + scl + mag
