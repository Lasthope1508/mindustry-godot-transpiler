extends Node

const main_scene := preload("res://scenes/Main.tscn")
const overdrive_projector_build_state := preload("res://src/game/SourceOverdriveProjectorBuildState.gd")
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

	# --- Pure boost scan (N2334): the eachBlock rect filter +
	# canOverdrive predicate (OverdriveProjector.java:106-111)
	# -- the N2194 advance already resets the charge at
	# reload, but the tick did nothing with the in-range
	# buildings; this pure adds the scan half, testing
	# candidate centers against the rect centered on the
	# projector with half-side realRange (`float realRange =
	# range + phaseHeat * phaseRangeBoost;`,
	# OverdriveProjector.java:107), INCLUSIVE on the edge
	# (the N2277 center-in-rect precedent: a rect corner is
	# IN), plus the Java pred half (`other.block.
	# canOverdrive`). The rect is in WORLD units directly
	# (BlockIndexer.java:345, no tilesize factor). A missing
	# can_overdrive reads TRUE -- the Java field default
	# (`public boolean canOverdrive = true;`,
	# Block.java:309). All pure calls below use the
	# projector at (100, 100) and the overdrive-projector
	# realRange values (range 80f, phaseRangeBoost 20f,
	# OverdriveProjector.java:24/28) unless noted. The pure
	# only REPORTS the targets -- applyBoost on them
	# (OverdriveProjector.java:110) waits for its own slice.
	var building_x := 100.0
	var building_y := 100.0
	var in_range_candidates: Array = [
		{"x": 100.0, "y": 100.0, "can_overdrive": true},
		{"x": 180.0, "y": 100.0, "can_overdrive": true},
		{"x": 20.0, "y": 100.0, "can_overdrive": true},
		{"x": 100.0, "y": 180.0, "can_overdrive": true},
		{"x": 180.0, "y": 180.0, "can_overdrive": true},
		{"x": 20.0, "y": 20.0, "can_overdrive": true},
		{"x": 110.0, "y": 110.0},
	]
	var admitted: Dictionary = overdrive_projector_build_state.source_overdrive_projector_supplied_boost_targets_state(in_range_candidates, 80.0, building_x, building_y)
	var admitted_list: Array = admitted.get("boost_targets", [])
	proof["scan_admits_in_range_overdrivable"] = admitted_list.size() == 7 and is_equal_approx(float(admitted.get("real_range", -1.0)), 80.0)

	var out_of_range_candidates: Array = [
		{"x": 180.01, "y": 100.0, "can_overdrive": true},
		{"x": 100.0, "y": 19.99, "can_overdrive": true},
		{"x": 200.0, "y": 200.0, "can_overdrive": true},
		{"y": 100.0, "can_overdrive": true},
		{"x": 100.0, "can_overdrive": true},
		{},
		"not-a-dict",
	]
	var excluded: Dictionary = overdrive_projector_build_state.source_overdrive_projector_supplied_boost_targets_state(out_of_range_candidates, 80.0, building_x, building_y)
	var excluded_list: Array = excluded.get("boost_targets", [])
	proof["scan_excludes_out_of_range"] = excluded_list.is_empty()

	var non_overdrivable_candidates: Array = [
		{"x": 100.0, "y": 100.0, "can_overdrive": false},
		{"x": 150.0, "y": 150.0, "can_overdrive": false},
		{"x": 180.0, "y": 100.0, "can_overdrive": false},
	]
	var non_overdrivable: Dictionary = overdrive_projector_build_state.source_overdrive_projector_supplied_boost_targets_state(non_overdrivable_candidates, 80.0, building_x, building_y)
	var non_overdrivable_list: Array = non_overdrivable.get("boost_targets", [])
	proof["scan_excludes_non_overdrivable"] = non_overdrivable_list.is_empty()

	# realRange = range + phaseHeat * phaseRangeBoost
	# (OverdriveProjector.java:107), overdrive-projector
	# defs: phaseHeat 0.0 -> 80.0, phaseHeat 0.5 -> 90.0,
	# phaseHeat 1.0 -> 100.0. A candidate at dx 85 is out
	# at heat 0 and in at heat 0.5; a candidate at dx 95 is
	# out at heat 0.5 and in at heat 1.0 -- the fold admits
	# further as phaseHeat grows.
	var edge_candidate: Array = [{"x": 185.0, "y": 100.0, "can_overdrive": true}]
	var far_candidate: Array = [{"x": 195.0, "y": 100.0, "can_overdrive": true}]
	var at_heat_zero: Dictionary = overdrive_projector_build_state.source_overdrive_projector_supplied_boost_targets_state(edge_candidate, 80.0, building_x, building_y)
	var at_heat_half: Dictionary = overdrive_projector_build_state.source_overdrive_projector_supplied_boost_targets_state(edge_candidate, 90.0, building_x, building_y)
	var far_at_heat_half: Dictionary = overdrive_projector_build_state.source_overdrive_projector_supplied_boost_targets_state(far_candidate, 90.0, building_x, building_y)
	var far_at_heat_full: Dictionary = overdrive_projector_build_state.source_overdrive_projector_supplied_boost_targets_state(far_candidate, 100.0, building_x, building_y)
	proof["scan_uses_real_range_with_phase_heat"] = Array(at_heat_zero.get("boost_targets", [])).is_empty() and Array(at_heat_half.get("boost_targets", [])).size() == 1 and Array(far_at_heat_half.get("boost_targets", [])).is_empty() and Array(far_at_heat_full.get("boost_targets", [])).size() == 1

	var empty_scan: Dictionary = overdrive_projector_build_state.source_overdrive_projector_supplied_boost_targets_state([], 80.0, building_x, building_y)
	proof["empty_candidates_empty"] = Array(empty_scan.get("boost_targets", [1])).is_empty() and is_equal_approx(float(empty_scan.get("real_range", -1.0)), 80.0)

	# --- Live tick: the overdrive-projector is an
	# OverdriveProjector with a power consumer (consumePower
	# 3.50f), placed live; the tick driver is called directly
	# (as the N2147/N2148/N2149/N2150/N2153/N2154/N2155/
	# N2156/N2157 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped
	# power_status -- the write-back itself is already proven
	# by N2142. Full power with a charged frame (charge 59.5,
	# heat 1.0): the N2194 advance resets the charge to 0 and
	# reports charge_ready, and the N2334 scan runs right
	# after it with the per-def projector params from the
	# block properties (range 80f, phaseRangeBoost 20f). The
	# projector sits at cell (28, 20), size 2, so its
	# building center is (228, 164) in world units (28 * 8 +
	# 4, 20 * 8 + 4, offset 4 for an even size). The frame
	# carries four boost candidates: two in range (dx 85, and
	# the rect corner at dx/dy 86 -- in the rect, out of any
	# circle), one out of range (dx 95), and one in range but
	# non-overdrivable (dx 50, can_overdrive false). Post-tick
	# phase_heat decays from 0.5 toward the folded
	# optionalEfficiency 0 (no phaseFabric in the frame), so
	# the live realRange is 80 + phase_heat * 20 with
	# phase_heat read back from the frame -- the key proves
	# the tick reports the two in-range overdrivable targets
	# when charge_ready. A second tick runs with charge not
	# ready (charge 0 + heat * 1 tick < reload 60), so Java
	# runs no scan at all and the tick reports an empty
	# target list at the live realRange.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var projector_cell := Vector2i(28, 20)
	var projector := Sprite2D.new()
	game.add_child(projector)
	game.call("record_placed_block", projector, blocks_by_id["overdrive-projector"], projector_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	overdrive_projector_build_state.source_overdrive_projector_bind_frame_state(projector, blocks_by_id["overdrive-projector"])
	var projector_frame: Dictionary = projector.get_meta(overdrive_projector_build_state.SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY, {})

	var live_center_x := 228.0
	var live_center_y := 164.0
	projector_frame["power_status"] = 1.0
	projector_frame["charge"] = 59.5
	projector_frame["heat"] = 1.0
	projector_frame["phase_heat"] = 0.5
	projector_frame["boost_candidates"] = [
		{"x": live_center_x + 85.0, "y": live_center_y, "can_overdrive": true},
		{"x": live_center_x + 86.0, "y": live_center_y + 86.0, "can_overdrive": true},
		{"x": live_center_x + 95.0, "y": live_center_y, "can_overdrive": true},
		{"x": live_center_x + 50.0, "y": live_center_y, "can_overdrive": false},
	]
	overdrive_projector_build_state.source_overdrive_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(overdrive_projector_build_state.SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY, {})
	var live_scan: Dictionary = projector_frame.get("last_boost_scan", {})
	var live_phase_heat: float = float(projector_frame.get("phase_heat", -1.0))
	var live_targets: Array = live_scan.get("boost_targets", [])
	var first_target: Dictionary = live_targets[0] if live_targets.size() > 0 else {}
	var second_target: Dictionary = live_targets[1] if live_targets.size() > 1 else {}
	overdrive_projector_build_state.source_overdrive_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(overdrive_projector_build_state.SOURCE_OVERDRIVE_PROJECTOR_BUILDING_META_KEY, {})
	var second_scan: Dictionary = projector_frame.get("last_boost_scan", {})
	proof["live_tick_scans_when_charge_ready"] = is_equal_approx(float(projector_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(live_scan.get("real_range", -1.0)), 80.0 + live_phase_heat * 20.0) and live_targets.size() == 2 and is_equal_approx(float(first_target.get("x", -1.0)), live_center_x + 85.0) and is_equal_approx(float(second_target.get("x", -1.0)), live_center_x + 86.0) and is_equal_approx(float(second_target.get("y", -1.0)), live_center_y + 86.0) and Array(second_scan.get("boost_targets", [1])).is_empty() and is_equal_approx(float(second_scan.get("real_range", -1.0)), 80.0 + float(projector_frame.get("phase_heat", -1.0)) * 20.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07OverdriveProjectorBoostScanProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
