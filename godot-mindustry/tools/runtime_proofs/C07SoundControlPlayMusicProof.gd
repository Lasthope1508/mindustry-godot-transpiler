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
	# SoundControl.playMusic(@Nullable Music, boolean) (SoundControl.java:243-249)
	# stops the current track when interrupt is set, then
	# delegates to playOnce. SoundControl.playOnce(Music)
	# (SoundControl.java:355-367) starts a track once and
	# only once: the guard `current != null || music ==
	# null || !shouldPlay()` returns with state untouched;
	# otherwise lastRandomPlayed = music, fade = 1f,
	# current = music, and the track starts with
	# setVolume(1f), setLooping(false), play() -- in
	# exactly that order. Music arrives as its name String
	# (the N2287 precedent); null music / current arrive
	# as explicit bool params (the N2306 precedent).
	# The playback calls are returned as playback-command
	# state, never executed -- NO audio playback in this
	# slice.
	# All expectations below are hand-computed from the
	# Java lines, not from the implementation:
	# playOnce with no current track starts "b" (fade 1,
	# last "b", setVolume 1, setLooping false, play); a
	# current track blocks the start (state unchanged, no
	# commands); a null music blocks the start; a muted
	# gate (shouldPlay false) blocks the start; a blocked
	# start keeps the saved last track ("old") and fade
	# (0.7); playMusic with interrupt stops "a" first
	# (stop, then the playOnce start of "b", fade 1, last
	# "b"); without interrupt a current track blocks
	# playMusic too (state unchanged, no commands);
	# interrupt with no current track starts "b" with no
	# stop command; interrupt with a null music stops "a"
	# only (current null, fade 0.3, last "old"); interrupt
	# with no current and no music is a no-op; a muted
	# gate blocks the playMusic start even with interrupt.
	var start := source_sound_control_state.source_sound_control_play_once_state(true, "b", false, "", 0.3, false, "", true)
	var blocked_current := source_sound_control_state.source_sound_control_play_once_state(true, "b", true, "a", 0.3, true, "old", true)
	var blocked_null := source_sound_control_state.source_sound_control_play_once_state(false, "", false, "", 0.3, false, "", true)
	var blocked_muted := source_sound_control_state.source_sound_control_play_once_state(true, "b", false, "", 0.3, false, "", false)
	var blocked_last := source_sound_control_state.source_sound_control_play_once_state(true, "b", true, "a", 0.7, true, "old", true)
	var interrupt_start := source_sound_control_state.source_sound_control_play_music_state(true, "b", true, true, "a", 0.3, false, "", true)
	var no_interrupt_blocked := source_sound_control_state.source_sound_control_play_music_state(true, "b", false, true, "a", 0.3, true, "old", true)
	var interrupt_no_current := source_sound_control_state.source_sound_control_play_music_state(true, "b", true, false, "", 0.3, false, "", true)
	var interrupt_null_stops := source_sound_control_state.source_sound_control_play_music_state(false, "", true, true, "a", 0.3, true, "old", true)
	var interrupt_noop := source_sound_control_state.source_sound_control_play_music_state(false, "", true, false, "", 0.3, false, "", true)
	var muted_blocked := source_sound_control_state.source_sound_control_play_music_state(true, "b", true, false, "", 0.3, false, "", false)
	var proof := {
		"play_once_starts_new_track": start.get("current", "") == "b" and is_equal_approx(float(start.get("fade", -1.0)), 1.0) and start.get("last_random_played", "") == "b" and (start.get("commands", []) as Array).size() == 3 and _cmd(start.get("commands", []) as Array, 0, "b", "set_volume", 1.0) and _cmd(start.get("commands", []) as Array, 1, "b", "set_looping", false) and _cmd_plain(start.get("commands", []) as Array, 2, "b", "play"),
		"play_once_blocked_by_current": blocked_current.get("current", "") == "a" and is_equal_approx(float(blocked_current.get("fade", -1.0)), 0.3) and blocked_current.get("last_random_played", "") == "old" and (blocked_current.get("commands", []) as Array).is_empty(),
		"play_once_blocked_by_null_music": blocked_null.get("current", "x") == null and is_equal_approx(float(blocked_null.get("fade", -1.0)), 0.3) and blocked_null.get("last_random_played", "x") == null and (blocked_null.get("commands", []) as Array).is_empty(),
		"play_once_blocked_when_muted": blocked_muted.get("current", "x") == null and is_equal_approx(float(blocked_muted.get("fade", -1.0)), 0.3) and blocked_muted.get("last_random_played", "x") == null and (blocked_muted.get("commands", []) as Array).is_empty(),
		"play_once_keeps_last_when_blocked": blocked_last.get("current", "") == "a" and is_equal_approx(float(blocked_last.get("fade", -1.0)), 0.7) and blocked_last.get("last_random_played", "") == "old" and (blocked_last.get("commands", []) as Array).is_empty(),
		"play_music_interrupt_stops_and_starts": interrupt_start.get("current", "") == "b" and is_equal_approx(float(interrupt_start.get("fade", -1.0)), 1.0) and interrupt_start.get("last_random_played", "") == "b" and (interrupt_start.get("commands", []) as Array).size() == 4 and _cmd_plain(interrupt_start.get("commands", []) as Array, 0, "a", "stop") and _cmd(interrupt_start.get("commands", []) as Array, 1, "b", "set_volume", 1.0) and _cmd(interrupt_start.get("commands", []) as Array, 2, "b", "set_looping", false) and _cmd_plain(interrupt_start.get("commands", []) as Array, 3, "b", "play"),
		"play_music_no_interrupt_blocked_by_current": no_interrupt_blocked.get("current", "") == "a" and is_equal_approx(float(no_interrupt_blocked.get("fade", -1.0)), 0.3) and no_interrupt_blocked.get("last_random_played", "") == "old" and (no_interrupt_blocked.get("commands", []) as Array).is_empty(),
		"play_music_interrupt_no_current_starts": interrupt_no_current.get("current", "") == "b" and is_equal_approx(float(interrupt_no_current.get("fade", -1.0)), 1.0) and interrupt_no_current.get("last_random_played", "") == "b" and (interrupt_no_current.get("commands", []) as Array).size() == 3 and _cmd(interrupt_no_current.get("commands", []) as Array, 0, "b", "set_volume", 1.0) and _cmd(interrupt_no_current.get("commands", []) as Array, 1, "b", "set_looping", false) and _cmd_plain(interrupt_no_current.get("commands", []) as Array, 2, "b", "play"),
		"play_music_interrupt_null_music_stops_only": interrupt_null_stops.get("current", "x") == null and is_equal_approx(float(interrupt_null_stops.get("fade", -1.0)), 0.3) and interrupt_null_stops.get("last_random_played", "") == "old" and (interrupt_null_stops.get("commands", []) as Array).size() == 1 and _cmd_plain(interrupt_null_stops.get("commands", []) as Array, 0, "a", "stop"),
		"play_music_interrupt_no_current_null_music_noop": interrupt_noop.get("current", "x") == null and is_equal_approx(float(interrupt_noop.get("fade", -1.0)), 0.3) and interrupt_noop.get("last_random_played", "x") == null and (interrupt_noop.get("commands", []) as Array).is_empty(),
		"play_music_muted_blocks_start": muted_blocked.get("current", "x") == null and is_equal_approx(float(muted_blocked.get("fade", -1.0)), 0.3) and muted_blocked.get("last_random_played", "x") == null and (muted_blocked.get("commands", []) as Array).is_empty(),
		"play_music_interrupt_keeps_last_when_no_music": interrupt_null_stops.get("last_random_played", "") == "old" and is_equal_approx(float(interrupt_null_stops.get("fade", -1.0)), 0.3) and interrupt_null_stops.get("current", "x") == null,
	}
	proof["matches"] = proof["play_once_starts_new_track"] and proof["play_once_blocked_by_current"] and proof["play_once_blocked_by_null_music"] and proof["play_once_blocked_when_muted"] and proof["play_once_keeps_last_when_blocked"] and proof["play_music_interrupt_stops_and_starts"] and proof["play_music_no_interrupt_blocked_by_current"] and proof["play_music_interrupt_no_current_starts"] and proof["play_music_interrupt_null_music_stops_only"] and proof["play_music_interrupt_no_current_null_music_noop"] and proof["play_music_muted_blocks_start"] and proof["play_music_interrupt_keeps_last_when_no_music"]
	proof_state.write_proof("C07SoundControlPlayMusicProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
