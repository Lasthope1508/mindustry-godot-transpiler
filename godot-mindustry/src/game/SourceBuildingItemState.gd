extends RefCounted
class_name SourceBuildingItemState

const source_building_item_source_text_state := preload("res://src/game/SourceBuildingItemSourceTextState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")

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
