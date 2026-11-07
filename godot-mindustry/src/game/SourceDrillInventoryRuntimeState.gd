extends RefCounted
class_name SourceDrillInventoryRuntimeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_drill_inventory_source_text_state := preload("res://src/game/SourceDrillInventorySourceTextState.gd")

const SOURCE_OFFLOAD_TO_INVENTORY_METHOD := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_METHOD
const SOURCE_OFFLOAD_TO_INVENTORY_PRODUCED := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_PRODUCED
const SOURCE_OFFLOAD_TO_INVENTORY_DUMP_CURSOR := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_DUMP_CURSOR
const SOURCE_OFFLOAD_TO_INVENTORY_NEIGHBOR_LOOP := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_NEIGHBOR_LOOP
const SOURCE_OFFLOAD_TO_INVENTORY_INCREMENT_DUMP := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_INCREMENT_DUMP
const SOURCE_OFFLOAD_TO_INVENTORY_PROXIMITY_GET := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_PROXIMITY_GET
const SOURCE_OFFLOAD_TO_INVENTORY_ACCEPT_CAN_DUMP := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_ACCEPT_CAN_DUMP
const SOURCE_OFFLOAD_TO_INVENTORY_NEIGHBOR_HANDLE := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_NEIGHBOR_HANDLE
const SOURCE_OFFLOAD_TO_INVENTORY_NEIGHBOR_RETURN := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_NEIGHBOR_RETURN
const SOURCE_OFFLOAD_TO_INVENTORY_FALLBACK_HANDLE := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_FALLBACK_HANDLE
const SOURCE_OFFLOAD_TO_INVENTORY_BUILDING_HANDLE_ADD := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_BUILDING_HANDLE_ADD
const SOURCE_OFFLOAD_TO_INVENTORY_BATCH_AMOUNT := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_BATCH_AMOUNT
const SOURCE_OFFLOAD_TO_INVENTORY_BATCH_LOOP := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_BATCH_LOOP
const SOURCE_OFFLOAD_TO_INVENTORY_BATCH_OFFLOAD := source_drill_inventory_source_text_state.SOURCE_OFFLOAD_TO_INVENTORY_BATCH_OFFLOAD

const SOURCE_DUMP_DRILL_ITEM_TO_CORE_METHOD := source_drill_inventory_source_text_state.SOURCE_DUMP_DRILL_ITEM_TO_CORE_METHOD
const SOURCE_DUMP_DRILL_ITEM_TO_CORE_INITIAL_GUARD := source_drill_inventory_source_text_state.SOURCE_DUMP_DRILL_ITEM_TO_CORE_INITIAL_GUARD
const SOURCE_DUMP_DRILL_ITEM_TO_CORE_ACCEPT_CAN_DUMP := source_drill_inventory_source_text_state.SOURCE_DUMP_DRILL_ITEM_TO_CORE_ACCEPT_CAN_DUMP
const SOURCE_DUMP_DRILL_ITEM_TO_CORE_HANDLE_ITEM := source_drill_inventory_source_text_state.SOURCE_DUMP_DRILL_ITEM_TO_CORE_HANDLE_ITEM
const SOURCE_DUMP_DRILL_ITEM_TO_CORE_REMOVE_ITEM := source_drill_inventory_source_text_state.SOURCE_DUMP_DRILL_ITEM_TO_CORE_REMOVE_ITEM
const SOURCE_DUMP_DRILL_ITEM_TO_CORE_INCREMENT_DUMP := source_drill_inventory_source_text_state.SOURCE_DUMP_DRILL_ITEM_TO_CORE_INCREMENT_DUMP

const SOURCE_DRILL_INVENTORY_ITEM_COUNT_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_ITEM_COUNT_KEY
const SOURCE_DRILL_INVENTORY_ITEM_COUNT_FALLBACK := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_ITEM_COUNT_FALLBACK
const SOURCE_DRILL_INVENTORY_CORE_ACCEPT_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_CORE_ACCEPT_KEY
const SOURCE_DRILL_INVENTORY_CORE_ACCEPT_FALLBACK := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_CORE_ACCEPT_FALLBACK
const SOURCE_DRILL_INVENTORY_CORE_HANDLE_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_CORE_HANDLE_KEY
const SOURCE_DRILL_INVENTORY_CORE_HANDLE_FALLBACK := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_CORE_HANDLE_FALLBACK
const SOURCE_DRILL_INVENTORY_REMOVE_ITEM_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_REMOVE_ITEM_KEY
const SOURCE_DRILL_INVENTORY_REMOVE_ITEM_FALLBACK := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_REMOVE_ITEM_FALLBACK
const SOURCE_DRILL_INVENTORY_INCREMENT_DUMP_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_INCREMENT_DUMP_KEY
const SOURCE_DRILL_INVENTORY_INCREMENT_DUMP_FALLBACK := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_INCREMENT_DUMP_FALLBACK
const SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY
const SOURCE_DRILL_INVENTORY_ITEM_ID_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_ITEM_ID_KEY
const SOURCE_DRILL_INVENTORY_AMOUNT_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_AMOUNT_KEY
const SOURCE_DRILL_INVENTORY_ITEM_COUNT_RESULT_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_ITEM_COUNT_RESULT_KEY
const SOURCE_DRILL_INVENTORY_SOURCE_OWNER_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_SOURCE_OWNER_KEY
const SOURCE_DRILL_INVENTORY_REQUESTED_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_REQUESTED_KEY
const SOURCE_DRILL_INVENTORY_REMOVED_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_REMOVED_KEY
const SOURCE_DRILL_INVENTORY_DUMP_SUCCESS_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_DUMP_SUCCESS_KEY
const SOURCE_DRILL_INVENTORY_REASON_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_REASON_KEY
const SOURCE_DRILL_INVENTORY_EMPTY_REASON := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_EMPTY_REASON
const SOURCE_DRILL_INVENTORY_CORE_REJECTED_REASON := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_CORE_REJECTED_REASON
const SOURCE_DRILL_INVENTORY_CORE_ACCEPTED_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_CORE_ACCEPTED_KEY
const SOURCE_DRILL_INVENTORY_CORE_HANDLE_FAILED_REASON := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_CORE_HANDLE_FAILED_REASON
const SOURCE_DRILL_INVENTORY_CORE_HANDLED_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_CORE_HANDLED_KEY
const SOURCE_DRILL_INVENTORY_DUMPED_REASON := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_DUMPED_REASON
const SOURCE_DRILL_INVENTORY_REMOVE_FAILED_REASON := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_REMOVE_FAILED_REASON
const SOURCE_DRILL_INVENTORY_ROUTING_CONTEXT_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_ROUTING_CONTEXT_KEY
const SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY
const SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY
const SOURCE_DRILL_INVENTORY_C_DUMP_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_C_DUMP_KEY
const SOURCE_DRILL_INVENTORY_CHECKED_INDICES_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_CHECKED_INDICES_KEY
const SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY
const SOURCE_DRILL_INVENTORY_NEIGHBOR_HANDLE_CALLS_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_NEIGHBOR_HANDLE_CALLS_KEY
const SOURCE_DRILL_INVENTORY_PRODUCED_COUNT_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_PRODUCED_COUNT_KEY
const SOURCE_DRILL_INVENTORY_ROUTED_COUNT_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_ROUTED_COUNT_KEY
const SOURCE_DRILL_INVENTORY_FALLBACK_COUNT_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_FALLBACK_COUNT_KEY
const SOURCE_DRILL_INVENTORY_OFFLOAD_CALLS_KEY := source_drill_inventory_source_text_state.SOURCE_DRILL_INVENTORY_OFFLOAD_CALLS_KEY

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_drill_inventory_method_names"):
		var names = game.call("_drill_inventory_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_DRILL_INVENTORY_ITEM_COUNT_KEY: Callable(game, runtime_method_name(method_names, SOURCE_DRILL_INVENTORY_ITEM_COUNT_KEY, SOURCE_DRILL_INVENTORY_ITEM_COUNT_FALLBACK)),
		SOURCE_DRILL_INVENTORY_CORE_ACCEPT_KEY: Callable(game, runtime_method_name(method_names, SOURCE_DRILL_INVENTORY_CORE_ACCEPT_KEY, SOURCE_DRILL_INVENTORY_CORE_ACCEPT_FALLBACK)),
		SOURCE_DRILL_INVENTORY_CORE_HANDLE_KEY: Callable(game, runtime_method_name(method_names, SOURCE_DRILL_INVENTORY_CORE_HANDLE_KEY, SOURCE_DRILL_INVENTORY_CORE_HANDLE_FALLBACK)),
		SOURCE_DRILL_INVENTORY_REMOVE_ITEM_KEY: Callable(game, runtime_method_name(method_names, SOURCE_DRILL_INVENTORY_REMOVE_ITEM_KEY, SOURCE_DRILL_INVENTORY_REMOVE_ITEM_FALLBACK)),
		SOURCE_DRILL_INVENTORY_INCREMENT_DUMP_KEY: Callable(game, runtime_method_name(method_names, SOURCE_DRILL_INVENTORY_INCREMENT_DUMP_KEY, SOURCE_DRILL_INVENTORY_INCREMENT_DUMP_FALLBACK)),
	}

static func game_dump_item_to_core_state(game: Object, item_id: String) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return dump_item_to_core_state(item_id, callbacks.get(SOURCE_DRILL_INVENTORY_ITEM_COUNT_KEY, Callable()), callbacks.get(SOURCE_DRILL_INVENTORY_CORE_ACCEPT_KEY, Callable()), callbacks.get(SOURCE_DRILL_INVENTORY_CORE_HANDLE_KEY, Callable()), callbacks.get(SOURCE_DRILL_INVENTORY_REMOVE_ITEM_KEY, Callable()), callbacks.get(SOURCE_DRILL_INVENTORY_INCREMENT_DUMP_KEY, Callable()))

static func item_count(items: Dictionary, item_id: String) -> int:
	return int(items.get(item_id, 0))

static func items_total(items: Dictionary) -> int:
	var total := 0
	for amount in items.values():
		total += int(amount)
	return total

static func add_item_state(items: Dictionary, item_id: String, amount: int) -> Dictionary:
	var next_items := items.duplicate(true)
	next_items[item_id] = item_count(next_items, item_id) + amount
	return {
		SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY: next_items,
		SOURCE_DRILL_INVENTORY_ITEM_ID_KEY: item_id,
		SOURCE_DRILL_INVENTORY_AMOUNT_KEY: amount,
		SOURCE_DRILL_INVENTORY_ITEM_COUNT_RESULT_KEY: item_count(next_items, item_id),
	}

static func add_item_runtime_state(game: Object, item_id: String, amount: int) -> void:
	var state := add_item_state(game.drill_items, item_id, amount)
	game.drill_items = state.get(SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, game.drill_items).duplicate(true)

static func offload_item_state(items: Dictionary, item_id: String, routing_context: Dictionary = {}) -> Dictionary:
	var neighbors_value = routing_context.get(SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY, [])
	var neighbors: Array = neighbors_value if neighbors_value is Array else []
	neighbors = neighbors.duplicate(true)
	var dump_cursor := int(routing_context.get(SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY, 0))
	var next_dump := dump_cursor
	var checked_indices: Array = []
	var neighbor_handle_calls: Array = []
	for index in range(neighbors.size()):
		# Match the source order: rotate the cursor, then inspect from its saved value.
		next_dump = (next_dump + 1) % neighbors.size()
		var neighbor_index := (index + dump_cursor) % neighbors.size()
		checked_indices.append(neighbor_index)
		var neighbor_value = neighbors[neighbor_index]
		var neighbor: Dictionary = neighbor_value if neighbor_value is Dictionary else {}
		if bool(neighbor.get("accepts_item", false)) and bool(neighbor.get("can_dump", false)):
			neighbor["item_count"] = int(neighbor.get("item_count", 0)) + 1
			neighbors[neighbor_index] = neighbor
			neighbor_handle_calls.append({"call": SOURCE_OFFLOAD_TO_INVENTORY_NEIGHBOR_HANDLE, "neighbor_index": neighbor_index, "item_id": item_id})
			return {
				SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY: items.duplicate(true),
				SOURCE_DRILL_INVENTORY_C_DUMP_KEY: next_dump,
				SOURCE_DRILL_INVENTORY_CHECKED_INDICES_KEY: checked_indices,
				SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY: neighbor_index,
				SOURCE_DRILL_INVENTORY_NEIGHBOR_HANDLE_CALLS_KEY: neighbor_handle_calls,
				SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY: neighbors,
				"routed": true,
				"fallback": false,
			}
	var fallback_state := add_item_state(items, item_id, 1)
	fallback_state[SOURCE_DRILL_INVENTORY_C_DUMP_KEY] = next_dump
	fallback_state[SOURCE_DRILL_INVENTORY_CHECKED_INDICES_KEY] = checked_indices
	fallback_state[SOURCE_DRILL_INVENTORY_HANDLED_INDEX_KEY] = -1
	fallback_state[SOURCE_DRILL_INVENTORY_NEIGHBOR_HANDLE_CALLS_KEY] = neighbor_handle_calls
	fallback_state[SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY] = neighbors
	fallback_state["routed"] = false
	fallback_state["fallback"] = true
	return fallback_state

static func offload_to_inventory_state(items: Dictionary, item_id: String, amount: int, routing_context: Dictionary = {}) -> Dictionary:
	var next_items := items.duplicate(true)
	var next_dump := int(routing_context.get(SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY, 0))
	var neighbors_value = routing_context.get(SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY, [])
	var neighbors: Array = neighbors_value if neighbors_value is Array else []
	var routed_count := 0
	var fallback_count := 0
	var offload_calls: Array = []
	for _index in range(maxi(amount, 0)):
		var item_context := routing_context.duplicate(true)
		item_context[SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY] = next_dump
		item_context[SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY] = neighbors
		var item_state := offload_item_state(next_items, item_id, item_context)
		next_items = item_state.get(SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, next_items).duplicate(true)
		next_dump = int(item_state.get(SOURCE_DRILL_INVENTORY_C_DUMP_KEY, next_dump))
		neighbors = item_state.get(SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY, neighbors)
		routed_count += 1 if bool(item_state.get("routed", false)) else 0
		fallback_count += 1 if bool(item_state.get("fallback", false)) else 0
		offload_calls.append(item_state)
	return {
		SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY: next_items,
		SOURCE_DRILL_INVENTORY_ITEM_ID_KEY: item_id,
		SOURCE_DRILL_INVENTORY_AMOUNT_KEY: amount,
		SOURCE_DRILL_INVENTORY_ITEM_COUNT_RESULT_KEY: item_count(next_items, item_id),
		SOURCE_DRILL_INVENTORY_C_DUMP_KEY: next_dump,
		SOURCE_DRILL_INVENTORY_PRODUCED_COUNT_KEY: maxi(amount, 0),
		SOURCE_DRILL_INVENTORY_ROUTED_COUNT_KEY: routed_count,
		SOURCE_DRILL_INVENTORY_FALLBACK_COUNT_KEY: fallback_count,
		SOURCE_DRILL_INVENTORY_OFFLOAD_CALLS_KEY: offload_calls,
		SOURCE_DRILL_INVENTORY_ROUTING_CONTEXT_KEY: routing_context,
		SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY: neighbors,
		SOURCE_DRILL_INVENTORY_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_OFFLOAD_TO_INVENTORY,
	}

static func offload_to_inventory_runtime_state(game: Object, item_id: String, amount: int, routing_context: Dictionary = {}) -> void:
	var context := routing_context.duplicate(true)
	if not context.has(SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY):
		context[SOURCE_DRILL_INVENTORY_DUMP_CURSOR_KEY] = game.drill_dump_cursor
	if not context.has(SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY):
		context[SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY] = game.get("offload_neighbors")
	var state := offload_to_inventory_state(game.drill_items, item_id, amount, context)
	game.drill_items = state.get(SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, game.drill_items).duplicate(true)
	game.drill_dump_cursor = int(state.get(SOURCE_DRILL_INVENTORY_C_DUMP_KEY, game.drill_dump_cursor))
	game.set("offload_neighbors", state.get(SOURCE_DRILL_INVENTORY_NEIGHBORS_KEY, game.get("offload_neighbors")))

static func remove_item_state(items: Dictionary, item_id: String, amount: int) -> Dictionary:
	var next_items := items.duplicate(true)
	var removed := mini(amount, item_count(next_items, item_id))
	next_items[item_id] = item_count(next_items, item_id) - removed
	return {
		SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY: next_items,
		SOURCE_DRILL_INVENTORY_ITEM_ID_KEY: item_id,
		SOURCE_DRILL_INVENTORY_REQUESTED_KEY: amount,
		SOURCE_DRILL_INVENTORY_REMOVED_KEY: removed,
		SOURCE_DRILL_INVENTORY_ITEM_COUNT_RESULT_KEY: item_count(next_items, item_id),
	}

static func remove_item_runtime_state(game: Object, item_id: String, amount: int) -> int:
	var state := remove_item_state(game.drill_items, item_id, amount)
	game.drill_items = state.get(SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, game.drill_items).duplicate(true)
	return int(state.get(SOURCE_DRILL_INVENTORY_REMOVED_KEY, 0))

static func dump_item_to_core_state(item_id: String, item_count_fn: Callable, core_accept_fn: Callable, core_handle_fn: Callable, remove_item_fn: Callable, increment_dump_fn: Callable) -> Dictionary:
	var drill_item_count := int(item_count_fn.call(item_id))
	if drill_item_count <= 0:
		return {SOURCE_DRILL_INVENTORY_DUMP_SUCCESS_KEY: false, SOURCE_DRILL_INVENTORY_REASON_KEY: SOURCE_DRILL_INVENTORY_EMPTY_REASON, SOURCE_DRILL_INVENTORY_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_DUMP_DRILL_ITEM_TO_CORE}
	var core_accepted := bool(core_accept_fn.call(item_id))
	if not core_accepted:
		increment_dump_fn.call(1)
		return {SOURCE_DRILL_INVENTORY_DUMP_SUCCESS_KEY: false, SOURCE_DRILL_INVENTORY_REASON_KEY: SOURCE_DRILL_INVENTORY_CORE_REJECTED_REASON, SOURCE_DRILL_INVENTORY_CORE_ACCEPTED_KEY: false, SOURCE_DRILL_INVENTORY_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_DUMP_DRILL_ITEM_TO_CORE}
	var core_handled := bool(core_handle_fn.call(item_id))
	if not core_handled:
		increment_dump_fn.call(1)
		return {SOURCE_DRILL_INVENTORY_DUMP_SUCCESS_KEY: false, SOURCE_DRILL_INVENTORY_REASON_KEY: SOURCE_DRILL_INVENTORY_CORE_HANDLE_FAILED_REASON, SOURCE_DRILL_INVENTORY_CORE_ACCEPTED_KEY: true, SOURCE_DRILL_INVENTORY_CORE_HANDLED_KEY: false, SOURCE_DRILL_INVENTORY_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_DUMP_DRILL_ITEM_TO_CORE}
	var removed := int(remove_item_fn.call(item_id, 1))
	increment_dump_fn.call(1)
	return {SOURCE_DRILL_INVENTORY_DUMP_SUCCESS_KEY: removed > 0, SOURCE_DRILL_INVENTORY_REASON_KEY: SOURCE_DRILL_INVENTORY_DUMPED_REASON if removed > 0 else SOURCE_DRILL_INVENTORY_REMOVE_FAILED_REASON, SOURCE_DRILL_INVENTORY_CORE_ACCEPTED_KEY: true, SOURCE_DRILL_INVENTORY_CORE_HANDLED_KEY: true, SOURCE_DRILL_INVENTORY_REMOVED_KEY: removed, SOURCE_DRILL_INVENTORY_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_DUMP_DRILL_ITEM_TO_CORE}
