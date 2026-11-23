extends Node

const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_sound_control_state := preload("res://src/game/SourceSoundControlState.gd")


func _noop_loops() -> void:
	pass


func _fake_random(_has_current: bool, _current: String, _fade: float, _has_last_random_played: bool, _last_random_played: String) -> Dictionary:
	return {"current": "game1", "fade": 1.0, "last_random_played": "game1", "commands": [{"track": "game1", "action": "play"}], "selected_music": "game1"}


func _update(over: Dictionary) -> Dictionary:
	var d: Dictionary = {
		"is_game": true, "has_dialog": false, "has_current": false, "current": "",
		"current_is_playing": false, "timer_tick": false, "was_playing": true,
		"filter": null, "is_paused": false, "keep_silent": false, "silenced": false,
		"is_menu": false, "planet_shown": false, "has_planet_launch_music": false,
		"planet_launch_music": "", "editor_shown": false, "rules_editor": false,
		"always_play_music": false, "last_played": 0, "now_millis": 0,
		"music_interval": 10800.0, "chance_roll": false, "fade": 0.0,
		"should_play": true, "music_vol": 100, "time_delta": 0.016,
		"fin_time": 120.0, "fout_time": 120.0, "has_last_random_played": false,
		"last_random_played": "", "play_random": Callable(self, "_fake_random"),
		"update_loops": Callable(self, "_noop_loops"),
	}
	for k in over:
		d[k] = over[k]
	return source_sound_control_state.source_sound_control_update_state(d["is_game"], d["has_dialog"], d["has_current"], d["current"], d["current_is_playing"], d["timer_tick"], d["was_playing"], d["filter"], d["is_paused"], d["keep_silent"], d["silenced"], d["is_menu"], d["planet_shown"], d["has_planet_launch_music"], d["planet_launch_music"], d["editor_shown"], d["rules_editor"], d["always_play_music"], d["last_played"], d["now_millis"], d["music_interval"], d["chance_roll"], d["fade"], d["should_play"], d["music_vol"], d["time_delta"], d["fin_time"], d["fout_time"], d["has_last_random_played"], d["last_random_played"], d["play_random"], d["update_loops"])


func _has_command(commands: Array, action: String, track: String = "") -> bool:
	for c in commands:
		var cd := c as Dictionary
		if cd.get("action", "") == action and (track == "" or cd.get("track", "") == track):
			return true
	return false


func _command_index(commands: Array, action: String) -> int:
	for i in commands.size():
		if (commands[i] as Dictionary).get("action", "") == action:
			return i
	return -1


func _ready() -> void:
	# SoundControl.update() (SoundControl.java:128-195)
	# is the per-frame dispatcher. All expectations
	# below are hand-computed from the Java lines, not
	# from the implementation: paused is isGame() and
	# hasDialog(); playing is isGame(); a finished
	# track (current present but not playing) is
	# cleared with fade zeroed; the 30-tick poll issues
	# one fade_filter_param command with value 1 when
	# paused, 0 otherwise, and nothing when the timer
	# does not tick; the playing transition plays the
	# sound bus + setupFilters when starting and stops
	# the sound bus, replays the music bus and replays
	# the sound bus when stopping; setPaused carries
	# isPaused; keepSilent stops the current track and
	# clears keepSilent; the menu leg plays the planet
	# launch music / editor / menu music; the editor
	# rules leg plays editor music; ingame silences
	# then plays a random track when alwaysPlayMusic
	# (without touching lastPlayed) or when the
	# interval elapsed and the chance roll hit (updating
	# lastPlayed to now); updateLoops() is called every
	# frame; the result has exactly eleven keys. NO
	# audio playback in this slice: bus and playback
	# calls are returned as command state, never
	# executed; playback belongs to updateLoops (N2304,
	# held waiting for B).
	var paused_case := _update({"has_dialog": true, "timer_tick": true, "is_menu": true})
	var paused_commands: Array = paused_case.get("commands", [])
	var no_tick := _update({"has_dialog": true, "timer_tick": false, "is_menu": true})
	var finished := _update({"has_current": true, "current": "game1", "current_is_playing": false, "fade": 0.5})
	var bus_start := _update({"was_playing": false, "is_paused": true})
	var bus_start_commands: Array = bus_start.get("commands", [])
	var bus_stop := _update({"is_game": false, "was_playing": true})
	var bus_stop_commands: Array = bus_stop.get("commands", [])
	var silent := _update({"keep_silent": true, "has_current": true, "current": "game1", "current_is_playing": true, "fade": 0.7})
	var silent_commands: Array = silent.get("commands", [])
	var planet := _update({"is_menu": true, "planet_shown": true, "has_planet_launch_music": true, "planet_launch_music": "game1"})
	var planet_commands: Array = planet.get("commands", [])
	var editor_menu := _update({"is_menu": true, "editor_shown": true})
	var menu := _update({"is_menu": true})
	var rules_editor := _update({"rules_editor": true})
	var ingame_random := _update({"always_play_music": true})
	var interval_random := _update({"last_played": 0, "now_millis": 200000, "chance_roll": true})
	var interval_recent := _update({"last_played": 0, "now_millis": 100000, "chance_roll": true})
	var proof := {
		"update_paused_when_dialog": paused_case.get("paused", false) == true and paused_case.get("playing", false) == true,
		"update_playing_when_game": bus_start.get("playing", false) == true and bus_stop.get("playing", true) == false,
		"update_clears_finished_track": finished.get("current", "x") == null and is_equal_approx(float(finished.get("fade", -1.0)), 0.0),
		"update_fade_filter_poll": _has_command(paused_commands, "fade_filter_param") and (paused_commands[_command_index(paused_commands, "fade_filter_param")] as Dictionary).get("value", -1.0) == 1.0 and not _has_command(no_tick.get("commands", []), "fade_filter_param"),
		"update_bus_plays_on_start": _has_command(bus_start_commands, "sound_bus_play") and _has_command(bus_start_commands, "set_filter") and bus_start.get("was_playing", false) == true,
		"update_bus_stops_on_pause": _command_index(bus_stop_commands, "sound_bus_stop") >= 0 and _command_index(bus_stop_commands, "sound_bus_stop") < _command_index(bus_stop_commands, "music_bus_play") and _command_index(bus_stop_commands, "music_bus_play") < _command_index(bus_stop_commands, "sound_bus_play") and bus_stop.get("was_playing", true) == false,
		"update_set_paused_command": _has_command(bus_start_commands, "set_paused") and (bus_start_commands[_command_index(bus_start_commands, "set_paused")] as Dictionary).get("paused", false) == true,
		"update_keep_silent_stops": silent.get("keep_silent", true) == false and silent.get("silenced", false) == true and silent.get("current", "x") == null and is_equal_approx(float(silent.get("fade", -1.0)), 0.0) and _has_command(silent_commands, "stop", "game1"),
		"update_menu_plays_planet_music": planet.get("current", "") == "game1" and _has_command(planet_commands, "play", "game1"),
		"update_menu_plays_editor_music": editor_menu.get("current", "") == "editor",
		"update_menu_plays_menu_music": menu.get("current", "") == "menu",
		"update_editor_plays_editor_music": rules_editor.get("current", "") == "editor",
		"update_ingame_silence_then_random": ingame_random.get("current", "") == "game1" and ingame_random.get("last_played", -1) == 0 and ingame_random.get("last_random_played", "") == "game1",
		"update_interval_random_updates_last_played": interval_random.get("last_played", -1) == 200000 and interval_random.get("current", "") == "game1",
		"update_interval_skipped_when_recent": interval_recent.get("current", "x") == null and interval_recent.get("last_played", -1) == 0,
		"update_calls_update_loops": ingame_random.get("update_loops_called", false) == true and bus_start.get("update_loops_called", false) == true,
		"update_returns_only_eleven_keys": paused_case.size() == 11 and bus_start.size() == 11 and ingame_random.size() == 11,
	}
	proof["matches"] = proof["update_paused_when_dialog"] and proof["update_playing_when_game"] and proof["update_clears_finished_track"] and proof["update_fade_filter_poll"] and proof["update_bus_plays_on_start"] and proof["update_bus_stops_on_pause"] and proof["update_set_paused_command"] and proof["update_keep_silent_stops"] and proof["update_menu_plays_planet_music"] and proof["update_menu_plays_editor_music"] and proof["update_menu_plays_menu_music"] and proof["update_editor_plays_editor_music"] and proof["update_ingame_silence_then_random"] and proof["update_interval_random_updates_last_played"] and proof["update_interval_skipped_when_recent"] and proof["update_calls_update_loops"] and proof["update_returns_only_eleven_keys"]
	proof_state.write_proof("C07SoundControlUpdateProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
