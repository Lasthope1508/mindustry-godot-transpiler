extends RefCounted
class_name SourceBuildingPayloadState

const source_building_payload_source_text_state := preload("res://src/game/SourceBuildingPayloadSourceTextState.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")

const SOURCE_PAYLOAD_FORWARD_OFFSET_METHOD := source_building_payload_source_text_state.SOURCE_PAYLOAD_FORWARD_OFFSET_METHOD
const SOURCE_PAYLOAD_FORWARD_OFFSET_TRNS := source_building_payload_source_text_state.SOURCE_PAYLOAD_FORWARD_OFFSET_TRNS
const SOURCE_PAYLOAD_FORWARD_OFFSET_NEXT_TILE := source_building_payload_source_text_state.SOURCE_PAYLOAD_FORWARD_OFFSET_NEXT_TILE
const SOURCE_MOVE_PAYLOAD_STATE_METHOD := source_building_payload_source_text_state.SOURCE_MOVE_PAYLOAD_STATE_METHOD
const SOURCE_MOVE_PAYLOAD_STATE_TRNS := source_building_payload_source_text_state.SOURCE_MOVE_PAYLOAD_STATE_TRNS
const SOURCE_MOVE_PAYLOAD_STATE_NEXT := source_building_payload_source_text_state.SOURCE_MOVE_PAYLOAD_STATE_NEXT
const SOURCE_MOVE_PAYLOAD_STATE_GATE := source_building_payload_source_text_state.SOURCE_MOVE_PAYLOAD_STATE_GATE
const SOURCE_MOVE_PAYLOAD_STATE_HANDLE_DEFERRED := source_building_payload_source_text_state.SOURCE_MOVE_PAYLOAD_STATE_HANDLE_DEFERRED
const SOURCE_MOVE_PAYLOAD_STATE_RETURN_TRUE := source_building_payload_source_text_state.SOURCE_MOVE_PAYLOAD_STATE_RETURN_TRUE
const SOURCE_MOVE_PAYLOAD_STATE_RETURN_FALSE := source_building_payload_source_text_state.SOURCE_MOVE_PAYLOAD_STATE_RETURN_FALSE
const SOURCE_DUMP_PAYLOAD_INDEX_DUMP_FIELD := source_building_payload_source_text_state.SOURCE_DUMP_PAYLOAD_INDEX_DUMP_FIELD
const SOURCE_DUMP_PAYLOAD_INDEX_PROXIMITY_GET := source_building_payload_source_text_state.SOURCE_DUMP_PAYLOAD_INDEX_PROXIMITY_GET
const SOURCE_DUMP_PAYLOAD_INDEX_EXPR := source_building_payload_source_text_state.SOURCE_DUMP_PAYLOAD_INDEX_EXPR
const SOURCE_DUMP_PAYLOAD_STATE_METHOD := source_building_payload_source_text_state.SOURCE_DUMP_PAYLOAD_STATE_METHOD
const SOURCE_DUMP_PAYLOAD_STATE_EMPTY_PROXIMITY_GUARD := source_building_payload_source_text_state.SOURCE_DUMP_PAYLOAD_STATE_EMPTY_PROXIMITY_GUARD
const SOURCE_DUMP_PAYLOAD_STATE_ACCEPT_PAYLOAD := source_building_payload_source_text_state.SOURCE_DUMP_PAYLOAD_STATE_ACCEPT_PAYLOAD
const SOURCE_DUMP_PAYLOAD_STATE_HANDLE_PAYLOAD := source_building_payload_source_text_state.SOURCE_DUMP_PAYLOAD_STATE_HANDLE_PAYLOAD
const SOURCE_DUMP_PAYLOAD_STATE_INCREMENT_DUMP := source_building_payload_source_text_state.SOURCE_DUMP_PAYLOAD_STATE_INCREMENT_DUMP
const SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY := source_building_payload_source_text_state.SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY
const SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK := source_building_payload_source_text_state.SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK
const SOURCE_GET_PAYLOAD_DEFAULT_METHOD := source_building_payload_source_text_state.SOURCE_GET_PAYLOAD_DEFAULT_METHOD
const SOURCE_PAYLOAD_NULLABLE := source_building_payload_source_text_state.SOURCE_PAYLOAD_NULLABLE
const SOURCE_PAYLOAD_RETURN_NULL := source_building_payload_source_text_state.SOURCE_PAYLOAD_RETURN_NULL
const SOURCE_TAKE_PAYLOAD_DEFAULT_COMMENT := source_building_payload_source_text_state.SOURCE_TAKE_PAYLOAD_DEFAULT_COMMENT
const SOURCE_TAKE_PAYLOAD_DEFAULT_METHOD := source_building_payload_source_text_state.SOURCE_TAKE_PAYLOAD_DEFAULT_METHOD
const SOURCE_GET_PAYLOADS_DEFAULT_METHOD := source_building_payload_source_text_state.SOURCE_GET_PAYLOADS_DEFAULT_METHOD
const SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_METHOD := source_building_payload_source_text_state.SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_METHOD
const SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SPAWN_EXPR := source_building_payload_source_text_state.SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SPAWN_EXPR
const SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_PLAYER_GUARD_EXPR := source_building_payload_source_text_state.SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_PLAYER_GUARD_EXPR
const SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLEAR_UNIT_EXPR := source_building_payload_source_text_state.SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLEAR_UNIT_EXPR
const SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_REMOVE_EXPR := source_building_payload_source_text_state.SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_REMOVE_EXPR
const SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLIENT_GUARD_EXPR := source_building_payload_source_text_state.SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLIENT_GUARD_EXPR
const SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLIENT_ID_EXPR := source_building_payload_source_text_state.SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLIENT_ID_EXPR
const SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SERVER_ID_EXPR := source_building_payload_source_text_state.SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SERVER_ID_EXPR
const SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_GRABBER_EXPR := source_building_payload_source_text_state.SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_GRABBER_EXPR
const SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_UNIT_DROP_EXPR := source_building_payload_source_text_state.SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_UNIT_DROP_EXPR
const SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_JAVA_METHOD := source_building_payload_source_text_state.SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_JAVA_METHOD
const SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_GENERATED_OWNER := source_building_payload_source_text_state.SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_GENERATED_OWNER
const SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CALL_ORDER := [
	SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SPAWN_EXPR,
	SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_PLAYER_GUARD_EXPR,
	SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLEAR_UNIT_EXPR,
	SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_REMOVE_EXPR,
	SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLIENT_GUARD_EXPR,
	SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLIENT_ID_EXPR,
	SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SERVER_ID_EXPR,
	SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_GRABBER_EXPR,
	SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_UNIT_DROP_EXPR,
]

const source_unit_payload_basic_state := preload("res://src/game/SourceUnitPayloadBasicState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS

static func runtime_method_names(game: Object) -> Dictionary:
	if game == null:
		return {}
	if game.has_method("_building_payload_state_method_names"):
		var names = game.call("_building_payload_state_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	return str(method_names.get(key, fallback_name))

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	var increment_dump_cursor_method := runtime_method_name(method_names, SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY, SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_FALLBACK)
	return {
		SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY: Callable(game, increment_dump_cursor_method),
	}

static func game_dump_payload_state(game: Object, proximity_size: int, dump_cursor: int, accepts_payload_by_index: Array) -> Dictionary:
	return dump_payload_state(
		proximity_size,
		dump_cursor,
		accepts_payload_by_index,
		default_callbacks_state(game).get(SOURCE_BUILDING_PAYLOAD_INCREMENT_DUMP_CURSOR_METHOD_KEY, Callable())
	)

static func accept_payload_state() -> bool:
	return false

static func handle_payload_state(payload_state: Variant) -> Variant:
	return payload_state

static func _require_callable(dependencies: Dictionary, key: String, missing_dependencies: Array) -> Callable:
	var callback: Variant = dependencies.get(key, Callable())
	if callback is Callable and callback.is_valid():
		return callback
	missing_dependencies.append(key)
	return Callable()

static func handle_unit_payload_state(unit: Variant, grabber: Variant, dependencies: Dictionary = {}) -> Dictionary:
	var missing_dependencies: Array = []
	var spawn_effect := _require_callable(dependencies, "spawn_effect", missing_dependencies)
	var clear_unit := _require_callable(dependencies, "clear_unit", missing_dependencies)
	var remove_unit := _require_callable(dependencies, "remove_unit", missing_dependencies)
	var next_id := _require_callable(dependencies, "next_id", missing_dependencies)
	var assign_unit_id := _require_callable(dependencies, "assign_unit_id", missing_dependencies)
	var post_deferred := _require_callable(dependencies, "post_deferred", missing_dependencies)
	var unit_drop_effect := _require_callable(dependencies, "unit_drop_effect", missing_dependencies)
	var grabber_get: Callable = grabber if grabber is Callable and grabber.is_valid() else Callable()
	if not grabber_get.is_valid():
		missing_dependencies.append("grabber")
	var unit_is_player: bool = bool(dependencies.get("unit_is_player", false))
	var net_client: bool = bool(dependencies.get("net_client", false))
	var call_order: Array = [SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SPAWN_EXPR]
	if spawn_effect.is_valid():
		spawn_effect.call(unit)
	if unit_is_player:
		call_order.append(SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_PLAYER_GUARD_EXPR)
		call_order.append(SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLEAR_UNIT_EXPR)
		if clear_unit.is_valid():
			clear_unit.call(unit)
	call_order.append(SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_REMOVE_EXPR)
	if remove_unit.is_valid():
		remove_unit.call(unit)
	var deferred_id_assignment := Callable(func() -> void:
		if next_id.is_valid() and assign_unit_id.is_valid():
			assign_unit_id.call(unit, next_id.call())
	)
	var unit_id_assigned_immediately := false
	var unit_id_assignment_deferred := false
	if net_client:
		call_order.append(SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLIENT_GUARD_EXPR)
		call_order.append(SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLIENT_ID_EXPR)
		deferred_id_assignment.call()
		unit_id_assigned_immediately = next_id.is_valid() and assign_unit_id.is_valid()
	else:
		call_order.append(SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SERVER_ID_EXPR)
		if post_deferred.is_valid():
			post_deferred.call(deferred_id_assignment)
			unit_id_assignment_deferred = true
	var payload := source_unit_payload_basic_state.constructor_state(unit)
	call_order.append(SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_GRABBER_EXPR)
	if grabber_get.is_valid():
		grabber_get.call(payload)
	call_order.append(SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_UNIT_DROP_EXPR)
	if unit_drop_effect.is_valid():
		unit_drop_effect.call(unit)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_STATE,
		"source": source_building_payload_source_text_state.SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SOURCE,
		"method": SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_METHOD,
		"unit": unit,
		"unit_is_player": unit_is_player,
		"net_client": net_client,
		"payload": payload,
		"call_order": call_order,
		"spawn_called": spawn_effect.is_valid(),
		"clear_unit_called": unit_is_player and clear_unit.is_valid(),
		"remove_called": remove_unit.is_valid(),
		"unit_id_assigned_immediately": unit_id_assigned_immediately,
		"unit_id_assignment_deferred": unit_id_assignment_deferred,
		"grabber_called": grabber_get.is_valid(),
		"unit_drop_called": unit_drop_effect.is_valid(),
		"missing_dependencies": missing_dependencies,
	}

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func generated_handle_unit_payload_bridge_state(unit: Variant, grabber: Variant, dependencies: Dictionary = {}) -> Dictionary:
	var generated_result: Variant = _building_comp_call(SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_JAVA_METHOD, [unit, grabber, dependencies])
	var result: Dictionary = generated_result if generated_result is Dictionary else {}
	var call_order: Array = result.get("call_order", [])
	var expected_order: Array = [
		SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SPAWN_EXPR,
		SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_REMOVE_EXPR,
		SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_GRABBER_EXPR,
		SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_UNIT_DROP_EXPR,
	]
	if bool(result.get("unit_is_player", false)):
		expected_order.insert(1, SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_PLAYER_GUARD_EXPR)
		expected_order.insert(2, SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLEAR_UNIT_EXPR)
	var expected_network_expr: String = SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLIENT_ID_EXPR if bool(result.get("net_client", false)) else SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SERVER_ID_EXPR
	var network_insert_index: int = expected_order.find(SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_GRABBER_EXPR)
	if bool(result.get("net_client", false)):
		expected_order.insert(network_insert_index, SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLIENT_GUARD_EXPR)
		expected_order.insert(network_insert_index + 1, SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_CLIENT_ID_EXPR)
	else:
		expected_order.insert(network_insert_index, SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_SERVER_ID_EXPR)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_STATE,
		"generated_owner": SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_GENERATED_OWNER,
		"result": result.duplicate(true),
		"expected_network_expr": expected_network_expr,
		"matches": result.get("source_owner", "") == source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HANDLE_UNIT_PAYLOAD_STATE and call_order == expected_order and result.get("payload", {}).get("source_owner", "") == source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_CONSTRUCTOR_STATE,
	}

static func get_payload_default_state() -> Dictionary:
	return {
		"method": SOURCE_GET_PAYLOAD_DEFAULT_METHOD,
		"nullable": SOURCE_PAYLOAD_NULLABLE,
		"return_null": SOURCE_PAYLOAD_RETURN_NULL,
		"payload": null,
		"has_payload": false,
	}

static func take_payload_default_state() -> Dictionary:
	return {
		"comment": SOURCE_TAKE_PAYLOAD_DEFAULT_COMMENT,
		"method": SOURCE_TAKE_PAYLOAD_DEFAULT_METHOD,
		"nullable": SOURCE_PAYLOAD_NULLABLE,
		"return_null": SOURCE_PAYLOAD_RETURN_NULL,
		"payload": null,
		"has_payload": false,
		"payload_taken": false,
	}

static func get_payloads_default_state() -> Dictionary:
	return {
		"method": SOURCE_GET_PAYLOADS_DEFAULT_METHOD,
		"nullable": SOURCE_PAYLOAD_NULLABLE,
		"return_null": SOURCE_PAYLOAD_RETURN_NULL,
		"payloads": null,
		"has_payloads": false,
	}

static func payload_forward_offset(payload_block_size: int) -> int:
	return floori(float(payload_block_size) / 2.0) + 1

static func move_payload_state(has_next_tile: bool, has_next_build: bool, same_team: bool, accepts_payload: bool) -> bool:
	return has_next_tile and has_next_build and same_team and accepts_payload

static func dump_payload_index(loop_index: int, dump_cursor: int, proximity_size: int) -> int:
	return (loop_index + dump_cursor) % proximity_size

static func dump_payload_state(proximity_size: int, dump_cursor: int, accepts_payload_by_index: Array, increment_dump_cursor: Callable) -> Dictionary:
	if proximity_size == 0:
		return {"moved": false, "cdump": dump_cursor, "handled_index": -1}
	var dump := dump_cursor
	var next_dump := dump_cursor
	for i in range(proximity_size):
		var other_index := dump_payload_index(i, dump, proximity_size)
		next_dump = int(increment_dump_cursor.call(next_dump, proximity_size))
		if other_index < accepts_payload_by_index.size() and bool(accepts_payload_by_index[other_index]):
			return {"moved": true, "cdump": next_dump, "handled_index": other_index}
	return {"moved": false, "cdump": next_dump, "handled_index": -1}
