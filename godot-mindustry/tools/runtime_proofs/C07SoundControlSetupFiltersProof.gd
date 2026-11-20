extends Node

const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_sound_control_state := preload("res://src/game/SourceSoundControlState.gd")


func _ready() -> void:
	# SoundControl.setupFilters() (SoundControl.java:70-73)
	# installs the SoundControl filter on sound-bus slot
	# 0 and sets its wet param to 0. The filter field
	# (SoundControl.java:39, `protected AudioFilter
	# filter = new BiquadFilter(){{ set(0, 500, 1); }};`)
	# arrives as an explicit opaque param -- the driver
	# owns the live filter object; this slice never
	# builds one. `Filters.paramWet` is the int
	# constant 0 (arc Filters.java:6, `public static
	# final int paramWet = 0;`), so the param in the
	# second command is 0. NO audio playback in this
	# slice: both sound-bus calls are returned as
	# command state, never executed. All expectations
	# below are hand-computed from the Java lines, not
	# from the implementation: the call issues exactly
	# two commands in Java order (set_filter first,
	# set_filter_param second); the first echoes the
	# passed filter on slot 0; the second sets param 0
	# to 0.0 on slot 0; a second call with a different
	# filter echoes that filter unchanged; the result
	# has exactly one key.
	var biquad := {"kind": "biquad", "band": 0, "frequency": 500, "q": 1}
	var other := {"kind": "biquad", "band": 1, "frequency": 1000, "q": 2}
	var first := source_sound_control_state.source_sound_control_setup_filters_state(biquad)
	var second := source_sound_control_state.source_sound_control_setup_filters_state(other)
	var first_commands: Array = first.get("commands", [])
	var second_commands: Array = second.get("commands", [])
	var proof := {
		"setup_filters_issues_two_commands": first_commands.size() == 2,
		"setup_filters_set_filter_first": first_commands.size() == 2 and (first_commands[0] as Dictionary).get("action", "") == "set_filter" and int((first_commands[0] as Dictionary).get("slot", -1)) == 0 and (first_commands[0] as Dictionary).get("filter", {}) == biquad,
		"setup_filters_set_filter_param_second": first_commands.size() == 2 and (first_commands[1] as Dictionary).get("action", "") == "set_filter_param" and int((first_commands[1] as Dictionary).get("slot", -1)) == 0 and int((first_commands[1] as Dictionary).get("param", -1)) == 0 and is_equal_approx(float((first_commands[1] as Dictionary).get("value", -1.0)), 0.0),
		"setup_filters_filter_echoes_param": second_commands.size() == 2 and (second_commands[0] as Dictionary).get("filter", {}) == other and (second_commands[1] as Dictionary).get("action", "") == "set_filter_param",
		"setup_filters_returns_only_one_key": first.size() == 1,
	}
	proof["matches"] = proof["setup_filters_issues_two_commands"] and proof["setup_filters_set_filter_first"] and proof["setup_filters_set_filter_param_second"] and proof["setup_filters_filter_echoes_param"] and proof["setup_filters_returns_only_one_key"]
	proof_state.write_proof("C07SoundControlSetupFiltersProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
