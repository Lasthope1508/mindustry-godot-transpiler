extends RefCounted
class_name SourceFactorySimulationApplyState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_factory_simulation_runtime_state_script := preload("res://src/game/SourceFactorySimulationRuntimeState.gd")
const source_item_transport_runtime_state_script := preload("res://src/game/SourceItemTransportRuntimeState.gd")
const source_drill_runtime_state_script := preload("res://src/game/SourceDrillRuntimeState.gd")
const source_drill_production_runtime_state_script := preload("res://src/game/SourceDrillProductionRuntimeState.gd")

const SOURCE_FACTORY_SIMULATION_DRILL_STATE_KEY := source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DRILL_STATE_KEY
const SOURCE_FACTORY_SIMULATION_DUMP_STATE_KEY := source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_DUMP_STATE_KEY
const SOURCE_FACTORY_SIMULATION_TRANSPORT_STATE_KEY := source_factory_simulation_runtime_state_script.SOURCE_FACTORY_SIMULATION_TRANSPORT_STATE_KEY
const SOURCE_FACTORY_APPLY_DRILL_TIME_DRILLED_KEY := "drill_time_drilled"
const SOURCE_FACTORY_APPLY_DRILL_LAST_SPEED_KEY := "drill_last_speed"
const SOURCE_FACTORY_APPLY_DRILL_WARMUP_KEY := "drill_warmup"
const SOURCE_FACTORY_APPLY_ITEM_PROGRESS_KEY := "item_progress"
const SOURCE_FACTORY_APPLY_PRODUCED_TOTAL_KEY := "produced_total"
const SOURCE_FACTORY_APPLY_DRILL_DUMP_TIMER_KEY := "drill_dump_timer"
const SOURCE_FACTORY_APPLY_SHOULD_DUMP_KEY := "should_dump"
const SOURCE_FACTORY_APPLY_TRANSPORT_PROGRESS_KEY := "transport_progress"
const SOURCE_FACTORY_APPLY_ITEM_SPRITES_KEY := "item_sprites"
const SOURCE_FACTORY_APPLY_SOURCE_OWNER_KEY := "source_owner"

static func runtime_context(game: Object, drill_cell: Vector2i) -> Dictionary:
	var drill_time_drilled_value: float = game.call("drill_time_drilled_at_cell", drill_cell.x, drill_cell.y)
	var drill_last_speed_value: float = game.call("drill_last_speed_at_cell", drill_cell.x, drill_cell.y)
	var drill_warmup_value: float = game.call("drill_warmup_at_cell", drill_cell.x, drill_cell.y)
	var item_progress_value: float = game.get(SOURCE_FACTORY_APPLY_ITEM_PROGRESS_KEY)
	var produced_total_value: int = game.get(SOURCE_FACTORY_APPLY_PRODUCED_TOTAL_KEY)
	var drill_dump_timer_value: float = game.get(SOURCE_FACTORY_APPLY_DRILL_DUMP_TIMER_KEY)
	var transport_progress_value: float = game.get(SOURCE_FACTORY_APPLY_TRANSPORT_PROGRESS_KEY)
	return {
		SOURCE_FACTORY_APPLY_DRILL_TIME_DRILLED_KEY: drill_time_drilled_value,
		SOURCE_FACTORY_APPLY_DRILL_LAST_SPEED_KEY: drill_last_speed_value,
		SOURCE_FACTORY_APPLY_DRILL_WARMUP_KEY: drill_warmup_value,
		SOURCE_FACTORY_APPLY_ITEM_PROGRESS_KEY: item_progress_value,
		SOURCE_FACTORY_APPLY_PRODUCED_TOTAL_KEY: produced_total_value,
		SOURCE_FACTORY_APPLY_DRILL_DUMP_TIMER_KEY: drill_dump_timer_value,
		SOURCE_FACTORY_APPLY_TRANSPORT_PROGRESS_KEY: transport_progress_value,
	}

static func apply_state(factory_state: Dictionary, apply_context: Dictionary) -> Dictionary:
	var drill_state: Dictionary = factory_state.get(SOURCE_FACTORY_SIMULATION_DRILL_STATE_KEY, {})
	var dump_state: Dictionary = factory_state.get(SOURCE_FACTORY_SIMULATION_DUMP_STATE_KEY, {})
	var transport_state: Dictionary = factory_state.get(SOURCE_FACTORY_SIMULATION_TRANSPORT_STATE_KEY, {})
	var offload_amount := int(drill_state.get(source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_OFFLOAD_AMOUNT_KEY, 0))
	var produced_total_before := int(apply_context.get(SOURCE_FACTORY_APPLY_PRODUCED_TOTAL_KEY, 0))
	var produced_delta := int(drill_state.get(source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_PRODUCED_DELTA_KEY, offload_amount))
	return {
		SOURCE_FACTORY_APPLY_DRILL_TIME_DRILLED_KEY: float(drill_state.get(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_TIME_DRILLED_KEY, apply_context.get(SOURCE_FACTORY_APPLY_DRILL_TIME_DRILLED_KEY, 0.0))),
		SOURCE_FACTORY_APPLY_DRILL_LAST_SPEED_KEY: float(drill_state.get(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_LAST_SPEED_KEY, apply_context.get(SOURCE_FACTORY_APPLY_DRILL_LAST_SPEED_KEY, 0.0))),
		SOURCE_FACTORY_APPLY_DRILL_WARMUP_KEY: float(drill_state.get(source_drill_runtime_state_script.SOURCE_DRILL_RESULT_WARMUP_KEY, apply_context.get(SOURCE_FACTORY_APPLY_DRILL_WARMUP_KEY, 0.0))),
		SOURCE_FACTORY_APPLY_ITEM_PROGRESS_KEY: float(drill_state.get(source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_ITEM_PROGRESS_KEY, apply_context.get(SOURCE_FACTORY_APPLY_ITEM_PROGRESS_KEY, 0.0))),
		source_drill_production_runtime_state_script.SOURCE_DRILL_PRODUCTION_OFFLOAD_AMOUNT_KEY: offload_amount,
		SOURCE_FACTORY_APPLY_PRODUCED_TOTAL_KEY: produced_total_before + produced_delta,
		SOURCE_FACTORY_APPLY_DRILL_DUMP_TIMER_KEY: float(dump_state.get(SOURCE_FACTORY_APPLY_DRILL_DUMP_TIMER_KEY, apply_context.get(SOURCE_FACTORY_APPLY_DRILL_DUMP_TIMER_KEY, 0.0))),
		SOURCE_FACTORY_APPLY_SHOULD_DUMP_KEY: bool(dump_state.get(SOURCE_FACTORY_APPLY_SHOULD_DUMP_KEY, false)),
		SOURCE_FACTORY_APPLY_TRANSPORT_PROGRESS_KEY: float(transport_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_PROGRESS_KEY, apply_context.get(SOURCE_FACTORY_APPLY_TRANSPORT_PROGRESS_KEY, 0.0))),
		SOURCE_FACTORY_APPLY_ITEM_SPRITES_KEY: transport_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITES_KEY, []),
		SOURCE_FACTORY_APPLY_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_SIMULATION_APPLY_STATE,
	}
