extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_query_basic_state := preload("res://src/game/SourceBlockQueryBasicState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var has_building_bridge := game.generated_block_has_building_bridge_state(true, false)
	var is_multiblock_bridge := game.generated_block_is_multiblock_bridge_state(3)
	var is_air_bridge := game.generated_block_is_air_bridge_state(0)
	var can_be_built_bridge := game.generated_block_can_be_built_bridge_state("shown")
	var is_static_bridge := game.generated_block_is_static_bridge_state("walls")
	var proof := {
		"module": "SourceBlockQueryBasicState",
		"has_building_bridge_matches": has_building_bridge == source_block_query_basic_state.generated_block_has_building_bridge_state(true, false) and bool(has_building_bridge.get("matches", false)),
		"is_multiblock_bridge_matches": is_multiblock_bridge == source_block_query_basic_state.generated_block_is_multiblock_bridge_state(3) and bool(is_multiblock_bridge.get("matches", false)),
		"is_air_bridge_matches": is_air_bridge == source_block_query_basic_state.generated_block_is_air_bridge_state(0) and bool(is_air_bridge.get("matches", false)),
		"can_be_built_bridge_matches": can_be_built_bridge == source_block_query_basic_state.generated_block_can_be_built_bridge_state("shown") and bool(can_be_built_bridge.get("matches", false)),
		"is_static_bridge_matches": is_static_bridge == source_block_query_basic_state.generated_block_is_static_bridge_state("walls") and bool(is_static_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["has_building_bridge_matches"] and proof["is_multiblock_bridge_matches"] and proof["is_air_bridge_matches"] and proof["can_be_built_bridge_matches"] and proof["is_static_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_QUERY_BASIC_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockQueryBasicModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
