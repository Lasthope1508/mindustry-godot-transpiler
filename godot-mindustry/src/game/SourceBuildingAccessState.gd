extends RefCounted
class_name SourceBuildingAccessState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_TILE_X_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_TILE_X_JAVA_METHOD
const SOURCE_BUILDING_TILE_Y_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_TILE_Y_JAVA_METHOD
const SOURCE_BUILDING_POS_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_POS_JAVA_METHOD
const SOURCE_BUILDING_FLOOR_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_FLOOR_JAVA_METHOD
const SOURCE_BUILDING_INTERACTABLE_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_INTERACTABLE_JAVA_METHOD
const SOURCE_BUILDING_TILE_X_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_TILE_X_GENERATED_OWNER
const SOURCE_BUILDING_TILE_Y_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_TILE_Y_GENERATED_OWNER
const SOURCE_BUILDING_POS_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_POS_GENERATED_OWNER
const SOURCE_BUILDING_FLOOR_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_FLOOR_GENERATED_OWNER
const SOURCE_BUILDING_INTERACTABLE_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_INTERACTABLE_GENERATED_OWNER
const SOURCE_BUILDING_ALLOW_UPDATE_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_ALLOW_UPDATE_JAVA_METHOD
const SOURCE_BUILDING_IN_MAP_AREA_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_IN_MAP_AREA_JAVA_METHOD
const SOURCE_BUILDING_ALLOW_UPDATE_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_ALLOW_UPDATE_GENERATED_OWNER
const SOURCE_BUILDING_IN_MAP_AREA_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_IN_MAP_AREA_GENERATED_OWNER
const SOURCE_BUILDING_STATUS_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_STATUS_JAVA_METHOD
const SOURCE_BUILDING_STATUS_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_STATUS_GENERATED_OWNER
const SOURCE_BUILDING_STATUS_LOGIC_DISABLE := "logicDisable"
const SOURCE_BUILDING_STATUS_NO_OUTPUT := "noOutput"
const SOURCE_BUILDING_STATUS_NO_INPUT := "noInput"
const SOURCE_BUILDING_STATUS_ACTIVE := "active"
const SOURCE_BUILDING_STATUS_TICK_DIVISOR := source_building_source_text_state.SOURCE_BUILDING_STATUS_TICK_DIVISOR
const SOURCE_BUILDING_SLEEP_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_SLEEP_JAVA_METHOD
const SOURCE_BUILDING_SLEEP_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_SLEEP_GENERATED_OWNER
const SOURCE_BUILDING_NOSLEEP_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_NOSLEEP_JAVA_METHOD
const SOURCE_BUILDING_NOSLEEP_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_NOSLEEP_GENERATED_OWNER
const SOURCE_BUILDING_CAN_WITHDRAW_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CAN_WITHDRAW_JAVA_METHOD
const SOURCE_BUILDING_CAN_WITHDRAW_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CAN_WITHDRAW_GENERATED_OWNER
const SOURCE_BUILDING_CAN_UNLOAD_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CAN_UNLOAD_JAVA_METHOD
const SOURCE_BUILDING_CAN_UNLOAD_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CAN_UNLOAD_GENERATED_OWNER
const SOURCE_BUILDING_CAN_RESUPPLY_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CAN_RESUPPLY_JAVA_METHOD
const SOURCE_BUILDING_CAN_RESUPPLY_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CAN_RESUPPLY_GENERATED_OWNER
const SOURCE_BUILDING_PAYLOAD_CHECK_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_PAYLOAD_CHECK_JAVA_METHOD
const SOURCE_BUILDING_PAYLOAD_CHECK_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_PAYLOAD_CHECK_GENERATED_OWNER
const SOURCE_BUILDING_ALLOW_DEPOSIT_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_ALLOW_DEPOSIT_JAVA_METHOD
const SOURCE_BUILDING_ALLOW_DEPOSIT_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_ALLOW_DEPOSIT_GENERATED_OWNER
const SOURCE_BUILDING_SHOULD_CONSUME_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_SHOULD_CONSUME_JAVA_METHOD
const SOURCE_BUILDING_SHOULD_CONSUME_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_SHOULD_CONSUME_GENERATED_OWNER
const SOURCE_BUILDING_PRODUCTION_VALID_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_PRODUCTION_VALID_JAVA_METHOD
const SOURCE_BUILDING_PRODUCTION_VALID_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_PRODUCTION_VALID_GENERATED_OWNER
const SOURCE_BUILDING_CONSUME_TRIGGER_VALID_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CONSUME_TRIGGER_VALID_JAVA_METHOD
const SOURCE_BUILDING_CONSUME_TRIGGER_VALID_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CONSUME_TRIGGER_VALID_GENERATED_OWNER
const SOURCE_BUILDING_SLEEP_TIME_TO_SLEEP := source_time_defaults.TICK_RATE

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func tile_x_state(tile_x: int) -> int:
	return tile_x

static func tile_y_state(tile_y: int) -> int:
	return tile_y

static func pos_state(tile_pos: int) -> int:
	return tile_pos

static func floor_state(floor_value: Variant) -> Variant:
	return source_block_geometry.tile_reference_state(floor_value)

static func interactable_state(can_interact: bool) -> bool:
	return source_block_geometry.tile_interactable_state(can_interact)

static func allow_update_state(team_is_derelict: bool, block_supports_env: bool, editor_tile: bool, block_privileged: bool, limit_map_area: bool, disable_outside_area: bool, tile_x: int, tile_y: int, limit_x: int, limit_y: int, limit_width: int, limit_height: int) -> bool:
	var inside_limit := source_block_geometry.tile_in_map_area_state(tile_x, tile_y, limit_map_area, limit_x, limit_y, limit_width, limit_height)
	return not team_is_derelict and block_supports_env and (editor_tile or block_privileged or not limit_map_area or not disable_outside_area or inside_limit)

static func in_map_area_state(limit_map_area: bool, limit_x: float, limit_y: float, limit_width: float, limit_height: float, source_x: float, source_y: float, tile_size: float) -> bool:
	if not limit_map_area:
		return true
	return limit_x * tile_size <= source_x and limit_x * tile_size + limit_width * tile_size >= source_x and limit_y * tile_size <= source_y and limit_y * tile_size + limit_height * tile_size >= source_y

static func status_state(enabled: bool, should_consume: bool, efficiency: float, production_valid: bool, state_tick: float) -> String:
	if not enabled:
		return SOURCE_BUILDING_STATUS_LOGIC_DISABLE
	if not should_consume:
		return SOURCE_BUILDING_STATUS_NO_OUTPUT
	if efficiency <= 0.0 or not production_valid:
		return SOURCE_BUILDING_STATUS_NO_INPUT
	return SOURCE_BUILDING_STATUS_ACTIVE if fmod(state_tick / SOURCE_BUILDING_STATUS_TICK_DIVISOR, 1.0) < efficiency else SOURCE_BUILDING_STATUS_NO_INPUT

static func sleep_state(sleep_time: float, time_delta: float, sleeping: bool, sleeping_entities: int, time_to_sleep: float = SOURCE_BUILDING_SLEEP_TIME_TO_SLEEP) -> Dictionary:
	var next_sleep_time := sleep_time + time_delta
	var should_sleep := not sleeping and next_sleep_time >= time_to_sleep
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SLEEP_STATE,
		"method": source_building_source_text_state.SOURCE_BUILDING_SLEEP_METHOD,
		"sleep_time_before": sleep_time,
		"sleep_time_after": next_sleep_time,
		"sleeping_before": sleeping,
		"sleeping_after": true if should_sleep else sleeping,
		"sleeping_entities_before": sleeping_entities,
		"sleeping_entities_after": sleeping_entities + 1 if should_sleep else sleeping_entities,
		"remove_called": should_sleep,
		"remove_call": source_building_source_text_state.SOURCE_BUILDING_SLEEP_REMOVE_CALL if should_sleep else "",
		"sleeping": should_sleep,
	}

static func no_sleep_state(sleeping: bool, sleeping_entities: int) -> Dictionary:
	var should_wake := sleeping
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_NOSLEEP_STATE,
		"method": source_building_source_text_state.SOURCE_BUILDING_NOSLEEP_METHOD,
		"sleep_time": 0.0,
		"sleeping_before": sleeping,
		"sleeping_after": false,
		"sleeping_entities_before": sleeping_entities,
		"sleeping_entities_after": sleeping_entities - 1 if should_wake else sleeping_entities,
		"add_called": should_wake,
		"add_call": source_building_source_text_state.SOURCE_BUILDING_NOSLEEP_ADD_CALL if should_wake else "",
		"sleeping": false,
	}


# Building.onProximityUpdate: the whole method is noSleep(). This is the
# superclass wake, distinct from the power-domain onProximityUpdate state
# (N968), which covers the power graph side of the same call.
static func source_on_proximity_update_wake_state(sleep_time: float, sleeping: bool, sleeping_entities: int) -> Dictionary:
	var wake: Dictionary = no_sleep_state(sleeping, sleeping_entities)
	return {
		"sleep_time_before": sleep_time,
		"sleep_time_after": wake.get("sleep_time", 0.0),
		"sleeping_before": sleeping,
		"sleeping_after": wake.get("sleeping_after", false),
		"sleeping_entities_before": sleeping_entities,
		"sleeping_entities_after": wake.get("sleeping_entities_after", sleeping_entities),
		"woke": sleeping,
		"add_called": wake.get("add_called", false),
	}

static func can_withdraw_state() -> bool:
	return true

static func can_unload_state(block_unloadable: bool) -> bool:
	return block_unloadable

static func can_resupply_state(block_allow_resupply: bool) -> bool:
	return block_allow_resupply

static func payload_check_state(block_rotate: bool, rotation: int, conveyor_rotation: int) -> bool:
	return block_rotate and posmod(rotation + 2, 4) == conveyor_rotation

static func allow_deposit_state(block_always_allow_deposit: bool, only_deposit_core: bool) -> bool:
	return block_always_allow_deposit or not only_deposit_core

static func should_consume_state(enabled: bool) -> bool:
	return enabled

static func production_valid_state() -> bool:
	return true

static func consume_trigger_valid_state() -> bool:
	return false

static func generated_tile_x_bridge_state(tile_x: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TILE_X_JAVA_METHOD, [tile_x])
	var canonical := tile_x_state(tile_x)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_TILE_X_STATE,
		"generated_owner": SOURCE_BUILDING_TILE_X_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result == canonical,
	}

static func generated_tile_y_bridge_state(tile_y: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_TILE_Y_JAVA_METHOD, [tile_y])
	var canonical := tile_y_state(tile_y)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_TILE_Y_STATE,
		"generated_owner": SOURCE_BUILDING_TILE_Y_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result == canonical,
	}

static func generated_pos_bridge_state(tile_pos: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_POS_JAVA_METHOD, [tile_pos])
	var canonical := pos_state(tile_pos)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_POS_STATE,
		"generated_owner": SOURCE_BUILDING_POS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result == canonical,
	}

static func generated_floor_bridge_state(floor_value: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_FLOOR_JAVA_METHOD, [floor_value])
	var canonical: Variant = floor_state(floor_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_FLOOR_STATE,
		"generated_owner": SOURCE_BUILDING_FLOOR_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result == canonical,
	}

static func generated_interactable_bridge_state(can_interact: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_INTERACTABLE_JAVA_METHOD, [can_interact])
	var canonical := interactable_state(can_interact)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_INTERACTABLE_STATE,
		"generated_owner": SOURCE_BUILDING_INTERACTABLE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result == canonical,
	}

static func generated_allow_update_bridge_state(team_is_derelict: bool, block_supports_env: bool, editor_tile: bool, block_privileged: bool, limit_map_area: bool, disable_outside_area: bool, tile_x: int, tile_y: int, limit_x: int, limit_y: int, limit_width: int, limit_height: int) -> Dictionary:
	var args := [team_is_derelict, block_supports_env, editor_tile, block_privileged, limit_map_area, disable_outside_area, tile_x, tile_y, limit_x, limit_y, limit_width, limit_height]
	var result = _building_comp_call(SOURCE_BUILDING_ALLOW_UPDATE_JAVA_METHOD, args)
	var canonical := allow_update_state(team_is_derelict, block_supports_env, editor_tile, block_privileged, limit_map_area, disable_outside_area, tile_x, tile_y, limit_x, limit_y, limit_width, limit_height)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ALLOW_UPDATE_STATE, "generated_owner": SOURCE_BUILDING_ALLOW_UPDATE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_in_map_area_bridge_state(limit_map_area: bool, limit_x: float, limit_y: float, limit_width: float, limit_height: float, source_x: float, source_y: float, tile_size: float) -> Dictionary:
	var args := [limit_map_area, limit_x, limit_y, limit_width, limit_height, source_x, source_y, tile_size]
	var result = _building_comp_call(SOURCE_BUILDING_IN_MAP_AREA_JAVA_METHOD, args)
	var canonical := in_map_area_state(limit_map_area, limit_x, limit_y, limit_width, limit_height, source_x, source_y, tile_size)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IN_MAP_AREA_STATE, "generated_owner": SOURCE_BUILDING_IN_MAP_AREA_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_status_bridge_state(enabled: bool, should_consume: bool, efficiency: float, production_valid: bool, state_tick: float) -> Dictionary:
	var args := [enabled, should_consume, efficiency, production_valid, state_tick]
	var result = _building_comp_call(SOURCE_BUILDING_STATUS_JAVA_METHOD, args)
	var canonical := status_state(enabled, should_consume, efficiency, production_valid, state_tick)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_STATUS_STATE, "generated_owner": SOURCE_BUILDING_STATUS_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_sleep_bridge_state(sleep_time: float, time_delta: float, sleeping: bool, sleeping_entities: int, time_to_sleep: float = SOURCE_BUILDING_SLEEP_TIME_TO_SLEEP) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_SLEEP_JAVA_METHOD, [sleep_time, time_delta, sleeping, sleeping_entities, time_to_sleep])
	var canonical := sleep_state(sleep_time, time_delta, sleeping, sleeping_entities, time_to_sleep)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SLEEP_STATE, "generated_owner": SOURCE_BUILDING_SLEEP_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_no_sleep_bridge_state(sleeping: bool, sleeping_entities: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_NOSLEEP_JAVA_METHOD, [sleeping, sleeping_entities])
	var canonical := no_sleep_state(sleeping, sleeping_entities)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_NOSLEEP_STATE, "generated_owner": SOURCE_BUILDING_NOSLEEP_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_can_withdraw_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CAN_WITHDRAW_JAVA_METHOD, [])
	var canonical := can_withdraw_state()
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CAN_WITHDRAW_STATE, "generated_owner": SOURCE_BUILDING_CAN_WITHDRAW_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_can_unload_bridge_state(block_unloadable: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CAN_UNLOAD_JAVA_METHOD, [block_unloadable])
	var canonical := can_unload_state(block_unloadable)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CAN_UNLOAD_STATE, "generated_owner": SOURCE_BUILDING_CAN_UNLOAD_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_can_resupply_bridge_state(block_allow_resupply: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CAN_RESUPPLY_JAVA_METHOD, [block_allow_resupply])
	var canonical := can_resupply_state(block_allow_resupply)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CAN_RESUPPLY_STATE, "generated_owner": SOURCE_BUILDING_CAN_RESUPPLY_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_payload_check_bridge_state(block_rotate: bool, rotation: int, conveyor_rotation: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_PAYLOAD_CHECK_JAVA_METHOD, [block_rotate, rotation, conveyor_rotation])
	var canonical := payload_check_state(block_rotate, rotation, conveyor_rotation)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_PAYLOAD_CHECK_STATE, "generated_owner": SOURCE_BUILDING_PAYLOAD_CHECK_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_allow_deposit_bridge_state(block_always_allow_deposit: bool, only_deposit_core: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_ALLOW_DEPOSIT_JAVA_METHOD, [block_always_allow_deposit, only_deposit_core])
	var canonical := allow_deposit_state(block_always_allow_deposit, only_deposit_core)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ALLOW_DEPOSIT_STATE, "generated_owner": SOURCE_BUILDING_ALLOW_DEPOSIT_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_should_consume_bridge_state(enabled: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_SHOULD_CONSUME_JAVA_METHOD, [enabled])
	var canonical := should_consume_state(enabled)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SHOULD_CONSUME_STATE, "generated_owner": SOURCE_BUILDING_SHOULD_CONSUME_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_production_valid_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_PRODUCTION_VALID_JAVA_METHOD, [])
	var canonical := production_valid_state()
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_PRODUCTION_VALID_STATE, "generated_owner": SOURCE_BUILDING_PRODUCTION_VALID_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_consume_trigger_valid_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CONSUME_TRIGGER_VALID_JAVA_METHOD, [])
	var canonical := consume_trigger_valid_state()
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONSUME_TRIGGER_VALID_STATE, "generated_owner": SOURCE_BUILDING_CONSUME_TRIGGER_VALID_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}
