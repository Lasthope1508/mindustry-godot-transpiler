extends RefCounted
class_name SourceBuildingItemState

const source_building_item_source_text_state := preload("res://src/game/SourceBuildingItemSourceTextState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const inventory := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")
const source_conveyor_runtime_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const source_placed_power_graph_state := preload("res://src/game/SourcePlacedPowerGraphState.gd")

# Conveyor.java:27-28: itemSpace = 0.4f, capacity = 3.
const SOURCE_NEIGHBOUR_CONVEYOR_CAPACITY := 3
const SOURCE_NEIGHBOUR_CONVEYOR_ITEM_SPACE := 0.4

const SOURCE_MOVE_FORWARD_ACCEPT_METHOD := source_building_item_source_text_state.SOURCE_MOVE_FORWARD_ACCEPT_METHOD
const SOURCE_MOVE_FORWARD_ACCEPT_FRONT := source_building_item_source_text_state.SOURCE_MOVE_FORWARD_ACCEPT_FRONT
const SOURCE_MOVE_FORWARD_ACCEPT_GATE := source_building_item_source_text_state.SOURCE_MOVE_FORWARD_ACCEPT_GATE
const SOURCE_MOVE_FORWARD_ACCEPT_HANDLE_DEFERRED := source_building_item_source_text_state.SOURCE_MOVE_FORWARD_ACCEPT_HANDLE_DEFERRED
const SOURCE_MOVE_FORWARD_ACCEPT_RETURN_TRUE := source_building_item_source_text_state.SOURCE_MOVE_FORWARD_ACCEPT_RETURN_TRUE
const SOURCE_MOVE_FORWARD_ACCEPT_RETURN_FALSE := source_building_item_source_text_state.SOURCE_MOVE_FORWARD_ACCEPT_RETURN_FALSE
const SOURCE_MOVE_FORWARD_TO_CORE_ACCEPT_BRIDGE := source_building_item_source_text_state.SOURCE_MOVE_FORWARD_TO_CORE_ACCEPT_BRIDGE
const SOURCE_MOVE_FORWARD_TO_CORE_HANDLE_BRIDGE := source_building_item_source_text_state.SOURCE_MOVE_FORWARD_TO_CORE_HANDLE_BRIDGE
const SOURCE_BUILDING_REMOVE_STACK_METHOD := source_building_item_source_text_state.SOURCE_BUILDING_REMOVE_STACK_METHOD
const SOURCE_BUILDING_REMOVE_STACK_NULL_GUARD := source_building_item_source_text_state.SOURCE_BUILDING_REMOVE_STACK_NULL_GUARD
const SOURCE_BUILDING_REMOVE_STACK_MIN_ASSIGN := source_building_item_source_text_state.SOURCE_BUILDING_REMOVE_STACK_MIN_ASSIGN
const SOURCE_BUILDING_REMOVE_STACK_NO_SLEEP_CALL := source_building_item_source_text_state.SOURCE_BUILDING_REMOVE_STACK_NO_SLEEP_CALL
const SOURCE_BUILDING_REMOVE_STACK_ITEMS_REMOVE_CALL := source_building_item_source_text_state.SOURCE_BUILDING_REMOVE_STACK_ITEMS_REMOVE_CALL
const SOURCE_BUILDING_REMOVE_STACK_RETURN_AMOUNT := source_building_item_source_text_state.SOURCE_BUILDING_REMOVE_STACK_RETURN_AMOUNT

static func move_forward_accept_state(has_front: bool, same_team: bool, front_accepts: bool) -> bool:
	return has_front and same_team and front_accepts

static func move_forward_to_core_runtime_state(game: Object, item_id: String, has_front: bool, same_team: bool) -> bool:
	if not move_forward_accept_state(has_front, same_team, game.source_core_accept_item(item_id)):
		return false
	return game.source_core_handle_item(item_id)

static func maximum_accepted(block_item_capacity: int) -> int:
	return block_item_capacity

static func handle_item_count(current_count: int) -> int:
	return current_count + 1

static func handle_stack_count(current_count: int, amount: int) -> int:
	return current_count + amount

static func accept_item_state(consumes_item: bool, item_count: int, maximum_accepted_value: int) -> bool:
	return consumes_item and item_count < maximum_accepted_value

static func accept_stack_state(accepts_item: bool, has_items: bool, same_team_or_null_source: bool, maximum_accepted_value: int, item_count: int, amount: int) -> int:
	if accepts_item and has_items and same_team_or_null_source:
		return mini(maximum_accepted_value - item_count, amount)
	return 0

static func source_neighbour_item_write_back_state(game: Object, cell: Vector2i, size: int, neighbour_index: int, item: String, amount: int) -> Dictionary:
	# The neighbour item write-back (N2353): offload()
	# (`public void offload(Item item){`, BuildingComp.java:1001-1016)
	# hands the picked item to the first accepting neighbour --
	# `Building other = proximity.get((i + dump) % proximity.size);` (:1007)
	# where `if(other.acceptItem(self(), item) && canDump(other, item)){` (:1008) holds --
	# via `other.handleItem(self(), item);` (:1009). handleItem is
	# `public void handleItem(Building source, Item item){` with `items.add(item, 1);`
	# (BuildingComp.java:860-862), no capacity check (acceptItem
	# already gated); the multi-item form is handleStack
	# (`public void handleStack(Item item, int amount, @Nullable Teamc source){` with
	# `items.add(item, amount);`, BuildingComp.java:795-798).
	# N2343 routed the pick but only bumped the ephemeral
	# neighbour dict item_count; this helper lands the item
	# for real. Index i is ring cell i (the
	# source_block_proximity_cells_state ring, angle-sorted),
	# so the live fill must fill the frame neighbour inputs
	# in ring order; the sprite resolves through
	# block_sprite_at_cell. A belt neighbour is told from a
	# building neighbour by the conveyor queue meta key on
	# the sprite, checked FIRST: a conveyor's handleItem
	# goes to its belt queue, never to a frame items dict.
	# The belt path runs the shared
	# source_conveyor_handle_for_cell_state (the drill dump
	# hooks precedent: the facing-edge source cell, the
	# per-item count_before) once per item on queue copies
	# and commits through set_queue only when every item
	# inserts -- ConveyorBuild.handleItem guards
	# `if(len >= capacity) return;` (Conveyor.java:362-363)
	# with `private static final float itemSpace = 0.4f;` and
	# `private static final int capacity = 3;` (Conveyor.java:27-28),
	# so a full belt reports belt_full with nothing written.
	# The frame path is the N2142 write-back precedent: the
	# first SOURCE_CONSUMER_FRAME_META_KEYS frame present on
	# the sprite, the item lands through the shared inventory
	# add_item_state, and the frame is written back with
	# set_meta. No sprite, no frame, a frame with no items
	# store, or a full belt reports written false with a
	# reason -- the item is already routed away, so there is
	# no fallback to the source store (a deviation from Java,
	# where other is always a real Building with an items
	# module; core / conduit neighbours carry no frame in the
	# meta-key list, so a routed item to one drops with
	# reason no_frame until a core/conduit store mapping
	# lands). No accept re-check here: the routing gate
	# already decided acceptance (BuildingComp.java:1008).
	var no_cell := Vector2i(-1, -1)
	if amount <= 0:
		return {"written": false, "reason": "invalid_amount", "neighbour_cell": no_cell}
	if item.is_empty():
		return {"written": false, "reason": "invalid_item", "neighbour_cell": no_cell}
	var ring: Array = source_block_geometry.source_block_proximity_cells_state(size, cell.x, cell.y).get("cells", [])
	if neighbour_index < 0 or neighbour_index >= ring.size():
		return {"written": false, "reason": "invalid_index", "neighbour_cell": no_cell}
	var neighbour_cell: Vector2i = ring[neighbour_index]
	var sprite: Variant = game.call("block_sprite_at_cell", neighbour_cell)
	if sprite == null:
		return {"written": false, "reason": "no_sprite", "neighbour_cell": neighbour_cell}
	if sprite.has_meta(source_conveyor_runtime_state.SOURCE_CONVEYOR_QUEUE_META_KEY):
		var queue: Dictionary = source_conveyor_runtime_state.source_conveyor_queue_for_cell_state(game, neighbour_cell)
		var ids: Array = (queue.get("ids", []) as Array).duplicate()
		var xs: Array = (queue.get("xs", []) as Array).duplicate()
		var ys: Array = (queue.get("ys", []) as Array).duplicate()
		var queue_len: int = int(queue.get("len", 0))
		var edge: Dictionary = source_block_geometry.source_block_facing_edge_state(size, cell.x, cell.y, neighbour_cell.x, neighbour_cell.y)
		var edge_cell := Vector2i(int(edge.get("edge_x", cell.x)), int(edge.get("edge_y", cell.y)))
		var rotation: int = int(sprite.get_meta(source_block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0))
		for _i in range(amount):
			var count_before := 0
			for queue_id in ids:
				if str(queue_id) == item:
					count_before += 1
			var handled: Dictionary = source_conveyor_runtime_state.source_conveyor_handle_for_cell_state(ids, xs, ys, queue_len, SOURCE_NEIGHBOUR_CONVEYOR_CAPACITY, SOURCE_NEIGHBOUR_CONVEYOR_ITEM_SPACE, edge_cell, neighbour_cell, rotation, item, count_before)
			if int(handled.get("index", -1)) < 0:
				return {"written": false, "reason": "belt_full", "neighbour_cell": neighbour_cell}
			ids = handled["ids_after"]
			xs = handled["xs_after"]
			ys = handled["ys_after"]
			queue_len = int(handled["len_after"])
		source_conveyor_runtime_state.source_conveyor_set_queue_for_cell_state(game, neighbour_cell, {"ids": ids, "xs": xs, "ys": ys, "len": queue_len})
		return {"written": true, "reason": "belt", "neighbour_cell": neighbour_cell}
	for meta_key in source_placed_power_graph_state.SOURCE_CONSUMER_FRAME_META_KEYS:
		if not sprite.has_meta(meta_key):
			continue
		var frame: Variant = sprite.get_meta(meta_key)
		if frame is Dictionary:
			var neighbour_items: Variant = frame.get("items", null)
			if not (neighbour_items is Dictionary):
				return {"written": false, "reason": "no_items_store", "neighbour_cell": neighbour_cell}
			var added: Dictionary = inventory.add_item_state(neighbour_items, item, amount)
			frame["items"] = added.get(inventory.SOURCE_DRILL_INVENTORY_DRILL_ITEMS_KEY, neighbour_items)
			sprite.set_meta(meta_key, frame)
			return {"written": true, "reason": "live_frame", "neighbour_cell": neighbour_cell}
	return {"written": false, "reason": "no_frame", "neighbour_cell": neighbour_cell}

static func remove_stack_state(has_items_module: bool, item_count: int, amount: int) -> Dictionary:
	if not has_items_module:
		return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_REMOVE_STACK_STATE, "method": SOURCE_BUILDING_REMOVE_STACK_METHOD, "null_guard": SOURCE_BUILDING_REMOVE_STACK_NULL_GUARD, "has_items_module": has_items_module, "item_count": item_count, "amount": amount, "removed": 0, "remaining": item_count, "return_value": 0}
	var removed := mini(amount, item_count)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_REMOVE_STACK_STATE, "method": SOURCE_BUILDING_REMOVE_STACK_METHOD, "null_guard": SOURCE_BUILDING_REMOVE_STACK_NULL_GUARD, "min_assign": SOURCE_BUILDING_REMOVE_STACK_MIN_ASSIGN, "no_sleep_call": SOURCE_BUILDING_REMOVE_STACK_NO_SLEEP_CALL, "items_remove_call": SOURCE_BUILDING_REMOVE_STACK_ITEMS_REMOVE_CALL, "return_amount": SOURCE_BUILDING_REMOVE_STACK_RETURN_AMOUNT, "has_items_module": has_items_module, "item_count": item_count, "amount": amount, "removed": removed, "remaining": item_count - removed, "return_value": removed}


# Building.handleStack: noSleep() runs first, then the stack is added.
# The wake transition comes from the noSleep binding; the group add() is
# recorded, not executed, because the runtime has no entity groups.
static func source_handle_stack_wake_state(current_count: int, amount: int, sleep_time: float, sleeping: bool, sleeping_entities: int) -> Dictionary:
	var wake: Dictionary = source_building_access_state.no_sleep_state(sleeping, sleeping_entities)
	return {
		"count_before": current_count,
		"count_after": handle_stack_count(current_count, amount),
		"sleep_time_before": sleep_time,
		"sleep_time_after": wake.get("sleep_time", 0.0),
		"sleeping_before": sleeping,
		"sleeping_after": wake.get("sleeping_after", false),
		"sleeping_entities_before": sleeping_entities,
		"sleeping_entities_after": wake.get("sleeping_entities_after", sleeping_entities),
		"woke": sleeping,
		"add_called": wake.get("add_called", false),
	}


# Building.removeStack: the null guard returns 0 before noSleep, so a
# Building without an items module keeps its sleep state untouched. With
# an items module, noSleep runs, then the clamped stack is removed.
static func source_remove_stack_wake_state(has_items_module: bool, item_count: int, amount: int, sleep_time: float, sleeping: bool, sleeping_entities: int) -> Dictionary:
	var removed_state: Dictionary = remove_stack_state(has_items_module, item_count, amount)
	if not has_items_module:
		return {
			"removed": removed_state.get("removed", 0),
			"remaining": removed_state.get("remaining", item_count),
			"return_value": removed_state.get("return_value", 0),
			"sleep_time_before": sleep_time,
			"sleep_time_after": sleep_time,
			"sleeping_before": sleeping,
			"sleeping_after": sleeping,
			"sleeping_entities_before": sleeping_entities,
			"sleeping_entities_after": sleeping_entities,
			"woke": false,
			"add_called": false,
		}
	var wake: Dictionary = source_building_access_state.no_sleep_state(sleeping, sleeping_entities)
	return {
		"removed": removed_state.get("removed", 0),
		"remaining": removed_state.get("remaining", item_count),
		"return_value": removed_state.get("return_value", 0),
		"sleep_time_before": sleep_time,
		"sleep_time_after": wake.get("sleep_time", 0.0),
		"sleeping_before": sleeping,
		"sleeping_after": wake.get("sleeping_after", false),
		"sleeping_entities_before": sleeping_entities,
		"sleeping_entities_after": wake.get("sleeping_entities_after", sleeping_entities),
		"woke": sleeping,
		"add_called": wake.get("add_called", false),
	}
