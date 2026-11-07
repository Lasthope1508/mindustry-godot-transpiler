extends Node

const main_scene := preload("res://scenes/Main.tscn")
const terrain_state := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}
	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- the water region is (5,14)-(8,17): 16 cells, all set to
	# the shallow-water floor (Blocks.java:224-234, liquidDrop water). ---
	var catalog: Object = game.get("content_catalog")
	var water_block: Object = terrain_state.source_world_block_by_field(catalog, "water")
	var world_tiles: Dictionary = game.get("source_world_tiles")
	var region: Dictionary = terrain_state.source_water_region_state(world_tiles, water_block)
	proof["water_region"] = int(region.get("count", -1)) == 16 and (region.get("cells", []) as Array).size() == 16 and str(region.get("reason", "")) == "water_region"

	# --- the real Main scene's tiles in the region have the
	# shallow-water floor, and a tile outside it (the drill at (7,8))
	# still has the stone floor. ---
	var water_tile: Dictionary = game.call("source_world_tile", 5, 14)
	var water_corner: Dictionary = game.call("source_world_tile", 8, 17)
	var drill_tile: Dictionary = game.call("source_world_tile", 7, 8)
	proof["water_region_live_floor"] = str(water_tile.get("floor").id) == "shallow-water" and str(water_corner.get("floor").id) == "shallow-water" and str(drill_tile.get("floor").id) == "stone"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("WaterRegionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
