extends Node

const main_scene := preload("res://scenes/Main.tscn")
const launch_pad_build_state := preload("res://src/game/SourceLaunchPadBuildState.gd")
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

	# --- Sense rows (N2389): LaunchPadBuild.sense()
	# (LaunchPad.java:98-101). `public double
	# sense(LAccess sensor){` + `if(sensor ==
	# LAccess.progress) return Mathf.clamp(
	# launchCounter / launchTime);` + `return
	# super.sense(sensor);`. launchCounter is the
	# frame value the N2238 advance tracks
	# (`public float launchCounter;`, :84);
	# launchTime is per-def (launch-pad 60f * 20,
	# advanced-launch-pad 60f * 30, Blocks.java:
	# 6794/6804; the class default is `public float
	# launchTime = 1f;`, :32). Mathf.clamp(value)
	# clamps to [0, 1] (arc Mathf.java:401-404), so
	# the pure uses clampf. super.sense is the
	# BuildingComp switch (BuildingComp.java:2093-
	# 2122, `return switch(sensor){`), already
	# modeled by the port (SourceBuildingSenseState),
	# so the pure takes the caller's super.sense
	# result as super_value; null is the default
	# branch (`default -> Float.NaN; //gets
	# converted to null in logic`). Pure-only: the
	# tick never calls sense -- sense is called by
	# logic, and the logic call site waits for a
	# logic-executor slice.

	# --- Progress zero: launchCounter 0.0 at any
	# launchTime reads 0.0, and the dispatch flag is
	# true -- including the class-default edge
	# (launchTime 1f with launchCounter 0).
	var zero_pad: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("progress", 0.0, 1200.0)
	var zero_advanced: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("progress", 0.0, 1800.0)
	var zero_default: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("progress", 0.0, 1.0)
	proof["sense_progress_zero"] = bool(zero_pad.get("is_progress", false)) and is_equal_approx(float(zero_pad.get("value", -1.0)), 0.0) and bool(zero_advanced.get("is_progress", false)) and is_equal_approx(float(zero_advanced.get("value", -1.0)), 0.0) and bool(zero_default.get("is_progress", false)) and is_equal_approx(float(zero_default.get("value", -1.0)), 0.0)

	# --- Progress half: launchCounter 600.0 at the
	# launch-pad launchTime 1200f reads 0.5, and
	# launchCounter 900.0 at the advanced-launch-pad
	# launchTime 1800f reads 0.5 too -- the
	# launchTime is the per-def explicit input, not
	# a constant.
	var half_pad: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("progress", 600.0, 1200.0)
	var half_advanced: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("progress", 900.0, 1800.0)
	proof["sense_progress_half"] = is_equal_approx(float(half_pad.get("value", -1.0)), 0.5) and is_equal_approx(float(half_advanced.get("value", -1.0)), 0.5)

	# --- Progress clamped: a counter past the
	# launchTime clamps to 1.0 (launchCounter 1500.0
	# at launchTime 1200f), and a negative counter
	# clamps to 0.0 -- Mathf.clamp clamps to [0, 1],
	# it never returns a value outside the range.
	var over: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("progress", 1500.0, 1200.0)
	var under: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("progress", -60.0, 1200.0)
	proof["sense_progress_clamped"] = is_equal_approx(float(over.get("value", -1.0)), 1.0) and is_equal_approx(float(under.get("value", -1.0)), 0.0)

	# --- Super sensor: a non-progress sensor returns
	# the caller-supplied super.sense result, not the
	# launchCounter ratio. health 80.0 (via the modeled
	# BuildingComp health case, `case health ->
	# health;`) and efficiency 0.75 (via `case
	# efficiency -> efficiency;`) both pass through
	# untouched, with the dispatch flag false -- even
	# though the launchCounter ratio would be 0.5.
	var health_super: Dictionary = building_sense_state.sense_health_process_state(80.0, 100.0, 0.75, 1.0, 0.0, 8.0, false, 0.0)
	var health_sensed: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("health", 600.0, 1200.0, health_super.get("health"))
	var efficiency_sensed: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("efficiency", 600.0, 1200.0, health_super.get("efficiency"))
	proof["sense_super_sensor"] = not bool(health_sensed.get("is_progress", true)) and is_equal_approx(float(health_sensed.get("value", -1.0)), 80.0) and not bool(efficiency_sensed.get("is_progress", true)) and is_equal_approx(float(efficiency_sensed.get("value", -1.0)), 0.75)

	# --- Super default: an unknown sensor with no
	# super value returns null -- the super switch's
	# default branch (`default -> Float.NaN; //gets
	# converted to null in logic`). The default
	# super_value is null, so the caller passes nothing.
	var unknown_sensed: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("not_a_sensor", 600.0, 1200.0)
	var unknown_explicit: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("progress2", 600.0, 1200.0, null)
	proof["sense_super_default"] = not bool(unknown_sensed.get("is_progress", true)) and unknown_sensed.get("value", 0.0) == null and not bool(unknown_explicit.get("is_progress", true)) and unknown_explicit.get("value", 0.0) == null

	# --- Live frame values: a placed launch-pad's
	# frame launchCounter feeds the progress value.
	# The frame starts at launchCounter 600.0 with
	# efficiency 1.0 and the driver launchTime stamp
	# 1200f (launch-pad, Blocks.java:6794 -- the
	# catalog carries no launchTime, so the driver
	# stamps it per def); one N2238 advance tick
	# (delta 1.0, timeScale 1.0) adds edelta =
	# efficiency * delta * timeScale = 1.0, so the
	# live counter is 601.0 and the sensed progress
	# at launchTime 1200f is 601.0 / 1200.0 -- the
	# sense pure reads live frame state, it just
	# never runs inside the tick. The pad holds no
	# items, so no launch fires.
	var launch_pad_cell := Vector2i(28, 21)
	var launch_pad := Sprite2D.new()
	game.add_child(launch_pad)
	game.call("record_placed_block", launch_pad, blocks_by_id["launch-pad"], launch_pad_cell)
	launch_pad_build_state.source_launch_pad_bind_frame_state(launch_pad, blocks_by_id["launch-pad"])
	var launch_pad_frame: Dictionary = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	launch_pad_frame["efficiency"] = 1.0
	launch_pad_frame["launch_counter"] = 600.0
	launch_pad_frame["launch_time"] = 60.0 * 20.0
	var advanced: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state(launch_pad_frame, 1.0, 1.0, 100)
	launch_pad_frame["launch_counter"] = float(advanced.get("launch_counter", -1.0))
	launch_pad_frame["items"] = advanced.get("items", {})
	var live: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("progress", float(launch_pad_frame.get("launch_counter", -1.0)), float(launch_pad_frame.get("launch_time", 1.0)))
	proof["sense_live_frame_values"] = is_equal_approx(float(launch_pad_frame.get("launch_time", -1.0)), 1200.0) and is_equal_approx(float(launch_pad_frame.get("launch_counter", -1.0)), 601.0) and bool(advanced.get("launched", true)) == false and is_equal_approx(float(live.get("value", -1.0)), 601.0 / 1200.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadSenseRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
