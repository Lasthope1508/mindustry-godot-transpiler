extends RefCounted
class_name SourceBlockPlacement

const source_world_grid := preload("res://src/game/SourceWorldGrid.gd")
const source_block_footprint := preload("res://src/game/SourceBlockFootprint.gd")
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_selected_build_state := preload("res://src/game/SourceSelectedBuildState.gd")
const source_block_requirements_state := preload("res://src/game/SourceBlockRequirementsState.gd")

const SOURCE_BUILD_WORLD_TILE_EXPR := "Tile check = world.tile(wx, wy);"
const SOURCE_BUILD_WORLD_TILE_NULL_EXPR := "check == null"

static func can_place_state(occupied_cells: Array[Vector2i], placed_blocks: Dictionary, world_size: Vector2i) -> Dictionary:
	for occupied_cell in occupied_cells:
		if occupied_cell.x < 0 or occupied_cell.y < 0 or occupied_cell.x >= world_size.x or occupied_cell.y >= world_size.y:
			return {
				"can_place": false,
				"blocked_reason": "out_of_bounds",
				"blocked_cell": occupied_cell,
			}
		var key := source_world_grid.cell_key(occupied_cell)
		if placed_blocks.has(key):
			return {
				"can_place": false,
				"blocked_reason": "occupied",
				"blocked_cell": occupied_cell,
			}
	return {
		"can_place": true,
		"blocked_reason": "",
		"blocked_cell": null,
	}

static func can_place(occupied_cells: Array[Vector2i], placed_blocks: Dictionary, world_size: Vector2i) -> bool:
	var state := can_place_state(occupied_cells, placed_blocks, world_size)
	return bool(state.get("can_place", false))

static func selected_block_placement_state(block, cell: Vector2i, placed_blocks: Dictionary, world_size: Vector2i, can_afford_result: bool) -> Dictionary:
	var block_size := source_block_metadata_state.block_size(block)
	var occupied_cells := source_block_footprint.occupied_cells(cell, block_size)
	var placement := can_place_state(occupied_cells, placed_blocks, world_size)
	return {
		"block": block,
		"cell": cell,
		"occupied_cells": occupied_cells,
		"occupied_cell_count": source_block_footprint.occupied_cell_count(block_size),
		"can_place": bool(placement.get("can_place", false)),
		"can_afford": can_afford_result,
		"blocked_reason": str(placement.get("blocked_reason", "")),
		"blocked_cell": placement.get("blocked_cell", null),
	}


static func place_selected_block_at_world(game: Object, world_pos: Vector2, world_size: Vector2i) -> bool:
	if game == null:
		return false
	var build_palette_value = game.get("build_palette")
	if not (build_palette_value is Array) or build_palette_value.is_empty():
		game.set("last_place_blocked", true)
		return false
	var build_palette: Array = build_palette_value
	var cell: Vector2i = game.call("world_to_grid", world_pos)
	var block = source_selected_build_state.selected_build(build_palette, int(game.get("selected_build_index")))
	var placed_blocks_value = game.get("placed_blocks")
	var placed_blocks: Dictionary = placed_blocks_value if placed_blocks_value is Dictionary else {}
	var can_afford_result := bool(game.call("can_afford", block))
	var placement_state := selected_block_placement_state(block, cell, placed_blocks, world_size, can_afford_result)
	if not bool(placement_state.get("can_place", false)):
		game.set("last_place_blocked", true)
		return false
	if not bool(placement_state.get("can_afford", false)):
		game.set("last_place_blocked", true)
		return false
	var blocks: Node = game.get_node("World/BlockLayer")
	game.call("spend_requirements", block)
	var sprite := Sprite2D.new()
	game.call("configure_block_sprite", sprite, block, cell)
	blocks.add_child(sprite)
	game.call("record_placed_block", sprite, block, cell)
	game.set("player_placed_block_count", int(game.get("player_placed_block_count")) + 1)
	game.set("last_placed_block_id", str(block.id))
	game.set("last_placed_block_size", source_block_metadata_state.block_size(block))
	game.set("last_placed_block_requirements", source_block_requirements_state.block_requirements(block))
	game.set("last_placed_cell", cell)
	game.set("last_placed_occupied_cell_count", source_block_footprint.occupied_cell_count(source_block_metadata_state.block_size(block)))
	game.set("last_place_blocked", false)
	game.call("register_turret_cell", cell, block)
	return true


static func add_source_block(game: Object, parent: Node, block_id: String, cell: Vector2i) -> void:
	if game == null or parent == null:
		return
	var content_catalog = game.get("content_catalog")
	if content_catalog == null:
		return
	var block = content_catalog.get_by_id(block_id)
	if block == null:
		return
	var sprite := Sprite2D.new()
	game.call("configure_block_sprite", sprite, block, cell)
	parent.add_child(sprite)
	game.call("record_placed_block", sprite, block, cell)
	game.call("register_turret_cell", cell, block)


static func record_cells(placed_block_origins: Dictionary, placed_blocks: Dictionary, origin_cell: Vector2i, occupied_cells: Array[Vector2i], sprite: Sprite2D) -> Array[String]:
	var cell_keys: Array[String] = []
	for occupied_cell in occupied_cells:
		var key := source_world_grid.cell_key(occupied_cell)
		cell_keys.append(key)
		placed_block_origins[key] = origin_cell
		placed_blocks[key] = sprite
	return cell_keys
