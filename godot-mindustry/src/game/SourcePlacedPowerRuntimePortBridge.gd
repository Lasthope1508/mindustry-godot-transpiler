extends "res://src/game/SourceBulletTypePortBridge.gd"

const source_placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const source_placed_power_battery_runtime_state := preload("res://src/game/SourcePlacedPowerBatteryRuntimeState.gd")
const source_placed_power_distribution_runtime_state := preload("res://src/game/SourcePlacedPowerDistributionRuntimeState.gd")

func placed_power_graph_role_counts() -> Dictionary:
	return source_placed_power_graph_state.game_role_counts_state(self)

func placed_power_needed_state() -> Dictionary:
	return source_placed_power_graph_state.game_needed_state(self)

func placed_power_produced_state() -> Dictionary:
	return source_placed_power_graph_state.game_produced_state(self)

func placed_power_battery_state() -> Dictionary:
	return source_placed_power_graph_state.game_battery_state(self)

func placed_power_battery_runtime_state() -> Dictionary:
	return source_placed_power_battery_runtime_state.game_summary_state(self)

func placed_power_distribution_runtime_state() -> Dictionary:
	return source_placed_power_distribution_runtime_state.game_summary_state(self)

func placed_power_runtime_state() -> Dictionary:
	return source_placed_power_graph_state.game_runtime_state(self)
