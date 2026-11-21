extends Node

const main_scene := preload("res://scenes/Main.tscn")
const base_turret_defaults := preload("res://src/game/SourceBaseTurretDefaults.gd")
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

	# --- BaseTurret(String name) (N2405):
	# BaseTurret(String name) (BaseTurret.java:36-46). One
	# ctor slice (batch 26 slot 3): the 4 literal field
	# defaults only. `super(name);` is N2185-owned,
	# `update = true;` is 22-slice-owned, `solid = true;`
	# is 11-slice-owned, `group = BlockGroup.turrets;`
	# is N2184-owned -- none is re-registered here. The
	# proof calls the pure function with synthetic inputs
	# (no live tick, no render): one call returns all 4
	# ctor defaults, writes them into the def frame,
	# preserves unrelated frame keys, overwrites stale
	# frame values, and is idempotent on a second call.
	# `TargetPriority.turret` is the float constant 1f,
	# so priority is the float literal 1.0; the block
	# flags arrive as the explicit block_flags Variant
	# param (the N2401 BeamDrill ctor precedent) and pass
	# through. The defaults are frame data only; no Draw
	# is ported.

	# One call returns all 4 ctor defaults, and nothing
	# else besides the updated frame.
	var fresh: Dictionary = {}
	var result: Dictionary = base_turret_defaults.source_base_turret_default_constructor_state(fresh, ["turret"])
	proof["ctor_defaults_all_four"] = result.get("outline_icon", false) == true and result.get("attacks", false) == true and result.get("priority", 0.0) == 1.0 and result.get("flags", null) == ["turret"]
	proof["ctor_returns_only_five_keys"] = result.size() == 5

	# The call writes the 4 defaults into the def frame
	# (in/out): the returned frame is the same frame.
	proof["ctor_writes_frame"] = (result.get("base_turret_defaults", {}) as Dictionary) == fresh and fresh.get("outline_icon", false) == true and fresh.get("attacks", false) == true and fresh.get("priority", 0.0) == 1.0 and fresh.get("flags", null) == ["turret"]

	# Unrelated frame keys survive the call untouched.
	var kept: Dictionary = {"name": "duo", "range": 80.0}
	var kept_result: Dictionary = base_turret_defaults.source_base_turret_default_constructor_state(kept, ["turret"])
	proof["ctor_preserves_existing_frame_keys"] = kept.get("name", "") == "duo" and kept.get("range", 0.0) == 80.0 and kept_result.get("outline_icon", false) == true

	# Stale frame values are overwritten: the ctor always
	# assigns, it never reads the old value.
	var stale: Dictionary = {"outline_icon": false, "attacks": false, "priority": 0.0, "flags": []}
	var stale_result: Dictionary = base_turret_defaults.source_base_turret_default_constructor_state(stale, ["turret"])
	proof["ctor_overwrites_stale_frame_values"] = stale.get("outline_icon", true) == true and stale.get("attacks", true) == true and stale.get("priority", 0.0) == 1.0 and stale.get("flags", null) == ["turret"] and stale_result.get("outline_icon", false) == true and stale_result.get("attacks", false) == true and stale_result.get("priority", 0.0) == 1.0 and stale_result.get("flags", null) == ["turret"]

	# The priority default is the float 1.0
	# (TargetPriority.turret = 1f), not an int and not 0.0.
	proof["ctor_priority_one_float"] = result.get("priority", 0.0) == 1.0 and typeof(result.get("priority", 0)) == TYPE_FLOAT

	# The block flags pass through: the param value is
	# returned unchanged, in both the array shape and a
	# plain string shape.
	var plain: Dictionary = base_turret_defaults.source_base_turret_default_constructor_state({}, "turret")
	proof["ctor_flags_passthrough"] = result.get("flags", null) == ["turret"] and plain.get("flags", null) == "turret"

	# A second call on the same frame yields the same 4
	# values: the ctor is idempotent.
	var second: Dictionary = base_turret_defaults.source_base_turret_default_constructor_state(fresh, ["turret"])
	proof["ctor_idempotent_second_call"] = second.get("outline_icon", false) == true and second.get("attacks", false) == true and second.get("priority", 0.0) == 1.0 and second.get("flags", null) == ["turret"] and second.size() == 5

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BaseTurretDefaultConstructorProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
