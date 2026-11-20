extends Node

const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_sound_control_state := preload("res://src/game/SourceSoundControlState.gd")


func _ready() -> void:
	# SoundControl.findMusic(String) (SoundControl.java:387-395)
	# is the static music lookup MusicContainer.get() reads
	# (MusicContainer.java:18-24, lazy
	# `SoundControl.findMusic(name)`, null when the asset is
	# not found): a null name reads null at once, else the
	# first of the five Core.assets.getOrNull branches that
	# hits -- name, name + ".ogg", name + ".mp3", "music/" +
	# name + ".ogg", "music/" + name + ".mp3" -- in exactly
	# that order, else null. The Core.assets lookup arrives
	# as an explicit Dictionary param (the asset registry:
	# lookup key -> resolved asset name, a missing key reads
	# null, exactly getOrNull): NO audio is loaded in this
	# slice. Music arrives as its resolved name String (the
	# N2287 precedent); the null name arrives as an explicit
	# bool param (the N2306 precedent -- GDScript typed
	# String params cannot take null), an unset name passed
	# as "" with has_name false.
	# All expectations below are hand-computed from the Java
	# lines, not from the implementation: a null name reads
	# null; "track" with only "track" registered reads
	# "track"; with only "track.ogg" registered reads
	# "track.ogg"; with only "track.mp3" reads "track.mp3";
	# with only "music/track.ogg" reads "music/track.ogg";
	# with only "music/track.mp3" reads "music/track.mp3";
	# with nothing registered reads null; with both
	# "track.ogg" and "track.mp3" registered reads
	# "track.ogg" (.ogg before .mp3, NOT "fixed"); with
	# "track.mp3" and "music/track.ogg" registered reads
	# "track.mp3" (plain before music/); with "track" and
	# "track.ogg" registered reads "track" (exact first);
	# with "music/track.ogg" and "music/track.mp3"
	# registered reads "music/track.ogg"; with "track.ogg"
	# and "music/track.ogg" registered reads "track.ogg";
	# and the returned value is the registry value -- the
	# resolved name -- not the lookup key ("track"
	# registered as "music/track.ogg" reads
	# "music/track.ogg").
	var proof := {
		"find_music_null_name": source_sound_control_state.source_sound_control_find_music_state(false, "", {}).get("found_music", "x") == null,
		"find_music_exact": source_sound_control_state.source_sound_control_find_music_state(true, "track", {"track": "track"}).get("found_music", "") == "track",
		"find_music_ogg": source_sound_control_state.source_sound_control_find_music_state(true, "track", {"track.ogg": "track.ogg"}).get("found_music", "") == "track.ogg",
		"find_music_mp3": source_sound_control_state.source_sound_control_find_music_state(true, "track", {"track.mp3": "track.mp3"}).get("found_music", "") == "track.mp3",
		"find_music_music_ogg": source_sound_control_state.source_sound_control_find_music_state(true, "track", {"music/track.ogg": "music/track.ogg"}).get("found_music", "") == "music/track.ogg",
		"find_music_music_mp3": source_sound_control_state.source_sound_control_find_music_state(true, "track", {"music/track.mp3": "music/track.mp3"}).get("found_music", "") == "music/track.mp3",
		"find_music_not_found": source_sound_control_state.source_sound_control_find_music_state(true, "track", {}).get("found_music", "x") == null,
		"find_music_ogg_before_mp3": source_sound_control_state.source_sound_control_find_music_state(true, "track", {"track.ogg": "track.ogg", "track.mp3": "track.mp3"}).get("found_music", "") == "track.ogg",
		"find_music_plain_before_music_dir": source_sound_control_state.source_sound_control_find_music_state(true, "track", {"track.mp3": "track.mp3", "music/track.ogg": "music/track.ogg"}).get("found_music", "") == "track.mp3",
		"find_music_exact_first": source_sound_control_state.source_sound_control_find_music_state(true, "track", {"track": "track", "track.ogg": "track.ogg"}).get("found_music", "") == "track",
		"find_music_music_ogg_before_mp3": source_sound_control_state.source_sound_control_find_music_state(true, "track", {"music/track.ogg": "music/track.ogg", "music/track.mp3": "music/track.mp3"}).get("found_music", "") == "music/track.ogg",
		"find_music_plain_ogg_before_music_ogg": source_sound_control_state.source_sound_control_find_music_state(true, "track", {"track.ogg": "track.ogg", "music/track.ogg": "music/track.ogg"}).get("found_music", "") == "track.ogg",
		"find_music_returns_resolved_name": source_sound_control_state.source_sound_control_find_music_state(true, "track", {"track": "music/track.ogg"}).get("found_music", "") == "music/track.ogg",
	}
	proof["matches"] = proof["find_music_null_name"] and proof["find_music_exact"] and proof["find_music_ogg"] and proof["find_music_mp3"] and proof["find_music_music_ogg"] and proof["find_music_music_mp3"] and proof["find_music_not_found"] and proof["find_music_ogg_before_mp3"] and proof["find_music_plain_before_music_dir"] and proof["find_music_exact_first"] and proof["find_music_music_ogg_before_mp3"] and proof["find_music_plain_ogg_before_music_ogg"] and proof["find_music_returns_resolved_name"]
	proof_state.write_proof("C07SoundControlFindMusicProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
