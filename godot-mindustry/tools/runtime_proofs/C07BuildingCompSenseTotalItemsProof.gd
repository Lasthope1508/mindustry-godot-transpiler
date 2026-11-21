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

	# --- BuildingComp.sense() `totalItems` leg (N2513):
	# BuildingComp.sense() (`public double sense(LAccess
	# sensor){`, BuildingComp.java:2093-2126) answers
	# `case totalItems -> items == null ? 0 : items.total();`
	# (:2107), with `items` the building's item module
	# (`@Nullable ItemModule items;`, BuildingComp.java:81)
	# and `items.total()` its total item count (`public int
	# total(){`, ItemModule.java:174 -- returns int). The two
	# params are the live input a future frame-stamp slice
	# will supply (the N2212/N2220 per-def-param
	# precedent): the live inventory total is not stamped
	# in the frame yet, so `items_is_null` is `items ==
	# null` (:2107, first branch of the ternary) and
	# `items_total` is `items.total()`. The value is
	# returned exactly: 0.0 when items is null, else
	# `float(items_total)` (Java `sense()` returns double;
	# the int widens exactly), no clamping, no rounding.
	# There is no driver tick line: the leg is a logic
	# read, not a tick write (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508/N2509/N2510/N2511/N2512
	# precedent); the proof calls the pure function
	# directly with synthetic inputs.

	# Null items: `items == null` reads 0.0 (first branch
	# of the ternary, :2107).
	var null_result: Dictionary = turret_build_state.source_building_comp_sense_total_items_state(true, 0)
	proof["total_items_null_num"] = bool(null_result.get("handled", false)) and float(null_result.get("sense_value", 1.0)) == 0.0 and not bool(null_result.get("sense_value_is_nan", true))

	# Empty items: total 0 with items present reads 0.0.
	var empty_result: Dictionary = turret_build_state.source_building_comp_sense_total_items_state(false, 0)
	proof["total_items_empty_num"] = bool(empty_result.get("handled", false)) and float(empty_result.get("sense_value", 1.0)) == 0.0 and not bool(empty_result.get("sense_value_is_nan", true))

	# Some items: total 25 reads back 25.0 exactly.
	var some_result: Dictionary = turret_build_state.source_building_comp_sense_total_items_state(false, 25)
	proof["total_items_some_num"] = bool(some_result.get("handled", false)) and float(some_result.get("sense_value", 0.0)) == 25.0 and not bool(some_result.get("sense_value_is_nan", true))

	# Large total: 1000 reads back 1000.0 exactly (the
	# int widens exactly to the double sense wire).
	var large_result: Dictionary = turret_build_state.source_building_comp_sense_total_items_state(false, 1000)
	proof["total_items_large_num"] = bool(large_result.get("handled", false)) and float(large_result.get("sense_value", 0.0)) == 1000.0 and not bool(large_result.get("sense_value_is_nan", true))

	# The leg always handles the fixed `totalItems` sensor.
	proof["total_items_handled_true"] = bool(null_result.get("handled", false))

	# The leg never yields NaN: `sense_value_is_nan` is
	# false always (the default `default -> Float.NaN;`
	# leg, BuildingComp.java:2123, never fires here).
	proof["total_items_value_not_nan"] = not bool(null_result.get("sense_value_is_nan", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildingCompSenseTotalItemsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
