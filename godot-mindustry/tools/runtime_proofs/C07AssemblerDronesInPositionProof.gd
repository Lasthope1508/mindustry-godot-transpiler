extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
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

	# --- Pure count (N2144): the AssemblerAI-only drone list
	# counted through inPosition() (UnitAssembler.java:516,
	# `float eff = (units.count(u -> ((AssemblerAI)u.controller()).inPosition()) / (float)dronesCreated);`).
	# The drone type is UnitTypes.assemblyDrone
	# (UnitAssembler.java:47) named "assembly-drone"
	# (UnitTypes.java:4595); in_position is the recorded
	# AssemblerAI.inPosition() flag (AssemblerAI.java).
	var empty_count: Dictionary = unit_factory_build_state.source_assembler_drones_in_position_state([])
	proof["count_empty_0"] = int(empty_count.get("drones_in_position", -1)) == 0

	var four_drones: Array = [
		{"team_id": 0, "type_id": 0, "type_name": "assembly-drone", "in_position": true},
		{"team_id": 0, "type_id": 0, "type_name": "assembly-drone", "in_position": true},
		{"team_id": 0, "type_id": 0, "type_name": "assembly-drone", "in_position": false},
		{"team_id": 0, "type_id": 0, "type_name": "assembly-drone", "in_position": false},
	]
	var two_of_four: Dictionary = unit_factory_build_state.source_assembler_drones_in_position_state(four_drones)
	proof["count_two_of_four"] = int(two_of_four.get("drones_in_position", -1)) == 2

	var mixed_types: Array = [
		{"team_id": 0, "type_id": 0, "type_name": "dagger", "in_position": true},
		{"team_id": 0, "type_id": 0, "type_name": "assembly-drone", "in_position": true},
		{"team_id": 0, "type_id": 0, "type_name": "dagger", "in_position": true},
	]
	var other_types: Dictionary = unit_factory_build_state.source_assembler_drones_in_position_state(mixed_types)
	proof["count_ignores_other_types"] = int(other_types.get("drones_in_position", -1)) == 1

	var none_in_position: Array = [
		{"team_id": 0, "type_id": 0, "type_name": "assembly-drone", "in_position": false},
		{"team_id": 0, "type_id": 0, "type_name": "assembly-drone", "in_position": false},
	]
	var zero_in_position: Dictionary = unit_factory_build_state.source_assembler_drones_in_position_state(none_in_position)
	proof["count_ignores_not_in_position"] = int(zero_in_position.get("drones_in_position", -1)) == 0

	# --- Tick folds the count into eff (UnitAssembler.java:516,
	# 526): 2 of 4 drones in position -> eff 0.5, progress
	# advances by edelta * unitBuildSpeed * 0.5 / plan.time;
	# 0 in position -> eff 0, no progress.
	var plan: Dictionary = {"unit": "mace", "time": 60.0}
	var half: Dictionary = unit_factory_build_state.source_unit_assembler_production_tick_state({"efficiency": 1.0, "progress": 0.0, "warmup": 0.0}, plan, 4, 240.0, false, false, false, 2, true, true, 1.0, 1.0, 1.0, 1.0)
	proof["tick_eff_half"] = is_equal_approx(float(half.get("progress", -1.0)), 0.5 / 60.0) and bool(half.get("completed", true)) == false

	var zero: Dictionary = unit_factory_build_state.source_unit_assembler_production_tick_state({"efficiency": 1.0, "progress": 0.0, "warmup": 0.0}, plan, 4, 240.0, false, false, false, 0, true, true, 1.0, 1.0, 1.0, 1.0)
	proof["tick_no_progress_zero_drones"] = is_equal_approx(float(zero.get("progress", -1.0)), 0.0) and bool(zero.get("completed", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07AssemblerDronesInPositionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
