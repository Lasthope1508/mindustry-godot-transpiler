class_name SourceBlockPlacement
extends RefCounted

const SourceWorldGrid := preload("res://src/game/SourceWorldGrid.gd")

const SOURCE_BUILD_WORLD_TILE_EXPR := "Tile check = world.tile(wx, wy);"
const SOURCE_BUILD_WORLD_TILE_NULL_EXPR := "check == null"

static func can_place_state(occupied_cells: Array[Vector2i], placed_blocks: Dictionary, world_size: Vector2i) -> Dictionary:
	for occupied_cell in occupied_cells:
		if occupied_cell.x < 0 or occupied_cell.y < 0 or occupied_cell.x >= world_size.x or occupied_cell.y >= world_size.y:
			return {"can_place": false, "blocked_reason": "out_of_bounds", "blocked_cell": occupied_cell}
		var key := SourceWorldGrid.cell_key(occupied_cell)
		if placed_blocks.has(key):
			return {"can_place": false, "blocked_reason": "occupied", "blocked_cell": occupied_cell}
	return {"can_place": true, "blocked_reason": "", "blocked_cell": Vector2i.ZERO}


static func can_place(occupied_cells: Array[Vector2i], placed_blocks: Dictionary, world_size: Vector2i) -> bool:
	return bool(can_place_state(occupied_cells, placed_blocks, world_size).get("can_place", false))


static func record_cells(placed_block_origins: Dictionary, placed_blocks: Dictionary, origin_cell: Vector2i, occupied_cells: Array[Vector2i], sprite: Sprite2D) -> Array[String]:
	var cell_keys: Array[String] = []
	for occupied_cell in occupied_cells:
		var key := SourceWorldGrid.cell_key(occupied_cell)
		placed_block_origins[key] = origin_cell
		placed_blocks[key] = sprite
		cell_keys.append(key)
	return cell_keys
