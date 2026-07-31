extends Node

const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const control_input_script := preload("res://src/game/ControlInput.gd")
const source_input_defaults := preload("res://src/game/SourceInputDefaults.gd")

func _ready() -> void:
	var control := control_input_script.new(source_ssot_catalog)
	control.load_profile()
	control.install_input_map()
	var defaults_profiles: Dictionary = source_input_defaults.input_profiles()
	var defaults_summary: Dictionary = source_input_defaults.runtime_summary()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var camera_action := control.action_name(ControlInput.CAMERA_PAN_LEFT_ACTION)
	var boost_action := control.action_name(ControlInput.CAMERA_PAN_BOOST_ACTION)
	var zoom_in_action := control.action_name(ControlInput.CAMERA_ZOOM_IN_ACTION)
	var zoom_out_action := control.action_name(ControlInput.CAMERA_ZOOM_OUT_ACTION)
	var wheel_zoom_actions_match_profile := control.action_for_mouse_button(MOUSE_BUTTON_WHEEL_UP) == ControlInput.CAMERA_ZOOM_IN_ACTION and control.action_for_mouse_button(MOUSE_BUTTON_WHEEL_DOWN) == ControlInput.CAMERA_ZOOM_OUT_ACTION
	var profile_pan_speed := float(control.camera_settings.get("pan_speed_pixels_per_second", 0.0))
	var profile_pan_boost_speed := float(control.camera_settings.get("pan_boost_speed_pixels_per_second", 0.0))
	var defaults_pan_speed := source_input_defaults.camera_pan_speed_per_second(false, 1.0)
	var defaults_pan_boost_speed := source_input_defaults.camera_pan_speed_per_second(true, 1.0)
	var profile_mouse_wheel_zoom_step := float(control.camera_settings.get("mouse_wheel_zoom_step", 0.0))
	var virtual_axis: Dictionary = control.profile.get("virtual_axis", {})
	var virtual_axis_matches_profile := absf(control.touch_move_pixels_per_axis() - float(virtual_axis.get("touch_pixels_per_axis", 0.0))) < 0.001 and absf(control.virtual_axis_deadzone() - float(virtual_axis.get("deadzone", 0.0))) < 0.001
	var proof := {
		"module": "ControlInput",
		"profile_loaded": not control.profile.is_empty(),
		"defaults_profiles_match": defaults_profiles == control.platforms,
		"defaults_summary_has_control_profile": defaults_summary.has("control_profile"),
		"pan_speed_matches_profile": absf(defaults_pan_speed - profile_pan_speed) < 0.001,
		"pan_boost_speed_matches_profile": absf(defaults_pan_boost_speed - profile_pan_boost_speed) < 0.001,
		"virtual_axis_matches_profile": virtual_axis_matches_profile,
		"mouse_wheel_zoom_step_matches_profile": absf(control.mouse_wheel_zoom_step() - profile_mouse_wheel_zoom_step) < 0.001,
		"wheel_zoom_actions_match_profile": wheel_zoom_actions_match_profile,
		"camera_action_installed": InputMap.has_action(camera_action) and InputMap.action_get_events(camera_action).size() > 0,
		"boost_action_installed": InputMap.has_action(boost_action) and InputMap.action_get_events(boost_action).size() > 0,
		"zoom_in_action_installed": InputMap.has_action(zoom_in_action) and InputMap.action_get_events(zoom_in_action).size() > 0,
		"zoom_out_action_installed": InputMap.has_action(zoom_out_action) and InputMap.action_get_events(zoom_out_action).size() > 0,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["profile_loaded"] and proof["defaults_profiles_match"] and proof["defaults_summary_has_control_profile"] and proof["pan_speed_matches_profile"] and proof["pan_boost_speed_matches_profile"] and proof["virtual_axis_matches_profile"] and proof["mouse_wheel_zoom_step_matches_profile"] and proof["wheel_zoom_actions_match_profile"] and proof["camera_action_installed"] and proof["boost_action_installed"] and proof["zoom_in_action_installed"] and proof["zoom_out_action_installed"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("CONTROL_INPUT_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/ControlInputModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
