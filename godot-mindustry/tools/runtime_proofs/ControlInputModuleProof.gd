extends Node

const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const control_input_binding_registry := preload("res://src/game/ControlInputBindingRegistry.gd")
const control_input_script := preload("res://src/game/ControlInput.gd")
const source_input_defaults := preload("res://src/game/SourceInputDefaults.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

const PROOF_LABEL := "CONTROL_INPUT_MODULE_PROOF"

func _profile_key_binding(control: RefCounted, canonical_action: String, canonical_key_label: String) -> Dictionary:
	var action_data: Dictionary = control.actions.get(canonical_action, {})
	for binding in control_input_binding_registry.keyboard_bindings(action_data):
		var key_label := control_input_binding_registry.binding_key_label(binding)
		if control_input_binding_registry.canonical_key_label(key_label) == canonical_key_label:
			return binding
	return {}

func _parse_profile_key_binding(binding: Dictionary, pressed: bool) -> void:
	if binding.is_empty():
		return
	var key_label := control_input_binding_registry.binding_key_label(binding)
	var event := control_input_binding_registry.key_event_for_label(key_label, pressed, bool(binding.get("shift", false)))
	Input.parse_input_event(event)

func _profile_key_axis(control: RefCounted, canonical_action: String, canonical_key_label: String) -> Vector2:
	var binding := _profile_key_binding(control, canonical_action, canonical_key_label)
	_parse_profile_key_binding(binding, true)
	Input.flush_buffered_events()
	var axis := source_input_defaults.movement_vector()
	_parse_profile_key_binding(binding, false)
	Input.flush_buffered_events()
	return axis

func _profile_key_drives_action(control: RefCounted, canonical_action: String, canonical_key_label: String) -> bool:
	var binding := _profile_key_binding(control, canonical_action, canonical_key_label)
	_parse_profile_key_binding(binding, true)
	Input.flush_buffered_events()
	var action_pressed := Input.is_action_pressed(control.action_name(canonical_action))
	_parse_profile_key_binding(binding, false)
	Input.flush_buffered_events()
	return action_pressed

func _profile_key_event_drives_action(control: RefCounted, canonical_action: String, canonical_key_label: String) -> bool:
	var binding := _profile_key_binding(control, canonical_action, canonical_key_label)
	if binding.is_empty():
		return false
	var key_label := control_input_binding_registry.binding_key_label(binding)
	var event := control_input_binding_registry.key_event_for_label(key_label, true, bool(binding.get("shift", false)))
	return event.is_action_pressed(control.action_name(canonical_action))

func _ready() -> void:
	var control := control_input_script.new(source_ssot_accessor_runtime_state)
	control.load_profile()
	control.install_input_map()
	var defaults_profiles: Dictionary = source_input_defaults.input_profiles()
	var defaults_summary: Dictionary = source_input_defaults.runtime_summary()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var camera_action := control.action_name(ControlInput.CAMERA_PAN_LEFT_ACTION)
	var boost_action := control.action_name(ControlInput.CAMERA_PAN_BOOST_ACTION)
	var zoom_in_action := control.action_name(ControlInput.CAMERA_ZOOM_IN_ACTION)
	var zoom_out_action := control.action_name(ControlInput.CAMERA_ZOOM_OUT_ACTION)
	var wheel_zoom_actions_match_profile := control.action_for_mouse_button(MOUSE_BUTTON_WHEEL_UP) == ControlInput.CAMERA_ZOOM_IN_ACTION and control.action_for_mouse_button(MOUSE_BUTTON_WHEEL_DOWN) == ControlInput.CAMERA_ZOOM_OUT_ACTION
	var left_action_data: Dictionary = control.actions.get(ControlInput.CAMERA_PAN_LEFT_ACTION, {})
	var left_key_signatures: Array = []
	for binding in control_input_binding_registry.keyboard_bindings(left_action_data):
		left_key_signatures.append(control_input_binding_registry.key_signature(control_input_binding_registry.binding_key_label(binding), bool(binding.get("shift", false))))
	var zoom_in_action_data: Dictionary = control.actions.get(ControlInput.CAMERA_ZOOM_IN_ACTION, {})
	var zoom_out_action_data: Dictionary = control.actions.get(ControlInput.CAMERA_ZOOM_OUT_ACTION, {})
	var binding_registry_key_labels_match_profile := left_key_signatures.has("a:plain") and left_key_signatures.has("left:plain")
	var binding_registry_mouse_buttons_match_profile := control_input_binding_registry.mouse_button_bindings(zoom_in_action_data).has("wheel_up") and control_input_binding_registry.mouse_button_bindings(zoom_out_action_data).has("wheel_down")
	var left_axis := _profile_key_axis(control, ControlInput.CAMERA_PAN_LEFT_ACTION, "a")
	var right_axis := _profile_key_axis(control, ControlInput.CAMERA_PAN_RIGHT_ACTION, "d")
	var up_axis := _profile_key_axis(control, ControlInput.CAMERA_PAN_UP_ACTION, "w")
	var down_axis := _profile_key_axis(control, ControlInput.CAMERA_PAN_DOWN_ACTION, "s")
	var wasd_key_events_drive_camera_actions := (
		_profile_key_drives_action(control, ControlInput.CAMERA_PAN_LEFT_ACTION, "a")
		and _profile_key_drives_action(control, ControlInput.CAMERA_PAN_RIGHT_ACTION, "d")
		and _profile_key_drives_action(control, ControlInput.CAMERA_PAN_UP_ACTION, "w")
		and _profile_key_drives_action(control, ControlInput.CAMERA_PAN_DOWN_ACTION, "s")
	)
	var wasd_events_match_camera_actions := (
		_profile_key_event_drives_action(control, ControlInput.CAMERA_PAN_LEFT_ACTION, "a")
		and _profile_key_event_drives_action(control, ControlInput.CAMERA_PAN_RIGHT_ACTION, "d")
		and _profile_key_event_drives_action(control, ControlInput.CAMERA_PAN_UP_ACTION, "w")
		and _profile_key_event_drives_action(control, ControlInput.CAMERA_PAN_DOWN_ACTION, "s")
	)
	var directional_key_events_resolve_axes := left_axis.x < 0.0 and right_axis.x > 0.0 and up_axis.y < 0.0 and down_axis.y > 0.0
	var profile_pan_speed := float(control.camera_settings.get("pan_speed_pixels_per_second", 0.0))
	var profile_pan_boost_speed := float(control.camera_settings.get("pan_boost_speed_pixels_per_second", 0.0))
	var defaults_pan_speed := source_input_defaults.camera_pan_speed_per_second(false, 1.0)
	var defaults_pan_boost_speed := source_input_defaults.camera_pan_speed_per_second(true, 1.0)
	var profile_mouse_wheel_zoom_step := float(control.camera_settings.get("mouse_wheel_zoom_step", 0.0))
	var virtual_axis: Dictionary = control.profile.get("virtual_axis", {})
	var virtual_axis_matches_profile := absf(control.touch_move_pixels_per_axis() - float(virtual_axis.get("touch_pixels_per_axis", 0.0))) < 0.001 and absf(control.virtual_axis_deadzone() - float(virtual_axis.get("deadzone", 0.0))) < 0.001
	var proof := {
		"module": PROOF_LABEL,
		"profile_loaded": not control.profile.is_empty(),
		"defaults_profiles_match": defaults_profiles == control.platforms,
		"defaults_summary_has_control_profile": defaults_summary.has("control_profile"),
		"pan_speed_matches_profile": absf(defaults_pan_speed - profile_pan_speed) < 0.001,
		"pan_boost_speed_matches_profile": absf(defaults_pan_boost_speed - profile_pan_boost_speed) < 0.001,
		"virtual_axis_matches_profile": virtual_axis_matches_profile,
		"mouse_wheel_zoom_step_matches_profile": absf(control.mouse_wheel_zoom_step() - profile_mouse_wheel_zoom_step) < 0.001,
		"wheel_zoom_actions_match_profile": wheel_zoom_actions_match_profile,
		"binding_registry_key_labels_match_profile": binding_registry_key_labels_match_profile,
		"binding_registry_mouse_buttons_match_profile": binding_registry_mouse_buttons_match_profile,
		"wasd_key_events_drive_camera_actions": wasd_key_events_drive_camera_actions,
		"wasd_events_match_camera_actions": wasd_events_match_camera_actions,
		"directional_key_events_resolve_axes": directional_key_events_resolve_axes,
		"camera_action_installed": InputMap.has_action(camera_action) and InputMap.action_get_events(camera_action).size() > 0,
		"boost_action_installed": InputMap.has_action(boost_action) and InputMap.action_get_events(boost_action).size() > 0,
		"zoom_in_action_installed": InputMap.has_action(zoom_in_action) and InputMap.action_get_events(zoom_in_action).size() > 0,
		"zoom_out_action_installed": InputMap.has_action(zoom_out_action) and InputMap.action_get_events(zoom_out_action).size() > 0,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["profile_loaded"] and proof["defaults_profiles_match"] and proof["defaults_summary_has_control_profile"] and proof["pan_speed_matches_profile"] and proof["pan_boost_speed_matches_profile"] and proof["virtual_axis_matches_profile"] and proof["mouse_wheel_zoom_step_matches_profile"] and proof["wheel_zoom_actions_match_profile"] and proof["binding_registry_key_labels_match_profile"] and proof["binding_registry_mouse_buttons_match_profile"] and proof["wasd_key_events_drive_camera_actions"] and proof["wasd_events_match_camera_actions"] and proof["directional_key_events_resolve_axes"] and proof["camera_action_installed"] and proof["boost_action_installed"] and proof["zoom_in_action_installed"] and proof["zoom_out_action_installed"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("ControlInputModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
