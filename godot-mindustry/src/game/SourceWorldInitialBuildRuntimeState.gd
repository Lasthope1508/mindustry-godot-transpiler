extends RefCounted
class_name SourceWorldInitialBuildRuntimeState

const source_world_terrain_runtime_state := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")

const source_world_grid := preload("res://src/game/SourceWorldGrid.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const NODE_PATH_WORLD_TERRAIN_LAYER := "World/TerrainLayer"
const NODE_PATH_WORLD_BLOCK_LAYER := "World/BlockLayer"
const NODE_PATH_WORLD_UNIT_LAYER := "World/UnitLayer"
const PROP_PLACED_BLOCK_ORIGINS := "placed_block_origins"
const PROP_PLACED_BLOCKS := "placed_blocks"
const PROP_PATH_POINTS := "path_points"
const PROP_ORE_ITEMS_BY_CELL := "ore_items_by_cell"
const PROP_DRILL_POS := "drill_pos"
const PROP_DRILL_OUTPUT_ITEM_ID := "drill_output_item_id"
const PROP_DRILL_ORE_CELL_COUNT := "drill_ore_cell_count"
const PROP_DRILL_OUTPUT_RATE := "drill_output_rate"
const PROP_CORE_MAX_HEALTH := "core_max_health"
const PROP_CORE_HEALTH := "core_health"
const PROP_CORE_ITEM_CAPACITY := "core_item_capacity"
const PROP_CONVEYOR_WORLD_SPEED := "conveyor_world_speed"
const PROP_CONVEYOR_PATH_PROGRESS_RATE := "conveyor_path_progress_rate"
const PROP_BOOTSTRAPPED_SELECTED_TURRET_AMMO_LOAD_COUNT := "bootstrapped_selected_turret_ammo_load_count"
const PROP_INITIAL_WORLD_BLOCK_COUNT := "initial_world_block_count"
const PROP_INITIAL_OCCUPIED_CELL_COUNT := "initial_occupied_cell_count"
const METHOD_SOURCE_WORLD_TERRAIN_RUNTIME_STATE := "source_world_terrain_runtime_state"
const METHOD_SOURCE_DRILL_ORE_COUNT := "source_drill_ore_count"
const METHOD_SOURCE_DRILL_OUTPUT_RATE := "source_drill_output_rate"
const METHOD_ADD_SPRITE := "add_sprite"
const METHOD_SOURCE_WORLD_INITIAL_BUILD_RUNTIME_STATE := "source_world_initial_build_runtime_state"
const METHOD_ADD_SOURCE_BLOCK := "add_source_block"
const METHOD_SOURCE_ITEM_TRANSPORT_BOOTSTRAP_STATE := "source_item_transport_bootstrap_state"
const METHOD_SOURCE_BLOCK_HEALTH := "source_block_health"
const METHOD_SOURCE_BLOCK_ITEM_CAPACITY := "source_block_item_capacity"
const METHOD_SOURCE_CONVEYOR_WORLD_SPEED := "source_conveyor_world_speed"
const METHOD_SOURCE_CONVEYOR_PATH_PROGRESS_RATE := "source_conveyor_path_progress_rate"
const METHOD_BOOTSTRAP_SELECTED_TURRET_AMMO := "bootstrap_selected_turret_ammo"
const KEY_BLOCK_PLACEMENTS := "block_placements"
const KEY_PATH_POINTS := "path_points"
const KEY_BLOCK_COUNT := "block_count"
const KEY_CONVEYOR_COUNT := "conveyor_count"
const KEY_PATH_POINT_COUNT := "path_point_count"
const KEY_SOURCE_OWNER := "source_owner"
const KEY_KEY := "key"
const KEY_ROLE := "role"
const KEY_CELL := "cell"
const KEY_X := "x"
const KEY_Y := "y"
const KEY_TERRAIN_SPRITES := "terrain_sprites"
const KEY_ORE_SPRITES := "ore_sprites"
const KEY_ITEM_SPRITES := "item_sprites"
const KEY_VISIBLE := "visible"

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


static func initial_build_plan_state(drill_cell: Vector2i, conveyor_cells: Array[Vector2i], core_cell: Vector2i, duo_cell: Vector2i, drill_block_id: String, conveyor_block_id: String, core_block_id: String, duo_block_id: String, path_points_input: Array[Vector2], tile_size: int) -> Dictionary:
	var block_placements: Array[Dictionary] = []
	var path_points: Array[Dictionary] = []
	block_placements.append(block_placement_state(drill_block_id, source_playable_scenario_defaults.INITIAL_BUILD_ROLE_DRILL, drill_cell, tile_size))
	for cell in conveyor_cells:
		block_placements.append(block_placement_state(conveyor_block_id, source_playable_scenario_defaults.INITIAL_BUILD_ROLE_CONVEYOR, cell, tile_size))
	block_placements.append(block_placement_state(core_block_id, source_playable_scenario_defaults.INITIAL_BUILD_ROLE_CORE, core_cell, tile_size))
	block_placements.append(block_placement_state(duo_block_id, source_playable_scenario_defaults.INITIAL_BUILD_ROLE_DUO, duo_cell, tile_size))
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
	for terrain_sprite in terrain_state.get(KEY_TERRAIN_SPRITES, []):
		game.call(METHOD_ADD_SPRITE, terrain, str(terrain_sprite.get(KEY_KEY, "")), Vector2(float(terrain_sprite.get(KEY_X, 0.0)), float(terrain_sprite.get(KEY_Y, 0.0))))
	for ore_sprite in terrain_state.get(KEY_ORE_SPRITES, []):
		game.call(METHOD_ADD_SPRITE, terrain, str(ore_sprite.get(KEY_KEY, "")), Vector2(float(ore_sprite.get(KEY_X, 0.0)), float(ore_sprite.get(KEY_Y, 0.0))))
	var initial_build_state: Dictionary = game.call(METHOD_SOURCE_WORLD_INITIAL_BUILD_RUNTIME_STATE)
	game.set("source_world_tiles", source_world_terrain_runtime_state.source_game_world_tiles_state(game, initial_build_state))
	for block_placement in initial_build_state.get(KEY_BLOCK_PLACEMENTS, []):
		game.call(METHOD_ADD_SOURCE_BLOCK, blocks, str(block_placement.get(KEY_KEY, "")), Vector2i(int(block_placement.get(KEY_CELL, {}).get(KEY_X, 0)), int(block_placement.get(KEY_CELL, {}).get(KEY_Y, 0))))
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
