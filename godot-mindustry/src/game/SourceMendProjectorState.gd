extends RefCounted
class_name SourceMendProjectorState

const source_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")
const source_mend_projector_display_state := preload("res://src/game/SourceMendProjectorDisplayState.gd")
const source_mend_projector_runtime_state := preload("res://src/game/SourceMendProjectorRuntimeState.gd")
const source_mend_projector_source_text_state := preload("res://src/game/SourceMendProjectorSourceTextState.gd")

const SOURCE_MEND_PROJECTOR_REPAIR_HEAL_CALL := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_REPAIR_HEAL_CALL
const SOURCE_MEND_PROJECTOR_REPAIR_FORMULA := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_REPAIR_FORMULA
const SOURCE_MEND_PROJECTOR_REPAIR_MAX_HEALTH := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_REPAIR_MAX_HEALTH
const SOURCE_MEND_PROJECTOR_REPAIR_HEAL_PERCENT_FIELD := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_REPAIR_HEAL_PERCENT_FIELD
const SOURCE_MEND_PROJECTOR_REPAIR_PHASE_BOOST_FIELD := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_REPAIR_PHASE_BOOST_FIELD

const SOURCE_MEND_PROJECTOR_PROGRESS_METHOD := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_PROGRESS_METHOD
const SOURCE_MEND_PROJECTOR_PROGRESS_SENSOR_GATE := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_PROGRESS_SENSOR_GATE
const SOURCE_MEND_PROJECTOR_PROGRESS_CLAMP_EXPR := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_PROGRESS_CLAMP_EXPR
const SOURCE_MEND_PROJECTOR_PROGRESS_RATIO_EXPR := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_PROGRESS_RATIO_EXPR
const SOURCE_MEND_PROJECTOR_PROGRESS_SUPER_SENSE := source_mend_projector_source_text_state.SOURCE_MEND_PROJECTOR_PROGRESS_SUPER_SENSE

static func repair_amount(mend_projector, target_block, phase_heat := 0.0, efficiency := 1.0) -> float:
	var properties := source_block_metadata_state.block_properties(mend_projector)
	var heal_percent := float(properties.get("healPercent", source_projector_defaults.MEND_HEAL_PERCENT_DEFAULT))
	var phase_boost := float(properties.get("phaseBoost", source_projector_defaults.MEND_PHASE_BOOST_DEFAULT))
	var target_health_value := source_block_metadata_state.block_health_value(target_block)
	return target_health_value * (heal_percent + phase_heat * phase_boost) / source_projector_defaults.PROJECTOR_HEAL_PERCENT_DIVISOR * efficiency

static func projector_reload(mend_projector) -> float:
	var properties := source_block_metadata_state.block_properties(mend_projector)
	return float(properties.get("reload", source_projector_defaults.MEND_RELOAD_DEFAULT))

static func use_time(mend_projector) -> float:
	var properties := source_block_metadata_state.block_properties(mend_projector)
	return float(properties.get("boosterUseTime", source_projector_defaults.MEND_USE_TIME_DEFAULT))

static func progress(mend_projector, charge: float) -> float:
	var reload_value := projector_reload(mend_projector)
	if reload_value <= 0.0:
		return 0.0
	return clamp(charge / reload_value, 0.0, 1.0)

static func projector_range(mend_projector, phase_heat := 0.0) -> float:
	return source_mend_projector_display_state.projector_range(mend_projector, phase_heat)

static func select_state(mend_projector, phase_heat := 0.0) -> Dictionary:
	return source_mend_projector_display_state.select_state(mend_projector, phase_heat)

static func place_state(mend_projector) -> Dictionary:
	return source_mend_projector_display_state.place_state(mend_projector)

static func light_state(mend_projector, smooth_efficiency: float) -> Dictionary:
	return source_mend_projector_display_state.light_state(mend_projector, smooth_efficiency)

static func projector_block_size(mend_projector) -> int:
	return source_mend_projector_display_state.projector_block_size(mend_projector)

static func draw_state(mend_projector, heat: float, phase_heat: float, tile_size: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	return source_mend_projector_display_state.draw_state(mend_projector, heat, phase_heat, tile_size, source_time_ticks, lod_l2, lod_alpha2)

static func target_health(sprite) -> float:
	return source_mend_projector_runtime_state.target_health(sprite)

static func target_max_health(sprite) -> float:
	return source_mend_projector_runtime_state.target_max_health(sprite)

static func capture_heal_result(target, healed_amount: float) -> Dictionary:
	return source_mend_projector_runtime_state.capture_heal_result(target, healed_amount)

static func heal_application_state(healed_state: Dictionary, healed := true) -> Dictionary:
	return source_mend_projector_runtime_state.heal_application_state(healed_state, healed)

static func find_damaged_block_in_range(game: Object, mend_cell: Vector2i, mend_projector, phase_heat := 0.0):
	return source_mend_projector_runtime_state.find_damaged_block_in_range(game, mend_cell, mend_projector, phase_heat)

static func heal_application_context(game, sprite, block, runtime_step: Dictionary) -> Dictionary:
	return source_mend_projector_runtime_state.heal_application_context(game, sprite, block, runtime_step)

static func state_value(sprite, state: Dictionary, default_value: float) -> float:
	return source_mend_projector_runtime_state.state_value(sprite, state, default_value)

static func phase_heat_at_cell(game: Object, x: int, y: int) -> float:
	return source_mend_projector_runtime_state.phase_heat_at_cell(game, x, y)

static func smooth_efficiency_at_cell(game: Object, x: int, y: int) -> float:
	return source_mend_projector_runtime_state.smooth_efficiency_at_cell(game, x, y)

static func heat_at_cell(game: Object, x: int, y: int) -> float:
	return source_mend_projector_runtime_state.heat_at_cell(game, x, y)

static func charge_at_cell(game: Object, x: int, y: int) -> float:
	return source_mend_projector_runtime_state.charge_at_cell(game, x, y)

static func progress_at_cell(game: Object, x: int, y: int) -> float:
	return source_mend_projector_runtime_state.progress_at_cell(game, x, y)

static func light_state_at_cell(game: Object, x: int, y: int) -> Dictionary:
	return source_mend_projector_runtime_state.light_state_at_cell(game, x, y)

static func select_state_at_cell(game: Object, x: int, y: int) -> Dictionary:
	return source_mend_projector_runtime_state.select_state_at_cell(game, x, y)

static func draw_state_at_cell(game: Object, x: int, y: int, source_time_ticks := 0.0, tile_size := 0.0) -> Dictionary:
	return source_mend_projector_runtime_state.draw_state_at_cell(game, x, y, source_time_ticks, tile_size)

static func state_at_cell(game: Object, x: int, y: int) -> Dictionary:
	return source_mend_projector_runtime_state.state_at_cell(game, x, y)

static func capture_state(sprite, heat: Dictionary, smooth_efficiency: Dictionary, phase_heat: Dictionary, charge: Dictionary) -> Dictionary:
	return source_mend_projector_runtime_state.capture_state(sprite, heat, smooth_efficiency, phase_heat, charge)

static func runtime_step_state(current_state: Dictionary, source_delta: float, booster_items: int, use_time_value: float, reload_value: float) -> Dictionary:
	return source_mend_projector_runtime_state.runtime_step_state(current_state, source_delta, booster_items, use_time_value, reload_value)

static func runtime_step_context(game, key: String, block, source_delta: float) -> Dictionary:
	return source_mend_projector_runtime_state.runtime_step_context(game, key, block, source_delta)

static func runtime_step_from_context(context: Dictionary) -> Dictionary:
	return source_mend_projector_runtime_state.runtime_step_from_context(context)

static func simulate_projectors(game, delta: float) -> void:
	source_mend_projector_runtime_state.simulate_projectors(game, delta)

static func first_projector_state(game, key: String) -> Dictionary:
	return source_mend_projector_runtime_state.first_projector_state(game, key)

static func step_projectors(game, seconds: float) -> Dictionary:
	return source_mend_projector_runtime_state.step_projectors(game, seconds)

static func _cell_from_key(key: String) -> Vector2i:
	return source_mend_projector_runtime_state._cell_from_key(key)

static func _state_dict(game: Object, property_name: String) -> Dictionary:
	return source_mend_projector_runtime_state._state_dict(game, property_name)

static func _vector2i_game_property(game: Object, property_name: String, default_value := Vector2i.ZERO) -> Vector2i:
	return source_mend_projector_runtime_state._vector2i_game_property(game, property_name, default_value)

static func _sprite_at_cell(game: Object, x: int, y: int):
	return source_mend_projector_runtime_state._sprite_at_cell(game, x, y)

static func _block_from_sprite(game: Object, sprite):
	return source_mend_projector_runtime_state._block_from_sprite(game, sprite)

static func _is_mend_projector(game: Object, block) -> bool:
	return source_mend_projector_runtime_state._is_mend_projector(game, block)
