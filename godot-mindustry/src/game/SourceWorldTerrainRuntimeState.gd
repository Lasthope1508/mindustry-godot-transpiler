extends RefCounted
class_name SourceWorldTerrainRuntimeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_world_grid := preload("res://src/game/SourceWorldGrid.gd")


static func terrain_plan_state(world_cells: Array[Vector2i], ore_cells: Array[Vector2i], floor_block_id: String, ore_block_id: String, ore_item_id: String, tile_size: int) -> Dictionary:
	var terrain_sprites: Array[Dictionary] = []
	var ore_sprites: Array[Dictionary] = []
	var ore_items_by_cell: Dictionary = {}
	for cell in world_cells:
		var world_position := source_world_grid.grid_to_world(cell, tile_size)
		terrain_sprites.append({"key": floor_block_id, "cell": {"x": cell.x, "y": cell.y}, "x": world_position.x, "y": world_position.y})
	for cell in ore_cells:
		var world_position := source_world_grid.grid_to_world(cell, tile_size)
		ore_sprites.append({"key": ore_block_id, "cell": {"x": cell.x, "y": cell.y}, "x": world_position.x, "y": world_position.y, "item_id": ore_item_id})
		ore_items_by_cell[source_world_grid.cell_key(cell)] = ore_item_id
	return {
		"terrain_sprites": terrain_sprites,
		"ore_sprites": ore_sprites,
		"ore_items_by_cell": ore_items_by_cell,
		"terrain_count": terrain_sprites.size(),
		"ore_count": ore_sprites.size(),
		"world_cell_count": world_cells.size(),
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_WORLD_TERRAIN_RUNTIME_STATE,
	}
