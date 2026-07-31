extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_query_placement_state := preload("res://src/game/SourceBlockQueryPlacementState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var can_place_on_bridge := game.generated_block_can_place_on_bridge_state("tile", "sharded", 1)
	var can_break_bridge := game.generated_block_can_break_bridge_state("tile")
	var rotated_output_bridge := game.generated_block_rotated_output_bridge_state(true, 2, 3)
	var rotated_output_tile_bridge := game.generated_block_rotated_output_tile_bridge_state(true, 4, 5, "destination")
	var proof := {
		"module": "SourceBlockQueryPlacementState",
		"can_place_on_bridge_matches": can_place_on_bridge == source_block_query_placement_state.generated_block_can_place_on_bridge_state("tile", "sharded", 1) and bool(can_place_on_bridge.get("matches", false)),
		"can_break_bridge_matches": can_break_bridge == source_block_query_placement_state.generated_block_can_break_bridge_state("tile") and bool(can_break_bridge.get("matches", false)),
		"rotated_output_bridge_matches": rotated_output_bridge == source_block_query_placement_state.generated_block_rotated_output_bridge_state(true, 2, 3) and bool(rotated_output_bridge.get("matches", false)),
		"rotated_output_tile_bridge_matches": rotated_output_tile_bridge == source_block_query_placement_state.generated_block_rotated_output_tile_bridge_state(true, 4, 5, "destination") and bool(rotated_output_tile_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["can_place_on_bridge_matches"] and proof["can_break_bridge_matches"] and proof["rotated_output_bridge_matches"] and proof["rotated_output_tile_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_QUERY_PLACEMENT_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockQueryPlacementModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
