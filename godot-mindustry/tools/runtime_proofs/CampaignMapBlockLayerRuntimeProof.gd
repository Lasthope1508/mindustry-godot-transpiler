extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_world_initial_build_runtime_state := preload("res://src/game/SourceWorldInitialBuildRuntimeState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_config()
	game.load_content_registry()
	game.load_textures()
	var world := Node2D.new()
	world.name = "World"
	game.add_child(world)
	var block_layer := Node2D.new()
	block_layer.name = "BlockLayer"
	world.add_child(block_layer)
	game.select_campaign_sector("biomassFacility")
	game.enter_campaign_playable_slice()
	var tile_state := game.source_campaign_map_tile_state()
	var initial_build_state := game.source_world_initial_build_runtime_state()
	source_world_initial_build_runtime_state.build_block_layer(game, block_layer, initial_build_state)
	var multimesh_batch_node_count := 0
	var dynamic_sprite_node_count := 0
	for child in block_layer.get_children():
		if child is MultiMeshInstance2D:
			multimesh_batch_node_count += 1
		elif child is Sprite2D:
			dynamic_sprite_node_count += 1
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceWorldInitialBuildRuntimeState",
		"block_placement_count": int(tile_state.get("block_placement_count", 0)),
		"initial_build_block_count": int(initial_build_state.get("block_count", 0)),
		"block_placement_count_matches": int(tile_state.get("block_placement_count", 0)) == 47588,
		"initial_build_block_count_matches": int(initial_build_state.get("block_count", 0)) == 47588,
		"core_origin_count_matches": int(tile_state.get("block_placement_name_counts", {}).get("core-shard", 0)) == 1,
		"core_tile_count_still_source_backed": int(tile_state.get("block_name_counts", {}).get("core-shard", 0)) == 9,
		"non_center_entity_tiles_match": int(tile_state.get("non_center_entity_tile_count", 0)) == 72,
		"initial_build_uses_campaign_blocks": int(initial_build_state.get("campaign_map_block_placement_count", 0)) == 47588,
		"static_block_count_matches": int(initial_build_state.get("static_block_count", 0)) == 47528,
		"dynamic_block_count_matches": int(initial_build_state.get("dynamic_block_count", 0)) == 60,
		"static_batch_count_matches": int(initial_build_state.get("static_block_batch_count", 0)) == 7,
		"dynamic_group_count_matches": int(initial_build_state.get("dynamic_block_name_counts", {}).size()) == 12,
		"block_layer_child_count_matches": block_layer.get_child_count() == 67,
		"multimesh_batch_node_count_matches": multimesh_batch_node_count == 7,
		"dynamic_sprite_node_count_matches": dynamic_sprite_node_count == 60,
		"source_owner_matches": str(initial_build_state.get("source_owner", "")) == "port_game.source_world_initial_build_runtime_state",
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["block_placement_count_matches"] and proof["initial_build_block_count_matches"] and proof["core_origin_count_matches"] and proof["core_tile_count_still_source_backed"] and proof["non_center_entity_tiles_match"] and proof["initial_build_uses_campaign_blocks"] and proof["static_block_count_matches"] and proof["dynamic_block_count_matches"] and proof["static_batch_count_matches"] and proof["dynamic_group_count_matches"] and proof["block_layer_child_count_matches"] and proof["multimesh_batch_node_count_matches"] and proof["dynamic_sprite_node_count_matches"] and proof["source_owner_matches"] and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("CAMPAIGN_MAP_BLOCK_LAYER_RUNTIME_PROOF " + JSON.stringify(proof))
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/CampaignMapBlockLayerRuntimeProof.json")
	var file := FileAccess.open(proof_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(proof))
		file.flush()
		file.close()
	game.free()
	await get_tree().process_frame
	get_tree().quit(0 if proof["matches"] else 1)

