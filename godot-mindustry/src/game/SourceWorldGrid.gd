class_name SourceWorldGrid
extends RefCounted

static func grid_to_world(cell: Vector2i, tile_size: int) -> Vector2:
	var half_tile := float(tile_size) * 0.5
	return Vector2(float(cell.x) * float(tile_size) + half_tile, float(cell.y) * float(tile_size) + half_tile)


static func world_to_grid(pos: Vector2, tile_size: int) -> Vector2i:
	var safe_tile_size: int = max(1, tile_size)
	return Vector2i(floori(pos.x / float(safe_tile_size)), floori(pos.y / float(safe_tile_size)))


static func cell_key(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]


static func sprite_tile_scale(texture_size: Vector2, tile_size: int) -> Vector2:
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Vector2.ONE
	return Vector2(float(tile_size) / texture_size.x, float(tile_size) / texture_size.y)
