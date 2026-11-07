extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const attribute_state := preload("res://src/game/SourceAttributeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var all_attributes := [{"id": 0, "name": "heat"}, {"id": 1, "name": "water"}]
	var attribute_map := {"heat": all_attributes[0], "water": all_attributes[1]}
	var env := game.source_attribute_env_state(false, 12.0)
	var text := game.source_attribute_to_string_state(all_attributes[0])
	var get_state := game.source_attribute_get_state(all_attributes, attribute_map, "heat")
	var get_or_null := game.source_attribute_get_or_null_state(all_attributes, attribute_map, "missing")
	var exists := game.source_attribute_exists_state(all_attributes, attribute_map, "water")
	var added := game.source_attribute_add_state(all_attributes, attribute_map, "steam")
	var proof := {
		"module": "ATTRIBUTE_MODULE_PROOF",
		"env": env,
		"to_string": text,
		"get": get_state,
		"get_or_null": get_or_null,
		"exists": exists,
		"add": added,
		"generated_add": attribute_state.generated_bridge("java_method_add_5", [all_attributes, attribute_map, "steam"], added),
		"matches": env.get("value", -1.0) == 0.0 and text.get("value", "") == "heat" and get_state.get("found", {}).get("name", "") == "heat" and get_or_null.get("value", null) == null and bool(exists.get("exists", false)) and added.get("attribute", {}).get("id", -1) == 2 and added.get("attribute", {}).get("name", "") == "steam",
	}
	proof["matches"] = proof["matches"] and bool(proof["generated_add"].get("matches", false))
	runtime_proof_state.write_proof("AttributeModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
