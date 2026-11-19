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

	# --- TurretBuild.progress() (N2292):
	# TurretBuild overrides progress (Turret.java:425-427,
	# `public float progress(){` / `return Mathf.clamp(
	# reloadCounter / reload);`) over the base default
	# BuildingComp.progress (BuildingComp.java:617-619,
	# `return 0f;`). The inputs are reloadCounter
	# (ReloadTurret.java:26, capped at reload,
	# Turret.java:723) against reload
	# (ReloadTurret.java:10, `public float reload = 10f;`).
	# arc Mathf.clamp with one argument clamps to [0, 1]
	# (the MendProjector precedent,
	# SourceMendProjectorState.gd:41). No driver line: the
	# only consumer is sense() case progress
	# (Turret.java:414, N2255), and the tick frame tracks
	# neither reloadCounter nor reload yet.

	# An empty reload counter reads 0.
	var zero: Dictionary = turret_build_state.source_turret_progress_state({}, 0.0, 10.0)
	proof["progress_zero"] = is_equal_approx(float(zero.get("progress", -1.0)), 0.0)

	# A half counter reads 0.5.
	var half: Dictionary = turret_build_state.source_turret_progress_state({}, 5.0, 10.0)
	proof["progress_half"] = is_equal_approx(float(half.get("progress", -1.0)), 0.5)

	# A full counter reads 1.
	var full: Dictionary = turret_build_state.source_turret_progress_state({}, 10.0, 10.0)
	proof["progress_full"] = is_equal_approx(float(full.get("progress", -1.0)), 1.0)

	# A counter past reload clamps to 1 (live it is capped at
	# reload, Turret.java:723, so this only proves the pure
	# clamp, not a live state).
	var beyond: Dictionary = turret_build_state.source_turret_progress_state({}, 12.0, 10.0)
	proof["progress_beyond_reload"] = is_equal_approx(float(beyond.get("progress", -1.0)), 1.0)

	# A negative counter clamps to 0 (pure clamp check; live
	# the counter never goes negative).
	var negative: Dictionary = turret_build_state.source_turret_progress_state({}, -2.0, 10.0)
	proof["progress_negative"] = is_equal_approx(float(negative.get("progress", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretProgressProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
