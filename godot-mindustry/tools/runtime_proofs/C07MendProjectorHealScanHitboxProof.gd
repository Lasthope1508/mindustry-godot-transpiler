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

	# --- Pure hitbox broad phase (N2350): the QuadTree
	# hitbox overlap filter (BlockIndexer.java:345) -- the
	# N2329 pure tested candidate CENTERS against the
	# eachBlock rect inclusively (the N2277 precedent), an
	# approximation that dropped large-hitbox buildings
	# whose center sat outside the rect but within range +
	# hitSize/2 before the N2335 narrow check ever saw
	# them. Java's buildings.intersect is a QuadTree HITBOX
	# overlap query: the QuadTree admits a building whose
	# hitbox (a hitSize-sided square centered on the
	# building, BuildingComp.java:2293) STRICTLY overlaps
	# the query rect (QuadTree.java:190-191 /
	# Rect.java:274-276), so a hitbox edge exactly touching
	# the rect edge does NOT overlap. The rect is in WORLD
	# units directly (BlockIndexer.java:345, no tilesize
	# factor). All pure calls below use the projector at
	# (100, 100) and realRange 40.0 (the mender range,
	# Blocks.java:1924) unless noted.
	var building_x := 100.0
	var building_y := 100.0
	var straddling_candidates: Array = [
		{"x": 144.0, "y": 100.0, "hit_size": 16.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 100.0, "y": 56.0, "hit_size": 16.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 144.0, "y": 144.0, "hit_size": 16.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
	]
	var straddling: Dictionary = mend_projector_build_state.source_mend_projector_heal_candidates_hitbox_state(straddling_candidates, 40.0, building_x, building_y)
	var straddling_list: Array = straddling.get("candidates", [])
	# Every center sits OUTSIDE the rect (dx 44 / dy -44 /
	# dx+dy 44) -- the old N2329 center test dropped all
	# three -- but each hitbox straddles the edge, so
	# Java's intersect admits them.
	proof["hitbox_admits_straddling_hitbox"] = straddling_list.size() == 3

	var edge_candidates: Array = [
		{"x": 140.0, "y": 100.0, "hit_size": 8.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 60.0, "y": 100.0, "hit_size": 8.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 140.0, "y": 140.0, "hit_size": 8.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
	]
	var edge_scan: Dictionary = mend_projector_build_state.source_mend_projector_heal_candidates_hitbox_state(edge_candidates, 40.0, building_x, building_y)
	var edge_list: Array = edge_scan.get("candidates", [])
	# A real building always has hitSize >= 8 (size 1 *
	# tilesize 8, BuildingComp.java:2048), so a building
	# centered exactly on the rect edge is admitted -- its
	# hitbox overlaps the rect.
	proof["hitbox_admits_edge_hitbox"] = edge_list.size() == 3

	var degenerate_candidates: Array = [
		{"x": 140.0, "y": 100.0, "hit_size": 0.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 100.0, "y": 60.0, "hit_size": 0.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 140.0, "y": 140.0, "hit_size": 0.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 60.0, "y": 60.0, "hit_size": 0.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
	]
	var degenerate_scan: Dictionary = mend_projector_build_state.source_mend_projector_heal_candidates_hitbox_state(degenerate_candidates, 40.0, building_x, building_y)
	var degenerate_list: Array = degenerate_scan.get("candidates", [])
	# STRICT overlap (Rect.java:274-276): a degenerate
	# hitSize-0 hitbox on the edge or corner only touches
	# the rect, so it is dropped -- the old N2329 center
	# test admitted all four.
	proof["hitbox_drops_degenerate_edge_hitbox"] = degenerate_list.is_empty()

	# A missing hit_size defaults to 0.0 (the N2335 narrow
	# precedent): a point strictly inside is admitted, a
	# point exactly on the edge is dropped -- only the 0.0
	# default gives that split. A missing x or y key and a
	# non-Dictionary entry are excluded the same way, and
	# admitted entries keep their keys intact (the hit_size
	# rides through untouched).
	var default_candidates: Array = [
		{"x": 110.0, "y": 110.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 140.0, "y": 100.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": 100.0, "y": 100.0, "hit_size": 16.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"y": 100.0},
		{"x": 100.0},
		{},
		"not-a-dict",
	]
	var default_scan: Dictionary = mend_projector_build_state.source_mend_projector_heal_candidates_hitbox_state(default_candidates, 40.0, building_x, building_y)
	var default_list: Array = default_scan.get("candidates", [])
	var default_second: Dictionary = default_list[1] if default_list.size() > 1 else {}
	proof["hitbox_defaults_missing_hit_size"] = default_list.size() == 2 and is_equal_approx(float(default_second.get("hit_size", -1.0)), 16.0)

	var empty_scan: Dictionary = mend_projector_build_state.source_mend_projector_heal_candidates_hitbox_state([], 40.0, building_x, building_y)
	proof["hitbox_empty_stays_empty"] = Array(empty_scan.get("candidates", [1])).is_empty()

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
	# frame carries three heal candidates: a straddler at dx
	# 52 with hit_size 16.0 (its center sits outside the live
	# rect -- the old N2329 center test dropped it -- but its
	# hitbox [268, 284] overlaps the live rect edge ~273.98
	# and it is inside the N2335 within circle, 52 < ~49.98 +
	# 8, so it heals), the rect corner at dx/dy 46 (in the
	# broad phase, out of the within circle -- excluded since
	# N2335), and one out of range (dx 60). Post-tick
	# phase_heat decays from 0.5 toward the folded
	# optionalEfficiency 0 (no silicon in the frame), so the
	# live realRange is 40 + phase_heat * 20 with phase_heat
	# read back from the frame -- the key proves the tick
	# passes the hitbox-admitted list through the narrow
	# filter into the heal scan (ONE heal, at the live
	# phase_heat fold), not [].
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
		{"x": live_center_x + 52.0, "y": live_center_y, "hit_size": 16.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": live_center_x + 46.0, "y": live_center_y + 46.0, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
		{"x": live_center_x + 60.0, "y": live_center_y, "damaged": true, "heal_suppressed": false, "max_health": 100.0},
	]
	mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	var live_scan: Dictionary = projector_frame.get("last_heal_scan", {})
	var live_phase_heat: float = float(projector_frame.get("phase_heat", -1.0))
	var live_amounts: Array = live_scan.get("heal_amounts", [])
	var live_expected_heal: float = 100.0 * (4.0 + live_phase_heat * 4.0) / 100.0 * 1.0
	proof["live_tick_passes_hitbox_candidates"] = is_equal_approx(float(projector_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(projector_frame.get("charge", -1.0)), 0.0) and bool(live_scan.get("scanned", false)) and bool(live_scan.get("any", false)) and is_equal_approx(float(live_scan.get("real_range", -1.0)), 40.0 + live_phase_heat * 20.0) and live_amounts.size() == 1 and is_equal_approx(float(live_amounts[0]), live_expected_heal)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MendProjectorHealScanHitboxProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
