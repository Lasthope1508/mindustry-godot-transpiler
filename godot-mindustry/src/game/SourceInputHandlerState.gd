extends RefCounted
class_name SourceInputHandlerState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerGameplayRegistry.gd")
const source_text := preload("res://src/game/SourceInputHandlerSourceTextState.gd")

static func get_mouse_x_state(mouse_x: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_INPUT_HANDLER_GET_MOUSE_X_STATE,
		"source": source_text.SOURCE_INPUT_HANDLER_SOURCE,
		"method": source_text.SOURCE_INPUT_HANDLER_GET_MOUSE_X_METHOD,
		"return_expr": source_text.SOURCE_INPUT_HANDLER_GET_MOUSE_X_EXPR,
		"mouse_x": mouse_x,
	}

static func get_mouse_y_state(mouse_y: float) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_INPUT_HANDLER_GET_MOUSE_Y_STATE,
		"source": source_text.SOURCE_INPUT_HANDLER_SOURCE,
		"method": source_text.SOURCE_INPUT_HANDLER_GET_MOUSE_Y_METHOD,
		"return_expr": source_text.SOURCE_INPUT_HANDLER_GET_MOUSE_Y_EXPR,
		"mouse_y": mouse_y,
	}

static func pan_camera_state(position: Vector2, locked: bool, camera_position_before: Vector2) -> Dictionary:
	var camera_position_after := camera_position_before if locked else position
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_INPUT_HANDLER_PAN_CAMERA_STATE,
		"source": source_text.SOURCE_INPUT_HANDLER_SOURCE,
		"method": source_text.SOURCE_INPUT_HANDLER_PAN_CAMERA_METHOD,
		"guard_expr": source_text.SOURCE_INPUT_HANDLER_PAN_CAMERA_GUARD_EXPR,
		"assignment_expr": source_text.SOURCE_INPUT_HANDLER_PAN_CAMERA_ASSIGNMENT_EXPR,
		"position": position,
		"locked": locked,
		"camera_position_before": camera_position_before,
		"camera_position_after": camera_position_after,
		"camera_updated": not locked,
	}

static func selected_block_state(block_present: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_INPUT_HANDLER_SELECTED_BLOCK_STATE,
		"source": source_text.SOURCE_INPUT_HANDLER_SOURCE,
		"method": source_text.SOURCE_INPUT_HANDLER_SELECTED_BLOCK_METHOD,
		"return_expr": source_text.SOURCE_INPUT_HANDLER_SELECTED_BLOCK_RETURN_EXPR,
		"block_present": block_present,
		"selected_block": block_present,
	}

static func is_placing_state(block_present: bool) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_INPUT_HANDLER_IS_PLACING_STATE,
		"source": source_text.SOURCE_INPUT_HANDLER_SOURCE,
		"method": source_text.SOURCE_INPUT_HANDLER_IS_PLACING_METHOD,
		"return_expr": source_text.SOURCE_INPUT_HANDLER_IS_PLACING_RETURN_EXPR,
		"block_present": block_present,
		"is_placing": block_present,
	}

static func is_breaking_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_INPUT_HANDLER_IS_BREAKING_STATE,
		"source": source_text.SOURCE_INPUT_HANDLER_SOURCE,
		"method": source_text.SOURCE_INPUT_HANDLER_IS_BREAKING_METHOD,
		"return_expr": source_text.SOURCE_INPUT_HANDLER_IS_BREAKING_RETURN_EXPR,
		"is_breaking": false,
	}

static func mouse_angle_state(x_value: float, y_value: float, mouse_world: Vector2) -> Dictionary:
	var delta := mouse_world - Vector2(x_value, y_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_INPUT_HANDLER_MOUSE_ANGLE_STATE,
		"source": source_text.SOURCE_INPUT_HANDLER_SOURCE,
		"method": source_text.SOURCE_INPUT_HANDLER_MOUSE_ANGLE_METHOD,
		"return_expr": source_text.SOURCE_INPUT_HANDLER_MOUSE_ANGLE_EXPR,
		"x": x_value,
		"y": y_value,
		"mouse_world": mouse_world,
		"delta": delta,
		"mouse_angle": rad_to_deg(delta.angle()) if delta.angle() >= 0.0 else rad_to_deg(delta.angle()) + 360.0,
	}
