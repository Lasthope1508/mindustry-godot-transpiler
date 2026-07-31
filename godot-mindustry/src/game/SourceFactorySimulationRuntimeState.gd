extends RefCounted
class_name SourceFactorySimulationRuntimeState


const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_item_transport_runtime_state_script := preload("res://src/game/SourceItemTransportRuntimeState.gd")

const SOURCE_FACTORY_SIMULATION_SECONDS_KEY := "seconds"
const SOURCE_FACTORY_SIMULATION_DRILL_CELL_KEY := "drill_cell"
const SOURCE_FACTORY_SIMULATION_CONVEYOR_CELL_KEY := "conveyor_cell"
const SOURCE_FACTORY_SIMULATION_DRILL_RUNTIME_STATE_KEY := "drill_runtime_state"
const SOURCE_FACTORY_SIMULATION_DRILL_DUMP_RUNTIME_STATE_KEY := "drill_dump_runtime_state"
const SOURCE_FACTORY_SIMULATION_ITEM_TRANSPORT_RUNTIME_STATE_KEY := "item_transport_runtime_state"
const SOURCE_FACTORY_SIMULATION_CONVEYOR_PROGRESS_DELTA_FOR_CELL_KEY := "conveyor_progress_delta_for_cell"
const SOURCE_FACTORY_SIMULATION_DRILL_STATE_KEY := "drill_state"
const SOURCE_FACTORY_SIMULATION_DUMP_STATE_KEY := "dump_state"
const SOURCE_FACTORY_SIMULATION_TRANSPORT_STATE_KEY := "transport_state"
const SOURCE_FACTORY_SIMULATION_TRANSPORT_PROGRESS_KEY := "transport_progress"
const SOURCE_FACTORY_SIMULATION_SOURCE_OWNER_KEY := "source_owner"

static func simulation_state(factory_context: Dictionary, factory_callbacks: Dictionary) -> Dictionary:
	var seconds := float(factory_context.get(SOURCE_FACTORY_SIMULATION_SECONDS_KEY, 0.0))
	var transport_progress_before := float(factory_context.get(SOURCE_FACTORY_SIMULATION_TRANSPORT_PROGRESS_KEY, 0.0))
	var conveyor_cell: Vector2i = factory_context.get(SOURCE_FACTORY_SIMULATION_CONVEYOR_CELL_KEY, Vector2i.ZERO)
	var drill_runtime_state_fn: Callable = factory_callbacks.get(SOURCE_FACTORY_SIMULATION_DRILL_RUNTIME_STATE_KEY, Callable())
	var drill_dump_runtime_state_fn: Callable = factory_callbacks.get(SOURCE_FACTORY_SIMULATION_DRILL_DUMP_RUNTIME_STATE_KEY, Callable())
	var conveyor_progress_delta_for_cell_fn: Callable = factory_callbacks.get(SOURCE_FACTORY_SIMULATION_CONVEYOR_PROGRESS_DELTA_FOR_CELL_KEY, Callable())
	var item_transport_runtime_state_fn: Callable = factory_callbacks.get(SOURCE_FACTORY_SIMULATION_ITEM_TRANSPORT_RUNTIME_STATE_KEY, Callable())
	var drill_state: Dictionary = drill_runtime_state_fn.call(seconds)
	var dump_state: Dictionary = drill_dump_runtime_state_fn.call(seconds)
	var transport_progress_delta := float(conveyor_progress_delta_for_cell_fn.call(conveyor_cell.x, conveyor_cell.y, seconds))
	var transport_state: Dictionary = item_transport_runtime_state_fn.call(transport_progress_before, transport_progress_delta)
	return {
		SOURCE_FACTORY_SIMULATION_DRILL_STATE_KEY: drill_state,
		SOURCE_FACTORY_SIMULATION_DUMP_STATE_KEY: dump_state,
		SOURCE_FACTORY_SIMULATION_TRANSPORT_STATE_KEY: transport_state,
		SOURCE_FACTORY_SIMULATION_TRANSPORT_PROGRESS_KEY: float(transport_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_PROGRESS_KEY, transport_progress_before)),
		SOURCE_FACTORY_SIMULATION_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_FACTORY_SIMULATION_RUNTIME_STATE,
	}
