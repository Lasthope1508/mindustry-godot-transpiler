extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mend_projector_build_state := preload("res://src/game/SourceMendProjectorBuildState.gd")
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

	# --- Pure range scan (N2329): the eachBlock rect filter
	# (MendProjector.java:112) -- the N2242 heal scan already
	# filters damaged + not heal-suppressed and folds the
	# heal, but takes its candidate list explicit with NO
	# range filter; this pure adds the range half, testing
	# candidate centers against the rect centered on the
	# projector with half-side realRange (`float realRange =
	# range + phaseHeat * phaseRangeBoost;`,
	# MendProjector.java:107), INCLUSIVE on the edge (the
	# N2277 center-in-rect precedent: a rect corner is IN).
	# The rect is in WORLD units directly
	# (BlockIndexer.java:345, no tilesize factor). All pure
	# calls below use the projector at (100, 100) and the
	# mender realRange values (range 40f, phaseRangeBoost
	# 20f, Blocks.java:1924/1927) unless noted.
	var building_x := 100.0
	var building_y := 100.0
	var in_range_candidates: Array = [
		{"x": 100.0, "y": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 140.0, "y": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 60.0, "y": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 100.0, "y": 140.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 140.0, "y": 140.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 60.0, "y": 60.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
	]
	var admitted: Dictionary = mend_projector_build_state.source_mend_projector_supplied_heal_candidates_state(in_range_candidates, 40.0, building_x, building_y)
	var admitted_list: Array = admitted.get("candidates", [])
	proof["scan_admits_in_range"] = admitted_list.size() == 6

	var out_of_range_candidates: Array = [
		{"x": 140.01, "y": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 100.0, "y": 59.99, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 200.0, "y": 200.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"y": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{},
		"not-a-dict",
	]
	var excluded: Dictionary = mend_projector_build_state.source_mend_projector_supplied_heal_candidates_state(out_of_range_candidates, 40.0, building_x, building_y)
	var excluded_list: Array = excluded.get("candidates", [])
	proof["scan_excludes_out_of_range"] = excluded_list.is_empty()

	# realRange = range + phaseHeat * phaseRangeBoost
	# (MendProjector.java:107), mender defs: phaseHeat 0.0
	# -> 40.0, phaseHeat 0.5 -> 50.0, phaseHeat 1.0 -> 60.0.
	# A candidate at dx 45 is out at heat 0 and in at heat
	# 0.5; a candidate at dx 55 is out at heat 0.5 and in
	# at heat 1.0 -- the fold admits further as phaseHeat
	# grows.
	var edge_candidate: Array = [{"x": 145.0, "y": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0}]
	var far_candidate: Array = [{"x": 155.0, "y": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0}]
	var at_heat_zero: Dictionary = mend_projector_build_state.source_mend_projector_supplied_heal_candidates_state(edge_candidate, 40.0, building_x, building_y)
	var at_heat_half: Dictionary = mend_projector_build_state.source_mend_projector_supplied_heal_candidates_state(edge_candidate, 50.0, building_x, building_y)
	var far_at_heat_half: Dictionary = mend_projector_build_state.source_mend_projector_supplied_heal_candidates_state(far_candidate, 50.0, building_x, building_y)
	var far_at_heat_full: Dictionary = mend_projector_build_state.source_mend_projector_supplied_heal_candidates_state(far_candidate, 60.0, building_x, building_y)
	proof["scan_uses_real_range_with_phase_heat"] = Array(at_heat_zero.get("candidates", [])).is_empty() and Array(at_heat_half.get("candidates", [])).size() == 1 and Array(far_at_heat_half.get("candidates", [])).is_empty() and Array(far_at_heat_full.get("candidates", [])).size() == 1

	# The pure only filters -- it never rewrites an entry:
	# damaged / heal_suppressed / max_health ride through
	# untouched. It also does NOT filter damaged /
	# heal_suppressed itself (the N2242 heal scan does), so
	# a healthy + suppressed in-range candidate is admitted
	# here and dropped downstream.
	var intact_entry: Dictionary = {"x": 110.0, "y": 110.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0}
	var healthy_suppressed_entry: Dictionary = {"x": 120.0, "y": 120.0, "damaged": false, "heal_suppressed": true, "max_health": 200.0}
	var intact_scan: Dictionary = mend_projector_build_state.source_mend_projector_supplied_heal_candidates_state([intact_entry, healthy_suppressed_entry], 40.0, building_x, building_y)
	var intact_list: Array = intact_scan.get("candidates", [])
	var first_entry: Dictionary = intact_list[0] if intact_list.size() > 0 else {}
	var second_entry: Dictionary = intact_list[1] if intact_list.size() > 1 else {}
	proof["scan_keeps_candidate_entries_intact"] = intact_list.size() == 2 and bool(first_entry.get("damaged", false)) and not bool(first_entry.get("heal_suppressed", true)) and is_equal_approx(float(first_entry.get("max_health", -1.0)), 100.0) and not bool(second_entry.get("damaged", true)) and bool(second_entry.get("heal_suppressed", false)) and is_equal_approx(float(second_entry.get("max_health", -1.0)), 200.0)

	var empty_scan: Dictionary = mend_projector_build_state.source_mend_projector_supplied_heal_candidates_state([], 40.0, building_x, building_y)
	proof["empty_candidates_empty"] = Array(empty_scan.get("candidates", [1])).is_empty()

	# --- Live tick: the mender is a MendProjector with a power
	# consumer (consumePower 0.3f), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/N2150/
	# N2153/N2154/N2155/N2156 proofs do), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. Full power
	# with a charged frame (charge 199.5, heat 1.0): the N2193
	# advance resets the charge to 0, and the N2242 scan runs
	# right after it (scanned true) with the per-def mender
	# params from the block properties (range 40f,
	# phaseRangeBoost 20f). The mender sits at cell (28, 20),
	# size 1, so its building center is (224, 160) in world
	# units (28 * 8, 20 * 8, offset 0 for an odd size). The
	# frame carries three heal candidates: two in range (dx
	# 45, and the rect corner at dx/dy 46 -- in the rect, out
	# of any circle) and one out of range (dx 60). Post-tick
	# phase_heat decays from 0.5 toward the folded
	# optionalEfficiency 0 (no silicon in the frame), so the
	# live realRange is 40 + phase_heat * 20 with phase_heat
	# read back from the frame -- the key proves the tick
	# passes the ranged list into the heal scan (two heals,
	# both at the live phase_heat fold), not [].
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var projector_cell := Vector2i(28, 20)
	var projector := Sprite2D.new()
	game.add_child(projector)
	game.call("record_placed_block", projector, blocks_by_id["mender"], projector_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	mend_projector_build_state.source_mend_projector_bind_frame_state(projector, blocks_by_id["mender"])
	var projector_frame: Dictionary = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})

	var live_center_x := 224.0
	var live_center_y := 160.0
	projector_frame["power_status"] = 1.0
	projector_frame["charge"] = 199.5
	projector_frame["heat"] = 1.0
	projector_frame["phase_heat"] = 0.5
	projector_frame["heal_candidates"] = [
		{"x": live_center_x + 45.0, "y": live_center_y, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": live_center_x + 46.0, "y": live_center_y + 46.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": live_center_x + 60.0, "y": live_center_y, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
	]
	mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	var live_scan: Dictionary = projector_frame.get("last_heal_scan", {})
	var live_phase_heat: float = float(projector_frame.get("phase_heat", -1.0))
	var live_amounts: Array = live_scan.get("heal_amounts", [])
	var live_expected_heal: float = 100.0 * (4.0 + live_phase_heat * 4.0) / 100.0 * 1.0
	proof["live_tick_passes_ranged_candidates"] = is_equal_approx(float(projector_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(projector_frame.get("charge", -1.0)), 0.0) and bool(live_scan.get("scanned", false)) and bool(live_scan.get("any", false)) and is_equal_approx(float(live_scan.get("real_range", -1.0)), 40.0 + live_phase_heat * 20.0) and live_amounts.size() == 2 and is_equal_approx(float(live_amounts[0]), live_expected_heal) and is_equal_approx(float(live_amounts[1]), live_expected_heal)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MendProjectorHealScanRangeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
