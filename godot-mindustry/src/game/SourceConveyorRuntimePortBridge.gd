extends "res://src/game/SourceTurretCellRegistryPortBridge.gd"

const source_conveyor_runtime_state := preload("res://src/game/SourceConveyorRuntimeState.gd")

func source_conveyor_world_speed(block_id: String) -> float:
	return source_conveyor_runtime_state.game_world_speed(self, block_id)

func source_conveyor_path_progress_rate(block_id: String) -> float:
	return source_conveyor_runtime_state.game_path_progress_rate(self, block_id)

func source_conveyor_path_progress_delta(block_id: String, seconds: float, time_scale := 1.0, efficiency := 1.0) -> float:
	return source_conveyor_runtime_state.game_path_progress_delta(self, block_id, seconds, time_scale, efficiency)

func source_conveyor_path_progress_delta_for_cell(x: int, y: int, seconds: float, efficiency := 1.0) -> float:
	return source_conveyor_runtime_state.game_path_progress_delta_for_cell(self, x, y, seconds, efficiency)
