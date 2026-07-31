extends RefCounted
class_name SourceInputRuntime

const source_input_defaults := preload("res://src/game/SourceInputDefaults.gd")

var touch_move_axis := Vector2.ZERO
var roblox_move_axis := Vector2.ZERO


func set_touch_move_axis(axis: Vector2) -> void:
	touch_move_axis = source_input_defaults.normalize_virtual_axis(axis)


func set_roblox_move_axis(axis: Vector2) -> void:
	roblox_move_axis = source_input_defaults.normalize_virtual_axis(axis)


func set_virtual_input_axes(touch_x: float, touch_y: float, roblox_x: float, roblox_y: float) -> void:
	set_touch_move_axis(Vector2(touch_x, touch_y))
	set_roblox_move_axis(Vector2(roblox_x, roblox_y))


func movement_vector() -> Vector2:
	var resolved_movement := source_input_defaults.movement_vector() + source_input_defaults.movement_vector_from_axes(touch_move_axis, roblox_move_axis)
	return source_input_defaults.normalize_virtual_axis(resolved_movement)


func runtime_summary_state() -> Dictionary:
	var resolved_movement := movement_vector()
	return {
		"touch_axis": {"x": touch_move_axis.x, "y": touch_move_axis.y},
		"roblox_axis": {"x": roblox_move_axis.x, "y": roblox_move_axis.y},
		"resolved_movement": {"x": resolved_movement.x, "y": resolved_movement.y},
		"profiles": source_input_defaults.input_profiles(),
		"runtime_summary": source_input_defaults.runtime_summary(),
	}


func runtime_summary_with_source_owner(source_owner: String) -> Dictionary:
	var summary := runtime_summary_state()
	summary["source_owner"] = source_owner
	return summary
