extends RefCounted
class_name SourceInputDefaults

const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const control_input_script := preload("res://src/game/ControlInput.gd")



static func ensure_input_map() -> void:
	control_input().install_input_map()


static func movement_vector() -> Vector2:
	var keyboard_axis: Vector2 = control_input().camera_vector()
	if keyboard_axis == Vector2.ZERO:
		return movement_vector_from_axes(Vector2.ZERO, Vector2.ZERO)
	return normalize_virtual_axis(keyboard_axis)


static func movement_vector_from_axes(touch_axis: Vector2, roblox_axis: Vector2) -> Vector2:
	var resolved_axis := touch_axis + roblox_axis
	return normalize_virtual_axis(resolved_axis)


static func touch_axis_from_drag(delta: Vector2) -> Vector2:
	return normalize_virtual_axis(delta / control_input().touch_move_pixels_per_axis())


static func normalize_virtual_axis(axis: Vector2) -> Vector2:
	if axis.length() < control_input().virtual_axis_deadzone():
		return Vector2.ZERO
	if axis.length() > 1.0:
		return axis.normalized()
	return axis


static func zoom_factor_from_event(event: InputEvent) -> float:
	if not (event is InputEventMouseButton):
		return 1.0
	var action: String = control_input().action_for_mouse_button(event.button_index)
	if action == control_input_script.CAMERA_ZOOM_IN_ACTION:
		return 1.0 + control_input().mouse_wheel_zoom_step()
	if action == control_input_script.CAMERA_ZOOM_OUT_ACTION:
		return 1.0 - control_input().mouse_wheel_zoom_step()
	return 1.0




static func boost_pressed() -> bool:
	return control_input().is_boost_pressed()


static func camera_pan_speed_per_second(boosted: bool, _source_tick_rate: float) -> float:
	if boosted:
		return control_input().camera_pan_boost_speed()
	return control_input().camera_pan_speed()


static func input_profiles() -> Dictionary:
	return control_input().platforms.duplicate(true)


static func runtime_summary() -> Dictionary:
	var control: RefCounted = control_input()
	return {
		"profiles": input_profiles(),
		"control_profile": control.runtime_summary(),
		"touch_pixels_per_axis": control.touch_move_pixels_per_axis(),
		"deadzone": control.virtual_axis_deadzone(),
	}

static func control_input() -> RefCounted:
	return control_input_script.new(source_ssot_catalog)
