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

	# --- Pure facing-tile fill (N2352): BeamDrillBuild.
	# updateFacing() (BeamDrill.java:375-411) walks each
	# laser ray from `Point2 l = lasers[p];` through
	# `Tile other = world.tile(rx, ry);` (:388) along
	# the rotation (`int dx = Geometry.d4x(rotation),
	# dy = Geometry.d4y(rotation);`, :378, the arc
	# Geometry d4x/d4y tables {1, 0, -1, 0} / {0, 1, 0,
	# -1}, Geometry.java:23-24, indexed with Mathf.mod(i,
	# 4), :47-52). The port has no live world query, so
	# the pure walks the same rays from frame["lasers"]
	# (the N2346 origins) through the frame input
	# world_tiles (a Dict keyed "x,y" to {solid,
	# wall_drop}, default {}) and returns the rays in
	# exactly the format the N2339 scan reads -- one
	# Array per laser in laser order, one entry per tile
	# in walk order (a Dict {solid, wall_drop} or null
	# when the world has no tile there). Item hardness
	# here is real upstream data (Items.java): copper 1,
	# lead 1, titanium 3, thorium 4, tungsten 5.
	# Plasma-bore is size 2 / range 5 / tier 3
	# (Blocks.java:3043-3045); large-plasma-bore is
	# size 3 / range 6 / tier 5 (Blocks.java:3057-3059).
	var copper: Dictionary = {"id": "copper", "hardness": 1}
	var lead: Dictionary = {"id": "lead", "hardness": 1}
	var thorium: Dictionary = {"id": "thorium", "hardness": 4}
	var open_tile: Dictionary = {"solid": false, "wall_drop": null}

	# Rays walked from the laser origins: the
	# plasma-bore at (28, 20) rotation 0 has origins
	# (30, 20) and (30, 21) (the N2346 geometry), so
	# ray 0 walks (30, 20), (31, 20), (32, 20), (33,
	# 20), (34, 20) and ray 1 walks (30, 21), (31, 21),
	# (32, 21), (33, 21), (34, 21). A copper wall at
	# (32, 20) lands at ray 0 index 2; a thorium wall
	# at (31, 21) lands at ray 1 index 1; every other
	# step is a null tile (no world entry). The
	# large-plasma-bore at (10, 10) rotation 0 has
	# origins (12, 9), (12, 10), (12, 11) and range 6:
	# a copper wall at (14, 10) lands at ray 1 index 2.
	var east: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 30, "y": 20}, {"x": 30, "y": 21}], {"32,20": {"solid": true, "wall_drop": copper}, "31,21": {"solid": true, "wall_drop": thorium}}, 2, 5, 0)
	var large: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 12, "y": 9}, {"x": 12, "y": 10}, {"x": 12, "y": 11}], {"14,10": {"solid": true, "wall_drop": copper}}, 3, 6, 0)
	proof["walks_rays_from_laser_origins"] = _rays_equal(east.get("facing_tiles", []), [[null, null, {"solid": true, "wall_drop": copper}, null, null], [null, {"solid": true, "wall_drop": thorium}, null, null, null]]) and _rays_equal(large.get("facing_tiles", []), [[null, null, null, null, null, null], [null, null, {"solid": true, "wall_drop": copper}, null, null, null], [null, null, null, null, null, null]])

	# Rotation changes the ray direction: the same
	# origins walked north (rotation 1, dy +1) reach
	# (30, 22) at ray 0 index 2; walked west (rotation
	# 2, dx -1) reach (28, 20) at ray 0 index 2; walked
	# south (rotation 3, dy -1) reach (30, 18) at ray 0
	# index 2. Rotation 4 normalizes to rotation 0
	# (Java's Mathf.mod(i, 4) -- the pure uses posmod),
	# so it walks east again and reaches (32, 20).
	var north: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 30, "y": 20}, {"x": 30, "y": 21}], {"30,22": {"solid": true, "wall_drop": copper}}, 2, 5, 1)
	var west: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 30, "y": 20}, {"x": 30, "y": 21}], {"28,20": {"solid": true, "wall_drop": lead}}, 2, 5, 2)
	var south: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 30, "y": 20}, {"x": 30, "y": 21}], {"30,18": {"solid": true, "wall_drop": copper}}, 2, 5, 3)
	var wrapped: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 30, "y": 20}, {"x": 30, "y": 21}], {"32,20": {"solid": true, "wall_drop": copper}}, 2, 5, 4)
	proof["rotation_changes_ray_direction"] = _rays_equal(north.get("facing_tiles", []), [[null, null, {"solid": true, "wall_drop": copper}, null, null], [null, null, null, null, null]]) and _rays_equal(west.get("facing_tiles", []), [[null, null, {"solid": true, "wall_drop": lead}, null, null], [null, null, null, null, null]]) and _rays_equal(south.get("facing_tiles", []), [[null, null, {"solid": true, "wall_drop": copper}, null, null], [null, null, null, null, null]]) and _rays_equal(wrapped.get("facing_tiles", []), [[null, null, {"solid": true, "wall_drop": copper}, null, null], [null, null, null, null, null]])

	# Missing / short rays and bounds: no lasers at all
	# gives two empty rays for a size-2 drill; a short
	# lasers array (one origin for a size-2 drill)
	# fills only the supplied ray and leaves the other
	# empty; lasers past `size` are ignored (Java reads
	# exactly `size` lasers: a third origin in a size-2
	# fill produces no third ray); tiles past
	# `beam_range` are ignored (Java walks exactly
	# `range` tiles: a copper wall at index 5 of a
	# range-5 ray is never reached, and each ray has
	# exactly 5 entries); a null laser entry and a
	# non-Dict laser entry both give an empty ray; a
	# size-0 call returns no rays.
	var no_lasers: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([], {"32,20": {"solid": true, "wall_drop": copper}}, 2, 5, 0)
	var short: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 30, "y": 20}], {"32,20": {"solid": true, "wall_drop": copper}}, 2, 5, 0)
	var extra_lasers: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 30, "y": 20}, {"x": 30, "y": 21}, {"x": 30, "y": 22}], {"32,20": {"solid": true, "wall_drop": copper}}, 2, 5, 0)
	var beyond_range: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 30, "y": 20}], {"35,20": {"solid": true, "wall_drop": copper}}, 1, 5, 0)
	var null_laser: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([null, {"x": 30, "y": 21}], {"31,21": {"solid": true, "wall_drop": copper}}, 2, 5, 0)
	var size_zero: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 30, "y": 20}], {"32,20": {"solid": true, "wall_drop": copper}}, 0, 5, 0)
	proof["missing_short_rays_and_bounds"] = _rays_equal(no_lasers.get("facing_tiles", [{}]), [[], []]) and _rays_equal(short.get("facing_tiles", []), [[null, null, {"solid": true, "wall_drop": copper}, null, null], []]) and _rays_equal(extra_lasers.get("facing_tiles", []), [[null, null, {"solid": true, "wall_drop": copper}, null, null], [null, null, null, null, null]]) and _rays_equal(beyond_range.get("facing_tiles", []), [[null, null, null, null, null]]) and _rays_equal(null_laser.get("facing_tiles", []), [[], [null, {"solid": true, "wall_drop": copper}, null, null, null]]) and (size_zero.get("facing_tiles", [{}]) as Array).is_empty()

	# Null and non-solid tiles pass through: a missing
	# world key is a null tile (the walk continues past
	# it), a null world entry is a null tile too, a
	# non-Dict world entry is a null tile, and a
	# non-solid tile passes through as {solid: false,
	# wall_drop} -- the fill emits the FULL ray and the
	# N2339 scan does the breaking, so the fill never
	# drops a step. A solid tile with no wall_drop key
	# normalizes to wall_drop null.
	var passthrough: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 30, "y": 20}], {"30,20": open_tile, "31,20": null, "32,20": "not-a-tile", "33,20": {"solid": true}}, 1, 5, 0)
	proof["null_and_nonsolid_tiles_pass_through"] = _rays_equal(passthrough.get("facing_tiles", []), [[open_tile, null, null, {"solid": true, "wall_drop": null}, null]])

	# The filled rays feed the N2339 scan to the right
	# count: a mineable copper wall on ray 0 and an
	# unmineable thorium wall on ray 1 count 1 (the
	# thorium is the first solid tile on its ray, so it
	# breaks the ray and counts 0 -- the scan's rule,
	# not the fill's); two mineable walls count 2; a
	# solid tile with no drop on ray 0 and a copper
	# wall on ray 1 count 1.
	var fill_one: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 30, "y": 20}, {"x": 30, "y": 21}], {"32,20": {"solid": true, "wall_drop": copper}, "31,21": {"solid": true, "wall_drop": thorium}}, 2, 5, 0)
	var scan_one: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state(fill_one.get("facing_tiles", []), 2, 5, 3, null)
	var fill_two: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 30, "y": 20}, {"x": 30, "y": 21}], {"32,20": {"solid": true, "wall_drop": copper}, "31,21": {"solid": true, "wall_drop": lead}}, 2, 5, 0)
	var scan_two: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state(fill_two.get("facing_tiles", []), 2, 5, 3, null)
	var fill_drop: Dictionary = beam_drill_build_state.source_beam_drill_facing_tiles_fill_state([{"x": 30, "y": 20}, {"x": 30, "y": 21}], {"30,20": {"solid": true, "wall_drop": null}, "31,21": {"solid": true, "wall_drop": copper}}, 2, 5, 0)
	var scan_drop: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state(fill_drop.get("facing_tiles", []), 2, 5, 3, null)
	proof["fill_feeds_scan_count"] = int(scan_one.get("facing_amount", -1)) == 1 and int(scan_two.get("facing_amount", -1)) == 2 and int(scan_drop.get("facing_amount", -1)) == 1

	# --- Live tick: the plasma-bore is a BeamDrill with a power
	# consumer (consumePower 0.15f) and a hydrogen booster row
	# (consumeLiquid hydrogen 0.25f/60f, Blocks.java:3049),
	# placed live; the tick driver is called directly (as the
	# N2147/N2148/N2149/N2150/N2153/N2154/N2155/N2156/N2157/
	# N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/
	# N2167/N2168/N2169/N2195/N2202/N2256/N2289/N2339/N2346
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. The
	# plasma-bore has NO required liquid row (the hydrogen row
	# is a booster), so no liquid seeding is needed: with no
	# hydrogen held the booster row folds optionalEfficiency 0
	# and efficiency still folds the power min (the N2289
	# precedent). Tick 1: the fresh frame refreshes its laser
	# origins at rotation 0 ([(30, 20), (30, 21)] for the
	# drill at (28, 20), the N2346 first-tick refresh), the
	# fill walks those rays through the seeded world_tiles
	# (a copper wall at (32, 20) on ray 0, a thorium wall at
	# (31, 21) on ray 1) and stamps facing_tiles, and the
	# scan stamps facing_amount 1 in the same tick. Tick 2:
	# the rotation meta moves to 1 AND tile_changes bumps to
	# 2 (the rotation event), so the origins re-stamp to
	# [(28, 22), (29, 22)] and the fill re-walks north: the
	# copper wall seeded at (28, 22) lands at ray 0 index 0
	# (it was null at rotation 0), so facing_tiles change
	# with the rotation while facing_amount stays 1. Tick 3:
	# world_tiles is cleared ({}), so the fill is skipped and
	# facing_tiles keep the tick-2 rays (the N2339
	# frame-input path, preserved) and facing_amount stays 1.
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
	drill_frame["world_tiles"] = {"32,20": {"solid": true, "wall_drop": copper}, "31,21": {"solid": true, "wall_drop": thorium}, "28,22": {"solid": true, "wall_drop": copper}}
	drill.set_meta(block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0)
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var tick_one_lasers: Array = drill_frame.get("lasers", [])
	var tick_one_tiles: Array = drill_frame.get("facing_tiles", [])
	var tick_one_facing: int = int(drill_frame.get("facing_amount", -1))
	drill.set_meta(block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 1)
	drill_frame["tile_changes"] = 2
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var tick_two_lasers: Array = drill_frame.get("lasers", [])
	var tick_two_tiles: Array = drill_frame.get("facing_tiles", [])
	var tick_two_facing: int = int(drill_frame.get("facing_amount", -1))
	drill_frame["world_tiles"] = {}
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	proof["live_tick_stamps_facing_tiles"] = _origins_equal(tick_one_lasers, [{"x": 30, "y": 20}, {"x": 30, "y": 21}]) and _rays_equal(tick_one_tiles, [[null, null, {"solid": true, "wall_drop": copper}, null, null], [null, {"solid": true, "wall_drop": thorium}, null, null, null]]) and tick_one_facing == 1 and _origins_equal(tick_two_lasers, [{"x": 28, "y": 22}, {"x": 29, "y": 22}]) and _rays_equal(tick_two_tiles, [[{"solid": true, "wall_drop": copper}, null, null, null, null], [null, null, null, null, null]]) and tick_two_facing == 1 and _rays_equal(drill_frame.get("facing_tiles", []), [[{"solid": true, "wall_drop": copper}, null, null, null, null], [null, null, null, null, null]]) and int(drill_frame.get("facing_amount", -1)) == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillFacingTilesFillProof", proof)
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


func _tile_equal(got: Variant, want: Variant) -> bool:
	if got == null or want == null:
		return got == null and want == null
	if not (got is Dictionary) or not (want is Dictionary):
		return false
	if bool(got.get("solid", false)) != bool(want.get("solid", false)):
		return false
	var got_drop: Variant = got.get("wall_drop", null)
	var want_drop: Variant = want.get("wall_drop", null)
	if got_drop == null or want_drop == null:
		return got_drop == null and want_drop == null
	if not (got_drop is Dictionary) or not (want_drop is Dictionary):
		return false
	return str(got_drop.get("id", "")) == str(want_drop.get("id", "")) and int(got_drop.get("hardness", -1)) == int(want_drop.get("hardness", -1))


func _rays_equal(actual: Array, expected: Array) -> bool:
	if actual.size() != expected.size():
		return false
	for p in range(expected.size()):
		var got_ray: Variant = actual[p]
		var want_ray: Variant = expected[p]
		if not (got_ray is Array) or not (want_ray is Array):
			return false
		if got_ray.size() != want_ray.size():
			return false
		for i in range(want_ray.size()):
			if not _tile_equal(got_ray[i], want_ray[i]):
				return false
	return true
