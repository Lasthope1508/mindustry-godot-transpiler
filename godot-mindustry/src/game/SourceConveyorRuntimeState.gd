extends RefCounted
class_name SourceConveyorRuntimeState

const SourceBlockMetadataState := preload("res://src/game/SourceBlockMetadataState.gd")
const SourceFactoryDefaults := preload("res://src/game/SourceFactoryDefaults.gd")

const SOURCE_CONVEYOR_WORLD_SPEED_SOURCE := "core/src/mindustry/world/blocks/distribution/Conveyor.java"
const SOURCE_CONVEYOR_TILE_SPEED_SCALE := SourceFactoryDefaults.CONVEYOR_TILE_SPEED_SCALE

const SOURCE_CONVEYOR_WORLD_SPEED_SPEED_FIELD := "public float speed = 0f;"
const SOURCE_CONVEYOR_WORLD_SPEED_UNIT_WORLD_SPEED := "float mspeed = speed * tilesize * 55f;"
const SOURCE_CONVEYOR_WORLD_SPEED_UNIT_IMPULSE := "unit.impulse((tx * mspeed + centerx) * delta(), (ty * mspeed + centery) * delta());"
const SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_COMMENT := "/** size of tiles in units */"
const SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_FIELD := "public static final int tilesize = 8;"
const SOURCE_CONVEYOR_WORLD_SPEED_KEY := "speed"
const SOURCE_CONVEYOR_WORLD_SPEED_TILE_SPEED_SCALE := SourceFactoryDefaults.CONVEYOR_TILE_SPEED_SCALE

const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_SPEED_FIELD := "public float speed = 0f;"
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_UNIT_WORLD_SPEED := "float mspeed = speed * tilesize * 55f;"
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_ITEM_POSITIONS := "public float[] xs = new float[capacity], ys = new float[capacity];"
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_MOVED := "float moved = speed * edelta();"
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_YS_ADD := "ys[i] += maxmove;"
const SOURCE_CONVEYOR_PATH_PROGRESS_RATE_PASS_THRESHOLD := "if(ys[i] >= 1f && pass(ids[i])){"

const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_SPEED_FIELD := "public float speed = 0f;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_MOVED := "float moved = speed * edelta();"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_MAXMOVE := "float maxmove = Mathf.clamp(nextpos - ys[i], 0, moved);"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_YS_ADD := "ys[i] += maxmove;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_EDELTA_METHOD := "public float edelta(){"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_EDELTA_RETURN := "return efficiency * delta();"

const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_FIELD := "transient Tile tile;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_BLOCK_FIELD := "transient Block block;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_X := "return tile.x;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TILE_Y := "return tile.y;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_FIELD := "private transient float timeScale = 1f, timeScaleDuration;"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_METHOD := "public float timeScale(){"
const SOURCE_CONVEYOR_PATH_PROGRESS_DELTA_FOR_CELL_TIME_SCALE_RETURN := "return timeScale;"

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"edelta_provider": Callable(game, "source_building_edelta"),
	}

static func world_speed(block_id: String, tile_size: float, content_catalog) -> float:
	return SourceBlockMetadataState.block_conveyor_world_speed(block_id, tile_size, content_catalog)

static func path_progress_rate(block_id: String, path_point_count: int, tile_size: float, content_catalog) -> float:
	if path_point_count < 2:
		return 0.0
	var path_length := float(max(1, path_point_count - 1) * tile_size)
	return world_speed(block_id, tile_size, content_catalog) / path_length

static func path_progress_delta(block_id: String, seconds: float, path_point_count: int, tile_size: float, source_tick_rate: float, content_catalog, time_scale := 1.0, efficiency := 1.0, edelta_provider := Callable()) -> float:
	if source_tick_rate == 0.0:
		return 0.0
	var scaled_source_delta: float = edelta_provider.call(seconds * source_tick_rate, time_scale, efficiency) if edelta_provider.is_valid() else seconds * source_tick_rate * time_scale * efficiency
	return path_progress_rate(block_id, path_point_count, tile_size, content_catalog) * scaled_source_delta / source_tick_rate
