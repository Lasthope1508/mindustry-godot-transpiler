extends Node

const main_scene := preload("res://scenes/Main.tscn")
const geometry := preload("res://src/game/SourceBlockGeometry.gd")
const placed := preload("res://src/game/SourcePlacedBlockState.gd")
const terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const live := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")


func _frame(sprite: Sprite2D) -> Dictionary:
	return sprite.get_meta(live.SOURCE_DRILL_BUILDING_META_KEY)


func _dominant_id(game: Node, sprite: Sprite2D) -> String:
	var frame: Dictionary = _frame(sprite)
	var dominant: Variant = frame.get("dominant_item")
	if not (dominant is Dictionary):
		return ""
	var items: Dictionary = game.get("source_item_catalog")
	var names: Array = items.get("item_names_by_id", [])
	var numeric_id: int = int(dominant.get("id", -1))
	return str(names[numeric_id]) if numeric_id >= 0 and numeric_id < names.size() else ""


func _dominant_count(sprite: Sprite2D) -> int:
	return int(_frame(sprite).get("dominant_items", 0))


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
	var catalog = game.get("content_catalog")
	var drill = catalog.get_by_id("mechanical-drill")
	var conveyor = catalog.get_by_id("conveyor")
	var lead_ore = catalog.get_by_id("ore-lead")
	var copper_ore = catalog.get_by_id("ore-copper")

	# --- Bootstrap binding: the initial Drill went through record_placed_block. ---
	var drill_cell: Vector2i = game.get("drill_pos")
	var first: Sprite2D = game.call("block_sprite_at_cell", drill_cell)
	var first_tile: Dictionary = game.call("source_world_tile", drill_cell.x, drill_cell.y)
	proof["bootstrap_tile_build_is_first_sprite"] = first_tile.get("build") == first and first_tile.get("block") == drill
	proof["bootstrap_team_is_sharded"] = int(first.get_meta(geometry.SOURCE_BUILD_TEAM_META_KEY, -1)) == geometry.SOURCE_TEAM_SHARDED_ID
	proof["bootstrap_frame_selects_copper"] = _dominant_id(game, first) == "copper" and _dominant_count(first) == 2

	# --- N2032: team assignment is the build_team hook target. ---
	var fresh := Sprite2D.new()
	var assigned: Dictionary = geometry.source_assign_build_team_state(fresh, geometry.SOURCE_TEAM_SHARDED_ID)
	proof["assign_team_state_sets_meta"] = assigned.get("team_id") == 1 and assigned.get("build") == fresh and int(fresh.get_meta(geometry.SOURCE_BUILD_TEAM_META_KEY, -1)) == 1

	# --- Stale frame: raw overlay mutation without notification. ---
	for stale_cell in [drill_cell, drill_cell + Vector2i(0, 1)]:
		var stale_tile: Dictionary = game.call("source_world_tile", stale_cell.x, stale_cell.y)
		stale_tile["overlay"] = lead_ore
	proof["raw_overlay_mutation_leaves_frame_stale"] = _dominant_id(game, first) == "copper"

	# --- N2033/N2034: place a second Drill edge-adjacent to the first. ---
	var second_cell := drill_cell + Vector2i(2, 0)
	var second := Sprite2D.new()
	game.add_child(second)
	for occupied in game.call("occupied_cells", second_cell, drill):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, copper_ore, false)
	game.call("record_placed_block", second, drill, second_cell)
	var second_tile: Dictionary = game.call("source_world_tile", second_cell.x, second_cell.y)
	proof["placed_second_drill_tile_build_and_proxies"] = second_tile.get("build") == second and second_tile.get("block") == drill and game.call("source_world_tile", second_cell.x + 1, second_cell.y).get("build") == second and game.call("source_world_tile", second_cell.x, second_cell.y + 1).get("build") == second and game.call("source_world_tile", second_cell.x + 1, second_cell.y + 1).get("block") == drill
	proof["placed_second_drill_team_and_frame"] = int(second.get_meta(geometry.SOURCE_BUILD_TEAM_META_KEY, -1)) == geometry.SOURCE_TEAM_SHARDED_ID and _dominant_id(game, second) == "copper" and _dominant_count(second) == 4
	proof["neighbour_proximity_recomputed_through_set_block"] = _dominant_id(game, first) == "lead" and _dominant_count(first) == 2

	# --- Replacement: a Conveyor over the second Drill removes its Building. ---
	var replacement := Sprite2D.new()
	game.add_child(replacement)
	game.call("record_placed_block", replacement, conveyor, second_cell)
	await get_tree().process_frame
	var placed_blocks: Dictionary = game.get("placed_blocks")
	proof["replacement_removes_old_build"] = not is_instance_valid(second) and not placed_blocks.values().has(second) and game.call("source_world_tile", second_cell.x, second_cell.y).get("build") == replacement and int(replacement.get_meta(geometry.SOURCE_BUILD_TEAM_META_KEY, -1)) == geometry.SOURCE_TEAM_SHARDED_ID
	proof["replacement_clears_old_proxies"] = game.call("source_world_tile", second_cell.x + 1, second_cell.y).get("block") == catalog.get_by_id("air") and game.call("source_world_tile", second_cell.x, second_cell.y + 1).get("build") == null
	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("PlacedTileSetBlockProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
