extends RefCounted
class_name SourceWorldInitialBuildRuntimeState

const source_world_terrain_runtime_state := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")

const source_world_grid := preload("res://src/game/SourceWorldGrid.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_campaign_block_layer_runtime_state := preload("res://src/game/SourceCampaignBlockLayerRuntimeState.gd")
const source_campaign_terrain_layer_runtime_state := preload("res://src/game/SourceCampaignTerrainLayerRuntimeState.gd")
const source_world_initial_build_source_text_state := preload("res://src/game/SourceWorldInitialBuildSourceTextState.gd")

const NODE_PATH_WORLD_TERRAIN_LAYER := source_world_initial_build_source_text_state.NODE_PATH_WORLD_TERRAIN_LAYER
const NODE_PATH_WORLD_BLOCK_LAYER := source_world_initial_build_source_text_state.NODE_PATH_WORLD_BLOCK_LAYER
const NODE_PATH_WORLD_UNIT_LAYER := source_world_initial_build_source_text_state.NODE_PATH_WORLD_UNIT_LAYER
const PROP_PLACED_BLOCK_ORIGINS := source_world_initial_build_source_text_state.PROP_PLACED_BLOCK_ORIGINS
const PROP_PLACED_BLOCKS := source_world_initial_build_source_text_state.PROP_PLACED_BLOCKS
const PROP_PATH_POINTS := source_world_initial_build_source_text_state.PROP_PATH_POINTS
const PROP_ORE_ITEMS_BY_CELL := source_world_initial_build_source_text_state.PROP_ORE_ITEMS_BY_CELL
const PROP_DRILL_POS := source_world_initial_build_source_text_state.PROP_DRILL_POS
const PROP_DRILL_OUTPUT_ITEM_ID := source_world_initial_build_source_text_state.PROP_DRILL_OUTPUT_ITEM_ID
const PROP_DRILL_ORE_CELL_COUNT := source_world_initial_build_source_text_state.PROP_DRILL_ORE_CELL_COUNT
const PROP_DRILL_OUTPUT_RATE := source_world_initial_build_source_text_state.PROP_DRILL_OUTPUT_RATE
const PROP_CORE_MAX_HEALTH := source_world_initial_build_source_text_state.PROP_CORE_MAX_HEALTH
const PROP_CORE_HEALTH := source_world_initial_build_source_text_state.PROP_CORE_HEALTH
const PROP_CORE_ITEM_CAPACITY := source_world_initial_build_source_text_state.PROP_CORE_ITEM_CAPACITY
const PROP_CONVEYOR_WORLD_SPEED := source_world_initial_build_source_text_state.PROP_CONVEYOR_WORLD_SPEED
const PROP_CONVEYOR_PATH_PROGRESS_RATE := source_world_initial_build_source_text_state.PROP_CONVEYOR_PATH_PROGRESS_RATE
const PROP_BOOTSTRAPPED_SELECTED_TURRET_AMMO_LOAD_COUNT := source_world_initial_build_source_text_state.PROP_BOOTSTRAPPED_SELECTED_TURRET_AMMO_LOAD_COUNT
const PROP_INITIAL_WORLD_BLOCK_COUNT := source_world_initial_build_source_text_state.PROP_INITIAL_WORLD_BLOCK_COUNT
const PROP_INITIAL_OCCUPIED_CELL_COUNT := source_world_initial_build_source_text_state.PROP_INITIAL_OCCUPIED_CELL_COUNT
const METHOD_SOURCE_WORLD_TERRAIN_RUNTIME_STATE := source_world_initial_build_source_text_state.METHOD_SOURCE_WORLD_TERRAIN_RUNTIME_STATE
const METHOD_SOURCE_DRILL_ORE_COUNT := source_world_initial_build_source_text_state.METHOD_SOURCE_DRILL_ORE_COUNT
const METHOD_SOURCE_DRILL_OUTPUT_RATE := source_world_initial_build_source_text_state.METHOD_SOURCE_DRILL_OUTPUT_RATE
const METHOD_ADD_SPRITE := source_world_initial_build_source_text_state.METHOD_ADD_SPRITE
const METHOD_ADD_SOURCE_TILE_BATCH := source_world_initial_build_source_text_state.METHOD_ADD_SOURCE_TILE_BATCH
const METHOD_SOURCE_WORLD_INITIAL_BUILD_RUNTIME_STATE := source_world_initial_build_source_text_state.METHOD_SOURCE_WORLD_INITIAL_BUILD_RUNTIME_STATE
const METHOD_ADD_SOURCE_BLOCK := source_world_initial_build_source_text_state.METHOD_ADD_SOURCE_BLOCK
const METHOD_ADD_SOURCE_BLOCK_BATCH := source_world_initial_build_source_text_state.METHOD_ADD_SOURCE_BLOCK_BATCH
const METHOD_SOURCE_ITEM_TRANSPORT_BOOTSTRAP_STATE := source_world_initial_build_source_text_state.METHOD_SOURCE_ITEM_TRANSPORT_BOOTSTRAP_STATE
const METHOD_SOURCE_BLOCK_HEALTH := source_world_initial_build_source_text_state.METHOD_SOURCE_BLOCK_HEALTH
const METHOD_SOURCE_BLOCK_ITEM_CAPACITY := source_world_initial_build_source_text_state.METHOD_SOURCE_BLOCK_ITEM_CAPACITY
const METHOD_SOURCE_CONVEYOR_WORLD_SPEED := source_world_initial_build_source_text_state.METHOD_SOURCE_CONVEYOR_WORLD_SPEED
const METHOD_SOURCE_CONVEYOR_PATH_PROGRESS_RATE := source_world_initial_build_source_text_state.METHOD_SOURCE_CONVEYOR_PATH_PROGRESS_RATE
const METHOD_BOOTSTRAP_SELECTED_TURRET_AMMO := source_world_initial_build_source_text_state.METHOD_BOOTSTRAP_SELECTED_TURRET_AMMO
const METHOD_SOURCE_CAMPAIGN_LAUNCH_CONTEXT_STATE := source_world_initial_build_source_text_state.METHOD_SOURCE_CAMPAIGN_LAUNCH_CONTEXT_STATE
const METHOD_SOURCE_CAMPAIGN_MAP_FILE_STATE := source_world_initial_build_source_text_state.METHOD_SOURCE_CAMPAIGN_MAP_FILE_STATE
const METHOD_SOURCE_CAMPAIGN_MAP_CONTENT_HEADER_STATE := source_world_initial_build_source_text_state.METHOD_SOURCE_CAMPAIGN_MAP_CONTENT_HEADER_STATE
const METHOD_SOURCE_CAMPAIGN_MAP_TILE_STATE := source_world_initial_build_source_text_state.METHOD_SOURCE_CAMPAIGN_MAP_TILE_STATE
const KEY_BLOCK_PLACEMENTS := source_world_initial_build_source_text_state.KEY_BLOCK_PLACEMENTS
const KEY_PATH_POINTS := source_world_initial_build_source_text_state.KEY_PATH_POINTS
const KEY_BLOCK_COUNT := source_world_initial_build_source_text_state.KEY_BLOCK_COUNT
const KEY_CONVEYOR_COUNT := source_world_initial_build_source_text_state.KEY_CONVEYOR_COUNT
const KEY_PATH_POINT_COUNT := source_world_initial_build_source_text_state.KEY_PATH_POINT_COUNT
const KEY_CAMPAIGN_LAUNCH_CONTEXT := source_world_initial_build_source_text_state.KEY_CAMPAIGN_LAUNCH_CONTEXT
const KEY_CAMPAIGN_MAP_FILE := source_world_initial_build_source_text_state.KEY_CAMPAIGN_MAP_FILE
const KEY_CAMPAIGN_MAP_CONTENT_HEADER := source_world_initial_build_source_text_state.KEY_CAMPAIGN_MAP_CONTENT_HEADER
const KEY_CAMPAIGN_MAP_TILE := source_world_initial_build_source_text_state.KEY_CAMPAIGN_MAP_TILE
const KEY_CAMPAIGN_MAP_BLOCK_PLACEMENT_COUNT := source_world_initial_build_source_text_state.KEY_CAMPAIGN_MAP_BLOCK_PLACEMENT_COUNT
const KEY_CAMPAIGN_MAP_BLOCK_PLACEMENT_NAME_COUNTS := source_world_initial_build_source_text_state.KEY_CAMPAIGN_MAP_BLOCK_PLACEMENT_NAME_COUNTS
const KEY_STATIC_BLOCK_BATCHES := source_world_initial_build_source_text_state.KEY_STATIC_BLOCK_BATCHES
const KEY_DYNAMIC_BLOCK_PLACEMENTS := source_world_initial_build_source_text_state.KEY_DYNAMIC_BLOCK_PLACEMENTS
const KEY_TERRAIN_BATCHES := source_world_initial_build_source_text_state.KEY_TERRAIN_BATCHES
const KEY_ORE_BATCHES := source_world_initial_build_source_text_state.KEY_ORE_BATCHES
const KEY_SOURCE_OWNER := source_world_initial_build_source_text_state.KEY_SOURCE_OWNER
const KEY_KEY := source_world_initial_build_source_text_state.KEY_KEY
const KEY_ROLE := source_world_initial_build_source_text_state.KEY_ROLE
const KEY_CELL := source_world_initial_build_source_text_state.KEY_CELL
const KEY_X := source_world_initial_build_source_text_state.KEY_X
const KEY_Y := source_world_initial_build_source_text_state.KEY_Y
const KEY_TERRAIN_SPRITES := source_world_initial_build_source_text_state.KEY_TERRAIN_SPRITES
const KEY_ORE_SPRITES := source_world_initial_build_source_text_state.KEY_ORE_SPRITES
const KEY_ITEM_SPRITES := source_world_initial_build_source_text_state.KEY_ITEM_SPRITES
const KEY_VISIBLE := source_world_initial_build_source_text_state.KEY_VISIBLE

static func block_placement_state(key: String, role: String, cell: Vector2i, tile_size: int) -> Dictionary:
	var world_position := source_world_grid.grid_to_world(cell, tile_size)
	var cell_state := {}
	cell_state[KEY_X] = cell.x
	cell_state[KEY_Y] = cell.y
	var state := {}
	state[KEY_KEY] = key
	state[KEY_ROLE] = role
	state[KEY_CELL] = cell_state
	state[KEY_X] = world_position.x
	state[KEY_Y] = world_position.y
	return state


static func source_solar_panel_placement_state(tile_size: int) -> Dictionary:
	# Blocks.java:2607-2610: solarPanel = new SolarGenerator("solar-panel")
	# with powerProduction = 0.12f. The panel is the bootstrap world's
	# power producer, placed on a free size-1 cell east of the duo.
	var world_position := source_world_grid.grid_to_world(source_playable_scenario_defaults.SOLAR_PANEL_POS, tile_size)
	return {
		"block_id": source_playable_scenario_defaults.BLOCK_SOLAR_PANEL,
		"role": source_playable_scenario_defaults.INITIAL_BUILD_ROLE_SOLAR_PANEL,
		"cell": source_playable_scenario_defaults.SOLAR_PANEL_POS,
		"x": world_position.x,
		"y": world_position.y,
		"power_production": 0.12,
	}


static func source_battery_placement_state(tile_size: int) -> Dictionary:
	# Blocks.java:2506-2510: battery = new Battery("battery")
	# with consumePowerBuffered(4000f). The battery is the bootstrap
	# world's power storage: the solar panel's surplus (0.12 produced,
	# 0 needed) charges it each frame (PowerGraph.java
	# chargeBatteries), placed on a free size-1 cell east of the panel.
	var world_position := source_world_grid.grid_to_world(source_playable_scenario_defaults.BATTERY_POS, tile_size)
	return {
		"block_id": source_playable_scenario_defaults.BLOCK_BATTERY,
		"role": source_playable_scenario_defaults.INITIAL_BUILD_ROLE_BATTERY,
		"cell": source_playable_scenario_defaults.BATTERY_POS,
		"x": world_position.x,
		"y": world_position.y,
		"power_capacity": 4000.0,
	}


static func source_lancer_placement_state(tile_size: int) -> Dictionary:
	# Blocks.java:3560-3584: lancer = new PowerTurret("lancer")
	# with consumePower(6f) and size = 2. The lancer is the bootstrap
	# world's first real power consumer: it needs 6.0 power against
	# the panel's 0.12 produced, so the graph runs at coverage 0.02
	# (partial power) and the battery stops charging (a deficit, not
	# a surplus). It sits on free cells east of the battery.
	var world_position := source_world_grid.grid_to_world(source_playable_scenario_defaults.LANCER_POS, tile_size)
	return {
		"block_id": source_playable_scenario_defaults.BLOCK_LANCER,
		"role": source_playable_scenario_defaults.INITIAL_BUILD_ROLE_LANCER,
		"cell": source_playable_scenario_defaults.LANCER_POS,
		"x": world_position.x,
		"y": world_position.y,
		"power_usage": 6.0,
	}


static func source_mechanical_pump_placement_state(tile_size: int) -> Dictionary:
	# Blocks.java:2298-2302: mechanicalPump = new Pump("mechanical-pump")
	# with pumpAmount = 7f / 60f and liquidCapacity = 20f. The pump is
	# the bootstrap world's water source (C04): it extracts water from
	# the shallow-water floor (N2084) — size 1 and floating, placed on
	# the water region's north-west corner (5, 14), so its linked tiles
	# include water tiles it can pump from.
	var world_position := source_world_grid.grid_to_world(source_playable_scenario_defaults.PUMP_POS, tile_size)
	return {
		"block_id": source_playable_scenario_defaults.BLOCK_MECHANICAL_PUMP,
		"role": source_playable_scenario_defaults.INITIAL_BUILD_ROLE_MECHANICAL_PUMP,
		"cell": source_playable_scenario_defaults.PUMP_POS,
		"x": world_position.x,
		"y": world_position.y,
		"pump_amount": 7.0 / 60.0,
		"liquid_capacity": 20.0,
	}


static func initial_build_plan_state(drill_cell: Vector2i, conveyor_cells: Array[Vector2i], core_cell: Vector2i, duo_cell: Vector2i, drill_block_id: String, conveyor_block_id: String, core_block_id: String, duo_block_id: String, path_points_input: Array[Vector2], tile_size: int) -> Dictionary:
	var block_placements: Array[Dictionary] = []
	var path_points: Array[Dictionary] = []
	block_placements.append(block_placement_state(drill_block_id, source_playable_scenario_defaults.INITIAL_BUILD_ROLE_DRILL, drill_cell, tile_size))
	for cell in conveyor_cells:
		block_placements.append(block_placement_state(conveyor_block_id, source_playable_scenario_defaults.INITIAL_BUILD_ROLE_CONVEYOR, cell, tile_size))
	block_placements.append(block_placement_state(core_block_id, source_playable_scenario_defaults.INITIAL_BUILD_ROLE_CORE, core_cell, tile_size))
	block_placements.append(block_placement_state(duo_block_id, source_playable_scenario_defaults.INITIAL_BUILD_ROLE_DUO, duo_cell, tile_size))
	var solar_panel := source_solar_panel_placement_state(tile_size)
	block_placements.append(block_placement_state(str(solar_panel.get("block_id", "")), str(solar_panel.get("role", "")), solar_panel.get("cell", Vector2i.ZERO), tile_size))
	var battery := source_battery_placement_state(tile_size)
	block_placements.append(block_placement_state(str(battery.get("block_id", "")), str(battery.get("role", "")), battery.get("cell", Vector2i.ZERO), tile_size))
	var lancer := source_lancer_placement_state(tile_size)
	block_placements.append(block_placement_state(str(lancer.get("block_id", "")), str(lancer.get("role", "")), lancer.get("cell", Vector2i.ZERO), tile_size))
	var pump := source_mechanical_pump_placement_state(tile_size)
	block_placements.append(block_placement_state(str(pump.get("block_id", "")), str(pump.get("role", "")), pump.get("cell", Vector2i.ZERO), tile_size))
	for point in path_points_input:
		var path_point := {}
		path_point[KEY_X] = point.x
		path_point[KEY_Y] = point.y
		path_points.append(path_point)
	var state := {}
	state[KEY_BLOCK_PLACEMENTS] = block_placements
	state[KEY_PATH_POINTS] = path_points
	state[KEY_BLOCK_COUNT] = block_placements.size()
	state[KEY_CONVEYOR_COUNT] = conveyor_cells.size()
	state[KEY_PATH_POINT_COUNT] = path_points.size()
	state[KEY_SOURCE_OWNER] = source_runtime_owner_registry.PORT_GAME_SOURCE_WORLD_INITIAL_BUILD_RUNTIME_STATE
	return state

static func campaign_map_initial_build_plan_state(campaign_map_tile_state: Dictionary, tile_size: int) -> Dictionary:
	var block_placements: Array[Dictionary] = []
	var path_points: Array[Dictionary] = []
	for block_placement in campaign_map_tile_state.get(KEY_BLOCK_PLACEMENTS, []):
		if not (block_placement is Dictionary):
			continue
		var cell_state: Dictionary = block_placement.get(KEY_CELL, {})
		block_placements.append(block_placement_state(
			str(block_placement.get(KEY_KEY, "")),
			str(block_placement.get(KEY_ROLE, "campaign_block")),
			Vector2i(int(cell_state.get(KEY_X, 0)), int(cell_state.get(KEY_Y, 0))),
			tile_size
		))
	for point in source_playable_scenario_defaults.path_points(tile_size):
		var path_point := {}
		path_point[KEY_X] = point.x
		path_point[KEY_Y] = point.y
		path_points.append(path_point)
	var state := {}
	state[KEY_BLOCK_PLACEMENTS] = block_placements
	state[KEY_PATH_POINTS] = path_points
	state[KEY_BLOCK_COUNT] = block_placements.size()
	state[KEY_CONVEYOR_COUNT] = 0
	state[KEY_PATH_POINT_COUNT] = path_points.size()
	state[KEY_CAMPAIGN_MAP_BLOCK_PLACEMENT_COUNT] = int(campaign_map_tile_state.get("block_placement_count", 0))
	state[KEY_CAMPAIGN_MAP_BLOCK_PLACEMENT_NAME_COUNTS] = campaign_map_tile_state.get("block_placement_name_counts", {})
	var campaign_block_layer_state: Dictionary = source_campaign_block_layer_runtime_state.campaign_block_layer_plan_state(campaign_map_tile_state)
	state[KEY_STATIC_BLOCK_BATCHES] = campaign_block_layer_state.get(KEY_STATIC_BLOCK_BATCHES, [])
	state[KEY_DYNAMIC_BLOCK_PLACEMENTS] = campaign_block_layer_state.get(KEY_DYNAMIC_BLOCK_PLACEMENTS, [])
	state["static_block_count"] = int(campaign_block_layer_state.get("static_block_count", 0))
	state["dynamic_block_count"] = int(campaign_block_layer_state.get("dynamic_block_count", 0))
	state["static_block_batch_count"] = int(campaign_block_layer_state.get("static_block_batch_count", 0))
	state["dynamic_block_name_counts"] = campaign_block_layer_state.get("dynamic_block_name_counts", {})
	state[KEY_SOURCE_OWNER] = source_runtime_owner_registry.PORT_GAME_SOURCE_WORLD_INITIAL_BUILD_RUNTIME_STATE
	return state

static func game_initial_build_plan_state(game: Object) -> Dictionary:
	var state := initial_build_plan_state(game.get(PROP_DRILL_POS), source_playable_scenario_defaults.conveyor_cells(), game.get("core_pos"), game.get("duo_pos"), source_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL, source_playable_scenario_defaults.BLOCK_CONVEYOR, source_playable_scenario_defaults.BLOCK_CORE_SHARD, source_playable_scenario_defaults.BLOCK_DUO, game_path_points(game), int(game.get("tile_size")))
	var campaign_map_tile_state := {}
	if game.has_method(METHOD_SOURCE_CAMPAIGN_MAP_TILE_STATE):
		campaign_map_tile_state = game.call(METHOD_SOURCE_CAMPAIGN_MAP_TILE_STATE)
		if bool(campaign_map_tile_state.get("map_region_consumed", false)) and int(campaign_map_tile_state.get("block_placement_count", 0)) > 0:
			state = campaign_map_initial_build_plan_state(campaign_map_tile_state, int(game.get("tile_size")))
	if game.has_method(METHOD_SOURCE_CAMPAIGN_LAUNCH_CONTEXT_STATE):
		state[KEY_CAMPAIGN_LAUNCH_CONTEXT] = game.call(METHOD_SOURCE_CAMPAIGN_LAUNCH_CONTEXT_STATE)
	if game.has_method(METHOD_SOURCE_CAMPAIGN_MAP_FILE_STATE):
		state[KEY_CAMPAIGN_MAP_FILE] = game.call(METHOD_SOURCE_CAMPAIGN_MAP_FILE_STATE)
	if game.has_method(METHOD_SOURCE_CAMPAIGN_MAP_CONTENT_HEADER_STATE):
		state[KEY_CAMPAIGN_MAP_CONTENT_HEADER] = game.call(METHOD_SOURCE_CAMPAIGN_MAP_CONTENT_HEADER_STATE)
	if game.has_method(METHOD_SOURCE_CAMPAIGN_MAP_TILE_STATE):
		state[KEY_CAMPAIGN_MAP_TILE] = campaign_map_tile_state
	return state

static func game_path_points(game: Object) -> Array[Vector2]:
	return source_playable_scenario_defaults.path_points(int(game.get("tile_size")))

static func build_block_layer(game: Object, blocks: Node, initial_build_state: Dictionary) -> void:
	for static_batch in initial_build_state.get(KEY_STATIC_BLOCK_BATCHES, []):
		if not (static_batch is Dictionary):
			continue
		game.call(METHOD_ADD_SOURCE_BLOCK_BATCH, blocks, str(static_batch.get(KEY_KEY, "")), static_batch.get("cells", []))
	for block_placement in initial_build_state.get(KEY_DYNAMIC_BLOCK_PLACEMENTS, initial_build_state.get(KEY_BLOCK_PLACEMENTS, [])):
		game.call(METHOD_ADD_SOURCE_BLOCK, blocks, str(block_placement.get(KEY_KEY, "")), Vector2i(int(block_placement.get(KEY_CELL, {}).get(KEY_X, 0)), int(block_placement.get(KEY_CELL, {}).get(KEY_Y, 0))))

static func build_terrain_layer(game: Object, terrain: Node, terrain_state: Dictionary) -> Dictionary:
	var terrain_layer_state: Dictionary = source_campaign_terrain_layer_runtime_state.campaign_terrain_layer_plan_state(terrain_state)
	for terrain_batch in terrain_layer_state.get(KEY_TERRAIN_BATCHES, []):
		if terrain_batch is Dictionary:
			game.call(METHOD_ADD_SOURCE_TILE_BATCH, terrain, str(terrain_batch.get(KEY_KEY, "")), terrain_batch.get("cells", []))
	for ore_batch in terrain_layer_state.get(KEY_ORE_BATCHES, []):
		if ore_batch is Dictionary:
			game.call(METHOD_ADD_SOURCE_TILE_BATCH, terrain, str(ore_batch.get(KEY_KEY, "")), ore_batch.get("cells", []))
	return terrain_layer_state

static func build_world(game) -> void:
	var terrain = game.get_node(NODE_PATH_WORLD_TERRAIN_LAYER)
	var blocks = game.get_node(NODE_PATH_WORLD_BLOCK_LAYER)
	var units = game.get_node(NODE_PATH_WORLD_UNIT_LAYER)
	var placed_block_origins: Dictionary = game.get(PROP_PLACED_BLOCK_ORIGINS)
	var placed_blocks: Dictionary = game.get(PROP_PLACED_BLOCKS)
	var path_points: Array = game.get(PROP_PATH_POINTS)
	var terrain_state: Dictionary = game.call(METHOD_SOURCE_WORLD_TERRAIN_RUNTIME_STATE)
	game.set(PROP_ORE_ITEMS_BY_CELL, terrain_state.get(PROP_ORE_ITEMS_BY_CELL, {}).duplicate(true))
	var drill_ore_cell_count := int(game.call(METHOD_SOURCE_DRILL_ORE_COUNT, source_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL, game.get(PROP_DRILL_POS), game.get(PROP_DRILL_OUTPUT_ITEM_ID)))
	game.set(PROP_DRILL_ORE_CELL_COUNT, drill_ore_cell_count)
	game.set(PROP_DRILL_OUTPUT_RATE, float(game.call(METHOD_SOURCE_DRILL_OUTPUT_RATE, source_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL, game.get(PROP_DRILL_OUTPUT_ITEM_ID), drill_ore_cell_count)))
	build_terrain_layer(game, terrain, terrain_state)
	var initial_build_state: Dictionary = game.call(METHOD_SOURCE_WORLD_INITIAL_BUILD_RUNTIME_STATE)
	game.set("source_item_catalog", SourceContentRegistryRuntimeState.source_item_catalog_state(game.get("content_catalog")))
	game.set("source_world_tiles", source_world_terrain_runtime_state.source_game_world_tiles_state(game, initial_build_state))
	build_block_layer(game, blocks, initial_build_state)
	path_points.clear()
	for path_point in initial_build_state.get(KEY_PATH_POINTS, []):
		path_points.append(Vector2(float(path_point.get(KEY_X, 0.0)), float(path_point.get(KEY_Y, 0.0))))
	var item_transport_bootstrap_state: Dictionary = game.call(METHOD_SOURCE_ITEM_TRANSPORT_BOOTSTRAP_STATE)
	for item_sprite_state in item_transport_bootstrap_state.get(KEY_ITEM_SPRITES, []):
		var sprite = game.call(METHOD_ADD_SPRITE, units, str(item_sprite_state.get(KEY_KEY, "")), Vector2(float(item_sprite_state.get(KEY_X, 0.0)), float(item_sprite_state.get(KEY_Y, 0.0))))
		sprite.visible = bool(item_sprite_state.get(KEY_VISIBLE, false))
	var core_max_health := float(game.call(METHOD_SOURCE_BLOCK_HEALTH, source_playable_scenario_defaults.BLOCK_CORE_SHARD))
	game.set(PROP_CORE_MAX_HEALTH, core_max_health)
	game.set(PROP_CORE_HEALTH, core_max_health)
	game.set(PROP_CORE_ITEM_CAPACITY, int(game.call(METHOD_SOURCE_BLOCK_ITEM_CAPACITY, source_playable_scenario_defaults.BLOCK_CORE_SHARD)))
	game.set(PROP_CONVEYOR_WORLD_SPEED, float(game.call(METHOD_SOURCE_CONVEYOR_WORLD_SPEED, source_playable_scenario_defaults.BLOCK_CONVEYOR)))
	game.set(PROP_CONVEYOR_PATH_PROGRESS_RATE, float(game.call(METHOD_SOURCE_CONVEYOR_PATH_PROGRESS_RATE, source_playable_scenario_defaults.BLOCK_CONVEYOR)))
	game.set(PROP_BOOTSTRAPPED_SELECTED_TURRET_AMMO_LOAD_COUNT, game.call(METHOD_BOOTSTRAP_SELECTED_TURRET_AMMO))
	game.set(PROP_INITIAL_WORLD_BLOCK_COUNT, placed_block_origins.size())
	game.set(PROP_INITIAL_OCCUPIED_CELL_COUNT, placed_blocks.size())
