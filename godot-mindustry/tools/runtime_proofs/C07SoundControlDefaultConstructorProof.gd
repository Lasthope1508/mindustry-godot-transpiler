extends Node

const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_sound_control_state := preload("res://src/game/SourceSoundControlState.gd")

var _reload_calls: int = 0


func _fake_reload() -> void:
	_reload_calls += 1


func _fake_boss_once(_has_music: bool, music: String, _has_current: bool, _current: String, _fade: float, _has_last_random_played: bool, _last_random_played: String, _should_play: bool) -> Dictionary:
	return {"current": music, "fade": 1.0, "last_random_played": music, "commands": [{"track": music, "action": "play"}]}


func _fake_random(_has_current: bool, _current: String, _fade: float, _has_last_random_played: bool, _last_random_played: String) -> Dictionary:
	return {"current": "game1", "fade": 1.0, "last_random_played": "game1", "commands": [{"track": "game1", "action": "play"}], "selected_music": "game1"}


func _ctor(over: Dictionary) -> Dictionary:
	var d: Dictionary = {
		"reload_handler": Callable(self, "_fake_reload"),
		"wave_delay_ticks": 600.0, "wave_is_boss": false, "wave_chance_roll": false,
		"music_wave_chance": 0.46, "play_boss_once": Callable(self, "_fake_boss_once"),
		"play_random": Callable(self, "_fake_random"), "filter": null,
		"has_current": false, "current": "", "fade": 0.0,
		"has_last_random_played": false, "last_random_played": "",
		"should_play": true, "has_boss_music": true, "boss_music": "boss1",
		"now_millis": 5000,
	}
	for k in over:
		d[k] = over[k]
	return source_sound_control_state.source_sound_control_default_constructor_state(d["reload_handler"], d["wave_delay_ticks"], d["wave_is_boss"], d["wave_chance_roll"], d["music_wave_chance"], d["play_boss_once"], d["play_random"], d["filter"], d["has_current"], d["current"], d["fade"], d["has_last_random_played"], d["last_random_played"], d["should_play"], d["has_boss_music"], d["boss_music"], d["now_millis"])


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
	# SoundControl() (SoundControl.java:45-68) registers
	# three event subscriptions and calls setupFilters()
	# once. All expectations below are hand-computed from
	# the Java lines, not from the implementation: the
	# ctor registers ClientLoadEvent (reload), WaveEvent
	# (delayed boss/chance leg) and ResetEvent (lastPlayed
	# + sound-bus stop/play); the reload handler is fired
	# once in the model; the wave leg plays the boss track
	# when the wave is a boss wave, plays a random track
	# when it is not and the chance roll hit, and plays
	# nothing when neither leg fires; the reset leg writes
	# lastPlayed = now_millis; setupFilters() runs once
	# and its commands (set_filter, set_filter_param) come
	# first, before the wave-leg and reset-leg commands;
	# the reset leg stops then plays the sound bus, in
	# that order; the result has exactly fourteen keys.
	# NO audio playback in this slice: bus and playback
	# calls are returned as command state, never executed;
	# playback belongs to updateLoops (N2304, held
	# waiting for B).
	var base := _ctor({})
	var base_commands: Array = base.get("commands", [])
	var boss := _ctor({"wave_is_boss": true, "wave_delay_ticks": 480.0})
	var boss_commands: Array = boss.get("commands", [])
	var random := _ctor({"wave_chance_roll": true, "wave_delay_ticks": 900.0})
	var skipped := _ctor({})
	var proof := {
		"ctor_registers_client_load": base.get("client_load_event", "") == "ClientLoadEvent" and base.get("client_load_subscribed", false) == true and base.get("reload_called", false) == true and _reload_calls >= 1,
		"ctor_registers_wave": base.get("wave_event", "") == "WaveEvent" and base.get("wave_subscribed", false) == true and is_equal_approx(float(base.get("wave_delay_ticks", -1.0)), 600.0) and is_equal_approx(float(base.get("music_wave_chance", -1.0)), 0.46),
		"ctor_wave_boss_plays_boss_music": boss.get("wave_action", "") == "play_boss_once" and boss.get("wave_music", "") == "boss1" and _has_command(boss_commands, "play", "boss1") and is_equal_approx(float(boss.get("wave_delay_ticks", -1.0)), 480.0),
		"ctor_wave_chance_plays_random": random.get("wave_action", "") == "play_random" and random.get("wave_music", "") == "game1" and _has_command(random.get("commands", []), "play", "game1") and is_equal_approx(float(random.get("wave_delay_ticks", -1.0)), 900.0),
		"ctor_wave_skips_when_no_chance": skipped.get("wave_action", "") == "none" and skipped.get("wave_music", "") == "" and not _has_command(skipped.get("commands", []), "play"),
		"ctor_registers_reset": base.get("reset_event", "") == "ResetEvent" and base.get("reset_subscribed", false) == true and base.get("last_played", -1) == 5000,
		"ctor_setup_filters_called": base.get("setup_filters_called", false) == true and _has_command(base_commands, "set_filter") and _has_command(base_commands, "set_filter_param") and _command_index(base_commands, "set_filter") == 0 and _command_index(base_commands, "set_filter_param") == 1,
		"ctor_reset_stops_and_plays_bus": _has_command(base_commands, "sound_bus_stop") and _has_command(base_commands, "sound_bus_play") and _command_index(base_commands, "sound_bus_stop") < _command_index(base_commands, "sound_bus_play") and _command_index(base_commands, "sound_bus_play") == base_commands.size() - 1,
		"ctor_returns_only_fourteen_keys": base.size() == 14 and boss.size() == 14 and random.size() == 14,
	}
	proof["matches"] = proof["ctor_registers_client_load"] and proof["ctor_registers_wave"] and proof["ctor_wave_boss_plays_boss_music"] and proof["ctor_wave_chance_plays_random"] and proof["ctor_wave_skips_when_no_chance"] and proof["ctor_registers_reset"] and proof["ctor_setup_filters_called"] and proof["ctor_reset_stops_and_plays_bus"] and proof["ctor_returns_only_fourteen_keys"]
	proof_state.write_proof("C07SoundControlDefaultConstructorProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
