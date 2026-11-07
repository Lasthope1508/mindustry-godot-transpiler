extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var content_type_bridge := game.generated_block_get_content_type_bridge_state()
	var logic_visible_bridge := game.generated_block_logic_visible_bridge_state("shown")
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_METADATA_MODULE_PROOF",
		"content_type_bridge": content_type_bridge,
		"logic_visible_bridge": logic_visible_bridge,
		"content_type_bridge_matches": content_type_bridge == source_block_metadata_state.generated_content_type_bridge_state(),
		"logic_visible_bridge_matches": logic_visible_bridge == source_block_metadata_state.generated_logic_visible_bridge_state("shown"),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(content_type_bridge.get("matches", false)) and bool(logic_visible_bridge.get("matches", false)) and proof["content_type_bridge_matches"] and proof["logic_visible_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BLOCK_METADATA_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BlockMetadataModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

