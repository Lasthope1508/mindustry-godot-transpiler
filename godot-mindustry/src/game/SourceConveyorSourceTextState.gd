extends RefCounted
class_name SourceConveyorSourceTextState

const source_world_source_text_state := preload("res://src/game/SourceWorldSourceTextState.gd")

const SOURCE_CONVEYOR_WORLD_SPEED_SOURCE := "core/src/mindustry/world/blocks/distribution/Conveyor.java"
const SOURCE_CONVEYOR_WORLD_SPEED_SPEED_FIELD := "public float speed = 0f;"
const SOURCE_CONVEYOR_WORLD_SPEED_UNIT_WORLD_SPEED := "float mspeed = speed * tilesize * 55f;"
const SOURCE_CONVEYOR_WORLD_SPEED_UNIT_IMPULSE := "unit.impulse((tx * mspeed + centerx) * delta(), (ty * mspeed + centery) * delta());"
const SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_COMMENT := "/** size of tiles in units */"
const SOURCE_CONVEYOR_WORLD_SPEED_TILESIZE_FIELD := source_world_source_text_state.SOURCE_TILESIZE_FIELD
const SOURCE_CONVEYOR_WORLD_SPEED_KEY := "speed"
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
const SOURCE_CONVEYOR_EDELTA_PROVIDER_KEY := "edelta_provider"
const SOURCE_CONVEYOR_EDELTA_PROVIDER_FALLBACK := "source_building_edelta"
