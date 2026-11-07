extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_tether_state := preload("res://src/game/SourceBuildingTetherState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var update_bridge := game.generated_building_tether_comp_update_bridge_state(true, false, "blue", "blue", 42)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_TETHER_STATE_MODULE_PROOF",
		"update_bridge": update_bridge,
		"update_bridge_matches": update_bridge == source_building_tether_state.generated_building_tether_update_bridge_state(true, false, "blue", "blue", 42),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["update_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_TETHER_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingTetherStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

