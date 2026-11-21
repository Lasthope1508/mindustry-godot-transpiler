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

	# --- BuildingComp.sense() `health` leg (N2512):
	# BuildingComp.sense() (`public double sense(LAccess
	# sensor){`, BuildingComp.java:2093-2126) answers
	# `case health -> health;` (:2101), with `health` the
	# building's current health field (`float health;`,
	# HealthComp.java:11 -- BuildingComp mixes HealthComp).
	# The live health is passed in as a param (the
	# N2212/N2220 per-def-param precedent): the live
	# building health is not stamped in the frame yet, so a
	# future frame-stamp slice will supply it. The value is
	# returned exactly, no clamping, no rounding, no
	# healthf() conversion (`healthf()` is a different
	# accessor, HealthComp.java:20 -- NOT this leg). There
	# is no driver tick line: the leg is a logic read, not a
	# tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511
	# precedent); the proof calls the pure function
	# directly with synthetic inputs.

	# Full health: 100.0 reads back 100.0 exactly.
	var full_result: Dictionary = turret_build_state.source_building_comp_sense_health_state(100.0)
	proof["health_full_num"] = bool(full_result.get("handled", false)) and float(full_result.get("sense_value", 0.0)) == 100.0 and not bool(full_result.get("sense_value_is_nan", true))

	# Damaged health: 37.5 reads back 37.5 exactly.
	var damaged_result: Dictionary = turret_build_state.source_building_comp_sense_health_state(37.5)
	proof["health_damaged_num"] = bool(damaged_result.get("handled", false)) and float(damaged_result.get("sense_value", 0.0)) == 37.5 and not bool(damaged_result.get("sense_value_is_nan", true))

	# Zero health: 0.0 reads back 0.0.
	var zero_result: Dictionary = turret_build_state.source_building_comp_sense_health_state(0.0)
	proof["health_zero_num"] = bool(zero_result.get("handled", false)) and float(zero_result.get("sense_value", 1.0)) == 0.0 and not bool(zero_result.get("sense_value_is_nan", true))

	# Fractional precision: 12.25 reads back 12.25
	# exactly (no rounding, no healthf() conversion).
	var fractional_result: Dictionary = turret_build_state.source_building_comp_sense_health_state(12.25)
	proof["health_fractional_num"] = bool(fractional_result.get("handled", false)) and float(fractional_result.get("sense_value", 0.0)) == 12.25 and not bool(fractional_result.get("sense_value_is_nan", true))

	# The leg always handles the fixed `health` sensor.
	proof["health_handled_true"] = bool(full_result.get("handled", false))

	# The leg never yields NaN: `sense_value_is_nan` is
	# false always (the default `default -> Float.NaN;`
	# leg, BuildingComp.java:2123, never fires here).
	proof["health_value_not_nan"] = not bool(full_result.get("sense_value_is_nan", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildingCompSenseHealthProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
