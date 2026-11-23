extends Node

const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_sound_control_state := preload("res://src/game/SourceSoundControlState.gd")


func _cmd(commands: Array, index: int, track: String, action: String, value) -> bool:
	if commands.size() <= index:
		return false
	var entry: Dictionary = commands[index]
	if entry.get("track", "") != track or entry.get("action", "") != action:
		return false
	if value is float:
		return is_equal_approx(float(entry.get("value", -99999.0)), value)
	return entry.get("value", null) == value


func _cmd_plain(commands: Array, index: int, track: String, action: String) -> bool:
	if commands.size() <= index:
		return false
	var entry: Dictionary = commands[index]
	return entry.get("track", "") == track and entry.get("action", "") == action and not entry.has("value")


func _ready() -> void:
	# SoundControl.playRandom() (SoundControl.java:256-264)
	# picks a random track from the boss list when a boss
	# is present, else from the dark list when isDark(),
	# else from the ambient list, and starts it with
	# playOnce (N2345). The branch order is kept exactly
	# -- boss first, then dark, then ambient -- and the
	# selected list is returned as selected_music, so the
	# branch choice is observable. The random draw
	# (Seq.random(lastRandomPlayed)) is RNG: its outcome
	# arrives as the explicit picked_track param (the
	# N2315 precedent), never rolled here. Music arrives
	# as its name String (the N2287 precedent); null
	# music / current arrive as explicit bool params
	# (the N2306 precedent). The playback calls are
	# returned as playback-command state, never
	# executed -- NO audio playback in this slice.
	# All expectations below are hand-computed from the
	# Java lines, not from the implementation:
	# boss + pick "boss1" starts it (fade 1, last
	# "boss1", setVolume 1, setLooping false, play,
	# selected the boss list); dark + pick "game2"
	# starts it (selected the dark list); ambient +
	# pick "game1" starts it (selected the ambient
	# list); boss wins over dark when both are true
	# (selected the boss list, starts "boss2"); a
	# current track blocks the start (state unchanged,
	# no commands, selected still the boss list); a
	# null pick blocks the start (current null, fade
	# unchanged, selected the ambient list); a muted
	# gate blocks the start (selected the dark list);
	# a blocked start keeps the saved last track
	# ("old") and fade (0.7); an empty ambient list
	# with no pick is a no-op (selected empty); a
	# pick different from the last track ("boss2"
	# after "boss1") saves it as the new last track.
	var boss_list: Array = ["boss1", "boss2"]
	var dark_list: Array = ["game2", "game5"]
	var ambient_list: Array = ["game1", "game3"]
	var boss := source_sound_control_state.source_sound_control_play_random_state(true, false, boss_list, dark_list, ambient_list, true, "boss1", false, "", 0.3, false, "", true)
	var dark := source_sound_control_state.source_sound_control_play_random_state(false, true, boss_list, dark_list, ambient_list, true, "game2", false, "", 0.3, false, "", true)
	var ambient := source_sound_control_state.source_sound_control_play_random_state(false, false, boss_list, dark_list, ambient_list, true, "game1", false, "", 0.3, false, "", true)
	var boss_wins := source_sound_control_state.source_sound_control_play_random_state(true, true, boss_list, dark_list, ambient_list, true, "boss2", false, "", 0.3, true, "boss1", true)
	var blocked_current := source_sound_control_state.source_sound_control_play_random_state(true, false, boss_list, dark_list, ambient_list, true, "boss1", true, "a", 0.3, true, "old", true)
	var blocked_null := source_sound_control_state.source_sound_control_play_random_state(false, false, boss_list, dark_list, ambient_list, false, "", false, "", 0.3, false, "", true)
	var blocked_muted := source_sound_control_state.source_sound_control_play_random_state(false, true, boss_list, dark_list, ambient_list, true, "game5", false, "", 0.3, false, "", false)
	var blocked_last := source_sound_control_state.source_sound_control_play_random_state(true, false, boss_list, dark_list, ambient_list, true, "boss1", true, "a", 0.7, true, "old", true)
	var empty_no_pick := source_sound_control_state.source_sound_control_play_random_state(false, false, boss_list, dark_list, [], false, "", false, "", 0.3, false, "", true)
	var proof := {
		"boss_branch_selects_boss_list_and_starts": boss.get("current", "") == "boss1" and is_equal_approx(float(boss.get("fade", -1.0)), 1.0) and boss.get("last_random_played", "") == "boss1" and (boss.get("commands", []) as Array).size() == 3 and _cmd(boss.get("commands", []) as Array, 0, "boss1", "set_volume", 1.0) and _cmd(boss.get("commands", []) as Array, 1, "boss1", "set_looping", false) and _cmd_plain(boss.get("commands", []) as Array, 2, "boss1", "play") and (boss.get("selected_music", []) as Array) == ["boss1", "boss2"],
		"dark_branch_selects_dark_list_and_starts": dark.get("current", "") == "game2" and is_equal_approx(float(dark.get("fade", -1.0)), 1.0) and dark.get("last_random_played", "") == "game2" and (dark.get("commands", []) as Array).size() == 3 and _cmd(dark.get("commands", []) as Array, 0, "game2", "set_volume", 1.0) and _cmd(dark.get("commands", []) as Array, 1, "game2", "set_looping", false) and _cmd_plain(dark.get("commands", []) as Array, 2, "game2", "play") and (dark.get("selected_music", []) as Array) == ["game2", "game5"],
		"ambient_branch_selects_ambient_list_and_starts": ambient.get("current", "") == "game1" and is_equal_approx(float(ambient.get("fade", -1.0)), 1.0) and ambient.get("last_random_played", "") == "game1" and (ambient.get("commands", []) as Array).size() == 3 and _cmd(ambient.get("commands", []) as Array, 0, "game1", "set_volume", 1.0) and _cmd(ambient.get("commands", []) as Array, 1, "game1", "set_looping", false) and _cmd_plain(ambient.get("commands", []) as Array, 2, "game1", "play") and (ambient.get("selected_music", []) as Array) == ["game1", "game3"],
		"boss_branch_wins_over_dark": boss_wins.get("current", "") == "boss2" and is_equal_approx(float(boss_wins.get("fade", -1.0)), 1.0) and boss_wins.get("last_random_played", "") == "boss2" and (boss_wins.get("commands", []) as Array).size() == 3 and (boss_wins.get("selected_music", []) as Array) == ["boss1", "boss2"],
		"random_blocked_by_current": blocked_current.get("current", "") == "a" and is_equal_approx(float(blocked_current.get("fade", -1.0)), 0.3) and blocked_current.get("last_random_played", "") == "old" and (blocked_current.get("commands", []) as Array).is_empty() and (blocked_current.get("selected_music", []) as Array) == ["boss1", "boss2"],
		"random_blocked_by_null_pick": blocked_null.get("current", "x") == null and is_equal_approx(float(blocked_null.get("fade", -1.0)), 0.3) and blocked_null.get("last_random_played", "x") == null and (blocked_null.get("commands", []) as Array).is_empty() and (blocked_null.get("selected_music", []) as Array) == ["game1", "game3"],
		"random_blocked_when_muted": blocked_muted.get("current", "x") == null and is_equal_approx(float(blocked_muted.get("fade", -1.0)), 0.3) and blocked_muted.get("last_random_played", "x") == null and (blocked_muted.get("commands", []) as Array).is_empty() and (blocked_muted.get("selected_music", []) as Array) == ["game2", "game5"],
		"random_keeps_last_when_blocked": blocked_last.get("current", "") == "a" and is_equal_approx(float(blocked_last.get("fade", -1.0)), 0.7) and blocked_last.get("last_random_played", "") == "old" and (blocked_last.get("commands", []) as Array).is_empty(),
		"random_empty_list_no_pick": empty_no_pick.get("current", "x") == null and is_equal_approx(float(empty_no_pick.get("fade", -1.0)), 0.3) and empty_no_pick.get("last_random_played", "x") == null and (empty_no_pick.get("commands", []) as Array).is_empty() and (empty_no_pick.get("selected_music", []) as Array).is_empty(),
		"random_pick_excludes_last": boss_wins.get("last_random_played", "") == "boss2" and boss_wins.get("current", "") == "boss2" and is_equal_approx(float(boss_wins.get("fade", -1.0)), 1.0),
	}
	proof["matches"] = proof["boss_branch_selects_boss_list_and_starts"] and proof["dark_branch_selects_dark_list_and_starts"] and proof["ambient_branch_selects_ambient_list_and_starts"] and proof["boss_branch_wins_over_dark"] and proof["random_blocked_by_current"] and proof["random_blocked_by_null_pick"] and proof["random_blocked_when_muted"] and proof["random_keeps_last_when_blocked"] and proof["random_empty_list_no_pick"] and proof["random_pick_excludes_last"]
	proof_state.write_proof("C07SoundControlPlayRandomProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
