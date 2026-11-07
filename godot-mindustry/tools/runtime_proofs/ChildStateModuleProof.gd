extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const PortGameScript := preload("res://src/game/PortGame.gd")
const source_child_state := preload("res://src/game/SourceChildState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var child_state := {
		"x": 12.0,
		"y": 18.0,
		"rotation": 45.0,
		"offsetX": 2.0,
		"offsetY": 4.0,
		"offsetPos": 6.0,
		"offsetRot": 8.0,
		"parent_exists": true,
		"parent_get_x": 10.0,
		"parent_get_y": 20.0,
		"rot_with_parent": true,
		"parent_is_rotc": true,
		"parent_rotc_rotation": 30.0,
		"parent_is_rotblock": false,
		"parent_rotblock_build_rotation": 60.0,
	}
	var callbacks := source_child_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_child_state.SOURCE_CHILD_TRNS_VEC_KEY: Callable(game, source_child_state.SOURCE_CHILD_TRNS_VEC_FALLBACK),
	}
	var override_callbacks := source_child_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_child_state.SOURCE_CHILD_TRNS_VEC_KEY, Callable()) == Callable(self, "proof_trns_vec")
	var add_wrapper := game.generated_child_comp_add_bridge_state(child_state)
	var add_module := source_child_state.generated_child_add_bridge_state(child_state)
	var update_wrapper := game.generated_child_comp_update_bridge_state(child_state)
	var update_module := source_child_state.generated_child_update_bridge_state(child_state)
	var add_state := source_child_state.add_state(child_state)
	var update_state := source_child_state.game_update_state(game, child_state)
	var override_update_state := source_child_state.game_update_state(self, child_state)
	var generated_update_state := source_child_state.game_generated_child_update_bridge_state(game, child_state)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceChildState",
		"add_matches": add_wrapper == add_module,
		"update_matches": update_wrapper == update_module,
		"generated_update_matches": generated_update_state == update_module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"override_trns_vec_matches": is_equal_approx(float(override_update_state.get("x", 0.0)), 22.0) and is_equal_approx(float(override_update_state.get("y", 0.0)), 33.0),
		"add_state_matches": add_module.get("canonical", {}) == add_state,
		"update_state_matches": update_module.get("canonical", {}) == update_state,
		"module_matches": add_wrapper == add_module and update_wrapper == update_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["add_matches"] and proof["update_matches"] and proof["add_state_matches"] and proof["update_state_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["override_trns_vec_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CHILD_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ChildStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func proof_trns_vec(_angle_degrees: float, _x_value: float, _y_value: float) -> Dictionary:
	return {"x": 12.0, "y": 13.0}

func _child_method_names() -> Dictionary:
	return {
		source_child_state.SOURCE_CHILD_TRNS_VEC_KEY: "proof_trns_vec",
	}

