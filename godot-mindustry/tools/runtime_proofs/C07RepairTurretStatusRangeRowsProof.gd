extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- Status/range rows (N2475): RepairTurret.
	# status() (RepairTurret.java:226-228)
	# returns BlockStatus.noInput when
	# potentialEfficiency is ~0 (Mathf.equal
	# with tolerance 0.01f), else super.status()
	# (BuildingComp.java:632-646). Mathf.equal(a,
	# b, tolerance) is `return Math.abs(a - b)
	# <= tolerance;` (arc Mathf.java:554-556) --
	# INCLUSIVE, so exactly 0.01 still reads
	# noInput. super.status() is the BuildingComp
	# status (logicDisable when !enabled,
	# noOutput when !shouldConsume(), noInput
	# when efficiency <= 0 or !productionValid(),
	# else active on the tick-phase gate) -- the
	# port computes it as source_building_status_
	# state and the caller supplies the result
	# here. range() (RepairTurret.java:231-233)
	# returns repairRadius -- the class 50f
	# (RepairTurret.java:32), repair-point 60f
	# (Blocks.java:6389), repair-turret 145f
	# (Blocks.java:6401).
	#
	# Fixture: the pure takes caller-supplied
	# inputs -- the folded potentialEfficiency,
	# the BuildingComp status result, and the def
	# repairRadius -- and returns the status
	# token + the range as data. Pure-only: the
	# tick never calls status() / range().

	# --- No input: potentialEfficiency at zero
	# or within 0.01 of zero reads noInput, even
	# when super.status() says active or
	# logicDisable -- the Mathf.equal gate runs
	# before the super call. A negative value
	# within tolerance reads noInput too (the
	# absolute value).
	var zero_active: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(0.0, "active", 50.0)
	var zero_logic_disable: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(0.0, "logicDisable", 60.0)
	var near_zero: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(0.005, "active", 145.0)
	var negative_near_zero: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(-0.005, "active", 50.0)
	proof["status_no_input"] = str(zero_active.get("status", "")) == "noInput" and str(zero_logic_disable.get("status", "")) == "noInput" and str(near_zero.get("status", "")) == "noInput" and str(negative_near_zero.get("status", "")) == "noInput"

	# --- Super passthrough: outside tolerance
	# the pure returns super.status() unchanged
	# -- active, logicDisable, and noOutput all
	# pass through verbatim.
	var super_active: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(1.0, "active", 50.0)
	var super_logic_disable: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(0.5, "logicDisable", 60.0)
	var super_no_output: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(0.02, "noOutput", 145.0)
	proof["status_super"] = str(super_active.get("status", "")) == "active" and str(super_logic_disable.get("status", "")) == "logicDisable" and str(super_no_output.get("status", "")) == "noOutput"

	# --- Boundary: exactly 0.01 reads noInput --
	# Mathf.equal is inclusive (<= tolerance),
	# so the boundary belongs to noInput. The
	# negative boundary -0.01 reads noInput too.
	var boundary: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(0.01, "active", 50.0)
	var negative_boundary: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(-0.01, "active", 50.0)
	proof["status_boundary"] = str(boundary.get("status", "")) == "noInput" and str(negative_boundary.get("status", "")) == "noInput"

	# --- Tolerance: just outside 0.01 the gate
	# opens and super.status() passes through --
	# 0.010001, 0.011, and -0.011 all return the
	# caller-supplied super status.
	var just_outside: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(0.010001, "active", 50.0)
	var outside: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(0.011, "active", 50.0)
	var negative_outside: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(-0.011, "noOutput", 50.0)
	proof["status_tolerance"] = str(just_outside.get("status", "")) == "active" and str(outside.get("status", "")) == "active" and str(negative_outside.get("status", "")) == "noOutput"

	# --- Range class: the class repairRadius
	# 50f (RepairTurret.java:32) returns 50.0.
	var range_class: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(1.0, "active", 50.0)
	proof["range_class"] = float(range_class.get("range_value", 0.0)) == 50.0

	# --- Range def: the def overrides return
	# verbatim -- repair-point 60f
	# (Blocks.java:6389) and repair-turret 145f
	# (Blocks.java:6401).
	var range_point: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(1.0, "active", 60.0)
	var range_turret: Dictionary = repair_turret_build_state.source_repair_turret_status_range_state(1.0, "active", 145.0)
	proof["range_def"] = float(range_point.get("range_value", 0.0)) == 60.0 and float(range_turret.get("range_value", 0.0)) == 145.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretStatusRangeRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
