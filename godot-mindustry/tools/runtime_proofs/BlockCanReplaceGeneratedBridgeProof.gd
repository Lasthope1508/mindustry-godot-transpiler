extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_core_state := preload("res://src/game/SourceBuildingCoreState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var bridge := game.generated_block_can_replace_bridge_state(false, false, true, false, true, false, false, true, 3, 2, true, false)
	var proof := {
		"module": "SourceBuildingCoreState",
		"can_replace_bridge_matches": bridge == source_building_core_state.generated_block_can_replace_bridge_state(false, false, true, false, true, false, false, true, 3, 2, true, false) and bool(bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["can_replace_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockCanReplaceGeneratedBridgeProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
