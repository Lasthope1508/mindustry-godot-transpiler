extends Node

const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_sound_control_state := preload("res://src/game/SourceSoundControlState.gd")


func _ready() -> void:
	# SoundControl.getBossMusic() / getAmbientMusic() /
	# getDarkMusic() (SoundControl.java:270-284) are the
	# three music-list getters playRandom() reads
	# (SoundControl.java:258-262). Each getter is pure:
	# the rules branch returns the resolved rules list
	# with nulls removed, else the planet list when set,
	# else the field fallback. QUIRK, kept verbatim: boss
	# and dark read the SAME state.rules.darkMusic /
	# planet darkMusic in the rules / planet branch (boss
	# has no field of its own there); only the fallback
	# differs -- bossMusic for boss, darkMusic for dark.
	# The null checks arrive as explicit bool params (the
	# N2306 precedent -- GDScript typed Array params
	# cannot take null); an unset seq is passed as an
	# empty Array with its flag false and is never read.
	# All expectations below are hand-computed from the
	# Java lines, not from the implementation: boss rules
	# ["boss-a", null, "boss-c"] filter to ["boss-a",
	# "boss-c"]; boss rules [null, null] filter to [];
	# boss with no rules and a planet list returns the
	# planet list; boss with no rules and no planet
	# returns the bossMusic field; ambient rules ["amb-a",
	# null] filter to ["amb-a"]; ambient with no rules
	# and a planet list returns the planet list; ambient
	# with no rules and no planet returns the
	# ambientMusic field; dark rules ["dark-a", null,
	# "dark-c"] filter to ["dark-a", "dark-c"]; dark with
	# no rules and a planet list returns the planet
	# list; dark with no rules and no planet returns
	# the darkMusic field; the same rules input ["shared-a",
	# null] reads ["shared-a"] from BOTH boss and dark
	# (the shared read, not "fixed"); with no rules and
	# no planet, boss returns ["field-boss"] while dark
	# returns ["field-dark"] (the fallbacks differ).
	var proof := {
		"boss_music_rules": source_sound_control_state.source_sound_control_get_boss_music_state(true, ["boss-a", null, "boss-c"], false, [], ["field-boss"]).get("boss_music", []) == ["boss-a", "boss-c"],
		"boss_music_rules_all_null": source_sound_control_state.source_sound_control_get_boss_music_state(true, [null, null], false, [], ["field-boss"]).get("boss_music", ["x"]) == [],
		"boss_music_planet": source_sound_control_state.source_sound_control_get_boss_music_state(false, [], true, ["planet-boss"], ["field-boss"]).get("boss_music", []) == ["planet-boss"],
		"boss_music_fallback": source_sound_control_state.source_sound_control_get_boss_music_state(false, [], false, [], ["field-boss"]).get("boss_music", []) == ["field-boss"],
		"ambient_music_rules": source_sound_control_state.source_sound_control_get_ambient_music_state(true, ["amb-a", null], false, [], ["field-amb"]).get("ambient_music", []) == ["amb-a"],
		"ambient_music_planet": source_sound_control_state.source_sound_control_get_ambient_music_state(false, [], true, ["planet-amb"], ["field-amb"]).get("ambient_music", []) == ["planet-amb"],
		"ambient_music_fallback": source_sound_control_state.source_sound_control_get_ambient_music_state(false, [], false, [], ["field-amb"]).get("ambient_music", []) == ["field-amb"],
		"dark_music_rules": source_sound_control_state.source_sound_control_get_dark_music_state(true, ["dark-a", null, "dark-c"], false, [], ["field-dark"]).get("dark_music", []) == ["dark-a", "dark-c"],
		"dark_music_planet": source_sound_control_state.source_sound_control_get_dark_music_state(false, [], true, ["planet-dark"], ["field-dark"]).get("dark_music", []) == ["planet-dark"],
		"dark_music_fallback": source_sound_control_state.source_sound_control_get_dark_music_state(false, [], false, [], ["field-dark"]).get("dark_music", []) == ["field-dark"],
		"boss_dark_share_rules": source_sound_control_state.source_sound_control_get_boss_music_state(true, ["shared-a", null], false, [], ["field-boss"]).get("boss_music", []) == ["shared-a"] and source_sound_control_state.source_sound_control_get_dark_music_state(true, ["shared-a", null], false, [], ["field-dark"]).get("dark_music", []) == ["shared-a"],
		"boss_dark_differ_fallback": source_sound_control_state.source_sound_control_get_boss_music_state(false, [], false, [], ["field-boss"]).get("boss_music", []) == ["field-boss"] and source_sound_control_state.source_sound_control_get_dark_music_state(false, [], false, [], ["field-dark"]).get("dark_music", []) == ["field-dark"],
	}
	proof["matches"] = proof["boss_music_rules"] and proof["boss_music_rules_all_null"] and proof["boss_music_planet"] and proof["boss_music_fallback"] and proof["ambient_music_rules"] and proof["ambient_music_planet"] and proof["ambient_music_fallback"] and proof["dark_music_rules"] and proof["dark_music_planet"] and proof["dark_music_fallback"] and proof["boss_dark_share_rules"] and proof["boss_dark_differ_fallback"]
	proof_state.write_proof("C07SoundControlGetMusicProof", proof)
	await get_tree().process_frame
	get_tree().quit(proof_state.exit_code(proof))
