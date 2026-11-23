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

	# --- BuildTurret.init() UnitType fields (N2426):
	# BuildTurret.init() (BuildTurret.java:50-69) builds
	# the builder unit type once at block init:
	# `unitType = new UnitType("turret-unit-" + name){{`
	# (:56). This slice is ONLY the 6 UnitType field
	# lines (:57-61, :63), all 0-hit in both ledgers at
	# RED. The 5 constants are taken verbatim from the
	# Java lines; rotateSpeed is the block field passed
	# as a param (constructor default `rotateSpeed =
	# 10f;`, BuildTurret.java:45). The proof drives the
	# pure function with fixtures (no live tick).

	# The constructor-default rotateSpeed passes through.
	var defaults: Dictionary = bridge.source_build_turret_init_unit_type_state(10.0)
	proof["hidden_true"] = bool(defaults.get("hidden", false)) == true
	proof["internal_true"] = bool(defaults.get("internal", false)) == true
	proof["speed_zero"] = is_equal_approx(float(defaults.get("speed", -99.0)), 0.0)
	proof["hit_size_zero"] = is_equal_approx(float(defaults.get("hit_size", -99.0)), 0.0)
	proof["health_one"] = int(defaults.get("health", -99)) == 1
	proof["rotate_speed_passthrough"] = is_equal_approx(float(defaults.get("rotate_speed", -99.0)), 10.0)

	# Any other block rotateSpeed passes through as-is.
	var other: Dictionary = bridge.source_build_turret_init_unit_type_state(5.0)
	proof["rotate_speed_other_value"] = is_equal_approx(float(other.get("rotate_speed", -99.0)), 5.0)

	# The result carries ONLY its own 6 keys.
	proof["returns_only_expected_keys"] = defaults.size() == 6 and other.size() == 6

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretInitUnitTypeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
