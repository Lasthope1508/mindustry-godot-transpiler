extends Node

const build_turret_state := preload("res://src/game/SourceBuildTurretBuildState.gd")
const turret_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- BuildTurretBuild.sense() (N2484):
	# BuildTurretBuild.sense() (BuildTurret.java:281-287):
	#     public double sense(LAccess sensor){
	#         return switch(sensor){
	#             case buildX, buildY -> unit.sense(sensor);
	#             default -> super.sense(sensor);
	#         };
	#     }
	# The `unit` here is the FIELD `public BlockUnitc unit =
	# (BlockUnitc)unitType.create(team);`
	# (BuildTurret.java:93) -- NOT the `unit()` accessor
	# (:113-119, excluded for its side-effect). The unit leg
	# reads Unit.sense (UnitComp.java:264): buildX ->
	# `isBuilding() ? buildPlan().x : -1;` (:290) and
	# buildY -> `isBuilding() ? buildPlan().y : -1;` (:291).
	# The default leg is `super.sense(sensor)` -- super
	# resolves to BuildingComp.sense (BuildingComp.java:2093,
	# default `default -> Float.NaN; //gets converted to
	# null in logic`, :2123). The proof drives the pure
	# function with pre-resolved unit + super values (no live
	# tick, no game state) and pins the cross-trap by driving
	# the parent TurretBuild.sense() (N2293,
	# source_turret_sense_state) on ammo, which the parent
	# handles itself.

	# KEY TRAP: buildX comes from the unit value, not the
	# super value -- with unit = 12.0 and super = 7.0 the
	# buildX leg must return 12.0 with handled = true.
	var build_x := build_turret_state.source_build_turret_sense_state({}, "buildX", 12.0, 7.0, false)
	proof["build_x_comes_from_unit"] = build_x.get("handled") == true and build_x.get("sense_value") == 12.0 and build_x.get("sense_value_is_nan") == false

	# buildY likewise comes from the unit value (34.0, not 7.0).
	var build_y := build_turret_state.source_build_turret_sense_state({}, "buildY", 34.0, 7.0, false)
	proof["build_y_comes_from_unit"] = build_y.get("handled") == true and build_y.get("sense_value") == 34.0 and build_y.get("sense_value_is_nan") == false

	# KEY TRAP: ammo does NOT go to unit -- it falls through
	# to super, so with unit = 42.0 and super = 7.0 the ammo
	# leg must return 7.0 with handled = false.
	var ammo := build_turret_state.source_build_turret_sense_state({}, "ammo", 42.0, 7.0, false)
	proof["ammo_falls_through_to_super"] = ammo.get("handled") == false and ammo.get("sense_value") == 7.0 and ammo.get("sense_value_is_nan") == false

	# A NaN super passes through: an unhandled sensor whose
	# super fell through to the BuildingComp default returns
	# null with sense_value_is_nan = true and handled = false.
	var nan_super := build_turret_state.source_build_turret_sense_state({}, "unknownSensor", 42.0, null, true)
	proof["super_nan_passes_through"] = nan_super.get("handled") == false and nan_super.get("sense_value") == null and nan_super.get("sense_value_is_nan") == true

	# When the builder unit is not building, Unit.sense
	# returns -1 for buildX (UnitComp.java:290,
	# `isBuilding() ? buildPlan().x : -1;`) -- the -1 passes
	# through the unit leg whole.
	var build_x_idle := build_turret_state.source_build_turret_sense_state({}, "buildX", -1.0, 7.0, false)
	proof["build_x_minus_one_when_not_building"] = build_x_idle.get("handled") == true and build_x_idle.get("sense_value") == -1.0

	# CROSS-TRAP, parent differs on ammo: TurretBuild.sense()
	# (N2293) handles ammo itself, so with totalAmmo = 5 it
	# returns 5.0 with handled = true, while this slice falls
	# through to super and returns 7.0 with handled = false
	# for the same sensor -- the two switches are different.
	var parent_ammo := turret_state.source_turret_sense_state({}, "ammo", 5, 30, 90.0, Vector2.ZERO, false, 0.0, 10.0, 8.0)
	proof["parent_sense_differs_on_ammo"] = parent_ammo.get("handled") == true and parent_ammo.get("sense_value") == 5.0 and ammo.get("sense_value") == 7.0 and parent_ammo.get("sense_value") != ammo.get("sense_value")

	# The result has exactly three keys.
	proof["returns_only_three_keys"] = build_turret_state.source_build_turret_sense_state({}, "buildX", 12.0, 7.0, false).size() == 3

	# A second call with the same input gives the same output.
	proof["idempotent_second_call"] = build_turret_state.source_build_turret_sense_state({}, "buildX", 12.0, 7.0, false) == build_turret_state.source_build_turret_sense_state({}, "buildX", 12.0, 7.0, false)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretSenseProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
