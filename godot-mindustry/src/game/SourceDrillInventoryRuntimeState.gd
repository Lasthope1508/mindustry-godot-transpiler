extends RefCounted
class_name SourceDrillInventoryRuntimeState

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

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"item_count": Callable(game, "drill_item_count"),
		"core_accept": Callable(game, "source_core_accept_item"),
		"core_handle": Callable(game, "source_core_handle_item"),
		"remove_item": Callable(game, "remove_drill_item"),
		"increment_dump": Callable(game, "increment_drill_dump"),
	}

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

static func offload_to_inventory_state(items: Dictionary, item_id: String, amount: int) -> Dictionary:
	var state := add_item_state(items, item_id, amount)
	state["source_owner"] = "PortGame.source_offload_to_inventory"
	return state

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

static func dump_item_to_core_state(item_id: String, item_count_fn: Callable, core_accept_fn: Callable, core_handle_fn: Callable, remove_item_fn: Callable, increment_dump_fn: Callable) -> Dictionary:
	var drill_item_count := int(item_count_fn.call(item_id))
	if drill_item_count <= 0:
		return {"dump_success": false, "reason": "empty", "source_owner": "PortGame.source_dump_drill_item_to_core"}
	var core_accepted := bool(core_accept_fn.call(item_id))
	if not core_accepted:
		increment_dump_fn.call(1)
		return {"dump_success": false, "reason": "core_rejected", "core_accepted": false, "source_owner": "PortGame.source_dump_drill_item_to_core"}
	var core_handled := bool(core_handle_fn.call(item_id))
	if not core_handled:
		increment_dump_fn.call(1)
		return {"dump_success": false, "reason": "core_handle_failed", "core_accepted": true, "core_handled": false, "source_owner": "PortGame.source_dump_drill_item_to_core"}
	var removed := int(remove_item_fn.call(item_id, 1))
	increment_dump_fn.call(1)
	return {"dump_success": removed > 0, "reason": "dumped" if removed > 0 else "remove_failed", "core_accepted": true, "core_handled": true, "removed": removed, "source_owner": "PortGame.source_dump_drill_item_to_core"}
