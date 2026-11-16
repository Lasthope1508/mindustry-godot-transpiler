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

	# --- Pure narrow scan (N2335): the within / privileged
	# filter chained after the N2329 rect broad phase
	# (BlockIndexer.java:346) -- past the rect, Java admits
	# only `b.within(wx, wy, range + b.hitSize() / 2f) &&
	# pred.get(b) && !b.block.privileged`, with within a
	# STRICT dst2 < dst^2 circle (Position.java:44-46), so
	# exactly at range + hitSize/2 is OUT. The predicate
	# halves (damaged + not heal-suppressed) already live
	# in the N2242 heal scan, so this pure filters within
	# + privileged ONLY. All pure calls below use the
	# projector at (100, 100) and realRange 40.0 (the
	# mender range, Blocks.java:1924) unless noted.
	var building_x := 100.0
	var building_y := 100.0
	var within_candidates: Array = [
		{"x": 100.0, "y": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 130.0, "y": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 100.0, "y": 139.9, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 145.0, "y": 100.0, "hit_size": 16.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 100.0, "y": 100.0, "privileged": false, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
	]
	var admitted: Dictionary = mend_projector_build_state.source_mend_projector_supplied_heal_candidates_narrow_state(within_candidates, 40.0, building_x, building_y)
	var admitted_list: Array = admitted.get("candidates", [])
	# The fourth entry is the hitSize extension: dst 45
	# exceeds realRange 40 but is inside 40 + 16/2 = 48.
	proof["narrow_admits_within_range"] = admitted_list.size() == 5

	var beyond_candidates: Array = [
		{"x": 140.0, "y": 140.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 60.0, "y": 60.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 150.0, "y": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 145.0, "y": 100.0, "hit_size": 8.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
	]
	var excluded: Dictionary = mend_projector_build_state.source_mend_projector_supplied_heal_candidates_narrow_state(beyond_candidates, 40.0, building_x, building_y)
	var excluded_list: Array = excluded.get("candidates", [])
	# The rect corners (140, 140) and (60, 60) are IN the
	# N2329 rect but OUT of the within circle (dst 56.57 >
	# 40) -- the differentiator vs N2329. The fourth entry
	# is the hitSize shortfall: dst 45 exceeds 40 + 8/2 =
	# 44.
	proof["narrow_excludes_beyond_range_plus_hit_size"] = excluded_list.is_empty()

	# STRICT within (Position.java:44-46): exactly at the
	# limit is OUT, with and without a hitSize extension.
	var exact_candidates: Array = [
		{"x": 140.0, "y": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 100.0, "y": 60.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 148.0, "y": 100.0, "hit_size": 16.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
	]
	var exact_scan: Dictionary = mend_projector_build_state.source_mend_projector_supplied_heal_candidates_narrow_state(exact_candidates, 40.0, building_x, building_y)
	var exact_list: Array = exact_scan.get("candidates", [])
	proof["narrow_excludes_at_exact_range"] = exact_list.is_empty()

	# Privileged buildings are excluded even at the
	# projector's own center and even with a huge hitbox.
	var privileged_candidates: Array = [
		{"x": 100.0, "y": 100.0, "privileged": true, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 110.0, "y": 100.0, "hit_size": 100.0, "privileged": true, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
	]
	var privileged_scan: Dictionary = mend_projector_build_state.source_mend_projector_supplied_heal_candidates_narrow_state(privileged_candidates, 40.0, building_x, building_y)
	var privileged_list: Array = privileged_scan.get("candidates", [])
	proof["narrow_excludes_privileged"] = privileged_list.is_empty()

	# The pure only filters -- it never rewrites an entry:
	# hit_size / privileged / damaged / heal_suppressed /
	# max_health ride through untouched. It also does NOT
	# filter damaged / heal_suppressed itself (the N2242
	# heal scan does), so a healthy + suppressed in-circle
	# candidate is admitted here and dropped downstream.
	# A missing hit_size defaults to 0.0 (the N2226
	# precedent): the entry at dst 40 with no hit_size key
	# is OUT, which only the 0.0 default gives.
	var intact_entry: Dictionary = {"x": 110.0, "y": 110.0, "hit_size": 16.0, "privileged": false, "damaged": true, "heal_suppressed": false, "max_health": 100.0}
	var healthy_suppressed_entry: Dictionary = {"x": 120.0, "y": 120.0, "hit_size": 8.0, "privileged": false, "damaged": false, "heal_suppressed": true, "max_health": 200.0}
	var missing_hit_size_at_edge: Dictionary = {"x": 140.0, "y": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0}
	var intact_scan: Dictionary = mend_projector_build_state.source_mend_projector_supplied_heal_candidates_narrow_state([intact_entry, healthy_suppressed_entry, missing_hit_size_at_edge, {"y": 100.0}, {"x": 100.0}, {}, "not-a-dict"], 40.0, building_x, building_y)
	var intact_list: Array = intact_scan.get("candidates", [])
	var first_entry: Dictionary = intact_list[0] if intact_list.size() > 0 else {}
	var second_entry: Dictionary = intact_list[1] if intact_list.size() > 1 else {}
	proof["narrow_keeps_candidate_entries_intact"] = intact_list.size() == 2 and is_equal_approx(float(first_entry.get("hit_size", -1.0)), 16.0) and not bool(first_entry.get("privileged", true)) and bool(first_entry.get("damaged", false)) and not bool(first_entry.get("heal_suppressed", true)) and is_equal_approx(float(first_entry.get("max_health", -1.0)), 100.0) and is_equal_approx(float(second_entry.get("hit_size", -1.0)), 8.0) and not bool(second_entry.get("privileged", true)) and not bool(second_entry.get("damaged", true)) and bool(second_entry.get("heal_suppressed", false)) and is_equal_approx(float(second_entry.get("max_health", -1.0)), 200.0)

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
	# frame carries four heal candidates: one in the within
	# circle (dx 45), the rect corner at dx/dy 46 (in the
	# rect, out of the circle -- excluded since N2335), one
	# privileged in-circle candidate (dx 30 -- excluded since
	# N2335), and one out of range (dx 60). Post-tick
	# phase_heat decays from 0.5 toward the folded
	# optionalEfficiency 0 (no silicon in the frame), so the
	# live realRange is 40 + phase_heat * 20 with phase_heat
	# read back from the frame -- the key proves the tick
	# passes the narrowed list into the heal scan (ONE heal,
	# at the live phase_heat fold), not the rect-only list.
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
		{"x": live_center_x + 30.0, "y": live_center_y, "privileged": true, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": live_center_x + 60.0, "y": live_center_y, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
	]
	mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	var live_scan: Dictionary = projector_frame.get("last_heal_scan", {})
	var live_phase_heat: float = float(projector_frame.get("phase_heat", -1.0))
	var live_amounts: Array = live_scan.get("heal_amounts", [])
	var live_expected_heal: float = 100.0 * (4.0 + live_phase_heat * 4.0) / 100.0 * 1.0
	proof["live_tick_passes_narrowed_candidates"] = is_equal_approx(float(projector_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(projector_frame.get("charge", -1.0)), 0.0) and bool(live_scan.get("scanned", false)) and bool(live_scan.get("any", false)) and is_equal_approx(float(live_scan.get("real_range", -1.0)), 40.0 + live_phase_heat * 20.0) and live_amounts.size() == 1 and is_equal_approx(float(live_amounts[0]), live_expected_heal)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MendProjectorHealScanNarrowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
