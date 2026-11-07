extends "res://src/game/SourceGamePresentationPortBridge.gd"

const source_game_simulation_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_game_simulation_factory_runtime_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const source_game_simulation_enemy_unit_runtime_state := preload("res://src/game/SourceEnemyUnitRuntimeState.gd")
const source_game_simulation_turret_state := preload("res://src/game/SourceTurretSimulationState.gd")

func build_hud() -> void:
	call("build_campaign_shell")
	call("update_hud")

func simulate_block_time_scales(delta: float) -> void:
	source_game_simulation_placed_block_state.game_simulate_time_scales(self, delta)

func simulate_factory(delta: float) -> void:
	source_game_simulation_factory_runtime_state.simulate_factory(self, delta)

func simulate_drill_dump(delta: float) -> void:
	source_game_simulation_factory_runtime_state.apply_drill_dump(self, delta)

func simulate_enemy_units(delta: float) -> void:
	source_game_simulation_enemy_unit_runtime_state.simulate_units(self, delta)

func simulate_turrets(delta: float) -> void:
	source_game_simulation_turret_state.simulate_turrets(self, delta)
