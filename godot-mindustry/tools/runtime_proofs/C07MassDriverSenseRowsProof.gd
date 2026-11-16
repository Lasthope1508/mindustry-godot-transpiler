extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mass_driver_build_state := preload("res://src/game/SourceMassDriverBuildState.gd")
const building_sense_state := preload("res://src/game/SourceBuildingSenseState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# --- Sense rows (N2392): MassDriverBuild.sense()
	# (MassDriver.java:224-228). `public double
	# sense(LAccess sensor){` + `if(sensor ==
	# LAccess.progress) return Mathf.clamp(1f -
	# reloadCounter);` + `return super.sense(sensor);`.
	# reloadCounter is the frame value the N2237
	# advance tracks (`public float reloadCounter =
	# 0f;`, :118) and it counts DOWN from 1.0 to 0 --
	# fire() resets it (`reloadCounter = 1f;`, :292)
	# and the decay drains it (`reloadCounter =
	# Mathf.clamp(reloadCounter - edelta() / reload);`,
	# :143) -- so progress RISES 0->1 as the driver
	# charges: a fresh reloadCounter 1.0 (just shot)
	# reads progress 0, NOT 1, and a ready
	# reloadCounter 0.0 reads 1. The formula is
	# clamp(1f - reloadCounter), NOT reloadCounter /
	# reload. Mathf.clamp(value) clamps to [0, 1] (arc
	# Mathf.java:401-404), so the pure uses clampf.
	# super.sense is the BuildingComp switch
	# (BuildingComp.java:2093-2122, `return
	# switch(sensor){`), already modeled by the port
	# (SourceBuildingSenseState), so the pure takes the
	# caller's super.sense result as super_value; null
	# is the default branch (`default -> Float.NaN;
	# //gets converted to null in logic`).
	# Pure-only: the tick never calls sense -- sense is
	# called by logic, and the logic call site waits for
	# a logic-executor slice.

	# --- Progress zero: reloadCounter 1.0 -- just shot
	# -- reads 0.0, and the dispatch flag is true. A
	# reloadCounter past 1.0 clamps to 0.0 too.
	var zero_just_shot: Dictionary = mass_driver_build_state.source_mass_driver_sense_state("progress", 1.0)
	var zero_over: Dictionary = mass_driver_build_state.source_mass_driver_sense_state("progress", 1.5)
	proof["sense_progress_zero"] = bool(zero_just_shot.get("is_progress", false)) and is_equal_approx(float(zero_just_shot.get("value", -1.0)), 0.0) and bool(zero_over.get("is_progress", false)) and is_equal_approx(float(zero_over.get("value", -1.0)), 0.0)

	# --- Progress half: reloadCounter 0.5 reads 0.5 --
	# the driver is halfway through its reload.
	var half: Dictionary = mass_driver_build_state.source_mass_driver_sense_state("progress", 0.5)
	proof["sense_progress_half"] = is_equal_approx(float(half.get("value", -1.0)), 0.5)

	# --- Progress full: reloadCounter 0.0 -- ready to
	# fire -- reads 1.0. A negative reloadCounter
	# clamps to 1.0 too -- Mathf.clamp clamps to
	# [0, 1], it never returns a value outside the
	# range.
	var full_ready: Dictionary = mass_driver_build_state.source_mass_driver_sense_state("progress", 0.0)
	var full_under: Dictionary = mass_driver_build_state.source_mass_driver_sense_state("progress", -0.5)
	proof["sense_progress_full"] = is_equal_approx(float(full_ready.get("value", -1.0)), 1.0) and is_equal_approx(float(full_under.get("value", -1.0)), 1.0)

	# --- Super sensor: a non-progress sensor returns
	# the caller-supplied super.sense result, not the
	# reload ratio. health 80.0 (via the modeled
	# BuildingComp health case, `case health ->
	# health;`) and efficiency 0.75 (via `case
	# efficiency -> efficiency;`) both pass through
	# untouched, with the dispatch flag false -- even
	# though the reload ratio would be 0.5.
	var health_super: Dictionary = building_sense_state.sense_health_process_state(80.0, 100.0, 0.75, 1.0, 0.0, 8.0, false, 0.0)
	var health_sensed: Dictionary = mass_driver_build_state.source_mass_driver_sense_state("health", 0.5, health_super.get("health"))
	var efficiency_sensed: Dictionary = mass_driver_build_state.source_mass_driver_sense_state("efficiency", 0.5, health_super.get("efficiency"))
	proof["sense_super_sensor"] = not bool(health_sensed.get("is_progress", true)) and is_equal_approx(float(health_sensed.get("value", -1.0)), 80.0) and not bool(efficiency_sensed.get("is_progress", true)) and is_equal_approx(float(efficiency_sensed.get("value", -1.0)), 0.75)

	# --- Super default: an unknown sensor with no
	# super value returns null -- the super switch's
	# default branch (`default -> Float.NaN; //gets
	# converted to null in logic`). The default
	# super_value is null, so the caller passes nothing.
	var unknown_sensed: Dictionary = mass_driver_build_state.source_mass_driver_sense_state("not_a_sensor", 0.5)
	var unknown_explicit: Dictionary = mass_driver_build_state.source_mass_driver_sense_state("progress2", 0.5, null)
	proof["sense_super_default"] = not bool(unknown_sensed.get("is_progress", true)) and unknown_sensed.get("value", 0.0) == null and not bool(unknown_explicit.get("is_progress", true)) and unknown_explicit.get("value", 0.0) == null

	# --- Live frame values: a placed mass driver's
	# frame reload_counter feeds the progress value.
	# The frame starts at reload_counter 1.0 (just
	# shot) with efficiency 1.0; one N2237 advance tick
	# (delta 1.0, timeScale 1.0, reload 200f) drains
	# edelta / reload = 1.0 / 200 = 0.005, so the live
	# reload_counter is 0.995 and the sensed progress
	# is 1.0 - 0.995 = 0.005 -- the sense pure reads
	# live frame state, it just never runs inside the
	# tick.
	var mass_driver_cell := Vector2i(28, 21)
	var mass_driver := Sprite2D.new()
	game.add_child(mass_driver)
	game.call("record_placed_block", mass_driver, blocks_by_id["mass-driver"], mass_driver_cell)
	mass_driver_build_state.source_mass_driver_bind_frame_state(mass_driver, blocks_by_id["mass-driver"])
	var mass_driver_frame: Dictionary = mass_driver.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	mass_driver_frame["efficiency"] = 1.0
	mass_driver_frame["reload_counter"] = 1.0
	var this_pos: int = (28 << 16) | 21
	var item_order: Array = ["copper", "lead"]
	var unlinked: Dictionary = {"exists": false, "pos": -1, "is_mass_driver": false, "same_block": false, "same_team": false, "within_range": false, "item_capacity": 120, "items_total": 0, "state": "idle", "rotation": 90.0, "waiting_shooters": [], "x": 0.0, "y": 0.0}
	var advanced: Dictionary = mass_driver_build_state.source_mass_driver_update_tile_advance_state(mass_driver_frame, 1.0, 1.0, 120, 200.0, 5.0, 10, 5.5, 200.0, this_pos, 0.0, 0.0, unlinked, {}, item_order)
	mass_driver_frame["reload_counter"] = advanced.get("reload_counter", mass_driver_frame.get("reload_counter", -1.0))
	var live: Dictionary = mass_driver_build_state.source_mass_driver_sense_state("progress", float(mass_driver_frame.get("reload_counter", -1.0)))
	proof["sense_live_frame_values"] = is_equal_approx(float(mass_driver_frame.get("reload_counter", -1.0)), 0.995) and is_equal_approx(float(live.get("value", -1.0)), 0.005)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MassDriverSenseRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
