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

	# --- Pure advance (N2221): PumpBuild.updateTile()
	# (Pump.java:160-182): `if(efficiency > 0 && liquidDrop !=
	# null){` (Pump.java:161), `float maxPump = Math.min(
	# liquidCapacity - liquids.get(liquidDrop), amount *
	# pumpAmount * edelta());` (Pump.java:162),
	# `liquids.add(liquidDrop, maxPump);` (Pump.java:163),
	# `if((consTimer += delta()) >= consumeTime){`
	# (Pump.java:166) with `consTimer %= 1f;`
	# (Pump.java:168), `warmup = Mathf.approachDelta(warmup,
	# maxPump > 0.001f ? 1f : 0f, warmupSpeed);`
	# (Pump.java:171) in the pumping branch and `warmup =
	# Mathf.approachDelta(warmup, 0f, warmupSpeed);`
	# (Pump.java:173) otherwise, `totalProgress += warmup *
	# Time.delta;` (Pump.java:176) on the NEW warmup.
	# source_delta is Time.delta in ticks (1.0 = one tick).
	# The liquids stand-in mirrors the live module shape
	# ({"liquids": [...], "current": id, "flow": null}) with
	# a one-liquid map; the pure advance reads the drop's
	# slot but does not mutate the store -- the driver
	# performs liquids.add.
	var capped: Dictionary = mechanical_pump_build_state.source_mechanical_pump_update_tile_advance_state({"efficiency": 1.0, "warmup": 0.0, "total_progress": 0.0, "cons_timer": 0.0}, "water", 4.0, {"liquids": [79.9], "current": 0, "flow": null}, 80.0, 0.2, 1.0, 1.0, {"water": 0})
	var uncapped: Dictionary = mechanical_pump_build_state.source_mechanical_pump_update_tile_advance_state({"efficiency": 1.0, "warmup": 0.0, "total_progress": 0.0, "cons_timer": 0.0}, "water", 4.0, {"liquids": [0.0], "current": 0, "flow": null}, 80.0, 0.2, 1.0, 1.0, {"water": 0})
	proof["max_pump_capped_by_remaining_capacity"] = is_equal_approx(float(capped.get("max_pump", -1.0)), 0.1) and is_equal_approx(float(capped.get("liquid_amount", -1.0)), 80.0) and is_equal_approx(float(uncapped.get("max_pump", -1.0)), 0.8) and is_equal_approx(float(uncapped.get("liquid_amount", -1.0)), 0.8)

	var warmup_frame: Dictionary = {"efficiency": 1.0, "warmup": 0.0, "total_progress": 0.0, "cons_timer": 0.0}
	for iteration in range(60):
		var advanced: Dictionary = mechanical_pump_build_state.source_mechanical_pump_update_tile_advance_state(warmup_frame, "water", 4.0, {"liquids": [0.0], "current": 0, "flow": null}, 80.0, 0.2, 1.0, 1.0, {"water": 0})
		warmup_frame["warmup"] = advanced["warmup"]
		warmup_frame["total_progress"] = advanced["total_progress"]
		warmup_frame["cons_timer"] = advanced["cons_timer"]
	proof["warmup_approaches_one_when_pumping"] = is_equal_approx(float(warmup_frame.get("warmup", -1.0)), 1.0)

	var progress_frame: Dictionary = {"efficiency": 1.0, "warmup": 1.0, "total_progress": 0.0, "cons_timer": 0.0}
	for iteration in range(10):
		var advanced: Dictionary = mechanical_pump_build_state.source_mechanical_pump_update_tile_advance_state(progress_frame, "water", 4.0, {"liquids": [0.0], "current": 0, "flow": null}, 80.0, 0.2, 1.0, 1.0, {"water": 0})
		progress_frame["warmup"] = advanced["warmup"]
		progress_frame["total_progress"] = advanced["total_progress"]
		progress_frame["cons_timer"] = advanced["cons_timer"]
	# totalProgress uses the NEW warmup: with efficiency 0
	# the warmup decays 0.5 -> 0.481 in one tick and
	# totalProgress advances by 0.481, not 0.5.
	var decayed_progress: Dictionary = mechanical_pump_build_state.source_mechanical_pump_update_tile_advance_state({"efficiency": 0.0, "warmup": 0.5, "total_progress": 0.0, "cons_timer": 0.0}, "water", 4.0, {"liquids": [0.0], "current": 0, "flow": null}, 80.0, 0.2, 1.0, 1.0, {"water": 0})
	proof["total_progress_advances_with_warmup"] = is_equal_approx(float(progress_frame.get("total_progress", -1.0)), 10.0) and is_equal_approx(float(decayed_progress.get("warmup", -1.0)), 0.481) and is_equal_approx(float(decayed_progress.get("total_progress", -1.0)), 0.481)

	var timer_plain: Dictionary = mechanical_pump_build_state.source_mechanical_pump_update_tile_advance_state({"efficiency": 1.0, "warmup": 0.0, "total_progress": 0.0, "cons_timer": 10.0}, "water", 4.0, {"liquids": [0.0], "current": 0, "flow": null}, 80.0, 0.2, 1.0, 1.0, {"water": 0})
	var timer_wrap: Dictionary = mechanical_pump_build_state.source_mechanical_pump_update_tile_advance_state({"efficiency": 1.0, "warmup": 0.0, "total_progress": 0.0, "cons_timer": 299.5}, "water", 4.0, {"liquids": [0.0], "current": 0, "flow": null}, 80.0, 0.2, 1.0, 1.0, {"water": 0})
	var timer_exact: Dictionary = mechanical_pump_build_state.source_mechanical_pump_update_tile_advance_state({"efficiency": 1.0, "warmup": 0.0, "total_progress": 0.0, "cons_timer": 299.0}, "water", 4.0, {"liquids": [0.0], "current": 0, "flow": null}, 80.0, 0.2, 1.0, 1.0, {"water": 0})
	var timer_scaled: Dictionary = mechanical_pump_build_state.source_mechanical_pump_update_tile_advance_state({"efficiency": 1.0, "warmup": 0.0, "total_progress": 0.0, "cons_timer": 10.0}, "water", 4.0, {"liquids": [0.0], "current": 0, "flow": null}, 80.0, 0.2, 1.0, 2.0, {"water": 0})
	var timer_idle: Dictionary = mechanical_pump_build_state.source_mechanical_pump_update_tile_advance_state({"efficiency": 0.0, "warmup": 0.0, "total_progress": 0.0, "cons_timer": 10.0}, "water", 4.0, {"liquids": [0.0], "current": 0, "flow": null}, 80.0, 0.2, 1.0, 1.0, {"water": 0})
	proof["cons_timer_advances_and_wraps"] = is_equal_approx(float(timer_plain.get("cons_timer", -1.0)), 11.0) and is_equal_approx(float(timer_wrap.get("cons_timer", -1.0)), 0.5) and is_equal_approx(float(timer_exact.get("cons_timer", -1.0)), 0.0) and is_equal_approx(float(timer_scaled.get("cons_timer", -1.0)), 12.0) and is_equal_approx(float(timer_idle.get("cons_timer", -1.0)), 10.0)

	# An empty frame defaults everything to 0 (the Java
	# field defaults, Pump.java:111-112), and with no liquid
	# drop nothing pumps, the timer freezes, and warmup
	# decays toward 0.
	var dry_defaults: Dictionary = mechanical_pump_build_state.source_mechanical_pump_update_tile_advance_state({}, null, 0.0, {"liquids": [0.0], "current": 0, "flow": null}, 80.0, 0.2, 1.0, 1.0, {"water": 0})
	var dry_frame: Dictionary = {"efficiency": 1.0, "warmup": 1.0, "total_progress": 0.0, "cons_timer": 10.0}
	for iteration in range(60):
		var advanced: Dictionary = mechanical_pump_build_state.source_mechanical_pump_update_tile_advance_state(dry_frame, null, 0.0, {"liquids": [0.0], "current": 0, "flow": null}, 80.0, 0.2, 1.0, 1.0, {"water": 0})
		dry_frame["warmup"] = advanced["warmup"]
		dry_frame["total_progress"] = advanced["total_progress"]
		dry_frame["cons_timer"] = advanced["cons_timer"]
	var unpowered: Dictionary = mechanical_pump_build_state.source_mechanical_pump_update_tile_advance_state({"efficiency": 0.0, "warmup": 0.0, "total_progress": 0.0, "cons_timer": 0.0}, "water", 4.0, {"liquids": [0.0], "current": 0, "flow": null}, 80.0, 0.2, 1.0, 1.0, {"water": 0})
	proof["no_pump_without_liquid_drop"] = is_equal_approx(float(dry_defaults.get("max_pump", -1.0)), 0.0) and is_equal_approx(float(dry_defaults.get("liquid_amount", -1.0)), 0.0) and is_equal_approx(float(dry_defaults.get("cons_timer", -1.0)), 0.0) and is_equal_approx(float(dry_defaults.get("warmup", -1.0)), 0.0) and is_equal_approx(float(dry_defaults.get("total_progress", -1.0)), 0.0) and is_equal_approx(float(dry_frame.get("warmup", -1.0)), 0.0) and is_equal_approx(float(dry_frame.get("cons_timer", -1.0)), 10.0) and is_equal_approx(float(unpowered.get("max_pump", -1.0)), 0.0)

	# --- Live tick: the rotary-pump is a Pump with a power
	# consumer (consumePower 0.3f, liquidCapacity 80f,
	# pumpAmount 0.2f), placed live on shallow-water floor so
	# the per-tick proximity scan finds liquidDrop water with
	# amount 4.0 (four size-2 footprint tiles at multiplier
	# 1.0); the tick driver is called directly (as the N2154
	# / N2205 proofs do), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status --
	# the write-back itself is already proven by N2142. One
	# 1/60s tick is one source tick: efficiency folds the
	# power min 0.5, edelta is 0.5, maxPump is min(80 - 0,
	# 4.0 * 0.2 * 0.5) = 0.4, warmup rises 0.019 toward 1,
	# totalProgress rises 0.019, consTimer rises 1.0.
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
	# frame dict before the tick to stamp power_status on it).
	mechanical_pump_build_state.source_mechanical_pump_bind_frame_state(pump, blocks_by_id["rotary-pump"])
	var pump_frame: Dictionary = pump.get_meta(mechanical_pump_build_state.SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, {})

	pump_frame["power_status"] = 0.5
	mechanical_pump_build_state.source_mechanical_pump_tick_buildings_state(game, 1.0 / 60.0)
	pump_frame = pump.get_meta(mechanical_pump_build_state.SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, {})
	var pump_liquids: Dictionary = pump.get_meta("source_building_liquids", {})
	var stored_water: float = 0.0
	if water_id >= 0 and water_id < pump_liquids.get("liquids", []).size():
		stored_water = float(pump_liquids["liquids"][water_id])
	proof["live_tick_pumps_and_advances_warmup"] = is_equal_approx(float(pump_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(stored_water, 0.4) and is_equal_approx(float(pump_frame.get("warmup", -1.0)), 0.019) and is_equal_approx(float(pump_frame.get("total_progress", -1.0)), 0.019) and is_equal_approx(float(pump_frame.get("cons_timer", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MechanicalPumpUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
