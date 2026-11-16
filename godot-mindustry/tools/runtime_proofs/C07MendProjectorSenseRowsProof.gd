extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mend_projector_build_state := preload("res://src/game/SourceMendProjectorBuildState.gd")
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

	# --- Sense rows (N2383): MendBuild.sense()
	# (MendProjector.java:126-129). `public double
	# sense(LAccess sensor){` + `if(sensor ==
	# LAccess.progress) return Mathf.clamp(charge /
	# reload);` + `return super.sense(sensor);`.
	# charge is the frame value the N2193 advance tracks
	# (`public float heat, charge =
	# Mathf.random(reload), phaseHeat, smoothEfficiency;`,
	# :85); reload is per-def (mender 200f,
	# mend-projector 250f, Blocks.java:1923/1936; the
	# class default is `public float reload = 250f;`,
	# :26). Mathf.clamp(value) clamps to [0, 1] (arc
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

	# --- Progress zero: charge 0.0 at any reload reads
	# 0.0, and the dispatch flag is true.
	var zero_mender: Dictionary = mend_projector_build_state.source_mend_projector_sense_state("progress", 0.0, 200.0)
	var zero_big: Dictionary = mend_projector_build_state.source_mend_projector_sense_state("progress", 0.0, 250.0)
	proof["sense_progress_zero"] = bool(zero_mender.get("is_progress", false)) and is_equal_approx(float(zero_mender.get("value", -1.0)), 0.0) and bool(zero_big.get("is_progress", false)) and is_equal_approx(float(zero_big.get("value", -1.0)), 0.0)

	# --- Progress half: charge 100.0 at the mender
	# reload 200f reads 0.5, and charge 125.0 at the
	# mend-projector reload 250f reads 0.5 too -- the
	# reload is the per-def explicit input, not a
	# constant.
	var half_mender: Dictionary = mend_projector_build_state.source_mend_projector_sense_state("progress", 100.0, 200.0)
	var half_big: Dictionary = mend_projector_build_state.source_mend_projector_sense_state("progress", 125.0, 250.0)
	proof["sense_progress_half"] = is_equal_approx(float(half_mender.get("value", -1.0)), 0.5) and is_equal_approx(float(half_big.get("value", -1.0)), 0.5)

	# --- Progress clamped: charge past the reload
	# clamps to 1.0 (charge 300.0 at reload 200f), and
	# a negative charge clamps to 0.0 -- Mathf.clamp
	# clamps to [0, 1], it never returns a value
	# outside the range.
	var over: Dictionary = mend_projector_build_state.source_mend_projector_sense_state("progress", 300.0, 200.0)
	var under: Dictionary = mend_projector_build_state.source_mend_projector_sense_state("progress", -50.0, 200.0)
	proof["sense_progress_clamped"] = is_equal_approx(float(over.get("value", -1.0)), 1.0) and is_equal_approx(float(under.get("value", -1.0)), 0.0)

	# --- Super sensor: a non-progress sensor returns
	# the caller-supplied super.sense result, not the
	# charge ratio. health 80.0 (via the modeled
	# BuildingComp health case, `case health ->
	# health;`) and efficiency 0.75 (via `case
	# efficiency -> efficiency;`) both pass through
	# untouched, with the dispatch flag false -- even
	# though the charge ratio would be 0.5.
	var health_super: Dictionary = building_sense_state.sense_health_process_state(80.0, 100.0, 0.75, 1.0, 0.0, 8.0, false, 0.0)
	var health_sensed: Dictionary = mend_projector_build_state.source_mend_projector_sense_state("health", 100.0, 200.0, health_super.get("health"))
	var efficiency_sensed: Dictionary = mend_projector_build_state.source_mend_projector_sense_state("efficiency", 100.0, 200.0, health_super.get("efficiency"))
	proof["sense_super_sensor"] = not bool(health_sensed.get("is_progress", true)) and is_equal_approx(float(health_sensed.get("value", -1.0)), 80.0) and not bool(efficiency_sensed.get("is_progress", true)) and is_equal_approx(float(efficiency_sensed.get("value", -1.0)), 0.75)

	# --- Super default: an unknown sensor with no
	# super value returns null -- the super switch's
	# default branch (`default -> Float.NaN; //gets
	# converted to null in logic`). The default
	# super_value is null, so the caller passes nothing.
	var unknown_sensed: Dictionary = mend_projector_build_state.source_mend_projector_sense_state("not_a_sensor", 100.0, 200.0)
	var unknown_explicit: Dictionary = mend_projector_build_state.source_mend_projector_sense_state("progress2", 100.0, 200.0, null)
	proof["sense_super_default"] = not bool(unknown_sensed.get("is_progress", true)) and unknown_sensed.get("value", 0.0) == null and not bool(unknown_explicit.get("is_progress", true)) and unknown_explicit.get("value", 0.0) == null

	# --- Live frame values: a placed mender's frame
	# charge feeds the progress value. The frame starts
	# at charge 100.0 with heat 1.0 and efficiency 1.0;
	# one N2193 advance tick (delta 1.0) adds heat *
	# delta * timeScale = 1.0, so the live charge is
	# 101.0 and the sensed progress at the mender reload
	# 200f is 0.505 -- the sense pure reads live frame
	# state, it just never runs inside the tick.
	var mend_projector_cell := Vector2i(28, 21)
	var mend_projector := Sprite2D.new()
	game.add_child(mend_projector)
	game.call("record_placed_block", mend_projector, blocks_by_id["mender"], mend_projector_cell)
	mend_projector_build_state.source_mend_projector_bind_frame_state(mend_projector, blocks_by_id["mender"])
	var mend_projector_frame: Dictionary = mend_projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	mend_projector_frame["efficiency"] = 1.0
	mend_projector_frame["heat"] = 1.0
	mend_projector_frame["charge"] = 100.0
	var mender_reload: float = float(blocks_by_id["mender"].properties.get("reload", 200.0))
	mend_projector_build_state.source_mend_projector_update_tile_advance_state(mend_projector_frame, mender_reload, 1.0)
	var live: Dictionary = mend_projector_build_state.source_mend_projector_sense_state("progress", float(mend_projector_frame.get("charge", -1.0)), mender_reload)
	proof["sense_live_frame_values"] = is_equal_approx(mender_reload, 200.0) and is_equal_approx(float(mend_projector_frame.get("charge", -1.0)), 101.0) and is_equal_approx(float(live.get("value", -1.0)), 0.505)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MendProjectorSenseRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
