extends Node

const main_scene := preload("res://scenes/Main.tscn")
const radar_state := preload("res://src/game/SourceRadarBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- Radar(String name) (N2404):
	# Radar(String name) (Radar.java:27-34). One ctor
	# slice (batch 26 slot 2): the 3 literal field
	# defaults only. `super(name);` is N2185-owned,
	# `fogRadius = 10;` is N2320/N2321/N2342-owned --
	# neither is re-registered here. The proof calls the
	# pure function with synthetic inputs (no live tick,
	# no render): one call returns all 4 ctor values,
	# writes them into the def frame, preserves unrelated
	# frame keys, overwrites stale frame values, passes
	# the flags param through in both shapes, and is
	# idempotent on a second call. The defaults are frame
	# data only (bool literals + one flags value); no Draw
	# is ported. Radar was declared 40/40 done at
	# renumber #52 -- that was drawSelect completion;
	# this ctor is the last unported Radar block-level
	# item.

	# One call returns all 4 ctor values, and nothing
	# else besides the updated frame.
	var fresh: Dictionary = {}
	var result: Dictionary = radar_state.source_radar_default_constructor_state(fresh, ["hasFogRadius"])
	proof["ctor_defaults_all_four"] = result.get("update", false) == true and result.get("solid", false) == true and result.get("flags", null) == ["hasFogRadius"] and result.get("outline_icon", false) == true
	proof["ctor_returns_only_five_keys"] = result.size() == 5

	# The call writes the 4 defaults into the def frame
	# (in/out): the returned frame is the same frame.
	proof["ctor_writes_frame"] = (result.get("radar_defaults", {}) as Dictionary) == fresh and fresh.get("update", false) == true and fresh.get("solid", false) == true and fresh.get("flags", null) == ["hasFogRadius"] and fresh.get("outline_icon", false) == true

	# Unrelated frame keys survive the call untouched.
	var kept: Dictionary = {"name": "radar", "fog_radius": 34.0}
	var kept_result: Dictionary = radar_state.source_radar_default_constructor_state(kept, ["hasFogRadius"])
	proof["ctor_preserves_existing_frame_keys"] = kept.get("name", "") == "radar" and kept.get("fog_radius", 0.0) == 34.0 and kept_result.get("update", false) == true

	# Stale frame values are overwritten: the ctor always
	# assigns, it never reads the old value.
	var stale: Dictionary = {"update": false, "solid": false, "outline_icon": false}
	var stale_result: Dictionary = radar_state.source_radar_default_constructor_state(stale, ["hasFogRadius"])
	proof["ctor_overwrites_stale_frame_values"] = stale.get("update", false) == true and stale.get("solid", false) == true and stale.get("outline_icon", false) == true and stale_result.get("update", false) == true and stale_result.get("solid", false) == true and stale_result.get("outline_icon", false) == true

	# The 3 bool defaults, checked as a group.
	proof["ctor_bool_defaults"] = result.get("update", false) == true and result.get("solid", false) == true and result.get("outline_icon", false) == true

	# The block flags pass through in both shapes (array
	# and plain string, the N2401 precedent): the caller
	# supplies the EnumSet value, the pure function
	# echoes it unchanged.
	var array_flags: Dictionary = radar_state.source_radar_default_constructor_state({}, ["hasFogRadius"])
	var string_flags: Dictionary = radar_state.source_radar_default_constructor_state({}, "hasFogRadius")
	proof["ctor_flags_passthrough"] = array_flags.get("flags", null) == ["hasFogRadius"] and string_flags.get("flags", null) == "hasFogRadius"

	# A second call on the same frame yields the same 4
	# values: the ctor is idempotent.
	var second: Dictionary = radar_state.source_radar_default_constructor_state(fresh, ["hasFogRadius"])
	proof["ctor_idempotent_second_call"] = second.get("update", false) == true and second.get("solid", false) == true and second.get("flags", null) == ["hasFogRadius"] and second.get("outline_icon", false) == true and second.size() == 5

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarDefaultConstructorProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
