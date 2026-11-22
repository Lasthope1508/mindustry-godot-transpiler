extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourceBuildTurretBuildState.gd")
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

	# --- BuildTurretBuild.read() plans restore (N2429):
	# BuildTurretBuild.read() (BuildTurret.java:266-278)
	# restores the builder unit's plans after
	# `TypeIO.readPlans(read)` (:272, owned at N2184):
	# the null-guard + restore loop (:273-275) is this
	# slice ONLY. The caller passes the already-read
	# plans Array plus an explicit reqs_null bool for
	# `reqs != null`. The proof drives the pure function
	# with fixtures (no live tick).

	var plan_a: Dictionary = {"x": 1, "y": 2, "rotation": 0, "block": "test-block", "config": null}
	var plan_b: Dictionary = {"x": 3, "y": 4, "rotation": 1, "block": "test-block", "config": null}

	# Null plans restore nothing.
	var null_result: Dictionary = bridge.source_build_turret_read_plans_state(true, [])
	proof["null_reqs_adds_nothing"] = (null_result.get("plans_to_add", [-1]) as Array).is_empty()

	# Null still restores nothing even when a reqs Array
	# is passed alongside (the guard, not the loop, rules).
	var null_ignored: Dictionary = bridge.source_build_turret_read_plans_state(true, [plan_a])
	proof["null_reqs_ignores_reqs"] = (null_ignored.get("plans_to_add", [-1]) as Array).is_empty()

	# An empty (non-null) plans Array restores nothing.
	var empty_result: Dictionary = bridge.source_build_turret_read_plans_state(false, [])
	proof["empty_reqs_adds_nothing"] = (empty_result.get("plans_to_add", [-1]) as Array).is_empty()

	# A single plan is restored as-is.
	var single_result: Dictionary = bridge.source_build_turret_read_plans_state(false, [plan_a])
	proof["single_req_restored"] = single_result.get("plans_to_add", []) == [plan_a]

	# Several plans are restored in Java order.
	var multi_result: Dictionary = bridge.source_build_turret_read_plans_state(false, [plan_a, plan_b])
	proof["multiple_reqs_restored_in_order"] = multi_result.get("plans_to_add", []) == [plan_a, plan_b]

	# Duplicates are kept: Java adds every req
	# unconditionally (`unit.plans().add(req);`).
	var dup_result: Dictionary = bridge.source_build_turret_read_plans_state(false, [plan_a, plan_a])
	proof["duplicate_reqs_kept"] = dup_result.get("plans_to_add", []) == [plan_a, plan_a]

	# The result carries ONLY its own 1 key.
	proof["returns_only_expected_keys"] = null_result.size() == 1 and single_result.size() == 1 and multi_result.size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretReadPlansProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
