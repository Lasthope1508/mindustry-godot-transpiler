extends Node

const main_scene := preload("res://scenes/Main.tscn")
const continuous_turret_defaults := preload("res://src/game/SourceContinuousTurretDefaults.gd")
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

	# --- ContinuousTurret(String name) (N2407):
	# ContinuousTurret(String name)
	# (ContinuousTurret.java:20-25). One ctor slice
	# (batch 27 slot 2): the 2 literal field defaults
	# only. `super(name);` and `envEnabled |=
	# Env.space;` are N2185-owned -- neither is
	# re-registered here. The proof calls the pure
	# function with synthetic inputs (no live tick, no
	# render): one call returns both ctor defaults,
	# writes them into the def frame, preserves
	# unrelated frame keys, overwrites stale frame
	# values, and is idempotent on a second call.
	# `coolantMultiplier` overrides the BaseTurret base
	# default 5f (BaseTurret.java:32) with 1f; the same
	# literal also appears in the LaserTurret() and
	# TractorBeamTurret() ctors, but this slice owns
	# only the ContinuousTurret() leg.
	# `displayAmmoMultiplier` overrides the Turret base
	# default true (Turret.java:99) with false. The
	# defaults are frame data only; no Draw is ported.

	# One call returns both ctor defaults, and nothing
	# else besides the updated frame.
	var fresh: Dictionary = {}
	var result: Dictionary = continuous_turret_defaults.source_continuous_turret_default_constructor_state(fresh)
	proof["ctor_defaults_both"] = result.get("coolant_multiplier", 0.0) == 1.0 and result.get("display_ammo_multiplier", true) == false
	proof["ctor_returns_only_three_keys"] = result.size() == 3

	# The call writes both defaults into the def frame
	# (in/out): the returned frame is the same frame.
	proof["ctor_writes_frame"] = (result.get("continuous_turret_defaults", {}) as Dictionary) == fresh and fresh.get("coolant_multiplier", 0.0) == 1.0 and fresh.get("display_ammo_multiplier", true) == false

	# Unrelated frame keys survive the call untouched.
	var kept: Dictionary = {"name": "lancer", "range": 130.0}
	var kept_result: Dictionary = continuous_turret_defaults.source_continuous_turret_default_constructor_state(kept)
	proof["ctor_preserves_existing_frame_keys"] = kept.get("name", "") == "lancer" and kept.get("range", 0.0) == 130.0 and kept_result.get("coolant_multiplier", 0.0) == 1.0

	# Stale frame values are overwritten: the ctor always
	# assigns, it never reads the old value.
	var stale: Dictionary = {"coolant_multiplier": 5.0, "display_ammo_multiplier": true}
	var stale_result: Dictionary = continuous_turret_defaults.source_continuous_turret_default_constructor_state(stale)
	proof["ctor_overwrites_stale_frame_values"] = stale.get("coolant_multiplier", 0.0) == 1.0 and stale.get("display_ammo_multiplier", true) == false and stale_result.get("coolant_multiplier", 0.0) == 1.0 and stale_result.get("display_ammo_multiplier", true) == false

	# The coolant default is the float 1.0 (overriding
	# the BaseTurret base default 5f), not an int and
	# not 5.0.
	proof["ctor_coolant_one_float"] = result.get("coolant_multiplier", 0.0) == 1.0 and typeof(result.get("coolant_multiplier", 0)) == TYPE_FLOAT

	# A second call on the same frame yields the same 2
	# values: the ctor is idempotent.
	var second: Dictionary = continuous_turret_defaults.source_continuous_turret_default_constructor_state(fresh)
	proof["ctor_idempotent_second_call"] = second.get("coolant_multiplier", 0.0) == 1.0 and second.get("display_ammo_multiplier", true) == false and second.size() == 3

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ContinuousTurretDefaultConstructorProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
