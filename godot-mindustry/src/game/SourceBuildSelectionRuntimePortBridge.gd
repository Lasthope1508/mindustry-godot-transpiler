extends "res://src/game/SourceBuildingDestructionPortBridge.gd"

const source_build_selection_runtime_state := preload("res://src/game/SourceBuildSelectionRuntimeState.gd")
const source_build_selection_runtime_port_bridge_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_build_selection_runtime_port_bridge_selected_build_state := preload("res://src/game/SourceSelectedBuildState.gd")

func build_block_palette() -> void:
	source_build_selection_runtime_state.build_block_palette(self)

func select_build_slot_action(canonical_action: String) -> void:
	source_build_selection_runtime_state.select_build_slot_action(self, canonical_action)

func select_next_build_slot() -> void:
	source_build_selection_runtime_state.select_next_build_slot(self)

func select_previous_build_slot() -> void:
	source_build_selection_runtime_state.select_previous_build_slot(self)

func select_build_block_by_id(block_id: String) -> bool:
	return source_build_selection_runtime_state.select_build_block_by_id(self, block_id)

func selected_build_properties(selected) -> Dictionary:
	return source_build_selection_runtime_port_bridge_selected_build_state.properties(selected)

func selected_build_health() -> float:
	return source_build_selection_runtime_state.selected_build_health(self)

func selected_build_scaled_health() -> float:
	return source_build_selection_runtime_state.selected_build_scaled_health(self)

func selected_build_heal_percent() -> float:
	return source_build_selection_runtime_state.selected_build_heal_percent(self)

func selected_build_phase_boost() -> float:
	return source_build_selection_runtime_state.selected_build_phase_boost(self)

func selected_build_phase_range_boost() -> float:
	return source_build_selection_runtime_state.selected_build_phase_range_boost(self)

func selected_build_can_overdrive() -> bool:
	return source_build_selection_runtime_state.selected_build_can_overdrive(self)

func selected_build_has_power() -> bool:
	return source_build_selection_runtime_state.selected_build_has_power(self)

func selected_build_consumes_power() -> bool:
	return source_build_selection_runtime_state.selected_build_consumes_power(self)

func selected_build_outputs_power() -> bool:
	return source_build_selection_runtime_state.selected_build_outputs_power(self)

func selected_build_power_usage() -> float:
	return source_build_selection_runtime_state.selected_build_power_usage(self)

func selected_build_power_capacity() -> float:
	return source_build_selection_runtime_state.selected_build_power_capacity(self)

func selected_build_power_buffered() -> bool:
	return source_build_selection_runtime_state.selected_build_power_buffered(self)

func selected_build_power_production() -> float:
	return source_build_selection_runtime_state.selected_build_power_production(self)

func selected_build_item_duration() -> float:
	return source_build_selection_runtime_state.selected_build_item_duration(self)

func selected_build_max_nodes() -> int:
	return source_build_selection_runtime_state.selected_build_max_nodes(self)

func selected_build_laser_range() -> float:
	return source_build_selection_runtime_state.selected_build_laser_range(self)

func selected_build_overdrive_target_filter_state_for_block_id(target_block_id: String, distance: float, phase_heat := 0.0) -> Dictionary:
	return source_build_selection_runtime_state.selected_build_overdrive_target_filter_state_for_block_id(self, target_block_id, distance, phase_heat)

func selected_build_overdrive_real_boost() -> float:
	return source_build_selection_runtime_state.selected_build_overdrive_real_boost(self)

func selected_build_overdrive_phase_real_boost() -> float:
	return source_build_selection_runtime_state.selected_build_overdrive_phase_real_boost(self)

func selected_build_overdrive_boost_bar_fraction() -> float:
	return source_build_selection_runtime_state.selected_build_overdrive_boost_bar_fraction(self)

func selected_build_overdrive_phase_boost_bar_fraction() -> float:
	return source_build_selection_runtime_state.selected_build_overdrive_phase_boost_bar_fraction(self)

func selected_build_overdrive_place_state() -> Dictionary:
	return source_build_selection_runtime_state.selected_build_overdrive_place_state(self)

func selected_build_overdrive_phase_select_state() -> Dictionary:
	return source_build_selection_runtime_state.selected_build_overdrive_phase_select_state(self)

func selected_build_overdrive_light_state_for_smooth_efficiency(smooth_efficiency: float) -> Dictionary:
	return source_build_selection_runtime_state.selected_build_overdrive_light_state_for_smooth_efficiency(self, smooth_efficiency)

func selected_build_overdrive_draw_state_for_inputs(heat: float, phase_heat: float, source_time_ticks := 0.0) -> Dictionary:
	return source_build_selection_runtime_state.selected_build_overdrive_draw_state_for_inputs(self, heat, phase_heat, source_time_ticks, source_build_selection_runtime_port_bridge_world_defaults.TILESIZE)

func selected_build_booster_item() -> String:
	return source_build_selection_runtime_state.selected_build_booster_item(self)

func selected_build_booster_use_time() -> float:
	return source_build_selection_runtime_state.selected_build_booster_use_time(self)

func selected_build_place_state() -> Dictionary:
	return source_build_selection_runtime_state.selected_build_place_state(self)

func selected_build_repair_amount() -> float:
	return source_build_selection_runtime_state.selected_build_repair_amount(self, get("content_catalog"))
