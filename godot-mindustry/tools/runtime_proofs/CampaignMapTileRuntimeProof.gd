extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_world_initial_build_runtime_state := preload("res://src/game/SourceWorldInitialBuildRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.select_campaign_sector("biomassFacility")
	game.enter_campaign_playable_slice()
	var tile_state := game.source_campaign_map_tile_state()
	var initial_build := game.source_world_initial_build_runtime_state()
	var initial_build_tile_state: Dictionary = initial_build.get(source_world_initial_build_runtime_state.KEY_CAMPAIGN_MAP_TILE, {})
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceCampaignMapTileState",
		"tile_state": tile_state,
		"dimensions_match": int(tile_state.get("width", 0)) == 250 and int(tile_state.get("height", 0)) == 250,
		"floor_runs_match": int(tile_state.get("floor_run_count", 0)) == 6002,
		"unique_floors_match": int(tile_state.get("unique_floor_id_count", 0)) == 12,
		"unique_blocks_match": int(tile_state.get("unique_block_id_count", 0)) == 20,
		"entity_tiles_match": int(tile_state.get("entity_tile_count", 0)) == 132,
		"top_floor_name_matches": int(tile_state.get("floor_name_counts", {}).get("moss", 0)) == 33940,
		"top_block_name_matches": int(tile_state.get("block_name_counts", {}).get("spore-wall", 0)) == 27841,
		"core_block_name_matches": int(tile_state.get("block_name_counts", {}).get("core-shard", 0)) == 9,
		"map_region_consumed": bool(tile_state.get("map_region_consumed", false)),
		"initial_build_carries_tile_state": initial_build_tile_state == tile_state,
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["dimensions_match"] and proof["floor_runs_match"] and proof["unique_floors_match"] and proof["unique_blocks_match"] and proof["entity_tiles_match"] and proof["top_floor_name_matches"] and proof["top_block_name_matches"] and proof["core_block_name_matches"] and proof["map_region_consumed"] and proof["initial_build_carries_tile_state"] and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("CAMPAIGN_MAP_TILE_RUNTIME_PROOF " + JSON.stringify(proof))
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/CampaignMapTileRuntimeProof.json")
	var file := FileAccess.open(proof_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(proof))
		file.flush()
		file.close()
	game.free()
	await get_tree().process_frame
	get_tree().quit(0 if proof["matches"] else 1)

