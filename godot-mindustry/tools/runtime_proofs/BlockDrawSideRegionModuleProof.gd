extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_draw_state := preload("res://src/game/SourceBlockDrawState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var wrapper := game.generated_block_draw_side_region_bridge_state(16.0, 1.0, 100.0, 200.0, 3.0, 8.0, 5)
	var module := source_block_draw_state.generated_block_draw_side_region_bridge_state(16.0, 1.0, 100.0, 200.0, 3.0, 8.0, 5)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_DRAW_SIDE_REGION_MODULE_PROOF",
		"wrapper_matches_module": wrapper == module,
		"generated_subset_matches": bool(wrapper.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["wrapper_matches_module"] and proof["generated_subset_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockDrawSideRegionModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
