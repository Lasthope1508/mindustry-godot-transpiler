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

	# --- Pure drop loop (N2477): the drop loop + time
	# reset + lastDrillSpeed (BeamDrillBuild.updateTile(),
	# BeamDrill.java:237-267, in Java order):
	# `float drillTime = getDrillTime(lastItem);` (:247,
	# getDrillTime :216-218, `return drillTime /
	# drillMultipliers.get(item, 1f);`, :217, the 1f
	# default honoured by arc, ObjectFloatMap.java:286,
	# including a null item, :287),
	# `lastDrillSpeed = (facingAmount * multiplier * timeScale) / drillTime * efficiency;`
	# (:249),
	# `if(time >= drillTime){` (:253),
	# `for(Tile tile : facing){` (:254),
	# `Item drop = tile == null ? null : tile.wallDrop();`
	# (:255),
	# `if(items.total() < itemCapacity && drop != null){`
	# (:256, the capacity gate re-checked PER tile),
	# `items.add(drop, 1);` (:257),
	# `produced(drop);` (:258, the sector stats + unlock,
	# BuildingComp.java:1035-1046 -- reported as counts
	# per item, not written: no sector stats in the port),
	# `time %= drillTime;` (:261). The facing[] dests +
	# lastItem come from updateFacing (:375-411): the
	# first solid tile breaks the ray even when its drop
	# is unmineable, the mineable gate is :391, distinct
	# drops null lastItem out (:393-394 / :408-409), and
	# `facing[p] = dest;` (:404). The pure re-walks the
	# facing rays for them (the N2339 scan returns ONLY
	# the count -- it has no last_item / facing key to
	# read) and wires getDrillTime through the N2473
	# lookup, INLINED (the N2473 test pins the multiplier
	# pure's call count at 1, the definition alone). The
	# base drillTime is 200f (BeamDrill.java:39), 160f
	# plasma-bore / 100f large-plasma-bore
	# (Blocks.java:3042/3055); itemCapacity is 10
	# (Block.java:75), 20 large-plasma-bore
	# (Blocks.java:3062). Item hardness here is real
	# upstream data (Items.java): copper 1, lead 1,
	# beryllium 3, thorium 4.
	var copper: Dictionary = {"id": "copper", "hardness": 1}
	var lead: Dictionary = {"id": "lead", "hardness": 1}
	var beryllium: Dictionary = {"id": "beryllium", "hardness": 3}
	var thorium: Dictionary = {"id": "thorium", "hardness": 4}
	var copper_wall: Dictionary = {"solid": true, "wall_drop": copper}
	var lead_wall: Dictionary = {"solid": true, "wall_drop": lead}
	var beryllium_wall: Dictionary = {"solid": true, "wall_drop": beryllium}
	var thorium_wall: Dictionary = {"solid": true, "wall_drop": thorium}

	# --- Threshold: below drillTime nothing drops --
	# time, items and produced are untouched -- but
	# lastItem / facing / drillTime / lastDrillSpeed
	# are still derived (Java :247/:249 run every tick,
	# before the :253 check). Two copper rays at time
	# 159.0 (plasma-bore drillTime 160): lastItem is
	# copper (the same drop on both lasers, no
	# multiple), drillTime 160, lastDrillSpeed
	# (2 * 1 * 1) / 160 * 1 = 0.0125. Empty rays (no
	# facing wall): facing [null, null], lastItem
	# null, drillTime still 160 (the null-item 1.0
	# default), speed 0.0 (facingAmount 0).
	var below_frame: Dictionary = {"facing_tiles": [[copper_wall], [copper_wall]], "items": {}, "time": 159.0, "facing_amount": 2, "multiplier": 1.0, "efficiency": 1.0}
	var below: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state(below_frame, 1.0, 160.0, {}, 10, 2, 5, 3, null)
	var below_facing: Array = below.get("facing", [])
	var below_facing_zero: Dictionary = below_facing[0] if below_facing.size() > 0 and below_facing[0] is Dictionary else {}
	var below_facing_zero_drop: Dictionary = below_facing_zero.get("wall_drop", {}) if below_facing_zero.get("wall_drop", null) is Dictionary else {}
	var empty_rays: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state({"facing_tiles": [[null], [null]], "items": {}, "time": 0.0, "facing_amount": 0, "multiplier": 1.0, "efficiency": 1.0}, 1.0, 160.0, {}, 10, 2, 5, 3, null)
	var empty_facing: Array = empty_rays.get("facing", [])
	proof["drop_threshold"] = is_equal_approx(float(below.get("time", -1.0)), 159.0) and (below.get("items", {}) as Dictionary).is_empty() and (below.get("produced", {}) as Dictionary).is_empty() and str(below.get("last_item", "")) == "copper" and below_facing.size() == 2 and str(below_facing_zero_drop.get("id", "")) == "copper" and is_equal_approx(float(below.get("drill_time", -1.0)), 160.0) and is_equal_approx(float(below.get("last_drill_speed", -1.0)), 0.0125) and empty_facing.size() == 2 and empty_facing[0] == null and empty_facing[1] == null and empty_rays.get("last_item", "") == null and is_equal_approx(float(empty_rays.get("drill_time", -1.0)), 160.0) and is_equal_approx(float(empty_rays.get("last_drill_speed", -1.0)), 0.0)

	# --- Reset + adds: at the threshold each facing
	# tile drops one item and time resets with `%=` --
	# the loop runs ONCE per tick even when time is
	# more than twice drillTime (Java has no repeat:
	# the `%=` keeps the remainder). Two copper rays
	# at time 160.0: {copper: 2}, produced {copper: 2},
	# time 0.0. At time 365.0: the same two adds, time
	# fmod(365, 160) = 45.0. Mixed drops (copper +
	# lead): lastItem null (multiple), one of each,
	# drillTime 160 (the null-item default).
	var at_frame: Dictionary = {"facing_tiles": [[copper_wall], [copper_wall]], "items": {}, "time": 160.0, "facing_amount": 2, "multiplier": 1.0, "efficiency": 1.0}
	var at_threshold: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state(at_frame, 1.0, 160.0, {}, 10, 2, 5, 3, null)
	var at_items: Dictionary = at_threshold.get("items", {})
	var at_produced: Dictionary = at_threshold.get("produced", {})
	var over_frame: Dictionary = {"facing_tiles": [[copper_wall], [copper_wall]], "items": {}, "time": 365.0, "facing_amount": 2, "multiplier": 1.0, "efficiency": 1.0}
	var over_threshold: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state(over_frame, 1.0, 160.0, {}, 10, 2, 5, 3, null)
	var over_items: Dictionary = over_threshold.get("items", {})
	var mixed_frame: Dictionary = {"facing_tiles": [[copper_wall], [lead_wall]], "items": {}, "time": 160.0, "facing_amount": 2, "multiplier": 1.0, "efficiency": 1.0}
	var mixed: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state(mixed_frame, 1.0, 160.0, {}, 10, 2, 5, 3, null)
	var mixed_items: Dictionary = mixed.get("items", {})
	var mixed_produced: Dictionary = mixed.get("produced", {})
	proof["drop_time_reset"] = int(at_items.get("copper", -1)) == 2 and int(at_produced.get("copper", -1)) == 2 and is_equal_approx(float(at_threshold.get("time", -1.0)), 0.0) and int(over_items.get("copper", -1)) == 2 and is_equal_approx(float(over_threshold.get("time", -1.0)), 45.0) and mixed.get("last_item", "") == null and int(mixed_items.get("copper", -1)) == 1 and int(mixed_items.get("lead", -1)) == 1 and int(mixed_produced.get("copper", -1)) == 1 and int(mixed_produced.get("lead", -1)) == 1 and is_equal_approx(float(mixed.get("drill_time", -1.0)), 160.0)

	# --- Capacity gate: items.total() is re-checked
	# PER tile (Java :256 sits INSIDE the loop), so a
	# store at 9/10 takes exactly one more copper and
	# the second facing tile is skipped -- and the
	# reset still fires (the `%=` is outside the
	# loop). A full store (10/10) takes nothing but
	# still resets. An unmineable facing tile (thorium,
	# hardness 4 > tier 3) is not a dest at all: the
	# ray breaks on it, facing is null there, and only
	# the copper ray drops.
	var near_full_frame: Dictionary = {"facing_tiles": [[copper_wall], [copper_wall]], "items": {"copper": 9}, "time": 160.0, "facing_amount": 2, "multiplier": 1.0, "efficiency": 1.0}
	var near_full: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state(near_full_frame, 1.0, 160.0, {}, 10, 2, 5, 3, null)
	var near_full_items: Dictionary = near_full.get("items", {})
	var near_full_produced: Dictionary = near_full.get("produced", {})
	var full_frame: Dictionary = {"facing_tiles": [[copper_wall], [copper_wall]], "items": {"copper": 10}, "time": 160.0, "facing_amount": 2, "multiplier": 1.0, "efficiency": 1.0}
	var full: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state(full_frame, 1.0, 160.0, {}, 10, 2, 5, 3, null)
	var full_items: Dictionary = full.get("items", {})
	var blocked_ray_frame: Dictionary = {"facing_tiles": [[thorium_wall], [copper_wall]], "items": {}, "time": 160.0, "facing_amount": 1, "multiplier": 1.0, "efficiency": 1.0}
	var blocked_ray: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state(blocked_ray_frame, 1.0, 160.0, {}, 10, 2, 5, 3, null)
	var blocked_ray_items: Dictionary = blocked_ray.get("items", {})
	var blocked_ray_facing: Array = blocked_ray.get("facing", [])
	proof["drop_capacity_gate"] = int(near_full_items.get("copper", -1)) == 10 and int(near_full_produced.get("copper", -1)) == 1 and is_equal_approx(float(near_full.get("time", -1.0)), 0.0) and int(full_items.get("copper", -1)) == 10 and (full.get("produced", {}) as Dictionary).is_empty() and is_equal_approx(float(full.get("time", -1.0)), 0.0) and int(blocked_ray_items.get("copper", -1)) == 1 and blocked_ray_facing.size() == 2 and blocked_ray_facing[0] == null and str(blocked_ray.get("last_item", "")) == "copper"

	# --- Last drill speed: (facingAmount * multiplier
	# * timeScale) / drillTime * efficiency (Java :249),
	# computed every tick -- even below the threshold
	# (all three frames below sit at time 0.0). Boosted
	# (multiplier 2.5, the full optionalBoostIntensity)
	# at half efficiency: (2 * 2.5 * 1) / 160 * 0.5 =
	# 0.015625. Overdrive (timeScale 2.0) on the large
	# drill (base 100, three facing tiles): (3 * 1 * 2)
	# / 100 * 1 = 0.06. Zero efficiency: 0.0.
	var boosted_frame: Dictionary = {"facing_tiles": [[copper_wall], [copper_wall]], "items": {}, "time": 0.0, "facing_amount": 2, "multiplier": 2.5, "efficiency": 0.5}
	var boosted: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state(boosted_frame, 1.0, 160.0, {}, 10, 2, 5, 3, null)
	var overdrive_frame: Dictionary = {"facing_tiles": [[copper_wall], [copper_wall], [copper_wall]], "items": {}, "time": 0.0, "facing_amount": 3, "multiplier": 1.0, "efficiency": 1.0}
	var overdrive: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state(overdrive_frame, 2.0, 100.0, {}, 20, 3, 6, 5, null)
	var idle_frame: Dictionary = {"facing_tiles": [[copper_wall], [copper_wall]], "items": {}, "time": 0.0, "facing_amount": 2, "multiplier": 1.0, "efficiency": 0.0}
	var idle: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state(idle_frame, 1.0, 160.0, {}, 10, 2, 5, 3, null)
	proof["drop_last_drill_speed"] = is_equal_approx(float(boosted.get("last_drill_speed", -1.0)), 0.015625) and is_equal_approx(float(overdrive.get("last_drill_speed", -1.0)), 0.06) and is_equal_approx(float(idle.get("last_drill_speed", -1.0)), 0.0)

	# --- Multiplier: the effective drillTime is the
	# per-def base DIVIDED by the mapped multiplier
	# (getDrillTime, BeamDrill.java:217). Beryllium at
	# 2.0 (the BurstDrill def value, Blocks.java:3083/
	# 3114, as a caller-supplied map entry -- neither
	# BeamDrill def sets one): drillTime 160 / 2 = 80,
	# so time 80.0 drops. An unmapped item (copper in
	# a beryllium-only map) reads the 1.0 default:
	# drillTime 160, time 80.0 does not drop. A null
	# lastItem (mixed copper + lead) reads 1.0 too
	# (the arc null-key rule, ObjectFloatMap.java:287).
	var beryllium_frame: Dictionary = {"facing_tiles": [[beryllium_wall], [beryllium_wall]], "items": {}, "time": 80.0, "facing_amount": 2, "multiplier": 1.0, "efficiency": 1.0}
	var beryllium_hit: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state(beryllium_frame, 1.0, 160.0, {"beryllium": 2.0}, 10, 2, 5, 3, null)
	var beryllium_items: Dictionary = beryllium_hit.get("items", {})
	var unmapped_frame: Dictionary = {"facing_tiles": [[copper_wall], [copper_wall]], "items": {}, "time": 80.0, "facing_amount": 2, "multiplier": 1.0, "efficiency": 1.0}
	var unmapped: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state(unmapped_frame, 1.0, 160.0, {"beryllium": 2.0}, 10, 2, 5, 3, null)
	var null_item_frame: Dictionary = {"facing_tiles": [[copper_wall], [lead_wall]], "items": {}, "time": 80.0, "facing_amount": 2, "multiplier": 1.0, "efficiency": 1.0}
	var null_item: Dictionary = beam_drill_build_state.source_beam_drill_drop_loop_state(null_item_frame, 1.0, 160.0, {"beryllium": 2.0}, 10, 2, 5, 3, null)
	proof["drop_multiplier"] = is_equal_approx(float(beryllium_hit.get("drill_time", -1.0)), 80.0) and int(beryllium_items.get("beryllium", -1)) == 2 and is_equal_approx(float(beryllium_hit.get("time", -1.0)), 0.0) and is_equal_approx(float(unmapped.get("drill_time", -1.0)), 160.0) and is_equal_approx(float(unmapped.get("time", -1.0)), 80.0) and (unmapped.get("items", {}) as Dictionary).is_empty() and null_item.get("last_item", "") == null and is_equal_approx(float(null_item.get("drill_time", -1.0)), 160.0) and is_equal_approx(float(null_item.get("time", -1.0)), 80.0)

	# --- Live tick: the plasma-bore is a BeamDrill with
	# a power consumer (consumePower 0.15f) and a
	# hydrogen booster row (consumeLiquid hydrogen
	# 0.25f/60f, Blocks.java:3049), placed live; the
	# tick driver is called directly (as the N2147/
	# N2148/N2149/N2150/N2153/N2154/N2155/N2156/N2157/
	# N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/
	# N2166/N2167/N2168/N2169/N2195/N2202/N2256/N2289
	# proofs do), not simulate_factory, so the graph
	# update does not overwrite the stamped
	# power_status -- the write-back itself is already
	# proven by N2142. The facing rays come from the
	# N2352 fill (the N2339 precedent): the frame seeds
	# world_tiles with a copper wall at (30, 20) on ray
	# 0 and a lead wall at (30, 21) on ray 1 (the N2346
	# origins for the drill at (28, 20), rotation 0),
	# so the scan stamps facing_amount 2 -- and the
	# drop loop reads lastItem null (two distinct drops)
	# and drillTime 160. Tick 1: the shouldConsume gate
	# reads the PREVIOUS facing_amount (0, seeded --
	# Java order, BuildingComp.java:2274-2277,
	# updateConsumption before updateTile), so the gate
	# is closed and efficiency folds 0 -- time freezes
	# at 0.0 and nothing drops. Between the ticks the
	# frame clock is seeded to 159.0 (the N2310 re-seed
	# precedent: the frame dict persists on the sprite
	# meta). Tick 2: the gate reads the stamped 2, so
	# efficiency folds the power min 1.0, the advance
	# moves time 159.0 + 1.0 * 1.0 * 1.0 * 1.0 = 160.0
	# (multiplier lerp(1, 2.5, 0) = 1.0 with no
	# hydrogen), the drop loop fires (160.0 >= 160):
	# one copper + one lead land in the store, produced
	# reports both, time resets to 0.0, and
	# lastDrillSpeed is (2 * 1 * 1) / 160 * 1 = 0.0125.
	# The timerDump dump does not fire (the clock sits
	# at 2.0 after two ticks, below 5).
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
	drill_frame["world_tiles"] = {"30,20": {"solid": true, "wall_drop": copper}, "30,21": {"solid": true, "wall_drop": lead}}
	drill.set_meta(block_geometry.SOURCE_BUILD_ROTATION_META_KEY, 0)
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var tick_one_time: float = float(drill_frame.get("time", -1.0))
	var tick_one_items: Dictionary = drill_frame.get("items", {})
	drill_frame["time"] = 159.0
	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var live_items: Dictionary = drill_frame.get("items", {})
	var live_produced: Dictionary = drill_frame.get("produced", {})
	var live_facing: Array = drill_frame.get("facing", [])
	var live_facing_zero: Dictionary = live_facing[0] if live_facing.size() > 0 and live_facing[0] is Dictionary else {}
	var live_facing_zero_drop: Dictionary = live_facing_zero.get("wall_drop", {}) if live_facing_zero.get("wall_drop", null) is Dictionary else {}
	proof["drop_live_tick"] = is_equal_approx(tick_one_time, 0.0) and (tick_one_items as Dictionary).is_empty() and is_equal_approx(float(drill_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(drill_frame.get("multiplier", -1.0)), 1.0) and is_equal_approx(float(drill_frame.get("time", -1.0)), 0.0) and int(live_items.get("copper", -1)) == 1 and int(live_items.get("lead", -1)) == 1 and int(live_produced.get("copper", -1)) == 1 and int(live_produced.get("lead", -1)) == 1 and drill_frame.get("last_item", "") == null and is_equal_approx(float(drill_frame.get("drill_time", -1.0)), 160.0) and is_equal_approx(float(drill_frame.get("last_drill_speed", -1.0)), 0.0125) and live_facing.size() == 2 and str(live_facing_zero_drop.get("id", "")) == "copper" and is_equal_approx(float(drill_frame.get("timer_dump_elapsed", -1.0)), 2.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillDropLoopProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
