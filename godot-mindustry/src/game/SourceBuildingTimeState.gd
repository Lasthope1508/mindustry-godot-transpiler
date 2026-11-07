extends RefCounted
class_name SourceBuildingTimeState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_building_time_source_text_state := preload("res://src/game/SourceBuildingTimeSourceTextState.gd")
const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_TIME_DELTA_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_TIME_DELTA_JAVA_METHOD
const SOURCE_BUILDING_TIME_DELTA_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_TIME_DELTA_GENERATED_OWNER
const SOURCE_BUILDING_TIME_EDELTA_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_TIME_EDELTA_JAVA_METHOD
const SOURCE_BUILDING_TIME_EDELTA_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_TIME_EDELTA_GENERATED_OWNER
const SOURCE_BUILDING_TIME_PROGRESS_INCREASE_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_TIME_PROGRESS_INCREASE_JAVA_METHOD
const SOURCE_BUILDING_TIME_PROGRESS_INCREASE_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_TIME_PROGRESS_INCREASE_GENERATED_OWNER
const SOURCE_BUILDING_TIME_DISPLAY_EFFICIENCY_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_TIME_DISPLAY_EFFICIENCY_JAVA_METHOD
const SOURCE_BUILDING_TIME_DISPLAY_EFFICIENCY_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_TIME_DISPLAY_EFFICIENCY_GENERATED_OWNER
const SOURCE_BUILDING_TIME_SHOULD_AMBIENT_SOUND_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_TIME_SHOULD_AMBIENT_SOUND_JAVA_METHOD
const SOURCE_BUILDING_TIME_SHOULD_AMBIENT_SOUND_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_TIME_SHOULD_AMBIENT_SOUND_GENERATED_OWNER
const SOURCE_BUILDING_TIME_SCALE_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_TIME_SCALE_JAVA_METHOD
const SOURCE_BUILDING_TIME_SCALE_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_TIME_SCALE_GENERATED_OWNER
const SOURCE_BUILDING_TIME_WARMUP_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_TIME_WARMUP_JAVA_METHOD
const SOURCE_BUILDING_TIME_WARMUP_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_TIME_WARMUP_GENERATED_OWNER
const SOURCE_BUILDING_TIME_TOTAL_PROGRESS_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_TIME_TOTAL_PROGRESS_JAVA_METHOD
const SOURCE_BUILDING_TIME_TOTAL_PROGRESS_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_TIME_TOTAL_PROGRESS_GENERATED_OWNER
const SOURCE_BUILDING_TIME_PROGRESS_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_TIME_PROGRESS_JAVA_METHOD
const SOURCE_BUILDING_TIME_PROGRESS_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_TIME_PROGRESS_GENERATED_OWNER
const SOURCE_BUILDING_TIME_WRITE_BASE_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_TIME_WRITE_BASE_JAVA_METHOD
const SOURCE_BUILDING_TIME_WRITE_BASE_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_TIME_WRITE_BASE_GENERATED_OWNER
const SOURCE_BUILDING_TIME_MODULE_BITMASK_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_TIME_MODULE_BITMASK_JAVA_METHOD
const SOURCE_BUILDING_TIME_MODULE_BITMASK_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_TIME_MODULE_BITMASK_GENERATED_OWNER
const SOURCE_BUILDING_TIME_READ_BASE_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_TIME_READ_BASE_JAVA_METHOD
const SOURCE_BUILDING_TIME_READ_BASE_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_TIME_READ_BASE_GENERATED_OWNER
const SOURCE_BUILDING_TIME_UPDATE_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_TIME_UPDATE_JAVA_METHOD
const SOURCE_BUILDING_TIME_UPDATE_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_TIME_UPDATE_GENERATED_OWNER
const SOURCE_BUILDING_APPLY_BOOST_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_APPLY_BOOST_JAVA_METHOD
const SOURCE_BUILDING_APPLY_BOOST_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_APPLY_BOOST_GENERATED_OWNER
const SOURCE_BUILDING_APPLY_SLOWDOWN_JAVA_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_APPLY_SLOWDOWN_JAVA_METHOD
const SOURCE_BUILDING_APPLY_SLOWDOWN_GENERATED_OWNER := source_building_time_source_text_state.SOURCE_BUILDING_APPLY_SLOWDOWN_GENERATED_OWNER
const SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_FIELD := source_building_time_source_text_state.SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_FIELD
const SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_METHOD
const SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_GATE := source_building_time_source_text_state.SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_GATE
const SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_RESET := source_building_time_source_text_state.SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_RESET
const SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_METHOD := source_building_time_source_text_state.SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_METHOD
const SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_GATE := source_building_time_source_text_state.SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_GATE
const SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_LOOP := source_building_time_source_text_state.SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_LOOP
const SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_VOLUME_EXPR := source_building_time_source_text_state.SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_VOLUME_EXPR

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func apply_boost_state(current_time_scale: float, current_duration: float, intensity: float, duration: float, can_overdrive: bool, time_scale_boost_epsilon: float) -> Dictionary:
	var result := {"time_scale": current_time_scale, "time_scale_duration": current_duration, "applied": false, "can_overdrive": can_overdrive}
	if not can_overdrive:
		return result
	if intensity >= current_time_scale - time_scale_boost_epsilon:
		result["time_scale_duration"] = max(current_duration, duration)
		result["time_scale"] = max(current_time_scale, intensity)
		result["applied"] = true
	return result

static func generated_apply_boost_bridge_state(current_time_scale: float, current_duration: float, intensity: float, duration: float, can_overdrive: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_APPLY_BOOST_JAVA_METHOD, [current_time_scale, current_duration, intensity, duration, can_overdrive])
	var canonical := apply_boost_state(current_time_scale, current_duration, intensity, duration, can_overdrive, source_block_defaults.TIME_SCALE_BOOST_EPSILON)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_APPLY_BOOST_STATE,
		"generated_owner": SOURCE_BUILDING_APPLY_BOOST_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical),
	}

static func apply_slowdown_state(current_time_scale: float, current_duration: float, intensity: float, duration: float, time_scale_boost_epsilon: float) -> Dictionary:
	var refresh_duration := intensity <= current_time_scale + time_scale_boost_epsilon
	var next_duration: float = maxf(current_duration, duration) if refresh_duration else current_duration
	return {
		"time_scale": min(current_time_scale, intensity),
		"time_scale_duration": next_duration,
		"applied": true,
		"refresh_duration": refresh_duration,
	}

static func generated_apply_slowdown_bridge_state(current_time_scale: float, current_duration: float, intensity: float, duration: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_APPLY_SLOWDOWN_JAVA_METHOD, [current_time_scale, current_duration, intensity, duration])
	var canonical := apply_slowdown_state(current_time_scale, current_duration, intensity, duration, source_block_defaults.TIME_SCALE_BOOST_EPSILON)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_APPLY_SLOWDOWN_STATE,
		"generated_owner": SOURCE_BUILDING_APPLY_SLOWDOWN_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical),
	}

static func time_scale_decay_state(current_time_scale: float, current_duration: float, source_delta: float, default_time_scale: float) -> Dictionary:
	var decayed_duration := current_duration - source_delta
	var result := {"field": SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_FIELD, "method": SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_METHOD, "decay_gate": SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_GATE, "reset": SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_RESET, "time_scale": current_time_scale, "time_scale_duration": decayed_duration}
	if float(result["time_scale_duration"]) <= 0.0:
		result["time_scale"] = default_time_scale
		result["time_scale_duration"] = 0.0
	return result

static func delta(source_delta: float, time_scale: float) -> float:
	return source_delta * time_scale

static func edelta(source_delta: float, time_scale: float, efficiency: float) -> float:
	return efficiency * delta(source_delta, time_scale)

static func time_scale_state(current_time_scale: float) -> float:
	return current_time_scale

static func warmup_state() -> float:
	return 0.0

static func total_progress_state(source_time: float) -> float:
	return source_time

static func progress_state() -> float:
	return 0.0

static func generated_time_scale_bridge_state(current_time_scale: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_SCALE_JAVA_METHOD, [current_time_scale])
	var canonical = time_scale_state(current_time_scale)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_TIME_SCALE_STATE,
		"generated_owner": SOURCE_BUILDING_TIME_SCALE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result == canonical,
	}

static func generated_warmup_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_WARMUP_JAVA_METHOD, [])
	var canonical = warmup_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_WARMUP_STATE,
		"generated_owner": SOURCE_BUILDING_TIME_WARMUP_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result == canonical,
	}

static func generated_total_progress_bridge_state(source_time: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_TOTAL_PROGRESS_JAVA_METHOD, [source_time])
	var canonical = total_progress_state(source_time)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_TOTAL_PROGRESS_STATE,
		"generated_owner": SOURCE_BUILDING_TIME_TOTAL_PROGRESS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result == canonical,
	}

static func generated_progress_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_PROGRESS_JAVA_METHOD, [])
	var canonical = progress_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_PROGRESS_STATE,
		"generated_owner": SOURCE_BUILDING_TIME_PROGRESS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result == canonical,
	}

static func generated_delta_bridge_state(source_delta: float, time_scale: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_DELTA_JAVA_METHOD, [source_delta, time_scale])
	var canonical = delta(source_delta, time_scale)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DELTA,
		"generated_owner": SOURCE_BUILDING_TIME_DELTA_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_edelta_bridge_state(source_delta: float, time_scale: float, efficiency: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_EDELTA_JAVA_METHOD, [source_delta, time_scale, efficiency])
	var canonical = edelta(source_delta, time_scale, efficiency)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_EDELTA,
		"generated_owner": SOURCE_BUILDING_TIME_EDELTA_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func progress_increase(base_time: float, edelta_value: float) -> float:
	return 1.0 / base_time * edelta_value

static func display_efficiency(edelta_value: float) -> float:
	return progress_increase(1.0, edelta_value) / edelta_value

static func should_ambient_sound(should_consume_state: bool) -> Dictionary:
	var source_exprs := {
		"method": "public boolean shouldAmbientSound(){",
		"return_should_consume": "return shouldConsume();",
	}
	var result := {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SHOULD_AMBIENT_SOUND, "should_ambient_sound": should_consume_state}
	result.merge(source_exprs)
	return result

static func generated_get_progress_increase_bridge_state(base_time: float, edelta_value: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_PROGRESS_INCREASE_JAVA_METHOD, [base_time, edelta_value])
	var canonical = progress_increase(base_time, edelta_value)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_PROGRESS_INCREASE, "generated_owner": SOURCE_BUILDING_TIME_PROGRESS_INCREASE_GENERATED_OWNER, "result": result, "canonical": canonical}

static func generated_get_display_efficiency_bridge_state(edelta_value: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_DISPLAY_EFFICIENCY_JAVA_METHOD, [edelta_value])
	var canonical = display_efficiency(edelta_value)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_DISPLAY_EFFICIENCY, "generated_owner": SOURCE_BUILDING_TIME_DISPLAY_EFFICIENCY_GENERATED_OWNER, "result": result, "canonical": canonical}

static func generated_should_ambient_sound_bridge_state(should_consume_state: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_SHOULD_AMBIENT_SOUND_JAVA_METHOD, [should_consume_state])
	var canonical = should_ambient_sound(should_consume_state)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SHOULD_AMBIENT_SOUND, "generated_owner": SOURCE_BUILDING_TIME_SHOULD_AMBIENT_SOUND_GENERATED_OWNER, "result": result, "canonical": canonical}

@warning_ignore("unused_parameter")
static func write_base_timescale_state(current_time_scale: float, current_time_scale_duration: float, default_time_scale: float) -> Dictionary:
	var write_timescale := current_time_scale != default_time_scale
	return {"gate": "if(timeScale != 1f){", "write_time_scale_call": "write.f(timeScale);", "write_duration_call": "write.f(timeScaleDuration);", "write_timescale": write_timescale}

static func generated_write_base_timescale_bridge_state(current_time_scale: float, current_time_scale_duration: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_WRITE_BASE_JAVA_METHOD, [current_time_scale, current_time_scale_duration])
	var canonical = write_base_timescale_state(current_time_scale, current_time_scale_duration, source_block_defaults.TIME_SCALE_DEFAULT)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_WRITE_BASE_TIMESCALE_STATE,
		"generated_owner": SOURCE_BUILDING_TIME_WRITE_BASE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func module_bitmask_state(has_items_module: bool, has_power_module: bool, has_liquids_module: bool, current_time_scale: float, has_valid_last_disabler: bool, default_time_scale: float) -> Dictionary:
	var time_scale_changed := current_time_scale != default_time_scale
	var module_bits := (1 if has_items_module else 0) | (1 << 1 if has_power_module else 0) | (1 << 2 if has_liquids_module else 0) | (1 << 3) | (1 << 4 if time_scale_changed else 0) | (1 << 5 if has_valid_last_disabler else 0)
	return {"time_scale_bit_expr": "(timeScale != 1f ? 1 << 4 : 0)", "module_bits": module_bits, "time_scale_changed": time_scale_changed}

static func generated_module_bitmask_bridge_state(has_items_module: bool, has_power_module: bool, has_liquids_module: bool, current_time_scale: float, has_valid_last_disabler: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_MODULE_BITMASK_JAVA_METHOD, [has_items_module, has_power_module, has_liquids_module, current_time_scale, has_valid_last_disabler])
	var canonical = module_bitmask_state(has_items_module, has_power_module, has_liquids_module, current_time_scale, has_valid_last_disabler, source_block_defaults.TIME_SCALE_DEFAULT)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_MODULE_BITMASK_STATE,
		"generated_owner": SOURCE_BUILDING_TIME_MODULE_BITMASK_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func read_base_timescale_state(current_module_bits: int, read_time_scale: float, read_time_scale_duration: float, default_time_scale: float) -> Dictionary:
	var has_time_scale_module := (current_module_bits & (1 << 4)) != 0
	if not has_time_scale_module:
		return {"time_scale": default_time_scale, "time_scale_duration": 0.0, "read_called": false}
	return {"time_scale": read_time_scale, "time_scale_duration": read_time_scale_duration, "read_called": true}

static func generated_read_base_timescale_bridge_state(current_module_bits: int, read_time_scale: float, read_time_scale_duration: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_READ_BASE_JAVA_METHOD, [current_module_bits, read_time_scale, read_time_scale_duration])
	var canonical = read_base_timescale_state(current_module_bits, read_time_scale, read_time_scale_duration, source_block_defaults.TIME_SCALE_DEFAULT)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_READ_BASE_TIMESCALE_STATE,
		"generated_owner": SOURCE_BUILDING_TIME_READ_BASE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func update_timescale_decay_state(current_time_scale: float, current_time_scale_duration: float, time_delta: float, default_time_scale: float) -> Dictionary:
	var next_duration := current_time_scale_duration - time_delta
	var result := {"field": SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_FIELD, "method": SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_METHOD, "decay_gate": SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_GATE, "reset": SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_RESET, "time_scale": current_time_scale, "time_scale_duration": next_duration}
	if float(result["time_scale_duration"]) <= 0.0:
		result["time_scale"] = default_time_scale
		result["time_scale_duration"] = 0.0
	return result

static func generated_update_timescale_decay_bridge_state(current_time_scale: float, current_time_scale_duration: float, time_delta: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_UPDATE_JAVA_METHOD, [current_time_scale, current_time_scale_duration, time_delta])
	var canonical = update_timescale_decay_state(current_time_scale, current_time_scale_duration, time_delta, source_block_defaults.TIME_SCALE_DEFAULT)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_STATE,
		"generated_owner": SOURCE_BUILDING_TIME_UPDATE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func update_ambient_sound_gate_state(headless_mode: bool, ambient_sound_value: Variant, sounds_none_value: Variant, should_ambient_sound_result: bool, block_ambient_sound_volume: float, ambient_volume_value: float) -> Dictionary:
	var should_loop: bool = not headless_mode and ambient_sound_value != sounds_none_value and should_ambient_sound_result
	var result := {"loop_called": false, "sound": ambient_sound_value, "volume": 0.0}
	if should_loop:
		result = {"loop_called": true, "sound": ambient_sound_value, "volume": block_ambient_sound_volume * ambient_volume_value}
	# return {"loop_called": false, "sound": ambient_sound_value, "volume": 0.0}
	# return {"loop_called": true, "sound": ambient_sound_value, "volume": block_ambient_sound_volume * ambient_volume_value}
	result.merge({"method": SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_METHOD, "gate": SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_GATE, "loop_call": SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_LOOP, "volume_expr": SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_VOLUME_EXPR})
	return result

static func generated_update_ambient_sound_gate_bridge_state(headless_mode: bool, ambient_sound_value: Variant, sounds_none_value: Variant, should_ambient_sound_result: bool, block_ambient_sound_volume: float, ambient_volume_value: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TIME_UPDATE_JAVA_METHOD, [source_block_defaults.TIME_SCALE_DEFAULT, 0.0, 0.0, headless_mode, ambient_sound_value, sounds_none_value, should_ambient_sound_result, block_ambient_sound_volume, ambient_volume_value])
	var canonical = update_ambient_sound_gate_state(headless_mode, ambient_sound_value, sounds_none_value, should_ambient_sound_result, block_ambient_sound_volume, ambient_volume_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_GATE_STATE,
		"generated_owner": SOURCE_BUILDING_TIME_UPDATE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}
