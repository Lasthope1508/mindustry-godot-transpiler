extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceChildState := preload("res://src/game/SourceChildState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

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
	var callbacks := SourceChildState.default_callbacks_state(game)
	var expected_callbacks := {
		"trns_vec": Callable(game, "source_arc_angles_trns_vec"),
	}
	var add_wrapper := game.generated_child_comp_add_bridge_state(child_state)
	var add_module := SourceChildState.generated_child_add_bridge_state(child_state)
	var update_wrapper := game.generated_child_comp_update_bridge_state(child_state)
	var update_module := SourceChildState.generated_child_update_bridge_state(child_state)
	var add_state := SourceChildState.add_state(child_state)
	var update_state := SourceChildState.update_state(child_state, callbacks.get("trns_vec", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceChildState",
		"add_matches": add_wrapper == add_module,
		"update_matches": update_wrapper == update_module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"add_state_matches": add_module.get("canonical", {}) == add_state,
		"update_state_matches": update_module.get("canonical", {}) == update_state,
		"module_matches": add_wrapper == add_module and update_wrapper == update_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["add_matches"] and proof["update_matches"] and proof["add_state_matches"] and proof["update_state_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("CHILD_STATE_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/ChildStateModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
