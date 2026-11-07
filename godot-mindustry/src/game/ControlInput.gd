extends RefCounted
class_name ControlInput

const control_input_binding_registry := preload("res://src/game/ControlInputBindingRegistry.gd")
const source_control_input_source_text_state := preload("res://src/game/SourceControlInputSourceTextState.gd")

const MODULE_NAME := source_control_input_source_text_state.MODULE_NAME
const CAMERA_PAN_LEFT_ACTION := source_control_input_source_text_state.CAMERA_PAN_LEFT_ACTION
const CAMERA_PAN_RIGHT_ACTION := source_control_input_source_text_state.CAMERA_PAN_RIGHT_ACTION
const CAMERA_PAN_UP_ACTION := source_control_input_source_text_state.CAMERA_PAN_UP_ACTION
const CAMERA_PAN_DOWN_ACTION := source_control_input_source_text_state.CAMERA_PAN_DOWN_ACTION
const CAMERA_PAN_BOOST_ACTION := source_control_input_source_text_state.CAMERA_PAN_BOOST_ACTION
const CAMERA_ZOOM_IN_ACTION := source_control_input_source_text_state.CAMERA_ZOOM_IN_ACTION
const CAMERA_ZOOM_OUT_ACTION := source_control_input_source_text_state.CAMERA_ZOOM_OUT_ACTION
const BUILD_SLOT_PREFIX := source_control_input_source_text_state.BUILD_SLOT_PREFIX
const BUILD_SLOT_NEXT_ACTION := source_control_input_source_text_state.BUILD_SLOT_NEXT_ACTION
const BUILD_SLOT_PREVIOUS_ACTION := source_control_input_source_text_state.BUILD_SLOT_PREVIOUS_ACTION

var catalog: Variant
var profile: Dictionary = {}
var actions: Dictionary = {}
var platforms: Dictionary = {}
var camera_settings: Dictionary = {}
var virtual_axis_settings: Dictionary = {}
var key_action_map: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_profile()

func load_profile() -> void:
	profile = catalog.document_data(MODULE_NAME)
	if profile.is_empty():
		profile = {"actions": {}, "platforms": {}, "camera": {}, "hud_hint": ""}
	actions = profile.get("actions", {})
	platforms = profile.get("platforms", {})
	camera_settings = profile.get("camera", {})
	virtual_axis_settings = profile.get("virtual_axis", {})
	rebuild_key_action_map()

func install_input_map() -> void:
	for canonical_action in actions.keys():
		var action_data: Dictionary = actions.get(canonical_action, {})
		var godot_action := action_name(canonical_action)
		if not InputMap.has_action(godot_action):
			InputMap.add_action(godot_action)
		for binding in control_input_binding_registry.keyboard_bindings(action_data):
			var key_label := control_input_binding_registry.binding_key_label(binding)
			var keycode := control_input_binding_registry.keycode_for_label(key_label)
			if keycode == KEY_NONE:
				continue
			if input_action_has_key(godot_action, keycode, bool(binding.get("shift", false))):
				continue
			var event := InputEventKey.new()
			event.keycode = keycode
			event.physical_keycode = keycode
			event.shift_pressed = bool(binding.get("shift", false))
			InputMap.action_add_event(godot_action, event)
		for mouse_button in control_input_binding_registry.mouse_button_bindings(action_data):
			var button_index := control_input_binding_registry.mouse_button_for_label(mouse_button)
			if button_index == 0:
				continue
			if input_action_has_mouse_button(godot_action, button_index):
				continue
			var mouse_event := InputEventMouseButton.new()
			mouse_event.button_index = button_index as MouseButton
			InputMap.action_add_event(godot_action, mouse_event)

func rebuild_key_action_map() -> void:
	key_action_map.clear()
	for canonical_action in actions.keys():
		var action_data: Dictionary = actions.get(canonical_action, {})
		for binding in control_input_binding_registry.keyboard_bindings(action_data):
			var key_label := control_input_binding_registry.binding_key_label(binding)
			if key_label == "":
				continue
			key_action_map[control_input_binding_registry.key_signature(key_label, bool(binding.get("shift", false)))] = canonical_action

func action_name(canonical_action: String) -> String:
	var action_data: Dictionary = actions.get(canonical_action, {})
	return str(action_data.get("godot_action", canonical_action))

func input_action_has_key(godot_action: String, keycode: Key, shift_pressed: bool) -> bool:
	for existing_event in InputMap.action_get_events(godot_action):
		if existing_event is InputEventKey:
			var key_matches: bool = existing_event.keycode == keycode or existing_event.physical_keycode == keycode
			if key_matches and bool(existing_event.shift_pressed) == shift_pressed:
				return true
	return false

func input_action_has_mouse_button(godot_action: String, button_index: int) -> bool:
	for existing_event in InputMap.action_get_events(godot_action):
		if existing_event is InputEventMouseButton and existing_event.button_index == button_index:
			return true
	return false

func is_action_pressed(canonical_action: String) -> bool:
	var godot_action := action_name(canonical_action)
	if not InputMap.has_action(godot_action):
		return false
	return Input.is_action_pressed(godot_action)

func camera_vector() -> Vector2:
	var movement := Vector2.ZERO
	if is_action_pressed(CAMERA_PAN_LEFT_ACTION):
		movement.x -= 1.0
	if is_action_pressed(CAMERA_PAN_RIGHT_ACTION):
		movement.x += 1.0
	if is_action_pressed(CAMERA_PAN_UP_ACTION):
		movement.y -= 1.0
	if is_action_pressed(CAMERA_PAN_DOWN_ACTION):
		movement.y += 1.0
	return movement

func is_zoom_in_pressed() -> bool:
	return is_action_pressed(CAMERA_ZOOM_IN_ACTION)

func is_zoom_out_pressed() -> bool:
	return is_action_pressed(CAMERA_ZOOM_OUT_ACTION)

func camera_pan_speed() -> float:
	return float(camera_settings.get("pan_speed_pixels_per_second", 0.0))

func camera_pan_boost_speed() -> float:
	return float(camera_settings.get("pan_boost_speed_pixels_per_second", 900.0))

func keyboard_zoom_in_factor(delta: float) -> float:
	return 1.0 + (delta * float(camera_settings.get("keyboard_zoom_in_rate_per_second", 0.0)))

func keyboard_zoom_out_factor(delta: float) -> float:
	var rate := float(camera_settings.get("keyboard_zoom_out_rate_per_second", 0.0))
	var max_delta := float(camera_settings.get("keyboard_zoom_out_max_delta", 0.0))
	return 1.0 - min(delta * rate, max_delta)

func mouse_wheel_zoom_step() -> float:
	return float(camera_settings.get("mouse_wheel_zoom_step", 0.25))

func touch_move_pixels_per_axis() -> float:
	return float(virtual_axis_settings.get("touch_pixels_per_axis", 72.0))

func virtual_axis_deadzone() -> float:
	return float(virtual_axis_settings.get("deadzone", 0.1))

func action_for_key_event(event: InputEventKey) -> String:
	var key_labels := [
		OS.get_keycode_string(event.keycode),
		OS.get_keycode_string(event.physical_keycode),
	]
	for key_label in key_labels:
		var signature := control_input_binding_registry.key_signature(str(key_label), event.shift_pressed)
		if key_action_map.has(signature):
			return str(key_action_map.get(signature, ""))
	return ""

func action_for_mouse_button(button_index: int) -> String:
	var button_label := control_input_binding_registry.mouse_button_label(button_index)
	for canonical_action in actions.keys():
		var action_data: Dictionary = actions.get(canonical_action, {})
		if control_input_binding_registry.mouse_button_bindings(action_data).has(button_label):
			return str(canonical_action)
	return ""

func build_slot_for_action(canonical_action: String) -> int:
	if not canonical_action.begins_with(BUILD_SLOT_PREFIX):
		return -1
	var slot_text := canonical_action.substr(BUILD_SLOT_PREFIX.length())
	if not slot_text.is_valid_int():
		return -1
	return int(slot_text) - 1

func is_next_slot_action(canonical_action: String) -> bool:
	return canonical_action == BUILD_SLOT_NEXT_ACTION

func is_previous_slot_action(canonical_action: String) -> bool:
	return canonical_action == BUILD_SLOT_PREVIOUS_ACTION

func is_boost_pressed() -> bool:
	return is_action_pressed(CAMERA_PAN_BOOST_ACTION)

func is_primary_place_event(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return event.pressed and control_input_binding_registry.mouse_button_label(event.button_index) == "left"
	if event is InputEventScreenTouch:
		return event.pressed
	return false

func pointer_position(event: InputEvent) -> Vector2:
	if event is InputEventMouseButton:
		return event.position
	if event is InputEventScreenTouch:
		return event.position
	return Vector2.ZERO

func touch_camera_delta(event: InputEvent) -> Vector2:
	if event is InputEventScreenDrag:
		return -event.relative
	return Vector2.ZERO

func zoom_factor_from_gesture(event: InputEvent) -> float:
	if event is InputEventMagnifyGesture:
		return float(event.factor)
	return 1.0

func hud_hint() -> String:
	return str(profile.get("hud_hint", ""))

func control_action_runtime_summary() -> Dictionary:
	var action_summary: Dictionary = {}
	for canonical_action in actions.keys():
		var action_data: Dictionary = actions.get(canonical_action, {})
		action_summary[canonical_action] = action_data.duplicate(true)
	return action_summary

func runtime_summary() -> Dictionary:
	return {
		"module": MODULE_NAME,
		"loaded": not actions.is_empty(),
		"action_count": actions.size(),
		"platforms": platforms.keys(),
		"platform_details": platforms.duplicate(true),
		"actions": control_action_runtime_summary(),
		"camera": camera_settings.duplicate(),
		"hud_hint": hud_hint(),
	}
