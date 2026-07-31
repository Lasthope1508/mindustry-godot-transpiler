extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_init_placement_state := preload("res://src/game/SourceBlockInitPlacementState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var accepts_items_bridge := game.generated_block_init_accepts_items_bridge_state("BlockGroup.transportation", "Category.distribution", false)
	var offset_bridge := game.generated_block_init_offset_bridge_state(2, 8.0)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_INIT_PLACEMENT_MODULE_PROOF",
		"accepts_items_bridge": accepts_items_bridge,
		"offset_bridge": offset_bridge,
		"accepts_items_bridge_matches": accepts_items_bridge == source_block_init_placement_state.generated_accepts_items_bridge_state("BlockGroup.transportation", "Category.distribution", false),
		"offset_bridge_matches": offset_bridge == source_block_init_placement_state.generated_offset_bridge_state(2, 8.0),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(accepts_items_bridge.get("matches", false)) and bool(offset_bridge.get("matches", false)) and proof["accepts_items_bridge_matches"] and proof["offset_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_INIT_PLACEMENT_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockInitPlacementModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
