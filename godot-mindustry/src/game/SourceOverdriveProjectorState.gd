extends RefCounted
class_name SourceOverdriveProjectorState

const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")
const source_overdrive_projector_display_state := preload("res://src/game/SourceOverdriveProjectorDisplayState.gd")
const source_overdrive_projector_runtime_state := preload("res://src/game/SourceOverdriveProjectorRuntimeState.gd")
const source_overdrive_projector_source_text_state := preload("res://src/game/SourceOverdriveProjectorSourceTextState.gd")

const SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_METHOD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_METHOD
const SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_RETURN := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_RETURN
const SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_SPEED_BOOST_FIELD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_SPEED_BOOST_FIELD
const SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_SPEED_BOOST_PHASE_FIELD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_SPEED_BOOST_PHASE_FIELD
const SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_PHASE_HEAT_FIELD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_REAL_BOOST_PHASE_HEAT_FIELD
const SOURCE_OVERDRIVE_PROJECTOR_TARGET_FILTER_BOOST_BRANCH := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_TARGET_FILTER_BOOST_BRANCH
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_METHOD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_METHOD
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_ADD_BAR := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_ADD_BAR
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_REAL_BOOST_CALL := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_REAL_BOOST_CALL
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_DENOMINATOR := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_DENOMINATOR
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_SPEED_BOOST_FIELD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_SPEED_BOOST_FIELD
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_SPEED_BOOST_PHASE_FIELD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_SPEED_BOOST_PHASE_FIELD
const SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_HAS_BOOST_FIELD := source_overdrive_projector_source_text_state.SOURCE_OVERDRIVE_PROJECTOR_BOOST_BAR_HAS_BOOST_FIELD

static func state_value(sprite, state: Dictionary, default_value: float) -> float:
	return source_overdrive_projector_runtime_state.state_value(sprite, state, default_value)

static func game_state_value_at_cell(game: Object, x: int, y: int, state: Dictionary, default_value: float) -> float:
	return source_overdrive_projector_runtime_state.game_state_value_at_cell(game, x, y, state, default_value)

static func capture_state(sprite, heat: Dictionary, smooth_efficiency: Dictionary, phase_heat: Dictionary, charge: Dictionary, use_progress: Dictionary) -> Dictionary:
	return source_overdrive_projector_runtime_state.capture_state(sprite, heat, smooth_efficiency, phase_heat, charge, use_progress)

static func game_capture_state_at_cell(game: Object, x: int, y: int, heat: Dictionary, smooth_efficiency: Dictionary, phase_heat: Dictionary, charge: Dictionary, use_progress: Dictionary) -> Dictionary:
	return source_overdrive_projector_runtime_state.game_capture_state_at_cell(game, x, y, heat, smooth_efficiency, phase_heat, charge, use_progress)

static func game_sprite_at_cell(game: Object, x: int, y: int):
	return source_overdrive_projector_runtime_state.game_sprite_at_cell(game, x, y)

static func game_block_from_sprite(game: Object, sprite):
	return source_overdrive_projector_runtime_state.game_block_from_sprite(game, sprite)

static func projector_block_size(overdrive_projector) -> int:
	return source_overdrive_projector_display_state.projector_block_size(overdrive_projector)

static func projector_reload(overdrive_projector) -> float:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	return float(properties.get("reload", source_projector_defaults.OVERDRIVE_RELOAD_DEFAULT))

static func use_time(overdrive_projector) -> float:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	return float(properties.get("useTime", source_projector_defaults.OVERDRIVE_USE_TIME_DEFAULT))

static func has_boost(overdrive_projector) -> bool:
	var properties := source_block_metadata_state.block_properties(overdrive_projector)
	return bool(properties.get("hasBoost", source_projector_defaults.OVERDRIVE_HAS_BOOST_DEFAULT))

static func projector_range(overdrive_projector, phase_heat := 0.0) -> float:
	return source_overdrive_projector_display_state.projector_range(overdrive_projector, phase_heat)

static func select_state(overdrive_projector, phase_heat := 0.0) -> Dictionary:
	return source_overdrive_projector_display_state.select_state(overdrive_projector, phase_heat)

static func place_state(overdrive_projector) -> Dictionary:
	return source_overdrive_projector_display_state.place_state(overdrive_projector)

static func target_filter_state(overdrive_projector, target_block, distance: float, phase_heat := 0.0) -> Dictionary:
	var real_range := projector_range(overdrive_projector, phase_heat)
	var can_overdrive := source_block_metadata_state.block_can_overdrive(target_block)
	var in_range := distance <= real_range
	return {
		"real_range": real_range,
		"distance": distance,
		"can_overdrive": can_overdrive,
		"in_range": in_range,
		"eligible": in_range and can_overdrive,
	}

static func real_boost(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	return source_overdrive_projector_runtime_state.real_boost(overdrive_projector, phase_heat, efficiency)

static func boost_bar_fraction(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	return source_overdrive_projector_runtime_state.boost_bar_fraction(overdrive_projector, phase_heat, efficiency)

static func light_state(overdrive_projector, smooth_efficiency: float) -> Dictionary:
	return source_overdrive_projector_display_state.light_state(overdrive_projector, smooth_efficiency)

static func game_light_state_at_cell(game: Object, x: int, y: int) -> Dictionary:
	var sprite = game_sprite_at_cell(game, x, y)
	var block = game_block_from_sprite(game, sprite)
	if not bool(game.call("source_overdrive_projector_is_projector", block)):
		return {"color": "", "radius": 0.0, "alpha": 0.0}
	return game.call("source_overdrive_projector_light_state", block, game.call("overdrive_projector_smooth_efficiency_at_cell", x, y))

static func draw_state(overdrive_projector, heat: float, phase_heat: float, tile_size: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	return source_overdrive_projector_display_state.draw_state(overdrive_projector, heat, phase_heat, tile_size, source_time_ticks, lod_l2, lod_alpha2)

static func game_draw_state_at_cell(game: Object, x: int, y: int, source_time_ticks := 0.0) -> Dictionary:
	var sprite = game_sprite_at_cell(game, x, y)
	var block = game_block_from_sprite(game, sprite)
	if not bool(game.call("source_overdrive_projector_is_projector", block)):
		return game.call("source_overdrive_projector_draw_state", null, 0.0, 0.0, source_time_ticks, false, 0.0)
	return game.call("source_overdrive_projector_draw_state", block, game.call("overdrive_projector_heat_at_cell", x, y), game.call("overdrive_projector_phase_heat_at_cell", x, y), source_time_ticks)

static func runtime_step_state(current_state: Dictionary, source_delta: float, booster_items: int, has_boost_value: bool, reload_value: float, use_time_value: float) -> Dictionary:
	return source_overdrive_projector_runtime_state.runtime_step_state(current_state, source_delta, booster_items, has_boost_value, reload_value, use_time_value)

static func runtime_step_context(game, key: String, block, source_delta: float) -> Dictionary:
	return source_overdrive_projector_runtime_state.runtime_step_context(game, key, block, source_delta)

static func runtime_step_from_context(context: Dictionary) -> Dictionary:
	return source_overdrive_projector_runtime_state.runtime_step_from_context(context)

static func boost_application_state(boost_range: float, boost: float, boost_duration: float, boosted_state: Dictionary, applied := true) -> Dictionary:
	return source_overdrive_projector_runtime_state.boost_application_state(boost_range, boost, boost_duration, boosted_state, applied)

static func boost_application_context(game, sprite, block, runtime_step: Dictionary) -> Dictionary:
	return source_overdrive_projector_runtime_state.boost_application_context(game, sprite, block, runtime_step)

static func find_overdrive_boost_target(game, overdrive_cell: Vector2i, overdrive_projector, phase_heat := 0.0):
	return source_overdrive_projector_runtime_state.find_overdrive_boost_target(game, overdrive_cell, overdrive_projector, phase_heat)

static func apply_overdrive_boost_to_sprite(game, target, intensity: float, duration: float) -> Dictionary:
	return source_overdrive_projector_runtime_state.apply_overdrive_boost_to_sprite(game, target, intensity, duration)

static func simulate_projectors(game, delta: float) -> void:
	source_overdrive_projector_runtime_state.simulate_projectors(game, delta)

static func step_projectors(game, seconds: float) -> Dictionary:
	return source_overdrive_projector_runtime_state.step_projectors(game, seconds)

static func _cell_from_key(key: String) -> Vector2i:
	return source_overdrive_projector_runtime_state._cell_from_key(key)

static func _vector2i_game_property(game: Object, property_name: String, default_value := Vector2i.ZERO) -> Vector2i:
	return source_overdrive_projector_runtime_state._vector2i_game_property(game, property_name, default_value)
