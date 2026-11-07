extends "res://src/game/SourceWorldGridPortBridge.gd"

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_input_runtime := preload("res://src/game/SourceInputRuntime.gd")
const source_input_event_runtime_state := preload("res://src/game/SourceInputEventRuntimeState.gd")
const source_input_viewport_runtime_state := preload("res://src/game/SourceInputViewportRuntimeState.gd")

var input_runtime := source_input_runtime.new()

func _unhandled_input(event: InputEvent) -> void:
	source_input_event_runtime_state.handle_unhandled_input(self, event)

func set_touch_move_axis(axis: Vector2) -> void:
	input_runtime.set_touch_move_axis(axis)

func set_roblox_move_axis(axis: Vector2) -> void:
	input_runtime.set_roblox_move_axis(axis)

func set_virtual_input_axes(touch_x: float, touch_y: float, roblox_x: float, roblox_y: float) -> void:
	input_runtime.set_virtual_input_axes(touch_x, touch_y, roblox_x, roblox_y)

func source_input_runtime_summary_state() -> Dictionary:
	return input_runtime.runtime_summary_with_source_owner(source_runtime_owner_registry.PORT_GAME_SOURCE_INPUT_RUNTIME_SUMMARY_STATE)

func source_input_viewport_camera_pan_delta(movement: Vector2, boosted: bool, delta: float) -> Vector2:
	return source_input_viewport_runtime_state.game_camera_pan_delta(self, movement, boosted, delta)

func source_input_viewport_camera_zoom_state(current_zoom: Vector2, zoom_factor: float) -> Dictionary:
	return source_input_viewport_runtime_state.camera_zoom_state(current_zoom, zoom_factor)

func source_input_viewport_fit_camera_state(viewport_size: Vector2) -> Dictionary:
	return source_input_viewport_runtime_state.viewport_fit_camera_runtime_state(self, viewport_size)

func source_input_viewport_viewport_world_cells(viewport_size: Vector2) -> Vector2i:
	return source_input_viewport_runtime_state.viewport_world_cells(viewport_size)

func source_input_viewport_screen_to_world_state(screen_position: Vector2) -> Dictionary:
	return source_input_viewport_runtime_state.screen_to_world_runtime_state(self, screen_position)

func source_input_viewport_clamped_camera_position_state(proposed_position: Vector2, viewport_size: Vector2) -> Dictionary:
	return source_input_viewport_runtime_state.clamped_camera_position_runtime_state(self, proposed_position, viewport_size)

func apply_world_viewport_fit() -> void:
	source_input_viewport_runtime_state.apply_world_viewport_fit(self)

func world_viewport_fit_runtime_state() -> Dictionary:
	return source_input_viewport_runtime_state.world_viewport_fit_runtime_state(self)

func update_camera(delta: float) -> void:
	source_input_viewport_runtime_state.update_camera(self, delta)
