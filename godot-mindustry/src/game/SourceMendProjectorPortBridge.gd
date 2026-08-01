extends "res://src/game/SourcePowerGraphPortBridge.gd"

const source_mend_projector_state := preload("res://src/game/SourceMendProjectorState.gd")
const source_mend_projector_port_bridge_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_mend_projector_port_bridge_selected_build_state := preload("res://src/game/SourceSelectedBuildState.gd")

func source_mend_projector_repair_amount(mend_projector, target_block, phase_heat := 0.0, efficiency := 1.0) -> float:
	return source_mend_projector_state.repair_amount(mend_projector, target_block, phase_heat, efficiency)

func source_mend_projector_light_state(mend_projector, smooth_efficiency: float) -> Dictionary:
	return source_mend_projector_state.light_state(mend_projector, smooth_efficiency)

func source_mend_projector_reload(mend_projector) -> float:
	return source_mend_projector_state.projector_reload(mend_projector)

func source_mend_projector_use_time(mend_projector) -> float:
	return source_mend_projector_state.use_time(mend_projector)

func source_mend_projector_is_projector(block) -> bool:
	return source_mend_projector_port_bridge_selected_build_state.is_mend_projector(block)

func source_mend_projector_progress(mend_projector, charge: float) -> float:
	return source_mend_projector_state.progress(mend_projector, charge)

func source_mend_projector_select_state(mend_projector, phase_heat := 0.0) -> Dictionary:
	return source_mend_projector_state.select_state(mend_projector, phase_heat)

func source_mend_projector_place_state(mend_projector) -> Dictionary:
	return source_mend_projector_state.place_state(mend_projector)

func source_mend_projector_draw_state(mend_projector, heat: float, phase_heat: float, source_time_ticks := 0.0, lod_l2 := true, lod_alpha2 := 1.0) -> Dictionary:
	return source_mend_projector_state.draw_state(mend_projector, heat, phase_heat, float(source_mend_projector_port_bridge_world_defaults.TILESIZE), source_time_ticks, lod_l2, lod_alpha2)

func mend_projector_phase_heat_at_cell(x: int, y: int) -> float:
	return source_mend_projector_state.phase_heat_at_cell(self, x, y)

func mend_projector_smooth_efficiency_at_cell(x: int, y: int) -> float:
	return source_mend_projector_state.smooth_efficiency_at_cell(self, x, y)

func mend_projector_light_state_at_cell(x: int, y: int) -> Dictionary:
	return source_mend_projector_state.light_state_at_cell(self, x, y)

func mend_projector_heat_at_cell(x: int, y: int) -> float:
	return source_mend_projector_state.heat_at_cell(self, x, y)

func mend_projector_charge_at_cell(x: int, y: int) -> float:
	return source_mend_projector_state.charge_at_cell(self, x, y)

func mend_projector_progress_at_cell(x: int, y: int) -> float:
	return source_mend_projector_state.progress_at_cell(self, x, y)

func mend_projector_select_state_at_cell(x: int, y: int) -> Dictionary:
	return source_mend_projector_state.select_state_at_cell(self, x, y)

func mend_projector_draw_state_at_cell(x: int, y: int, source_time_ticks := 0.0) -> Dictionary:
	return source_mend_projector_state.draw_state_at_cell(self, x, y, source_time_ticks, source_mend_projector_port_bridge_world_defaults.TILESIZE)

func mend_projector_state_at_cell(x: int, y: int) -> Dictionary:
	return source_mend_projector_state.state_at_cell(self, x, y)

func source_mend_projector_range(mend_projector, phase_heat := 0.0) -> float:
	return source_mend_projector_state.projector_range(mend_projector, phase_heat)

func find_damaged_block_in_mend_range(mend_cell: Vector2i, mend_projector, phase_heat := 0.0):
	return source_mend_projector_state.find_damaged_block_in_range(self, mend_cell, mend_projector, phase_heat)

func simulate_mend_projectors(delta: float) -> void:
	source_mend_projector_state.simulate_projectors(self, delta)

func step_mend_projectors(seconds: float) -> Dictionary:
	return source_mend_projector_state.step_projectors(self, seconds)
