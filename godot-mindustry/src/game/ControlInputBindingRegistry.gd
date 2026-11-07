extends RefCounted
class_name ControlInputBindingRegistry

static func keyboard_bindings(action_data: Dictionary) -> Array:
	var result: Array = []
	for platform_name in action_data.keys():
		var platform_bindings: Variant = action_data.get(platform_name, {})
		if typeof(platform_bindings) != TYPE_DICTIONARY:
			continue
		var keys: Array = platform_bindings.get("keys", [])
		for key_binding in keys:
			var binding := normalize_key_binding(key_binding)
			if not result.has(binding):
				result.append(binding)
	return result

static func normalize_key_binding(key_binding: Variant) -> Dictionary:
	if typeof(key_binding) == TYPE_DICTIONARY:
		return {
			"key": str(key_binding.get("key", "")),
			"shift": bool(key_binding.get("shift", false)),
		}
	return {"key": str(key_binding), "shift": false}

static func binding_key_label(binding: Dictionary) -> String:
	return str(binding.get("key", ""))

static func mouse_button_bindings(action_data: Dictionary) -> Array:
	var result: Array = []
	for platform_name in action_data.keys():
		var platform_bindings: Variant = action_data.get(platform_name, {})
		if typeof(platform_bindings) != TYPE_DICTIONARY:
			continue
		var buttons: Array = platform_bindings.get("mouse_buttons", [])
		for button_label in buttons:
			var canonical_label := canonical_mouse_button_label(str(button_label))
			if canonical_label != "" and not result.has(canonical_label):
				result.append(canonical_label)
	return result

static func key_signature(key_label: String, shift_pressed: bool) -> String:
	return "%s:%s" % [canonical_key_label(key_label), "shift" if shift_pressed else "plain"]

static func canonical_key_label(key_label: String) -> String:
	var label := key_label.strip_edges().to_lower()
	match label:
		"arrowleft":
			return "left"
		"arrowright":
			return "right"
		"arrowup":
			return "up"
		"arrowdown":
			return "down"
		_:
			return label

static func keycode_for_label(key_label: String) -> Key:
	match canonical_key_label(key_label):
		"left":
			return KEY_LEFT
		"right":
			return KEY_RIGHT
		"up":
			return KEY_UP
		"down":
			return KEY_DOWN
		_:
			return OS.find_keycode_from_string(key_label)

static func key_event_for_label(key_label: String, pressed: bool, shift_pressed: bool = false) -> InputEventKey:
	var keycode := keycode_for_label(key_label)
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.shift_pressed = shift_pressed
	event.pressed = pressed
	return event

static func canonical_mouse_button_label(button_label: String) -> String:
	return button_label.strip_edges().to_lower()

static func mouse_button_for_label(button_label: String) -> int:
	match canonical_mouse_button_label(button_label):
		"left":
			return MOUSE_BUTTON_LEFT
		"right":
			return MOUSE_BUTTON_RIGHT
		"middle":
			return MOUSE_BUTTON_MIDDLE
		"wheel_up":
			return MOUSE_BUTTON_WHEEL_UP
		"wheel_down":
			return MOUSE_BUTTON_WHEEL_DOWN
		_:
			return 0

static func mouse_button_label(button_index: int) -> String:
	match button_index:
		MOUSE_BUTTON_LEFT:
			return "left"
		MOUSE_BUTTON_RIGHT:
			return "right"
		MOUSE_BUTTON_MIDDLE:
			return "middle"
		MOUSE_BUTTON_WHEEL_UP:
			return "wheel_up"
		MOUSE_BUTTON_WHEEL_DOWN:
			return "wheel_down"
		_:
			return str(button_index)
