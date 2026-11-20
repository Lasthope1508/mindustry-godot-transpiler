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

	# --- BuildingComp.sense() `dead` leg (N2511):
	# BuildingComp.sense() (`public double sense(LAccess
	# sensor){`, BuildingComp.java:2093-2126) answers
	# `case dead -> !isValid() ? 1 : 0;` (:2098), with
	# `isValid()` `public boolean isValid(){` /
	# `return tile.build == self() && !dead();`
	# (:2030-2032). The two conjuncts are passed in as
	# params (the N2212/N2220 per-def-param precedent):
	# `tile_build_is_self` is `tile.build == self()`
	# (:2031, first conjunct) and `is_dead` is `dead()`
	# (:2031, second conjunct, negated in `isValid()`).
	# There is no driver tick line: the leg is a logic
	# read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510
	# precedent); the proof calls the pure function
	# directly with synthetic inputs.

	# Dead when tile.build is not self: `isValid()` fails
	# on its first conjunct, so the leg reads 1.0.
	var not_self_result: Dictionary = turret_build_state.source_building_comp_sense_dead_state(false, false)
	proof["dead_tile_not_self_num"] = bool(not_self_result.get("handled", false)) and float(not_self_result.get("sense_value", 0.0)) == 1.0 and not bool(not_self_result.get("sense_value_is_nan", true))

	# Dead when is_dead: `isValid()` fails on its second
	# conjunct (`!dead()`), so the leg reads 1.0.
	var is_dead_result: Dictionary = turret_build_state.source_building_comp_sense_dead_state(true, true)
	proof["dead_is_dead_num"] = bool(is_dead_result.get("handled", false)) and float(is_dead_result.get("sense_value", 0.0)) == 1.0 and not bool(is_dead_result.get("sense_value_is_nan", true))

	# Alive when valid: both conjuncts hold, so `isValid()`
	# is true and the leg reads 0.0.
	var alive_result: Dictionary = turret_build_state.source_building_comp_sense_dead_state(true, false)
	proof["alive_valid_zero"] = bool(alive_result.get("handled", false)) and float(alive_result.get("sense_value", 1.0)) == 0.0 and not bool(alive_result.get("sense_value_is_nan", true))

	# The leg always handles the fixed `dead` sensor.
	proof["dead_handled_true"] = bool(alive_result.get("handled", false))

	# The leg never yields NaN: `sense_value_is_nan` is
	# false always (the default `default -> Float.NaN;`
	# leg, BuildingComp.java:2123, never fires here).
	proof["dead_value_not_nan"] = not bool(alive_result.get("sense_value_is_nan", true))

	# Both inputs invalid: tile.build is not self AND
	# dead -- `!isValid()` still reads 1.0 (the
	# short-circuit shape of `tile.build == self() &&
	# !dead()`).
	var both_invalid_result: Dictionary = turret_build_state.source_building_comp_sense_dead_state(false, true)
	proof["dead_both_invalid_num"] = bool(both_invalid_result.get("handled", false)) and float(both_invalid_result.get("sense_value", 0.0)) == 1.0 and not bool(both_invalid_result.get("sense_value_is_nan", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildingCompSenseDeadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
