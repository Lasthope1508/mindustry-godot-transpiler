extends Node

const main_scene := preload("res://scenes/Main.tscn")
const continuous_liquid_turret_build := preload("res://src/game/SourceContinuousLiquidTurretBuildState.gd")
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

	# --- ContinuousLiquidTurret(String name) (N2413):
	# ContinuousLiquidTurret(String name)
	# (ContinuousLiquidTurret.java:17-24). One ctor slice
	# (batch 29 slot 3): the 1 distinguishing field
	# default only. `super(name);` is N2185-owned,
	# `hasLiquids = true;` is N927/N2000/N2179/N2182/
	# N2209-owned, and `shootSound = Sounds.none;` /
	# `smokeEffect = Fx.none;` / `shootEffect = Fx.none;`
	# are N2406-owned (LiquidTurret ctor) -- none is
	# re-registered here. The proof calls the pure
	# function with synthetic inputs (no live tick, no
	# render): one call returns the ctor default, writes
	# it into the def frame, preserves unrelated frame
	# keys, overwrites a stale frame value, and is
	# idempotent on a second call. `loopSound` overrides
	# the Turret base default `Sounds.none`
	# (Turret.java:128) with `Sounds.loopMineBeam`; the
	# continuous liquid turret loops the mining beam
	# sound while firing. The default is frame data
	# only; no Draw is ported.

	# One call returns the ctor default, and nothing
	# else besides the updated frame.
	var fresh: Dictionary = {}
	var result: Dictionary = continuous_liquid_turret_build.source_continuous_liquid_turret_default_constructor_state(fresh, "loopMineBeam")
	proof["ctor_defaults_loop_sound"] = result.get("loop_sound", "") == "loopMineBeam"
	proof["ctor_returns_only_two_keys"] = result.size() == 2

	# The call writes the default into the def frame
	# (in/out): the returned frame is the same frame.
	proof["ctor_writes_frame"] = (result.get("continuous_liquid_turret_defaults", {}) as Dictionary) == fresh and fresh.get("loop_sound", "") == "loopMineBeam"

	# Unrelated frame keys survive the call untouched.
	var kept: Dictionary = {"name": "meltdown", "range": 170.0}
	var kept_result: Dictionary = continuous_liquid_turret_build.source_continuous_liquid_turret_default_constructor_state(kept, "loopMineBeam")
	proof["ctor_preserves_existing_frame_keys"] = kept.get("name", "") == "meltdown" and kept.get("range", 0.0) == 170.0 and kept_result.get("loop_sound", "") == "loopMineBeam"

	# A stale frame value is overwritten: the ctor always
	# assigns, it never reads the old value.
	var stale: Dictionary = {"loop_sound": "none"}
	var stale_result: Dictionary = continuous_liquid_turret_build.source_continuous_liquid_turret_default_constructor_state(stale, "loopMineBeam")
	proof["ctor_overwrites_stale_frame_values"] = stale.get("loop_sound", "") == "loopMineBeam" and stale_result.get("loop_sound", "") == "loopMineBeam"

	# The loop sound passes through unchanged, even
	# when wrapped in an Array (the reference is not
	# copied or coerced).
	var arrayed: Dictionary = continuous_liquid_turret_build.source_continuous_liquid_turret_default_constructor_state({}, ["loopMineBeam"])
	proof["ctor_loop_sound_passthrough"] = result.get("loop_sound", "") == "loopMineBeam" and arrayed.get("loop_sound", null) == ["loopMineBeam"]

	# A second call on the same frame yields the same
	# value: the ctor is idempotent.
	var second: Dictionary = continuous_liquid_turret_build.source_continuous_liquid_turret_default_constructor_state(fresh, "loopMineBeam")
	proof["ctor_idempotent_second_call"] = second.get("loop_sound", "") == "loopMineBeam" and second.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ContinuousLiquidTurretDefaultConstructorProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
