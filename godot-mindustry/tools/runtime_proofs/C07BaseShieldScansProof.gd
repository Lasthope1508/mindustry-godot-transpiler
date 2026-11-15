extends Node

const main_scene := preload("res://scenes/Main.tscn")
const base_shield_build_state := preload("res://src/game/SourceBaseShieldBuildState.gd")
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

	# --- Pure scans (N2328): the Groups.bullet RECTANGLE
	# intersect (BaseShield.java:96) as a broad-phase filter
	# and the Units.nearbyEnemies (rad + 10f) scan
	# (BaseShield.java:97) as an enemy + STRICT within
	# filter. The building sits at (0, 0) for the pure calls
	# with rad 100; its team is derelict (0), the enemy team
	# is sharded (1) (Team.java:33-34). The bullet scan admits
	# a candidate when its CENTER falls in [x +/- rad, y +/-
	# rad], INCLUSIVE -- a rect, not a circle -- and never
	# looks at team or absorbable: the N2236 advance does the
	# enemy + absorbable + STRICT within narrow check. The
	# unit scan admits an enemy unit whose center is STRICTLY
	# within rad + 10 + hitSize/2 (Units.java:482-488): exactly
	# at the range is OUT. A candidate without x/y is
	# EXCLUDED; a unit without a team is its own team (never
	# an enemy); a unit without hit_size defaults to 0.0.

	# A bullet in the rect is admitted (rad 100): at (50, 0)
	# it is in; at the rect corner (100, 100) it is IN even
	# though it sits outside the radius circle (dst2 20000 >
	# 10000) -- the scan is a RECT, not a circle; at the edge
	# (100, 0) it is IN (inclusive); at the opposite corner
	# (-100, -100) it is in; and a SAME-TEAM bullet at (50, 0)
	# is admitted too -- the scan has no team filter, the
	# advance does that.
	var admitted_bullets: Dictionary = base_shield_build_state.source_base_shield_supplied_bullets_state([{"x": 50.0, "y": 0.0, "team": 1}, {"x": 100.0, "y": 100.0, "team": 1}, {"x": 100.0, "y": 0.0, "team": 1}, {"x": -100.0, "y": -100.0, "team": 1}, {"x": 50.0, "y": 0.0, "team": 0}], 100.0, 0.0, 0.0)
	var admitted_bullets_list: Array = admitted_bullets.get("bullets", [])
	var admitted_corner: Dictionary = admitted_bullets_list[1] if admitted_bullets_list.size() > 1 else {}
	var admitted_edge: Dictionary = admitted_bullets_list[2] if admitted_bullets_list.size() > 2 else {}
	proof["bullet_scan_admits_in_rect"] = admitted_bullets_list.size() == 5 and is_equal_approx(float(admitted_corner.get("x", -1.0)), 100.0) and is_equal_approx(float(admitted_corner.get("y", -1.0)), 100.0) and is_equal_approx(float(admitted_edge.get("x", -1.0)), 100.0) and is_equal_approx(float(admitted_edge.get("y", -1.0)), 0.0)

	# A bullet outside the rect is excluded (rad 100): at
	# (101, 0) and (0, -101) it is just past the edge; at
	# (150, 150) it is far outside; a candidate without x or
	# without y has no center to test and is excluded; a
	# non-dict candidate is skipped.
	var excluded_bullets: Dictionary = base_shield_build_state.source_base_shield_supplied_bullets_state([{"x": 101.0, "y": 0.0, "team": 1}, {"x": 0.0, "y": -101.0, "team": 1}, {"x": 150.0, "y": 150.0, "team": 1}, {"y": 0.0, "team": 1}, {"x": 0.0, "team": 1}, "not-a-dict"], 100.0, 0.0, 0.0)
	proof["bullet_scan_excludes_out_of_rect"] = Array(excluded_bullets.get("bullets", [1])).is_empty()

	# An enemy unit within rad + 10 + hitSize/2 is admitted
	# (rad 100, team 0): hitSize 20 at (119, 0) has dst 119 <
	# 120, so it is in; hitSize 20 at (0, 0) is on top of the
	# building, in; and a unit WITHOUT hit_size at (109, 0)
	# defaults hit_size to 0.0 (range 110), so dst 109 < 110
	# is in.
	var admitted_units: Dictionary = base_shield_build_state.source_base_shield_supplied_enemy_units_state([{"x": 119.0, "y": 0.0, "team": 1, "hit_size": 20.0}, {"x": 0.0, "y": 0.0, "team": 1, "hit_size": 20.0}, {"x": 109.0, "y": 0.0, "team": 1}], 100.0, 0.0, 0.0, 0)
	var admitted_units_list: Array = admitted_units.get("enemy_units", [])
	var admitted_first_unit: Dictionary = admitted_units_list[0] if admitted_units_list.size() > 0 else {}
	var admitted_third_unit: Dictionary = admitted_units_list[2] if admitted_units_list.size() > 2 else {}
	proof["unit_scan_admits_enemy_in_range"] = admitted_units_list.size() == 3 and is_equal_approx(float(admitted_first_unit.get("x", -1.0)), 119.0) and is_equal_approx(float(admitted_third_unit.get("x", -1.0)), 109.0)

	# An out-of-range / own-team unit is excluded (rad 100,
	# team 0): hitSize 20 at (120, 0) sits EXACTLY at the
	# range -- the within is STRICT (Position.java:44-46, dst2
	# < range^2), so it is OUT; hitSize 20 at (0, 121) is past
	# the range; an own-team unit at (50, 0) is excluded; a
	# unit WITHOUT a team at (50, 0) is its own team, never an
	# enemy; a unit without x is excluded; and a unit WITHOUT
	# hit_size at (110, 0) defaults to range 110, so dst 110
	# exactly is OUT.
	var excluded_units: Dictionary = base_shield_build_state.source_base_shield_supplied_enemy_units_state([{"x": 120.0, "y": 0.0, "team": 1, "hit_size": 20.0}, {"x": 0.0, "y": 121.0, "team": 1, "hit_size": 20.0}, {"x": 50.0, "y": 0.0, "team": 0, "hit_size": 20.0}, {"x": 50.0, "y": 0.0, "hit_size": 20.0}, {"y": 0.0, "team": 1, "hit_size": 20.0}, {"x": 110.0, "y": 0.0, "team": 1}], 100.0, 0.0, 0.0, 0)
	proof["unit_scan_excludes_out_of_range"] = Array(excluded_units.get("enemy_units", [1])).is_empty()

	# --- Live tick: a shield-projector placed live at cell
	# (28, 20) -- building world position (224, 160)
	# (tile.drawx / drawy, BuildingComp.java:124, offset 0 for
	# size 3). The tick driver is called directly (as the
	# N2159 proof does), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status --
	# the write-back itself is already proven by N2142. One
	# 1/60s tick is one source tick. The frame candidates ride
	# frame["bullet_candidates"] / frame["enemy_unit_candidates"]
	# (default [] -- the live Groups.bullet / Units queries
	# still defer); the tick computes scan_rad with the same
	# lerpDelta helper + const the advance uses and gates both
	# scans on scan_rad > 1 (BaseShield.java:93).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var shield_cell := Vector2i(28, 20)
	var shield := Sprite2D.new()
	game.add_child(shield)
	game.call("record_placed_block", shield, blocks_by_id["shield-projector"], shield_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status, seed
	# the smooth radius, and supply the scan candidates).
	base_shield_build_state.source_base_shield_bind_frame_state(shield, blocks_by_id["shield-projector"])
	var shield_frame: Dictionary = shield.get_meta(base_shield_build_state.SOURCE_BASE_SHIELD_BUILDING_META_KEY, {})

	# With rad <= 1 both scans are empty: a collapsed shield
	# (smooth 0, no efficiency) with an enemy bullet AND an
	# enemy unit sitting on top of it absorbs / repels
	# nothing -- scan_rad is 0, so the tick skips both scans
	# and the advance gets empty lists.
	shield_frame["power_status"] = 0.0
	shield_frame["smooth_radius"] = 0.0
	shield_frame["bullet_candidates"] = [{"x": 224.0, "y": 160.0, "team": 1, "absorbable": true}]
	shield_frame["enemy_unit_candidates"] = [{"x": 224.0, "y": 160.0, "team": 1, "hit_size": 20.0}]
	base_shield_build_state.source_base_shield_tick_buildings_state(game, 1.0 / 60.0)
	shield_frame = shield.get_meta(base_shield_build_state.SOURCE_BASE_SHIELD_BUILDING_META_KEY, {})
	proof["scans_empty_when_radius_small"] = is_equal_approx(float(shield_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(shield_frame.get("smooth_radius", -1.0)), 0.0) and Array(shield_frame.get("absorbed_bullets", [1])).is_empty() and Array(shield_frame.get("repelled_units", [1])).is_empty() and Array(shield_frame.get("killed_units", [1])).is_empty()

	# With rad 100 the tick passes the scanned lists into the
	# advance (smooth 100 held at half power, target 200 * 0.5
	# = 100): the enemy bullet at (274, 160) is in the rect
	# and inside the radius, so it is absorbed; the enemy
	# bullet at (374, 160) is outside the rect, so the scan
	# drops it and it is NOT absorbed; the same-team bullet at
	# (274, 160) passes the scan (no team filter) but the
	# advance ignores it; the enemy unit at (329, 160) with
	# hitSize 20 is in scan range (dst 105 < 120) and overlaps
	# (overlapDst 5), so it is repelled (5.01, 0); the
	# own-team unit at (274, 160) is dropped by the scan; the
	# enemy unit at (354, 160) is out of scan range (dst 130 >
	# 120), so it is dropped too and never repelled.
	shield_frame["power_status"] = 0.5
	shield_frame["smooth_radius"] = 100.0
	shield_frame["bullet_candidates"] = [{"x": 274.0, "y": 160.0, "team": 1, "absorbable": true}, {"x": 374.0, "y": 160.0, "team": 1, "absorbable": true}, {"x": 274.0, "y": 160.0, "team": 0, "absorbable": true}]
	shield_frame["enemy_unit_candidates"] = [{"x": 329.0, "y": 160.0, "team": 1, "hit_size": 20.0}, {"x": 274.0, "y": 160.0, "team": 0, "hit_size": 20.0}, {"x": 354.0, "y": 160.0, "team": 1, "hit_size": 20.0}]
	base_shield_build_state.source_base_shield_tick_buildings_state(game, 1.0 / 60.0)
	shield_frame = shield.get_meta(base_shield_build_state.SOURCE_BASE_SHIELD_BUILDING_META_KEY, {})
	var live_absorbed: Array = shield_frame.get("absorbed_bullets", [])
	var live_repelled: Array = shield_frame.get("repelled_units", [])
	var live_absorbed_first: Dictionary = live_absorbed[0] if live_absorbed.size() > 0 else {}
	var live_repelled_first: Dictionary = live_repelled[0] if live_repelled.size() > 0 else {}
	var live_repelled_first_unit: Dictionary = live_repelled_first.get("unit", {})
	proof["live_tick_passes_scanned_lists"] = is_equal_approx(float(shield_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(shield_frame.get("smooth_radius", -1.0)), 100.0) and live_absorbed.size() == 1 and is_equal_approx(float(live_absorbed_first.get("x", -1.0)), 274.0) and is_equal_approx(float(live_absorbed_first.get("y", -1.0)), 160.0) and live_repelled.size() == 1 and is_equal_approx(float(live_repelled_first_unit.get("x", -1.0)), 329.0) and is_equal_approx(float(live_repelled_first.get("repel_x", -1.0)), 5.01) and is_equal_approx(float(live_repelled_first.get("repel_y", -1.0)), 0.0) and is_equal_approx(float(live_repelled_first.get("overlap_dst", -1.0)), 5.0) and Array(shield_frame.get("killed_units", [1])).is_empty()

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BaseShieldScansProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
