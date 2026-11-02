extends RefCounted
class_name SourceWorldTerrainRuntimeState

const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_block_query_basic_state := preload("res://src/game/SourceBlockQueryBasicState.gd")

static func source_tile_ore_state(tile: Dictionary, item_catalog: Dictionary, air_block: Object) -> Dictionary:
	var floor_block: Object = tile["floor"]
	var overlay_block: Object = tile["overlay"]
	var block: Object = tile["block"]
	assert(floor_block.properties.has("itemDrop") and overlay_block.properties.has("itemDrop") and block.properties.has("cacheLayer"), "Tile ore source definitions are unresolved")
	var fields: Dictionary = item_catalog["item_facts_by_field"]
	var floor_item_drop: Variant = null if floor_block.properties["itemDrop"] == null else fields[floor_block.properties["itemDrop"]]
	var overlay_item_drop: Variant = null if overlay_block.properties["itemDrop"] == null else fields[overlay_block.properties["itemDrop"]]
	var drop: Variant = source_block_geometry.tile_drop_state(is_same(overlay_block, air_block), overlay_item_drop, floor_item_drop)
	var is_static: bool = source_block_query_basic_state.is_static_state(block.properties["cacheLayer"])["is_static"]
	return {"is_static": is_static, "drop": drop}

static func source_linked_ore_tiles_state(block_is_multiblock: bool, block_size: int, size_offset: int, x: int, y: int, world_tile_lookup: Callable, self_tile: Dictionary, item_catalog: Dictionary, air_block: Object) -> Dictionary:
	var linked_tiles: Array = []
	source_block_geometry.tile_get_linked_tiles_as_array_state(block_is_multiblock, block_size, size_offset, x, y, world_tile_lookup, self_tile, linked_tiles)
	var ore_tiles: Array = []
	for tile in linked_tiles:
		ore_tiles.append(source_tile_ore_state(tile, item_catalog, air_block))
	return {"ore_tiles": ore_tiles}

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
