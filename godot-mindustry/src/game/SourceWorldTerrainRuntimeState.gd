extends RefCounted
class_name SourceWorldTerrainRuntimeState

const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_block_plan_geometry_state := preload("res://src/game/SourceBlockPlanGeometryState.gd")
const source_block_query_basic_state := preload("res://src/game/SourceBlockQueryBasicState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_drill_consumption_runtime_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const SOURCE_WORLD_AIR_FIELD := "air"
const SOURCE_WORLD_STONE_FIELD := "stone"
const SOURCE_WORLD_SCENARIO_ORE_FIELD := "oreCopper"
const SOURCE_WORLD_WATER_FIELD := "water"
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_block_init_placement_state := preload("res://src/game/SourceBlockInitPlacementState.gd")
const source_continuous_liquid_turret_build_state := preload("res://src/game/SourceContinuousLiquidTurretBuildState.gd")
const source_turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
const source_factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const source_unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
const source_adjacent_factory_build_state := preload("res://src/game/SourceAdjacentFactoryBuildState.gd")

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


# Execute Tile.setBlock for a placed Building on the actual world Tile
# store, with runtime hooks built from the game context. This is the
# ConstructBlock.constructFinish equivalent: the placed sprite is the
# Building entity, the player team is sharded, rotation is normalized by
# the primitive, and multiblock proxies are cleared through setBlock(air)
# then reassigned. A Building exists exactly when a sprite is supplied;
# the air recursion passes null and creates none. Block.update is read
# from the catalog when exported and falls back to the Java field default
# (false); the sprite init is unconditional so the value is inert here.
# Change events and renderer recache have no runtime bus or cache yet, so
# those hooks are explicit no-ops and the result records only whether the
# guard reached them. Building.onRemoved and Block.blockChanged are empty
# by default upstream, so those hooks are no-ops too; the ColoredWall /
# TiledWall blockChanged overrides stay open. Proximity updates are the
# registered Drill recompute, team-filtered like Building.updateProximity.
static func source_apply_placed_tile_set_block_state(game: Object, block: Object, cell: Vector2i, sprite: Sprite2D, team_id: int, rotation: int) -> Dictionary:
	var world_tiles: Dictionary = game.get("source_world_tiles")
	var self_tile: Variant = source_world_tile(world_tiles, cell.x, cell.y)
	assert(self_tile != null and block != null, "Placed Tile.setBlock requires a resolved world Tile and Block")
	var catalog: Object = game.get("content_catalog")
	var placed_blocks: Dictionary = game.get("placed_blocks")
	var air_block: Object = source_world_block_by_field(catalog, SOURCE_WORLD_AIR_FIELD)
	var previous_build: Variant = placed_blocks.get(source_world_grid.cell_key(cell))
	if previous_build != null and not is_instance_valid(previous_build):
		previous_build = null
	var previous_block: Variant = null
	var previous_block_size := 0
	var previous_block_multiblock := false
	var old_build_center := cell
	if previous_build != null:
		var previous_block_id: String = str(previous_build.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if previous_block_id != "":
			previous_block = catalog.get_by_id(previous_block_id)
		if previous_block != null:
			previous_block_size = source_block_metadata_state.block_size(previous_block)
			previous_block_multiblock = source_block_query_basic_state.is_multiblock_state(previous_block_size)["is_multiblock"]
			old_build_center = previous_build.get_meta("origin_cell", cell)
	var geometry: Dictionary = source_block_geometry_state(block, float(game.get("tile_size")))
	var new_block_size: int = geometry["size"]
	var new_block_multiblock: bool = geometry["is_multiblock"]
	var size_offset: int = geometry["size_offset"]
	var previous_block_static := false
	if previous_block != null:
		previous_block_static = source_block_query_basic_state.is_static_state(str(previous_block.properties["cacheLayer"]))["is_static"]
	var type_static: bool = source_block_query_basic_state.is_static_state(str(block.properties["cacheLayer"]))["is_static"]
	var new_block_has_building: bool = sprite != null
	var new_block_update: bool = bool(block.properties.get("update", false))
	var removed_old_build: bool = previous_build != null and not is_same(previous_build, sprite)
	var proximity_state := {"updated": 0}
	var world_tile_lookup := func(tile_x: int, tile_y: int) -> Variant: return source_world_tile(world_tiles, tile_x, tile_y)
	var world_build := func(tile_x: int, tile_y: int) -> Variant:
		var tile: Variant = source_world_tile(world_tiles, tile_x, tile_y)
		return tile.get("build") if tile != null else null
	var on_proximity_update := func(build: Variant) -> bool:
		if build == null or not is_instance_valid(build):
			return false
		if int(build.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, source_block_geometry.SOURCE_TEAM_DERELICT_ID)) != team_id:
			return false
		var build_block_id: String = str(build.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if build_block_id == "":
			return false
		var build_block: Variant = catalog.get_by_id(build_block_id)
		if build_block == null:
			return false
		var applied: bool = source_drill_consumption_runtime_state.source_on_proximity_update_state(game, build, build_block)["applied"]
		# The turret frame is bound at placement like the drill frame:
		# Block.newBuilding() creates the Building when the block is
		# placed (Block.java:1002), and the port's frame is that
		# Building state. The live-loop tick fills the frame keys
		# every tick (N2103); other blocks bind nothing.
		source_continuous_liquid_turret_build_state.source_bind_frame_state(build, build_block)
		# The turret frame is bound at placement like the drill and
		# ContinuousLiquidTurret frames: Block.newBuilding() creates
		# the Building when the block is placed (Block.java:1002),
		# and the port's frame is that Building state. The live-loop
		# tick fills the frame keys every tick (N2108); other blocks
		# bind nothing.
		source_turret_build_state.source_turret_bind_frame_state(build, build_block)
		# The factory frame is bound at placement like the drill,
		# ContinuousLiquidTurret and turret frames: Block.newBuilding()
		# creates the Building when the block is placed (Block.java:1002),
		# and the port's frame is that Building state. The live-loop
		# tick fills the frame keys every tick (N2109); other blocks
		# bind nothing.
		source_factory_build_state.source_factory_bind_frame_state(build, build_block)
		# The factory frame is bound at placement like the drill,
		# ContinuousLiquidTurret and turret frames:
		# Block.newBuilding() creates the Building when the block is
		# placed (Block.java:1002), and the port's frame is that
		# Building state. The live-loop tick fills the frame keys
		# every tick (N2109); other blocks bind nothing.
		source_unit_factory_build_state.source_unit_factory_bind_frame_state(build, build_block)
		# The adjacent-factory frame is bound at placement like the
		# drill, ContinuousLiquidTurret, turret and factory frames:
		# Block.newBuilding() creates the Building when the block is
		# placed (Block.java:1002), and the port's frame is that
		# Building state. The live-loop tick fills the frame keys
		# every tick (N2114); other blocks bind nothing.
		source_adjacent_factory_build_state.source_adjacent_factory_bind_frame_state(build, build_block)
		if applied:
			proximity_state["updated"] = int(proximity_state["updated"]) + 1
		return applied
	var update_proximity := func(build: Variant) -> bool:
		# Building.updateProximity: recompute this Building, then
		# onProximityUpdate on each same-team edge neighbour. The
		# neighbour pass is deduplicated; the recompute is idempotent,
		# so the count reports unique neighbours only.
		var applied_self: bool = on_proximity_update.call(build)
		if build == null or not is_instance_valid(build):
			return applied_self
		var build_block_id: String = str(build.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		var build_block: Variant = catalog.get_by_id(build_block_id) if build_block_id != "" else null
		if build_block == null:
			return applied_self
		var build_size: int = source_block_metadata_state.block_size(build_block)
		var origin: Vector2i = build.get_meta("origin_cell", cell)
		var seen: Array = []
		for point in source_block_plan_geometry_state.edge_points_state(build_size):
			var other: Variant = world_build.call(origin.x + point.x, origin.y + point.y)
			if other != null and not is_same(other, build) and not seen.has(other):
				seen.append(other)
				on_proximity_update.call(other)
		return applied_self
	var remove_from_proximity := func(old_build: Variant) -> void:
		if old_build == null:
			return
		var seen: Array = []
		for point in source_block_plan_geometry_state.edge_points_state(previous_block_size):
			var other: Variant = world_build.call(int(self_tile["x"]) + point.x, int(self_tile["y"]) + point.y)
			if other != null and not seen.has(other):
				seen.append(other)
				on_proximity_update.call(other)
	var remove_build := func(old_build: Variant) -> void:
		if old_build == null or not is_instance_valid(old_build):
			return
		if is_same(old_build, sprite):
			return
		for key in placed_blocks.keys():
			if is_same(placed_blocks[key], old_build):
				placed_blocks.erase(key)
		# placed_block_origins maps each occupied cell to the origin cell,
		# not to the sprite, so the old Building's cells are removed by
		# matching its origin.
		var old_origin: Vector2i = old_build.get_meta("origin_cell", cell)
		var origins: Dictionary = game.get("placed_block_origins")
		for key in origins.keys():
			if origins.get(key) == old_origin:
				origins.erase(key)
		game.set("placed_blocks", placed_blocks)
		game.set("placed_block_origins", origins)
		old_build.queue_free()
	var entity_provider := func() -> Variant:
		return sprite
	var entity_init := func(created: Variant, tile: Dictionary, init_team: int, init_update: bool, init_rotation: int) -> Variant:
		var occupied: Array[Vector2i] = game.call("occupied_cells", cell, block)
		var cell_keys: Array[String] = []
		for occupied_cell in occupied:
			cell_keys.append(source_world_grid.cell_key(occupied_cell))
		source_placed_block_state.game_initialize_sprite(game, created, block, cell, cell_keys)
		if created is Sprite2D:
			created.set_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, init_rotation)
		return created
	var build_team := func(build: Variant, new_team_id: int) -> void:
		source_block_geometry.source_assign_build_team_state(build, new_team_id)
	var neighbor_changing := func(other_build: Variant) -> bool:
		if other_build == null or not is_instance_valid(other_build):
			return false
		var origin: Vector2i = other_build.get_meta("origin_cell", cell)
		var tile: Variant = source_world_tile(world_tiles, origin.x, origin.y)
		return bool(tile.get("changing", false)) if tile != null else false
	var set_block_air := func(other_tile: Dictionary) -> void:
		var proxy_cell := Vector2i(int(other_tile["x"]), int(other_tile["y"]))
		source_apply_placed_tile_set_block_state(game, air_block, proxy_cell, null, team_id, 0)
	var d4_offsets: Array = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]
	var world_generating := false
	var editor_state := false
	source_block_geometry.source_apply_tile_set_block(self_tile, block, team_id, rotation, type_static, previous_block_static, false, null, world_generating, previous_build, previous_block_multiblock, previous_block_size, size_offset, old_build_center, world_tile_lookup, world_build, air_block, func(_old_build: Variant) -> void: pass, remove_from_proximity, remove_build, func(_tile: Dictionary) -> void: pass, func(_tile: Dictionary) -> void: pass, new_block_has_building, new_block_update, editor_state, update_proximity, on_proximity_update, entity_provider, entity_init, build_team, d4_offsets, neighbor_changing, func(_tile: Dictionary) -> void: pass, func(_tile: Dictionary) -> void: pass, set_block_air, new_block_multiblock, new_block_size, func(_new_block: Variant, _tile: Dictionary) -> void: pass)
	return {
		"tile": self_tile,
		"build": self_tile.get("build"),
		"removed_old_build": removed_old_build,
		"proximity_updated": int(proximity_state["updated"]),
		"changed_event_fired": not world_generating,
		"recache_called": type_static or previous_block_static,
	}

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

static func source_floor_liquid_drop_state(floor_id: String) -> Dictionary:
	# Blocks.java floor liquidDrop definitions: deep-water /
	# shallow-water / tainted-water / deep-tainted-water drop water
	# (deep-water and deep-tainted-water have liquidMultiplier 1.5);
	# tar drops oil; pooled-cryofluid drops cryofluid (multiplier
	# 0.5); molten-slag drops slag; arkycite-floor drops arkycite.
	# Any other floor drops nothing (Floor.java default liquidDrop
	# null, liquidMultiplier 1.0). The pump's canPump is exactly
	# this: tile != null && tile.floor().liquidDrop != null
	# (Pump.java:106-108).
	match floor_id:
		"deep-water":
			return {"liquid_drop": "water", "liquid_multiplier": 1.5, "is_liquid": true}
		"shallow-water", "tainted-water":
			return {"liquid_drop": "water", "liquid_multiplier": 1.0, "is_liquid": true}
		"deep-tainted-water":
			return {"liquid_drop": "water", "liquid_multiplier": 1.5, "is_liquid": true}
		"tar":
			return {"liquid_drop": "oil", "liquid_multiplier": 1.0, "is_liquid": true}
		"pooled-cryofluid":
			return {"liquid_drop": "cryofluid", "liquid_multiplier": 0.5, "is_liquid": true}
		"molten-slag":
			return {"liquid_drop": "slag", "liquid_multiplier": 1.0, "is_liquid": true}
		"arkycite-floor":
			return {"liquid_drop": "arkycite", "liquid_multiplier": 1.0, "is_liquid": true}
	return {"liquid_drop": null, "liquid_multiplier": 0.0, "is_liquid": false}

static func source_water_region_state(world_tiles: Dictionary, water_block: Object) -> Dictionary:
	# Blocks.java:224-234 water = new Floor("shallow-water") with
	# liquidDrop = Liquids.water and isLiquid = true. The bootstrap
	# world has a water region (5,14)-(8,17) so a pump has water to
	# pump (C04); the region is free of buildings and ore.
	var cells: Array[Vector2i] = source_playable_scenario_defaults.water_cells()
	var applied := 0
	for cell in cells:
		var tile: Variant = source_world_tile(world_tiles, cell.x, cell.y)
		if tile != null:
			tile["floor"] = water_block
			applied += 1
	return {"cells": cells, "count": applied, "reason": "water_region"}

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
	var water_block: Object = source_world_block_by_field(catalog, SOURCE_WORLD_WATER_FIELD)
	source_water_region_state(world_tiles, water_block)
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
const source_campaign_map_tile_state := preload("res://src/game/SourceCampaignMapTileState.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_world_grid := preload("res://src/game/SourceWorldGrid.gd")
const source_world_terrain_source_text_state := preload("res://src/game/SourceWorldTerrainSourceTextState.gd")

const PROP_TILE_SIZE := source_world_terrain_source_text_state.PROP_TILE_SIZE
const METHOD_SOURCE_CAMPAIGN_MAP_TILE_STATE := source_world_terrain_source_text_state.METHOD_SOURCE_CAMPAIGN_MAP_TILE_STATE
const SOURCE_ORE_BLOCK_SOURCE := source_world_terrain_source_text_state.SOURCE_ORE_BLOCK_SOURCE
const SOURCE_ORE_BLOCK_ITEM_DROP := source_world_terrain_source_text_state.SOURCE_ORE_BLOCK_ITEM_DROP


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

static func campaign_map_terrain_plan_state(campaign_map_tile_state: Dictionary, tile_size: int) -> Dictionary:
	var terrain_sprites: Array[Dictionary] = []
	var ore_sprites: Array[Dictionary] = []
	var ore_items_by_cell: Dictionary = {}
	var map_width := int(campaign_map_tile_state.get("width", 0))
	for floor_run in campaign_map_tile_state.get("floor_runs", []):
		var run_length := int(floor_run.get("run_length", 0))
		var start_index := int(floor_run.get("y", 0)) * map_width + int(floor_run.get("x", 0))
		var floor_block_id := str(floor_run.get("floor_name", ""))
		var overlay_block_id := str(floor_run.get("overlay_name", ""))
		for run_offset in range(run_length):
			var cell_index := start_index + run_offset
			var cell := Vector2i(cell_index % map_width, source_campaign_map_tile_state._cell_y_from_index(cell_index, map_width))
			var world_position := source_world_grid.grid_to_world(cell, tile_size)
			terrain_sprites.append({"key": floor_block_id, "cell": {"x": cell.x, "y": cell.y}, "x": world_position.x, "y": world_position.y})
			if _is_ore_overlay(overlay_block_id):
				var ore_item_id := _ore_item_id_from_overlay_name(overlay_block_id)
				ore_sprites.append({"key": overlay_block_id, "cell": {"x": cell.x, "y": cell.y}, "x": world_position.x, "y": world_position.y, "item_id": ore_item_id})
				ore_items_by_cell[source_world_grid.cell_key(cell)] = ore_item_id
	return {
		"terrain_sprites": terrain_sprites,
		"ore_sprites": ore_sprites,
		"ore_items_by_cell": ore_items_by_cell,
		"terrain_count": terrain_sprites.size(),
		"ore_count": ore_sprites.size(),
		"world_cell_count": terrain_sprites.size(),
		"map_width": map_width,
		"map_height": int(campaign_map_tile_state.get("height", 0)),
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_WORLD_TERRAIN_RUNTIME_STATE,
		"source": SOURCE_ORE_BLOCK_SOURCE,
		"source_item_drop": SOURCE_ORE_BLOCK_ITEM_DROP,
	}

static func game_terrain_plan_state(game: Object) -> Dictionary:
	if game != null and game.has_method(METHOD_SOURCE_CAMPAIGN_MAP_TILE_STATE):
		var campaign_map_tile_state: Dictionary = game.call(METHOD_SOURCE_CAMPAIGN_MAP_TILE_STATE)
		if bool(campaign_map_tile_state.get("map_region_consumed", false)) and int(campaign_map_tile_state.get("floor_run_count", 0)) > 0:
			return campaign_map_terrain_plan_state(campaign_map_tile_state, int(game.get(PROP_TILE_SIZE)))
	var viewport = game.call("get_viewport") if game != null else null
	var viewport_size: Vector2 = viewport.get_visible_rect().size if viewport else Vector2.ZERO
	return terrain_plan_state(
		source_playable_scenario_defaults.background_cells_for_viewport(Vector2i(int(viewport_size.x), int(viewport_size.y))),
		source_playable_scenario_defaults.ore_copper_cells(),
		source_playable_scenario_defaults.BLOCK_STONE_FLOOR,
		source_playable_scenario_defaults.BLOCK_ORE_COPPER,
		source_playable_scenario_defaults.ITEM_COPPER,
		int(game.get(PROP_TILE_SIZE)) if game != null else 0
	)

static func _is_ore_overlay(overlay_block_id: String) -> bool:
	return overlay_block_id.begins_with("ore-") and not overlay_block_id.begins_with("ore-wall-")

static func _ore_item_id_from_overlay_name(overlay_block_id: String) -> String:
	if not overlay_block_id.begins_with("ore-"):
		return ""
	return overlay_block_id.substr("ore-".length())
