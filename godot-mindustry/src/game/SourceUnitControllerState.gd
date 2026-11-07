extends RefCounted
class_name SourceUnitControllerState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_text := preload("res://src/game/SourceUnitControllerSourceTextState.gd")

static func collision_state(other_is_bullet: bool, bullet: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_COLLISION_STATE,
		source_text.SOURCE_UNIT_COLLISION_OTHER_IS_BULLET_KEY: other_is_bullet,
		source_text.SOURCE_UNIT_COLLISION_BULLET_KEY: bullet,
		source_text.SOURCE_UNIT_COLLISION_CONTROLLER_HIT_CALLED_KEY: other_is_bullet,
		source_text.SOURCE_UNIT_COLLISION_CONTROLLER_HIT_KEY: {"call": source_text.SOURCE_UNIT_COLLISION_CONTROLLER_HIT, "bullet": bullet} if other_is_bullet else null,
	}

static func controller_set_state(next_controller: Variant, controller_unit: Variant, self_unit: Variant) -> Dictionary:
	var unit_sync_required: bool = controller_unit != self_unit
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_CONTROLLER_SET_STATE,
		source_text.SOURCE_UNIT_CONTROLLER_KEY: next_controller,
		source_text.SOURCE_UNIT_CONTROLLER_UNIT_KEY: self_unit if unit_sync_required else controller_unit,
		source_text.SOURCE_UNIT_CONTROLLER_UNIT_SYNC_REQUIRED_KEY: unit_sync_required,
		source_text.SOURCE_UNIT_CALL_ORDER_KEY: [source_text.SOURCE_UNIT_CONTROLLER_ASSIGN, source_text.SOURCE_UNIT_CONTROLLER_UNIT_SYNC] if unit_sync_required else [source_text.SOURCE_UNIT_CONTROLLER_ASSIGN],
	}

static func controller_get_state(controller: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_CONTROLLER_GET_STATE,
		source_text.SOURCE_UNIT_CONTROLLER_KEY: controller,
	}

static func get_controller_name_state(is_player: bool, player_colored_name: String, controller_is_logic_ai: bool, logic_controller_exists: bool, logic_controller_last_accessed: String) -> Dictionary:
	var branch := "none"
	var controller_name: Variant = null
	if is_player:
		branch = "player"
		controller_name = player_colored_name
	elif controller_is_logic_ai and logic_controller_exists:
		branch = "logic_ai"
		controller_name = logic_controller_last_accessed
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_GET_CONTROLLER_NAME_STATE,
		"comment": source_text.SOURCE_UNIT_GET_CONTROLLER_NAME_COMMENT,
		"method": source_text.SOURCE_UNIT_GET_CONTROLLER_NAME_METHOD,
		"player_guard": source_text.SOURCE_UNIT_GET_CONTROLLER_NAME_PLAYER_GUARD,
		"logic_guard": source_text.SOURCE_UNIT_GET_CONTROLLER_NAME_LOGIC_GUARD,
		"null_return": source_text.SOURCE_UNIT_GET_CONTROLLER_NAME_RETURN_NULL,
		"controller_name": controller_name,
		"branch": branch,
	}

static func display_state(table: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_DISPLAY_STATE, "method": source_text.SOURCE_UNIT_DISPLAY_METHOD, "call": source_text.SOURCE_UNIT_DISPLAY_CALL, "table": table}

static func draw_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_DRAW_STATE, "method": source_text.SOURCE_UNIT_DRAW_METHOD, "call": source_text.SOURCE_UNIT_DRAW_CALL}

static func is_player_state(controller_is_player: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_IS_PLAYER_STATE, "method": source_text.SOURCE_UNIT_IS_PLAYER_METHOD, "return": source_text.SOURCE_UNIT_IS_PLAYER_RETURN, "is_player": controller_is_player}

static func get_player_state(controller_is_player: bool, controller: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_GET_PLAYER_STATE, "method": source_text.SOURCE_UNIT_GET_PLAYER_METHOD, "return": source_text.SOURCE_UNIT_GET_PLAYER_RETURN, "player": controller if controller_is_player else null, "is_player": controller_is_player}

static func to_string_state(unit_id: int, unit_type: Variant, unit_x: float, unit_y: float) -> Dictionary:
	var to_string_value := "Unit#" + str(unit_id) + ":" + str(unit_type) + " (" + str(unit_x) + ", " + str(unit_y) + ")"
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TO_STRING_STATE,
		"method": source_text.SOURCE_UNIT_TO_STRING_METHOD,
		"return": source_text.SOURCE_UNIT_TO_STRING_RETURN,
		"id": unit_id,
		"type": unit_type,
		"x": unit_x,
		"y": unit_y,
		"to_string": to_string_value,
	}

static func reset_controller_state(created_controller: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_RESET_CONTROLLER_STATE,
		source_text.SOURCE_UNIT_RESET_CREATED_CONTROLLER_KEY: created_controller,
		source_text.SOURCE_UNIT_CONTROLLER_KEY: created_controller,
		source_text.SOURCE_UNIT_RESET_CREATE_CONTROLLER_CALL_KEY: source_text.SOURCE_UNIT_RESET_CONTROLLER_FACTORY,
	}

static func set_state(current_type: Variant, definition: Variant, controller: Variant, controller_unit: Variant, self_unit: Variant) -> Dictionary:
	var type_changed: bool = current_type != definition
	var controller_result := controller_set_state(controller, controller_unit, self_unit)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_SET_STATE,
		source_text.SOURCE_UNIT_SET_TYPE_KEY: definition if type_changed else current_type,
		source_text.SOURCE_UNIT_SET_TYPE_CHANGED_KEY: type_changed,
		source_text.SOURCE_UNIT_SET_TYPE_CALLED_KEY: type_changed,
		source_text.SOURCE_UNIT_CONTROLLER_KEY: controller_result.get(source_text.SOURCE_UNIT_CONTROLLER_KEY),
		source_text.SOURCE_UNIT_CONTROLLER_UNIT_KEY: controller_result.get(source_text.SOURCE_UNIT_CONTROLLER_UNIT_KEY),
		source_text.SOURCE_UNIT_SET_CONTROLLER_UNIT_SYNC_REQUIRED_KEY: controller_result.get(source_text.SOURCE_UNIT_CONTROLLER_UNIT_SYNC_REQUIRED_KEY),
		source_text.SOURCE_UNIT_CALL_ORDER_KEY: ([source_text.SOURCE_UNIT_SET_TYPE_CALL] if type_changed else []) + [source_text.SOURCE_UNIT_SET_CONTROLLER_CALL],
	}

static func collision_layer_state(type_allow_leg_step: bool, type_leg_physics_layer: bool, is_grounded: bool, layer_legs: int, layer_ground: int, layer_flying: int) -> Dictionary:
	var layer := layer_legs if type_allow_leg_step and type_leg_physics_layer else layer_ground if is_grounded else layer_flying
	var branch := source_text.SOURCE_UNIT_COLLISION_LAYER_LEGS_BRANCH if type_allow_leg_step and type_leg_physics_layer else source_text.SOURCE_UNIT_COLLISION_LAYER_GROUND_BRANCH if is_grounded else source_text.SOURCE_UNIT_COLLISION_LAYER_FLYING_BRANCH
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_COLLISION_LAYER_STATE,
		source_text.SOURCE_UNIT_COLLISION_LAYER_KEY: layer,
		source_text.SOURCE_UNIT_COLLISION_LAYER_BRANCH_KEY: branch,
	}
