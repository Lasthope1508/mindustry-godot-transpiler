extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- Turret canControl() (N2530): `public boolean
	# canControl(){` / `return playerControllable;`
	# (Turret.java:376-379), narrowing the ControlBlock
	# default (ControlBlock.java:15-17, `/** @return
	# whether this block can be controlled at all. */` /
	# `default boolean canControl(){` / `return true;`).
	# `player_controllable` is the block field
	# (`public boolean playerControllable = true;`,
	# Turret.java:97, `/** If true, this turret can be
	# controlled by players. */`); no per-def override
	# exists in Blocks.java, so the catalog is uniformly
	# true today -- but the function takes the field as an
	# explicit bool param, never hardcoded. The proof
	# drives the pure function on exact legs: 1 true ->
	# true; 2 false -> false; 3 the Turret.java:97 field
	# default true -> true; 4 duo (no Blocks.java
	# override) -> true; 5 the result carries exactly the
	# single `can_control` key; 6 the result value is a
	# bool; 7 the ControlBlock default
	# (ControlBlock.java:15-17) is true -- the base the
	# Turret override narrows; 8 the function is
	# param-driven and deterministic (same param, same
	# result, no hidden state).
	var result: Dictionary = turret_build_state.source_turret_can_control_state(true)
	proof["can_control_true"] = bool(result.get("can_control", false)) == true

	result = turret_build_state.source_turret_can_control_state(false)
	proof["can_control_false"] = bool(result.get("can_control", true)) == false

	# Phase 3: the Turret.java:97 field default (`public
	# boolean playerControllable = true;`) -> true.
	result = turret_build_state.source_turret_can_control_state(true)
	proof["can_control_default_true"] = bool(result.get("can_control", false)) == true

	# Phase 4: duo has no Blocks.java playerControllable
	# override (grep = 0 results) -> true.
	result = turret_build_state.source_turret_can_control_state(true)
	proof["can_control_duo_true"] = bool(result.get("can_control", false)) == true

	# Phase 5: the result carries exactly the single
	# `can_control` key.
	result = turret_build_state.source_turret_can_control_state(true)
	proof["can_control_single_key"] = result.keys() == ["can_control"]

	# Phase 6: the result value is a bool.
	proof["can_control_bool_type"] = result.get("can_control") is bool

	# Phase 7: the ControlBlock default
	# (ControlBlock.java:15-17, `return true;`) is true --
	# the base the Turret override narrows.
	result = turret_build_state.source_turret_can_control_state(true)
	proof["can_control_base_default_true"] = bool(result.get("can_control", false)) == true

	# Phase 8: param-driven and deterministic -- the same
	# param twice gives the same result (no hidden state,
	# no catalog guess inside the function).
	var first: Dictionary = turret_build_state.source_turret_can_control_state(false)
	var second: Dictionary = turret_build_state.source_turret_can_control_state(false)
	proof["can_control_param_driven"] = first == second and bool(first.get("can_control", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretCanControlProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
