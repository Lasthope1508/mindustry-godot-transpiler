extends "res://src/game/SourceBlockQueryPortBridge.gd"

const source_world_grid_port_bridge_grid := preload("res://src/game/SourceWorldGrid.gd")

func grid_to_world(cell: Vector2i) -> Vector2:
	return source_world_grid_port_bridge_grid.grid_to_world(cell, int(get("tile_size")))

func world_to_grid(pos: Vector2) -> Vector2i:
	return source_world_grid_port_bridge_grid.world_to_grid(pos, int(get("tile_size")))

func cell_key(cell: Vector2i) -> String:
	return source_world_grid_port_bridge_grid.cell_key(cell)
