extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
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

	# --- Turret(String name) (N2400):
	# Turret(String name) (Turret.java:157-171). One ctor
	# slice (batch 25 slot 1): the 10 literal field
	# defaults only. `super(name);` is N2185-owned,
	# `liquidCapacity = 20f;` is N2085/N2089/N2091-owned,
	# `rotate = true;` is N2091/N2180/N2181-owned -- none
	# is re-registered here. The proof calls the pure
	# function with synthetic inputs (no live tick, no
	# render): one call returns all 10 ctor literals,
	# writes them into the def frame, preserves unrelated
	# frame keys, overwrites stale frame values, and is
	# idempotent on a second call. The defaults are frame
	# data only (bool/int/float literals); no Draw is
	# ported.

	# One call returns all 10 ctor literals, and nothing
	# else besides the updated frame.
	var fresh: Dictionary = {}
	var result: Dictionary = turret_defaults.source_turret_default_constructor_state(fresh)
	proof["ctor_defaults_all_ten"] = result.get("outlined_icon", -1) == 1 and result.get("draw_liquid_light", true) == false and result.get("sync", false) == true and result.get("quick_rotate", true) == false and result.get("draw_arrow", true) == false and result.get("ignore_line_rotation", false) == true and result.get("rotate_draw_editor", true) == false and result.get("visual_rotation_offset", 0.0) == -90.0 and result.get("region_rotated_1", -1) == 1 and result.get("region_rotated_2", -1) == 2
	proof["ctor_returns_only_eleven_keys"] = result.size() == 11

	# The call writes the 10 defaults into the def frame
	# (in/out): the returned frame is the same frame.
	proof["ctor_writes_frame"] = (result.get("turret_defaults", {}) as Dictionary) == fresh and fresh.get("outlined_icon", -1) == 1 and fresh.get("draw_liquid_light", true) == false and fresh.get("sync", false) == true and fresh.get("quick_rotate", true) == false and fresh.get("draw_arrow", true) == false and fresh.get("ignore_line_rotation", false) == true and fresh.get("rotate_draw_editor", true) == false and fresh.get("visual_rotation_offset", 0.0) == -90.0 and fresh.get("region_rotated_1", -1) == 1 and fresh.get("region_rotated_2", -1) == 2

	# Unrelated frame keys survive the call untouched.
	var kept: Dictionary = {"name": "duo", "range": 80.0}
	var kept_result: Dictionary = turret_defaults.source_turret_default_constructor_state(kept)
	proof["ctor_preserves_existing_frame_keys"] = kept.get("name", "") == "duo" and kept.get("range", 0.0) == 80.0 and kept_result.get("outlined_icon", -1) == 1

	# Stale frame values are overwritten: the ctor always
	# assigns, it never reads the old value.
	var stale: Dictionary = {"sync": false, "visual_rotation_offset": 0.0, "region_rotated_1": 0, "region_rotated_2": 0, "draw_arrow": true}
	var stale_result: Dictionary = turret_defaults.source_turret_default_constructor_state(stale)
	proof["ctor_overwrites_stale_frame_values"] = stale.get("sync", false) == true and stale.get("visual_rotation_offset", 0.0) == -90.0 and stale.get("region_rotated_1", -1) == 1 and stale.get("region_rotated_2", -1) == 2 and stale.get("draw_arrow", true) == false and stale_result.get("sync", false) == true and stale_result.get("visual_rotation_offset", 0.0) == -90.0 and stale_result.get("region_rotated_1", -1) == 1 and stale_result.get("region_rotated_2", -1) == 2 and stale_result.get("draw_arrow", true) == false

	# The 6 bool defaults, checked as a group.
	proof["ctor_bool_defaults"] = result.get("draw_liquid_light", true) == false and result.get("sync", false) == true and result.get("quick_rotate", true) == false and result.get("draw_arrow", true) == false and result.get("ignore_line_rotation", false) == true and result.get("rotate_draw_editor", true) == false

	# The visual rotation offset is a float -90.0, not an
	# int and not 90.0.
	proof["ctor_visual_rotation_offset_negative_ninety"] = result.get("visual_rotation_offset", 0.0) == -90.0 and typeof(result.get("visual_rotation_offset", 0)) == TYPE_FLOAT

	# The region-rotation pair is 1 then 2 (ints).
	proof["ctor_region_rotated_pair"] = result.get("region_rotated_1", -1) == 1 and result.get("region_rotated_2", -1) == 2 and typeof(result.get("region_rotated_1", 0)) == TYPE_INT and typeof(result.get("region_rotated_2", 0)) == TYPE_INT

	# The outlined icon index is the int 1.
	proof["ctor_outlined_icon_one"] = result.get("outlined_icon", -1) == 1 and typeof(result.get("outlined_icon", 0)) == TYPE_INT

	# A second call on the same frame yields the same 10
	# values: the ctor is idempotent.
	var second: Dictionary = turret_defaults.source_turret_default_constructor_state(fresh)
	proof["ctor_idempotent_second_call"] = second.get("outlined_icon", -1) == 1 and second.get("draw_liquid_light", true) == false and second.get("sync", false) == true and second.get("quick_rotate", true) == false and second.get("draw_arrow", true) == false and second.get("ignore_line_rotation", false) == true and second.get("rotate_draw_editor", true) == false and second.get("visual_rotation_offset", 0.0) == -90.0 and second.get("region_rotated_1", -1) == 1 and second.get("region_rotated_2", -1) == 2 and second.size() == 11

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretDefaultConstructorProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
