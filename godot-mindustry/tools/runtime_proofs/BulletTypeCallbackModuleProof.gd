extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_bullet_type_create_state := preload("res://src/game/SourceBulletTypeCreateState.gd")
const source_bullet_type_update_state := preload("res://src/game/SourceBulletTypeUpdateState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var create_callbacks := source_bullet_type_create_state.default_callbacks_state(game)
	var expected_create_callbacks := {
		source_bullet_type_create_state.SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_KEY: Callable(game, source_bullet_type_create_state.SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_FALLBACK),
	}
	var update_callbacks := source_bullet_type_update_state.default_callbacks_state(game)
	var expected_update_callbacks := {
		source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY: Callable(game, source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_FALLBACK),
		source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_MOVE_TOWARD_ANGLE_KEY: Callable(game, source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_MOVE_TOWARD_ANGLE_FALLBACK),
		source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_TRNS_VEC_KEY: Callable(game, source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_TRNS_VEC_FALLBACK),
		source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_VEC2_LIMIT_KEY: Callable(game, source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_VEC2_LIMIT_FALLBACK),
		source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_KEY: Callable(game, source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_FALLBACK),
	}
	var create_override_callbacks := source_bullet_type_create_state.default_callbacks_state(self)
	var create_override_trns_fn: Callable = create_override_callbacks.get(source_bullet_type_create_state.SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_KEY, Callable())
	var create_override_trns_value: Dictionary = create_override_trns_fn.call(10.0, 2.0, 3.0) if create_override_trns_fn.is_valid() else {}
	var create_override_callbacks_match := create_override_trns_fn == Callable(self, "_proof_trns_vec") and create_override_trns_value == {"x": 12.0, "y": 13.0}
	var update_override_callbacks := source_bullet_type_update_state.default_callbacks_state(self)
	var update_override_angle_fn: Callable = update_override_callbacks.get(source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY, Callable())
	var update_override_angle_value := float(update_override_angle_fn.call(1.0, 2.0, 3.0, 4.0)) if update_override_angle_fn.is_valid() else 0.0
	var update_override_callbacks_match := update_override_angle_fn == Callable(self, "_proof_angles_angle") and update_override_angle_value == 42.5
	var velocity_state := {
		"angle": 30.0,
		"speed": 5.0,
	}
	var trail_add_state := {
		"bulletContinues": true,
		"bulletTrailAddApplied": true,
		"bullet": {
			"velocity": {"angle": 20.0, "speed": 4.0},
			"lifetime": 10.0,
		},
	}
	var bullet_type_create_state := {
		"keepVelocity": true,
		"scaleKeepVelocity": true,
	}
	var owner_state := {
		"isVelc": true,
		"vel": {"x": 1.0, "y": 2.0},
	}
	var homing_initial_state := {
		"gatePassed": true,
		"homingPower": 0.05,
		"bullet": {
			"x": 0.0,
			"y": 0.0,
			"rotation": 0.0,
			"velocity": {"x": 3.0, "y": 0.0, "angle": 0.0, "speed": 3.0},
		},
	}
	var target_state := {
		"x": 10.0,
		"y": 10.0,
	}
	var bullet_update_state := {
		"id": 7,
		"x": 2.0,
		"y": 3.0,
		"time": 6.0,
		"rotation": 15.0,
		"velocity": {"x": 3.0, "y": 1.0, "angle": 18.434948822922, "speed": 3.162277660168},
	}
	var bullet_type_update_state := {
		"weaveMag": 2.0,
		"weaveScale": 4.0,
		"weaveRandom": true,
		"rotateSpeed": 8.0,
		"trailMinVelocity": 0.0,
		"trailChance": 1.0,
		"trailInterval": 1.0,
		"trailSpread": 2.0,
		"trailRotation": true,
		"trailColor": "white",
		"trailEffect": "trail",
	}
	var random_offset_state := {
		"x": 0.25,
		"y": -0.5,
	}
	var velocity_wrapper := game.source_bullet_velocity_vector_state(velocity_state)
	var velocity_module_bridge := source_bullet_type_create_state.game_velocity_vector_state(game, velocity_state)
	var velocity_module := source_bullet_type_create_state.velocity_vector_state(velocity_state, create_callbacks.get(source_bullet_type_create_state.SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_KEY, Callable()))
	var keep_velocity_wrapper := game.source_bullet_type_create_keep_velocity_state(trail_add_state, bullet_type_create_state, owner_state)
	var keep_velocity_module_bridge := source_bullet_type_create_state.game_keep_velocity_state(game, trail_add_state, bullet_type_create_state, owner_state)
	var keep_velocity_module := source_bullet_type_create_state.keep_velocity_state(trail_add_state, bullet_type_create_state, owner_state, create_callbacks.get(source_bullet_type_create_state.SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_KEY, Callable()))
	var homing_wrapper := game.source_bullet_type_update_homing_target_velocity_state(homing_initial_state, target_state, 0.25)
	var homing_module_bridge := source_bullet_type_update_state.game_update_homing_target_velocity_state(game, homing_initial_state, target_state, 0.25)
	var homing_module := source_bullet_type_update_state.update_homing_target_velocity_state(homing_initial_state, target_state, 0.25, update_callbacks.get(source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY, Callable()), update_callbacks.get(source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_MOVE_TOWARD_ANGLE_KEY, Callable()), update_callbacks.get(source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_TRNS_VEC_KEY, Callable()))
	var weaving_wrapper := game.source_bullet_type_update_weaving_state(bullet_update_state, bullet_type_update_state, 1, 0.25)
	var weaving_module_bridge := source_bullet_type_update_state.game_update_weaving_state(game, bullet_update_state, bullet_type_update_state, 1, 0.25)
	var weaving_module := source_bullet_type_update_state.update_weaving_state(bullet_update_state, bullet_type_update_state, 1, 0.25, update_callbacks.get(source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY, Callable()))
	var trail_chance_wrapper := game.source_bullet_type_update_trail_effects_chance_state(bullet_update_state, bullet_type_update_state, true, random_offset_state)
	var trail_chance_module_bridge := source_bullet_type_update_state.game_update_trail_effects_chance_state(game, bullet_update_state, bullet_type_update_state, true, random_offset_state)
	var trail_chance_module := source_bullet_type_update_state.update_trail_effects_chance_state(bullet_update_state, bullet_type_update_state, true, random_offset_state, update_callbacks.get(source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_KEY, Callable()))
	var trail_interval_wrapper := game.source_bullet_type_update_trail_effects_interval_state(trail_chance_wrapper, bullet_type_update_state, true, random_offset_state)
	var trail_interval_module_bridge := source_bullet_type_update_state.game_update_trail_effects_interval_state(game, trail_chance_wrapper, bullet_type_update_state, true, random_offset_state)
	var trail_interval_module := source_bullet_type_update_state.update_trail_effects_interval_state(trail_chance_module, bullet_type_update_state, true, random_offset_state, update_callbacks.get(source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_BULLET_ROTATION_DEGREES_KEY, Callable()))
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "source_bullet_type_create_state+source_bullet_type_update_state",
		"velocity_matches": velocity_wrapper == velocity_module,
		"velocity_bridge_matches": velocity_wrapper == velocity_module_bridge,
		"keep_velocity_matches": keep_velocity_wrapper == keep_velocity_module,
		"keep_velocity_bridge_matches": keep_velocity_wrapper == keep_velocity_module_bridge,
		"homing_matches": homing_wrapper == homing_module,
		"homing_bridge_matches": homing_wrapper == homing_module_bridge,
		"weaving_matches": weaving_wrapper == weaving_module,
		"weaving_bridge_matches": weaving_wrapper == weaving_module_bridge,
		"trail_chance_matches": trail_chance_wrapper == trail_chance_module,
		"trail_chance_bridge_matches": trail_chance_wrapper == trail_chance_module_bridge,
		"trail_interval_matches": trail_interval_wrapper == trail_interval_module,
		"trail_interval_bridge_matches": trail_interval_wrapper == trail_interval_module_bridge,
		"create_default_callbacks_match": create_callbacks == expected_create_callbacks,
		"update_default_callbacks_match": update_callbacks == expected_update_callbacks,
		"create_override_callbacks_match": create_override_callbacks_match,
		"update_override_callbacks_match": update_override_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["velocity_matches"] and proof["velocity_bridge_matches"] and proof["keep_velocity_matches"] and proof["keep_velocity_bridge_matches"] and proof["homing_matches"] and proof["homing_bridge_matches"] and proof["weaving_matches"] and proof["weaving_bridge_matches"] and proof["trail_chance_matches"] and proof["trail_chance_bridge_matches"] and proof["trail_interval_matches"] and proof["trail_interval_bridge_matches"]
	print("BULLET_TYPE_CALLBACK_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func _bullet_type_create_method_names() -> Dictionary:
	return {
		source_bullet_type_create_state.SOURCE_BULLET_TYPE_CREATE_TRNS_VEC_KEY: "_proof_trns_vec",
	}

func _bullet_type_update_method_names() -> Dictionary:
	return {
		source_bullet_type_update_state.SOURCE_BULLET_TYPE_UPDATE_ANGLES_ANGLE_KEY: "_proof_angles_angle",
	}

func _proof_trns_vec(angle: float, x_value: float, y_value: float) -> Dictionary:
	return {"x": x_value + angle, "y": y_value + angle}

func _proof_angles_angle(from_x: float, from_y: float, to_x: float, to_y: float) -> float:
	return 42.5 + (from_x + from_y + to_x + to_y) * 0.0
