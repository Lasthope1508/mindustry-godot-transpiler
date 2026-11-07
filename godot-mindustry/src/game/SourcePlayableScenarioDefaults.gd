extends RefCounted
class_name SourcePlayableScenarioDefaults

const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const display_profile_runtime_script := preload("res://src/game/DisplayProfileRuntime.gd")
const source_playable_world_layout_defaults := preload("res://src/game/SourcePlayableWorldLayoutDefaults.gd")
const source_playable_content_defaults := preload("res://src/game/SourcePlayableContentDefaults.gd")
const source_world_grid := preload("res://src/game/SourceWorldGrid.gd")

const WORLD_SIZE := source_playable_world_layout_defaults.WORLD_SIZE
const WORLD_BACKGROUND_MIN_CELLS := source_playable_world_layout_defaults.WORLD_BACKGROUND_MIN_CELLS
const ORE_COPPER_MIN := source_playable_world_layout_defaults.ORE_COPPER_MIN
const ORE_COPPER_MAX := source_playable_world_layout_defaults.ORE_COPPER_MAX
const DRILL_POS := source_playable_world_layout_defaults.DRILL_POS
const CORE_POS := source_playable_world_layout_defaults.CORE_POS
const DUO_POS := source_playable_world_layout_defaults.DUO_POS

const ITEM_COPPER := source_playable_content_defaults.ITEM_COPPER
const BLOCK_STONE_FLOOR := source_playable_content_defaults.BLOCK_STONE_FLOOR
const BLOCK_ORE_COPPER := source_playable_content_defaults.BLOCK_ORE_COPPER
const BLOCK_MECHANICAL_DRILL := source_playable_content_defaults.BLOCK_MECHANICAL_DRILL
const BLOCK_CONVEYOR := source_playable_content_defaults.BLOCK_CONVEYOR
const BLOCK_ROUTER := source_playable_content_defaults.BLOCK_ROUTER
const BLOCK_JUNCTION := source_playable_content_defaults.BLOCK_JUNCTION
const BLOCK_CORE_SHARD := source_playable_content_defaults.BLOCK_CORE_SHARD
const BLOCK_DUO := source_playable_content_defaults.BLOCK_DUO
const BLOCK_COPPER_WALL := source_playable_content_defaults.BLOCK_COPPER_WALL
const INITIAL_BUILD_ROLE_DRILL := "drill"
const INITIAL_BUILD_ROLE_CONVEYOR := "conveyor"
const INITIAL_BUILD_ROLE_CORE := "core"
const INITIAL_BUILD_ROLE_DUO := "duo"
const PLAYABLE_WAVE_SPACING_SECONDS := 3.0
const ENEMY_CORE_IMPACT_RADIUS_TILE_FRACTION := 0.35

static func world_size() -> Vector2i:
	return WORLD_SIZE

static func game_world_size(_game: Object) -> Vector2i:
	return world_size()

static func selected_generated_class_names() -> Array[String]:
	return source_playable_content_defaults.selected_generated_class_names()

static func pinned_build_block_ids() -> Array[String]:
	return source_playable_content_defaults.pinned_build_block_ids()

static func world_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in range(WORLD_SIZE.y):
		for x in range(WORLD_SIZE.x):
			cells.append(Vector2i(x, y))
	return cells


static func background_size() -> Vector2i:
	return display_profile_runtime_for_viewport(Vector2i.ZERO).background_size()

static func display_world_size_for_viewport(viewport_size: Vector2i) -> Vector2i:
	var display_world_size: Vector2i = display_profile_runtime_for_viewport(viewport_size).world_size_cells()
	return Vector2i(maxi(display_world_size.x, WORLD_BACKGROUND_MIN_CELLS.x), maxi(display_world_size.y, WORLD_BACKGROUND_MIN_CELLS.y))


static func display_camera_zoom_for_viewport(viewport_size: Vector2i) -> Vector2:
	var runtime := display_profile_runtime_for_viewport(viewport_size)
	return Vector2(runtime.camera_initial_zoom, runtime.camera_initial_zoom)

static func background_cells() -> Array[Vector2i]:
	return display_profile_runtime_for_viewport(Vector2i.ZERO).background_cells()

static func display_profile_runtime_for_viewport(viewport_size: Vector2i) -> RefCounted:
	var runtime := display_profile_runtime_script.new(source_ssot_accessor_runtime_state)
	if runtime.load():
		runtime.sync_runtime_viewport_size(viewport_size)
		runtime.sync_runtime_camera_zoom(Vector2(runtime.camera_initial_zoom, runtime.camera_initial_zoom))
	return runtime

static func background_cells_for_viewport(viewport_size: Vector2i) -> Array[Vector2i]:
	return display_profile_runtime_for_viewport(viewport_size).background_cells()

static func ore_copper_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in range(ORE_COPPER_MIN.y, ORE_COPPER_MAX.y + 1):
		for x in range(ORE_COPPER_MIN.x, ORE_COPPER_MAX.x + 1):
			cells.append(Vector2i(x, y))
	return cells

static func conveyor_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x in range(DRILL_POS.x + 1, CORE_POS.x):
		cells.append(Vector2i(x, DRILL_POS.y))
	return cells

static func path_points(tile_size: int) -> Array[Vector2]:
	var points: Array[Vector2] = []
	points.append(source_world_grid.grid_to_world(DRILL_POS, tile_size))
	for cell in conveyor_cells():
		points.append(source_world_grid.grid_to_world(cell, tile_size))
	return points

static func enemy_spawn_cell(index: int) -> Vector2i:
	var lane := clampi(index % max(1, WORLD_SIZE.y - 4), 0, WORLD_SIZE.y - 1)
	return Vector2i(0, lane + 2)

static func cell_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < WORLD_SIZE.x and cell.y < WORLD_SIZE.y
