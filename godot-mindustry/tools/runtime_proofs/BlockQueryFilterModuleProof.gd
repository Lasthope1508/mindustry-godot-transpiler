extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_query_filter_state := preload("res://src/game/SourceBlockQueryFilterState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var consumes_item_bridge := game.generated_block_consumes_item_bridge_state([false, true], 1, "copper")
	var consumes_liquid_bridge := game.generated_block_consumes_liquid_bridge_state([true, false], 0, "water")
	var proof := {
		"module": "SourceBlockQueryFilterState",
		"consumes_item_bridge_matches": consumes_item_bridge == source_block_query_filter_state.generated_block_consumes_item_bridge_state([false, true], 1, "copper") and bool(consumes_item_bridge.get("matches", false)),
		"consumes_liquid_bridge_matches": consumes_liquid_bridge == source_block_query_filter_state.generated_block_consumes_liquid_bridge_state([true, false], 0, "water") and bool(consumes_liquid_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["consumes_item_bridge_matches"] and proof["consumes_liquid_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_QUERY_FILTER_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockQueryFilterModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
