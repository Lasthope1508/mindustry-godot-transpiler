extends RefCounted
class_name SourceSchematicPlacementState

const source_world_terrain_runtime_state := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const source_building_configure_state := preload("res://src/game/SourceBuildingConfigureState.gd")


# Place one Schematics.place stile through the canonical setBlock binding.
# This is the Schematics.place loop body: the world Tile is resolved at
# the stile offset from the schematic origin, a null Tile is skipped, and
# with overwrite false the caller-supplied valid-place hook decides. The
# hook is Build.validPlace, which has no runtime equivalent yet (rules
# visibility, core protection, fog, darkness, unit overlap, canPlaceOn /
# canReplace), so placement is fail-closed without one. The Building is
# created by the placement funnel exactly like player placement (new
# sprite, configure_block_sprite, BlockLayer, record_placed_block), which
# runs the N2033 setBlock binding with the threaded team. When the Tile
# keeps a Building and the stile carries a config, configureAny runs with
# the caller-supplied tile_config_callback, the Call.tileConfig
# equivalent; without a callback the call is recorded but applies
# nothing, and per-block-type config application stays open.
static func source_apply_schematic_tile_state(game: Object, stile: Dictionary, origin_cell: Vector2i, team_id: int, overwrite: bool, valid_place_hook: Variant, tile_config_callback: Variant) -> Dictionary:
	var block: Variant = stile.get("block")
	assert(block != null, "Schematic stile requires a Block")
	var rotation: int = int(stile.get("rotation", 0))
	var cell := Vector2i(int(stile.get("x", 0)) + origin_cell.x, int(stile.get("y", 0)) + origin_cell.y)
	var world_tiles: Dictionary = game.get("source_world_tiles")
	var tile: Variant = source_world_terrain_runtime_state.source_world_tile(world_tiles, cell.x, cell.y)
	if tile == null:
		return {"cell": cell, "tile": null, "build": null, "placed": false, "skipped": "tile_missing", "valid_place_checked": false, "configured": false}
	var valid_place_checked := false
	if not overwrite:
		if not (valid_place_hook is Callable and valid_place_hook.is_valid()):
			return {"cell": cell, "tile": tile, "build": null, "placed": false, "skipped": "valid_place_unchecked", "valid_place_checked": false, "configured": false}
		valid_place_checked = true
		if not bool(valid_place_hook.call(block, team_id, cell.x, cell.y, rotation)):
			return {"cell": cell, "tile": tile, "build": null, "placed": false, "skipped": "valid_place_rejected", "valid_place_checked": true, "configured": false}
	var sprite := Sprite2D.new()
	game.call("configure_block_sprite", sprite, block, cell)
	game.get_node("World/BlockLayer").add_child(sprite)
	game.call("record_placed_block", sprite, block, cell, team_id)
	var build: Variant = tile.get("build")
	var configured := false
	if build != null and stile.get("config") != null:
		source_building_configure_state.configure_any_state(build, stile.get("config"), tile_config_callback)
		configured = true
	return {"cell": cell, "tile": tile, "build": build, "placed": true, "skipped": "", "valid_place_checked": valid_place_checked, "configured": configured}


# Place a whole schematic: the origin is the center minus half the width
# and height, and the stiles run in source order through the per-tile
# binding above. The result counts what the loop placed, skipped and
# configured, and keeps every per-tile result in source order.
static func source_apply_schematic_place_state(game: Object, schematic: Dictionary, x: int, y: int, team_id: int, overwrite: bool, valid_place_hook: Variant, tile_config_callback: Variant) -> Dictionary:
	var width: int = int(schematic.get("width", 0))
	var height: int = int(schematic.get("height", 0))
	var origin := Vector2i(x - width / 2, y - height / 2)
	var tiles: Array = schematic.get("tiles", [])
	var placed := 0
	var skipped := 0
	var configured := 0
	var results: Array = []
	for stile in tiles:
		var result: Dictionary = source_apply_schematic_tile_state(game, stile, origin, team_id, overwrite, valid_place_hook, tile_config_callback)
		results.append(result)
		if bool(result.get("placed", false)):
			placed += 1
		else:
			skipped += 1
		if bool(result.get("configured", false)):
			configured += 1
	return {"origin": origin, "placed": placed, "skipped": skipped, "configured": configured, "results": results}


# Place one Schematics.placeLoadout stile through the canonical setBlock
# binding. This is the placeLoadout loop body: the world Tile is resolved
# at the stile offset from the loadout origin, a null Tile is skipped, and
# with check true a non-core stile first clears every blocking non-air
# tile from its footprint (Tile.remove() is setBlock(air), so each linked
# tile goes through the N2033 binding). Core stiles skip the removal pass.
# The Building is then placed exactly like a Schematics.place stile
# (overwrite true, placeLoadout never checks Build.validPlace), and when
# the placed Building is a CoreBuild the caller-supplied
# register_core_hook runs, the Teams.registerCore equivalent; the runtime
# has no TeamData.cores registry, so the hook is where registration
# happens and the result records whether it fired.
static func source_apply_loadout_tile_state(game: Object, stile: Dictionary, origin_cell: Vector2i, team_id: int, check: bool, tile_config_callback: Variant, register_core_hook: Variant) -> Dictionary:
	var block: Variant = stile.get("block")
	assert(block != null, "Schematic stile requires a Block")
	var cell := Vector2i(int(stile.get("x", 0)) + origin_cell.x, int(stile.get("y", 0)) + origin_cell.y)
	var world_tiles: Dictionary = game.get("source_world_tiles")
	var tile: Variant = source_world_terrain_runtime_state.source_world_tile(world_tiles, cell.x, cell.y)
	if tile == null:
		return {"cell": cell, "tile": null, "build": null, "placed": false, "skipped": "tile_missing", "removed": 0, "configured": false, "core_placed": false, "core_registered": false}
	var removed := 0
	if check and str(block.implementation) != "CoreBlock":
		var air_block: Object = source_world_terrain_runtime_state.source_world_block_by_field(game.get("content_catalog"), "air")
		for footprint_cell in game.call("occupied_cells", cell, block):
			var linked_tile: Variant = source_world_terrain_runtime_state.source_world_tile(world_tiles, int(footprint_cell.x), int(footprint_cell.y))
			if linked_tile != null and linked_tile.get("block") != air_block:
				source_world_terrain_runtime_state.source_apply_placed_tile_set_block_state(game, air_block, footprint_cell, null, team_id, 0)
				removed += 1
	var placed_result: Dictionary = source_apply_schematic_tile_state(game, stile, origin_cell, team_id, true, null, tile_config_callback)
	var build: Variant = placed_result.get("build")
	var core_placed := bool(placed_result.get("placed", false)) and str(block.implementation) == "CoreBlock"
	var core_registered := false
	if core_placed and register_core_hook is Callable and register_core_hook.is_valid():
		register_core_hook.call(build, team_id)
		core_registered = true
	return {"cell": cell, "tile": tile, "build": build, "placed": bool(placed_result.get("placed", false)), "skipped": placed_result.get("skipped", ""), "removed": removed, "configured": bool(placed_result.get("configured", false)), "core_placed": core_placed, "core_registered": core_registered}


static func _loadout_priority(stile: Dictionary, priority_hook: Variant) -> int:
	if priority_hook is Callable and priority_hook.is_valid():
		return int(priority_hook.call(stile.get("block")))
	return 0


# Place a whole loadout schematic: the origin is the placed core position
# minus the core stile offsets (the schematic must carry exactly one core
# stile, otherwise the placement fails like Java's throw), and the stiles
# run in descending schematicPriority order through the per-tile binding
# above, on a copy so the schematic's own tile order is untouched. The
# priority hook is caller-supplied because schematicPriority is not
# exported by the content catalog; without one every stile has priority
# 0. The result counts what the loop placed, skipped, removed and
# configured, how many cores the register hook fired for, and keeps every
# per-tile result in priority order.
static func source_apply_loadout_place_state(game: Object, schematic: Dictionary, x: int, y: int, team_id: int, check: bool, priority_hook: Variant, tile_config_callback: Variant, register_core_hook: Variant) -> Dictionary:
	var tiles: Array = schematic.get("tiles", [])
	var core_tile: Variant = null
	for stile in tiles:
		if str(stile.get("block").implementation) == "CoreBlock":
			core_tile = stile
			break
	assert(core_tile != null, "Loadout schematic has no core tile!")
	var origin := Vector2i(x - int(core_tile.get("x", 0)), y - int(core_tile.get("y", 0)))
	var ordered: Array = tiles.duplicate()
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return _loadout_priority(a, priority_hook) > _loadout_priority(b, priority_hook))
	var placed := 0
	var skipped := 0
	var removed := 0
	var configured := 0
	var cores_registered := 0
	var results: Array = []
	for stile in ordered:
		var result: Dictionary = source_apply_loadout_tile_state(game, stile, origin, team_id, check, tile_config_callback, register_core_hook)
		results.append(result)
		if bool(result.get("placed", false)):
			placed += 1
		else:
			skipped += 1
		removed += int(result.get("removed", 0))
		if bool(result.get("configured", false)):
			configured += 1
		if bool(result.get("core_registered", false)):
			cores_registered += 1
	return {"origin": origin, "placed": placed, "skipped": skipped, "removed": removed, "configured": configured, "cores_registered": cores_registered, "results": results}
