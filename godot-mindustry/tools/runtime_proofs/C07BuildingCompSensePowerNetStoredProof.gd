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

	# --- BuildingComp.sense() `powerNetStored` leg (N2516):
	# BuildingComp.sense() (`public double sense(LAccess
	# sensor){`, BuildingComp.java:2093-2126) answers
	# `case powerNetStored -> power == null ? 0 :
	# power.graph.getLastPowerStored();` (:2116),
	# with `power` the building's power module (`@Nullable
	# PowerModule power;`, BuildingComp.java:80) and
	# `power.graph.getLastPowerStored()` the graph's last
	# stored battery power (`public float
	# getLastPowerStored(){`, PowerGraph.java:73-75 --
	# returns float; updated :236 `lastPowerStored =
	# getBatteryStored()`). There is NO
	# `* 60` here, unlike powerNetIn/powerNetOut -- the
	# stored value is an absolute amount (battery charge),
	# not a per-tick rate, so it is returned as-is. The two
	# params are the live input a future frame-stamp slice
	# will supply (the N2212/N2220 per-def-param
	# precedent): the live graph values are not stamped in
	# the frame yet, so `power_is_null` is `power == null`
	# (:2116, first branch of the ternary) and
	# `last_power_stored` is
	# `power.graph.getLastPowerStored()`. The value is
	# returned exactly: 0.0 when power is null, else
	# `last_power_stored` (Java `sense()` returns double;
	# the float widens exactly), no clamping, no rounding.
	# There is no driver tick line: the leg is a logic read,
	# not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512/N2514/N2515
	# precedent); the proof calls the pure function
	# directly with synthetic inputs.

	# Null power: `power == null` reads 0.0 (first branch
	# of the ternary, :2116).
	var null_result: Dictionary = turret_build_state.source_building_comp_sense_power_net_stored_state(true, 0.0)
	proof["power_net_stored_null_num"] = bool(null_result.get("handled", false)) and float(null_result.get("sense_value", 1.0)) == 0.0 and not bool(null_result.get("sense_value_is_nan", true))

	# Zero stored: last stored power 0.0 with power present
	# reads 0.0.
	var zero_result: Dictionary = turret_build_state.source_building_comp_sense_power_net_stored_state(false, 0.0)
	proof["power_net_stored_zero_num"] = bool(zero_result.get("handled", false)) and float(zero_result.get("sense_value", 1.0)) == 0.0 and not bool(zero_result.get("sense_value_is_nan", true))

	# Some stored: 2.5 reads back 2.5 (NO * 60 -- an
	# absolute amount, not a per-tick rate).
	var some_result: Dictionary = turret_build_state.source_building_comp_sense_power_net_stored_state(false, 2.5)
	proof["power_net_stored_some_num"] = bool(some_result.get("handled", false)) and float(some_result.get("sense_value", 0.0)) == 2.5 and not bool(some_result.get("sense_value_is_nan", true))

	# Large stored: 10.0 reads back 10.0 exactly (the
	# float widens exactly to the double sense wire).
	var large_result: Dictionary = turret_build_state.source_building_comp_sense_power_net_stored_state(false, 10.0)
	proof["power_net_stored_large_num"] = bool(large_result.get("handled", false)) and float(large_result.get("sense_value", 0.0)) == 10.0 and not bool(large_result.get("sense_value_is_nan", true))

	# The leg always handles the fixed `powerNetStored` sensor.
	proof["power_net_stored_handled_true"] = bool(null_result.get("handled", false))

	# The leg never yields NaN: `sense_value_is_nan` is
	# false always (the default `default -> Float.NaN;`
	# leg, BuildingComp.java:2123, never fires here).
	proof["power_net_stored_value_not_nan"] = not bool(null_result.get("sense_value_is_nan", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildingCompSensePowerNetStoredProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
