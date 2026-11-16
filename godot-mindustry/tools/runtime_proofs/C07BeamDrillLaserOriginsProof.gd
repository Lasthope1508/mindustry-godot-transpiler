extends Node

const main_scene := preload("res://scenes/Main.tscn")
const beam_drill_build_state := preload("res://src/game/SourceBeamDrillBuildState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
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

	# --- Pure laser origins (N2346): BeamDrillBuild.
	# updateLasers() (BeamDrill.java:368-373) computes one
	# origin per laser through nearbySide (Block.java:
	# 936-944 -- NOT :936-947, the brief cite: :946-948 is
	# getEdges): corner = tile - (size-1)/2 with JAVA
	# integer division, then the rotation switch: 0 ->
	# (cornerX + s, cornerY + index); 1 -> (cornerX +
	# index, cornerY + s); 2 -> (cornerX - 1, cornerY +
	# index); 3 -> (cornerX + index, cornerY - 1).
	# Plasma-bore is size 2 (Blocks.java:3044);
	# large-plasma-bore is size 3 (Blocks.java:3058);
	# the Block class default is size 1 (Block.java:215).
	# The switch has NO default in Java: an out-of-range
	# rotation leaves `out` unchanged, and updateLasers
	# creates a fresh `new Point2()` (x = 0, y = 0, the
	# arc Point2 field defaults) when the slot is null.

	# Rotation 0: the plasma-bore at (28, 20) corners ON
	# its tile ((2-1)/2 = 0) and its two lasers sit one
	# tile east of the block's east edge: (30, 20) and
	# (30, 21). The large-plasma-bore at (10, 10) corners
	# one tile back ((3-1)/2 = 1), so its three lasers are
	# (12, 9), (12, 10) and (12, 11). A size-1 block at
	# (5, 5) has the single laser (6, 5).
	var rot0_size2: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(28, 20, 0, 2)
	var rot0_size3: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(10, 10, 0, 3)
	var rot0_size1: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(5, 5, 0, 1)
	proof["rotation_zero_origins"] = _origins_equal(rot0_size2.get("lasers", []), [{"x": 30, "y": 20}, {"x": 30, "y": 21}]) and _origins_equal(rot0_size3.get("lasers", []), [{"x": 12, "y": 9}, {"x": 12, "y": 10}, {"x": 12, "y": 11}]) and _origins_equal(rot0_size1.get("lasers", []), [{"x": 6, "y": 5}])

	# All four rotations for the plasma-bore at (28, 20):
	# rotation 1 puts the lasers north ((28, 22),
	# (29, 22)), rotation 2 west ((27, 20), (27, 21)),
	# rotation 3 south ((28, 19), (29, 19)). The index
	# walks along the facing side in laser order.
	var rot1_size2: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(28, 20, 1, 2)
	var rot2_size2: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(28, 20, 2, 2)
	var rot3_size2: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(28, 20, 3, 2)
	proof["all_rotations_origins"] = _origins_equal(rot1_size2.get("lasers", []), [{"x": 28, "y": 22}, {"x": 29, "y": 22}]) and _origins_equal(rot2_size2.get("lasers", []), [{"x": 27, "y": 20}, {"x": 27, "y": 21}]) and _origins_equal(rot3_size2.get("lasers", []), [{"x": 28, "y": 19}, {"x": 29, "y": 19}])

	# The corner formula across even/odd sizes: size 4 at
	# (10, 10) corners at (9, 9) ((4-1)/2 = 1, the Java
	# integer division truncates), so rotation 0 gives
	# (13, 9), (13, 10), (13, 11), (13, 12); size 5 at
	# (10, 10) corners at (8, 8) ((5-1)/2 = 2), so
	# rotation 2 gives (7, 8), (7, 9), (7, 10), (7, 11),
	# (7, 12). A size-0 call returns no origins (the Java
	# loop `for(int i = 0; i < size; i++)` runs zero
	# times).
	var size4: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(10, 10, 0, 4)
	var size5: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(10, 10, 2, 5)
	var size0: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(10, 10, 0, 0)
	proof["corner_formula_even_odd_sizes"] = _origins_equal(size4.get("lasers", []), [{"x": 13, "y": 9}, {"x": 13, "y": 10}, {"x": 13, "y": 11}, {"x": 13, "y": 12}]) and _origins_equal(size5.get("lasers", []), [{"x": 7, "y": 8}, {"x": 7, "y": 9}, {"x": 7, "y": 10}, {"x": 7, "y": 11}, {"x": 7, "y": 12}]) and (size0.get("lasers", [{}]) as Array).is_empty()

	# One origin per laser: the count matches size for
	# sizes 1, 2, 3 and 4.
	var count1: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(0, 0, 0, 1)
	var count2: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(0, 0, 1, 2)
	var count3: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(0, 0, 2, 3)
	var count4: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(0, 0, 3, 4)
	proof["laser_count_matches_size"] = (count1.get("lasers", []) as Array).size() == 1 and (count2.get("lasers", []) as Array).size() == 2 and (count3.get("lasers", []) as Array).size() == 3 and (count4.get("lasers", []) as Array).size() == 4

	# An unmatched rotation leaves the fresh Point2 at its
	# default: rotation 4 (and -1) give (0, 0) for every
	# laser -- the Java switch has no default case, so
	# `out` is never written for them.
	var rot4: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(28, 20, 4, 2)
	var rot_neg: Dictionary = beam_drill_build_state.source_beam_drill_laser_origins_state(28, 20, -1, 2)
	proof["invalid_rotation_keeps_fresh_origin"] = _origins_equal(rot4.get("lasers", []), [{"x": 0, "y": 0}, {"x": 0, "y": 0}]) and _origins_equal(rot_neg.get("lasers", []), [{"x": 0, "y": 0}, {"x": 0, "y": 0}])

	# --- Live tick: the plasma-bore is a BeamDrill with a power
	# consumer (consumePower 0.15f) and a hydrogen booster row
	# (consumeLiquid hydrogen 0.25f/60f, Blocks.java:3049),
	# placed live; the tick driver is called directly (as the
	# N2147/N2148/N2149/N2150/N2153/N2154/N2155/N2156/N2157/
	# N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/
	# N2167/N2168/N2169/N2195/N2202/N2256/N2289/N2339 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The plasma-bore has
	# NO required liquid row (the hydrogen row is a booster),
	# so no liquid seeding is needed: with no hydrogen held
	# the booster row folds optionalEfficiency 0 and efficiency
	# still folds the power min (the N2289 precedent).
	# updateLasers runs in onProximityUpdate (BeamDrill.java:
	# 362-366), NOT every tick, so the tick stamps
	# frame["lasers"] only when tile_changes moves (the N2277
	# pattern) -- and on the first tick, covering the lazy
	# `if(lasers[0] == null) updateLasers();` (BeamDrill.java:
	# 240). Tick 1: the fresh frame (lasers_last_change -2,
	# tile_changes 1) refreshes at rotation 0, stamping
	# [(30, 20), (30, 21)] for the drill at (28, 20).
	# Tick 2: the rotation meta moves to 1 AND tile_changes
	# bumps to 2 (the rotation event), so the origins
	# re-stamp to [(28, 22), (29, 22)]. Tick 3: the rotation
	# meta moves to 2 WITHOUT a tile_changes bump, so the
	# gate holds and the origins stay [(28, 22), (29, 22)].
	# The facing scan is untouched: with no facing_tiles
	# supplied, facing_amount stays 0 through all three
	# ticks (the N2339 behavior, preserved).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var drill_cell := Vector2i(28, 20)
	var drill := Sprite2D.new()
	game.add_child(drill)
	game.call("record_placed_block", drill, blocks_by_id["plasma-bore"], drill_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	beam_drill_build_state.source_beam_drill_bind_frame_state(drill, blocks_by_id["plasma-bore"])
	var drill_frame: Dictionary = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})

	drill_frame["items"] = {}
	drill_frame["power_status"] = 1.0
	drill_frame["facing_amount"] = 0
	drill.set_meta(block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0)
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var tick_one_lasers: Array = drill_frame.get("lasers", [])
	var tick_one_last_change: int = int(drill_frame.get("lasers_last_change", -99))
	var tick_one_facing: int = int(drill_frame.get("facing_amount", -1))
	drill.set_meta(block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 1)
	drill_frame["tile_changes"] = 2
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var tick_two_lasers: Array = drill_frame.get("lasers", [])
	var tick_two_last_change: int = int(drill_frame.get("lasers_last_change", -99))
	var tick_two_facing: int = int(drill_frame.get("facing_amount", -1))
	drill.set_meta(block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 2)
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	proof["live_tick_stamps_laser_origins"] = _origins_equal(tick_one_lasers, [{"x": 30, "y": 20}, {"x": 30, "y": 21}]) and tick_one_last_change == 1 and tick_one_facing == 0 and _origins_equal(tick_two_lasers, [{"x": 28, "y": 22}, {"x": 29, "y": 22}]) and tick_two_last_change == 2 and tick_two_facing == 0 and _origins_equal(drill_frame.get("lasers", []), [{"x": 28, "y": 22}, {"x": 29, "y": 22}]) and int(drill_frame.get("lasers_last_change", -99)) == 2 and int(drill_frame.get("facing_amount", -1)) == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillLaserOriginsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))


func _origins_equal(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size():
		return false
	for i in range(expected.size()):
		var got: Variant = actual[i]
		var want: Dictionary = expected[i]
		if not (got is Dictionary):
			return false
		if int(got.get("x", -999)) != int(want.get("x", -999)) or int(got.get("y", -999)) != int(want.get("y", -999)):
			return false
	return true
