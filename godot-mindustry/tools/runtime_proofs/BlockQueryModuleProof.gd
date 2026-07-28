extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBlockQueryState := preload("res://src/game/SourceBlockQueryState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var outputs_items_bridge := game.generated_block_outputs_items_bridge_state(true)
	var is_darkened_bridge := game.generated_block_is_darkened_bridge_state(true, false, false, true, false, "tile")
	var remove_consumers_bridge := game.generated_block_remove_consumers_bridge_state(false, "remove-filter")
	var proof := {
		"module": "SourceBlockQueryState",
		"outputs_items_bridge_matches": outputs_items_bridge == SourceBlockQueryState.generated_block_outputs_items_bridge_state(true) and bool(outputs_items_bridge.get("matches", false)),
		"is_darkened_bridge_matches": is_darkened_bridge == SourceBlockQueryState.generated_block_is_darkened_bridge_state(true, false, false, true, false, "tile") and bool(is_darkened_bridge.get("matches", false)),
		"remove_consumers_bridge_matches": remove_consumers_bridge == SourceBlockQueryState.generated_block_remove_consumers_bridge_state(false, "remove-filter") and bool(remove_consumers_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["outputs_items_bridge_matches"] and proof["is_darkened_bridge_matches"] and proof["remove_consumers_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_QUERY_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockQueryModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
