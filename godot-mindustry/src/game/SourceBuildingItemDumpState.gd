extends RefCounted
class_name SourceBuildingItemDumpState

const source_building_item_dump_source_text_state := preload("res://src/game/SourceBuildingItemDumpSourceTextState.gd")

const SOURCE_INCREMENT_DUMP_CURSOR_METHOD := source_building_item_dump_source_text_state.SOURCE_INCREMENT_DUMP_CURSOR_METHOD
const SOURCE_INCREMENT_DUMP_CURSOR_COMMENT := source_building_item_dump_source_text_state.SOURCE_INCREMENT_DUMP_CURSOR_COMMENT
const SOURCE_INCREMENT_DUMP_CURSOR_NONZERO_GUARD := source_building_item_dump_source_text_state.SOURCE_INCREMENT_DUMP_CURSOR_NONZERO_GUARD
const SOURCE_INCREMENT_DUMP_CURSOR_ASSIGNMENT := source_building_item_dump_source_text_state.SOURCE_INCREMENT_DUMP_CURSOR_ASSIGNMENT
const SOURCE_BUILDING_ITEM_DUMP_METHOD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_METHOD
const SOURCE_BUILDING_ITEM_DUMP_INITIAL_GUARD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_INITIAL_GUARD
const SOURCE_BUILDING_ITEM_DUMP_CURSOR_ASSIGNMENT := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_CURSOR_ASSIGNMENT
const SOURCE_BUILDING_ITEM_DUMP_ITEM_ARRAY := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_ITEM_ARRAY
const SOURCE_BUILDING_ITEM_DUMP_ACCEPT_CAN_DUMP_GUARD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_ACCEPT_CAN_DUMP_GUARD
const SOURCE_BUILDING_ITEM_DUMP_HANDLE_ITEM_CALL := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_HANDLE_ITEM_CALL
const SOURCE_BUILDING_ITEM_DUMP_REMOVE_ITEM_CALL := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_REMOVE_ITEM_CALL
const SOURCE_BUILDING_ITEM_DUMP_RETURN_TRUE := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_RETURN_TRUE
const SOURCE_BUILDING_ITEM_DUMP_RETURN_FALSE := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_RETURN_FALSE

const SOURCE_DUMP_ACCUMULATE_ATTEMPT_FIELD := source_building_item_dump_source_text_state.SOURCE_DUMP_ACCUMULATE_ATTEMPT_FIELD
const SOURCE_DUMP_ACCUMULATE_ATTEMPT_ADD_DELTA := source_building_item_dump_source_text_state.SOURCE_DUMP_ACCUMULATE_ATTEMPT_ADD_DELTA
const SOURCE_DUMP_ACCUMULATE_ATTEMPT_WHILE_GATE := source_building_item_dump_source_text_state.SOURCE_DUMP_ACCUMULATE_ATTEMPT_WHILE_GATE
const SOURCE_DUMP_ACCUMULATE_ATTEMPT_DUMP_CALL := source_building_item_dump_source_text_state.SOURCE_DUMP_ACCUMULATE_ATTEMPT_DUMP_CALL
const SOURCE_DUMP_ACCUMULATE_ATTEMPT_SUBTRACT_ONE := source_building_item_dump_source_text_state.SOURCE_DUMP_ACCUMULATE_ATTEMPT_SUBTRACT_ONE
const SOURCE_BUILDING_ITEM_CAN_DUMP_METHOD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_CAN_DUMP_METHOD
const SOURCE_BUILDING_ITEM_PUT_COMMENT := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_PUT_COMMENT
const SOURCE_BUILDING_ITEM_PUT_METHOD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_PUT_METHOD
const SOURCE_BUILDING_ITEM_PUT_DUMP_ASSIGNMENT := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_PUT_DUMP_ASSIGNMENT
const SOURCE_BUILDING_ITEM_PUT_LOOP := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_PUT_LOOP
const SOURCE_BUILDING_ITEM_PUT_INCREMENT_DUMP := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_PUT_INCREMENT_DUMP
const SOURCE_BUILDING_ITEM_PUT_PROXIMITY_GET := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_PUT_PROXIMITY_GET
const SOURCE_BUILDING_ITEM_PRODUCED_METHOD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_PRODUCED_METHOD
const SOURCE_BUILDING_ITEM_PRODUCED_DELEGATE := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_PRODUCED_DELEGATE
const SOURCE_BUILDING_ITEM_PRODUCED_AMOUNT_METHOD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_PRODUCED_AMOUNT_METHOD
const SOURCE_BUILDING_ITEM_PRODUCED_AMOUNT_GUARD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_PRODUCED_AMOUNT_GUARD
const SOURCE_BUILDING_ITEM_PRODUCED_AMOUNT_HANDLE := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_PRODUCED_AMOUNT_HANDLE
const SOURCE_BUILDING_ITEM_PRODUCED_AMOUNT_UNLOCK_GUARD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_PRODUCED_AMOUNT_UNLOCK_GUARD
const SOURCE_BUILDING_ITEM_DUMP_ACCUMULATE_COMMENT := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_ACCUMULATE_COMMENT
const SOURCE_BUILDING_ITEM_DUMP_ACCUMULATE_METHOD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_ACCUMULATE_METHOD
const SOURCE_BUILDING_ITEM_DUMP_ACCUMULATE_DELEGATE := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_ACCUMULATE_DELEGATE
const SOURCE_BUILDING_ITEM_DUMP_ACCUMULATE_ITEM_METHOD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_ACCUMULATE_ITEM_METHOD
const SOURCE_BUILDING_ITEM_DUMP_COMMENT := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_COMMENT
const SOURCE_BUILDING_ITEM_DUMP_DEFAULT_METHOD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_DEFAULT_METHOD
const SOURCE_BUILDING_ITEM_DUMP_DEFAULT_DELEGATE := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_DEFAULT_DELEGATE
const SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_ALL_ITEMS := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_ALL_ITEMS
const SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_ITEM_SIZE := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_ITEM_SIZE
const SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_NULL_BRANCH := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_NULL_BRANCH
const SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_LOOP := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_LOOP
const SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_HAS_ITEM_SKIP := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_HAS_ITEM_SKIP
const SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_ITEM_CAST := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_ITEM_CAST
const SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_DUMP_ASSIGNMENT := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_DUMP_ASSIGNMENT
const SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_LOOP := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_LOOP
const SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_PROXIMITY_GET := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_PROXIMITY_GET
const SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_INCREMENT := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_INCREMENT
const SOURCE_BUILDING_ITEM_DUMP_NULL_REMOVE_SOURCE_METHOD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_NULL_REMOVE_SOURCE_METHOD
const SOURCE_BUILDING_ITEM_DUMP_NULL_SUCCESS_SOURCE_METHOD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_NULL_SUCCESS_SOURCE_METHOD
const SOURCE_BUILDING_ITEM_DUMP_SPECIFIC_SOURCE_METHOD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_SPECIFIC_SOURCE_METHOD
const SOURCE_BUILDING_ITEM_DUMP_SPECIFIC_ELSE_BRANCH := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_SPECIFIC_ELSE_BRANCH
const SOURCE_BUILDING_ITEM_DUMP_TERMINAL_SOURCE_METHOD := source_building_item_dump_source_text_state.SOURCE_BUILDING_ITEM_DUMP_TERMINAL_SOURCE_METHOD
const SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY := "increment_dump_cursor"
const SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK := "source_increment_dump_cursor"

static func runtime_method_names(game: Object) -> Dictionary:
	if game == null:
		return {}
	if game.has_method("_building_item_dump_state_method_names"):
		var names = game.call("_building_item_dump_state_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return str(method_names.get(key, fallback_name))

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	var increment_dump_cursor_method := runtime_method_name(method_names, SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK)
	return {
		SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY: Callable(game, increment_dump_cursor_method),
	}

static func increment_dump_cursor_state(current_dump: int, proximity_size: int) -> int:
	if proximity_size != 0:
		return (current_dump + 1) % proximity_size
	return current_dump

static func increment_dump_cursor_runtime_state(game: Object, proximity_size: int) -> int:
	var next_dump := increment_dump_cursor_state(game.drill_dump_cursor, proximity_size)
	game.drill_dump_cursor = next_dump
	return next_dump

static func game_put_item_state(game: Object, item: Variant, proximity_size: int, dump_cursor: int, accepts_item_by_index: Array, can_dump_by_index: Array) -> Dictionary:
	return put_item_state(
		item,
		proximity_size,
		dump_cursor,
		accepts_item_by_index,
		can_dump_by_index,
		default_callbacks_state(game).get(SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable())
	)

static func can_dump_item_default_state(to_state: Variant, item: Variant) -> Dictionary:
	return {
		"method": SOURCE_BUILDING_ITEM_CAN_DUMP_METHOD,
		"return_true": SOURCE_BUILDING_ITEM_DUMP_RETURN_TRUE,
		"to_state": to_state,
		"item": item,
		"can_dump_item": true,
	}

static func put_item_state(item: Variant, proximity_size: int, dump_cursor: int, accepts_item_by_index: Array, can_dump_by_index: Array, increment_dump_cursor: Callable) -> Dictionary:
	var next_dump := dump_cursor
	var handled_index := -1
	var put_success := false
	var checked_indices: Array = []
	for i in range(proximity_size):
		next_dump = int(increment_dump_cursor.call(next_dump, proximity_size))
		var other_index := (i + dump_cursor) % proximity_size
		checked_indices.append(other_index)
		var accepts_item := other_index >= 0 and other_index < accepts_item_by_index.size() and bool(accepts_item_by_index[other_index])
		var can_dump := other_index >= 0 and other_index < can_dump_by_index.size() and bool(can_dump_by_index[other_index])
		if accepts_item and can_dump:
			handled_index = other_index
			put_success = true
			break
	return {
		"comment": SOURCE_BUILDING_ITEM_PUT_COMMENT,
		"method": SOURCE_BUILDING_ITEM_PUT_METHOD,
		"dump_assign": SOURCE_BUILDING_ITEM_PUT_DUMP_ASSIGNMENT,
		"loop": SOURCE_BUILDING_ITEM_PUT_LOOP,
		"increment_dump": SOURCE_BUILDING_ITEM_PUT_INCREMENT_DUMP,
		"proximity_get": SOURCE_BUILDING_ITEM_PUT_PROXIMITY_GET,
		"accept_can_dump_guard": "if(other.acceptItem(self(), item) && canDump(other, item)){",
		"handle_item": "other.handleItem(self(), item);",
		"return_true": SOURCE_BUILDING_ITEM_DUMP_RETURN_TRUE,
		"return_false": SOURCE_BUILDING_ITEM_DUMP_RETURN_FALSE,
		"item": item,
		"proximity_size": proximity_size,
		"dump_cursor": dump_cursor,
		"cdump": next_dump,
		"checked_indices": checked_indices,
		"handled_index": handled_index,
		"handle_item_called": handled_index != -1,
		"put": put_success,
		"return_value": put_success,
	}

static func generated_put_item_state(item: Variant, proximity_size: int, dump_cursor: int, accepts_item_by_index: Array, can_dump_by_index: Array) -> Dictionary:
	return put_item_state(item, proximity_size, dump_cursor, accepts_item_by_index, can_dump_by_index, Callable(SourceBuildingItemDumpState, "increment_dump_cursor_state"))

static func produced_item_default_state(item: Variant) -> Dictionary:
	return {
		"method": SOURCE_BUILDING_ITEM_PRODUCED_METHOD,
		"delegate": SOURCE_BUILDING_ITEM_PRODUCED_DELEGATE,
		"item": item,
		"amount": 1,
		"delegates_to_amount_overload": true,
	}

static func produced_item_amount_state(item: Variant, amount: int, sector_present: bool, team_is_default_team: bool, net_client: bool) -> Dictionary:
	var production_recorded := sector_present and team_is_default_team
	var unlock_called := production_recorded and not net_client
	return {
		"method": SOURCE_BUILDING_ITEM_PRODUCED_AMOUNT_METHOD,
		"production_guard": SOURCE_BUILDING_ITEM_PRODUCED_AMOUNT_GUARD,
		"handle_production": SOURCE_BUILDING_ITEM_PRODUCED_AMOUNT_HANDLE,
		"unlock_guard": SOURCE_BUILDING_ITEM_PRODUCED_AMOUNT_UNLOCK_GUARD,
		"item": item,
		"amount": amount,
		"sector_present": sector_present,
		"team_is_default_team": team_is_default_team,
		"net_client": net_client,
		"production_recorded": production_recorded,
		"unlock_called": unlock_called,
	}

static func dump_accumulate_default_state() -> Dictionary:
	return {
		"comment": SOURCE_BUILDING_ITEM_DUMP_ACCUMULATE_COMMENT,
		"method": SOURCE_BUILDING_ITEM_DUMP_ACCUMULATE_METHOD,
		"delegate": SOURCE_BUILDING_ITEM_DUMP_ACCUMULATE_DELEGATE,
		"item": null,
		"delegates_to_item_overload": true,
	}

static func dump_accumulate_state(current_accum: float, source_delta: float) -> Dictionary:
	var next_accum := current_accum + source_delta
	var dump_attempts := 0
	while next_accum >= 1.0:
		dump_attempts += 1
		next_accum -= 1.0
	return {"dump_attempts": dump_attempts, "dump_accum": next_accum}

static func dump_accumulate_generated_state(current_accum: float, source_delta: float, item: Variant, dump_outcomes: Array) -> Dictionary:
	var next_accum := current_accum + source_delta
	var dump_attempts := 0
	var dumped := false
	var dump_results: Array = []
	while next_accum >= 1.0:
		var dump_result := bool(dump_outcomes[dump_attempts] if dump_attempts < dump_outcomes.size() else false)
		dump_results.append(dump_result)
		dumped = dumped or dump_result
		dump_attempts += 1
		next_accum -= 1.0
	return {
		"method": SOURCE_BUILDING_ITEM_DUMP_ACCUMULATE_ITEM_METHOD,
		"dump_accum_field": SOURCE_DUMP_ACCUMULATE_ATTEMPT_FIELD,
		"add_delta": SOURCE_DUMP_ACCUMULATE_ATTEMPT_ADD_DELTA,
		"while_gate": SOURCE_DUMP_ACCUMULATE_ATTEMPT_WHILE_GATE,
		"dump_call": SOURCE_DUMP_ACCUMULATE_ATTEMPT_DUMP_CALL,
		"subtract_one": SOURCE_DUMP_ACCUMULATE_ATTEMPT_SUBTRACT_ONE,
		"item": item,
		"current_accum": current_accum,
		"source_delta": source_delta,
		"dump_outcomes": dump_outcomes.duplicate(),
		"dump_results": dump_results,
		"dump_attempts": dump_attempts,
		"dump_accum": next_accum,
		"dumped": dumped,
		"return_value": dumped,
	}

static func dump_accumulate_runtime_state(game: Object, source_delta: float) -> Dictionary:
	var state := dump_accumulate_state(game.building_dump_accum, source_delta)
	game.building_dump_accum = float(state["dump_accum"])
	return state

static func dump_default_state() -> Dictionary:
	return {
		"comment": SOURCE_BUILDING_ITEM_DUMP_COMMENT,
		"method": SOURCE_BUILDING_ITEM_DUMP_DEFAULT_METHOD,
		"delegate": SOURCE_BUILDING_ITEM_DUMP_DEFAULT_DELEGATE,
		"todump": null,
		"delegates_to_item_overload": true,
	}

static func dump_null_item_scan_state(item_ids: Array, item_present_by_index: Array) -> Dictionary:
	var present_item_indices := []
	var present_items := []
	for ii in range(item_ids.size()):
		if not bool(item_present_by_index[ii]):
			continue
		present_item_indices.append(ii)
		present_items.append(item_ids[ii])
	return {
		"method": SOURCE_BUILDING_ITEM_DUMP_METHOD,
		"all_items": SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_ALL_ITEMS,
		"item_size_source": SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_ITEM_SIZE,
		"item_array": SOURCE_BUILDING_ITEM_DUMP_ITEM_ARRAY,
		"null_branch": SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_NULL_BRANCH,
		"item_loop": SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_LOOP,
		"has_item_skip": SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_HAS_ITEM_SKIP,
		"item_cast": SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_ITEM_CAST,
		"item_ids": item_ids,
		"item_present_by_index": item_present_by_index,
		"item_size": item_ids.size(),
		"present_item_indices": present_item_indices,
		"present_items": present_items,
	}

static func dump_null_proximity_scan_state(proximity_size: int, dump_cursor: int, increment_dump_cursor: Callable) -> Dictionary:
	var checked_indices := []
	var next_dump := dump_cursor
	for i in range(proximity_size):
		checked_indices.append((i + dump_cursor) % proximity_size)
		next_dump = int(increment_dump_cursor.call(next_dump, proximity_size))
	return {
		"method": SOURCE_BUILDING_ITEM_DUMP_METHOD,
		"dump_assign": SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_DUMP_ASSIGNMENT,
		"null_branch": SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_NULL_BRANCH,
		"proximity_loop": SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_LOOP,
		"proximity_get": SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_PROXIMITY_GET,
		"increment_dump_call": SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_INCREMENT,
		"proximity_size": proximity_size,
		"dump_cursor": dump_cursor,
		"checked_indices": checked_indices,
		"cdump": next_dump,
	}

static func game_dump_null_proximity_scan_state(game: Object, proximity_size: int, dump_cursor: int) -> Dictionary:
	return dump_null_proximity_scan_state(
		proximity_size,
		dump_cursor,
		default_callbacks_state(game).get(SOURCE_BUILDING_ITEM_DUMP_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable())
	)

static func dump_null_remove_item_state(item: Variant, item_amount_before: int) -> Dictionary:
	return {
		"source_method": SOURCE_BUILDING_ITEM_DUMP_NULL_REMOVE_SOURCE_METHOD,
		"null_branch": SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_NULL_BRANCH,
		"accept_can_dump_guard": SOURCE_BUILDING_ITEM_DUMP_ACCEPT_CAN_DUMP_GUARD,
		"remove_item_call": SOURCE_BUILDING_ITEM_DUMP_REMOVE_ITEM_CALL,
		"item": item,
		"item_amount_before": item_amount_before,
		"remove_amount": 1,
		"item_amount_after": item_amount_before - 1,
	}

static func dump_null_success_handoff_state(item: Variant, accepts_item: bool, can_dump: bool) -> Dictionary:
	return {
		"source_method": SOURCE_BUILDING_ITEM_DUMP_NULL_SUCCESS_SOURCE_METHOD,
		"null_branch": SOURCE_BUILDING_ITEM_DUMP_NULL_ITEM_SCAN_NULL_BRANCH,
		"accept_can_dump_guard": SOURCE_BUILDING_ITEM_DUMP_ACCEPT_CAN_DUMP_GUARD,
		"handle_item_call": SOURCE_BUILDING_ITEM_DUMP_HANDLE_ITEM_CALL,
		"return_true": SOURCE_BUILDING_ITEM_DUMP_RETURN_TRUE,
		"item": item,
		"accepts_item": accepts_item,
		"can_dump": can_dump,
		"handle_item_called": accepts_item and can_dump,
		"dumped": accepts_item and can_dump,
		"return_value": accepts_item and can_dump,
	}

static func dump_specific_proximity_scan_state(todump: Variant, proximity_size: int, dump_cursor: int) -> Dictionary:
	var checked_indices := []
	for i in range(proximity_size):
		checked_indices.append((i + dump_cursor) % proximity_size)
	return {
		"source_method": SOURCE_BUILDING_ITEM_DUMP_SPECIFIC_SOURCE_METHOD,
		"else_branch": SOURCE_BUILDING_ITEM_DUMP_SPECIFIC_ELSE_BRANCH,
		"proximity_loop": SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_LOOP,
		"proximity_get": SOURCE_BUILDING_ITEM_DUMP_NULL_PROXIMITY_SCAN_PROXIMITY_GET,
		"todump": todump,
		"proximity_size": proximity_size,
		"dump_cursor": dump_cursor,
		"checked_indices": checked_indices,
	}

static func dump_terminal_failure_state() -> Dictionary:
	return {
		"source_method": SOURCE_BUILDING_ITEM_DUMP_TERMINAL_SOURCE_METHOD,
		"terminal_return": SOURCE_BUILDING_ITEM_DUMP_RETURN_FALSE,
		"dumped": false,
		"return_value": false,
	}

static func dump_item_state(
	block_has_items: bool,
	item_total: int,
	proximity_size: int,
	todump: Variant,
	todump_present: bool,
	item_ids: Array,
	item_amounts_by_index: Array,
	accepts_item_by_index: Array,
	can_dump_by_index: Array,
	dump_cursor: int
) -> Dictionary:
	var guard_failed := not block_has_items or item_total == 0 or proximity_size == 0 or (todump != null and not todump_present)
	var next_cursor := dump_cursor
	var checked_indices: Array = []
	var handled_index := -1
	var handled_item: Variant = null
	var removed_item: Variant = null
	var next_item_amounts := item_amounts_by_index.duplicate()
	if guard_failed:
		return {
			"source_method": SOURCE_BUILDING_ITEM_DUMP_METHOD,
			"initial_guard": SOURCE_BUILDING_ITEM_DUMP_INITIAL_GUARD,
			"block_has_items": block_has_items,
			"item_total": item_total,
			"proximity_size": proximity_size,
			"todump": todump,
			"todump_present": todump_present,
			"dump_cursor": dump_cursor,
			"cdump": next_cursor,
			"checked_indices": checked_indices,
			"handled_index": handled_index,
			"handled_item": handled_item,
			"removed_item": removed_item,
			"item_amounts_by_index": next_item_amounts,
			"handle_item_called": false,
			"remove_item_called": false,
			"dumped": false,
			"return_value": false,
		}

	for i in range(proximity_size):
		var other_index := (i + dump_cursor) % proximity_size
		checked_indices.append(other_index)
		if todump == null:
			for item_index in range(item_ids.size()):
				if item_index >= item_amounts_by_index.size() or int(item_amounts_by_index[item_index]) <= 0:
					continue
				var accepts_item := other_index >= 0 and other_index < accepts_item_by_index.size() and bool(accepts_item_by_index[other_index])
				var can_dump := other_index >= 0 and other_index < can_dump_by_index.size() and bool(can_dump_by_index[other_index])
				if accepts_item and can_dump:
					handled_index = other_index
					handled_item = item_ids[item_index]
					removed_item = handled_item
					if item_index < next_item_amounts.size():
						next_item_amounts[item_index] = max(0, int(next_item_amounts[item_index]) - 1)
					next_cursor = increment_dump_cursor_state(next_cursor, proximity_size)
					return {
						"source_method": SOURCE_BUILDING_ITEM_DUMP_METHOD,
						"initial_guard": SOURCE_BUILDING_ITEM_DUMP_INITIAL_GUARD,
						"dump_cursor": dump_cursor,
						"cdump": next_cursor,
						"checked_indices": checked_indices,
						"handled_index": handled_index,
						"handled_item": handled_item,
						"removed_item": removed_item,
						"item_amounts_by_index": next_item_amounts,
						"handle_item_called": true,
						"remove_item_called": true,
						"dumped": true,
						"return_value": true,
					}
		else:
			var accepts_item := other_index >= 0 and other_index < accepts_item_by_index.size() and bool(accepts_item_by_index[other_index])
			var can_dump := other_index >= 0 and other_index < can_dump_by_index.size() and bool(can_dump_by_index[other_index])
			if accepts_item and can_dump:
				handled_index = other_index
				handled_item = todump
				removed_item = todump
				var todump_index := item_ids.find(todump)
				if todump_index >= 0 and todump_index < next_item_amounts.size():
					next_item_amounts[todump_index] = max(0, int(next_item_amounts[todump_index]) - 1)
				next_cursor = increment_dump_cursor_state(next_cursor, proximity_size)
				return {
					"source_method": SOURCE_BUILDING_ITEM_DUMP_METHOD,
					"initial_guard": SOURCE_BUILDING_ITEM_DUMP_INITIAL_GUARD,
					"dump_cursor": dump_cursor,
					"cdump": next_cursor,
					"checked_indices": checked_indices,
					"handled_index": handled_index,
					"handled_item": handled_item,
					"removed_item": removed_item,
					"item_amounts_by_index": next_item_amounts,
					"handle_item_called": true,
					"remove_item_called": true,
					"dumped": true,
					"return_value": true,
				}
		next_cursor = increment_dump_cursor_state(next_cursor, proximity_size)
	return {
		"source_method": SOURCE_BUILDING_ITEM_DUMP_METHOD,
		"initial_guard": SOURCE_BUILDING_ITEM_DUMP_INITIAL_GUARD,
		"dump_cursor": dump_cursor,
		"cdump": next_cursor,
		"checked_indices": checked_indices,
		"handled_index": handled_index,
		"handled_item": handled_item,
		"removed_item": removed_item,
		"item_amounts_by_index": next_item_amounts,
		"handle_item_called": false,
		"remove_item_called": false,
		"dumped": false,
		"return_value": false,
	}
