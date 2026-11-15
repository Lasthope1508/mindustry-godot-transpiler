extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mechanical_pump_build_state := preload("res://src/game/SourceMechanicalPumpBuildState.gd")
const terrain_state := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	# --- Pure dump (N2285): PumpBuild.updateTile()
	# (Pump.java:160-182): after `totalProgress += warmup *
	# Time.delta;` (Pump.java:176), `if(liquidDrop != null){`
	# `dumpLiquid(liquidDrop);` (Pump.java:178-180).
	# dumpLiquid(Liquid) scales by 2f
	# (BuildingComp.java:877-878) into the implementation
	# (BuildingComp.java:886-908): early return at
	# `if(liquids.get(liquid) <= 0.0001f) return;`
	# (BuildingComp.java:889), the proximity scan from
	# cdump with `incrementDump(proximity.size);` each
	# iteration, the eligibility gate
	# (BuildingComp.java:901), and the fraction transfer
	# `if(ofract < fract) transferLiquid(other, (fract -
	# ofract) * block.liquidCapacity / scaling, liquid);`
	# (BuildingComp.java:905) with flow = min(neighbour
	# free capacity, amount) gated on acceptLiquid
	# (BuildingComp.java:914-921). The liquids stand-in
	# mirrors the live module shape ({"liquids": [...],
	# "current": id, "flow": null}) with a one-liquid map;
	# the pure dump reads the drop's slot and returns a
	# copy with the dumped amount removed -- it does not
	# mutate the store. The rotary-pump capacity is 80f
	# (Blocks.java:2308).
	var single: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0], [20.0], [true], [true])
	var single_after: Dictionary = single.get("liquids_after", {})
	# fract 40/80 = 0.5, ofract 0/20 = 0: transfer
	# (0.5 - 0) * 80 / 2 = 20, flow min(20 - 0, 20) = 20.
	var pair: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0, 0.0], [20.0, 20.0], [true, true], [true, true])
	var pair_after: Dictionary = pair.get("liquids_after", {})
	# Two empty 20-cap neighbours in order: the first takes
	# 20 (fract 0.5), the second takes 10 (fract 20/80 =
	# 0.25), 30 dumped in total. The cursor wraps back to
	# 0 after a full loop (incrementDump runs once per
	# iteration: 0 -> 1 -> 0).
	proof["dump_transfers_to_neighbour"] = is_equal_approx(float(single.get("dumped_amount", -1.0)), 20.0) and is_equal_approx(float(single_after.get("liquids", [-1.0])[0]), 20.0) and int(single.get("cursor_after", -1)) == 0 and is_equal_approx(float(pair.get("dumped_amount", -1.0)), 30.0) and is_equal_approx(float(pair_after.get("liquids", [-1.0])[0]), 10.0) and int(pair.get("cursor_after", -1)) == 0

	# Scaling 2f halves the transfer: with scaling 1 the
	# 40/80 pump would move 40 to an empty 80-cap
	# neighbour; with scaling 2 it moves 20. A 60/80 pump
	# moves 30, not 60.
	var scaled_half: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0], [80.0], [true], [true])
	var scaled_three_quarters: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [60.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0], [80.0], [true], [true])
	proof["dump_scales_by_two"] = is_equal_approx(float(scaled_half.get("dumped_amount", -1.0)), 20.0) and is_equal_approx(float(scaled_three_quarters.get("dumped_amount", -1.0)), 30.0)

	# No transfer when the neighbour is fuller (ofract 1.0
	# > fract 0.5), when the fractions are equal (the
	# guard is a STRICT ofract < fract), or when the
	# neighbour does not accept the liquid -- the store
	# and the cursor are untouched in all three cases.
	var fuller: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [20.0], [20.0], [true], [true])
	var equal: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [10.0], [20.0], [true], [true])
	var refused: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0], [20.0], [false], [true])
	var fuller_after: Dictionary = fuller.get("liquids_after", {})
	var equal_after: Dictionary = equal.get("liquids_after", {})
	var refused_after: Dictionary = refused.get("liquids_after", {})
	proof["dump_no_transfer_when_neighbour_full"] = is_equal_approx(float(fuller.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(fuller_after.get("liquids", [-1.0])[0]), 40.0) and is_equal_approx(float(equal.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(equal_after.get("liquids", [-1.0])[0]), 40.0) and is_equal_approx(float(refused.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(refused_after.get("liquids", [-1.0])[0]), 40.0)

	# No liquid drop, no dump -- even with a full store and
	# an empty neighbour waiting, and the cursor does not
	# move (Java never calls dumpLiquid, so incrementDump
	# never runs).
	var dry: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 1}, null, {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0, 0.0], [20.0, 20.0], [true, true], [true, true])
	var dry_after: Dictionary = dry.get("liquids_after", {})
	var dry_defaults: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({}, null, {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [], [], [], [])
	proof["dump_skipped_when_no_liquid_drop"] = is_equal_approx(float(dry.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(dry_after.get("liquids", [-1.0])[0]), 40.0) and int(dry.get("cursor_after", -1)) == 1 and is_equal_approx(float(dry_defaults.get("dumped_amount", -1.0)), 0.0) and int(dry_defaults.get("cursor_after", -1)) == 0

	# At or below the 0.0001f threshold nothing dumps and
	# the cursor does not move; just above it the dump runs
	# (fract 0.0002/80, transfer 0.0001).
	var threshold: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 1}, "water", {"liquids": [0.0001], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0, 0.0], [20.0, 20.0], [true, true], [true, true])
	var threshold_after: Dictionary = threshold.get("liquids_after", {})
	var empty: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [0.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0], [20.0], [true], [true])
	var above: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [0.0002], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0], [20.0], [true], [true])
	proof["dump_no_transfer_below_threshold"] = is_equal_approx(float(threshold.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(threshold_after.get("liquids", [-1.0])[0]), 0.0001) and int(threshold.get("cursor_after", -1)) == 1 and is_equal_approx(float(empty.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(above.get("dumped_amount", -1.0)), 0.0001)

	# --- Live tick: the rotary-pump is a Pump with a power
	# consumer (consumePower 0.3f, liquidCapacity 80f,
	# pumpAmount 0.2f), placed live on shallow-water floor so
	# the per-tick proximity scan finds liquidDrop water with
	# amount 4.0 (four size-2 footprint tiles at multiplier
	# 1.0); the tick driver is called directly (as the N2154
	# / N2205 / N2221 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped power_status
	# -- the write-back itself is already proven by N2142. One
	# 1/60s tick is one source tick: efficiency folds the
	# power min 0.5, edelta is 0.5, maxPump is min(80 - 0,
	# 4.0 * 0.2 * 0.5) = 0.4, warmup rises 0.019 toward 1,
	# totalProgress rises 0.019, consTimer rises 1.0 -- and
	# then the dump runs (Java order: Pump.java:178-180
	# after :176) against the stamped neighbour inputs: fract
	# 0.4/80 = 0.005, transfer 0.005 * 80 / 2 = 0.2, so the
	# store holds 0.2 after the tick -- the dump drains what
	# the advance pumped THIS tick.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var liquid_id_by_name: Dictionary = content_registry_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
	var water_id: int = int(liquid_id_by_name.get("water", -1))

	var pump_cell := Vector2i(28, 20)
	var shallow_water = catalog.get_by_id("shallow-water")
	for occupied in game.call("occupied_cells", pump_cell, blocks_by_id["rotary-pump"]):
		terrain_state.source_set_world_floor_state(game, occupied.x, occupied.y, shallow_water)
	var pump := Sprite2D.new()
	game.add_child(pump)
	game.call("record_placed_block", pump, blocks_by_id["rotary-pump"], pump_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and the
	# neighbour inputs on it).
	mechanical_pump_build_state.source_mechanical_pump_bind_frame_state(pump, blocks_by_id["rotary-pump"])
	var pump_frame: Dictionary = pump.get_meta(mechanical_pump_build_state.SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, {})

	pump_frame["power_status"] = 0.5
	pump_frame["dump_neighbour_amounts"] = [0.0]
	pump_frame["dump_neighbour_capacities"] = [20.0]
	pump_frame["dump_neighbour_accepts"] = [true]
	pump_frame["dump_neighbour_can_dump"] = [true]
	mechanical_pump_build_state.source_mechanical_pump_tick_buildings_state(game, 1.0 / 60.0)
	pump_frame = pump.get_meta(mechanical_pump_build_state.SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, {})
	var pump_liquids: Dictionary = pump.get_meta("source_building_liquids", {})
	var stored_water: float = 0.0
	if water_id >= 0 and water_id < pump_liquids.get("liquids", []).size():
		stored_water = float(pump_liquids["liquids"][water_id])
	proof["live_tick_dumps_liquid"] = is_equal_approx(float(pump_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(stored_water, 0.2) and is_equal_approx(float(pump_frame.get("warmup", -1.0)), 0.019) and is_equal_approx(float(pump_frame.get("total_progress", -1.0)), 0.019) and is_equal_approx(float(pump_frame.get("cons_timer", -1.0)), 1.0) and int(pump_frame.get("cdump", -1)) == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PumpDumpLiquidProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
