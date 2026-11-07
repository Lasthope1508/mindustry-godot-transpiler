extends "res://src/game/SourceOverdriveProjectorPortBridge.gd"

const source_building_time_state := preload("res://src/game/SourceBuildingTimeState.gd")
const source_building_time_port_bridge_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")

func source_building_apply_boost_state(current_time_scale: float, current_duration: float, intensity: float, duration: float, can_overdrive := true) -> Dictionary:
	return source_building_time_state.apply_boost_state(current_time_scale, current_duration, intensity, duration, can_overdrive, source_building_time_port_bridge_block_defaults.TIME_SCALE_BOOST_EPSILON)

func generated_building_comp_apply_boost_bridge_state(current_time_scale: float, current_duration: float, intensity: float, duration: float, can_overdrive := true) -> Dictionary:
	return source_building_time_state.generated_apply_boost_bridge_state(current_time_scale, current_duration, intensity, duration, can_overdrive)

func source_building_apply_slowdown_state(current_time_scale: float, current_duration: float, intensity: float, duration: float) -> Dictionary:
	return source_building_time_state.apply_slowdown_state(current_time_scale, current_duration, intensity, duration, source_building_time_port_bridge_block_defaults.TIME_SCALE_BOOST_EPSILON)

func generated_building_comp_apply_slowdown_bridge_state(current_time_scale: float, current_duration: float, intensity: float, duration: float) -> Dictionary:
	return source_building_time_state.generated_apply_slowdown_bridge_state(current_time_scale, current_duration, intensity, duration)

func source_building_time_scale_decay_state(current_time_scale: float, current_duration: float, source_delta: float) -> Dictionary:
	return source_building_time_state.time_scale_decay_state(current_time_scale, current_duration, source_delta, source_building_time_port_bridge_block_defaults.TIME_SCALE_DEFAULT)

func source_building_delta(source_delta: float, time_scale: float) -> float:
	return source_building_time_state.delta(source_delta, time_scale)

func source_building_edelta(source_delta: float, time_scale: float, efficiency: float) -> float:
	return source_building_time_state.edelta(source_delta, time_scale, efficiency)

func source_building_time_scale_state(current_time_scale: float) -> float:
	return source_building_time_state.time_scale_state(current_time_scale)

func source_building_warmup_state() -> float:
	return source_building_time_state.warmup_state()

func source_building_total_progress_state(source_time: float) -> float:
	return source_building_time_state.total_progress_state(source_time)

func source_building_progress_state() -> float:
	return source_building_time_state.progress_state()

func generated_building_comp_time_scale_bridge_state(current_time_scale: float) -> Dictionary:
	return source_building_time_state.generated_time_scale_bridge_state(current_time_scale)

func generated_building_comp_warmup_bridge_state() -> Dictionary:
	return source_building_time_state.generated_warmup_bridge_state()

func generated_building_comp_total_progress_bridge_state(source_time: float) -> Dictionary:
	return source_building_time_state.generated_total_progress_bridge_state(source_time)

func generated_building_comp_progress_bridge_state() -> Dictionary:
	return source_building_time_state.generated_progress_bridge_state()

func source_building_progress_increase(base_time: float, edelta_value: float) -> float:
	return source_building_time_state.progress_increase(base_time, edelta_value)

func source_building_display_efficiency(edelta_value: float) -> float:
	return source_building_time_state.display_efficiency(edelta_value)

func generated_building_comp_get_progress_increase_bridge_state(base_time: float, edelta_value: float) -> Dictionary:
	return source_building_time_state.generated_get_progress_increase_bridge_state(base_time, edelta_value)

func generated_building_comp_get_display_efficiency_bridge_state(edelta_value: float) -> Dictionary:
	return source_building_time_state.generated_get_display_efficiency_bridge_state(edelta_value)

func generated_building_comp_should_ambient_sound_bridge_state(should_consume_state: bool) -> Dictionary:
	return source_building_time_state.generated_should_ambient_sound_bridge_state(should_consume_state)

func generated_building_comp_delta_bridge_state(source_delta: float, time_scale: float) -> Dictionary:
	return source_building_time_state.generated_delta_bridge_state(source_delta, time_scale)

func generated_building_comp_edelta_bridge_state(source_delta: float, time_scale: float, efficiency: float) -> Dictionary:
	return source_building_time_state.generated_edelta_bridge_state(source_delta, time_scale, efficiency)

func source_building_should_ambient_sound(should_consume_state: bool) -> Dictionary:
	return source_building_time_state.should_ambient_sound(should_consume_state)

func source_building_write_base_timescale_state(current_time_scale: float, current_time_scale_duration: float) -> Dictionary:
	return source_building_time_state.write_base_timescale_state(current_time_scale, current_time_scale_duration, source_building_time_port_bridge_block_defaults.TIME_SCALE_DEFAULT)

func generated_building_comp_write_base_timescale_bridge_state(current_time_scale: float, current_time_scale_duration: float) -> Dictionary:
	return source_building_time_state.generated_write_base_timescale_bridge_state(current_time_scale, current_time_scale_duration)

func source_building_read_base_timescale_state(current_module_bits: int, read_time_scale: float, read_time_scale_duration: float) -> Dictionary:
	return source_building_time_state.read_base_timescale_state(current_module_bits, read_time_scale, read_time_scale_duration, source_building_time_port_bridge_block_defaults.TIME_SCALE_DEFAULT)

func generated_building_comp_read_base_timescale_bridge_state(current_module_bits: int, read_time_scale: float, read_time_scale_duration: float) -> Dictionary:
	return source_building_time_state.generated_read_base_timescale_bridge_state(current_module_bits, read_time_scale, read_time_scale_duration)

func source_building_module_bitmask_state(has_items_module: bool, has_power_module: bool, has_liquids_module: bool, current_time_scale: float, has_valid_last_disabler: bool) -> Dictionary:
	return source_building_time_state.module_bitmask_state(has_items_module, has_power_module, has_liquids_module, current_time_scale, has_valid_last_disabler, source_building_time_port_bridge_block_defaults.TIME_SCALE_DEFAULT)

func generated_building_comp_module_bitmask_bridge_state(has_items_module: bool, has_power_module: bool, has_liquids_module: bool, current_time_scale: float, has_valid_last_disabler: bool) -> Dictionary:
	return source_building_time_state.generated_module_bitmask_bridge_state(has_items_module, has_power_module, has_liquids_module, current_time_scale, has_valid_last_disabler)

func generated_building_comp_update_timescale_decay_bridge_state(current_time_scale: float, current_time_scale_duration: float, time_delta: float) -> Dictionary:
	return source_building_time_state.generated_update_timescale_decay_bridge_state(current_time_scale, current_time_scale_duration, time_delta)

func source_building_update_timescale_decay_state(current_time_scale: float, current_time_scale_duration: float, time_delta: float) -> Dictionary:
	return source_building_time_state.update_timescale_decay_state(current_time_scale, current_time_scale_duration, time_delta, source_building_time_port_bridge_block_defaults.TIME_SCALE_DEFAULT)

func generated_building_comp_update_ambient_sound_gate_bridge_state(headless_mode: bool, ambient_sound_value: Variant, sounds_none_value: Variant, should_ambient_sound_result: bool, block_ambient_sound_volume: float, ambient_volume_value: float) -> Dictionary:
	return source_building_time_state.generated_update_ambient_sound_gate_bridge_state(headless_mode, ambient_sound_value, sounds_none_value, should_ambient_sound_result, block_ambient_sound_volume, ambient_volume_value)

func source_building_update_ambient_sound_gate_state(headless_mode: bool, ambient_sound_value: Variant, sounds_none_value: Variant, should_ambient_sound_result: bool, block_ambient_sound_volume: float, ambient_volume_value: float) -> Dictionary:
	return source_building_time_state.update_ambient_sound_gate_state(headless_mode, ambient_sound_value, sounds_none_value, should_ambient_sound_result, block_ambient_sound_volume, ambient_volume_value)
