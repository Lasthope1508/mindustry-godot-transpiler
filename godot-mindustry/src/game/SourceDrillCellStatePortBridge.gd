extends "res://src/game/SourceDrillInventoryPortBridge.gd"

const source_drill_cell_state_port_bridge_world_grid := preload("res://src/game/SourceWorldGrid.gd")

func drill_warmup_at_cell(x: int, y: int) -> float:
	var key := source_drill_cell_state_port_bridge_world_grid.cell_key(Vector2i(x, y))
	var drill_warmups_state = get("drill_warmups")
	if drill_warmups_state is Dictionary:
		return float(drill_warmups_state.get(key, 0.0))
	return 0.0

func set_drill_warmup_at_cell(x: int, y: int, warmup: float) -> void:
	var key := source_drill_cell_state_port_bridge_world_grid.cell_key(Vector2i(x, y))
	var drill_warmups_state = get("drill_warmups")
	if drill_warmups_state is Dictionary:
		drill_warmups_state[key] = warmup
		set("drill_warmups", drill_warmups_state)

func drill_last_speed_at_cell(x: int, y: int) -> float:
	var key := source_drill_cell_state_port_bridge_world_grid.cell_key(Vector2i(x, y))
	var drill_last_speeds_state = get("drill_last_speeds")
	if drill_last_speeds_state is Dictionary:
		return float(drill_last_speeds_state.get(key, 0.0))
	return 0.0

func set_drill_last_speed_at_cell(x: int, y: int, value: float) -> void:
	var key := source_drill_cell_state_port_bridge_world_grid.cell_key(Vector2i(x, y))
	var drill_last_speeds_state = get("drill_last_speeds")
	if drill_last_speeds_state is Dictionary:
		drill_last_speeds_state[key] = value
		set("drill_last_speeds", drill_last_speeds_state)

func drill_time_drilled_at_cell(x: int, y: int) -> float:
	var key := source_drill_cell_state_port_bridge_world_grid.cell_key(Vector2i(x, y))
	var drill_time_drilled_state = get("drill_time_drilled")
	if drill_time_drilled_state is Dictionary:
		return float(drill_time_drilled_state.get(key, 0.0))
	return 0.0

func set_drill_time_drilled_at_cell(x: int, y: int, value: float) -> void:
	var key := source_drill_cell_state_port_bridge_world_grid.cell_key(Vector2i(x, y))
	var drill_time_drilled_state = get("drill_time_drilled")
	if drill_time_drilled_state is Dictionary:
		drill_time_drilled_state[key] = value
		set("drill_time_drilled", drill_time_drilled_state)
