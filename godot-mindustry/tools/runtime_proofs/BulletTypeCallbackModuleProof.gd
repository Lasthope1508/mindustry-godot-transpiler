extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBulletTypeCreateState := preload("res://src/game/SourceBulletTypeCreateState.gd")
const SourceBulletTypeUpdateState := preload("res://src/game/SourceBulletTypeUpdateState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var create_callbacks := SourceBulletTypeCreateState.default_callbacks_state(game)
	var expected_create_callbacks := {
		"trns_vec": Callable(game, "source_arc_angles_trns_vec"),
	}
	var update_callbacks := SourceBulletTypeUpdateState.default_callbacks_state(game)
	var expected_update_callbacks := {
		"angles_angle": Callable(game, "source_arc_angles_angle"),
		"move_toward_angle": Callable(game, "source_arc_angles_move_toward"),
		"trns_vec": Callable(game, "source_arc_angles_trns_vec"),
		"vec2_limit": Callable(game, "source_vec2_limit"),
		"bullet_rotation_degrees": Callable(game, "source_bullet_rotation_degrees"),
	}
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
	var velocity_module := SourceBulletTypeCreateState.velocity_vector_state(velocity_state, create_callbacks.get("trns_vec", Callable()))
	var keep_velocity_wrapper := game.source_bullet_type_create_keep_velocity_state(trail_add_state, bullet_type_create_state, owner_state)
	var keep_velocity_module := SourceBulletTypeCreateState.keep_velocity_state(trail_add_state, bullet_type_create_state, owner_state, create_callbacks.get("trns_vec", Callable()))
	var homing_wrapper := game.source_bullet_type_update_homing_target_velocity_state(homing_initial_state, target_state, 0.25)
	var homing_module := SourceBulletTypeUpdateState.update_homing_target_velocity_state(homing_initial_state, target_state, 0.25, update_callbacks.get("angles_angle", Callable()), update_callbacks.get("move_toward_angle", Callable()), update_callbacks.get("trns_vec", Callable()))
	var weaving_wrapper := game.source_bullet_type_update_weaving_state(bullet_update_state, bullet_type_update_state, 1, 0.25)
	var weaving_module := SourceBulletTypeUpdateState.update_weaving_state(bullet_update_state, bullet_type_update_state, 1, 0.25, update_callbacks.get("angles_angle", Callable()))
	var trail_chance_wrapper := game.source_bullet_type_update_trail_effects_chance_state(bullet_update_state, bullet_type_update_state, true, random_offset_state)
	var trail_chance_module := SourceBulletTypeUpdateState.update_trail_effects_chance_state(bullet_update_state, bullet_type_update_state, true, random_offset_state, update_callbacks.get("bullet_rotation_degrees", Callable()))
	var trail_interval_wrapper := game.source_bullet_type_update_trail_effects_interval_state(trail_chance_wrapper, bullet_type_update_state, true, random_offset_state)
	var trail_interval_module := SourceBulletTypeUpdateState.update_trail_effects_interval_state(trail_chance_module, bullet_type_update_state, true, random_offset_state, update_callbacks.get("bullet_rotation_degrees", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBulletTypeCreateState+SourceBulletTypeUpdateState",
		"velocity_matches": velocity_wrapper == velocity_module,
		"keep_velocity_matches": keep_velocity_wrapper == keep_velocity_module,
		"homing_matches": homing_wrapper == homing_module,
		"weaving_matches": weaving_wrapper == weaving_module,
		"trail_chance_matches": trail_chance_wrapper == trail_chance_module,
		"trail_interval_matches": trail_interval_wrapper == trail_interval_module,
		"create_default_callbacks_match": create_callbacks == expected_create_callbacks,
		"update_default_callbacks_match": update_callbacks == expected_update_callbacks,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["velocity_matches"] and proof["keep_velocity_matches"] and proof["homing_matches"] and proof["weaving_matches"] and proof["trail_chance_matches"] and proof["trail_interval_matches"]
	print("BULLET_TYPE_CALLBACK_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
