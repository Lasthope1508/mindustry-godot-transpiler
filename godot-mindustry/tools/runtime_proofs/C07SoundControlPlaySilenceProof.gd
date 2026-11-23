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
	# SoundControl.play(@Nullable Music) (SoundControl.java:303-353)
	# is the fade state machine the caller drives every
	# frame: !shouldPlay() mutes the current track and
	# zeroes fade; the current track volume is updated
	# every frame from fade * musicvol / 100; a silenced
	# machine returns after that volume update; a null
	# current with a track starts it (looping, volume
	# fade = 0, play); the same track fades in (clamp
	# fade + delta / finTime); another track fades out
	# (clamp fade - delta / foutTime) and at fade <= 0.01
	# stops, clears current, marks silenced, and starts
	# the scheduled track when one is set. silence()
	# (:374-376) is play(null); keepSilent() (:197-199)
	# only sets the flag update() consumes. Music arrives
	# as its name String (the N2287 precedent); null
	# music / current arrive as explicit bool params (the
	# N2306 precedent). The playback calls are returned
	# as playback-command state, never executed -- NO
	# audio playback in this slice.
	# All expectations below are hand-computed from the
	# Java lines, not from the implementation, with
	# musicvol 80, Time.delta 12, finTime / foutTime 120:
	# muted with a current track mutes it (setVolume 0)
	# and zeroes fade; muted with no current track only
	# zeroes fade; no current + a track starts it
	# (setLooping, setVolume 0, play, fade 0); the same
	# track fades 0.2 -> 0.3 and still issues the volume
	# update from the old fade (0.16); the fade-in
	# clamps at 1.0 (0.95 + 1.0); another track fades
	# 0.5 -> 0.4 with only the volume update (0.4); a
	# fade-out from 0.05 hits 0, stops the old track and
	# starts the new one (setVolume 0.04, stop, setVolume
	# 0, setLooping, play); the same fade-out with no
	# scheduled track stops and marks silenced; a
	# silenced machine still issues the volume update
	# (0.4) and returns with fade unchanged; no current
	# and no music is a no-op (fade unchanged, no
	# commands); silence() fades the current track out
	# exactly like play(null) and stops it at zero;
	# keepSilent() reads true whatever the old flag was.
	var muted := source_sound_control_state.source_sound_control_play_state(true, "b", true, "a", 0.5, false, false, 80, 12.0, 120.0, 120.0)
	var muted_no_current := source_sound_control_state.source_sound_control_play_state(true, "b", false, "", 0.5, false, false, 80, 12.0, 120.0, 120.0)
	var new_track := source_sound_control_state.source_sound_control_play_state(true, "b", false, "", 0.3, false, true, 80, 12.0, 120.0, 120.0)
	var fade_in := source_sound_control_state.source_sound_control_play_state(true, "a", true, "a", 0.2, false, true, 80, 12.0, 120.0, 120.0)
	var fade_in_clamped := source_sound_control_state.source_sound_control_play_state(true, "a", true, "a", 0.95, false, true, 80, 120.0, 120.0, 120.0)
	var fade_out := source_sound_control_state.source_sound_control_play_state(true, "b", true, "a", 0.5, false, true, 80, 12.0, 120.0, 120.0)
	var fade_out_restart := source_sound_control_state.source_sound_control_play_state(true, "b", true, "a", 0.05, false, true, 80, 12.0, 120.0, 120.0)
	var fade_out_stop := source_sound_control_state.source_sound_control_play_state(false, "", true, "a", 0.05, false, true, 80, 12.0, 120.0, 120.0)
	var silenced := source_sound_control_state.source_sound_control_play_state(true, "b", true, "a", 0.5, true, true, 80, 12.0, 120.0, 120.0)
	var no_op := source_sound_control_state.source_sound_control_play_state(false, "", false, "", 0.3, false, true, 80, 12.0, 120.0, 120.0)
	var silence_fade := source_sound_control_state.source_sound_control_silence_state(true, "a", 0.5, false, true, 80, 12.0, 120.0, 120.0)
	var silence_stop := source_sound_control_state.source_sound_control_silence_state(true, "a", 0.05, false, true, 80, 12.0, 120.0, 120.0)
	var silence_no_current := source_sound_control_state.source_sound_control_silence_state(false, "", 0.3, false, true, 80, 12.0, 120.0, 120.0)
	var proof := {
		"play_muted_no_should_play": muted.get("current", "") == "a" and is_equal_approx(float(muted.get("fade", -1.0)), 0.0) and muted.get("silenced", true) == false and (muted.get("commands", []) as Array).size() == 1 and _cmd(muted.get("commands", []) as Array, 0, "a", "set_volume", 0.0),
		"play_muted_no_current": muted_no_current.get("current", "x") == null and is_equal_approx(float(muted_no_current.get("fade", -1.0)), 0.0) and muted_no_current.get("silenced", true) == false and (muted_no_current.get("commands", []) as Array).is_empty(),
		"play_starts_new_track": new_track.get("current", "") == "b" and is_equal_approx(float(new_track.get("fade", -1.0)), 0.0) and new_track.get("silenced", true) == false and (new_track.get("commands", []) as Array).size() == 3 and _cmd(new_track.get("commands", []) as Array, 0, "b", "set_looping", true) and _cmd(new_track.get("commands", []) as Array, 1, "b", "set_volume", 0.0) and _cmd_plain(new_track.get("commands", []) as Array, 2, "b", "play"),
		"play_fades_in_same_track": fade_in.get("current", "") == "a" and is_equal_approx(float(fade_in.get("fade", -1.0)), 0.3) and fade_in.get("silenced", true) == false and (fade_in.get("commands", []) as Array).size() == 1 and _cmd(fade_in.get("commands", []) as Array, 0, "a", "set_volume", 0.16),
		"play_fade_in_clamps_at_one": is_equal_approx(float(fade_in_clamped.get("fade", -1.0)), 1.0) and fade_in_clamped.get("current", "") == "a" and (fade_in_clamped.get("commands", []) as Array).size() == 1 and _cmd(fade_in_clamped.get("commands", []) as Array, 0, "a", "set_volume", 0.76),
		"play_fades_out_other_track": fade_out.get("current", "") == "a" and is_equal_approx(float(fade_out.get("fade", -1.0)), 0.4) and fade_out.get("silenced", true) == false and (fade_out.get("commands", []) as Array).size() == 1 and _cmd(fade_out.get("commands", []) as Array, 0, "a", "set_volume", 0.4),
		"play_fade_out_stops_and_starts_new": fade_out_restart.get("current", "") == "b" and is_equal_approx(float(fade_out_restart.get("fade", -1.0)), 0.0) and fade_out_restart.get("silenced", true) == false and (fade_out_restart.get("commands", []) as Array).size() == 5 and _cmd(fade_out_restart.get("commands", []) as Array, 0, "a", "set_volume", 0.04) and _cmd_plain(fade_out_restart.get("commands", []) as Array, 1, "a", "stop") and _cmd(fade_out_restart.get("commands", []) as Array, 2, "b", "set_volume", 0.0) and _cmd(fade_out_restart.get("commands", []) as Array, 3, "b", "set_looping", true) and _cmd_plain(fade_out_restart.get("commands", []) as Array, 4, "b", "play"),
		"play_fade_out_stops_no_new_track": fade_out_stop.get("current", "x") == null and is_equal_approx(float(fade_out_stop.get("fade", -1.0)), 0.0) and fade_out_stop.get("silenced", false) == true and (fade_out_stop.get("commands", []) as Array).size() == 2 and _cmd(fade_out_stop.get("commands", []) as Array, 0, "a", "set_volume", 0.04) and _cmd_plain(fade_out_stop.get("commands", []) as Array, 1, "a", "stop"),
		"play_silenced_returns_after_volume": silenced.get("current", "") == "a" and is_equal_approx(float(silenced.get("fade", -1.0)), 0.5) and silenced.get("silenced", false) == true and (silenced.get("commands", []) as Array).size() == 1 and _cmd(silenced.get("commands", []) as Array, 0, "a", "set_volume", 0.4),
		"play_no_current_no_music_keeps_state": no_op.get("current", "x") == null and is_equal_approx(float(no_op.get("fade", -1.0)), 0.3) and no_op.get("silenced", true) == false and (no_op.get("commands", []) as Array).is_empty(),
		"silence_fades_out_current": silence_fade.get("current", "") == "a" and is_equal_approx(float(silence_fade.get("fade", -1.0)), 0.4) and silence_fade.get("silenced", true) == false and (silence_fade.get("commands", []) as Array).size() == 1 and _cmd(silence_fade.get("commands", []) as Array, 0, "a", "set_volume", 0.4),
		"silence_stops_at_zero": silence_stop.get("current", "x") == null and is_equal_approx(float(silence_stop.get("fade", -1.0)), 0.0) and silence_stop.get("silenced", false) == true and (silence_stop.get("commands", []) as Array).size() == 2 and _cmd(silence_stop.get("commands", []) as Array, 0, "a", "set_volume", 0.04) and _cmd_plain(silence_stop.get("commands", []) as Array, 1, "a", "stop"),
		"silence_no_current_keeps_state": silence_no_current.get("current", "x") == null and is_equal_approx(float(silence_no_current.get("fade", -1.0)), 0.3) and silence_no_current.get("silenced", true) == false and (silence_no_current.get("commands", []) as Array).is_empty(),
		"keep_silent_sets_flag": source_sound_control_state.source_sound_control_keep_silent_state(false).get("keep_silent", false) == true,
		"keep_silent_overwrites_true": source_sound_control_state.source_sound_control_keep_silent_state(true).get("keep_silent", false) == true,
	}
	proof["matches"] = proof["play_muted_no_should_play"] and proof["play_muted_no_current"] and proof["play_starts_new_track"] and proof["play_fades_in_same_track"] and proof["play_fade_in_clamps_at_one"] and proof["play_fades_out_other_track"] and proof["play_fade_out_stops_and_starts_new"] and proof["play_fade_out_stops_no_new_track"] and proof["play_silenced_returns_after_volume"] and proof["play_no_current_no_music_keeps_state"] and proof["silence_fades_out_current"] and proof["silence_stops_at_zero"] and proof["silence_no_current_keeps_state"] and proof["keep_silent_sets_flag"] and proof["keep_silent_overwrites_true"]
	proof_state.write_proof("C07SoundControlPlaySilenceProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
