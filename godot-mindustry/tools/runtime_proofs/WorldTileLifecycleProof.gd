extends Node

const catalog_script := preload("res://src/mindustry/content/ContentCatalog.gd")
const terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const content := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const drill := preload("res://src/game/SourceDrillRuntimeState.gd")
const scenario := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const main_scene := preload("res://scenes/Main.tscn")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var catalog := catalog_script.new()
	var air: Object = catalog.get_by_id("air")
	var stone: Object = catalog.get_by_id("stone")
	var sand: Object = catalog.get_by_id("sand-floor")
	var mechanical: Object = catalog.get_by_id("mechanical-drill")
	var proof: Dictionary = {}
	for size in [1, 2, 3, 4]:
		var block: Object = catalog.get_by_id(["conveyor", "mechanical-drill", "core-shard", "laser-drill"][size - 1])
		# Size 4 is an explicit source-sized fixture; laser-drill's own size stays intact.
		if size == 4:
			block = preload("res://src/mindustry/content/Block.gd").new({"id": "fixture", "properties": {"size": 4}})
		var geometry := terrain.source_block_geometry_state(block, 8.0)
		proof["geometry_size_" + str(size)] = geometry["size"] == size and geometry["size_offset"] == [0, 0, -1, -1][size - 1] and geometry["is_multiblock"] == (size > 1)
	var world := terrain.source_world_tiles_state(3, 2, air)
	var first: Dictionary = terrain.source_world_tile(world, 0, 0)
	proof["air_fill_coordinates_identity"] = world["array"].size() == 6 and first["x"] == 0 and first["y"] == 0 and is_same(first["floor"], air) and is_same(first["overlay"], air) and is_same(first["block"], air) and terrain.source_world_tile(world, 2, 1)["x"] == 2
	proof["all_four_bounds_null"] = terrain.source_world_tile(world, -1, 0) == null and terrain.source_world_tile(world, 0, -1) == null and terrain.source_world_tile(world, 3, 0) == null and terrain.source_world_tile(world, 0, 2) == null
	first["floor"] = sand
	proof["storage_reference_identity"] = is_same(terrain.source_world_tile(world, 0, 0), first) and is_same(world["array"][0]["floor"], sand) and is_same(world["array"][1]["floor"], air)
	var map := {"width": 3, "height": 2, "floor_runs": [{"x": 0, "y": 0, "run_length": 4, "floor_name": "air", "overlay_name": "ore-lead"}, {"x": 1, "y": 1, "run_length": 2, "floor_name": "sand-floor", "overlay_name": "spawn"}], "block_placements": [{"key": "stone-wall", "cell": {"x": 0, "y": 0}}, {"key": "mechanical-drill", "cell": {"x": 1, "y": 0}}]}
	if "--unknown-block" in OS.get_cmdline_user_args():
		map["floor_runs"][0]["overlay_name"] = "missing-definition"
		terrain.source_campaign_world_tiles_state(map, catalog, 8.0)
		return
	if "--incomplete-map" in OS.get_cmdline_user_args():
		map["floor_runs"].pop_back()
		terrain.source_campaign_world_tiles_state(map, catalog, 8.0)
		return
	world = terrain.source_campaign_world_tiles_state(map, catalog, 8.0)
	map["map_region_consumed"] = true
	proof["air_floor_becomes_stone_cross_row_run"] = is_same(terrain.source_world_tile(world, 0, 1)["floor"], stone) and is_same(terrain.source_world_tile(world, 1, 1)["floor"], sand)
	proof["static_batch_blocks_materialized"] = terrain.source_tile_ore_state(terrain.source_world_tile(world, 0, 0), content.source_item_catalog_state(catalog), air)["is_static"]
	proof["center_placement_expands_proxies"] = is_same(terrain.source_world_tile(world, 1, 0)["block"], mechanical) and is_same(terrain.source_world_tile(world, 2, 1)["block"], mechanical)
	terrain.source_record_world_block(world, catalog.get_by_id("core-shard"), 0, 0, 8.0)
	proof["edge_footprint_skips_null"] = is_same(terrain.source_world_tile(world, 1, 1)["block"], catalog.get_by_id("core-shard")) and is_same(terrain.source_world_tile(world, 2, 0)["block"], mechanical)
	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)
	var actual: Dictionary = game.get("source_world_tiles")
	var actual_catalog: Object = game.get("content_catalog")
	proof["actual_bootstrap_dense_logical_world"] = actual["width"] == scenario.world_size().x and actual["height"] == scenario.world_size().y and actual["array"].size() == actual["width"] * actual["height"]
	var ore_cell: Vector2i = scenario.ore_copper_cells()[0]
	var actual_tile: Dictionary = game.call("source_world_tile", ore_cell.x, ore_cell.y)
	proof["actual_bootstrap_source_overlay"] = is_same(actual_tile["overlay"], actual_catalog.get_by_id("ore-copper")) and is_same(actual_tile["floor"], actual_catalog.get_by_id("stone"))
	var cell: Vector2i = game.get("drill_pos")
	var actual_drill: Object = actual_catalog.get_by_id("mechanical-drill")
	proof["initial_build_records_actual_tile"] = is_same(game.call("source_world_tile", cell.x, cell.y)["block"], actual_drill)
	var sprite := Sprite2D.new()
	game.add_child(sprite)
	var new_cell := Vector2i(2, 2)
	game.call("record_placed_block", sprite, actual_drill, new_cell)
	proof["actual_placement_updates_same_storage"] = is_same(game.call("source_world_tile", 3, 3)["block"], actual_drill) and is_same(game.get("source_world_tiles"), actual)
	var items := content.source_item_catalog_state(actual_catalog)
	var linked: Dictionary = game.call("source_world_linked_ore_tiles_state", actual_drill, cell.x, cell.y, items)
	var selected := drill.source_count_ore_state(linked["ore_tiles"], 2, null)
	proof["actual_world_drill_selection_composition"] = linked["ore_tiles"].size() == 4 and is_same(selected["returnItem"], items["item_facts_by_field"]["copper"]) and selected["returnCount"] > 0
	var old_array: Array = actual["array"]
	var replacement := terrain.source_game_world_tiles_state(game, {"campaign_map_tile": map})
	proof["campaign_bootstrap_uses_map_dimensions"] = replacement["width"] == 3 and replacement["height"] == 2 and is_same(terrain.source_world_tile(replacement, 0, 0)["block"], actual_catalog.get_by_id("stone-wall"))
	proof["new_world_has_independent_storage"] = not is_same(old_array, replacement["array"]) and old_array.size() == actual["width"] * actual["height"]
	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	game.queue_free()
	await get_tree().process_frame
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("WorldTileLifecycleProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
