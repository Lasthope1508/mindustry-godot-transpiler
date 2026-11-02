extends RefCounted
class_name SourceFactoryRuntimeState

const source_drill_consumption_runtime_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_drill_dump_runtime_state_script := preload("res://src/game/SourceDrillDumpRuntimeState.gd")
const source_drill_production_runtime_state_script := preload("res://src/game/SourceDrillProductionRuntimeState.gd")
const source_item_transport_runtime_state_script := preload("res://src/game/SourceItemTransportRuntimeState.gd")
const source_factory_simulation_runtime_state_script := preload("res://src/game/SourceFactorySimulationRuntimeState.gd")
const source_factory_simulation_apply_state_script := preload("res://src/game/SourceFactorySimulationApplyState.gd")

const SOURCE_FACTORY_DRILL_RUNTIME_STATE_METHOD_FALLBACK := "source_drill_runtime_state"
const SOURCE_FACTORY_DRILL_DUMP_RUNTIME_STATE_METHOD_FALLBACK := "factory_drill_dump_preview_state"
const SOURCE_FACTORY_DRILL_DUMP_PREVIEW_RUNTIME_STATE_METHOD_FALLBACK := "source_drill_dump_runtime_state"
const SOURCE_FACTORY_DUMP_DRILL_ITEM_TO_CORE_METHOD_FALLBACK := "source_dump_drill_item_to_core"
const SOURCE_FACTORY_ITEM_TRANSPORT_RUNTIME_STATE_METHOD_FALLBACK := "source_item_transport_runtime_state"
const SOURCE_FACTORY_CONVEYOR_PROGRESS_DELTA_FOR_CELL_METHOD_FALLBACK := "source_conveyor_path_progress_delta_for_cell"
const SOURCE_FACTORY_DRILL_DELAY_METHOD_FALLBACK := "source_drill_delay"
const SOURCE_FACTORY_DRILL_OUTPUT_DELTA_FOR_CELL_METHOD_FALLBACK := "source_drill_output_delta_for_cell"
const SOURCE_FACTORY_BLOCK_TIME_SCALE_AT_CELL_METHOD_FALLBACK := "source_block_time_scale_at_cell"
const SOURCE_FACTORY_SIMULATE_FACTORY_METHOD_FALLBACK := "simulate_factory"
const SOURCE_FACTORY_DRILL_DUMP_INTERVAL_METHOD_FALLBACK := "source_drill_dump_interval"
const SOURCE_FACTORY_SUMMARY_DRILL_BLOCK_ID_KEY := "drill_block_id"
const SOURCE_FACTORY_SUMMARY_CONVEYOR_BLOCK_ID_KEY := "conveyor_block_id"
const SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_ITEM_ID_KEY := "drill_output_item_id"
const SOURCE_FACTORY_SUMMARY_DRILL_ORE_CELL_COUNT_KEY := "drill_ore_cell_count"
const SOURCE_FACTORY_SUMMARY_DRILL_WARMUP_KEY := "drill_warmup"
const SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_RATE_KEY := "drill_output_rate"
const SOURCE_FACTORY_SUMMARY_CORE_INVENTORY_KEY := "core_inventory"
const SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY := "produced_total"
const SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY := "conveyor_world_speed"
const SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY := "conveyor_path_progress_rate"
const SOURCE_FACTORY_SUMMARY_DRILL_DELAY_KEY := "drill_delay"
const SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_DELTA_FOR_CELL_CALLBACK_KEY := "drill_output_delta_for_cell"
const SOURCE_FACTORY_SUMMARY_CONVEYOR_PROGRESS_DELTA_FOR_CELL_CALLBACK_KEY := "conveyor_progress_delta_for_cell"
const SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_DELTA_PER_SECOND_KEY := "drill_output_delta_per_second"
const SOURCE_FACTORY_SUMMARY_CONVEYOR_PROGRESS_DELTA_PER_SECOND_KEY := "conveyor_progress_delta_per_second"
const SOURCE_FACTORY_SUMMARY_SOURCE_OWNER_KEY := "source_owner"
const SOURCE_FACTORY_STEP_CONVEYOR_PROGRESS_DELTA_FOR_CELL_CALLBACK_KEY := "conveyor_progress_delta_for_cell"
const SOURCE_FACTORY_STEP_SIMULATE_FACTORY_CALLBACK_KEY := "simulate_factory"
const SOURCE_FACTORY_STEP_BLOCK_TIME_SCALE_AT_CELL_CALLBACK_KEY := "block_time_scale_at_cell"
const SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_BEFORE_KEY := "transport_progress_before"
const SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_DELTA_KEY := "transport_progress_delta"
const SOURCE_FACTORY_STEP_CONVEYOR_PROGRESS_DELTA_KEY := "conveyor_progress_delta"
const SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_KEY := "transport_progress"
const SOURCE_FACTORY_STEP_CONVEYOR_TIME_SCALE_KEY := "conveyor_time_scale"
const SOURCE_FACTORY_STEP_ITEM_PROGRESS_BEFORE_KEY := "item_progress_before"
const SOURCE_FACTORY_STEP_DRILL_WARMUP_BEFORE_KEY := "drill_warmup_before"
const SOURCE_FACTORY_STEP_DRILL_OUTPUT_DELTA_KEY := "drill_output_delta"

static func game_summary_state(game: Object, drill_block_id: String, conveyor_block_id: String) -> Dictionary:
	var factory_context: Dictionary = summary_context(game, game.call("factory_cell_context"), game.get("drill_pos"), drill_block_id, conveyor_block_id)
	return summary_state(factory_context, summary_callbacks(game))

static func apply_drill_dump(game: Object, delta: float) -> void:
	var dump_state: Dictionary = game.call(SOURCE_FACTORY_DRILL_DUMP_RUNTIME_STATE_METHOD_FALLBACK, delta)
	game.set(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_TIMER_KEY, float(dump_state.get(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_TIMER_KEY, game.get(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_TIMER_KEY))))
	if bool(dump_state.get(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_SHOULD_DUMP_KEY, false)):
		game.call(SOURCE_FACTORY_DUMP_DRILL_ITEM_TO_CORE_METHOD_FALLBACK, str(game.get(SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_ITEM_ID_KEY)))


static func runtime_method_names(game: Object) -> Dictionary:
	if game == null:
		return {}
	if game.has_method("_factory_runtime_method_names"):
		var names = game.call("_factory_runtime_method_names")
		if names is Dictionary:
			return names
	return {}


static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return str(method_names.get(key, fallback_name))


static func cell_context(drill_cell: Vector2i, conveyor_cells: Array[Vector2i]) -> Dictionary:
	var conveyor_cell := Vector2i(drill_cell.x + 1, drill_cell.y)
	if not conveyor_cells.is_empty():
		conveyor_cell = conveyor_cells[0]
	return {
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_CELL_KEY: drill_cell,
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_CONVEYOR_CELL_KEY: conveyor_cell,
	}


static func simulation_context(seconds: float, transport_progress: float, factory_cells: Dictionary, fallback_cell: Vector2i) -> Dictionary:
	return {
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_SECONDS_KEY: seconds,
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_TRANSPORT_PROGRESS_KEY: transport_progress,
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_CELL_KEY: factory_cells.get(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_CELL_KEY, fallback_cell),
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_CONVEYOR_CELL_KEY: factory_cells.get(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_CONVEYOR_CELL_KEY, fallback_cell),
	}


static func simulation_callbacks(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	var drill_runtime_state_method := runtime_method_name(method_names, source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_RUNTIME_STATE_KEY, SOURCE_FACTORY_DRILL_RUNTIME_STATE_METHOD_FALLBACK)
	var drill_dump_runtime_state_method := runtime_method_name(method_names, source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_DUMP_RUNTIME_STATE_KEY, SOURCE_FACTORY_DRILL_DUMP_RUNTIME_STATE_METHOD_FALLBACK)
	var item_transport_runtime_state_method := runtime_method_name(method_names, source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_ITEM_TRANSPORT_RUNTIME_STATE_KEY, SOURCE_FACTORY_ITEM_TRANSPORT_RUNTIME_STATE_METHOD_FALLBACK)
	var conveyor_progress_delta_method := runtime_method_name(method_names, source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_CONVEYOR_PROGRESS_DELTA_FOR_CELL_KEY, SOURCE_FACTORY_CONVEYOR_PROGRESS_DELTA_FOR_CELL_METHOD_FALLBACK)
	return {
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_RUNTIME_STATE_KEY: Callable(game, drill_runtime_state_method),
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_DUMP_RUNTIME_STATE_KEY: Callable(game, drill_dump_runtime_state_method),
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_ITEM_TRANSPORT_RUNTIME_STATE_KEY: Callable(game, item_transport_runtime_state_method),
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_CONVEYOR_PROGRESS_DELTA_FOR_CELL_KEY: Callable(game, conveyor_progress_delta_method),
	}


static func simulation_runtime_state(game: Object, seconds: float) -> Dictionary:
	var factory_context: Dictionary = simulation_context(seconds, game.get(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_TRANSPORT_PROGRESS_KEY), game.call("factory_cell_context"), game.get("drill_pos"))
	return source_factory_simulation_runtime_state_script.simulation_state(factory_context, simulation_callbacks(game))

static func simulate_factory(game: Object, delta: float) -> void:
	if game == null:
		return
	var path_points_value = game.get("path_points")
	if not (path_points_value is Array) or path_points_value.is_empty():
		return
	var drill_cell: Vector2i = game.get("drill_pos")
	var drill_output_item_id: Variant = source_drill_consumption_runtime_state.source_dominant_item_name_state(game, game.call("block_sprite_at_cell", drill_cell))["item_id"]
	var factory_state: Dictionary = source_drill_consumption_runtime_state.source_factory_state(game, delta)
	var apply_state: Dictionary = game.call("source_factory_simulation_apply_state", factory_state)
	game.call("set_drill_time_drilled_at_cell", drill_cell.x, drill_cell.y, float(apply_state.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_DRILL_TIME_DRILLED_KEY, game.call("drill_time_drilled_at_cell", drill_cell.x, drill_cell.y))))
	game.call("set_drill_last_speed_at_cell", drill_cell.x, drill_cell.y, float(apply_state.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_DRILL_LAST_SPEED_KEY, game.call("drill_last_speed_at_cell", drill_cell.x, drill_cell.y))))
	game.call("set_drill_warmup_at_cell", drill_cell.x, drill_cell.y, float(apply_state.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_DRILL_WARMUP_KEY, game.call("drill_warmup_at_cell", drill_cell.x, drill_cell.y))))
	game.set(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_ITEM_PROGRESS_KEY, float(apply_state.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_ITEM_PROGRESS_KEY, game.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_ITEM_PROGRESS_KEY))))
	var offload_amount := int(apply_state.get(source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_OFFLOAD_AMOUNT_KEY, 0))
	if drill_output_item_id != null and offload_amount > 0:
		game.call("source_offload_to_inventory", drill_output_item_id, offload_amount)
	game.set(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_PRODUCED_TOTAL_KEY, int(apply_state.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_PRODUCED_TOTAL_KEY, game.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_PRODUCED_TOTAL_KEY))))
	game.set(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_TIMER_KEY, float(apply_state.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_DRILL_DUMP_TIMER_KEY, game.get(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_TIMER_KEY))))
	if drill_output_item_id != null and bool(apply_state.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_SHOULD_DUMP_KEY, false)):
		game.call(SOURCE_FACTORY_DUMP_DRILL_ITEM_TO_CORE_METHOD_FALLBACK, drill_output_item_id)
	game.set(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_TRANSPORT_PROGRESS_KEY, float(apply_state.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_TRANSPORT_PROGRESS_KEY, game.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_TRANSPORT_PROGRESS_KEY))))
	var item_sprites_value = game.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_ITEM_SPRITES_KEY)
	if not (item_sprites_value is Array):
		return
	var item_sprites: Array = item_sprites_value
	for item_sprite_state in apply_state.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_ITEM_SPRITES_KEY, []):
		var item_index := int(item_sprite_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_INDEX_KEY, -1))
		if item_index < 0 or item_index >= item_sprites.size():
			continue
		item_sprites[item_index].position = Vector2(float(item_sprite_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_X_KEY, item_sprites[item_index].position.x)), float(item_sprite_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_Y_KEY, item_sprites[item_index].position.y)))
		item_sprites[item_index].visible = bool(item_sprite_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_VISIBLE_KEY, item_sprites[item_index].visible))


static func summary_context(game: Object, factory_cells: Dictionary, fallback_cell: Vector2i, drill_block_id: String, conveyor_block_id: String) -> Dictionary:
	return {
		SOURCE_FACTORY_SUMMARY_DRILL_BLOCK_ID_KEY: drill_block_id,
		SOURCE_FACTORY_SUMMARY_CONVEYOR_BLOCK_ID_KEY: conveyor_block_id,
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_CELL_KEY: factory_cells.get(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_CELL_KEY, fallback_cell),
		source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_CONVEYOR_CELL_KEY: factory_cells.get(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_CONVEYOR_CELL_KEY, fallback_cell),
		SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_ITEM_ID_KEY: str(game.get(SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_ITEM_ID_KEY)),
		SOURCE_FACTORY_SUMMARY_DRILL_ORE_CELL_COUNT_KEY: int(game.get(SOURCE_FACTORY_SUMMARY_DRILL_ORE_CELL_COUNT_KEY)),
		SOURCE_FACTORY_SUMMARY_DRILL_WARMUP_KEY: game.call("drill_warmup_at_cell", fallback_cell.x, fallback_cell.y),
		SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_RATE_KEY: float(game.get(SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_RATE_KEY)),
		SOURCE_FACTORY_SUMMARY_CORE_INVENTORY_KEY: int(game.get(SOURCE_FACTORY_SUMMARY_CORE_INVENTORY_KEY)),
		SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY: int(game.get(SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY)),
		SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY: float(game.get(SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY)),
		SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY: float(game.get(SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY)),
	}


static func summary_callbacks(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	var drill_delay_method := runtime_method_name(method_names, SOURCE_FACTORY_SUMMARY_DRILL_DELAY_KEY, SOURCE_FACTORY_DRILL_DELAY_METHOD_FALLBACK)
	var drill_output_delta_method := runtime_method_name(method_names, SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_DELTA_FOR_CELL_CALLBACK_KEY, SOURCE_FACTORY_DRILL_OUTPUT_DELTA_FOR_CELL_METHOD_FALLBACK)
	var conveyor_progress_delta_method := runtime_method_name(method_names, SOURCE_FACTORY_SUMMARY_CONVEYOR_PROGRESS_DELTA_FOR_CELL_CALLBACK_KEY, SOURCE_FACTORY_CONVEYOR_PROGRESS_DELTA_FOR_CELL_METHOD_FALLBACK)
	return {
		SOURCE_FACTORY_SUMMARY_DRILL_DELAY_KEY: Callable(game, drill_delay_method),
		SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_DELTA_FOR_CELL_CALLBACK_KEY: Callable(game, drill_output_delta_method),
		SOURCE_FACTORY_SUMMARY_CONVEYOR_PROGRESS_DELTA_FOR_CELL_CALLBACK_KEY: Callable(game, conveyor_progress_delta_method),
	}


static func summary_state(factory_context: Dictionary, factory_callbacks: Dictionary) -> Dictionary:
	var drill_block_id := str(factory_context.get(SOURCE_FACTORY_SUMMARY_DRILL_BLOCK_ID_KEY, ""))
	var drill_output_item_id := str(factory_context.get(SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_ITEM_ID_KEY, ""))
	var drill_ore_cell_count := int(factory_context.get(SOURCE_FACTORY_SUMMARY_DRILL_ORE_CELL_COUNT_KEY, 0))
	var drill_cell: Vector2i = factory_context.get(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_CELL_KEY, Vector2i.ZERO)
	var conveyor_cell: Vector2i = factory_context.get(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_CONVEYOR_CELL_KEY, Vector2i.ZERO)
	var drill_warmup := float(factory_context.get(SOURCE_FACTORY_SUMMARY_DRILL_WARMUP_KEY, 0.0))
	var drill_output_rate := float(factory_context.get(SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_RATE_KEY, 0.0))
	var drill_delay_fn: Callable = factory_callbacks.get(SOURCE_FACTORY_SUMMARY_DRILL_DELAY_KEY, Callable())
	var drill_output_delta_for_cell_fn: Callable = factory_callbacks.get(SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_DELTA_FOR_CELL_CALLBACK_KEY, Callable())
	var conveyor_progress_delta_for_cell_fn: Callable = factory_callbacks.get(SOURCE_FACTORY_SUMMARY_CONVEYOR_PROGRESS_DELTA_FOR_CELL_CALLBACK_KEY, Callable())
	var drill_delay := float(drill_delay_fn.call(drill_block_id, drill_output_item_id))
	var drill_output_delta := float(drill_output_delta_for_cell_fn.call(drill_cell.x, drill_cell.y, drill_ore_cell_count, 1.0, drill_warmup))
	var conveyor_progress_delta := float(conveyor_progress_delta_for_cell_fn.call(conveyor_cell.x, conveyor_cell.y, 1.0))
	return {
		SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_ITEM_ID_KEY: drill_output_item_id,
		SOURCE_FACTORY_SUMMARY_DRILL_DELAY_KEY: drill_delay,
		SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_DELTA_PER_SECOND_KEY: drill_output_delta,
		SOURCE_FACTORY_SUMMARY_CONVEYOR_PROGRESS_DELTA_PER_SECOND_KEY: conveyor_progress_delta,
		SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_RATE_KEY: drill_output_rate,
		SOURCE_FACTORY_SUMMARY_CORE_INVENTORY_KEY: int(factory_context.get(SOURCE_FACTORY_SUMMARY_CORE_INVENTORY_KEY, 0)),
		SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY: int(factory_context.get(SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY, 0)),
		SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY: float(factory_context.get(SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY, 0.0)),
		SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY: float(factory_context.get(SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY, 0.0)),
		SOURCE_FACTORY_SUMMARY_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_FACTORY_RUNTIME_STATE,
	}


static func transport_step_context(game: Object, seconds: float, factory_cells: Dictionary, fallback_cell: Vector2i) -> Dictionary:
	var method_names := runtime_method_names(game)
	var conveyor_delta_method := runtime_method_name(method_names, SOURCE_FACTORY_STEP_CONVEYOR_PROGRESS_DELTA_FOR_CELL_CALLBACK_KEY, SOURCE_FACTORY_CONVEYOR_PROGRESS_DELTA_FOR_CELL_METHOD_FALLBACK)
	var simulate_method := runtime_method_name(method_names, SOURCE_FACTORY_STEP_SIMULATE_FACTORY_CALLBACK_KEY, SOURCE_FACTORY_SIMULATE_FACTORY_METHOD_FALLBACK)
	var block_time_scale_method := runtime_method_name(method_names, SOURCE_FACTORY_STEP_BLOCK_TIME_SCALE_AT_CELL_CALLBACK_KEY, SOURCE_FACTORY_BLOCK_TIME_SCALE_AT_CELL_METHOD_FALLBACK)
	var conveyor_cell: Vector2i = factory_cells.get(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_CONVEYOR_CELL_KEY, fallback_cell)
	var transport_progress_before_value: float = game.get(SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_KEY)
	var transport_progress_delta_value: float = game.call(conveyor_delta_method, conveyor_cell.x, conveyor_cell.y, seconds)
	var conveyor_time_scale_value: float = game.call(block_time_scale_method, conveyor_cell.x, conveyor_cell.y)
	game.call(simulate_method, seconds)
	return {
		SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_BEFORE_KEY: transport_progress_before_value,
		SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_DELTA_KEY: transport_progress_delta_value,
		SOURCE_FACTORY_STEP_CONVEYOR_TIME_SCALE_KEY: conveyor_time_scale_value,
		SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY: float(game.get(SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY)),
		SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY: float(game.get(SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY)),
	}


static func transport_step_state(step_context: Dictionary) -> Dictionary:
	var transport_progress_before := float(step_context.get(SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_BEFORE_KEY, 0.0))
	var transport_progress_delta := float(step_context.get(SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_DELTA_KEY, 0.0))
	return {
		SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_BEFORE_KEY: transport_progress_before,
		SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_DELTA_KEY: transport_progress_delta,
		SOURCE_FACTORY_STEP_CONVEYOR_PROGRESS_DELTA_KEY: transport_progress_delta,
		SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_KEY: fmod(transport_progress_before + transport_progress_delta, 1.0),
		SOURCE_FACTORY_STEP_CONVEYOR_TIME_SCALE_KEY: float(step_context.get(SOURCE_FACTORY_STEP_CONVEYOR_TIME_SCALE_KEY, 1.0)),
		SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY: float(step_context.get(SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY, 0.0)),
		SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY: float(step_context.get(SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY, 0.0)),
	}


static func drill_step_context(game: Object, seconds: float, drill_cell: Vector2i) -> Dictionary:
	var method_names := runtime_method_names(game)
	var drill_output_delta_method := runtime_method_name(method_names, SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_DELTA_FOR_CELL_CALLBACK_KEY, SOURCE_FACTORY_DRILL_OUTPUT_DELTA_FOR_CELL_METHOD_FALLBACK)
	var item_progress_before_value: float = game.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_ITEM_PROGRESS_KEY)
	var drill_warmup_before_value: float = game.call("drill_warmup_at_cell", drill_cell.x, drill_cell.y)
	var drill_warmup_value: float = game.call("step_drill_warmup_cell", drill_cell.x, drill_cell.y, seconds)
	var drill_ore_cell_count_value := int(game.get(SOURCE_FACTORY_SUMMARY_DRILL_ORE_CELL_COUNT_KEY))
	var drill_output_delta_value: float = game.call(drill_output_delta_method, drill_cell.x, drill_cell.y, drill_ore_cell_count_value, seconds, drill_warmup_value)
	return {
		SOURCE_FACTORY_STEP_ITEM_PROGRESS_BEFORE_KEY: item_progress_before_value,
		SOURCE_FACTORY_STEP_DRILL_WARMUP_BEFORE_KEY: drill_warmup_before_value,
		SOURCE_FACTORY_SUMMARY_DRILL_WARMUP_KEY: drill_warmup_value,
		SOURCE_FACTORY_STEP_DRILL_OUTPUT_DELTA_KEY: drill_output_delta_value,
		SOURCE_FACTORY_SUMMARY_DRILL_ORE_CELL_COUNT_KEY: drill_ore_cell_count_value,
		SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY: int(game.get(SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY)),
	}


static func drill_step_state(step_context: Dictionary) -> Dictionary:
	var item_progress_before := float(step_context.get(SOURCE_FACTORY_STEP_ITEM_PROGRESS_BEFORE_KEY, 0.0))
	var drill_warmup := float(step_context.get(SOURCE_FACTORY_SUMMARY_DRILL_WARMUP_KEY, 0.0))
	var drill_output_delta := float(step_context.get(SOURCE_FACTORY_STEP_DRILL_OUTPUT_DELTA_KEY, 0.0))
	return {
		SOURCE_FACTORY_STEP_ITEM_PROGRESS_BEFORE_KEY: item_progress_before,
		SOURCE_FACTORY_SUMMARY_DRILL_WARMUP_KEY: drill_warmup,
		SOURCE_FACTORY_STEP_DRILL_OUTPUT_DELTA_KEY: drill_output_delta,
		SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY: int(step_context.get(SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY, 0)),
	}


static func drill_dump_preview_context(game: Object, seconds: float, drill_cell: Vector2i, block_id: String, source_tick_rate: float) -> Dictionary:
	var method_names := runtime_method_names(game)
	var block_time_scale_method := runtime_method_name(method_names, SOURCE_FACTORY_STEP_BLOCK_TIME_SCALE_AT_CELL_CALLBACK_KEY, SOURCE_FACTORY_BLOCK_TIME_SCALE_AT_CELL_METHOD_FALLBACK)
	var drill_dump_interval_method := runtime_method_name(method_names, source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_INTERVAL_CALLBACK_KEY, SOURCE_FACTORY_DRILL_DUMP_INTERVAL_METHOD_FALLBACK)
	var drill_dump_runtime_state_method := runtime_method_name(method_names, source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_PREVIEW_RUNTIME_STATE_CALLBACK_KEY, SOURCE_FACTORY_DRILL_DUMP_PREVIEW_RUNTIME_STATE_METHOD_FALLBACK)
	var block_time_scale_value: float = game.call(block_time_scale_method, drill_cell.x, drill_cell.y)
	var dump_interval_value: float = game.call(drill_dump_interval_method, block_id, block_time_scale_value)
	var drill_dump_timer_value: float = game.get(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_TIMER_KEY)
	return {
		source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_CURRENT_TIMER_KEY: drill_dump_timer_value,
		source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_SOURCE_DELTA_KEY: seconds * source_tick_rate,
		source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_INTERVAL_KEY: dump_interval_value,
		source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_RUNTIME_STATE_METHOD_KEY: drill_dump_runtime_state_method,
	}


static func drill_dump_preview_state(game: Object, preview_context: Dictionary) -> Dictionary:
	var current_timer := float(preview_context.get(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_CURRENT_TIMER_KEY, 0.0))
	var source_delta := float(preview_context.get(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_SOURCE_DELTA_KEY, 0.0))
	var dump_interval := float(preview_context.get(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_INTERVAL_KEY, 0.0))
	var drill_dump_runtime_state_method := str(preview_context.get(source_drill_dump_runtime_state_script.SOURCE_DRILL_DUMP_RUNTIME_STATE_METHOD_KEY, SOURCE_FACTORY_DRILL_DUMP_PREVIEW_RUNTIME_STATE_METHOD_FALLBACK))
	return game.call(drill_dump_runtime_state_method, current_timer, source_delta, dump_interval)
