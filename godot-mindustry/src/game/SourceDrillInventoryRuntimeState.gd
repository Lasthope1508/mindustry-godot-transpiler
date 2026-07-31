extends RefCounted
class_name SourceDrillInventoryRuntimeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_OFFLOAD_TO_INVENTORY_METHOD := "public void offload(Item item){"
const SOURCE_OFFLOAD_TO_INVENTORY_PRODUCED := "produced(item, 1);"
const SOURCE_OFFLOAD_TO_INVENTORY_FALLBACK_HANDLE := "handleItem(self(), item);"
const SOURCE_OFFLOAD_TO_INVENTORY_BUILDING_HANDLE_ADD := "items.add(item, 1);"
const SOURCE_OFFLOAD_TO_INVENTORY_BATCH_AMOUNT := "int amount = (int)(progress / delay);"
const SOURCE_OFFLOAD_TO_INVENTORY_BATCH_LOOP := "for(int i = 0; i < amount; i++){"
const SOURCE_OFFLOAD_TO_INVENTORY_BATCH_OFFLOAD := "offload(dominantItem);"

const SOURCE_DUMP_DRILL_ITEM_TO_CORE_METHOD := "public boolean dump(Item todump){"
const SOURCE_DUMP_DRILL_ITEM_TO_CORE_INITIAL_GUARD := "if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;"
const SOURCE_DUMP_DRILL_ITEM_TO_CORE_ACCEPT_CAN_DUMP := "if(other.acceptItem(self(), todump) && canDump(other, todump)){"
const SOURCE_DUMP_DRILL_ITEM_TO_CORE_HANDLE_ITEM := "other.handleItem(self(), todump);"
const SOURCE_DUMP_DRILL_ITEM_TO_CORE_REMOVE_ITEM := "items.remove(todump, 1);"
const SOURCE_DUMP_DRILL_ITEM_TO_CORE_INCREMENT_DUMP := "incrementDump(proximity.size);"

const SOURCE_DRILL_INVENTORY_ITEM_COUNT_KEY := "item_count"
const SOURCE_DRILL_INVENTORY_ITEM_COUNT_FALLBACK := "drill_item_count"
const SOURCE_DRILL_INVENTORY_CORE_ACCEPT_KEY := "core_accept"
const SOURCE_DRILL_INVENTORY_CORE_ACCEPT_FALLBACK := "source_core_accept_item"
const SOURCE_DRILL_INVENTORY_CORE_HANDLE_KEY := "core_handle"
const SOURCE_DRILL_INVENTORY_CORE_HANDLE_FALLBACK := "source_core_handle_item"
const SOURCE_DRILL_INVENTORY_REMOVE_ITEM_KEY := "remove_item"
const SOURCE_DRILL_INVENTORY_REMOVE_ITEM_FALLBACK := "remove_drill_item"
const SOURCE_DRILL_INVENTORY_INCREMENT_DUMP_KEY := "increment_dump"
const SOURCE_DRILL_INVENTORY_INCREMENT_DUMP_FALLBACK := "increment_drill_dump"

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
		"drill_items": next_items,
		"item_id": item_id,
		"amount": amount,
		"item_count": item_count(next_items, item_id),
	}

static func add_item_runtime_state(game: Object, item_id: String, amount: int) -> void:
	var state := add_item_state(game.drill_items, item_id, amount)
	game.drill_items = state.get("drill_items", game.drill_items).duplicate(true)

static func offload_to_inventory_state(items: Dictionary, item_id: String, amount: int) -> Dictionary:
	var state := add_item_state(items, item_id, amount)
	state["source_owner"] = source_runtime_owner_registry.PORT_GAME_SOURCE_OFFLOAD_TO_INVENTORY
	return state

static func offload_to_inventory_runtime_state(game: Object, item_id: String, amount: int) -> void:
	var state := offload_to_inventory_state(game.drill_items, item_id, amount)
	game.drill_items = state.get("drill_items", game.drill_items).duplicate(true)

static func remove_item_state(items: Dictionary, item_id: String, amount: int) -> Dictionary:
	var next_items := items.duplicate(true)
	var removed := mini(amount, item_count(next_items, item_id))
	next_items[item_id] = item_count(next_items, item_id) - removed
	return {
		"drill_items": next_items,
		"item_id": item_id,
		"requested": amount,
		"removed": removed,
		"item_count": item_count(next_items, item_id),
	}

static func remove_item_runtime_state(game: Object, item_id: String, amount: int) -> int:
	var state := remove_item_state(game.drill_items, item_id, amount)
	game.drill_items = state.get("drill_items", game.drill_items).duplicate(true)
	return int(state.get("removed", 0))

static func dump_item_to_core_state(item_id: String, item_count_fn: Callable, core_accept_fn: Callable, core_handle_fn: Callable, remove_item_fn: Callable, increment_dump_fn: Callable) -> Dictionary:
	var drill_item_count := int(item_count_fn.call(item_id))
	if drill_item_count <= 0:
		return {"dump_success": false, "reason": "empty", "source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_DUMP_DRILL_ITEM_TO_CORE}
	var core_accepted := bool(core_accept_fn.call(item_id))
	if not core_accepted:
		increment_dump_fn.call(1)
		return {"dump_success": false, "reason": "core_rejected", "core_accepted": false, "source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_DUMP_DRILL_ITEM_TO_CORE}
	var core_handled := bool(core_handle_fn.call(item_id))
	if not core_handled:
		increment_dump_fn.call(1)
		return {"dump_success": false, "reason": "core_handle_failed", "core_accepted": true, "core_handled": false, "source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_DUMP_DRILL_ITEM_TO_CORE}
	var removed := int(remove_item_fn.call(item_id, 1))
	increment_dump_fn.call(1)
	return {"dump_success": removed > 0, "reason": "dumped" if removed > 0 else "remove_failed", "core_accepted": true, "core_handled": true, "removed": removed, "source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_DUMP_DRILL_ITEM_TO_CORE}
