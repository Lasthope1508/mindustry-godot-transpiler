extends RefCounted
class_name SourceWorldTerrainRuntimeState

const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")

const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_block_query_basic_state := preload("res://src/game/SourceBlockQueryBasicState.gd")
const SOURCE_WORLD_AIR_FIELD := "air"
const SOURCE_WORLD_STONE_FIELD := "stone"
const SOURCE_WORLD_SCENARIO_ORE_FIELD := "oreCopper"
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_block_init_placement_state := preload("res://src/game/SourceBlockInitPlacementState.gd")

static func source_block_geometry_state(block: Object, source_tilesize: float) -> Dictionary:
	assert(block != null and block.content_type == "block", "World Tile block definition is unresolved")
	var size: int = source_block_metadata_state.block_size(block)
	var initialized: Dictionary = source_block_init_placement_state.offset_state(size, source_tilesize)
	return {"size": size, "size_offset": initialized["size_offset_after"], "is_multiblock": source_block_query_basic_state.is_multiblock_state(size)["is_multiblock"]}

static func source_world_tiles_state(width: int, height: int, air_block: Object) -> Dictionary:
	assert(width > 0 and height > 0)
	var tiles: Array = []
	for index in range(width * height):
		tiles.append({"x": index % width, "y": int(index / width), "floor": air_block, "overlay": air_block, "block": air_block})
	return {"width": width, "height": height, "array": tiles}

static func source_world_tile(world_tiles: Dictionary, x: int, y: int) -> Variant:
	if x < 0 or x >= world_tiles["width"] or y < 0 or y >= world_tiles["height"]:
		return null
	return world_tiles["array"][y * world_tiles["width"] + x]

static func source_record_world_block(world_tiles: Dictionary, block: Object, x: int, y: int, source_tilesize: float) -> void:
	var self_tile: Variant = source_world_tile(world_tiles, x, y)
	if self_tile == null:
		return
	var geometry: Dictionary = source_block_geometry_state(block, source_tilesize)
	var linked: Array = []
	var lookup := func(tile_x: int, tile_y: int) -> Variant: return source_world_tile(world_tiles, tile_x, tile_y)
	source_block_geometry.tile_get_linked_tiles_as_array_state(geometry["is_multiblock"], geometry["size"], geometry["size_offset"], x, y, lookup, self_tile, linked)
	# Field/proxy assignment only. Removal, overlapping entity cleanup and events have separate lifecycle gates.
	for tile in linked:
		tile["block"] = block

static func _source_block_by_id(content_catalog: Object, id: String) -> Object:
	var block: Object = content_catalog.call("get_by_id", id)
	assert(block != null and block.content_type == "block", "World Tile block definition is unresolved: " + id)
	return block

static func source_world_block_by_field(content_catalog: Object, field: String) -> Object:
	for block in content_catalog.call("get_many", "block"):
		if block.field == field:
			return block
	assert(false, "World Tile block definition is unresolved: " + field)
	return null

static func source_campaign_world_tiles_state(campaign_map_tile_state: Dictionary, content_catalog: Object, source_tilesize: float) -> Dictionary:
	var air: Object = source_world_block_by_field(content_catalog, SOURCE_WORLD_AIR_FIELD)
	var world_tiles := source_world_tiles_state(campaign_map_tile_state["width"], campaign_map_tile_state["height"], air)
	var created: int = 0
	for run in campaign_map_tile_state["floor_runs"]:
		var start_index: int = run["y"] * world_tiles["width"] + run["x"]
		var length: int = run["run_length"]
		assert(start_index == created and length > 0 and created + length <= world_tiles["array"].size(), "World Tile floor runs must cover the map")
		var floor_block: Object = _source_block_by_id(content_catalog, run["floor_name"])
		if is_same(floor_block, air):
			floor_block = source_world_block_by_field(content_catalog, SOURCE_WORLD_STONE_FIELD)
		var overlay: Object = _source_block_by_id(content_catalog, run["overlay_name"])
		for index in range(start_index, start_index + length):
			world_tiles["array"][index]["floor"] = floor_block
			world_tiles["array"][index]["overlay"] = overlay
		created += length
	assert(created == world_tiles["array"].size(), "World Tile floor runs must cover the map")
	for placement in campaign_map_tile_state["block_placements"]:
		var block: Object = _source_block_by_id(content_catalog, placement["key"])
		source_record_world_block(world_tiles, block, placement["cell"]["x"], placement["cell"]["y"], source_tilesize)
	return world_tiles

static func source_game_world_tiles_state(game: Object, initial_build_state: Dictionary) -> Dictionary:
	var catalog: Object = game.get("content_catalog")
	var map: Dictionary = initial_build_state.get("campaign_map_tile", {})
	if bool(map.get("map_region_consumed", false)):
		return source_campaign_world_tiles_state(map, catalog, float(game.get("tile_size")))
	var air: Object = source_world_block_by_field(catalog, SOURCE_WORLD_AIR_FIELD)
	var floor_block: Object = source_world_block_by_field(catalog, SOURCE_WORLD_STONE_FIELD)
	var overlay: Object = source_world_block_by_field(catalog, SOURCE_WORLD_SCENARIO_ORE_FIELD)
	var dimensions: Vector2i = source_playable_scenario_defaults.world_size()
	var world_tiles := source_world_tiles_state(dimensions.x, dimensions.y, air)
	for tile in world_tiles["array"]:
		tile["floor"] = floor_block
	for cell in source_playable_scenario_defaults.ore_copper_cells():
		var tile: Variant = source_world_tile(world_tiles, cell.x, cell.y)
		if tile != null:
			tile["overlay"] = overlay
	return world_tiles

# Live overlay assignment/Drill notification only; rendering/events and other Building overrides remain separate.
static func source_set_world_overlay_state(game: Object, x: int, y: int, block: Object, generating: bool) -> Dictionary:
	var tile: Variant = source_world_tile(game.get("source_world_tiles"), x, y)
	assert(tile != null and block != null, "Tile overlay mutation requires resolved world/content")
	var sprite: Variant = game.call("block_sprite_at_cell", Vector2i(x, y))
	var mutation := source_block_geometry.tile_overlay_mutation_state("set_overlay", block, tile["overlay"], false, generating, sprite != null)
	if mutation["same_overlay"]:
		return {"changed": false, "proximity_updated": false}
	tile["overlay"] = mutation["overlay"]
	var applied := false
	if mutation["proximity_updated"]:
		var catalog: Object = game.get("content_catalog")
		var placed_block: Object = catalog.get_by_id(sprite.get_meta(SourcePlacedBlockState.SOURCE_BLOCK_ID_META_KEY))
		applied = SourceDrillConsumptionRuntimeState.source_on_proximity_update_state(game, sprite, placed_block)["applied"]
	return {"changed": true, "proximity_updated": applied}

# Apply Tile.setFloor assignment and its Building notification; other Tile side effects have separate owners.
static func source_set_world_floor_state(game: Object, x: int, y: int, floor_block: Object) -> Dictionary:
	var tile: Variant = source_world_tile(game.get("source_world_tiles"), x, y)
	assert(tile != null and floor_block != null, "Tile floor mutation requires resolved world/content")
	var sprite: Variant = game.call("block_sprite_at_cell", Vector2i(x, y))
	var mutation := source_block_geometry.tile_floor_assignment_state(floor_block, tile["floor"], sprite != null)
	if mutation["same_floor"]:
		return {"changed": false, "proximity_updated": false}
	tile["floor"] = mutation["floor"]
	var applied := false
	if mutation["build_proximity_updated"]:
		var catalog: Object = game.get("content_catalog")
		var placed_block: Object = catalog.get_by_id(sprite.get_meta(SourcePlacedBlockState.SOURCE_BLOCK_ID_META_KEY))
		applied = SourceDrillConsumptionRuntimeState.source_on_proximity_update_state(game, sprite, placed_block)["applied"]
	return {"changed": true, "proximity_updated": applied}

static func source_set_world_overlay_quiet_state(game: Object, x: int, y: int, block: Object) -> void:
	var tile: Variant = source_world_tile(game.get("source_world_tiles"), x, y)
	assert(tile != null and block != null, "Tile overlay mutation requires resolved world/content")
	var mutation := source_block_geometry.tile_overlay_mutation_state("set_overlay_quiet", block)
	tile["overlay"] = mutation["overlay"]

static func source_clear_world_overlay_state(game: Object, x: int, y: int, generating: bool) -> Dictionary:
	var air: Object = source_world_block_by_field(game.get("content_catalog"), SOURCE_WORLD_AIR_FIELD)
	var mutation := source_block_geometry.tile_overlay_mutation_state("clear_overlay", null, null, false, generating, false, null, air)
	return source_set_world_overlay_state(game, x, y, mutation["overlay"], generating)

# Execute the existing canonical receiver recipe in order; no networking transport is implied.
static func source_set_world_floor_overlay_state(game: Object, x: int, y: int, floor_block: Object, overlay_block: Object, generating: bool) -> Dictionary:
	var tile: Variant = source_world_tile(game.get("source_world_tiles"), x, y)
	assert(tile != null)
	var recipe := source_block_geometry.tile_single_mutation_state("set_floor", tile, floor_block, overlay_block, 0, true)
	var result: Dictionary = {}
	for mutation in recipe["calls"]:
		if mutation.has("floor"):
			result["floor_state"] = source_set_world_floor_state(game, x, y, mutation["floor"])
		else:
			result["overlay_state"] = source_set_world_overlay_state(game, x, y, mutation["overlay"], generating)
	return result

static func source_set_world_floor_default_state(game: Object, x: int, y: int, floor_block: Object, generating: bool) -> Dictionary:
	var air: Object = source_world_block_by_field(game.get("content_catalog"), SOURCE_WORLD_AIR_FIELD)
	return source_set_world_floor_overlay_state(game, x, y, floor_block, air, generating)

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
