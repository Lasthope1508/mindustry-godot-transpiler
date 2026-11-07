extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const attributes_state := preload("res://src/game/SourceAttributesState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var attribute_all := [{"id": 0, "name": "heat"}, {"id": 1, "name": "water"}, {"id": 2, "name": "sand"}]
	var arr := [1.5, 0.0]
	var other := [2.0, 3.0, 4.0]
	var clear_state := game.source_attributes_clear_state(attribute_all, arr)
	var get_state := game.source_attributes_get_state(attribute_all, arr, 0)
	var set_state := game.source_attributes_set_state(attribute_all, arr, 1, 2.25)
	var add_state := game.source_attributes_add_state(attribute_all, arr, other)
	var scaled_state := game.source_attributes_add_scaled_state(attribute_all, arr, other, 0.5)
	var write_state := game.source_attributes_write_state(attribute_all, [1.5, 0.0, 2.0])
	var read_state := game.source_attributes_read_state(attribute_all, arr, {"heat": 7.0})
	var check_state := game.source_attributes_check_state(attribute_all, arr)
	var string_state := game.source_attributes_to_string_state(attribute_all, [1.5, 0.0, 2.0])
	var generated_string := game.generated_attributes_to_string_bridge_state(attribute_all, [1.5, 0.0, 2.0])
	var generated_read := game.generated_attributes_read_bridge_state(attribute_all, arr, {"heat": 7.0})
	var proof := {
		"module": "ATTRIBUTES_MODULE_PROOF",
		"clear": clear_state,
		"get": get_state,
		"set": set_state,
		"add": add_state,
		"add_scaled": scaled_state,
		"write": write_state,
		"read": read_state,
		"check": check_state,
		"to_string": string_state,
		"generated_to_string": generated_string,
		"generated_read": generated_read,
		"matches": clear_state.get("arr", []) == [0.0, 0.0, 0.0] and get_state.get("value", -1.0) == 1.5 and set_state.get("arr", []).size() == 3 and add_state.get("arr", []) == [3.5, 3.0, 4.0] and scaled_state.get("arr", []) == [2.5, 1.5, 2.0] and write_state.get("data", {}) == {"heat": 1.5, "sand": 2.0} and read_state.get("arr", []) == [7.0, 0.0, 0.0] and check_state.get("arr", []).size() == 3 and string_state.get("text", "") == "Attributes{heat: 1.5, sand: 2.0}",
		"module_direct_matches": attributes_state.to_string_state(attribute_all, [1.5, 0.0, 2.0]).get("text", "") == "Attributes{heat: 1.5, sand: 2.0}",
	}
	proof["matches"] = proof["matches"] and bool(generated_string.get("matches", false)) and bool(generated_read.get("matches", false))
	runtime_proof_state.write_proof("AttributesModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
