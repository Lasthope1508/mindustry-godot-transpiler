extends Node

const build_turret_state := preload("res://src/game/SourceBuildTurretBuildState.gd")
const turret_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- BuildTurretBuild.senseObject() (N2485):
	# BuildTurretBuild.senseObject() (BuildTurret.java:289-295):
	#     public Object senseObject(LAccess sensor){
	#         return switch(sensor){
	#             case building, breaking -> unit.senseObject(sensor);
	#             default -> super.senseObject(sensor);
	#         };
	#     }
	# The `unit` here is the FIELD `public BlockUnitc unit =
	# (BlockUnitc)unitType.create(team);`
	# (BuildTurret.java:93) -- NOT the `unit()` accessor
	# (:113-119, excluded for its side-effect). The unit leg
	# reads Unit.senseObject (UnitComp.java:313): building ->
	# `isBuilding() && !buildPlan().breaking ?
	# buildPlan().tile().build : null;` (:324) and breaking ->
	# `isBuilding() && buildPlan().breaking ?
	# buildPlan().tile().build : null;` (:325) -- the build
	# object when the builder unit has a plan of that kind,
	# null otherwise. The default leg is
	# `super.senseObject(sensor)` -- super resolves to
	# BuildingComp.senseObject (BuildingComp.java:2128,
	# `case type -> block;` / `case firstItem -> ...` /
	# `case config -> ...` / `case payloadType -> ...` /
	# `default -> noSensed;`, :2129-2135). The proof drives
	# the pure function with pre-resolved unit + super values
	# (no live tick, no game state) and pins the cross-trap
	# by driving the turret senseObject bridge (N2506,
	# source_turret_sense_object_state), which handles type
	# itself but does not handle building.

	# KEY TRAP: building comes from the unit value, not the
	# super value -- with unit = "duo" and super = "router"
	# the building leg must return "duo" with handled = true.
	# (The build object is an Object; the proof passes its
	# block id string as the stand-in value, the same
	# identity convention as the N2506 bridge.)
	var building := build_turret_state.source_build_turret_sense_object_state({}, "building", "duo", "router", false)
	proof["building_comes_from_unit"] = building.get("handled") == true and building.get("sense_object_value") == "duo" and building.get("sense_object_value_is_null") == false

	# breaking likewise comes from the unit value ("router", not "duo").
	var breaking := build_turret_state.source_build_turret_sense_object_state({}, "breaking", "router", "duo", false)
	proof["breaking_comes_from_unit"] = breaking.get("handled") == true and breaking.get("sense_object_value") == "router" and breaking.get("sense_object_value_is_null") == false

	# When the builder unit has no plan, Unit.senseObject
	# returns null for building (UnitComp.java:324) -- the
	# null passes through the handled leg with
	# sense_object_value_is_null = true.
	var building_idle := build_turret_state.source_build_turret_sense_object_state({}, "building", null, "router", false)
	proof["building_null_when_not_building"] = building_idle.get("handled") == true and building_idle.get("sense_object_value") == null and building_idle.get("sense_object_value_is_null") == true

	# KEY TRAP: type does NOT go to unit -- it falls through
	# to super, so with unit = "duo" and super = "router"
	# the type leg must return "router" with handled = false.
	var type_sensor := build_turret_state.source_build_turret_sense_object_state({}, "type", "duo", "router", false)
	proof["type_falls_through_to_super"] = type_sensor.get("handled") == false and type_sensor.get("sense_object_value") == "router" and type_sensor.get("sense_object_value_is_null") == false

	# A null super passes through: an unhandled sensor whose
	# super fell through to the BuildingComp default returns
	# null with sense_object_value_is_null = true and
	# handled = false.
	var null_super := build_turret_state.source_build_turret_sense_object_state({}, "unknownSensor", "duo", null, true)
	proof["super_null_passes_through"] = null_super.get("handled") == false and null_super.get("sense_object_value") == null and null_super.get("sense_object_value_is_null") == true

	# CROSS-TRAP, bridge differs on building and type: the
	# turret senseObject bridge (N2506) does NOT handle
	# building (handled = false, is_no_sensed = true) while
	# this slice handles it (handled = true); conversely the
	# bridge handles type itself (handled = true) while this
	# slice falls through to super (handled = false) -- the
	# two switches are different.
	var parent_building := turret_state.source_turret_sense_object_state("building", "duo", "copper")
	var parent_type := turret_state.source_turret_sense_object_state("type", "duo", "copper")
	proof["parent_sense_object_differs_on_building_and_type"] = parent_building.get("handled") == false and parent_building.get("is_no_sensed") == true and building.get("handled") == true and parent_type.get("handled") == true and type_sensor.get("handled") == false

	# The result has exactly three keys.
	proof["returns_only_three_keys"] = build_turret_state.source_build_turret_sense_object_state({}, "building", "duo", "router", false).size() == 3

	# A second call with the same input gives the same output.
	proof["idempotent_second_call"] = build_turret_state.source_build_turret_sense_object_state({}, "building", "duo", "router", false) == build_turret_state.source_build_turret_sense_object_state({}, "building", "duo", "router", false)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretSenseObjectProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
