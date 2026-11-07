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
	var terrain_layer := Node2D.new()
	terrain_layer.name = "TerrainLayer"
	world.add_child(terrain_layer)
	game.select_campaign_sector("biomassFacility")
	game.enter_campaign_playable_slice()
	var terrain_state := game.source_world_terrain_runtime_state()
	var terrain_layer_state: Dictionary = source_world_initial_build_runtime_state.build_terrain_layer(game, terrain_layer, terrain_state)
	var multimesh_batch_node_count := 0
	var sprite_node_count := 0
	for child in terrain_layer.get_children():
		if child is MultiMeshInstance2D:
			multimesh_batch_node_count += 1
		elif child is Sprite2D:
			sprite_node_count += 1
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceWorldTerrainRuntimeState",
		"terrain_count": int(terrain_state.get("terrain_count", 0)),
		"ore_count": int(terrain_state.get("ore_count", 0)),
		"world_cell_count": int(terrain_state.get("world_cell_count", 0)),
		"terrain_count_matches": int(terrain_state.get("terrain_count", 0)) == 62500,
		"ore_count_matches": int(terrain_state.get("ore_count", 0)) == 694,
		"world_cell_count_matches": int(terrain_state.get("world_cell_count", 0)) == 62500,
		"ore_items_by_cell_matches": int(terrain_state.get("ore_items_by_cell", {}).size()) == 694,
		"terrain_batch_count_matches": int(terrain_layer_state.get("terrain_batch_count", 0)) == 12,
		"ore_batch_count_matches": int(terrain_layer_state.get("ore_batch_count", 0)) == 4,
		"terrain_render_node_count_matches": int(terrain_layer_state.get("terrain_render_node_count", 0)) == 16,
		"terrain_layer_child_count_matches": terrain_layer.get_child_count() == 16,
		"multimesh_batch_node_count_matches": multimesh_batch_node_count == 16,
		"sprite_node_count_matches": sprite_node_count == 0,
		"source_owner_matches": str(terrain_state.get("source_owner", "")) == "port_game.source_world_terrain_runtime_state",
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["terrain_count_matches"] and proof["ore_count_matches"] and proof["world_cell_count_matches"] and proof["ore_items_by_cell_matches"] and proof["terrain_batch_count_matches"] and proof["ore_batch_count_matches"] and proof["terrain_render_node_count_matches"] and proof["terrain_layer_child_count_matches"] and proof["multimesh_batch_node_count_matches"] and proof["sprite_node_count_matches"] and proof["source_owner_matches"] and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("CAMPAIGN_MAP_TERRAIN_RUNTIME_PROOF " + JSON.stringify(proof))
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/CampaignMapTerrainRuntimeProof.json")
	var file := FileAccess.open(proof_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(proof))
		file.flush()
		file.close()
	game.free()
	await get_tree().process_frame
	get_tree().quit(0 if proof["matches"] else 1)

