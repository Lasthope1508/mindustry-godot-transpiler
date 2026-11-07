extends "res://src/game/SourceGameSimulationPortBridge.gd"

const source_gameplay_factory_runtime_state := preload("res://src/game/SourceFactoryRuntimeState.gd")
const source_gameplay_factory_simulation_apply_state_script := preload("res://src/game/SourceFactorySimulationApplyState.gd")
const source_gameplay_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_gameplay_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_gameplay_enemy_unit_runtime_state := preload("res://src/game/SourceEnemyUnitRuntimeState.gd")
const source_gameplay_wave_spawn_runtime_state := preload("res://src/game/SourceWaveSpawnRuntimeState.gd")
const source_gameplay_wave_timing_runtime_state_script := preload("res://src/game/SourceWaveTimingRuntimeState.gd")
const source_gameplay_game_over_core_destroyed_state_script := preload("res://src/game/SourceGameOverCoreDestroyedState.gd")
const source_gameplay_core_damage_runtime_state := preload("res://src/game/SourceCoreDamageRuntimeState.gd")
const source_gameplay_unit_metadata_state := preload("res://src/game/SourceUnitMetadataState.gd")
const source_gameplay_status_apply_state := preload("res://src/game/SourceStatusApplyState.gd")
const source_gameplay_turret_simulation_state := preload("res://src/game/SourceTurretSimulationState.gd")

func factory_cell_context() -> Dictionary:
	return source_gameplay_factory_runtime_state.game_factory_cell_context(self)

func source_factory_simulation_runtime_state(seconds: float) -> Dictionary:
	return source_gameplay_factory_runtime_state.simulation_runtime_state(self, seconds)

func source_factory_simulation_apply_state(factory_state: Dictionary) -> Dictionary:
	var runtime_drill_pos: Vector2i = get("drill_pos")
	var apply_context := source_gameplay_factory_simulation_apply_state_script.runtime_context(self, runtime_drill_pos)
	return source_gameplay_factory_simulation_apply_state_script.apply_state(factory_state, apply_context)

func factory_drill_dump_preview_state(seconds: float) -> Dictionary:
	return source_gameplay_factory_runtime_state.game_drill_dump_preview_state(self, seconds)

func step_factory_transport(seconds: float) -> Dictionary:
	return source_gameplay_factory_runtime_state.game_transport_step_state(self, seconds)

func step_factory_drill(seconds: float) -> Dictionary:
	return source_gameplay_factory_runtime_state.game_drill_step_state(self, seconds)

func factory_runtime_state() -> Dictionary:
	return source_gameplay_factory_runtime_state.game_playable_summary_state(self)

func source_block_is_damaged(sprite) -> bool:
	return source_gameplay_placed_block_state.damaged(sprite, source_gameplay_block_defaults.HEALTH_DAMAGED_EPSILON)

func selected_enemy_unit():
	return source_gameplay_enemy_unit_runtime_state.selected_enemy_unit(self)

func spawn_enemy_wave() -> void:
	source_gameplay_enemy_unit_runtime_state.spawn_wave(self)

func spawned_for_wave(group: Dictionary, wave_zero: int) -> int:
	return int(source_gameplay_wave_spawn_runtime_state.spawned_for_wave_state(group, wave_zero).get("spawned", 0))

func spawn_enemy_unit(unit_type, index: int) -> void:
	source_gameplay_enemy_unit_runtime_state.spawn_unit(self, unit_type, index)

func source_wave_timing_runtime_state(seconds: float) -> Dictionary:
	return source_gameplay_wave_timing_runtime_state_script.game_wave_timer_state(self, seconds)

func source_game_over_core_destroyed_state(core_health_value: float, game_over_value: bool, attack_mode := false) -> Dictionary:
	return source_gameplay_game_over_core_destroyed_state_script.core_destroyed_state(core_health_value, game_over_value, attack_mode)

func apply_core_damage(amount: float) -> Dictionary:
	return source_gameplay_core_damage_runtime_state.game_apply_core_damage(self, amount)

func enemy_runtime_state() -> Dictionary:
	return source_gameplay_enemy_unit_runtime_state.runtime_summary_state(self)

func source_unit_weapon_damage(unit_type) -> float:
	return source_gameplay_unit_metadata_state.game_unit_weapon_damage_state(self, unit_type)

func source_unit_world_speed(unit_type) -> float:
	return source_gameplay_unit_metadata_state.game_unit_world_speed(self, unit_type)

func source_unit_hit_size(unit_type) -> float:
	return source_gameplay_unit_metadata_state.unit_hit_size(unit_type)

func source_unit_health(unit_type) -> float:
	return source_gameplay_unit_metadata_state.unit_health(unit_type)

func source_status_apply_result(status_effect: String, duration: float, status_immune: bool) -> Dictionary:
	return source_gameplay_status_apply_state.apply_result_state(status_effect, duration, status_immune)

func source_angles_angle_dist(a: float, b: float) -> float:
	return float(call("source_arc_angles_angle_dist", a, b))

func source_unit_icon_state(type_ui_icon: String) -> Dictionary:
	return source_gameplay_unit_metadata_state.unit_icon_state(type_ui_icon)

func source_arc_mathf_num(value: bool) -> int:
	return 1 if value else 0

func turret_simulation_callbacks() -> Dictionary:
	return source_gameplay_turret_simulation_state.simulation_callbacks(self)

func turret_random_inaccuracy_offset(inaccuracy_range: float) -> float:
	return randf_range(-inaccuracy_range, inaccuracy_range)
