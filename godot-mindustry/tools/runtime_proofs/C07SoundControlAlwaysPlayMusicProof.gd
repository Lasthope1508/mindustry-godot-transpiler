extends Node

const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_sound_control_state := preload("res://src/game/SourceSoundControlState.gd")


func _ready() -> void:
	# SoundControl.alwaysPlayMusic() (SoundControl.java:266-268)
	# only gates on three bool flags, ORed together: the
	# rules flag, the "alwaysmusic" settings flag, and the
	# planet flag (null-safe: false when there is no planet).
	# There is no updateLoops key here -- the mixer (C,
	# N2304) waits for B -- and no audio playback key: this
	# is a pure gate, it plays nothing. All expectations
	# below are hand-computed from the Java lines, not from
	# the implementation: any single true flag reads true,
	# all false reads false, and all true reads true.
	var proof := {
		"always_play_rules_true": bool(source_sound_control_state.source_sound_control_always_play_music_state(true, false, false).get("always_play_music", false)),
		"always_play_setting_true": bool(source_sound_control_state.source_sound_control_always_play_music_state(false, true, false).get("always_play_music", false)),
		"always_play_planet_true": bool(source_sound_control_state.source_sound_control_always_play_music_state(false, false, true).get("always_play_music", false)),
		"always_play_all_false": not bool(source_sound_control_state.source_sound_control_always_play_music_state(false, false, false).get("always_play_music", true)),
		"always_play_all_true": bool(source_sound_control_state.source_sound_control_always_play_music_state(true, true, true).get("always_play_music", false)),
		"always_play_two_true": bool(source_sound_control_state.source_sound_control_always_play_music_state(false, true, true).get("always_play_music", false)),
	}
	proof["matches"] = proof["always_play_rules_true"] and proof["always_play_setting_true"] and proof["always_play_planet_true"] and proof["always_play_all_false"] and proof["always_play_all_true"] and proof["always_play_two_true"]
	proof_state.write_proof("C07SoundControlAlwaysPlayMusicProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
