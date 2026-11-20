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

	# --- Turret logic-processor sense LAccess numeric dispatch (N2510):
	# SenseI.run() (LExecutor.java:681-718,
	# `public static class SenseI implements LInstruction{`,
	# :668) takes the LAccess branch when the target is a
	# Senseable and the sensor is an LAccess
	# (`}else if(sense instanceof LAccess la){`, :694):
	# `Object objOut = se.senseObject(la);` /
	# `if(objOut == Senseable.noSensed){` /
	# `//numeric output` /
	# `to.setnum(se.sense(la));` /
	# `}else{` /
	# `//object output` /
	# `to.setobj(objOut);` /
	# `}` (:695-703). On the noSensed sentinel the dispatch
	# writes the numeric `se.sense(la)` value. For a duo
	# turret that value is Turret.sense
	# (`public double sense(LAccess sensor){`,
	# Turret.java:405-419: ammo / ammoCapacity / rotation /
	# shootX / shootY / shooting / progress), whose `default`
	# falls through to super.sense (`default ->
	# super.sense(sensor);`, :417; BuildingComp.sense,
	# BuildingComp.java:2093-2126, 23 handled legs), whose
	# default is NaN (`default -> Float.NaN; //gets converted
	# to null in logic`, :2123). The two sense outcomes are
	# passed in as params (the N2212/N2220 per-def-param
	# precedent, same as N2507 passing in `sense_value`); the
	# pure function does not re-implement the 30 sensor legs.
	# There is no driver tick line: the leg is a logic read,
	# not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509
	# precedent).

	# ammo is handled by Turret.sense: 12 total ammo reads 12.0.
	var ammo_result: Dictionary = turret_build_state.source_logic_sense_laccess_state("ammo", true, 12.0, false, 0.0)
	proof["turret_ammo_num"] = bool(ammo_result.get("handled", false)) and float(ammo_result.get("sense_value", 0.0)) == 12.0 and not bool(ammo_result.get("sense_value_is_nan", true))

	# rotation is handled by BOTH switches, but Turret.sense
	# runs first: the turret value 45.0 wins over the comp
	# value 90.0 (`default -> super.sense(sensor);`,
	# Turret.java:417 is only reached when Turret.sense misses).
	var rotation_result: Dictionary = turret_build_state.source_logic_sense_laccess_state("rotation", true, 45.0, true, 90.0)
	proof["turret_wins_rotation"] = bool(rotation_result.get("handled", false)) and float(rotation_result.get("sense_value", 0.0)) == 45.0 and not bool(rotation_result.get("sense_value_is_nan", true))

	# size misses Turret.sense and is handled by
	# BuildingComp.sense: a size-2 block reads 2.0.
	var size_result: Dictionary = turret_build_state.source_logic_sense_laccess_state("size", false, 0.0, true, 2.0)
	proof["comp_size_num"] = bool(size_result.get("handled", false)) and float(size_result.get("sense_value", 0.0)) == 2.0 and not bool(size_result.get("sense_value_is_nan", true))

	# maxHealth misses Turret.sense and is handled by
	# BuildingComp.sense: duo maxHealth 250 reads 250.0.
	var max_health_result: Dictionary = turret_build_state.source_logic_sense_laccess_state("maxHealth", false, 0.0, true, 250.0)
	proof["comp_max_health_num"] = bool(max_health_result.get("handled", false)) and float(max_health_result.get("sense_value", 0.0)) == 250.0 and not bool(max_health_result.get("sense_value_is_nan", true))

	# health is a deferred sensor leg (live building health is
	# not in the frame, N2284): neither switch handles it, so
	# the dispatch reports handled false + NaN.
	var health_result: Dictionary = turret_build_state.source_logic_sense_laccess_state("health", false, 0.0, false, 0.0)
	proof["deferred_health_nan"] = not bool(health_result.get("handled", true)) and health_result.get("sense_value", 0.0) == null and bool(health_result.get("sense_value_is_nan", false))

	# An unknown sensor is handled by neither switch: handled
	# false + NaN, the BuildingComp default
	# (`default -> Float.NaN; //gets converted to null in logic`,
	# BuildingComp.java:2123).
	var unknown_result: Dictionary = turret_build_state.source_logic_sense_laccess_state("foobar", false, 0.0, false, 0.0)
	proof["unknown_sensor_nan"] = not bool(unknown_result.get("handled", true)) and unknown_result.get("sense_value", 0.0) == null and bool(unknown_result.get("sense_value_is_nan", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretLogicSenseLAccessProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
