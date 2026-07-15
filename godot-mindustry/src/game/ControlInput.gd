extends RefCounted
class_name ControlInput

const MODULE_NAME := "control_profile"

var catalog: Variant
var profile: Dictionary = {}
var actions: Dictionary = {}
var platforms: Dictionary = {}
var key_action_map: Dictionary = {}

func _init(source_catalog: Variant) -> void:
	catalog = source_catalog
	load_profile()

func load_profile() -> void:
	var document: Dictionary = catalog.load_document(MODULE_NAME)
	if not bool(document.get("loaded", false)):
		profile = {"actions": {}, "platforms": {}, "hud_hint": ""}
		actions = {}
		platforms = {}
		return
	profile = document.get("data", {})
	actions = profile.get("actions", {})
	platforms = profile.get("platforms", {})
	rebuild_key_action_map()

func install_input_map() -> void:
	for canonical_action in actions.keys():
		var action_data: Dictionary = actions.get(canonical_action, {})
		var godot_action := action_name(canonical_action)
		if not InputMap.has_action(godot_action):
			InputMap.add_action(godot_action)
		for binding in keyboard_bindings(action_data):
			var key_label := binding_key_label(binding)
			var keycode := keycode_for_label(key_label)
			if keycode == KEY_NONE:
				continue
			if input_action_has_key(godot_action, keycode, bool(binding.get("shift", false))):
				continue
			var event := InputEventKey.new()
			event.keycode = keycode
			event.physical_keycode = keycode
			event.shift_pressed = bool(binding.get("shift", false))
			InputMap.action_add_event(godot_action, event)

func rebuild_key_action_map() -> void:
	key_action_map.clear()
	for canonical_action in actions.keys():
		var action_data: Dictionary = actions.get(canonical_action, {})
		for binding in keyboard_bindings(action_data):
			var key_label := binding_key_label(binding)
			if key_label == "":
				continue
			key_action_map[key_signature(key_label, bool(binding.get("shift", false)))] = canonical_action

func keyboard_bindings(action_data: Dictionary) -> Array:
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

func normalize_key_binding(key_binding: Variant) -> Dictionary:
	if typeof(key_binding) == TYPE_DICTIONARY:
		return {
			"key": str(key_binding.get("key", "")),
			"shift": bool(key_binding.get("shift", false)),
		}
	return {"key": str(key_binding), "shift": false}

func binding_key_label(binding: Dictionary) -> String:
	return str(binding.get("key", ""))

func key_signature(key_label: String, shift_pressed: bool) -> String:
	return "%s:%s" % [canonical_key_label(key_label), "shift" if shift_pressed else "plain"]

func canonical_key_label(key_label: String) -> String:
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

func keycode_for_label(key_label: String) -> Key:
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

func is_action_pressed(canonical_action: String) -> bool:
	return Input.is_action_pressed(action_name(canonical_action))

func camera_vector() -> Vector2:
	var movement := Vector2.ZERO
	if is_action_pressed("camera.pan.left"):
		movement.x -= 1.0
	if is_action_pressed("camera.pan.right"):
		movement.x += 1.0
	if is_action_pressed("camera.pan.up"):
		movement.y -= 1.0
	if is_action_pressed("camera.pan.down"):
		movement.y += 1.0
	return movement

func is_zoom_in_pressed() -> bool:
	return is_action_pressed("camera.zoom.in")

func is_zoom_out_pressed() -> bool:
	return is_action_pressed("camera.zoom.out")

func action_for_key_event(event: InputEventKey) -> String:
	var key_labels := [
		OS.get_keycode_string(event.keycode),
		OS.get_keycode_string(event.physical_keycode),
	]
	for key_label in key_labels:
		var signature := key_signature(str(key_label), event.shift_pressed)
		if key_action_map.has(signature):
			return str(key_action_map.get(signature, ""))
	return ""

func build_slot_for_action(canonical_action: String) -> int:
	var prefix := "build.slot."
	if not canonical_action.begins_with(prefix):
		return -1
	var slot_text := canonical_action.substr(prefix.length())
	if not slot_text.is_valid_int():
		return -1
	return int(slot_text) - 1

func is_next_slot_action(canonical_action: String) -> bool:
	return canonical_action == "build.slot.next"

func is_previous_slot_action(canonical_action: String) -> bool:
	return canonical_action == "build.slot.previous"

func is_primary_place_event(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return event.pressed and mouse_button_label(event.button_index) == "left"
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

func mouse_button_label(button_index: int) -> String:
	match button_index:
		MOUSE_BUTTON_LEFT:
			return "left"
		MOUSE_BUTTON_RIGHT:
			return "right"
		MOUSE_BUTTON_MIDDLE:
			return "middle"
		_:
			return str(button_index)

func hud_hint() -> String:
	return str(profile.get("hud_hint", ""))

func runtime_summary() -> Dictionary:
	return {
		"module": MODULE_NAME,
		"loaded": not actions.is_empty(),
		"action_count": actions.size(),
		"platforms": platforms.keys(),
		"hud_hint": hud_hint(),
	}
