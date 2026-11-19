extends Node

const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
const drill_build_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
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

	# --- Pure advance (N2219): BurstDrillBuild.updateTile()
	# (BurstDrill.java:76-125): the invertTime decay
	# (BurstDrill.java:81), the smoothProgress lerpDelta
	# (BurstDrill.java:89), the gate branch (BurstDrill.java:
	# 91-99: warmup approachDelta toward progress/drillTime,
	# speed = lerp(1, liquidBoostIntensity,
	# optionalEfficiency) * efficiency, timeDrilled +=
	# pow2In(progress/drillTime) * speed, lastDrillSpeed,
	# progress += delta() * speed), the blocked branch
	# (BurstDrill.java:100-104: warmup toward 0,
	# lastDrillSpeed 0, return), and the offload branch
	# (BurstDrill.java:106-112: offload dominantItem x
	# dominantItems, invertTime = 1f, progress %= drillTime).
	# The drillTime uses the BurstDrill getDrillTime OVERRIDE
	# (BurstDrill.java:54, `return drillTime /
	# drillMultipliers.get(item, 1f);`, NO hardness term), not
	# the base-Drill formula (Drill.java:171). source_delta is
	# Time.delta in ticks (1.0 = one tick). The pure calls use
	# the eruption def values (drillTime 281.25f,
	# liquidBoostIntensity 2f, itemCapacity 60, Blocks.java:
	# 3095/:3115/:3107) unless noted.
	var advance_frame: Dictionary = {"dominant_item": {"id": 1}, "dominant_items": 5, "efficiency": 1.0, "optional_efficiency": 0.0, "items": {}}
	var advanced: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_advance_state(advance_frame, 1.0, 1.0, 281.25, 2.0, 1.0, "copper", 60)
	# The frame omits progress / warmup / time_drilled /
	# last_drill_speed / smooth_progress / invert_time, so
	# they default to the 0f Java field defaults
	# (Drill.java:238-241, BurstDrill.java:72-73). One tick at
	# full efficiency: speed = lerp(1, 2, 0) * 1 = 1, progress
	# += 1 * 1 = 1, lastDrillSpeed = 1/281.25 * 1 * 5.
	proof["progress_advances_when_efficient"] = is_equal_approx(float(advanced.get("progress", -1.0)), 1.0) and is_equal_approx(float(advanced.get("drill_time", -1.0)), 281.25) and is_equal_approx(float(advanced.get("speed", -1.0)), 1.0) and is_equal_approx(float(advanced.get("last_drill_speed", -1.0)), 5.0 / 281.25) and is_equal_approx(float(advanced.get("warmup", -1.0)), 0.0) and int(advanced.get("offloaded", -1)) == 0

	var warmup_frame: Dictionary = {"dominant_item": {"id": 1}, "dominant_items": 5, "efficiency": 1.0, "optional_efficiency": 0.0, "items": {}, "progress": 140.625, "warmup": 0.0, "time_drilled": 0.0, "smooth_progress": 0.0}
	var warmed: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_advance_state(warmup_frame, 1.0, 1.0, 281.25, 2.0, 1.0, "copper", 60)
	# progress/drillTime = 140.625/281.25 = 0.5: warmup moves
	# one 0.01 approachDelta step toward 0.5, timeDrilled +=
	# pow2In(0.5) * 1 = 0.25, smoothProgress lerps 0.1 of the
	# way toward 140.625/(281.25 - 20). A warmup already AT
	# the ratio stays put.
	var settled_frame: Dictionary = {"dominant_item": {"id": 1}, "dominant_items": 5, "efficiency": 1.0, "optional_efficiency": 0.0, "items": {}, "progress": 140.625, "warmup": 0.5, "time_drilled": 0.0, "smooth_progress": 0.0}
	var settled: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_advance_state(settled_frame, 1.0, 1.0, 281.25, 2.0, 1.0, "copper", 60)
	proof["warmup_approaches_progress_ratio"] = is_equal_approx(float(warmed.get("warmup", -1.0)), 0.01) and is_equal_approx(float(warmed.get("time_drilled", -1.0)), 0.25) and is_equal_approx(float(warmed.get("smooth_progress", -1.0)), 0.1 * (140.625 / 261.25)) and is_equal_approx(float(settled.get("warmup", -1.0)), 0.5)

	var offload_frame: Dictionary = {"dominant_item": {"id": 8}, "dominant_items": 5, "efficiency": 1.0, "optional_efficiency": 0.0, "items": {"beryllium": 10}, "progress": 140.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "smooth_progress": 0.0, "invert_time": 0.0}
	var offloaded: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_advance_state(offload_frame, 1.0, 1.0, 281.25, 2.0, 2.0, "beryllium", 60)
	# The beryllium drill multiplier is 2f (Blocks.java:3114),
	# so the effective drillTime is 281.25/2 = 140.625: one
	# tick takes progress 140.0 -> 141.0, past the threshold,
	# so 5 beryllium offload into the store, invertTime sets
	# to 1f, and progress wraps to 141.0 - 140.625 = 0.375.
	var offloaded_items: Dictionary = offloaded.get("items", {})
	proof["offload_at_drill_time"] = is_equal_approx(float(offloaded.get("drill_time", -1.0)), 140.625) and int(offloaded.get("offloaded", -1)) == 5 and int(offloaded_items.get("beryllium", -1)) == 15 and is_equal_approx(float(offloaded.get("progress", -1.0)), 0.375)

	var decay_frame: Dictionary = {"dominant_item": {"id": 1}, "dominant_items": 5, "efficiency": 1.0, "optional_efficiency": 0.0, "items": {}, "progress": 0.0, "warmup": 0.0, "time_drilled": 0.0, "last_drill_speed": 0.0, "smooth_progress": 0.0, "invert_time": 1.0}
	var decayed: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_advance_state(decay_frame, 1.0, 1.0, 281.25, 2.0, 1.0, "copper", 60)
	# invertTime is 1f right after the offload above, and it
	# decays by delta()/invertedTime = 1/200 per tick while
	# positive (BurstDrill.java:81, invertedTime 200f).
	proof["invert_time_set_on_offload"] = is_equal_approx(float(offloaded.get("invert_time", -1.0)), 1.0) and is_equal_approx(float(decayed.get("invert_time", -1.0)), 1.0 - 1.0 / 200.0)

	var blocked_frame: Dictionary = {"dominant_item": {"id": 1}, "dominant_items": 5, "efficiency": 0.0, "optional_efficiency": 0.0, "items": {}, "progress": 100.0, "warmup": 0.5, "time_drilled": 10.0, "last_drill_speed": 0.5, "smooth_progress": 0.0, "invert_time": 0.0}
	var blocked: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_advance_state(blocked_frame, 1.0, 1.0, 281.25, 2.0, 1.0, "copper", 60)
	var full_frame: Dictionary = {"dominant_item": {"id": 1}, "dominant_items": 5, "efficiency": 1.0, "optional_efficiency": 0.0, "items": {"copper": 60}, "progress": 100.0, "warmup": 0.5, "time_drilled": 10.0, "last_drill_speed": 0.5, "smooth_progress": 0.0, "invert_time": 0.0}
	var full: Dictionary = burst_drill_build_state.source_burst_drill_update_tile_advance_state(full_frame, 1.0, 1.0, 281.25, 2.0, 1.0, "copper", 60)
	# Blocked by zero efficiency AND blocked by a full store
	# (60 > 60 - 5): lastDrillSpeed is 0, warmup decays one
	# 0.01 step toward 0, progress and timeDrilled freeze,
	# and the offload branch never runs (return,
	# BurstDrill.java:100-104).
	proof["last_drill_speed_zero_when_blocked"] = is_equal_approx(float(blocked.get("last_drill_speed", -1.0)), 0.0) and is_equal_approx(float(blocked.get("warmup", -1.0)), 0.49) and is_equal_approx(float(blocked.get("progress", -1.0)), 100.0) and is_equal_approx(float(blocked.get("time_drilled", -1.0)), 10.0) and int(blocked.get("offloaded", -1)) == 0 and is_equal_approx(float(full.get("last_drill_speed", -1.0)), 0.0) and is_equal_approx(float(full.get("progress", -1.0)), 100.0)

	# --- Live tick: the eruption-drill is a BurstDrill with a
	# power consumer (consumePower 6f, itemCapacity 60),
	# placed live on copper ore; the tick driver is called
	# directly (as the N2149/N2203 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is
	# one source tick: half power folds efficiency to 0.5,
	# optionalEfficiency folds to the same 0.5 with no
	# optional rows modeled, so speed = lerp(1, 2, 0.5) * 0.5
	# = 0.75 and progress advances 0.75; warmup stays 0
	# (its target is progress/drillTime = 0 on the first
	# tick) and lastDrillSpeed is positive with live ore.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var eruption_cell := Vector2i(28, 20)
	var eruption := Sprite2D.new()
	game.add_child(eruption)
	var terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
	for occupied in game.call("occupied_cells", eruption_cell, blocks_by_id["eruption-drill"]):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("ore-copper"), false)
	game.call("record_placed_block", eruption, blocks_by_id["eruption-drill"], eruption_cell)
	# Bind the frame + dominant item from the ore under the
	# footprint: the overlay mutation binds proximity only when a
	# sprite is already on the cell, and the overlays were set
	# before placement, so bind explicitly here (the N2149
	# pattern; BurstDrillBuild extends DrillBuild, so the drill
	# proximity path binds the shared "source_drill_building"
	# frame and sets dominant_items from the ore count).
	drill_build_state.source_on_proximity_update_state(game, eruption, blocks_by_id["eruption-drill"])
	var eruption_frame: Dictionary = eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	# Supply the later required hydrogen consumer; preserve the original power/progress expectations.
	liquid_module_state.source_set_state(eruption.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY), int(liquid_catalog["liquid_id_by_name"]["hydrogen"]), 1.0)
	# This scenario expects boosted speed 0.75 at half power: cyanogen booster (Blocks.java:3120).
	liquid_module_state.source_set_state(eruption.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY), int(liquid_catalog["liquid_id_by_name"]["cyanogen"]), 1.0)

	eruption_frame["power_status"] = 0.5
	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	eruption_frame = eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	proof["live_tick_advances_progress"] = is_equal_approx(float(eruption_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(eruption_frame.get("progress", -1.0)), 0.75) and float(eruption_frame.get("last_drill_speed", -1.0)) > 0.0 and is_equal_approx(float(eruption_frame.get("warmup", -1.0)), 0.0) and int(eruption_frame.get("dominant_items", 0)) > 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
