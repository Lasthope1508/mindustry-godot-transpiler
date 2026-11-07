extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_query_darkness_state := preload("res://src/game/SourceBlockQueryDarknessState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var synthetic_bridge := game.generated_block_synthetic_bridge_state(false, true)
	var check_force_dark_bridge := game.generated_block_check_force_dark_bridge_state(true, "tile")
	var is_darkened_bridge := game.generated_block_is_darkened_bridge_state(true, false, false, true, false, "tile")
	var proof := {
		"module": "SourceBlockQueryDarknessState",
		"synthetic_bridge_matches": synthetic_bridge == source_block_query_darkness_state.generated_block_synthetic_bridge_state(false, true) and bool(synthetic_bridge.get("matches", false)),
		"check_force_dark_bridge_matches": check_force_dark_bridge == source_block_query_darkness_state.generated_block_check_force_dark_bridge_state(true, "tile") and bool(check_force_dark_bridge.get("matches", false)),
		"is_darkened_bridge_matches": is_darkened_bridge == source_block_query_darkness_state.generated_block_is_darkened_bridge_state(true, false, false, true, false, "tile") and bool(is_darkened_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["synthetic_bridge_matches"] and proof["check_force_dark_bridge_matches"] and proof["is_darkened_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockQueryDarknessModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

