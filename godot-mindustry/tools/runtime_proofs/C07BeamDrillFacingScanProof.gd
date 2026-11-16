extends Node

const main_scene := preload("res://scenes/Main.tscn")
const beam_drill_build_state := preload("res://src/game/SourceBeamDrillBuildState.gd")
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

	# --- Pure facing scan (N2339): BeamDrillBuild.
	# updateFacing() (BeamDrill.java:375-411 -- the range
	# is :375-411, NOT :375-410 (the old driver cite, off
	# by one: the closing brace is :411) and NOT :368-411
	# (the old DEFERRED cite: :368-373 is updateLasers)
	# resets facingAmount to 0 and, for each of the size
	# facing lasers, walks range tiles along the rotation
	# from the laser origin, takes the FIRST solid tile,
	# and counts it when its wallDrop passes the mineable
	# check (`drop != null && drop.hardness <= tier &&
	# (blockedItems == null || !blockedItems.contains(
	# drop))`, BeamDrill.java:391). The first solid tile
	# BREAKS the ray even when its drop is unmineable,
	# while a null tile (out of the world) and a
	# non-solid tile do not break it. The port has no
	# live world, so the pure takes the facing rays as
	# frame inputs (the N2301 WallCrafter getEfficiency
	# precedent): one Array per laser in laser order,
	# one Dict per tile in walk order {solid, wall_drop}
	# carrying the `other != null && other.solid()`
	# answer and the wallDrop item {id, hardness} (null
	# when the tile drops nothing). Item hardness here
	# is real upstream data (Items.java): copper 1, lead
	# 1, coal 2, titanium 3, beryllium 3, thorium 4,
	# tungsten 5. Plasma-bore is size 2 / range 5 /
	# tier 3 (Blocks.java:3043-3045); large-plasma-bore
	# is size 3 / range 6 / tier 5 (Blocks.java:3057-
	# 3059).
	var copper: Dictionary = {"id": "copper", "hardness": 1}
	var lead: Dictionary = {"id": "lead", "hardness": 1}
	var titanium: Dictionary = {"id": "titanium", "hardness": 3}
	var thorium: Dictionary = {"id": "thorium", "hardness": 4}
	var tungsten: Dictionary = {"id": "tungsten", "hardness": 5}
	var open_tile: Dictionary = {"solid": false, "wall_drop": null}

	# Counts mineable facing tiles: two lasers, the
	# first past an open tile to a copper wall
	# (hardness 1 <= tier 3), the second straight to a
	# titanium wall (hardness 3 == tier 3, the boundary
	# counts) -- facing_amount 2. A thorium wall
	# (hardness 4 > tier 3) does not count, and a solid
	# tile with no wallDrop does not count either.
	var counted: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[open_tile, {"solid": true, "wall_drop": copper}], [{"solid": true, "wall_drop": titanium}]], 2, 5, 3, null)
	var too_hard: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[{"solid": true, "wall_drop": thorium}]], 1, 5, 3, null)
	var no_drop: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[{"solid": true, "wall_drop": null}]], 1, 5, 3, null)
	proof["counts_mineable_facing_tiles"] = int(counted.get("facing_amount", -1)) == 2 and int(too_hard.get("facing_amount", -1)) == 0 and int(no_drop.get("facing_amount", -1)) == 0

	# The first solid tile breaks the ray: a thorium
	# wall (unmineable at tier 3) in front of a copper
	# wall counts 0 -- the copper behind it is never
	# reached. A solid tile with no drop in front of a
	# copper wall counts 0 the same way. Open tiles do
	# NOT break the ray (two open tiles, then a copper
	# wall, counts 1), and neither does a null tile
	# (out of the world: null, then a copper wall,
	# counts 1).
	var blocked_behind: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[{"solid": true, "wall_drop": thorium}, {"solid": true, "wall_drop": copper}]], 1, 5, 3, null)
	var no_drop_behind: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[{"solid": true, "wall_drop": null}, {"solid": true, "wall_drop": copper}]], 1, 5, 3, null)
	var skip_open: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[open_tile, open_tile, {"solid": true, "wall_drop": copper}]], 1, 5, 3, null)
	var skip_null: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[null, {"solid": true, "wall_drop": copper}]], 1, 5, 3, null)
	proof["first_solid_tile_breaks_ray"] = int(blocked_behind.get("facing_amount", -1)) == 0 and int(no_drop_behind.get("facing_amount", -1)) == 0 and int(skip_open.get("facing_amount", -1)) == 1 and int(skip_null.get("facing_amount", -1)) == 1

	# Blocked items are excluded: with copper blocked,
	# a copper wall and a lead wall count 1 (lead
	# only); with no blocked list (null, the case for
	# both BeamDrill defs -- neither sets blockedItem /
	# blockedItems) both count; with both blocked,
	# neither counts.
	var blocked_one: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[{"solid": true, "wall_drop": copper}], [{"solid": true, "wall_drop": lead}]], 2, 5, 3, ["copper"])
	var blocked_none: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[{"solid": true, "wall_drop": copper}], [{"solid": true, "wall_drop": lead}]], 2, 5, 3, null)
	var blocked_both: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[{"solid": true, "wall_drop": copper}], [{"solid": true, "wall_drop": lead}]], 2, 5, 3, ["copper", "lead"])
	proof["blocked_items_excluded"] = int(blocked_one.get("facing_amount", -1)) == 1 and int(blocked_none.get("facing_amount", -1)) == 2 and int(blocked_both.get("facing_amount", -1)) == 0

	# Missing tiles and bounds: no rays at all gives 0;
	# a short ray array (one ray for a size-2 drill)
	# counts only the supplied ray; rays past `size`
	# are ignored (Java reads exactly `size` lasers: a
	# third mineable ray in a size-2 scan is not
	# counted); tiles past `beam_range` are ignored
	# (Java walks exactly `range` tiles: a copper wall
	# at index 5 of a range-5 ray is not reached); a
	# null ray entry is skipped like a missing laser.
	var empty: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([], 2, 5, 3, null)
	var short: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[{"solid": true, "wall_drop": copper}]], 2, 5, 3, null)
	var extra_rays: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[{"solid": true, "wall_drop": copper}], [{"solid": true, "wall_drop": lead}], [{"solid": true, "wall_drop": copper}]], 2, 5, 3, null)
	var beyond_range: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[open_tile, open_tile, open_tile, open_tile, open_tile, {"solid": true, "wall_drop": copper}]], 1, 5, 3, null)
	var null_ray: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([null, [{"solid": true, "wall_drop": copper}]], 2, 5, 3, null)
	proof["missing_tiles_and_bounds"] = int(empty.get("facing_amount", -1)) == 0 and int(short.get("facing_amount", -1)) == 1 and int(extra_rays.get("facing_amount", -1)) == 2 and int(beyond_range.get("facing_amount", -1)) == 0 and int(null_ray.get("facing_amount", -1)) == 1

	# The large-plasma-bore's three lasers (size 3 /
	# range 6 / tier 5): a thorium wall (hardness 4),
	# a tungsten wall (hardness 5 == tier 5, the
	# boundary counts) and a copper wall count 3. A
	# copper wall at index 6 of a range-6 ray is past
	# the walk and does not count.
	var large: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[{"solid": true, "wall_drop": thorium}], [{"solid": true, "wall_drop": tungsten}], [{"solid": true, "wall_drop": copper}]], 3, 6, 5, null)
	var large_beyond: Dictionary = beam_drill_build_state.source_beam_drill_facing_scan_state([[open_tile, open_tile, open_tile, open_tile, open_tile, open_tile, {"solid": true, "wall_drop": copper}]], 1, 6, 5, null)
	proof["large_bore_three_lasers"] = int(large.get("facing_amount", -1)) == 3 and int(large_beyond.get("facing_amount", -1)) == 0

	# --- Live tick: the plasma-bore is a BeamDrill with a power
	# consumer (consumePower 0.15f) and a hydrogen booster row
	# (consumeLiquid hydrogen 0.25f/60f, Blocks.java:3049),
	# placed live; the tick driver is called directly (as the
	# N2147/N2148/N2149/N2150/N2153/N2154/N2155/N2156/N2157/
	# N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/
	# N2167/N2168/N2169/N2195/N2202/N2256/N2289 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The plasma-bore has NO required
	# liquid row (the hydrogen row is a booster), so no liquid
	# seeding is needed: with no hydrogen held the booster row
	# folds optionalEfficiency 0 and efficiency still folds
	# the power min (the N2289 precedent). The facing rays are
	# frame inputs (frame["facing_tiles"], default []),
	# stamped here like the N2228 targets precedent: two
	# mineable walls (copper, lead) face the drill. One 1/60s
	# tick is one source tick. Tick 1: the shouldConsume gate
	# reads the PREVIOUS facing_amount (0, seeded -- Java
	# order, BuildingComp.java:2274-2277, updateConsumption
	# before updateTile), so the gate is closed and efficiency
	# folds 0 even at full power -- but the scan stamps
	# facing_amount 2 after the fold. Tick 2: the gate reads
	# the stamped 2, so efficiency folds the power min 1.0,
	# the advance moves warmup 1/60 and time 1.0 * 1.0 * 1.0
	# * 1.0 = 1.0 (multiplier lerp(1, 2.5, 0) = 1.0 with no
	# hydrogen), and facing_amount stays 2.
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
	# frame dict before the tick to stamp power_status and the
	# facing rays on it).
	beam_drill_build_state.source_beam_drill_bind_frame_state(drill, blocks_by_id["plasma-bore"])
	var drill_frame: Dictionary = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})

	drill_frame["items"] = {}
	drill_frame["power_status"] = 1.0
	drill_frame["facing_amount"] = 0
	drill_frame["facing_tiles"] = [[{"solid": true, "wall_drop": copper}], [{"solid": true, "wall_drop": lead}]]
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var tick_one_efficiency: float = float(drill_frame.get("efficiency", -1.0))
	var tick_one_facing: int = int(drill_frame.get("facing_amount", -1))
	var tick_one_warmup: float = float(drill_frame.get("warmup", -1.0))
	var tick_one_time: float = float(drill_frame.get("time", -1.0))
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	proof["live_tick_stamps_facing_amount"] = is_equal_approx(tick_one_efficiency, 0.0) and tick_one_facing == 2 and is_equal_approx(tick_one_warmup, 0.0) and is_equal_approx(tick_one_time, 0.0) and is_equal_approx(float(drill_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(drill_frame.get("optional_efficiency", -1.0)), 0.0) and int(drill_frame.get("facing_amount", -1)) == 2 and is_equal_approx(float(drill_frame.get("warmup", -1.0)), 1.0 / 60.0) and is_equal_approx(float(drill_frame.get("multiplier", -1.0)), 1.0) and is_equal_approx(float(drill_frame.get("time", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillFacingScanProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
