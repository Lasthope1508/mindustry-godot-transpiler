extends Node

const main_scene := preload("res://scenes/Main.tscn")
const launch_pad_build_state := preload("res://src/game/SourceLaunchPadBuildState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	# --- Advanced variant (N2400): the advanced-launch-pad
	# def (Blocks.java:6800-6809) runs through the SAME
	# driver as the launch-pad def (Blocks.java:6790-6797).
	# Advanced: size 4, itemCapacity 100, launchTime 60f *
	# 30 = 1800f, liquidCapacity 40f, drawLiquid oil,
	# consumeLiquid oil 9f/60f, consumePower 8f. Plain:
	# size 3, itemCapacity 100, launchTime 60f * 20 =
	# 1200f, acceptMultipleItems true, consumePower 4f,
	# no liquid at all. Class defaults (LaunchPad.java:
	# 32/40): launchTime 1f, acceptMultipleItems false;
	# Block.java:75/77: itemCapacity 10, liquidCapacity
	# -1f (derived in Block.init when negative -- the
	# plain def derives 10f, the advanced def keeps its
	# explicit 40f). VERIFICATION ONLY: this proof
	# checks the values flow through the driver and the
	# catalog, it fixes nothing. One gap is REPORTED,
	# not fixed: the catalog carries NO liquidCapacity
	# for either def (31 other blocks DO carry it), and
	# no LaunchPad code reads liquidCapacity anywhere,
	# so the Java 40f flows nowhere in the port -- the
	# catalog-rows key below pins that absence, and the
	# full-store key shows the 40f value itself still
	# folds the oil row to 1.0 when held.

	# --- Catalog rows: both defs are LaunchPad
	# implementations; the per-def size / consumePower /
	# powerUsage / itemCapacity / consumeLiquid rows are
	# what the driver reads live (the power row keys off
	# has("consumePower"), the liquid row off the
	# consumeLiquid rows, itemCapacity off the catalog
	# with the Block default 10). launchTime is in NO
	# catalog row -- the driver stamps it per def by
	# block id (1200f / 1800f) every tick. liquidCapacity
	# is likewise absent from BOTH rows -- the reported
	# gap (see the header comment).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var small_block = blocks_by_id["launch-pad"]
	var large_block = blocks_by_id["advanced-launch-pad"]
	var small_properties: Dictionary = small_block.properties
	var large_properties: Dictionary = large_block.properties
	var large_liquid_rows: Array = large_properties.get("consumeLiquid", [])
	proof["advanced_def_catalog_rows"] = str(small_block.implementation) == "LaunchPad" and str(large_block.implementation) == "LaunchPad" and int(small_properties.get("size", -1)) == 3 and int(large_properties.get("size", -1)) == 4 and is_equal_approx(float(small_properties.get("consumePower", -1.0)), 4.0) and is_equal_approx(float(large_properties.get("consumePower", -1.0)), 8.0) and is_equal_approx(float(small_properties.get("powerUsage", -1.0)), 4.0) and is_equal_approx(float(large_properties.get("powerUsage", -1.0)), 8.0) and int(small_properties.get("itemCapacity", -1)) == 100 and int(large_properties.get("itemCapacity", -1)) == 100 and large_liquid_rows.size() == 1 and str(large_liquid_rows[0].get("liquid", "")) == "oil" and is_equal_approx(float(large_liquid_rows[0].get("amount", -1.0)), 0.15) and not small_properties.has("consumeLiquid") and not small_properties.has("launchTime") and not large_properties.has("launchTime") and not small_properties.has("liquidCapacity") and not large_properties.has("liquidCapacity")

	# --- Pure sense (N2389): progress is clampf(
	# launch_counter / launch_time, 0.0, 1.0) with the
	# per-def launchTime as the explicit input -- 900 /
	# 1800 = 0.5 for the advanced def, 600 / 1200 = 0.5
	# for the plain def, and the SAME counter 900 reads
	# 0.75 at the plain 1200f, so the launchTime is a
	# live input, not a constant. The shouldConsume
	# gate (N2186, `return launchCounter < launchTime;`,
	# LaunchPad.java:94) closes exactly at each def's
	# own threshold: 1799.0 < 1800 consumes, 1800.0
	# does not; 1199.0 < 1200 consumes, 1200.0 does
	# not -- so an advanced pad at counter 1500 still
	# consumes while a plain pad at 1500 stopped long
	# ago.
	var half_advanced: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("progress", 900.0, 1800.0)
	var half_plain: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("progress", 600.0, 1200.0)
	var same_counter_plain: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("progress", 900.0, 1200.0)
	var full_advanced: Dictionary = launch_pad_build_state.source_launch_pad_sense_state("progress", 1800.0, 1800.0)
	var gate_open_advanced: Dictionary = launch_pad_build_state.source_launch_pad_should_consume_state({"launch_counter": 1799.0, "launch_time": 1800.0})
	var gate_shut_advanced: Dictionary = launch_pad_build_state.source_launch_pad_should_consume_state({"launch_counter": 1800.0, "launch_time": 1800.0})
	var gate_open_plain: Dictionary = launch_pad_build_state.source_launch_pad_should_consume_state({"launch_counter": 1199.0, "launch_time": 1200.0})
	var gate_shut_plain: Dictionary = launch_pad_build_state.source_launch_pad_should_consume_state({"launch_counter": 1200.0, "launch_time": 1200.0})
	proof["advanced_def_launch_time_1800_sense"] = is_equal_approx(float(half_advanced.get("value", -1.0)), 0.5) and is_equal_approx(float(half_plain.get("value", -1.0)), 0.5) and is_equal_approx(float(same_counter_plain.get("value", -1.0)), 0.75) and is_equal_approx(float(full_advanced.get("value", -1.0)), 1.0) and bool(gate_open_advanced.get("should_consume", false)) == true and bool(gate_shut_advanced.get("should_consume", true)) == false and bool(gate_open_plain.get("should_consume", false)) == true and bool(gate_shut_plain.get("should_consume", true)) == false

	# --- Pure advance (N2238): the launch gate
	# (`if((launchCounter += edelta()) >= launchTime &&
	# items.total() >= itemCapacity){`, LaunchPad.java:
	# 146) fires per def. Counter 1199.0 + edelta 1.0
	# (efficiency 1.0, delta 1.0, timeScale 1.0) with a
	# full pad (100 copper) LAUNCHES at the plain
	# 1200f (stacks copied, items cleared, counter
	# reset to 0f) but only advances to 1200.0 at the
	# advanced 1800f (no launch, items kept).
	var plain_frame: Dictionary = {"launch_counter": 1199.0, "launch_time": 1200.0, "efficiency": 1.0, "items": {"copper": 100}}
	var plain_launched: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state(plain_frame, 1.0, 1.0, 100)
	var advanced_frame: Dictionary = {"launch_counter": 1199.0, "launch_time": 1800.0, "efficiency": 1.0, "items": {"copper": 100}}
	var advanced_held: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state(advanced_frame, 1.0, 1.0, 100)
	proof["advanced_def_launch_time_1800_advance"] = bool(plain_launched.get("launched", false)) == true and Dictionary(plain_launched.get("launched_stacks", {})).get("copper", -1) == 100 and Dictionary(plain_launched.get("items", {"copper": -1})).is_empty() and is_equal_approx(float(plain_launched.get("launch_counter", -1.0)), 0.0) and bool(advanced_held.get("launched", true)) == false and Dictionary(advanced_held.get("items", {})).get("copper", -1) == 100 and is_equal_approx(float(advanced_held.get("launch_counter", -1.0)), 1200.0)

	# --- Pure oil row (N2253): ConsumeLiquid.efficiency
	# (ConsumeLiquid.java:42-47) at the advanced amount
	# 0.15 = 9f/60f per tick. Starved oil (0.075 held)
	# folds 0.5; a full store at the Java liquidCapacity
	# 40f folds 1.0 -- the 40f value is the def's full
	# store even though the catalog does not carry it
	# (the reported gap: nothing in the port caps the
	# store at 40f, the row only ever reads what is
	# held). No liquid consumer means no row at all --
	# the plain def's shape.
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var oil_id: int = int(liquid_id_by_name.get("oil", -1))
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog.get("content_liquid_ids", []))
	starved_liquids["liquids"][oil_id] = 0.075
	var starved_row: Dictionary = launch_pad_build_state.source_launch_pad_liquid_consumer_row_state({"liquids": starved_liquids}, true, oil_id, 0.15, 1.0, 1.0, 1.0, 1.0)
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog.get("content_liquid_ids", []))
	full_liquids["liquids"][oil_id] = 40.0
	var full_row: Dictionary = launch_pad_build_state.source_launch_pad_liquid_consumer_row_state({"liquids": full_liquids}, true, oil_id, 0.15, 1.0, 1.0, 1.0, 1.0)
	var absent_row: Dictionary = launch_pad_build_state.source_launch_pad_liquid_consumer_row_state({"liquids": full_liquids}, false, oil_id, 0.15, 1.0, 1.0, 1.0, 1.0)
	proof["advanced_def_oil_row_live"] = oil_id >= 0 and bool(starved_row.get("has_liquid_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.5) and bool(starved_row.get("row", {}).get("is_power", true)) == false and bool(full_row.get("has_liquid_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0) and bool(absent_row.get("has_liquid_row", true)) == false

	# --- Size 4 footprint: the driver never reads size
	# (no properties.get("size") in the driver -- the
	# size flows through the catalog into placement /
	# geometry). The geometry helpers turn the catalog
	# size into world extents: block_world_size(size,
	# 32) is 128.0 for the advanced def vs 96.0 for the
	# plain def (game tile_size 32, rendering px), and
	# the Java-world hitbox (tilesize 8.0, the N2364
	# lesson -- game tile_size is NOT Java world units)
	# is 32.0 vs 24.0 wide.
	var advanced_hitbox: Dictionary = block_geometry.tile_get_hitbox_state(28, 21, 4, 8.0, 0.0)
	var plain_hitbox: Dictionary = block_geometry.tile_get_hitbox_state(28, 26, 3, 8.0, 0.0)
	proof["advanced_def_size_4_hitbox"] = is_equal_approx(float(block_geometry.block_world_size(4, 32)), 128.0) and is_equal_approx(float(block_geometry.block_world_size(3, 32)), 96.0) and is_equal_approx(float(advanced_hitbox.get("size", -1.0)), 32.0) and is_equal_approx(float(plain_hitbox.get("size", -1.0)), 24.0)

	# --- Live tick: an advanced-launch-pad and a plain
	# launch-pad placed live, disjoint footprints
	# (advanced size 4 at (28, 21), plain size 3 at
	# (28, 26)). The tick driver is called directly
	# (the N2147-N2172 proof pattern), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142.
	# record_placed_block binds the consumeLiquid row
	# and initializes the liquids store for the
	# advanced def (PortGame.gd); the proof falls back
	# to building the store itself if the meta is
	# somehow absent (the N2253 pattern). One tick
	# (1/60 s = 1.0 source tick): the advanced pad
	# stamps launch_time 1800f, folds efficiency 1.0
	# (full power + full oil), advances its counter
	# 900.0 -> 901.0, and the second pass removes
	# 0.15 * 1.0 * 1.0 = 0.15 oil (10.0 -> 9.85); the
	# plain pad stamps 1200f, folds efficiency 0.5
	# (half power, no liquid row), and advances 600.0
	# -> 600.5. Neither launches (both pads hold no
	# items).
	var advanced_cell := Vector2i(28, 21)
	var advanced_pad := Sprite2D.new()
	game.add_child(advanced_pad)
	game.call("record_placed_block", advanced_pad, blocks_by_id["advanced-launch-pad"], advanced_cell)
	var plain_cell := Vector2i(28, 26)
	var plain_pad := Sprite2D.new()
	game.add_child(plain_pad)
	game.call("record_placed_block", plain_pad, blocks_by_id["launch-pad"], plain_cell)
	# Bind the frames explicitly (the N2149 pattern:
	# the driver binds them on their first tick, but
	# the proof needs the live frame dicts before the
	# tick to stamp power_status, the counters, and
	# the oil on them).
	launch_pad_build_state.source_launch_pad_bind_frame_state(advanced_pad, blocks_by_id["advanced-launch-pad"])
	launch_pad_build_state.source_launch_pad_bind_frame_state(plain_pad, blocks_by_id["launch-pad"])
	var advanced_pad_frame: Dictionary = advanced_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	var plain_pad_frame: Dictionary = plain_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	var liquids_store: Dictionary = advanced_pad.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	if liquids_store.is_empty():
		liquids_store = liquid_module_state.source_initial_state(liquid_catalog.get("content_liquid_ids", []))
		advanced_pad.set_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, liquids_store)
	liquids_store["liquids"][oil_id] = 10.0
	advanced_pad_frame["power_status"] = 1.0
	advanced_pad_frame["launch_counter"] = 900.0
	plain_pad_frame["power_status"] = 0.5
	plain_pad_frame["launch_counter"] = 600.0
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	advanced_pad_frame = advanced_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	plain_pad_frame = plain_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	liquids_store = advanced_pad.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	proof["advanced_def_live_tick_stamps"] = is_equal_approx(float(advanced_pad_frame.get("launch_time", -1.0)), 1800.0) and is_equal_approx(float(advanced_pad_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(advanced_pad_frame.get("launch_counter", -1.0)), 901.0) and is_equal_approx(float(liquids_store["liquids"][oil_id]), 9.85) and bool(advanced_pad_frame.get("launched", true)) == false and is_equal_approx(float(plain_pad_frame.get("launch_time", -1.0)), 1200.0) and is_equal_approx(float(plain_pad_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(plain_pad_frame.get("launch_counter", -1.0)), 600.5) and bool(plain_pad_frame.get("launched", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadAdvancedVariantProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
