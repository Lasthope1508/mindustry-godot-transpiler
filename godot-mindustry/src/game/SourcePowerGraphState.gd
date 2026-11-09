extends RefCounted
class_name SourcePowerGraphState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_math_defaults_script := preload("res://src/game/SourceMathDefaults.gd")
const source_consume_power_state := preload("res://src/game/SourceConsumePowerState.gd")
const source_power_graph_balance_state := preload("res://src/game/SourcePowerGraphBalanceState.gd")
const source_power_graph_remove_branch_state := preload("res://src/game/SourcePowerGraphRemoveBranchState.gd")
const source_power_graph_metrics_state := preload("res://src/game/SourcePowerGraphMetricsState.gd")
const source_power_graph_topology_state := preload("res://src/game/SourcePowerGraphTopologyState.gd")
const source_power_graph_source_text_state := preload("res://src/game/SourcePowerGraphSourceTextState.gd")
const SOURCE_FLOAT_ROUNDING_ERROR := source_math_defaults_script.FLOAT_ROUNDING_ERROR

const SOURCE_POWER_GRAPH_CHECK_ADD_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CHECK_ADD_METHOD
const SOURCE_POWER_GRAPH_CHECK_ADD_ENTITY_ADD_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CHECK_ADD_ENTITY_ADD_GUARD
const SOURCE_POWER_GRAPH_CLEAR_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CLEAR_METHOD
const SOURCE_POWER_GRAPH_CLEAR_ALL_CLEAR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CLEAR_ALL_CLEAR
const SOURCE_POWER_GRAPH_CLEAR_PRODUCERS_CLEAR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CLEAR_PRODUCERS_CLEAR
const SOURCE_POWER_GRAPH_CLEAR_CONSUMERS_CLEAR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CLEAR_CONSUMERS_CLEAR
const SOURCE_POWER_GRAPH_CLEAR_BATTERIES_CLEAR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CLEAR_BATTERIES_CLEAR
const SOURCE_POWER_GRAPH_CLEAR_NOTHING_LEFT_COMMENT := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CLEAR_NOTHING_LEFT_COMMENT
const SOURCE_POWER_GRAPH_CLEAR_ENTITY_REMOVE_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_CLEAR_ENTITY_REMOVE_GUARD
const SOURCE_POWER_GRAPH_ADD_ROLE_POWER_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_POWER_GUARD
const SOURCE_POWER_GRAPH_ADD_ROLE_ADD_GATE := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_ADD_GATE
const SOURCE_POWER_GRAPH_ADD_ROLE_GRAPH_ASSIGN := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_GRAPH_ASSIGN
const SOURCE_POWER_GRAPH_ADD_ROLE_INIT_ASSIGN := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_INIT_ASSIGN
const SOURCE_POWER_GRAPH_ADD_ROLE_ALL_ADD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_ALL_ADD
const SOURCE_POWER_GRAPH_ADD_ROLE_PRODUCER_CONSUMER_BRANCH := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_PRODUCER_CONSUMER_BRANCH
const SOURCE_POWER_GRAPH_ADD_ROLE_BATTERY_BRANCH := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_BATTERY_BRANCH
const SOURCE_POWER_GRAPH_ADD_ROLE_PRODUCER_BRANCH := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_PRODUCER_BRANCH
const SOURCE_POWER_GRAPH_ADD_ROLE_CONSUMER_BRANCH := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_CONSUMER_BRANCH
const SOURCE_POWER_GRAPH_ADD_ROLE_NONE := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_NONE
const SOURCE_POWER_GRAPH_ADD_ROLE_PRODUCER_CONSUMER := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_PRODUCER_CONSUMER
const SOURCE_POWER_GRAPH_ADD_ROLE_BATTERY := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_BATTERY
const SOURCE_POWER_GRAPH_ADD_ROLE_PRODUCER := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_PRODUCER
const SOURCE_POWER_GRAPH_ADD_ROLE_CONSUMER := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_ROLE_CONSUMER
const SOURCE_POWER_GRAPH_ADD_GRAPH_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_GRAPH_METHOD
const SOURCE_POWER_GRAPH_ADD_GRAPH_SELF_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_GRAPH_SELF_GUARD
const SOURCE_POWER_GRAPH_ADD_GRAPH_MERGE_COMMENT := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_GRAPH_MERGE_COMMENT
const SOURCE_POWER_GRAPH_ADD_GRAPH_DELEGATE_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_GRAPH_DELEGATE_GUARD
const SOURCE_POWER_GRAPH_ADD_GRAPH_DELEGATE_CALL := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_GRAPH_DELEGATE_CALL
const SOURCE_POWER_GRAPH_ADD_GRAPH_DELEGATE_RETURN := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_GRAPH_DELEGATE_RETURN
const SOURCE_POWER_GRAPH_ADD_GRAPH_REMOVE_COMMENT := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_GRAPH_REMOVE_COMMENT
const SOURCE_POWER_GRAPH_ADD_GRAPH_REMOVE_ENTITY := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_GRAPH_REMOVE_ENTITY
const SOURCE_POWER_GRAPH_ADD_GRAPH_ALL_LOOP := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_GRAPH_ALL_LOOP
const SOURCE_POWER_GRAPH_ADD_GRAPH_ADD_TILE := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_GRAPH_ADD_TILE
const SOURCE_POWER_GRAPH_ADD_GRAPH_CHECK_ADD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_ADD_GRAPH_CHECK_ADD
const SOURCE_POWER_GRAPH_REFLOW_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REFLOW_METHOD
const SOURCE_POWER_GRAPH_REFLOW_QUEUE_CLEAR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REFLOW_QUEUE_CLEAR
const SOURCE_POWER_GRAPH_REFLOW_QUEUE_ADD_TILE := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REFLOW_QUEUE_ADD_TILE
const SOURCE_POWER_GRAPH_REFLOW_CLOSED_SET_CLEAR := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REFLOW_CLOSED_SET_CLEAR
const SOURCE_POWER_GRAPH_REFLOW_WHILE_QUEUE := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REFLOW_WHILE_QUEUE
const SOURCE_POWER_GRAPH_REFLOW_REMOVE_FIRST := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REFLOW_REMOVE_FIRST
const SOURCE_POWER_GRAPH_REFLOW_ADD_CHILD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REFLOW_ADD_CHILD
const SOURCE_POWER_GRAPH_REFLOW_CHECK_ADD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REFLOW_CHECK_ADD
const SOURCE_POWER_GRAPH_REFLOW_CONNECTIONS_LOOP := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REFLOW_CONNECTIONS_LOOP
const SOURCE_POWER_GRAPH_REFLOW_CLOSED_SET_ADD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REFLOW_CLOSED_SET_ADD
const SOURCE_POWER_GRAPH_REFLOW_QUEUE_ADD_NEXT := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REFLOW_QUEUE_ADD_NEXT
const SOURCE_POWER_GRAPH_REMOVE_LIST_COMMENT := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REMOVE_LIST_COMMENT
const SOURCE_POWER_GRAPH_REMOVE_LIST_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REMOVE_LIST_METHOD
const SOURCE_POWER_GRAPH_REMOVE_LIST_ALL_REMOVE := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REMOVE_LIST_ALL_REMOVE
const SOURCE_POWER_GRAPH_REMOVE_LIST_PRODUCERS_REMOVE := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REMOVE_LIST_PRODUCERS_REMOVE
const SOURCE_POWER_GRAPH_REMOVE_LIST_CONSUMERS_REMOVE := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REMOVE_LIST_CONSUMERS_REMOVE
const SOURCE_POWER_GRAPH_REMOVE_LIST_BATTERIES_REMOVE := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REMOVE_LIST_BATTERIES_REMOVE
const SOURCE_POWER_GRAPH_GET_ID_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_ID_METHOD
const SOURCE_POWER_GRAPH_GET_ID_RETURN_GRAPH_ID := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_ID_RETURN_GRAPH_ID
const SOURCE_POWER_GRAPH_TO_STRING_PREFIX := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_TO_STRING_PREFIX
const SOURCE_POWER_GRAPH_GET_LAST_SCALED_POWER_IN_FIELD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_SCALED_POWER_IN_FIELD
const SOURCE_POWER_GRAPH_GET_LAST_SCALED_POWER_IN_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_SCALED_POWER_IN_METHOD
const SOURCE_POWER_GRAPH_GET_LAST_SCALED_POWER_IN_RETURN := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_SCALED_POWER_IN_RETURN
const SOURCE_POWER_GRAPH_GET_LAST_SCALED_POWER_OUT_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_SCALED_POWER_OUT_METHOD
const SOURCE_POWER_GRAPH_GET_LAST_SCALED_POWER_OUT_RETURN := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_SCALED_POWER_OUT_RETURN
const SOURCE_POWER_GRAPH_GET_LAST_CAPACITY_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_CAPACITY_METHOD
const SOURCE_POWER_GRAPH_GET_LAST_CAPACITY_RETURN := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_CAPACITY_RETURN
const SOURCE_POWER_GRAPH_GET_POWER_BALANCE_FIELD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_POWER_BALANCE_FIELD
const SOURCE_POWER_GRAPH_GET_POWER_BALANCE_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_POWER_BALANCE_METHOD
const SOURCE_POWER_GRAPH_GET_POWER_BALANCE_RETURN := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_POWER_BALANCE_RETURN
const SOURCE_POWER_GRAPH_HAS_POWER_BALANCE_SAMPLES_FIELD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_HAS_POWER_BALANCE_SAMPLES_FIELD
const SOURCE_POWER_GRAPH_HAS_POWER_BALANCE_SAMPLES_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_HAS_POWER_BALANCE_SAMPLES_METHOD
const SOURCE_POWER_GRAPH_HAS_POWER_BALANCE_SAMPLES_RETURN := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_HAS_POWER_BALANCE_SAMPLES_RETURN
const SOURCE_POWER_GRAPH_GET_LAST_POWER_NEEDED_FIELD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_POWER_NEEDED_FIELD
const SOURCE_POWER_GRAPH_GET_LAST_POWER_NEEDED_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_POWER_NEEDED_METHOD
const SOURCE_POWER_GRAPH_GET_LAST_POWER_NEEDED_RETURN := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_POWER_NEEDED_RETURN
const SOURCE_POWER_GRAPH_GET_LAST_POWER_PRODUCED_FIELD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_POWER_PRODUCED_FIELD
const SOURCE_POWER_GRAPH_GET_LAST_POWER_PRODUCED_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_POWER_PRODUCED_METHOD
const SOURCE_POWER_GRAPH_GET_LAST_POWER_PRODUCED_RETURN := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_POWER_PRODUCED_RETURN
const SOURCE_POWER_GRAPH_GET_LAST_POWER_STORED_FIELD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_POWER_STORED_FIELD
const SOURCE_POWER_GRAPH_GET_LAST_POWER_STORED_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_POWER_STORED_METHOD
const SOURCE_POWER_GRAPH_GET_LAST_POWER_STORED_RETURN := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_LAST_POWER_STORED_RETURN
const SOURCE_POWER_GRAPH_TRANSFER_POWER_FIELD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_TRANSFER_POWER_FIELD
const SOURCE_POWER_GRAPH_TRANSFER_POWER_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_TRANSFER_POWER_METHOD
const SOURCE_POWER_GRAPH_TRANSFER_POWER_POSITIVE_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_TRANSFER_POWER_POSITIVE_GUARD
const SOURCE_POWER_GRAPH_TRANSFER_POWER_CHARGE_CALL := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_TRANSFER_POWER_CHARGE_CALL
const SOURCE_POWER_GRAPH_TRANSFER_POWER_ELSE_BRANCH := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_TRANSFER_POWER_ELSE_BRANCH
const SOURCE_POWER_GRAPH_TRANSFER_POWER_USE_CALL := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_TRANSFER_POWER_USE_CALL
const SOURCE_POWER_GRAPH_TRANSFER_POWER_ENERGY_DELTA_ADD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_TRANSFER_POWER_ENERGY_DELTA_ADD
const SOURCE_POWER_GRAPH_GET_SATISFACTION_FIELD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_SATISFACTION_FIELD
const SOURCE_POWER_GRAPH_GET_SATISFACTION_METHOD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_SATISFACTION_METHOD
const SOURCE_POWER_GRAPH_GET_SATISFACTION_PRODUCED_ZERO_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_SATISFACTION_PRODUCED_ZERO_GUARD
const SOURCE_POWER_GRAPH_GET_SATISFACTION_RETURN_ZERO := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_SATISFACTION_RETURN_ZERO
const SOURCE_POWER_GRAPH_GET_SATISFACTION_NEEDED_ZERO_GUARD := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_SATISFACTION_NEEDED_ZERO_GUARD
const SOURCE_POWER_GRAPH_GET_SATISFACTION_RETURN_ONE := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_SATISFACTION_RETURN_ONE
const SOURCE_POWER_GRAPH_GET_SATISFACTION_RETURN_CLAMP := source_power_graph_source_text_state.SOURCE_POWER_GRAPH_GET_SATISFACTION_RETURN_CLAMP

static func check_add_state(entity_present: bool) -> Dictionary:
	return source_power_graph_topology_state.check_add_state(entity_present)

static func clear_state(all: Array, producers: Array, consumers: Array, batteries: Array, entity_present: bool) -> Dictionary:
	return source_power_graph_topology_state.clear_state(all, producers, consumers, batteries, entity_present)

static func add_role_state(build_present: bool, power_present: bool, graph_matches: bool, power_init: bool, old_graph_present: bool, old_graph_is_self: bool, old_graph_has_entity: bool, outputs_power: bool, consumes_power: bool, has_cons_power: bool, cons_power_buffered: bool) -> Dictionary:
	return source_power_graph_topology_state.add_role_state(build_present, power_present, graph_matches, power_init, old_graph_present, old_graph_is_self, old_graph_has_entity, outputs_power, consumes_power, has_cons_power, cons_power_buffered)

static func add_graph_state(graph_is_self: bool, graph_all_size: int, all_size: int, graph_has_entity: bool, graph_tiles: Array, role_state_callable: Callable = Callable(SourcePowerGraphState, "add_role_state")) -> Dictionary:
	return source_power_graph_topology_state.add_graph_state(graph_is_self, graph_all_size, all_size, graph_has_entity, graph_tiles, role_state_callable)

static func reflow_state(tile: Dictionary, role_state_callable: Callable = Callable(SourcePowerGraphState, "add_role_state")) -> Dictionary:
	return source_power_graph_topology_state.reflow_state(tile, role_state_callable)

static func remove_list_state(all: Array, producers: Array, consumers: Array, batteries: Array, build) -> Dictionary:
	return source_power_graph_topology_state.remove_list_state(all, producers, consumers, batteries, build)

static func remove_branch_seed_state(tile: Dictionary, role_state_callable: Callable = Callable(SourcePowerGraphState, "add_role_state")) -> Dictionary:
	return source_power_graph_remove_branch_state.remove_branch_seed_state(tile, role_state_callable)

static func remove_branch_bfs_state(tile: Dictionary, role_state_callable: Callable = Callable(SourcePowerGraphState, "add_role_state")) -> Dictionary:
	return source_power_graph_remove_branch_state.remove_branch_bfs_state(tile, role_state_callable)

static func remove_branch_update_state(tile: Dictionary, role_state_callable: Callable = Callable(SourcePowerGraphState, "add_role_state")) -> Dictionary:
	return source_power_graph_remove_branch_state.remove_branch_update_state(tile, role_state_callable)

static func remove_empty_entity_state(tile: Dictionary, entity_present: bool, role_state_callable: Callable = Callable(SourcePowerGraphState, "add_role_state")) -> Dictionary:
	return source_power_graph_remove_branch_state.remove_empty_entity_state(tile, entity_present, role_state_callable)

static func power_needed_state(consumers: Array, requested_power_state: Callable = Callable(source_consume_power_state, "requested_power_state")) -> Dictionary:
	return source_power_graph_balance_state.power_needed_state(consumers, requested_power_state)

static func power_produced_state(producers: Array) -> Dictionary:
	return source_power_graph_balance_state.power_produced_state(producers)

static func battery_state(batteries: Array) -> Dictionary:
	return source_power_graph_balance_state.battery_state(batteries)

static func use_batteries_state(batteries: Array, needed: float) -> Dictionary:
	return source_power_graph_balance_state.use_batteries_state(batteries, needed)

static func charge_batteries_state(batteries: Array, excess: float) -> Dictionary:
	return source_power_graph_balance_state.charge_batteries_state(batteries, excess)

static func distribute_power_state(consumers: Array, needed: float, produced: float, charged: bool, last_power_stored: float) -> Dictionary:
	return source_power_graph_balance_state.distribute_power_state(consumers, needed, produced, charged, last_power_stored)

static func update_cheat_state(consumers: Array) -> Dictionary:
	return source_power_graph_balance_state.update_cheat_state(consumers)

static func update_balance_state(consumers: Array, producers: Array, batteries: Array, energy_delta: float, source_delta: float, power_balance_samples: Array = [], requested_power_state: Callable = Callable(source_consume_power_state, "requested_power_state")) -> Dictionary:
	return source_power_graph_balance_state.update_balance_state(consumers, producers, batteries, energy_delta, source_delta, power_balance_samples, requested_power_state)

static func update_battery_distribute_state(consumers: Array, producers: Array, batteries: Array, power_needed: float, power_produced: float, last_power_produced: float, last_power_stored: float) -> Dictionary:
	return source_power_graph_balance_state.update_battery_distribute_state(consumers, producers, batteries, power_needed, power_produced, last_power_produced, last_power_stored)

static func update_state(consumers: Array, producers: Array, batteries: Array, energy_delta: float, source_delta: float, power_balance_samples: Array = []) -> Dictionary:
	var cheat_state := update_cheat_state(consumers)
	# PowerGraph.java:217-224 update(): when the first consumer
	# cheats, every consumer's power.status is set to 1,
	# lastPowerNeeded and lastPowerProduced are 1, and the update
	# returns before getPowerNeeded/getPowerProduced and the battery
	# distribution run. The cheat state above is computed on duplicated
	# consumers, so the status is written here onto the real dicts; the
	# port reports power_needed/power_produced 1.0 to match the 1.0
	# lasts, and last_power_stored from the batteries' stored power
	# (the distribution never runs on this branch, so the stored value
	# is unchanged). The balance and battery-distribute states are
	# empty on this branch because Java returns before computing them.
	if bool(cheat_state.get("returned", false)):
		for consumer in consumers:
			if consumer is Dictionary:
				consumer["power_status"] = 1.0
		return {
			"method": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_METHOD,
			"nonempty_guard": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_NONEMPTY_GUARD,
			"charged_init": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_CHARGED_INIT,
			"unequal_guard_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_UNEQUAL_GUARD,
			"deficit_gate": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_DEFICIT_GATE,
			"power_battery_used_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_POWER_BATTERY_USED_EXPR,
			"power_produced_battery_add_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_POWER_PRODUCED_BATTERY_ADD_EXPR,
			"last_power_produced_battery_add_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_LAST_POWER_PRODUCED_BATTERY_ADD_EXPR,
			"surplus_gate": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_SURPLUS_GATE,
			"charged_true_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_CHARGED_TRUE_EXPR,
			"power_produced_charge_sub_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_POWER_PRODUCED_CHARGE_SUB_EXPR,
			"distribute_power_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_DISTRIBUTE_POWER_EXPR,
			"mathf_equal": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_MATHF_EQUAL_EXPR,
			"cheat_state": cheat_state,
			"balance_state": {},
			"battery_distribute_state": {},
			"power_needed": 1.0,
			"power_produced": 1.0,
			"last_power_needed": 1.0,
			"last_power_produced": 1.0,
			"last_power_stored": float(source_power_graph_balance_state.battery_state(batteries).get("stored", 0.0)),
			"consumers": consumers,
			"producers": producers,
			"batteries": batteries,
			"energy_delta": energy_delta,
			"source_delta": source_delta,
			"power_balance_samples": power_balance_samples,
		}
	var balance_state := update_balance_state(consumers, producers, batteries, energy_delta, source_delta, power_balance_samples)
	var power_needed: float = float(balance_state.get("power_needed", 0.0))
	var power_produced: float = float(balance_state.get("power_produced", 0.0))
	var last_power_needed: float = float(balance_state.get("last_power_needed", power_needed))
	var last_power_produced: float = float(balance_state.get("last_power_produced", power_produced))
	var last_power_stored: float = float(balance_state.get("last_power_stored", 0.0))
	var battery_distribute_state := update_battery_distribute_state(consumers, producers, batteries, power_needed, power_produced, last_power_produced, last_power_stored)
	return {
		"method": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_METHOD,
		"nonempty_guard": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_NONEMPTY_GUARD,
		"charged_init": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_CHARGED_INIT,
		"unequal_guard_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_UNEQUAL_GUARD,
		"deficit_gate": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_DEFICIT_GATE,
		"power_battery_used_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_POWER_BATTERY_USED_EXPR,
		"power_produced_battery_add_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_POWER_PRODUCED_BATTERY_ADD_EXPR,
		"last_power_produced_battery_add_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_LAST_POWER_PRODUCED_BATTERY_ADD_EXPR,
		"surplus_gate": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_SURPLUS_GATE,
		"charged_true_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_CHARGED_TRUE_EXPR,
		"power_produced_charge_sub_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_POWER_PRODUCED_CHARGE_SUB_EXPR,
		"distribute_power_expr": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_UPDATE_DISTRIBUTE_POWER_EXPR,
		"mathf_equal": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_MATHF_EQUAL_EXPR,
		"cheat_state": cheat_state,
		"balance_state": balance_state,
		"battery_distribute_state": battery_distribute_state,
		"power_needed": power_needed,
		"power_produced": power_produced,
		"last_power_needed": last_power_needed,
		"last_power_produced": last_power_produced,
		"last_power_stored": last_power_stored,
		"consumers": consumers,
		"producers": producers,
		"batteries": batteries,
		"energy_delta": energy_delta,
		"source_delta": source_delta,
		"power_balance_samples": power_balance_samples,
	}

static func remove_state(tile: Dictionary, entity_present: bool, role_state_callable: Callable = Callable(SourcePowerGraphState, "add_role_state")) -> Dictionary:
	var seed_state := remove_branch_seed_state(tile, role_state_callable)
	var bfs_state := remove_branch_bfs_state(tile, role_state_callable)
	var branch_update_state := remove_branch_update_state(tile, role_state_callable)
	var empty_entity_state := remove_empty_entity_state(tile, entity_present, role_state_callable)
	return {
		"method": source_power_graph_source_text_state.SOURCE_POWER_GRAPH_REMOVE_METHOD,
		"remove_comment": seed_state.get("remove_comment", ""),
		"seed_state": seed_state,
		"bfs_state": bfs_state,
		"update_state": branch_update_state,
		"empty_entity_state": empty_entity_state,
		"tile": tile.duplicate(true),
		"entity_present": entity_present,
	}

static func get_id_state(graph_id: int) -> Dictionary:
	return source_power_graph_metrics_state.get_id_state(graph_id)

static func get_last_scaled_power_in_state(last_scaled_power_in: float) -> Dictionary:
	return source_power_graph_metrics_state.get_last_scaled_power_in_state(last_scaled_power_in)

static func get_last_scaled_power_out_state(last_scaled_power_out: float) -> Dictionary:
	return source_power_graph_metrics_state.get_last_scaled_power_out_state(last_scaled_power_out)

static func get_last_capacity_state(last_capacity: float) -> Dictionary:
	return source_power_graph_metrics_state.get_last_capacity_state(last_capacity)

static func get_power_balance_state(power_balance_raw_mean: float) -> Dictionary:
	return source_power_graph_metrics_state.get_power_balance_state(power_balance_raw_mean)

static func has_power_balance_samples_state(has_power_balance_samples: bool) -> Dictionary:
	return source_power_graph_metrics_state.has_power_balance_samples_state(has_power_balance_samples)

static func get_last_power_needed_state(last_power_needed: float) -> Dictionary:
	return source_power_graph_metrics_state.get_last_power_needed_state(last_power_needed)

static func get_last_power_produced_state(last_power_produced: float) -> Dictionary:
	return source_power_graph_metrics_state.get_last_power_produced_state(last_power_produced)

static func get_last_power_stored_state(last_power_stored: float) -> Dictionary:
	return source_power_graph_metrics_state.get_last_power_stored_state(last_power_stored)

static func transfer_power_state(amount: float, energy_delta: float) -> Dictionary:
	return source_power_graph_metrics_state.transfer_power_state(amount, energy_delta)

static func get_satisfaction_state(last_power_produced: float, last_power_needed: float) -> Dictionary:
	return source_power_graph_metrics_state.get_satisfaction_state(last_power_produced, last_power_needed)

static func to_string_state(producers: String, consumers: String, batteries: String, all: String, graph_id: int) -> String:
	return source_power_graph_metrics_state.to_string_state(producers, consumers, batteries, all, graph_id)
