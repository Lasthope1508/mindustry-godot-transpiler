extends RefCounted
class_name SourceFactoryRuntimeState

const source_drill_consumption_runtime_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_conveyor_runtime_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const source_placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const source_placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")
const source_power_graph_state := preload("res://src/game/SourcePowerGraphState.gd")
const source_pump_runtime_state := preload("res://src/game/SourcePumpRuntimeState.gd")
const source_conduit_runtime_state := preload("res://src/game/SourceConduitRuntimeState.gd")
const source_continuous_liquid_turret_build_state := preload("res://src/game/SourceContinuousLiquidTurretBuildState.gd")
const source_turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
const source_factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const source_unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
const source_adjacent_factory_build_state := preload("res://src/game/SourceAdjacentFactoryBuildState.gd")

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_drill_dump_runtime_state_script := preload("res://src/game/SourceDrillDumpRuntimeState.gd")
const source_drill_production_runtime_state_script := preload("res://src/game/SourceDrillProductionRuntimeState.gd")
const source_item_transport_runtime_state_script := preload("res://src/game/SourceItemTransportRuntimeState.gd")
const source_factory_simulation_runtime_state_script := preload("res://src/game/SourceFactorySimulationRuntimeState.gd")
const source_factory_simulation_apply_state_script := preload("res://src/game/SourceFactorySimulationApplyState.gd")
const source_factory_source_text_state := preload("res://src/game/SourceFactorySourceTextState.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

const SOURCE_FACTORY_DRILL_RUNTIME_STATE_METHOD_FALLBACK := source_factory_source_text_state.SOURCE_FACTORY_DRILL_RUNTIME_STATE_METHOD_FALLBACK
const SOURCE_FACTORY_DRILL_DUMP_RUNTIME_STATE_METHOD_FALLBACK := source_factory_source_text_state.SOURCE_FACTORY_DRILL_DUMP_RUNTIME_STATE_METHOD_FALLBACK
const SOURCE_FACTORY_DRILL_DUMP_PREVIEW_RUNTIME_STATE_METHOD_FALLBACK := source_factory_source_text_state.SOURCE_FACTORY_DRILL_DUMP_PREVIEW_RUNTIME_STATE_METHOD_FALLBACK
const SOURCE_FACTORY_DUMP_DRILL_ITEM_TO_CORE_METHOD_FALLBACK := source_factory_source_text_state.SOURCE_FACTORY_DUMP_DRILL_ITEM_TO_CORE_METHOD_FALLBACK
const SOURCE_FACTORY_ITEM_TRANSPORT_RUNTIME_STATE_METHOD_FALLBACK := source_factory_source_text_state.SOURCE_FACTORY_ITEM_TRANSPORT_RUNTIME_STATE_METHOD_FALLBACK
const SOURCE_FACTORY_CONVEYOR_PROGRESS_DELTA_FOR_CELL_METHOD_FALLBACK := source_factory_source_text_state.SOURCE_FACTORY_CONVEYOR_PROGRESS_DELTA_FOR_CELL_METHOD_FALLBACK
const SOURCE_FACTORY_DRILL_DELAY_METHOD_FALLBACK := source_factory_source_text_state.SOURCE_FACTORY_DRILL_DELAY_METHOD_FALLBACK
const SOURCE_FACTORY_DRILL_OUTPUT_DELTA_FOR_CELL_METHOD_FALLBACK := source_factory_source_text_state.SOURCE_FACTORY_DRILL_OUTPUT_DELTA_FOR_CELL_METHOD_FALLBACK
const SOURCE_FACTORY_BLOCK_TIME_SCALE_AT_CELL_METHOD_FALLBACK := source_factory_source_text_state.SOURCE_FACTORY_BLOCK_TIME_SCALE_AT_CELL_METHOD_FALLBACK
const SOURCE_FACTORY_SIMULATE_FACTORY_METHOD_FALLBACK := source_factory_source_text_state.SOURCE_FACTORY_SIMULATE_FACTORY_METHOD_FALLBACK
const SOURCE_FACTORY_DRILL_DUMP_INTERVAL_METHOD_FALLBACK := source_factory_source_text_state.SOURCE_FACTORY_DRILL_DUMP_INTERVAL_METHOD_FALLBACK
const SOURCE_FACTORY_SUMMARY_DRILL_BLOCK_ID_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_DRILL_BLOCK_ID_KEY
const SOURCE_FACTORY_SUMMARY_CONVEYOR_BLOCK_ID_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_CONVEYOR_BLOCK_ID_KEY
const SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_ITEM_ID_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_ITEM_ID_KEY
const SOURCE_FACTORY_SUMMARY_DRILL_ORE_CELL_COUNT_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_DRILL_ORE_CELL_COUNT_KEY
const SOURCE_FACTORY_SUMMARY_DRILL_WARMUP_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_DRILL_WARMUP_KEY
const SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_RATE_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_RATE_KEY
const SOURCE_FACTORY_SUMMARY_CORE_INVENTORY_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_CORE_INVENTORY_KEY
const SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_PRODUCED_TOTAL_KEY
const SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_CONVEYOR_WORLD_SPEED_KEY
const SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_CONVEYOR_PATH_PROGRESS_RATE_KEY
const SOURCE_FACTORY_SUMMARY_DRILL_DELAY_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_DRILL_DELAY_KEY
const SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_DELTA_FOR_CELL_CALLBACK_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_DELTA_FOR_CELL_CALLBACK_KEY
const SOURCE_FACTORY_SUMMARY_CONVEYOR_PROGRESS_DELTA_FOR_CELL_CALLBACK_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_CONVEYOR_PROGRESS_DELTA_FOR_CELL_CALLBACK_KEY
const SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_DELTA_PER_SECOND_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_DRILL_OUTPUT_DELTA_PER_SECOND_KEY
const SOURCE_FACTORY_SUMMARY_CONVEYOR_PROGRESS_DELTA_PER_SECOND_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_CONVEYOR_PROGRESS_DELTA_PER_SECOND_KEY
const SOURCE_FACTORY_SUMMARY_SOURCE_OWNER_KEY := source_factory_source_text_state.SOURCE_FACTORY_SUMMARY_SOURCE_OWNER_KEY
const SOURCE_FACTORY_STEP_CONVEYOR_PROGRESS_DELTA_FOR_CELL_CALLBACK_KEY := source_factory_source_text_state.SOURCE_FACTORY_STEP_CONVEYOR_PROGRESS_DELTA_FOR_CELL_CALLBACK_KEY
const SOURCE_FACTORY_STEP_SIMULATE_FACTORY_CALLBACK_KEY := source_factory_source_text_state.SOURCE_FACTORY_STEP_SIMULATE_FACTORY_CALLBACK_KEY
const SOURCE_FACTORY_STEP_BLOCK_TIME_SCALE_AT_CELL_CALLBACK_KEY := source_factory_source_text_state.SOURCE_FACTORY_STEP_BLOCK_TIME_SCALE_AT_CELL_CALLBACK_KEY
const SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_BEFORE_KEY := source_factory_source_text_state.SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_BEFORE_KEY
const SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_DELTA_KEY := source_factory_source_text_state.SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_DELTA_KEY
const SOURCE_FACTORY_STEP_CONVEYOR_PROGRESS_DELTA_KEY := source_factory_source_text_state.SOURCE_FACTORY_STEP_CONVEYOR_PROGRESS_DELTA_KEY
const SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_KEY := source_factory_source_text_state.SOURCE_FACTORY_STEP_TRANSPORT_PROGRESS_KEY
const SOURCE_FACTORY_STEP_CONVEYOR_TIME_SCALE_KEY := source_factory_source_text_state.SOURCE_FACTORY_STEP_CONVEYOR_TIME_SCALE_KEY
const SOURCE_FACTORY_STEP_ITEM_PROGRESS_BEFORE_KEY := source_factory_source_text_state.SOURCE_FACTORY_STEP_ITEM_PROGRESS_BEFORE_KEY
const SOURCE_FACTORY_STEP_DRILL_WARMUP_BEFORE_KEY := source_factory_source_text_state.SOURCE_FACTORY_STEP_DRILL_WARMUP_BEFORE_KEY
const SOURCE_FACTORY_STEP_DRILL_OUTPUT_DELTA_KEY := source_factory_source_text_state.SOURCE_FACTORY_STEP_DRILL_OUTPUT_DELTA_KEY

static func game_summary_state(game: Object, drill_block_id: String, conveyor_block_id: String) -> Dictionary:
	var factory_context: Dictionary = summary_context(game, game_factory_cell_context(game), game.get("drill_pos"), drill_block_id, conveyor_block_id)
	return summary_state(factory_context, summary_callbacks(game))

static func game_playable_summary_state(game: Object) -> Dictionary:
	return game_summary_state(game, source_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL, source_playable_scenario_defaults.BLOCK_CONVEYOR)

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


static func game_factory_cell_context(game: Object) -> Dictionary:
	return cell_context(game.get("drill_pos"), source_playable_scenario_defaults.conveyor_cells())

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
	var factory_context: Dictionary = simulation_context(seconds, game.get(source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_TRANSPORT_PROGRESS_KEY), game_factory_cell_context(game), game.get("drill_pos"))
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
	source_factory_dump_all_drill_outputs_state(game, bool(apply_state.get(source_factory_simulation_apply_state_script.SOURCE_FACTORY_APPLY_SHOULD_DUMP_KEY, false)))
	var advance_cells: Array = source_playable_scenario_defaults.conveyor_cells()
	advance_cells.reverse()
	source_factory_advance_conveyors_state(game, advance_cells, delta)
	source_factory_update_power_graph_state(game, delta)
	source_pump_runtime_state.source_pump_update_state(game, source_playable_scenario_defaults.PUMP_POS, delta)
	source_pump_runtime_state.source_pump_dump_liquid_state(game, source_playable_scenario_defaults.PUMP_POS)
	for conduit_cell in source_playable_scenario_defaults.conduit_cells():
		source_conduit_runtime_state.source_conduit_update_state(game, conduit_cell, delta)
	# The turret tick runs every live-loop tick (N2103): each placed
	# ContinuousLiquidTurret gets its frame keys refreshed from its
	# live liquid module, so the N2101 cost multiplier is actually
	# paid live (ContinuousLiquidTurretBuild.updateTile()).
	source_continuous_liquid_turret_build_state.source_tick_buildings_state(game, delta)
	# The turret-family tick runs every live-loop tick (N2108): each
	# placed Turret-family build (ItemTurret/LiquidTurret/PowerTurret
	# and their subclasses) gets its frame keys refreshed from the
	# live rules, so a cheating team's turret skips ammo consumption
	# (TurretBuild.useAmmo(), Turret.java:682).
	source_turret_build_state.source_turret_tick_buildings_state(game, delta)
	# The factory-family tick runs every live-loop tick (N2109): each
	# placed factory-family build (GenericCrafter/AttributeCrafter/
	# HeatCrafter/HeatProducer, whose builds run
	# GenericCrafterBuild.updateTile(), GenericCrafter.java:235) gets
	# its frame keys refreshed from the live rules, so a cheating
	# team's factory counts everything as valid
	# (BuildingComp.updateConsumption(), BuildingComp.java:1944-1945).
	source_factory_build_state.source_factory_tick_buildings_state(game, delta)
	# The factory-family tick runs every live-loop tick (N2109): each
	# placed factory-family build (UnitFactory/Reconstructor/
	# UnitAssembler) gets its frame keys refreshed from the live
	# rules, so a cheating team's factory skips consumption
	# (BuildingComp.updateConsumption(), BuildingComp.java:1944).
	source_unit_factory_build_state.source_unit_factory_tick_buildings_state(game, delta)
	# The adjacent-factory tick runs every live-loop tick (N2114):
	# each placed adjacent-family build (Separator/Incinerator/
	# WallCrafter/SingleBlockProducer, whose builds run their own
	# updateTile() after updateConsumption) gets its frame keys
	# refreshed from the live rules, so a cheating team's adjacent
	# factory counts everything as valid
	# (BuildingComp.updateConsumption(), BuildingComp.java:1944-1945).
	source_adjacent_factory_build_state.source_adjacent_factory_tick_buildings_state(game, delta)
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


static func game_transport_step_state(game: Object, seconds: float) -> Dictionary:
	return transport_step_state(transport_step_context(game, seconds, game_factory_cell_context(game), game.get("drill_pos")))

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


static func game_drill_step_state(game: Object, seconds: float) -> Dictionary:
	return drill_step_state(drill_step_context(game, seconds, game.get("drill_pos")))

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

static func game_drill_dump_preview_state(game: Object, seconds: float) -> Dictionary:
	return drill_dump_preview_state(game, drill_dump_preview_context(game, seconds, game.get("drill_pos"), source_playable_scenario_defaults.BLOCK_MECHANICAL_DRILL, source_time_defaults.TICK_RATE))


static func source_factory_dump_all_drill_outputs_state(game: Object, should_dump: bool) -> Dictionary:
	# The live-loop dump step (the two-Drill gate): when the dump timer
	# fires, every drill dumps from its own inventory via the per-drill
	# dump (N2072). All drills share the primary's SHOULD_DUMP — they
	# share dumpTime 5 and were placed at bootstrap — and each drill
	# resolves its own dominant item from its frame.
	var results_by_cell := {}
	var dumped_count := 0
	if not should_dump:
		return {"results_by_cell": results_by_cell, "dumped_count": dumped_count, "reason": "timer_not_fired"}
	var found := 0
	for sprite in source_placed_block_state.source_unique_buildings_state(game).get("buildings", []):
		if not is_instance_valid(sprite) or not sprite is Sprite2D:
			continue
		if not sprite.has_meta(source_drill_consumption_runtime_state.SOURCE_DRILL_BUILDING_META_KEY):
			continue
		var cell_value: Variant = sprite.get_meta("origin_cell", null)
		if not (cell_value is Vector2i):
			continue
		var cell: Vector2i = cell_value
		var dominant_item_id: Variant = source_drill_consumption_runtime_state.source_dominant_item_name_state(game, sprite).get("item_id")
		if dominant_item_id == null:
			continue
		found += 1
		var result: Dictionary = source_factory_dump_drill_output_for_cell_state(game, cell, dominant_item_id)
		results_by_cell[cell] = result
		if bool(result.get("dumped", false)):
			dumped_count += 1
	if found == 0:
		return {"results_by_cell": results_by_cell, "dumped_count": dumped_count, "reason": "no_drills"}
	if dumped_count > 0:
		return {"results_by_cell": results_by_cell, "dumped_count": dumped_count, "reason": "dumped"}
	return {"results_by_cell": results_by_cell, "dumped_count": dumped_count, "reason": "none_dumped"}


static func source_factory_dump_drill_output_state(game: Object, drill_cell: Vector2i, drill_output_item_id: Variant) -> Dictionary:
	return source_factory_dump_drill_output_for_cell_state(game, drill_cell, drill_output_item_id)


static func source_factory_dump_drill_output_for_cell_state(game: Object, drill_cell: Vector2i, drill_output_item_id: Variant) -> Dictionary:
	# Each drill dumps from its own inventory (one inventory owner per
	# drill): the primary drill's inventory is the game-global
	# drill_items (kept in sync with its frame), and every other
	# drill's inventory is its own frame items. Before N2072 this read
	# the game-global for every drill, so a second drill's output never
	# reached a belt or the core.
	var empty := {
		"dumped": false,
		"item_id": null,
		"receiver_index": -1,
		"receiver_cell": null,
		"cdump_before": 0,
		"cdump_after": 0,
		"items_after": {},
		"queues_after": {},
		"removed": 0,
		"destination": "none",
		"reason": "",
	}
	var sprite: Variant = game.call("block_sprite_at_cell", drill_cell)
	if sprite == null:
		empty["reason"] = "no_sprite"
		return empty
	if not sprite.has_meta(source_drill_consumption_runtime_state.SOURCE_DRILL_BUILDING_META_KEY):
		empty["reason"] = "no_frame"
		return empty
	var frame: Dictionary = sprite.get_meta(source_drill_consumption_runtime_state.SOURCE_DRILL_BUILDING_META_KEY)
	var cdump := int(frame.get("cdump", 0))
	var is_primary: bool = drill_cell == game.get("drill_pos")
	var items: Dictionary
	if is_primary:
		var items_value: Variant = game.get("drill_items")
		items = items_value if items_value is Dictionary else {}
	else:
		var frame_items: Variant = frame.get("items", {})
		items = frame_items if frame_items is Dictionary else {}
	var drill_size := 1
	var block_id := str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
	if block_id != "":
		var catalog = game.get("content_catalog")
		if catalog != null:
			var block = catalog.get_by_id(block_id)
			if block != null:
				drill_size = int(block.properties.get("size", 1))
	var ring := source_block_geometry.source_block_proximity_cells_state(drill_size, drill_cell.x, drill_cell.y)
	var ring_cells: Array = ring.get("cells", [])
	var queues := source_conveyor_runtime_state.source_conveyor_queues_for_cells_state(game, ring_cells)
	var queues_by_cell: Dictionary = queues.get("queues_by_cell", {})
	var rotations := {}
	for cell in queues_by_cell.keys():
		var conveyor_sprite: Variant = game.call("block_sprite_at_cell", cell)
		if conveyor_sprite != null:
			rotations[cell] = int(conveyor_sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))
	var content_item_ids: Array = []
	var item_catalog_value: Variant = game.get("source_item_catalog")
	if item_catalog_value is Dictionary and item_catalog_value.has("item_names_by_id"):
		content_item_ids = item_catalog_value["item_names_by_id"]
	# Conveyor.java:27-28: itemSpace = 0.4f, capacity = 3. Block.rotate
	# defaults to false (Block.java:120) and the Drill never sets it, so
	# the source never rotates and the next belt is never the source.
	var result: Dictionary
	if drill_output_item_id != null and int(items.get(str(drill_output_item_id), 0)) > 0:
		result = source_building_item_dump_state.source_drill_dump_step_state(items, ring_cells, str(drill_output_item_id), cdump, true, queues_by_cell, 3, 0.4, rotations, false, false, drill_cell, drill_size)
	else:
		result = source_building_item_dump_state.source_drill_dump_any_step_state(items, ring_cells, cdump, true, content_item_ids, queues_by_cell, 3, 0.4, rotations, false, false, drill_cell, drill_size)
	var queues_after: Dictionary = result.get("queues_after", {})
	# Only the receiving belt's queue changes: the dump composition calls
	# the handle hook for the receiver alone, so writing back every
	# resolved queue would create a stored (empty) queue on belts the
	# dump never touched.
	if bool(result.get("dumped", false)):
		var receiver_cell: Variant = result.get("receiver_cell")
		if receiver_cell is Vector2i and queues_after.has(receiver_cell):
			source_conveyor_runtime_state.source_conveyor_set_queue_for_cell_state(game, receiver_cell, queues_after[receiver_cell])
	var items_after: Dictionary = result.get("items_after", items.duplicate(true))
	if is_primary:
		game.set("drill_items", items_after)
	frame["items"] = items_after
	frame["cdump"] = int(result.get("cdump_after", cdump))
	return {
		"dumped": bool(result.get("dumped", false)),
		"item_id": result.get("item_id"),
		"receiver_index": int(result.get("receiver_index", -1)),
		"receiver_cell": result.get("receiver_cell"),
		"cdump_before": int(result.get("cdump_before", cdump)),
		"cdump_after": int(result.get("cdump_after", cdump)),
		"items_after": items_after,
		"queues_after": queues_after,
		"removed": int(result.get("removed", 0)),
		"destination": str(result.get("destination", "none")),
		"reason": str(result.get("reason", "")),
	}


static func _factory_conveyor_item_count(queue: Dictionary, item_id: String) -> int:
	var count := 0
	for queued_id in queue.get("ids", []):
		if str(queued_id) == item_id:
			count += 1
	return count


static func _factory_next_cell(cell: Vector2i, rotation: int) -> Vector2i:
	# Tile.relativeTo: 0 east, 1 north (y - 1), 2 west, 3 south (y + 1).
	match rotation:
		0:
			return Vector2i(cell.x + 1, cell.y)
		1:
			return Vector2i(cell.x, cell.y - 1)
		2:
			return Vector2i(cell.x - 1, cell.y)
		_:
			return Vector2i(cell.x, cell.y + 1)


static func source_factory_advance_conveyors_state(game: Object, conveyor_cells: Array, delta: float) -> Dictionary:
	var results_by_cell := {}
	var passed_count := 0
	if conveyor_cells.is_empty():
		return {"results_by_cell": results_by_cell, "passed_count": passed_count, "reason": "no_conveyors"}
	var queues := {}
	var original_queues := {}
	var rotations := {}
	var speeds := {}
	var teams := {}
	for cell in conveyor_cells:
		var sprite: Variant = game.call("block_sprite_at_cell", cell)
		if sprite == null:
			continue
		var queue := source_conveyor_runtime_state.source_conveyor_queue_for_cell_state(game, cell)
		if not bool(queue.get("found", false)):
			continue
		queues[cell] = {"ids": queue.get("ids", []), "xs": queue.get("xs", []), "ys": queue.get("ys", []), "len": int(queue.get("len", 0))}
		original_queues[cell] = {"ids": queue.get("ids", []).duplicate(), "xs": queue.get("xs", []).duplicate(), "ys": queue.get("ys", []).duplicate(), "len": int(queue.get("len", 0))}
		rotations[cell] = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))
		teams[cell] = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, 1))
		speeds[cell] = 0.03
		var block_id := str(sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
		if block_id != "":
			var catalog = game.get("content_catalog")
			if catalog != null:
				var block = catalog.get_by_id(block_id)
				if block != null:
					speeds[cell] = float(block.properties.get("speed", 0.03))
	# Advance front-to-back, so a belt hands off to a belt that already
	# advanced this frame. The caller gives the cells in that order.
	for cell in conveyor_cells:
		if not queues.has(cell):
			continue
		var queue: Dictionary = queues[cell]
		var rotation: int = rotations[cell]
		var next_cell := _factory_next_cell(cell, rotation)
		var next_sprite: Variant = game.call("block_sprite_at_cell", next_cell)
		var next_is_conveyor := false
		var next_is_core := false
		var next_rotation := 0
		var next_team := -1
		if next_sprite != null:
			var next_block_id := str(next_sprite.get_meta(source_placed_block_state.SOURCE_BLOCK_ID_META_KEY, ""))
			next_rotation = int(next_sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))
			next_team = int(next_sprite.get_meta(source_block_geometry.SOURCE_BUILD_TEAM_META_KEY, 1))
			if next_block_id == source_playable_scenario_defaults.BLOCK_CONVEYOR:
				next_is_conveyor = true
			elif next_block_id == source_playable_scenario_defaults.BLOCK_CORE_SHARD:
				next_is_core = true
		var aligned := next_is_conveyor and next_rotation == rotation
		var next_minitem := 1.0
		if next_is_conveyor and queues.has(next_cell):
			var next_queue: Dictionary = queues[next_cell]
			next_minitem = float(source_conveyor_runtime_state.source_conveyor_queue_scan_state(next_queue.get("ys", []), []).get("minitem", 1.0))
		var advance := source_conveyor_runtime_state.source_conveyor_advance_state(queue.get("ids", []), queue.get("xs", []), queue.get("ys", []), int(queue.get("len", 0)), float(speeds[cell]), delta, 1.0, aligned, next_minitem, 0, 0.0)
		var cell_result := {
			"ids_after": advance.get("ids_after", []),
			"xs_after": advance.get("xs_after", []),
			"ys_after": advance.get("ys_after", []),
			"len_after": advance.get("len_after", 0),
			"mid": advance.get("mid", 0),
			"minitem": advance.get("minitem", 1.0),
			"pass_ready": advance.get("pass_ready", false),
			"pass_item_id": advance.get("pass_item_id"),
			"passed": false,
			"passed_to": "none",
			"clog_heat": advance.get("clog_heat", 0.0),
			"reason": advance.get("reason", "advanced"),
		}
		queues[cell] = {"ids": cell_result["ids_after"], "xs": cell_result["xs_after"], "ys": cell_result["ys_after"], "len": cell_result["len_after"]}
		if bool(advance.get("pass_ready", false)):
			var pass_item_id := str(advance.get("pass_item_id", ""))
			var next_present := next_sprite != null
			var next_same_team := next_present and next_team == int(teams[cell])
			var accept_hook: Callable
			var handle_hook: Callable
			if next_is_conveyor:
				# Conveyor.java:40: rotate = true for the conveyor block.
				accept_hook = func(item_id):
					var nq: Dictionary = queues.get(next_cell, {"ids": [], "xs": [], "ys": [], "len": 0})
					var result := source_conveyor_runtime_state.source_conveyor_accept_for_cell_state(nq.get("ids", []), nq.get("xs", []), nq.get("ys", []), int(nq.get("len", 0)), 3, 0.4, cell, next_cell, int(rotations.get(next_cell, 0)), true, false)
					return bool(result.get("accepted", false))
				handle_hook = func(item_id):
					var nq: Dictionary = queues.get(next_cell, {"ids": [], "xs": [], "ys": [], "len": 0})
					var result := source_conveyor_runtime_state.source_conveyor_handle_for_cell_state(nq.get("ids", []), nq.get("xs", []), nq.get("ys", []), int(nq.get("len", 0)), 3, 0.4, cell, next_cell, int(rotations.get(next_cell, 0)), item_id, _factory_conveyor_item_count(nq, item_id))
					if int(result.get("index", -1)) >= 0:
						queues[next_cell] = {"ids": result.get("ids_after", []), "xs": result.get("xs_after", []), "ys": result.get("ys_after", []), "len": result.get("len_after", 0)}
					return result
			elif next_is_core:
				accept_hook = Callable(game, "source_core_accept_item")
				handle_hook = Callable(game, "source_core_handle_item")
			else:
				accept_hook = func(_item_id): return false
				handle_hook = func(_item_id): return false
			var pass_result := source_conveyor_runtime_state.source_conveyor_pass_state(pass_item_id, next_present, next_same_team, accept_hook, handle_hook)
			if bool(pass_result.get("passed", false)):
				var remove_result := source_conveyor_runtime_state.source_conveyor_queue_remove_state(cell_result["ids_after"], cell_result["xs_after"], cell_result["ys_after"], int(cell_result["len_after"]), int(cell_result["len_after"]) - 1)
				cell_result["ids_after"] = remove_result.get("ids_after", cell_result["ids_after"])
				cell_result["xs_after"] = remove_result.get("xs_after", cell_result["xs_after"])
				cell_result["ys_after"] = remove_result.get("ys_after", cell_result["ys_after"])
				cell_result["len_after"] = remove_result.get("len_after", cell_result["len_after"])
				queues[cell] = {"ids": cell_result["ids_after"], "xs": cell_result["xs_after"], "ys": cell_result["ys_after"], "len": cell_result["len_after"]}
				cell_result["passed"] = true
				cell_result["passed_to"] = "next_belt" if next_is_conveyor else ("core" if next_is_core else "other")
				passed_count += 1
		results_by_cell[cell] = cell_result
	# Only write back a queue that actually changed; an empty belt that
	# stayed empty must not gain a stored queue meta (the N2068 lesson:
	# the live loop ticks during every proof's setup frames).
	for cell in queues.keys():
		if queues[cell] != original_queues.get(cell, {}):
			source_conveyor_runtime_state.source_conveyor_set_queue_for_cell_state(game, cell, queues[cell])
	return {"results_by_cell": results_by_cell, "passed_count": passed_count, "reason": "advanced"}


static func source_factory_update_power_graph_state(game: Object, delta: float) -> Dictionary:
	# PowerGraph.java:220-260 (update): the graph's balance is recomputed
	# each tick (needed/produced, battery use/charge, distributePower).
	# The bootstrap world has no power producer or consumer, so the
	# placed graph is empty and this update is a no-op there; it still
	# runs so the live loop owns the power graph.
	var callbacks: Dictionary = source_placed_power_graph_state.default_callbacks_state(game)
	var grouped: Dictionary = source_placed_power_graph_state._group_state(game.get("placed_block_origins"), callbacks.get("block_from_sprite", Callable()), callbacks.get("role_for_block", Callable()), delta)
	var consumers: Array = grouped.get("consumers", [])
	var producers: Array = grouped.get("producers", [])
	var batteries: Array = grouped.get("batteries", [])
	# Load each battery's stored power_status (PowerGraph.java: the
	# status persists on the building across frames; the port stores
	# it on the battery sprite's meta). block_battery_state rebuilds
	# the status as 0.0 every frame, so without this the charge never
	# persists and the discharge path can never trigger live.
	for battery in batteries:
		if battery is Dictionary and battery.get("origin_cell", null) is Vector2i:
			var stored: Dictionary = source_placed_power_graph_state.source_battery_power_status_for_cell_state(game, battery.get("origin_cell"))
			battery["power_status"] = float(stored.get("status", 0.0))
	# Load each consumer's live cheating value (PowerGraph.java:217
	# update(): the cheat gate reads consumers.first().cheating() —
	# the first consumer's live team value, TeamComp.cheating(),
	# N2099). The grouped consumer dicts are rebuilt from the catalog
	# every frame and carry no cheating key, so the gate could never
	# fire live even for a cheating drill; stamp each consumer with
	# its building's live value (the battery pattern above: per-building
	# state loaded from the sprite into the grouped dict before the
	# update runs). A consumer without a Vector2i origin keeps the
	# false default.
	for consumer in consumers:
		if consumer is Dictionary and consumer.get("origin_cell", null) is Vector2i:
			var cheat_state: Dictionary = source_placed_power_graph_state.source_consumer_cheating_for_cell_state(game, consumer.get("origin_cell"))
			consumer["cheating"] = bool(cheat_state.get("cheating", false))
	var update: Dictionary = source_power_graph_state.update_state(consumers, producers, batteries, 0.0, delta, [])
	# Write the resulting status back so the next frame reads it.
	var updated_batteries: Array = update.get("battery_distribute_state", {}).get("batteries", [])
	for battery in updated_batteries:
		if battery is Dictionary and battery.get("origin_cell", null) is Vector2i:
			source_placed_power_graph_state.source_battery_set_power_status_for_cell_state(game, battery.get("origin_cell"), float(battery.get("power_status", 0.0)))
	return {
		"power_needed": float(update.get("power_needed", 0.0)),
		"power_produced": float(update.get("power_produced", 0.0)),
		"consumer_count": consumers.size(),
		"producer_count": producers.size(),
		"battery_count": batteries.size(),
		"update": update,
	}
