extends Node

const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_sound_control_state := preload("res://src/game/SourceSoundControlState.gd")


func _ready() -> void:
	# SoundControl.reload() (SoundControl.java:75-91)
	# resets current / fade, rebuilds the three music
	# lists from the Musics fields in exactly this order,
	# assigns the uiBus to every Sound asset whose file
	# sits in the "ui" folder, and fires a
	# MusicRegisterEvent (evidence only -- the event
	# system is NOT ported). current / fade arrive as
	# explicit params and are overwritten unconditionally
	# (the keepSilent precedent, N2336); the asset
	# enumeration + file-name resolution arrive folded
	# into one Dictionary param (sound name -> parent
	# folder name) and the `equals("ui")` check IS
	# ported, case-sensitive, in order. Music arrives as
	# its name String (the N2287 precedent). NO audio
	# playback in this slice.
	# All expectations below are hand-computed from the
	# Java lines, not from the implementation: reload
	# with a current track ("game2", fade 0.7) and an
	# empty registry still clears current, zeroes fade,
	# and sets the three lists; a mixed registry assigns
	# only the "ui" sounds to the bus, in order
	# ("uiClick", "uiBack"); a registry with no "ui"
	# folder assigns nothing; an empty registry assigns
	# nothing; no current track still reads null with
	# fade 0; "UI" / "Ui" parents do NOT match the
	# case-sensitive "ui" check; the input Dictionary
	# is never mutated.
	var base := source_sound_control_state.source_sound_control_reload_state(true, "game2", 0.7, {})
	var mixed := source_sound_control_state.source_sound_control_reload_state(false, "", 0.0, {"uiClick": "ui", "shoot": "shoot", "uiBack": "ui", "explosion": "explosions"})
	var none_ui := source_sound_control_state.source_sound_control_reload_state(false, "", 0.0, {"shoot": "shoot", "land": "environment"})
	var no_current := source_sound_control_state.source_sound_control_reload_state(false, "", 0.3, {})
	var case_sensitive := source_sound_control_state.source_sound_control_reload_state(false, "", 0.0, {"weird": "UI", "also": "Ui"})
	var inputs := {"a": "ui", "b": "block"}
	var inputs_before: Dictionary = inputs.duplicate()
	var _mutated := source_sound_control_state.source_sound_control_reload_state(false, "", 0.0, inputs)
	var proof := {
		"reload_resets_current_and_fade": base.get("current", "x") == null and is_equal_approx(float(base.get("fade", -1.0)), 0.0),
		"reload_sets_ambient_music": (base.get("ambient_music", []) as Array) == ["game1", "game3", "game6", "game8", "game9", "fine"],
		"reload_sets_dark_music": (base.get("dark_music", []) as Array) == ["game2", "game5", "game7", "game4"],
		"reload_sets_boss_music": (base.get("boss_music", []) as Array) == ["boss1", "boss2", "game2", "game5"],
		"reload_assigns_ui_folder_sounds": (mixed.get("ui_bus_sounds", []) as Array) == ["uiClick", "uiBack"],
		"reload_ignores_other_folders": (none_ui.get("ui_bus_sounds", ["x"]) as Array).is_empty(),
		"reload_empty_sound_registry": (base.get("ui_bus_sounds", ["x"]) as Array).is_empty(),
		"reload_no_current_still_null": no_current.get("current", "x") == null and is_equal_approx(float(no_current.get("fade", -1.0)), 0.0),
		"reload_ui_match_is_case_sensitive": (case_sensitive.get("ui_bus_sounds", ["x"]) as Array).is_empty(),
		"reload_does_not_mutate_inputs": inputs == inputs_before,
	}
	proof["matches"] = proof["reload_resets_current_and_fade"] and proof["reload_sets_ambient_music"] and proof["reload_sets_dark_music"] and proof["reload_sets_boss_music"] and proof["reload_assigns_ui_folder_sounds"] and proof["reload_ignores_other_folders"] and proof["reload_empty_sound_registry"] and proof["reload_no_current_still_null"] and proof["reload_ui_match_is_case_sensitive"] and proof["reload_does_not_mutate_inputs"]
	proof_state.write_proof("C07SoundControlReloadProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
