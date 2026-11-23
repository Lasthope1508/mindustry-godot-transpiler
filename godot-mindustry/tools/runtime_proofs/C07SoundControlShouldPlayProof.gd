extends Node

const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_sound_control_state := preload("res://src/game/SourceSoundControlState.gd")


func _ready() -> void:
	# SoundControl.shouldPlay() (SoundControl.java:369-371)
	# only gates on the music volume setting, and
	# SoundControl.isPlaying() (SoundControl.java:251-253)
	# only gates on the current track: there is no
	# updateLoops key here -- the mixer (C, N2264) waits
	# for B -- and no audio playback key: these are pure
	# gates, they play nothing. All expectations below are
	# hand-computed from the Java lines, not from the
	# implementation: shouldPlay is strict (> 0), so a
	# positive volume reads true and zero or negative
	# reads false; isPlaying short-circuits on the null
	# check, so no current track reads false whatever the
	# playing flag says.
	var proof := {
		"should_play_positive": bool(source_sound_control_state.source_sound_control_should_play_state(100).get("should_play", false)),
		"should_play_zero": not bool(source_sound_control_state.source_sound_control_should_play_state(0).get("should_play", true)),
		"should_play_negative": not bool(source_sound_control_state.source_sound_control_should_play_state(-1).get("should_play", true)),
		"is_playing_current_playing": bool(source_sound_control_state.source_sound_control_is_playing_state(true, true).get("is_playing", false)),
		"is_playing_no_current": not bool(source_sound_control_state.source_sound_control_is_playing_state(false, true).get("is_playing", true)),
		"is_playing_current_stopped": not bool(source_sound_control_state.source_sound_control_is_playing_state(true, false).get("is_playing", true)),
	}
	proof["matches"] = proof["should_play_positive"] and proof["should_play_zero"] and proof["should_play_negative"] and proof["is_playing_current_playing"] and proof["is_playing_no_current"] and proof["is_playing_current_stopped"]
	proof_state.write_proof("C07SoundControlShouldPlayProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
