extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceUnitUpdateState := preload("res://src/game/SourceUnitUpdateState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceUnitUpdateState.default_callbacks_state(game)
	var expected_callbacks := {
		"sin_scaled": Callable(game, "source_arc_mathf_sin_scaled"),
		"cos_scaled": Callable(game, "source_arc_mathf_cos_scaled"),
		"vec2_limit": Callable(game, "source_arc_vec2_limit"),
		"vec2_angle": Callable(game, "source_unit_vec2_angle"),
		"angles_move_toward": Callable(game, "source_arc_angles_move_toward"),
		"angles_angle": Callable(game, "source_arc_angles_angle"),
	}
	var wobble_wrapper := game.source_unit_wobble_state(12.0, 24.0, 30.0, 0.5, 0.75, 17)
	var wobble_module := SourceUnitUpdateState.wobble_state(12.0, 24.0, 30.0, 0.5, 0.75, 17, callbacks.get("sin_scaled", Callable()), callbacks.get("cos_scaled", Callable()))
	var move_at_wrapper := game.source_unit_move_at_state(1.0, 2.0, 4.0, 8.0, 0.6, 0.5)
	var move_at_module := SourceUnitUpdateState.move_at_state(1.0, 2.0, 4.0, 8.0, 0.6, 0.5, callbacks.get("vec2_limit", Callable()))
	var rotate_wrapper := game.source_unit_rotate_move_rotation_state(20.0, 3.0, 4.0, 5.0, 1.25, 0.5)
	var rotate_module := SourceUnitUpdateState.rotate_move_rotation_state(20.0, 3.0, 4.0, 5.0, 1.25, 0.5, callbacks.get("vec2_angle", Callable()), callbacks.get("angles_move_toward", Callable()))
	var look_angle_wrapper := game.source_unit_look_at_angle_state(20.0, 90.0, 5.0, 1.25, 0.5)
	var look_angle_module := SourceUnitUpdateState.look_at_angle_state(20.0, 90.0, 5.0, 1.25, 0.5, callbacks.get("angles_move_toward", Callable()))
	var look_position_wrapper := game.source_unit_look_at_position_state(20.0, 1.0, 2.0, 4.0, 8.0, 5.0, 1.25, 0.5)
	var look_position_module := SourceUnitUpdateState.look_at_position_state(20.0, 1.0, 2.0, 4.0, 8.0, 5.0, 1.25, 0.5, callbacks.get("angles_angle", Callable()), callbacks.get("angles_move_toward", Callable()))
	var look_xy_wrapper := game.source_unit_look_at_xy_state(20.0, 1.0, 2.0, 4.0, 8.0, 5.0, 1.25, 0.5)
	var look_xy_module := SourceUnitUpdateState.look_at_xy_state(20.0, 1.0, 2.0, 4.0, 8.0, 5.0, 1.25, 0.5, callbacks.get("angles_angle", Callable()), callbacks.get("angles_move_toward", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceUnitUpdateState",
		"wobble_matches": wobble_wrapper == wobble_module,
		"move_at_matches": move_at_wrapper == move_at_module,
		"rotate_matches": rotate_wrapper == rotate_module,
		"look_angle_matches": look_angle_wrapper == look_angle_module,
		"look_position_matches": look_position_wrapper == look_position_module,
		"look_xy_matches": look_xy_wrapper == look_xy_module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"player_controllable_matches": game.source_unit_player_controllable_state(true, true, true, true) == SourceUnitUpdateState.player_controllable_state(true, true, true, true),
		"targetable_matches": game.source_unit_targetable_state(true, true, true, true, 3) == SourceUnitUpdateState.targetable_state(true, true, true, true, 3),
		"killable_matches": game.source_unit_killable_state(true) == SourceUnitUpdateState.killable_state(true),
		"hittable_matches": game.source_unit_hittable_state(true, true, true, true) == SourceUnitUpdateState.hittable_state(true, true, true, true),
		"after_sync_matches": game.source_unit_after_sync_state(4, true) == SourceUnitUpdateState.after_sync_state(4, true),
		"after_read_matches": game.source_unit_after_read_state(5, true, false, true) == SourceUnitUpdateState.after_read_state(5, true, false, true),
		"after_read_all_matches": game.source_unit_after_read_all_state(true) == SourceUnitUpdateState.after_read_all_state(true),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["wobble_matches"] and proof["move_at_matches"] and proof["rotate_matches"] and proof["look_angle_matches"] and proof["look_position_matches"] and proof["look_xy_matches"] and proof["player_controllable_matches"] and proof["targetable_matches"] and proof["killable_matches"] and proof["hittable_matches"] and proof["after_sync_matches"] and proof["after_read_matches"] and proof["after_read_all_matches"]
	print("UNIT_UPDATE_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
