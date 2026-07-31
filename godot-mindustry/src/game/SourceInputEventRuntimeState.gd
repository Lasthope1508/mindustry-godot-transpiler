extends RefCounted
class_name SourceInputEventRuntimeState

const source_input_defaults := preload("res://src/game/SourceInputDefaults.gd")

static func handle_unhandled_input(game: Object, event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var canonical_action: String = source_input_defaults.control_input().action_for_key_event(event)
		if canonical_action != "":
			game.call("select_build_slot_action", canonical_action)
	elif event is InputEventScreenDrag:
		game.call("set_touch_move_axis", source_input_defaults.touch_axis_from_drag(event.relative))
	elif event is InputEventScreenTouch and not event.pressed:
		game.call("set_touch_move_axis", Vector2.ZERO)
	elif event is InputEventMouseButton and event.pressed:
		var zoom_factor := source_input_defaults.zoom_factor_from_event(event)
		if zoom_factor != 1.0:
			_apply_camera_zoom(game, zoom_factor)
		elif is_primary_place_event(event):
			_place_from_pointer_event(game, event.position)
	elif is_primary_place_event(event):
		_place_from_pointer_event(game, pointer_position(event))

static func pointer_world_position_state(game: Object, screen_position: Vector2) -> Dictionary:
	var click_world_state = game.call("source_input_viewport_screen_to_world_state", screen_position)
	return click_world_state if typeof(click_world_state) == TYPE_DICTIONARY else {"x": screen_position.x, "y": screen_position.y}

static func is_primary_place_event(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if event is InputEventScreenTouch:
		return event.pressed
	return false

static func pointer_position(event: InputEvent) -> Vector2:
	if event is InputEventMouseButton:
		return event.position
	if event is InputEventScreenTouch:
		return event.position
	return Vector2.ZERO

static func _apply_camera_zoom(game: Object, zoom_factor: float) -> void:
	var camera = game.get("camera")
	if camera == null:
		return
	var zoom_state = game.call("source_input_viewport_camera_zoom_state", camera.zoom, zoom_factor)
	if typeof(zoom_state) != TYPE_DICTIONARY:
		return
	camera.zoom = Vector2(float(zoom_state.get("x", camera.zoom.x)), float(zoom_state.get("y", camera.zoom.y)))

static func _place_from_pointer_event(game: Object, screen_position: Vector2) -> void:
	var click_world_state := pointer_world_position_state(game, screen_position)
	game.call("place_selected_block_at_world", Vector2(float(click_world_state.get("x", screen_position.x)), float(click_world_state.get("y", screen_position.y))))
