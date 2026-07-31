extends RefCounted
class_name SourcePlacedBlockState

const source_world_grid := preload("res://src/game/SourceWorldGrid.gd")
const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_texture_runtime_state := preload("res://src/game/SourceTextureRuntimeState.gd")

const SOURCE_BLOCK_ID_META_KEY := "source_block_id"
const SOURCE_BLOCK_MAX_HEALTH_META_KEY := "source_block_max_health"
const SOURCE_BLOCK_HEALTH_META_KEY := "source_block_health"
const SOURCE_BLOCK_TIME_SCALE_META_KEY := "source_block_time_scale"
const SOURCE_BLOCK_TIME_SCALE_DURATION_META_KEY := "source_block_time_scale_duration"
const SOURCE_BLOCK_CELL_KEY_META_KEY := "source_block_cell_key"
const SOURCE_PLACED_BLOCK_TIME_SCALE_DECAY_METHOD_KEY := "time_scale_decay"
const SOURCE_PLACED_BLOCK_TIME_SCALE_AT_CELL_METHOD_KEY := "time_scale_at_cell"
const SOURCE_PLACED_BLOCK_TIME_SCALE_DURATION_AT_CELL_METHOD_KEY := "time_scale_duration_at_cell"
const SOURCE_PLACED_BLOCK_TIME_SCALE_DECAY_METHOD_FALLBACK := "source_building_time_scale_decay_state"
const SOURCE_PLACED_BLOCK_TIME_SCALE_AT_CELL_METHOD_FALLBACK := "source_block_time_scale_at_cell"
const SOURCE_PLACED_BLOCK_TIME_SCALE_DURATION_AT_CELL_METHOD_FALLBACK := "source_block_time_scale_duration_at_cell"

static func runtime_method_names(game: Object) -> Dictionary:
	if game == null:
		return {}
	if game.has_method("_placed_block_state_method_names"):
		var names = game.call("_placed_block_state_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return str(method_names.get(key, fallback_name))

static func properties(block) -> Dictionary:
	return source_block_metadata_state.block_properties(block)

static func initialize_sprite(sprite: Sprite2D, block, cell: Vector2i, occupied_cell_keys: Array[String], _default_health: float, default_time_scale: float) -> void:
	if not is_instance_valid(sprite):
		return
	if block != null:
		sprite.set_meta(SOURCE_BLOCK_ID_META_KEY, block.id)
	var source_health := source_block_metadata_state.block_health_value(block)
	if source_health < 0.0:
		source_health = _default_health
	sprite.set_meta(SOURCE_BLOCK_MAX_HEALTH_META_KEY, source_health)
	sprite.set_meta(SOURCE_BLOCK_HEALTH_META_KEY, source_health)
	sprite.set_meta(SOURCE_BLOCK_TIME_SCALE_META_KEY, default_time_scale)
	sprite.set_meta(SOURCE_BLOCK_TIME_SCALE_DURATION_META_KEY, 0.0)
	sprite.set_meta("occupied_cells", occupied_cell_keys)
	sprite.set_meta("origin_cell", cell)
	sprite.set_meta(SOURCE_BLOCK_CELL_KEY_META_KEY, source_world_grid.cell_key(cell))

static func health(sprite) -> float:
	if not is_instance_valid(sprite):
		return 0.0
	return float(sprite.get_meta(SOURCE_BLOCK_HEALTH_META_KEY, 0.0))

static func game_health_at_cell(game: Object, x: int, y: int) -> float:
	var sprite = source_texture_runtime_state.game_sprite_at_cell(game, x, y)
	return health(sprite)

static func damaged(sprite, damaged_epsilon: float) -> bool:
	if not is_instance_valid(sprite):
		return false
	return float(sprite.get_meta(SOURCE_BLOCK_HEALTH_META_KEY, 0.0)) < float(sprite.get_meta(SOURCE_BLOCK_MAX_HEALTH_META_KEY, 0.0)) - damaged_epsilon

static func damage_sprite(sprite, amount: float) -> float:
	if not is_instance_valid(sprite):
		return 0.0
	sprite.set_meta(SOURCE_BLOCK_HEALTH_META_KEY, max(0.0, float(sprite.get_meta(SOURCE_BLOCK_HEALTH_META_KEY, 0.0)) - amount))
	return float(sprite.get_meta(SOURCE_BLOCK_HEALTH_META_KEY, 0.0))

static func game_damage_at_cell(game: Object, x: int, y: int, amount: float) -> float:
	var sprite = source_texture_runtime_state.game_sprite_at_cell(game, x, y)
	return damage_sprite(sprite, amount)

static func repair_sprite(sprite, amount: float) -> float:
	if not is_instance_valid(sprite):
		return 0.0
	var before := float(sprite.get_meta(SOURCE_BLOCK_HEALTH_META_KEY, 0.0))
	var after: float = min(float(sprite.get_meta(SOURCE_BLOCK_MAX_HEALTH_META_KEY, 0.0)), before + amount)
	sprite.set_meta(SOURCE_BLOCK_HEALTH_META_KEY, after)
	return after - before

static func time_scale(sprite, default_time_scale: float) -> float:
	if not is_instance_valid(sprite):
		return default_time_scale
	return float(sprite.get_meta(SOURCE_BLOCK_TIME_SCALE_META_KEY, default_time_scale))

static func game_time_scale_at_cell(game: Object, x: int, y: int, default_time_scale: float) -> float:
	var sprite = source_texture_runtime_state.game_sprite_at_cell(game, x, y)
	return time_scale(sprite, default_time_scale)

static func time_scale_duration(sprite) -> float:
	if not is_instance_valid(sprite):
		return 0.0
	return float(sprite.get_meta(SOURCE_BLOCK_TIME_SCALE_DURATION_META_KEY, 0.0))

static func game_time_scale_duration_at_cell(game: Object, x: int, y: int) -> float:
	var sprite = source_texture_runtime_state.game_sprite_at_cell(game, x, y)
	return time_scale_duration(sprite)

static func apply_time_scale_decay(sprite, decay_state: Dictionary, default_time_scale: float) -> void:
	if not is_instance_valid(sprite):
		return
	sprite.set_meta(SOURCE_BLOCK_TIME_SCALE_META_KEY, float(decay_state.get("time_scale", default_time_scale)))
	sprite.set_meta(SOURCE_BLOCK_TIME_SCALE_DURATION_META_KEY, max(0.0, float(decay_state.get("time_scale_duration", 0.0))))

static func decay_time_scale_sprite(game: Object, sprite, source_delta: float, default_time_scale: float) -> void:
	if not is_instance_valid(sprite):
		return
	var method_names := runtime_method_names(game)
	var decay_method := runtime_method_name(method_names, SOURCE_PLACED_BLOCK_TIME_SCALE_DECAY_METHOD_KEY, SOURCE_PLACED_BLOCK_TIME_SCALE_DECAY_METHOD_FALLBACK)
	var result: Dictionary = game.call(decay_method, time_scale(sprite, default_time_scale), time_scale_duration(sprite), source_delta)
	apply_time_scale_decay(sprite, result, default_time_scale)

static func simulate_time_scales(game: Object, source_delta: float, default_time_scale: float) -> void:
	var placed_block_origins_value = game.get("placed_block_origins")
	if not (placed_block_origins_value is Dictionary):
		return
	var placed_block_origins: Dictionary = placed_block_origins_value
	for key in placed_block_origins.keys():
		decay_time_scale_sprite(game, placed_block_origins.get(key), source_delta, default_time_scale)

static func step_time_scales(game: Object, seconds: float, tick_rate: float, default_time_scale: float) -> Dictionary:
	var source_delta := seconds * tick_rate
	simulate_time_scales(game, source_delta, default_time_scale)
	var boosted_cell: Vector2i = game.get("last_overdrive_projector_boosted_cell")
	var method_names := runtime_method_names(game)
	var time_scale_method := runtime_method_name(method_names, SOURCE_PLACED_BLOCK_TIME_SCALE_AT_CELL_METHOD_KEY, SOURCE_PLACED_BLOCK_TIME_SCALE_AT_CELL_METHOD_FALLBACK)
	var duration_method := runtime_method_name(method_names, SOURCE_PLACED_BLOCK_TIME_SCALE_DURATION_AT_CELL_METHOD_KEY, SOURCE_PLACED_BLOCK_TIME_SCALE_DURATION_AT_CELL_METHOD_FALLBACK)
	return {
		"last_overdrive_projector_boosted_block_id": game.get("last_overdrive_projector_boosted_block_id"),
		"last_overdrive_projector_boosted_cell": {"x": boosted_cell.x, "y": boosted_cell.y},
		"time_scale": game.call(time_scale_method, boosted_cell.x, boosted_cell.y),
		"time_scale_duration": game.call(duration_method, boosted_cell.x, boosted_cell.y),
	}
