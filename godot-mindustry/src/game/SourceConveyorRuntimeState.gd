extends RefCounted
class_name SourceConveyorRuntimeState

const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_factory_defaults := preload("res://src/game/SourceFactoryDefaults.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_conveyor_source_text_state := preload("res://src/game/SourceConveyorSourceTextState.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

const SOURCE_CONVEYOR_WORLD_SPEED_SOURCE := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_SOURCE
const SOURCE_CONVEYOR_TILE_SPEED_SCALE := source_factory_defaults.CONVEYOR_TILE_SPEED_SCALE

const SOURCE_CONVEYOR_WORLD_SPEED_SPEED_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_SPEED_FIELD
const SOURCE_CONVEYOR_WORLD_SPEED_UNIT_WORLD_SPEED := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_UNIT_WORLD_SPEED
const SOURCE_CONVEYOR_WORLD_SPEED_UNIT_IMPULSE := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_UNIT_IMPULSE
const SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_COMMENT := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_COMMENT
const SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_FIELD
const SOURCE_CONVEYOR_WORLD_SPEED_KEY := source_conveyor_source_text_state.SOURCE_CONVEYOR_WORLD_SPEED_KEY
const SOURCE_CONVEYOR_WORLD_SPEED_TILE_SPEED_SCALE := source_factory_defaults.CONVEYOR_TILE_SPEED_SCALE

const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_SPEED_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_RATE_SPEED_FIELD
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_UNIT_WORLD_SPEED := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_RATE_UNIT_WORLD_SPEED
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_ITEM_POSITIONS := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_RATE_ITEM_POSITIONS
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_MOVED := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_RATE_MOVED
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_YS_ADD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_RATE_YS_ADD
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_PASS_THRESHOLD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_RATE_PASS_THRESHOLD

const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_SPEED_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_SPEED_FIELD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_MOVED := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_MOVED
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_MAXMOVE := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_MAXMOVE
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_YS_ADD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_YS_ADD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_EDELTA_METHOD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_EDELTA_METHOD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_EDELTA_RETURN := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_EDELTA_RETURN

const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_FIELD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_BLOCK_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_BLOCK_FIELD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_X := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_X
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_Y := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_Y
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_FIELD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_FIELD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_METHOD := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_METHOD
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_RETURN := source_conveyor_source_text_state.SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_RETURN
const SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY := source_conveyor_source_text_state.SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY
const SOURCE_CONVEYOR_EDELTA_PROVIDER_FALLBACK := source_conveyor_source_text_state.SOURCE_CONVEYOR_EDELTA_PROVIDER_FALLBACK

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_conveyor_runtime_method_names"):
		var names = game.call("_conveyor_runtime_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY: Callable(game, runtime_method_name(method_names, SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY, SOURCE_CONVEYOR_EDELTA_PROVIDER_FALLBACK)),
	}

static func game_path_points(game: Object) -> Array:
	var points = game.get("path_points")
	if points is Array:
		return points
	return []

static func world_speed(block_id: String, tile_size: float, content_catalog) -> float:
	return source_block_metadata_state.block_conveyor_world_speed(block_id, tile_size, content_catalog)

static func game_world_speed(game: Object, block_id: String) -> float:
	return world_speed(block_id, int(game.get("tile_size")), game.get("content_catalog"))

static func path_progress_rate(block_id: String, path_point_count: int, tile_size: float, content_catalog) -> float:
	if path_point_count < 2:
		return 0.0
	var path_length := float(max(1, path_point_count - 1) * tile_size)
	return world_speed(block_id, tile_size, content_catalog) / path_length

static func game_path_progress_rate(game: Object, block_id: String) -> float:
	return path_progress_rate(block_id, game_path_points(game).size(), int(game.get("tile_size")), game.get("content_catalog"))

static func path_progress_delta(block_id: String, seconds: float, path_point_count: int, tile_size: float, source_tick_rate: float, content_catalog, time_scale := 1.0, efficiency := 1.0, edelta_provider := Callable()) -> float:
	if source_tick_rate == 0.0:
		return 0.0
	var scaled_source_delta: float = edelta_provider.call(seconds * source_tick_rate, time_scale, efficiency) if edelta_provider.is_valid() else seconds * source_tick_rate * time_scale * efficiency
	return path_progress_rate(block_id, path_point_count, tile_size, content_catalog) * scaled_source_delta / source_tick_rate

static func game_path_progress_delta(game: Object, block_id: String, seconds: float, time_scale := 1.0, efficiency := 1.0) -> float:
	var callbacks := default_callbacks_state(game)
	return path_progress_delta(block_id, seconds, game_path_points(game).size(), int(game.get("tile_size")), source_time_defaults.TICK_RATE, game.get("content_catalog"), time_scale, efficiency, callbacks.get(SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY, Callable()))

static func game_path_progress_delta_for_cell(game: Object, x: int, y: int, seconds: float, efficiency := 1.0) -> float:
	var sprite = source_texture_runtime_state.game_sprite_at_cell(game, x, y)
	if not is_instance_valid(sprite):
		return 0.0
	return game.call("source_conveyor_path_progress_delta", str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, "")), seconds, float(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_TIME_SCALE_META_KEY, source_block_defaults.TIME_SCALE_DEFAULT)), efficiency)
