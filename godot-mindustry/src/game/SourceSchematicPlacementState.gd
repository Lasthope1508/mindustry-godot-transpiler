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
