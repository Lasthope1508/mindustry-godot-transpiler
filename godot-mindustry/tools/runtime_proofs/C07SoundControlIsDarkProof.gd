extends Node

const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_sound_control_state := preload("res://src/game/SourceSoundControlState.gd")


func _ready() -> void:
	# SoundControl.isDark() (SoundControl.java:286-299)
	# the dark-music gate: a damaged core (hasCore() and
	# healthf() strictly below 0.85f) reads dark at once,
	# otherwise the wave chance roll decides, then the
	# enemy chance roll. The two Mathf.chance outcomes
	# arrive as explicit bool params, so this function is
	# pure and never rolls RNG itself. All expectations
	# below are hand-computed from the Java lines, not from
	# the implementation: damaged core reads true even
	# with both rolls false; a true wave roll reads true
	# with an intact core; a true enemy roll reads true
	# with an intact core and a false wave roll; all
	# false reads false; an intact core with both rolls
	# false reads false; exactly 0.85f falls through
	# (strict <) and reads false with both rolls false;
	# no core reads false with both rolls false whatever
	# the health value says; all true reads true.
	var proof := {
		"is_dark_core_damaged": bool(source_sound_control_state.source_sound_control_is_dark_state(true, 0.5, false, false).get("is_dark", false)),
		"is_dark_wave_roll": bool(source_sound_control_state.source_sound_control_is_dark_state(true, 1.0, true, false).get("is_dark", false)),
		"is_dark_enemy_roll": bool(source_sound_control_state.source_sound_control_is_dark_state(true, 1.0, false, true).get("is_dark", false)),
		"is_dark_all_false": not bool(source_sound_control_state.source_sound_control_is_dark_state(false, 0.0, false, false).get("is_dark", true)),
		"is_dark_core_intact": not bool(source_sound_control_state.source_sound_control_is_dark_state(true, 1.0, false, false).get("is_dark", true)),
		"is_dark_core_boundary": not bool(source_sound_control_state.source_sound_control_is_dark_state(true, 0.85, false, false).get("is_dark", true)),
		"is_dark_no_core": not bool(source_sound_control_state.source_sound_control_is_dark_state(false, 1.0, false, false).get("is_dark", true)),
		"is_dark_all_true": bool(source_sound_control_state.source_sound_control_is_dark_state(true, 0.5, true, true).get("is_dark", false)),
	}
	proof["matches"] = proof["is_dark_core_damaged"] and proof["is_dark_wave_roll"] and proof["is_dark_enemy_roll"] and proof["is_dark_all_false"] and proof["is_dark_core_intact"] and proof["is_dark_core_boundary"] and proof["is_dark_no_core"] and proof["is_dark_all_true"]
	proof_state.write_proof("C07SoundControlIsDarkProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
