extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_query_consumer_state := preload("res://src/game/SourceBlockQueryConsumerState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var has_consumer_bridge := game.generated_block_has_consumer_bridge_state(true, "coal")
	var remove_consumer_bridge := game.generated_block_remove_consumer_bridge_state(2, "coal")
	var remove_consumers_bridge := game.generated_block_remove_consumers_bridge_state(false, "coal")
	var proof := {
		"module": "SourceBlockQueryConsumerState",
		"has_consumer_bridge_matches": has_consumer_bridge == source_block_query_consumer_state.generated_block_has_consumer_bridge_state(true, "coal") and bool(has_consumer_bridge.get("matches", false)),
		"remove_consumer_bridge_matches": remove_consumer_bridge == source_block_query_consumer_state.generated_block_remove_consumer_bridge_state(2, "coal") and bool(remove_consumer_bridge.get("matches", false)),
		"remove_consumers_bridge_matches": remove_consumers_bridge == source_block_query_consumer_state.generated_block_remove_consumers_bridge_state(false, "coal") and bool(remove_consumers_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["has_consumer_bridge_matches"] and proof["remove_consumer_bridge_matches"] and proof["remove_consumers_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_QUERY_CONSUMER_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockQueryConsumerModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
