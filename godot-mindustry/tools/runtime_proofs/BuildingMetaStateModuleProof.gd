extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_meta_state := preload("res://src/game/SourceBuildingMetaState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var cursor_state := source_building_meta_state.cursor_state(true, true)
	var cursor_bridge := game.generated_building_comp_get_cursor_bridge_state(true, true)
	var health_changed_state := source_building_meta_state.health_changed_state(true, {"health": 10})
	var to_string_state := source_building_meta_state.to_string_state(5, 7, 9, "block")
	var to_string_bridge := game.generated_building_comp_to_string_bridge_state(5, 7, 9, "block")
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_META_STATE_MODULE_PROOF",
		"cursor_state": cursor_state,
		"cursor_bridge": cursor_bridge,
		"cursor_bridge_matches": cursor_bridge == source_building_meta_state.generated_cursor_bridge_state(true, true),
		"health_changed_state": health_changed_state,
		"to_string_state": to_string_state,
		"to_string_bridge": to_string_bridge,
		"to_string_bridge_matches": to_string_bridge == source_building_meta_state.generated_to_string_bridge_state(5, 7, 9, "block"),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["cursor_bridge_matches"] and proof["to_string_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_META_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingMetaStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

