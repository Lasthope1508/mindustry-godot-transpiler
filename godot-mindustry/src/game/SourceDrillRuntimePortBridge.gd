extends "res://src/game/SourceDrillCellStatePortBridge.gd"

const source_drill_consumption_runtime_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const source_drill_dump_runtime_state_script := preload("res://src/game/SourceDrillDumpRuntimeState.gd")
const source_drill_production_runtime_state_script := preload("res://src/game/SourceDrillProductionRuntimeState.gd")
const source_drill_runtime_state_script := preload("res://src/game/SourceDrillRuntimeState.gd")
const source_drill_runtime_port_bridge_block_metadata_state := preload("res://src/game/SourceBlockMetadataState.gd")
const source_drill_runtime_port_bridge_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_drill_runtime_port_bridge_factory_defaults := preload("res://src/game/SourceFactoryDefaults.gd")
const source_drill_runtime_port_bridge_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

func source_drill_dump_runtime_state(current_timer: float, source_delta: float, dump_interval: float) -> Dictionary:
	return source_drill_dump_runtime_state_script.dump_timer_state(current_timer, source_delta, dump_interval)

func source_drill_production_runtime_state(current_progress_fraction: float, drill_delay: float, output_delta: float, dominant_items: int, items_total: int, item_capacity: int) -> Dictionary:
	return source_drill_production_runtime_state_script.game_production_state(self, current_progress_fraction, drill_delay, output_delta, dominant_items, items_total, item_capacity)

func source_drill_runtime_state(seconds: float) -> Dictionary:
	var drill_pos = get("drill_pos")
	var drill_sprite: Variant = call("block_sprite_at_cell", drill_pos)
	# Drill.onProximityUpdate resolves the dominant item from the ores
	# under the drill (countOre), not from a game-global item id.
	var drill_output_item_id = source_drill_consumption_runtime_state.source_dominant_item_name_state(self, drill_sprite).get("item_id")
	var drill_ore_cell_count = get("drill_ore_cell_count")
	return source_drill_runtime_state_script.runtime_state(source_drill_runtime_state_script.runtime_context(self, seconds, drill_pos, source_drill_runtime_port_bridge_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL, drill_output_item_id, drill_ore_cell_count, source_drill_runtime_port_bridge_time_defaults.TICK_RATE), source_drill_runtime_state_script.runtime_callbacks(self))

func source_drill_dump_interval(block_id: String, time_scale := 1.0) -> float:
	return source_drill_dump_runtime_state_script.game_dump_interval(self, block_id, time_scale)

func source_drill_ore_count(block_id: String, cell: Vector2i, item_id: String) -> int:
	return source_drill_runtime_state_script.game_ore_count(self, block_id, cell, item_id)

func source_drill_delay(block_id: String, item_id: String) -> float:
	var content_catalog = get("content_catalog")
	return source_drill_runtime_state_script.drill_delay(block_id, item_id, content_catalog, source_drill_runtime_port_bridge_factory_defaults.DRILL_HARDNESS_MULTIPLIER)

func generated_drill_get_drill_time_bridge_state(block_id: String, item_id: String) -> Dictionary:
	var content_catalog = get("content_catalog")
	return source_drill_runtime_state_script.generated_get_drill_time_bridge_state(block_id, item_id, content_catalog, source_drill_runtime_port_bridge_factory_defaults.DRILL_HARDNESS_MULTIPLIER)

func source_drill_output_rate(block_id: String, item_id: String, return_count: int) -> float:
	return source_drill_runtime_state_script.game_output_rate(self, block_id, item_id, return_count)

func source_drill_warmup_speed(block_id: String) -> float:
	var content_catalog = get("content_catalog")
	return source_drill_runtime_port_bridge_block_metadata_state.block_warmup_speed(block_id, content_catalog)

func source_drill_warmup_state(current_warmup: float, speed: float, warmup_speed: float, source_delta: float) -> float:
	return source_drill_runtime_state_script.game_warmup_state(self, current_warmup, speed, warmup_speed, source_delta)

func source_drill_inactive_warmup_state(current_warmup: float, warmup_speed: float, source_delta: float) -> float:
	return source_drill_runtime_state_script.game_inactive_warmup_state(self, current_warmup, warmup_speed, source_delta)

func source_drill_last_speed(block_id: String, item_id: String, ore_count: int, warmup: float, speed := 1.0) -> float:
	return source_drill_runtime_state_script.game_last_speed(self, block_id, item_id, ore_count, warmup, speed)

func source_drill_last_speed_for_cell(x: int, y: int, item_id: String, dominant_items: int, warmup: float, speed := 1.0) -> float:
	return source_drill_runtime_state_script.game_last_speed_for_cell(self, x, y, item_id, dominant_items, warmup, speed)

func source_drill_time_drilled_delta(warmup: float, seconds: float, time_scale := 1.0) -> float:
	return source_drill_runtime_state_script.game_time_drilled_delta(self, warmup, seconds, time_scale)

func step_drill_time_drilled_cell(x: int, y: int, seconds: float, warmup: float) -> float:
	return source_drill_runtime_state_script.game_step_drill_time_drilled_cell(self, x, y, seconds, warmup)

func step_drill_warmup_cell(x: int, y: int, seconds: float, speed := 1.0) -> float:
	return source_drill_runtime_state_script.game_step_drill_warmup_cell(self, x, y, seconds, speed)

func source_drill_output_delta(dominant_items: int, seconds: float, time_scale := 1.0, warmup := 1.0, speed := 1.0) -> float:
	return source_drill_runtime_state_script.game_output_delta(self, dominant_items, seconds, time_scale, warmup, speed)

func source_drill_output_delta_for_cell(x: int, y: int, dominant_items: int, seconds: float, warmup := 1.0, speed := 1.0) -> float:
	return source_drill_runtime_state_script.game_output_delta_for_cell(self, x, y, dominant_items, seconds, warmup, speed)

func source_drill_output_batch(progress: float, delay: float, dominant_items: int, items_total: int, item_capacity: int) -> Dictionary:
	return source_drill_production_runtime_state_script.output_batch(progress, delay, dominant_items, items_total, item_capacity)

func source_drill_progress_fraction(progress: float, delay: float, has_dominant_item: bool) -> float:
	return source_drill_production_runtime_state_script.progress_fraction(progress, delay, has_dominant_item)
