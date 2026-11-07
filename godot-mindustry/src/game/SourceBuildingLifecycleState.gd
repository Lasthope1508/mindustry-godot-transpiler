extends RefCounted
class_name SourceBuildingLifecycleState

const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_lifecycle_proximity_state := preload("res://src/game/SourceBuildingLifecycleProximityState.gd")
const source_building_lifecycle_team_state := preload("res://src/game/SourceBuildingLifecycleTeamState.gd")
const source_building_lifecycle_pickup_state := preload("res://src/game/SourceBuildingLifecyclePickupState.gd")
const source_building_lifecycle_callback_registry := preload("res://src/game/SourceBuildingLifecycleCallbackRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_building_lifecycle_source_text_state := preload("res://src/game/SourceBuildingLifecycleSourceTextState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_UPDATE_TILE_GATE_METHOD := source_building_source_text_state.SOURCE_BUILDING_UPDATE_TILE_GATE_METHOD
const SOURCE_BUILDING_UPDATE_TILE_GATE_GUARD := source_building_source_text_state.SOURCE_BUILDING_UPDATE_TILE_GATE_GUARD
const SOURCE_BUILDING_UPDATE_TILE_GATE_CALL := source_building_source_text_state.SOURCE_BUILDING_UPDATE_TILE_GATE_CALL
const SOURCE_BUILDING_LIFECYCLE_CHECK_SUPPRESSION_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_CHECK_SUPPRESSION_JAVA_METHOD
const SOURCE_BUILDING_HEAL_SUPPRESSION_DEFAULT_COLOR := source_building_lifecycle_source_text_state.HEAL_SUPPRESSION_DEFAULT_COLOR
const SOURCE_BUILDING_LIFECYCLE_CHECK_SUPPRESSION_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_CHECK_SUPPRESSION_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_IS_HEAL_SUPPRESSED_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_IS_HEAL_SUPPRESSED_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_IS_HEAL_SUPPRESSED_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_IS_HEAL_SUPPRESSED_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_RECENTLY_HEALED_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_RECENTLY_HEALED_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_WAS_RECENTLY_HEALED_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_WAS_RECENTLY_HEALED_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_WAS_RECENTLY_DAMAGED_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_WAS_RECENTLY_DAMAGED_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_PLAYER_PLACED_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_PLAYER_PLACED_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_PLAYER_PLACED_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_PLAYER_PLACED_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_PLACED_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_PLACED_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_PLACED_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_PLACED_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_ON_REPAIRED_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_ON_REPAIRED_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_ON_REPAIRED_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_ON_REPAIRED_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_CAN_PICKUP_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_CAN_PICKUP_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_CAN_PICKUP_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_CAN_PICKUP_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_PICKED_UP_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_PICKED_UP_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_PICKED_UP_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_PICKED_UP_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_AFTER_PICKED_UP_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_AFTER_PICKED_UP_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_AFTER_PICKED_UP_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_AFTER_PICKED_UP_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_CONFIG_DEFAULT_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_CONFIG_DEFAULT_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_CONFIG_DEFAULT_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_CONFIG_DEFAULT_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_IS_VALID_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_IS_VALID_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_IS_VALID_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_IS_VALID_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_HEAL_NO_ARG_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_HEAL_NO_ARG_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_HEAL_NO_ARG_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_HEAL_NO_ARG_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_HEAL_AMOUNT_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_HEAL_AMOUNT_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_HEAL_AMOUNT_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_HEAL_AMOUNT_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_KILL_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_KILL_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_KILL_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_KILL_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_KILLED_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_KILLED_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_KILLED_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_KILLED_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_CHECK_ALLOW_UPDATE_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_CHECK_ALLOW_UPDATE_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_CHECK_ALLOW_UPDATE_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_CHECK_ALLOW_UPDATE_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_GATE_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_GATE_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_GATE_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_GATE_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_UPDATE_PAYLOAD_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_UPDATE_PAYLOAD_METHOD
const SOURCE_BUILDING_LIFECYCLE_UPDATE_PAYLOAD_UPDATE_EXPR := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_UPDATE_PAYLOAD_UPDATE_EXPR
const SOURCE_BUILDING_LIFECYCLE_UPDATE_PAYLOAD_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_UPDATE_PAYLOAD_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_UPDATE_PAYLOAD_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_UPDATE_PAYLOAD_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_METHOD
const SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_CHANCE_DELTA_THRESHOLD_KEY := source_building_lifecycle_callback_registry.SOURCE_BUILDING_LIFECYCLE_CHANCE_DELTA_THRESHOLD_KEY
const SOURCE_BUILDING_LIFECYCLE_CHANCE_DELTA_THRESHOLD_FALLBACK := source_building_lifecycle_callback_registry.SOURCE_BUILDING_LIFECYCLE_CHANCE_DELTA_THRESHOLD_FALLBACK
const SOURCE_BUILDING_INIT_SOURCE := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_SOURCE
const SOURCE_BUILDING_INIT_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_METHOD
const SOURCE_BUILDING_INIT_INITIALIZED_GUARD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_INITIALIZED_GUARD
const SOURCE_BUILDING_INIT_CREATE_CALL := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_CREATE_CALL
const SOURCE_BUILDING_INIT_POWER_REINIT_GUARD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_POWER_REINIT_GUARD
const SOURCE_BUILDING_INIT_POWER_INIT_ASSIGN := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_POWER_INIT_ASSIGN
const SOURCE_BUILDING_INIT_POWER_GRAPH_ADD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_POWER_GRAPH_ADD
const SOURCE_BUILDING_INIT_PROXIMITY_CLEAR := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_PROXIMITY_CLEAR
const SOURCE_BUILDING_INIT_ROTATION_ASSIGN := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_ROTATION_ASSIGN
const SOURCE_BUILDING_INIT_TILE_ASSIGN := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_TILE_ASSIGN
const SOURCE_BUILDING_INIT_SET_POSITION := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_SET_POSITION
const SOURCE_BUILDING_INIT_ADD_GUARD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_ADD_GUARD
const SOURCE_BUILDING_INIT_ADD_CALL := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_ADD_CALL
const SOURCE_BUILDING_INIT_CHECK_ALLOW_UPDATE := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_CHECK_ALLOW_UPDATE
const SOURCE_BUILDING_INIT_CREATED_CALL := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_CREATED_CALL
const SOURCE_BUILDING_INIT_RETURN := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_RETURN
const SOURCE_BUILDING_CREATE_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_METHOD
const SOURCE_BUILDING_CREATE_BLOCK_ASSIGN := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_BLOCK_ASSIGN
const SOURCE_BUILDING_CREATE_TEAM_ASSIGN := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_TEAM_ASSIGN
const SOURCE_BUILDING_CREATE_HEALTH_ASSIGN := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_HEALTH_ASSIGN
const SOURCE_BUILDING_CREATE_MAX_HEALTH_CALL := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_MAX_HEALTH_CALL
const SOURCE_BUILDING_CREATE_TIMER_CALL := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_TIMER_CALL
const SOURCE_BUILDING_CREATE_ITEMS_GUARD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_ITEMS_GUARD
const SOURCE_BUILDING_CREATE_ITEMS_CALL := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_ITEMS_CALL
const SOURCE_BUILDING_CREATE_LIQUIDS_GUARD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_LIQUIDS_GUARD
const SOURCE_BUILDING_CREATE_LIQUIDS_CALL := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_LIQUIDS_CALL
const SOURCE_BUILDING_CREATE_POWER_GUARD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_POWER_GUARD
const SOURCE_BUILDING_CREATE_POWER_CALL := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_POWER_CALL
const SOURCE_BUILDING_CREATE_POWER_GRAPH_ADD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_POWER_GRAPH_ADD
const SOURCE_BUILDING_CREATE_INITIALIZED_ASSIGN := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_INITIALIZED_ASSIGN
const SOURCE_BUILDING_CREATE_RETURN := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_RETURN
const SOURCE_BUILDING_ADD_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_ADD_METHOD
const SOURCE_BUILDING_ADD_POWER_GUARD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_ADD_POWER_GUARD
const SOURCE_BUILDING_ADD_POWER_GRAPH_CHECK := source_building_lifecycle_source_text_state.SOURCE_BUILDING_ADD_POWER_GRAPH_CHECK
const SOURCE_BUILDING_INIT_CREATE_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_CREATE_JAVA_METHOD
const SOURCE_BUILDING_INIT_CREATE_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_INIT_CREATE_GENERATED_OWNER
const SOURCE_BUILDING_CREATE_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_JAVA_METHOD
const SOURCE_BUILDING_CREATE_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_CREATE_GENERATED_OWNER
const SOURCE_BUILDING_ADD_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_ADD_JAVA_METHOD
const SOURCE_BUILDING_ADD_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_ADD_GENERATED_OWNER

static func init_state(initialized: bool, block_has_power: bool, should_add: bool, tile_state: Variant, team_state: Variant, rotation: int, draw_x: float, draw_y: float) -> Dictionary:
	var create_called := not initialized
	var reinit_power := initialized and block_has_power
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_INIT_STATE,
		"source": SOURCE_BUILDING_INIT_SOURCE,
		"method": SOURCE_BUILDING_INIT_METHOD,
		"initialized": initialized,
		"block_has_power": block_has_power,
		"should_add": should_add,
		"tile": tile_state,
		"team": team_state,
		"rotation": rotation,
		"draw_x": draw_x,
		"draw_y": draw_y,
		"create_called": create_called,
		"power_reinit": reinit_power,
		"proximity_cleared": true,
		"position_set": true,
		"add_called": should_add,
		"check_allow_update_called": true,
		"created_called": true,
		"returned_self": true,
	}

static func create_state(block_state: Variant, team_state: Variant, block_health: float, block_timers: int, has_items: bool, has_liquids: bool, has_power: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CREATE_STATE,
		"source": SOURCE_BUILDING_INIT_SOURCE,
		"method": SOURCE_BUILDING_CREATE_METHOD,
		"block": block_state,
		"team": team_state,
		"health": block_health,
		"max_health": block_health,
		"timers": block_timers,
		"items_created": has_items,
		"liquids_created": has_liquids,
		"power_created": has_power,
		"power_graph_add_called": has_power,
		"initialized": true,
		"returned_self": true,
	}

static func add_state(power_present: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ADD_STATE,
		"source": SOURCE_BUILDING_INIT_SOURCE,
		"method": SOURCE_BUILDING_ADD_METHOD,
		"power_present": power_present,
		"power_graph_check_add_called": power_present,
	}

static func generated_init_bridge_state(initialized: bool, block_has_power: bool, should_add: bool, tile_state: Variant, team_state: Variant, rotation: int, draw_x: float, draw_y: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_INIT_CREATE_JAVA_METHOD, [initialized, block_has_power, should_add, tile_state, team_state, rotation, draw_x, draw_y])
	var canonical := init_state(initialized, block_has_power, should_add, tile_state, team_state, rotation, draw_x, draw_y)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_INIT_STATE, "generated_owner": SOURCE_BUILDING_INIT_CREATE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)}

static func generated_create_bridge_state(block_state: Variant, team_state: Variant, block_health: float, block_timers: int, has_items: bool, has_liquids: bool, has_power: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CREATE_JAVA_METHOD, [block_state, team_state, block_health, block_timers, has_items, has_liquids, has_power])
	var canonical := create_state(block_state, team_state, block_health, block_timers, has_items, has_liquids, has_power)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CREATE_STATE, "generated_owner": SOURCE_BUILDING_CREATE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)}

static func generated_add_bridge_state(power_present: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_ADD_JAVA_METHOD, [power_present])
	var canonical := add_state(power_present)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ADD_STATE, "generated_owner": SOURCE_BUILDING_ADD_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)}

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func runtime_method_names(game: Object) -> Dictionary:
	if game.has_method("_building_lifecycle_method_names"):
		var names = game.call("_building_lifecycle_method_names")
		if names is Dictionary:
			return names
	return {}

static func runtime_method_name(method_names: Dictionary, key: String, fallback_name: String) -> String:
	var method_name = method_names.get(key, fallback_name)
	return str(method_name) if method_name != null and str(method_name) != "" else fallback_name

static func default_callbacks_state(game: Object) -> Dictionary:
	var method_names := runtime_method_names(game)
	return {
		SOURCE_BUILDING_LIFECYCLE_CHANCE_DELTA_THRESHOLD_KEY: Callable(game, runtime_method_name(method_names, SOURCE_BUILDING_LIFECYCLE_CHANCE_DELTA_THRESHOLD_KEY, SOURCE_BUILDING_LIFECYCLE_CHANCE_DELTA_THRESHOLD_FALLBACK)),
	}

static func config_default() -> Variant:
	return null

static func is_valid(tile_build_matches_self: bool, dead_state: bool) -> bool:
	return tile_build_matches_self and not dead_state

static func heal_state(_amount: Variant = null) -> Dictionary:
	return {
		"amount": _amount,
		"health_changed": true,
	}

static func kill_state(self_state := {}) -> Dictionary:
	return {
		"method": "public void kill(){",
		"build_destroyed_call": "Call.buildDestroyed(self());",
		"self_state": self_state,
		"call": "buildDestroyed",
		"self": self_state,
	}

static func generated_config_default_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_CONFIG_DEFAULT_JAVA_METHOD, [])
	var canonical = config_default()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CONFIG_DEFAULT,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_CONFIG_DEFAULT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_is_valid_bridge_state(tile_build_matches_self: bool, dead_state: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_IS_VALID_JAVA_METHOD, [tile_build_matches_self, dead_state])
	var canonical = is_valid(tile_build_matches_self, dead_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IS_VALID,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_IS_VALID_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_heal_bridge_state(amount: Variant = null) -> Dictionary:
	var result_no_arg = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_HEAL_NO_ARG_JAVA_METHOD, [])
	var result_amount = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_HEAL_AMOUNT_JAVA_METHOD, [amount])
	var canonical_no_arg = heal_state()
	var canonical_amount = heal_state(amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HEAL_STATE,
		"generated_owner_no_arg": SOURCE_BUILDING_LIFECYCLE_HEAL_NO_ARG_GENERATED_OWNER,
		"generated_owner_amount": SOURCE_BUILDING_LIFECYCLE_HEAL_AMOUNT_GENERATED_OWNER,
		"result_no_arg": result_no_arg,
		"result_amount": result_amount,
		"canonical_no_arg": canonical_no_arg,
		"canonical_amount": canonical_amount,
	}

static func generated_kill_bridge_state(self_state := {}) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_KILL_JAVA_METHOD, [self_state])
	var canonical = kill_state(self_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_KILL_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_KILL_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func killed_initial_side_effects_state(tile_value: Variant) -> Dictionary:
	return {
		"method": "public void killed(){",
		"tile_value": tile_value,
		"dead": true,
		"event": {"type": "BlockDestroyEvent", "tile": tile_value},
		"on_destroyed_called": true,
		"next_step": "tile_remove_gate",
	}

static func generated_killed_initial_side_effects_bridge_state(tile_value: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_KILLED_JAVA_METHOD, [tile_value])
	var canonical = killed_initial_side_effects_state(tile_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_KILLED_INITIAL_SIDE_EFFECTS_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_KILLED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func killed_removal_side_effects_state(tile_not_empty_tile: bool) -> Dictionary:
	return {
		"method": "public void killed(){",
		"tile_not_empty_tile": tile_not_empty_tile,
		"tile_remove_gate": tile_not_empty_tile,
		"tile_remove_called": tile_not_empty_tile,
		"remove_called": true,
		"after_destroyed_called": true,
	}

static func generated_killed_removal_side_effects_bridge_state(tile_value: Variant, tile_not_empty_tile: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_KILLED_JAVA_METHOD, [tile_value, tile_not_empty_tile])
	var canonical = killed_removal_side_effects_state(tile_not_empty_tile)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_KILLED_REMOVAL_SIDE_EFFECTS_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_KILLED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func change_team_delegate_state(next_team: Variant) -> Dictionary:
	return source_building_lifecycle_team_state.change_team_delegate_state(next_team)

static func change_team_initial_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool) -> Dictionary:
	return source_building_lifecycle_team_state.change_team_initial_state(current_team, next_team, force_team, was_valid)

static func change_team_power_proximity_state(power_present: bool, update_power: bool, old_graph: Variant, team: Variant) -> Dictionary:
	return source_building_lifecycle_team_state.change_team_power_proximity_state(power_present, update_power, old_graph, team)

static func change_team_power_links_state(link_count: int, team: Variant, old_graph: Variant) -> Dictionary:
	return source_building_lifecycle_team_state.change_team_power_links_state(link_count, team, old_graph)

static func change_team_final_state(was: bool, last_team: Variant) -> Dictionary:
	return source_building_lifecycle_team_state.change_team_final_state(was, last_team)

static func can_pickup_state(block_can_pickup: bool) -> bool:
	return source_building_lifecycle_pickup_state.can_pickup_state(block_can_pickup)

static func picked_up_state(previous_state: Variant) -> Dictionary:
	return source_building_lifecycle_pickup_state.picked_up_state(previous_state)

static func after_picked_up_state(power_present: bool, has_cons_power: bool, cons_power_buffered: bool, current_status: float) -> Dictionary:
	return source_building_lifecycle_pickup_state.after_picked_up_state(power_present, has_cons_power, cons_power_buffered, current_status)

static func check_allow_update_state(current_enabled: bool, allow_update_result: bool) -> Dictionary:
	if not allow_update_result:
		return {"enabled": false, "changed": current_enabled}
	return {"enabled": current_enabled, "changed": false}

static func generated_check_allow_update_bridge_state(current_enabled: bool, allow_update_result: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_CHECK_ALLOW_UPDATE_JAVA_METHOD, [current_enabled, allow_update_result])
	var canonical = check_allow_update_state(current_enabled, allow_update_result)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CHECK_ALLOW_UPDATE_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_CHECK_ALLOW_UPDATE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func update_tile_gate_state(enabled_state: bool, block_no_update_disabled: bool) -> Dictionary:
	var update_tile_called: bool = enabled_state or not block_no_update_disabled
	return {"update_tile_called": update_tile_called}

static func generated_update_tile_gate_bridge_state(enabled_state: bool, block_no_update_disabled: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_GATE_JAVA_METHOD, [source_block_defaults.TIME_SCALE_DEFAULT, 0.0, 0.0, false, null, null, false, 0.0, 0.0, enabled_state, block_no_update_disabled])
	var canonical = update_tile_gate_state(enabled_state, block_no_update_disabled)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_TILE_GATE_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_GATE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func update_payload_state(update_state: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_PAYLOAD_STATE,
		"method": SOURCE_BUILDING_LIFECYCLE_UPDATE_PAYLOAD_METHOD,
		"update_call": SOURCE_BUILDING_LIFECYCLE_UPDATE_PAYLOAD_UPDATE_EXPR,
		"unit_holder": unit_holder,
		"building_holder": building_holder,
		"update_called": true,
		"update_state": update_state,
	}

static func generated_update_payload_bridge_state(unit_holder: Variant, building_holder: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_UPDATE_PAYLOAD_JAVA_METHOD, [unit_holder, building_holder])
	var canonical = update_payload_state(result.get("update_state", null) if result is Dictionary else null, unit_holder, building_holder)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_PAYLOAD_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_UPDATE_PAYLOAD_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical),
	}

static func empty_lifecycle_callback_state(generated_method: String) -> Dictionary:
	assert(source_building_lifecycle_source_text_state.EMPTY_LIFECYCLE_METHODS.has(generated_method))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_EMPTY_LIFECYCLE_CALLBACKS_STATE,
		"method": source_building_lifecycle_source_text_state.EMPTY_LIFECYCLE_METHODS[generated_method],
		"no_op": true,
	}

static func generated_empty_lifecycle_callbacks_bridge_state(generated_method: String, args: Array) -> Dictionary:
	# Validate the source boundary before allowing dynamic generated-method dispatch.
	var canonical := empty_lifecycle_callback_state(generated_method)
	var result = _building_comp_call(generated_method, args)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_EMPTY_LIFECYCLE_CALLBACKS_STATE,
		"result": result,
		"canonical": canonical,
		"matches": result is Dictionary and result == canonical,
	}

static func update_tile_noop_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_TILE_NOOP_STATE,
		"method": SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_METHOD,
		"no_op": true,
	}

static func generated_update_tile_noop_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_JAVA_METHOD, [])
	var canonical = update_tile_noop_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_TILE_NOOP_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_UPDATE_TILE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical),
	}

static func is_heal_suppressed_state(block_suppressable: bool, source_time: float, heal_suppression_time: float) -> bool:
	return block_suppressable and source_time <= heal_suppression_time

static func apply_heal_suppression_state(heal_suppression_time: float, source_time: float, amount: float, suppress_color: Variant) -> Dictionary:
	var updated_time := maxf(heal_suppression_time, source_time + amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HEAL_SUPPRESSION_STATE,
		"method": source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_APPLY_HEAL_SUPPRESSION_METHOD,
		"heal_suppression_time_before": heal_suppression_time,
		"source_time": source_time,
		"amount": amount,
		"heal_suppression_time_after": updated_time,
		"suppress_color": suppress_color,
		"updated": true,
	}

static func generated_apply_heal_suppression_bridge_state(heal_suppression_time: float, source_time: float, amount: float, suppress_color: Variant, use_color_overload: bool) -> Dictionary:
	var method := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_APPLY_HEAL_SUPPRESSION_COLOR_JAVA_METHOD if use_color_overload else source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_APPLY_HEAL_SUPPRESSION_NO_COLOR_JAVA_METHOD
	var args := [heal_suppression_time, source_time, amount, suppress_color] if use_color_overload else [heal_suppression_time, source_time, amount]
	var result = _building_comp_call(method, args)
	var canonical := apply_heal_suppression_state(heal_suppression_time, source_time, amount, suppress_color if use_color_overload else source_building_lifecycle_source_text_state.HEAL_SUPPRESSION_DEFAULT_COLOR)
	return {"generated_owner": source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_APPLY_HEAL_SUPPRESSION_COLOR_GENERATED_OWNER if use_color_overload else source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_APPLY_HEAL_SUPPRESSION_NO_COLOR_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)}

static func is_heal_suppressed_result_state(block_suppressable: bool, source_time: float, heal_suppression_time: float) -> Dictionary:
	return {"block_suppressable": block_suppressable, "source_time": source_time, "heal_suppression_time": heal_suppression_time, "method": "public boolean isHealSuppressed(){", "suppressed": is_heal_suppressed_state(block_suppressable, source_time, heal_suppression_time)}

static func recently_healed_state(source_time: float) -> Dictionary:
	return {"source_time": source_time, "last_heal_time": source_time, "updated": true}

static func was_recently_healed_state(last_heal_time: float, duration: float, source_time: float) -> Dictionary:
	return {"last_heal_time": last_heal_time, "duration": duration, "source_time": source_time, "recent": last_heal_time + duration >= source_time}

static func was_recently_damaged_state(last_damage_time: float, recent_damage_time: float, source_time: float) -> Dictionary:
	return {"last_damage_time": last_damage_time, "recent_damage_time": recent_damage_time, "source_time": source_time, "recent": last_damage_time + recent_damage_time >= source_time}

static func generated_recently_healed_bridge_state(source_time: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_RECENTLY_HEALED_JAVA_METHOD, [source_time])
	var canonical := recently_healed_state(source_time)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HEALTH_RECENT_STATE, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)}

static func generated_was_recently_healed_bridge_state(last_heal_time: float, duration: float, source_time: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_WAS_RECENTLY_HEALED_JAVA_METHOD, [last_heal_time, duration, source_time])
	var canonical := was_recently_healed_state(last_heal_time, duration, source_time)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HEALTH_RECENT_STATE, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)}

static func generated_was_recently_damaged_bridge_state(last_damage_time: float, recent_damage_time: float, source_time: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_WAS_RECENTLY_DAMAGED_JAVA_METHOD, [last_damage_time, recent_damage_time, source_time])
	var canonical := was_recently_damaged_state(last_damage_time, recent_damage_time, source_time)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HEALTH_RECENT_STATE, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)}

static func generated_is_heal_suppressed_bridge_state(block_suppressable: bool, source_time: float, heal_suppression_time: float) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_IS_HEAL_SUPPRESSED_JAVA_METHOD, [block_suppressable, source_time, heal_suppression_time])
	var canonical := is_heal_suppressed_result_state(block_suppressable, source_time, heal_suppression_time)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IS_HEAL_SUPPRESSED_STATE, "generated_owner": SOURCE_BUILDING_LIFECYCLE_IS_HEAL_SUPPRESSED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)}

static func check_suppression_state(block_suppressable: bool, source_time: float, heal_suppression_time: float, source_delta: float, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, suppress_color: String, chance_delta_threshold: Callable) -> Dictionary:
	var suppressed := is_heal_suppressed_state(block_suppressable, source_time, heal_suppression_time)
	if not suppressed:
		return {"suppressed": false, "particle_visible": false}
	var particle_range := block_size_value * source_tilesize / 2.0 - 1.0
	var chance_threshold := float(chance_delta_threshold.call(0.03, source_delta))
	return {"suppressed": true, "particle_visible": "chanceDelta", "chance_threshold": chance_threshold, "effect": "regenSuppressParticle", "color": suppress_color, "particle_range": particle_range, "x_min": source_x - particle_range, "x_max": source_x + particle_range, "y_min": source_y - particle_range, "y_max": source_y + particle_range}

static func game_check_suppression_state(game: Object, block_suppressable: bool, source_time: float, heal_suppression_time: float, source_delta: float, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, suppress_color: String) -> Dictionary:
	var callbacks := default_callbacks_state(game)
	return check_suppression_state(block_suppressable, source_time, heal_suppression_time, source_delta, source_x, source_y, block_size_value, source_tilesize, suppress_color, callbacks.get(SOURCE_BUILDING_LIFECYCLE_CHANCE_DELTA_THRESHOLD_KEY, Callable()))

static func generated_check_suppression_bridge_state(block_suppressable: bool, source_time: float, heal_suppression_time: float, source_delta: float, source_x: float, source_y: float, block_size_value: int, source_tilesize: float, suppress_color: String) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_CHECK_SUPPRESSION_JAVA_METHOD, [block_suppressable, source_time, heal_suppression_time, source_delta, source_x, source_y, block_size_value, source_tilesize, suppress_color])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CHECK_SUPPRESSION_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_CHECK_SUPPRESSION_GENERATED_OWNER,
		"result": result,
	}

static func player_placed_state(config_state: Variant) -> Dictionary:
	return {
		"method": "public void playerPlaced(Object config){",
		"comment": "Called after the block is placed by this client.",
		"call_super": "@CallSuper",
		"no_op": true,
		"config_state": config_state,
	}

static func generated_player_placed_bridge_state(config_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_PLAYER_PLACED_JAVA_METHOD, [config_state])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_PLAYER_PLACED_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_PLAYER_PLACED_GENERATED_OWNER,
		"result": result,
	}

static func placed_state(net_client: bool, consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, linked_to_self: bool, source_pos: int) -> Dictionary:
	var should_link_power := (consumes_power or outputs_power) and has_power and connected_power
	if net_client:
		return {"method": "public void placed(){", "comment": "Called after the block is placed by anyone.", "call_super": "@CallSuper", "client_guard": "if(net.client()) return;" if net_client else "", "power_gate": "", "power_node_scan": "", "link_guard": "", "configure_call": "", "returned": true, "power_link_scan": false, "configure": false, "configure_pos": -1}
	if not should_link_power:
		return {"method": "public void placed(){", "comment": "Called after the block is placed by anyone.", "call_super": "@CallSuper", "client_guard": "if(net.client()) return;" if net_client else "", "power_gate": "if((block.consumesPower || block.outputsPower) && block.hasPower && block.connectedPower){" if should_link_power else "", "power_node_scan": "PowerNode.getNodeLinks(tile, block, team, other -> {" if should_link_power else "", "link_guard": "if(!other.power.links.contains(pos())){" if should_link_power else "", "configure_call": "", "returned": false, "power_link_scan": false, "configure": false, "configure_pos": -1}
	var configure := not linked_to_self
	return {"method": "public void placed(){", "comment": "Called after the block is placed by anyone.", "call_super": "@CallSuper", "client_guard": "if(net.client()) return;" if net_client else "", "power_gate": "if((block.consumesPower || block.outputsPower) && block.hasPower && block.connectedPower){" if should_link_power else "", "power_node_scan": "PowerNode.getNodeLinks(tile, block, team, other -> {" if should_link_power else "", "link_guard": "if(!other.power.links.contains(pos())){" if should_link_power else "", "configure_call": "other.configureAny(pos());" if configure else "", "returned": false, "power_link_scan": true, "configure": configure, "configure_pos": source_pos if configure else -1}

static func generated_placed_bridge_state(net_client: bool, consumes_power: bool, outputs_power: bool, has_power: bool, connected_power: bool, linked_to_self: bool, source_pos: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_PLACED_JAVA_METHOD, [net_client, consumes_power, outputs_power, has_power, connected_power, linked_to_self, source_pos])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_PLACED_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_PLACED_GENERATED_OWNER,
		"result": result,
	}

static func on_repaired_state(has_fog_radius: bool) -> Dictionary:
	return {
		"method": "public void onRepaired(){",
		"call_super": "@CallSuper",
		"placed_call": "placed();",
		"fog_gate": "if(block.flags.contains(BlockFlag.hasFogRadius)){" if has_fog_radius else "",
		"fog_call": "fogControl.forceUpdate(team, self());" if has_fog_radius else "",
		"has_fog_radius": has_fog_radius,
		"placed": true,
		"fog_force_update": has_fog_radius,
	}

static func generated_on_repaired_bridge_state(has_fog_radius: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_ON_REPAIRED_JAVA_METHOD, [has_fog_radius])
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_REPAIRED_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_ON_REPAIRED_GENERATED_OWNER,
		"result": result,
	}

static func generated_change_team_delegate_bridge_state(next_team: Variant) -> Dictionary:
	return source_building_lifecycle_team_state.generated_change_team_delegate_bridge_state(next_team)

static func generated_change_team_initial_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool) -> Dictionary:
	return source_building_lifecycle_team_state.generated_change_team_initial_bridge_state(current_team, next_team, force_team, was_valid)

static func generated_change_team_power_proximity_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool, power_present: bool, update_power: bool, old_graph: Variant) -> Dictionary:
	return source_building_lifecycle_team_state.generated_change_team_power_proximity_bridge_state(current_team, next_team, force_team, was_valid, power_present, update_power, old_graph)

static func generated_change_team_power_links_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool, power_present: bool, update_power: bool, old_graph: Variant, link_count: int) -> Dictionary:
	return source_building_lifecycle_team_state.generated_change_team_power_links_bridge_state(current_team, next_team, force_team, was_valid, power_present, update_power, old_graph, link_count)

static func generated_change_team_final_bridge_state(current_team: Variant, next_team: Variant, force_team: Variant, was_valid: bool, power_present: bool, update_power: bool, old_graph: Variant, link_count: int) -> Dictionary:
	return source_building_lifecycle_team_state.generated_change_team_final_bridge_state(current_team, next_team, force_team, was_valid, power_present, update_power, old_graph, link_count)

static func generated_can_pickup_bridge_state(block_can_pickup: bool) -> Dictionary:
	return source_building_lifecycle_pickup_state.generated_can_pickup_bridge_state(block_can_pickup)

static func generated_picked_up_bridge_state(previous_state: Variant) -> Dictionary:
	return source_building_lifecycle_pickup_state.generated_picked_up_bridge_state(previous_state)

static func generated_after_picked_up_bridge_state(power_present: bool, has_cons_power: bool, cons_power_buffered: bool, current_status: float) -> Dictionary:
	return source_building_lifecycle_pickup_state.generated_after_picked_up_bridge_state(power_present, has_cons_power, cons_power_buffered, current_status)

static func generated_remove_from_proximity_bridge_state(nearby_count: int, removable_count: int) -> Dictionary:
	return source_building_lifecycle_proximity_state.generated_remove_from_proximity_bridge_state(nearby_count, removable_count)

static func generated_update_proximity_bridge_state(nearby_count: int, same_team_count: int, headless: bool, draw_cached: bool) -> Dictionary:
	return source_building_lifecycle_proximity_state.generated_update_proximity_bridge_state(nearby_count, same_team_count, headless, draw_cached)

static func generated_on_nearby_build_added_bridge_state(other_state: Variant) -> Dictionary:
	return source_building_lifecycle_proximity_state.generated_on_nearby_build_added_bridge_state(other_state)

static func remove_from_proximity_state(nearby_count: int, removable_count: int) -> Dictionary:
	return source_building_lifecycle_proximity_state.remove_from_proximity_state(nearby_count, removable_count)

static func update_proximity_state(nearby_count: int, same_team_count: int, headless: bool, draw_cached: bool) -> Dictionary:
	return source_building_lifecycle_proximity_state.update_proximity_state(nearby_count, same_team_count, headless, draw_cached)

static func on_nearby_build_added_state(other_state: Variant) -> Dictionary:
	return source_building_lifecycle_proximity_state.on_nearby_build_added_state(other_state)
