extends Node

const generated_script := preload("res://src/generated/classes/mindustry/input/InputHandler.gd")
const source_input_handler_state := preload("res://src/game/SourceInputHandlerState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _without_generated_markers(result: Dictionary) -> Dictionary:
	var canonical := result.duplicate(true)
	canonical.erase("generated_owner")
	canonical.erase("generated_method")
	return canonical


func _ready() -> void:
	var generated := generated_script.new()
	var mouse_x: Dictionary = generated.java_method_getMouseX_50([321.5])
	var mouse_y: Dictionary = generated.java_method_getMouseY_51([123.25])
	var camera_position: Dictionary = generated.java_method_panCamera_121([Vector2(80.0, 40.0), false, Vector2.ZERO])
	var locked_camera_position: Dictionary = generated.java_method_panCamera_121([Vector2(80.0, 40.0), true, Vector2(12.0, 8.0)])
	var selected_block: Dictionary = generated.java_method_selectedBlock_122([true])
	var placing: Dictionary = generated.java_method_isPlacing_123([false])
	var breaking: Dictionary = generated.java_method_isBreaking_124([])
	var angle: Dictionary = generated.java_method_mouseAngle_126([0.0, 0.0, Vector2(0.0, 1.0)])
	var expected_mouse_x := source_input_handler_state.get_mouse_x_state(321.5)
	var expected_mouse_y := source_input_handler_state.get_mouse_y_state(123.25)
	var expected_camera := source_input_handler_state.pan_camera_state(Vector2(80.0, 40.0), false, Vector2.ZERO)
	var expected_locked_camera := source_input_handler_state.pan_camera_state(Vector2(80.0, 40.0), true, Vector2(12.0, 8.0))
	var expected_selected_block := source_input_handler_state.selected_block_state(true)
	var expected_placing := source_input_handler_state.is_placing_state(false)
	var expected_breaking := source_input_handler_state.is_breaking_state()
	var expected_angle := source_input_handler_state.mouse_angle_state(0.0, 0.0, Vector2(0.0, 1.0))
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "INPUT_HANDLER_QUERY_MODULE_PROOF",
		"mouse_x_matches": _without_generated_markers(mouse_x) == expected_mouse_x,
		"mouse_y_matches": _without_generated_markers(mouse_y) == expected_mouse_y,
		"camera_matches": _without_generated_markers(camera_position) == expected_camera,
		"locked_camera_matches": _without_generated_markers(locked_camera_position) == expected_locked_camera,
		"selected_block_matches": _without_generated_markers(selected_block) == expected_selected_block,
		"placing_matches": _without_generated_markers(placing) == expected_placing,
		"breaking_matches": _without_generated_markers(breaking) == expected_breaking,
		"angle_matches": _without_generated_markers(angle) == expected_angle,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["mouse_x_matches"] and proof["mouse_y_matches"] and proof["camera_matches"] and proof["locked_camera_matches"] and proof["selected_block_matches"] and proof["placing_matches"] and proof["breaking_matches"] and proof["angle_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("InputHandlerQueryModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
