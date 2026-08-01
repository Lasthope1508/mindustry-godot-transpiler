extends "res://src/game/SourceBlockUnitPortBridge.gd"

const source_overdrive_projector_state := preload("res://src/game/SourceOverdriveProjectorState.gd")
const source_overdrive_projector_port_bridge_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_selected_build_state := preload("res://src/game/SourceSelectedBuildState.gd")

func source_overdrive_projector_range(overdrive_projector, phase_heat := 0.0) -> float:
	return source_overdrive_projector_state.projector_range(overdrive_projector, phase_heat)

func source_overdrive_projector_select_state(overdrive_projector, phase_heat := 0.0) -> Dictionary:
	return source_overdrive_projector_state.select_state(overdrive_projector, phase_heat)

func source_overdrive_projector_place_state(overdrive_projector) -> Dictionary:
	return source_overdrive_projector_state.place_state(overdrive_projector)

func source_overdrive_projector_target_filter_state(overdrive_projector, target_block, distance: float, phase_heat := 0.0) -> Dictionary:
	return source_overdrive_projector_state.target_filter_state(overdrive_projector, target_block, distance, phase_heat)

func source_overdrive_projector_light_state(overdrive_projector, smooth_efficiency: float) -> Dictionary:
	return source_overdrive_projector_state.light_state(overdrive_projector, smooth_efficiency)

func source_overdrive_projector_draw_state(overdrive_projector, heat: float, phase_heat: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	return source_overdrive_projector_state.draw_state(overdrive_projector, heat, phase_heat, source_overdrive_projector_port_bridge_world_defaults.TILESIZE, source_time_ticks, lod_l2, lod_alpha2)

func source_overdrive_projector_real_boost(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	return source_overdrive_projector_state.real_boost(overdrive_projector, phase_heat, efficiency)

func source_overdrive_projector_boost_bar_fraction(overdrive_projector, phase_heat := 0.0, efficiency := 1.0) -> float:
	return source_overdrive_projector_state.boost_bar_fraction(overdrive_projector, phase_heat, efficiency)

func source_overdrive_projector_reload(overdrive_projector) -> float:
	return source_overdrive_projector_state.projector_reload(overdrive_projector)

func source_overdrive_projector_use_time(overdrive_projector) -> float:
	return source_overdrive_projector_state.use_time(overdrive_projector)

func source_overdrive_projector_has_boost(overdrive_projector) -> bool:
	return source_overdrive_projector_state.has_boost(overdrive_projector)

func source_overdrive_projector_is_projector(block) -> bool:
	return source_selected_build_state.is_overdrive_projector(block)

func overdrive_projector_phase_heat_at_cell(x: int, y: int) -> float:
	return source_overdrive_projector_state.game_state_value_at_cell(self, x, y, get("overdrive_projector_phase_heat"), 0.0)

func overdrive_projector_smooth_efficiency_at_cell(x: int, y: int) -> float:
	return source_overdrive_projector_state.game_state_value_at_cell(self, x, y, get("overdrive_projector_smooth_efficiency"), 0.0)

func overdrive_projector_heat_at_cell(x: int, y: int) -> float:
	return source_overdrive_projector_state.game_state_value_at_cell(self, x, y, get("overdrive_projector_heat"), 0.0)

func overdrive_projector_charge_at_cell(x: int, y: int) -> float:
	return source_overdrive_projector_state.game_state_value_at_cell(self, x, y, get("overdrive_projector_charges"), 0.0)

func overdrive_projector_use_progress_at_cell(x: int, y: int) -> float:
	return source_overdrive_projector_state.game_state_value_at_cell(self, x, y, get("overdrive_projector_use_progress"), 0.0)

func overdrive_projector_light_state_at_cell(x: int, y: int) -> Dictionary:
	return source_overdrive_projector_state.game_light_state_at_cell(self, x, y)

func overdrive_projector_draw_state_at_cell(x: int, y: int, source_time_ticks := 0.0) -> Dictionary:
	return source_overdrive_projector_state.game_draw_state_at_cell(self, x, y, source_time_ticks)

func overdrive_projector_state_at_cell(x: int, y: int) -> Dictionary:
	return source_overdrive_projector_state.game_capture_state_at_cell(self, x, y, get("overdrive_projector_heat"), get("overdrive_projector_smooth_efficiency"), get("overdrive_projector_phase_heat"), get("overdrive_projector_charges"), get("overdrive_projector_use_progress"))

func find_overdrive_boost_target(overdrive_cell: Vector2i, overdrive_projector, phase_heat := 0.0):
	return source_overdrive_projector_state.find_overdrive_boost_target(self, overdrive_cell, overdrive_projector, phase_heat)

func apply_overdrive_boost_to_sprite(target, intensity: float, duration: float) -> Dictionary:
	return source_overdrive_projector_state.apply_overdrive_boost_to_sprite(self, target, intensity, duration)

func simulate_overdrive_projectors(delta: float) -> void:
	source_overdrive_projector_state.simulate_projectors(self, delta)

func step_overdrive_projectors(seconds: float) -> Dictionary:
	return source_overdrive_projector_state.step_projectors(self, seconds)
