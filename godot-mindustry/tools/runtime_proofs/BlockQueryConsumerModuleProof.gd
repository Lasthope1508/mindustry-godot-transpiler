extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_query_consumer_state := preload("res://src/game/SourceBlockQueryConsumerState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var has_consumer_bridge := game.generated_block_has_consumer_bridge_state(true, "coal")
	var find_consumer_bridge := game.generated_block_find_consumer_bridge_state(0, "builder-consumer", "array-consumer", "filter")
	var remove_consumer_bridge := game.generated_block_remove_consumer_bridge_state(2, "coal")
	var remove_consumers_bridge := game.generated_block_remove_consumers_bridge_state(false, "coal")
	var proof := {
		"module": "SourceBlockQueryConsumerState",
		"has_consumer_bridge_matches": has_consumer_bridge == source_block_query_consumer_state.generated_block_has_consumer_bridge_state(true, "coal") and bool(has_consumer_bridge.get("matches", false)),
		"find_consumer_bridge_matches": find_consumer_bridge == source_block_query_consumer_state.generated_block_find_consumer_bridge_state(0, "builder-consumer", "array-consumer", "filter") and bool(find_consumer_bridge.get("matches", false)),
		"remove_consumer_bridge_matches": remove_consumer_bridge == source_block_query_consumer_state.generated_block_remove_consumer_bridge_state(2, "coal") and bool(remove_consumer_bridge.get("matches", false)),
		"remove_consumers_bridge_matches": remove_consumers_bridge == source_block_query_consumer_state.generated_block_remove_consumers_bridge_state(false, "coal") and bool(remove_consumers_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["has_consumer_bridge_matches"] and proof["find_consumer_bridge_matches"] and proof["remove_consumer_bridge_matches"] and proof["remove_consumers_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockQueryConsumerModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

