extends RefCounted
class_name SourcePowerGraphTopologyState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_power_graph_source_text_state := preload("res://src/game/SourcePowerGraphSourceTextState.gd")

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

static func check_add_state(entity_present: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GRAPH_CHECK_ADD_STATE, "method": SOURCE_POWER_GRAPH_CHECK_ADD_METHOD, "entity_add_guard": SOURCE_POWER_GRAPH_CHECK_ADD_ENTITY_ADD_GUARD, "entity_add_called": entity_present}

static func clear_state(all: Array, producers: Array, consumers: Array, batteries: Array, entity_present: bool) -> Dictionary:
	var source_all := all.duplicate(true)
	var source_producers := producers.duplicate(true)
	var source_consumers := consumers.duplicate(true)
	var source_batteries := batteries.duplicate(true)
	source_all.clear()
	source_producers.clear()
	source_consumers.clear()
	source_batteries.clear()
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GRAPH_CLEAR_STATE, "method": SOURCE_POWER_GRAPH_CLEAR_METHOD, "all_clear": SOURCE_POWER_GRAPH_CLEAR_ALL_CLEAR, "producers_clear": SOURCE_POWER_GRAPH_CLEAR_PRODUCERS_CLEAR, "consumers_clear": SOURCE_POWER_GRAPH_CLEAR_CONSUMERS_CLEAR, "batteries_clear": SOURCE_POWER_GRAPH_CLEAR_BATTERIES_CLEAR, "nothing_left_comment": SOURCE_POWER_GRAPH_CLEAR_NOTHING_LEFT_COMMENT, "entity_remove_guard": SOURCE_POWER_GRAPH_CLEAR_ENTITY_REMOVE_GUARD, "all": source_all, "producers": source_producers, "consumers": source_consumers, "batteries": source_batteries, "entity_removed": entity_present}

static func add_role_state(build_present: bool, power_present: bool, graph_matches: bool, power_init: bool, old_graph_present: bool, old_graph_is_self: bool, old_graph_has_entity: bool, outputs_power: bool, consumes_power: bool, has_cons_power: bool, cons_power_buffered: bool) -> Dictionary:
	var result := {"returned": false, "remove_old_graph_entity": false, "assign_graph": false, "init_power": false, "add_all": false, "role": SOURCE_POWER_GRAPH_ADD_ROLE_NONE, "add_producer": false, "add_consumer": false, "add_battery": false, "has_cons_power": has_cons_power, "power_guard": SOURCE_POWER_GRAPH_ADD_ROLE_POWER_GUARD, "add_gate": SOURCE_POWER_GRAPH_ADD_ROLE_ADD_GATE, "graph_assign": SOURCE_POWER_GRAPH_ADD_ROLE_GRAPH_ASSIGN, "init_assign": SOURCE_POWER_GRAPH_ADD_ROLE_INIT_ASSIGN, "all_add": SOURCE_POWER_GRAPH_ADD_ROLE_ALL_ADD, "producer_consumer_branch": SOURCE_POWER_GRAPH_ADD_ROLE_PRODUCER_CONSUMER_BRANCH, "battery_branch": SOURCE_POWER_GRAPH_ADD_ROLE_BATTERY_BRANCH, "producer_branch": SOURCE_POWER_GRAPH_ADD_ROLE_PRODUCER_BRANCH, "consumer_branch": SOURCE_POWER_GRAPH_ADD_ROLE_CONSUMER_BRANCH}
	if not build_present or not power_present:
		result["returned"] = true
		return result
	if not graph_matches or not power_init:
		result["remove_old_graph_entity"] = old_graph_present and not old_graph_is_self and old_graph_has_entity
		result["assign_graph"] = true
		result["init_power"] = true
		result["add_all"] = true
		if outputs_power and consumes_power and has_cons_power and not cons_power_buffered:
			result["role"] = SOURCE_POWER_GRAPH_ADD_ROLE_PRODUCER_CONSUMER
			result["add_producer"] = true
			result["add_consumer"] = true
		elif outputs_power and consumes_power:
			result["role"] = SOURCE_POWER_GRAPH_ADD_ROLE_BATTERY
			result["add_battery"] = true
		elif outputs_power:
			result["role"] = SOURCE_POWER_GRAPH_ADD_ROLE_PRODUCER
			result["add_producer"] = true
		elif consumes_power and has_cons_power:
			result["role"] = SOURCE_POWER_GRAPH_ADD_ROLE_CONSUMER
			result["add_consumer"] = true
	return result

static func add_graph_state(graph_is_self: bool, graph_all_size: int, all_size: int, graph_has_entity: bool, graph_tiles: Array, role_state_callable: Callable = Callable(SourcePowerGraphTopologyState, "add_role_state")) -> Dictionary:
	var tile_add_states: Array = []
	var returned := false
	var delegate_to_other_graph := false
	var remove_graph_entity := false
	var check_add := false
	if graph_is_self:
		returned = true
	elif graph_all_size > all_size:
		returned = true
		delegate_to_other_graph = true
	else:
		remove_graph_entity = graph_has_entity
		for tile in graph_tiles:
			if typeof(tile) != TYPE_DICTIONARY:
				continue
			tile_add_states.append(role_state_callable.call(bool(tile.get("build_present", true)), bool(tile.get("power_present", true)), bool(tile.get("graph_matches", false)), bool(tile.get("power_init", false)), bool(tile.get("old_graph_present", false)), bool(tile.get("old_graph_is_self", false)), bool(tile.get("old_graph_has_entity", false)), bool(tile.get("outputs_power", false)), bool(tile.get("consumes_power", false)), bool(tile.get("has_cons_power", false)), bool(tile.get("cons_power_buffered", false))))
		check_add = true
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GRAPH_ADD_GRAPH_STATE, "method": SOURCE_POWER_GRAPH_ADD_GRAPH_METHOD, "self_guard": SOURCE_POWER_GRAPH_ADD_GRAPH_SELF_GUARD, "merge_comment": SOURCE_POWER_GRAPH_ADD_GRAPH_MERGE_COMMENT, "delegate_guard_expr": SOURCE_POWER_GRAPH_ADD_GRAPH_DELEGATE_GUARD, "delegate_call_expr": SOURCE_POWER_GRAPH_ADD_GRAPH_DELEGATE_CALL, "delegate_return_expr": SOURCE_POWER_GRAPH_ADD_GRAPH_DELEGATE_RETURN, "remove_comment": SOURCE_POWER_GRAPH_ADD_GRAPH_REMOVE_COMMENT, "remove_graph_entity_expr": SOURCE_POWER_GRAPH_ADD_GRAPH_REMOVE_ENTITY, "graph_all_loop_expr": SOURCE_POWER_GRAPH_ADD_GRAPH_ALL_LOOP, "add_tile_expr": SOURCE_POWER_GRAPH_ADD_GRAPH_ADD_TILE, "check_add_expr": SOURCE_POWER_GRAPH_ADD_GRAPH_CHECK_ADD, "graph_is_self": graph_is_self, "graph_all_size": graph_all_size, "all_size": all_size, "graph_has_entity": graph_has_entity, "graph_tiles": graph_tiles.duplicate(true), "returned": returned, "delegate_to_other_graph": delegate_to_other_graph, "remove_graph_entity": remove_graph_entity, "add_call_count": tile_add_states.size(), "tile_add_states": tile_add_states, "check_add": check_add}

static func reflow_state(tile: Dictionary, role_state_callable: Callable = Callable(SourcePowerGraphTopologyState, "add_role_state")) -> Dictionary:
	var queue: Array = [tile.duplicate(true)]
	var closed_lookup: Dictionary = {}
	var closed_positions: Array = []
	var queued_positions: Array = []
	var visited_positions: Array = []
	var tile_add_states: Array = []
	var check_add_count := 0
	while queue.size() > 0:
		var child_variant = queue.pop_front()
		if typeof(child_variant) != TYPE_DICTIONARY:
			continue
		var child: Dictionary = child_variant
		visited_positions.append(child.get("pos", null))
		tile_add_states.append(role_state_callable.call(bool(child.get("build_present", true)), bool(child.get("power_present", true)), bool(child.get("graph_matches", false)), bool(child.get("power_init", false)), bool(child.get("old_graph_present", false)), bool(child.get("old_graph_is_self", false)), bool(child.get("old_graph_has_entity", false)), bool(child.get("outputs_power", false)), bool(child.get("consumes_power", false)), bool(child.get("has_cons_power", false)), bool(child.get("cons_power_buffered", false))))
		check_add_count += 1
		for next in child.get("connections", []):
			if typeof(next) != TYPE_DICTIONARY:
				continue
			var next_pos = next.get("pos", null)
			var next_pos_key := var_to_str(next_pos)
			if not closed_lookup.has(next_pos_key):
				closed_lookup[next_pos_key] = true
				closed_positions.append(next_pos)
				queued_positions.append(next_pos)
				queue.append(next.duplicate(true))
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GRAPH_REFLOW_STATE, "method": SOURCE_POWER_GRAPH_REFLOW_METHOD, "queue_clear": SOURCE_POWER_GRAPH_REFLOW_QUEUE_CLEAR, "queue_add_tile": SOURCE_POWER_GRAPH_REFLOW_QUEUE_ADD_TILE, "closed_set_clear": SOURCE_POWER_GRAPH_REFLOW_CLOSED_SET_CLEAR, "while_queue": SOURCE_POWER_GRAPH_REFLOW_WHILE_QUEUE, "remove_first": SOURCE_POWER_GRAPH_REFLOW_REMOVE_FIRST, "add_child": SOURCE_POWER_GRAPH_REFLOW_ADD_CHILD, "check_add": SOURCE_POWER_GRAPH_REFLOW_CHECK_ADD, "connections_loop": SOURCE_POWER_GRAPH_REFLOW_CONNECTIONS_LOOP, "closed_set_add": SOURCE_POWER_GRAPH_REFLOW_CLOSED_SET_ADD, "queue_add_next": SOURCE_POWER_GRAPH_REFLOW_QUEUE_ADD_NEXT, "tile": tile.duplicate(true), "visited_positions": visited_positions, "queued_positions": queued_positions, "closed_positions": closed_positions, "tile_add_states": tile_add_states, "check_add_count": check_add_count}

static func remove_list_state(all: Array, producers: Array, consumers: Array, batteries: Array, build) -> Dictionary:
	var source_all := all.duplicate(true)
	var source_producers := producers.duplicate(true)
	var source_consumers := consumers.duplicate(true)
	var source_batteries := batteries.duplicate(true)
	source_all.erase(build)
	source_producers.erase(build)
	source_consumers.erase(build)
	source_batteries.erase(build)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GRAPH_REMOVE_LIST_STATE, "comment": SOURCE_POWER_GRAPH_REMOVE_LIST_COMMENT, "method": SOURCE_POWER_GRAPH_REMOVE_LIST_METHOD, "all_remove": SOURCE_POWER_GRAPH_REMOVE_LIST_ALL_REMOVE, "producers_remove": SOURCE_POWER_GRAPH_REMOVE_LIST_PRODUCERS_REMOVE, "consumers_remove": SOURCE_POWER_GRAPH_REMOVE_LIST_CONSUMERS_REMOVE, "batteries_remove": SOURCE_POWER_GRAPH_REMOVE_LIST_BATTERIES_REMOVE, "build": build, "all": source_all, "producers": source_producers, "consumers": source_consumers, "batteries": source_batteries}
