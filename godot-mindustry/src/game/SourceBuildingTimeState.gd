extends RefCounted
class_name SourceBuildingTimeState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const SourceBlockDefaults := preload("res://src/game/SourceBlockDefaults.gd")
const SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_FIELD := "private transient float timeScale = 1f, timeScaleDuration;"
const SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_METHOD := "public void update(){"
const SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_GATE := "if((timeScaleDuration -= Time.delta) <= 0f){"
const SOURCE_BUILDING_UPDATE_TIMESCALE_DECAY_RESET := "timeScale = 1f;"
const SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_METHOD := "public void update(){"
const SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_GATE := "if(!headless && block.ambientSound != Sounds.none && shouldAmbientSound()){"
const SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_LOOP := "control.sound.loop(block.ambientSound, self(), block.ambientSoundVolume * ambientVolume());"
const SOURCE_BUILDING_UPDATE_AMBIENT_SOUND_VOLUME_EXPR := "block.ambientSoundVolume * ambientVolume()"

static func apply_boost_state(current_time_scale: float, current_duration: float, intensity: float, duration: float, can_overdrive: bool, time_scale_boost_epsilon: float) -> Dictionary:
	var result := {"time_scale": current_time_scale, "time_scale_duration": current_duration, "applied": false, "can_overdrive": can_overdrive}
	if not can_overdrive:
		return result
	if intensity >= current_time_scale - time_scale_boost_epsilon:
		result["time_scale_duration"] = max(current_duration, duration)
		result["time_scale"] = max(current_time_scale, intensity)
		result["applied"] = true
	return result

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

static func generated_delta_bridge_state(source_delta: float, time_scale: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_delta_190", [source_delta, time_scale], null)
	var canonical = delta(source_delta, time_scale)
	return {
		"source_owner": "PortGame.source_building_delta",
		"generated_owner": "BuildingComp.java_method_delta_190",
		"result": result,
		"canonical": canonical,
	}

static func generated_edelta_bridge_state(source_delta: float, time_scale: float, efficiency: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_edelta_191", [source_delta, time_scale, efficiency], null)
	var canonical = edelta(source_delta, time_scale, efficiency)
	return {
		"source_owner": "PortGame.source_building_edelta",
		"generated_owner": "BuildingComp.java_method_edelta_191",
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
	var result := {"source_owner": "PortGame.source_building_should_ambient_sound", "should_ambient_sound": should_consume_state}
	result.merge(source_exprs)
	return result

static func generated_get_progress_increase_bridge_state(base_time: float, edelta_value: float) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
	var instance = script.new()
	var result = instance.java_method_getProgressIncrease_120([base_time, edelta_value])
	var canonical = progress_increase(base_time, edelta_value)
	return {"source_owner": "PortGame.source_building_progress_increase", "generated_owner": "BuildingComp.java_method_getProgressIncrease_120", "result": result, "canonical": canonical}

static func generated_get_display_efficiency_bridge_state(edelta_value: float) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
	var instance = script.new()
	var result = instance.java_method_getDisplayEfficiency_121([edelta_value])
	var canonical = display_efficiency(edelta_value)
	return {"source_owner": "PortGame.source_building_display_efficiency", "generated_owner": "BuildingComp.java_method_getDisplayEfficiency_121", "result": result, "canonical": canonical}

static func generated_should_ambient_sound_bridge_state(should_consume_state: bool) -> Dictionary:
	var script = ResourceLoader.load("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
	var instance = script.new()
	var result = instance.java_method_shouldAmbientSound_122([should_consume_state])
	var canonical = should_ambient_sound(should_consume_state)
	return {"source_owner": "PortGame.source_building_should_ambient_sound", "generated_owner": "BuildingComp.java_method_shouldAmbientSound_122", "result": result, "canonical": canonical}

@warning_ignore("unused_parameter")
static func write_base_timescale_state(current_time_scale: float, current_time_scale_duration: float, default_time_scale: float) -> Dictionary:
	var write_timescale := current_time_scale != default_time_scale
	return {"gate": "if(timeScale != 1f){", "write_time_scale_call": "write.f(timeScale);", "write_duration_call": "write.f(timeScaleDuration);", "write_timescale": write_timescale}

static func generated_write_base_timescale_bridge_state(current_time_scale: float, current_time_scale_duration: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_writeBase_5", [current_time_scale, current_time_scale_duration], null)
	var canonical = write_base_timescale_state(current_time_scale, current_time_scale_duration, SourceBlockDefaults.TIME_SCALE_DEFAULT)
	return {
		"source_owner": "PortGame.source_building_write_base_timescale_state",
		"generated_owner": "BuildingComp.java_method_writeBase_5",
		"result": result,
		"canonical": canonical,
	}

static func module_bitmask_state(has_items_module: bool, has_power_module: bool, has_liquids_module: bool, current_time_scale: float, has_valid_last_disabler: bool, default_time_scale: float) -> Dictionary:
	var time_scale_changed := current_time_scale != default_time_scale
	var module_bits := (1 if has_items_module else 0) | (1 << 1 if has_power_module else 0) | (1 << 2 if has_liquids_module else 0) | (1 << 3) | (1 << 4 if time_scale_changed else 0) | (1 << 5 if has_valid_last_disabler else 0)
	return {"time_scale_bit_expr": "(timeScale != 1f ? 1 << 4 : 0)", "module_bits": module_bits, "time_scale_changed": time_scale_changed}

static func generated_module_bitmask_bridge_state(has_items_module: bool, has_power_module: bool, has_liquids_module: bool, current_time_scale: float, has_valid_last_disabler: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_moduleBitmask_7", [has_items_module, has_power_module, has_liquids_module, current_time_scale, has_valid_last_disabler], null)
	var canonical = module_bitmask_state(has_items_module, has_power_module, has_liquids_module, current_time_scale, has_valid_last_disabler, SourceBlockDefaults.TIME_SCALE_DEFAULT)
	return {
		"source_owner": "PortGame.source_building_module_bitmask_state",
		"generated_owner": "BuildingComp.java_method_moduleBitmask_7",
		"result": result,
		"canonical": canonical,
	}

static func read_base_timescale_state(current_module_bits: int, read_time_scale: float, read_time_scale_duration: float, default_time_scale: float) -> Dictionary:
	var has_time_scale_module := (current_module_bits & (1 << 4)) != 0
	if not has_time_scale_module:
		return {"time_scale": default_time_scale, "time_scale_duration": 0.0, "read_called": false}
	return {"time_scale": read_time_scale, "time_scale_duration": read_time_scale_duration, "read_called": true}

static func generated_read_base_timescale_bridge_state(current_module_bits: int, read_time_scale: float, read_time_scale_duration: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_readBase_6", [current_module_bits, read_time_scale, read_time_scale_duration], null)
	var canonical = read_base_timescale_state(current_module_bits, read_time_scale, read_time_scale_duration, SourceBlockDefaults.TIME_SCALE_DEFAULT)
	return {
		"source_owner": "PortGame.source_building_read_base_timescale_state",
		"generated_owner": "BuildingComp.java_method_readBase_6",
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
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_update_217", [current_time_scale, current_time_scale_duration, time_delta], null)
	var canonical = update_timescale_decay_state(current_time_scale, current_time_scale_duration, time_delta, SourceBlockDefaults.TIME_SCALE_DEFAULT)
	return {
		"source_owner": "PortGame.source_building_update_timescale_decay_state",
		"generated_owner": "BuildingComp.java_method_update_217",
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
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_update_217", [SourceBlockDefaults.TIME_SCALE_DEFAULT, 0.0, 0.0, headless_mode, ambient_sound_value, sounds_none_value, should_ambient_sound_result, block_ambient_sound_volume, ambient_volume_value], null)
	var canonical = update_ambient_sound_gate_state(headless_mode, ambient_sound_value, sounds_none_value, should_ambient_sound_result, block_ambient_sound_volume, ambient_volume_value)
	return {
		"source_owner": "PortGame.source_building_update_ambient_sound_gate_state",
		"generated_owner": "BuildingComp.java_method_update_217",
		"result": result,
		"canonical": canonical,
	}
