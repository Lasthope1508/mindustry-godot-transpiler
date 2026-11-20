extends Node

const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_sound_control_state := preload("res://src/game/SourceSoundControlState.gd")


func _ready() -> void:
	# SoundControl.stop() (SoundControl.java:118-127)
	# sets silenced, then stops the current track (if
	# any), clears it and zeroes fade. This is a
	# SEPARATE public method from silence() /
	# keepSilent() (N2336 own those) -- stop() is the
	# one update() :165-167 calls when keepSilent is
	# set. Music arrives as its name String (the N2287
	# precedent); has_current folds the null check
	# (the N2306 precedent). NO audio playback in this
	# slice: the stop is returned as one command
	# (`track`, `action` -- the N2345 shape), never
	# executed. All expectations below are hand-computed
	# from the Java lines, not from the implementation:
	# silenced is always true (even with no track);
	# a playing track issues exactly one stop command
	# for that track; stopping clears current and
	# zeroes fade; with no track there is no command,
	# current stays null and fade passes through
	# unchanged; the result has exactly five keys.
	var playing := source_sound_control_state.source_sound_control_stop_state(true, "game1", 0.7)
	var idle := source_sound_control_state.source_sound_control_stop_state(false, "", 0.4)
	var playing_commands: Array = playing.get("commands", [])
	var idle_commands: Array = idle.get("commands", [])
	var proof := {
		"stop_silences_always": playing.get("silenced", false) == true and idle.get("silenced", false) == true,
		"stop_stops_current_track": playing.get("stopped", false) == true and playing_commands.size() == 1 and (playing_commands[0] as Dictionary).get("track", "") == "game1" and (playing_commands[0] as Dictionary).get("action", "") == "stop",
		"stop_clears_current_and_fade": playing.get("current", "x") == null and is_equal_approx(float(playing.get("fade", -1.0)), 0.0),
		"stop_no_track_noop": idle.get("stopped", true) == false and idle_commands.is_empty() and idle.get("current", "x") == null and is_equal_approx(float(idle.get("fade", -1.0)), 0.4),
		"stop_returns_only_five_keys": playing.size() == 5 and idle.size() == 5,
	}
	proof["matches"] = proof["stop_silences_always"] and proof["stop_stops_current_track"] and proof["stop_clears_current_and_fade"] and proof["stop_no_track_noop"] and proof["stop_returns_only_five_keys"]
	proof_state.write_proof("C07SoundControlStopProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
