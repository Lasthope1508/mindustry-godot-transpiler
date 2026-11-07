extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const PortGameScript := preload("res://src/game/PortGame.gd")
const source_bullet_type_create_frags_state := preload("res://src/game/SourceBulletTypeCreateFragsState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var bullet_type_state := {"fragBullet": true, "fragBullets": 1, "fragOffsetMin": 1.0, "fragOffsetMax": 1.0, "fragRandomSpread": 0.0, "fragAngle": 0.0, "fragSpread": 0.0, "fragVelocityMin": 0.2, "fragVelocityMax": 0.2, "fragLifeMin": 1.0, "fragLifeMax": 1.0}
	var bullet_state := {"rotation": 0.0, "frags": 0, "absorbed": false}
	var create_frags_state := {}
	var frag_random_state := {"lenSamples": [1.0], "rangeSamples": [0.0], "velocitySamples": [0.2], "lifeSamples": [1.0]}
	var create_frags_initial_state := source_bullet_type_create_frags_state.initial_state(bullet_type_state, bullet_state, create_frags_state)
	var create_frags_random_geometry_state := source_bullet_type_create_frags_state.random_geometry_state(bullet_type_state, bullet_state, create_frags_initial_state, frag_random_state)
	var callbacks := source_bullet_type_create_frags_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_bullet_type_create_frags_state.SOURCE_BULLET_TYPE_CREATE_FRAGS_TRNS_VEC_KEY: Callable(game, source_bullet_type_create_frags_state.SOURCE_BULLET_TYPE_CREATE_FRAGS_TRNS_VEC_FALLBACK),
	}
	var override_callbacks := source_bullet_type_create_frags_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_bullet_type_create_frags_state.SOURCE_BULLET_TYPE_CREATE_FRAGS_TRNS_VEC_KEY, Callable()) == Callable(self, "proof_trns_vec")
	var wrapper := game.source_bullet_type_create_frags_create_call_state(bullet_type_state, bullet_state, create_frags_random_geometry_state, frag_random_state)
	var module := source_bullet_type_create_frags_state.game_create_call_state(game, bullet_type_state, bullet_state, create_frags_random_geometry_state, frag_random_state)
	var override_module := source_bullet_type_create_frags_state.game_create_call_state(self, bullet_type_state, bullet_state, create_frags_random_geometry_state, frag_random_state)
	var override_calls: Array = override_module.get("fragmentCreateCalls", [])
	var override_call: Dictionary = override_calls[0] if not override_calls.is_empty() else {}
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBulletTypeCreateFragsState",
		"game_create_call_matches": wrapper == module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"override_trns_vec_matches": is_equal_approx(float(override_call.get("trnsx", 0.0)), 12.0) and is_equal_approx(float(override_call.get("trnsy", 0.0)), 13.0),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["game_create_call_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["override_trns_vec_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BULLET_TYPE_CREATE_FRAGS_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BulletTypeCreateFragsStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func proof_trns_vec(_angle_degrees: float, _x_value: float, _y_value: float) -> Dictionary:
	return {"x": 12.0, "y": 13.0}

func _bullet_type_create_frags_method_names() -> Dictionary:
	return {
		source_bullet_type_create_frags_state.SOURCE_BULLET_TYPE_CREATE_FRAGS_TRNS_VEC_KEY: "proof_trns_vec",
	}

