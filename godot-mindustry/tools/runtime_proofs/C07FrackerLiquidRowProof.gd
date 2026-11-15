extends Node

const main_scene := preload("res://scenes/Main.tscn")
const fracker_build_state := preload("res://src/game/SourceFrackerBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# The liquid catalog resolves the consumed liquid's id
	# (the N2207 precedent): the pure row takes the catalog
	# id, the driver resolves it from liquid_id_by_name with
	# the def constant "water".
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))
	var content_liquid_ids: Array = liquid_catalog["content_liquid_ids"]

	# --- Pure liquid row (N2255): ConsumeLiquid.efficiency
	# (ConsumeLiquid.java:42-47, `float ed = build.edelta() *
	# build.efficiencyScale();` / `if(ed <= 0.00000001f)
	# return 0f;` / `return Math.min(build.liquids.get(
	# liquid) / (amount * ed * multiplier.get(build)), 1f);`)
	# with the first-pass efficiency assumed 1f
	# (BuildingComp.java:1965), so edelta = delta() =
	# source_delta * time_scale. The amount is 0.15f PER
	# FRAME (= 9/s, Blocks.java:2978), not /60f; the def
	# sets no multiplier, so the default 1f (Consume.java:18)
	# applies. source_delta is Time.delta in ticks (1.0 =
	# one tick). The amounts below are set through the shared
	# liquid module helper (SourceLiquidModuleState.
	# source_set_state) over a fresh module state, the same
	# store the driver reads.

	# Starved: 0.075 water at ed 1.0 folds 0.075 / (0.15 *
	# 1.0 * 1.0) = 0.5, with is_power false (so the shared
	# fold stops power draw when the row is <= 1e-7) -- and
	# a multiplier of 2.0 halves it again to 0.25. A def
	# with no liquid consumer contributes no row (the N2253
	# launch-pad precedent).
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, water_id, 0.075)
	var starved_row: Dictionary = fracker_build_state.source_fracker_liquid_consumer_row_state({"liquids": starved_liquids}, true, water_id, 0.15, 1.0, 1.0, 1.0)
	var doubled_row: Dictionary = fracker_build_state.source_fracker_liquid_consumer_row_state({"liquids": starved_liquids}, true, water_id, 0.15, 1.0, 1.0, 1.0, 2.0)
	var no_consumer: Dictionary = fracker_build_state.source_fracker_liquid_consumer_row_state({"liquids": starved_liquids}, false, water_id, 0.15, 1.0, 1.0, 1.0)
	proof["row_folds_below_one_when_starved"] = bool(starved_row.get("has_liquid_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.5) and bool(starved_row.get("row", {}).get("is_power", true)) == false and is_equal_approx(float(doubled_row.get("row", {}).get("result", -1.0)), 0.25) and bool(no_consumer.get("has_liquid_row", true)) == false

	# Full: 0.3 water caps at 1.0 (min(0.3 / 0.15, 1f)),
	# and exactly 0.15 -- one frame's worth -- also reads
	# 1.0. The def constants pin the consumed liquid and
	# the per-frame amount independently of the literals.
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, water_id, 0.3)
	var full_row: Dictionary = fracker_build_state.source_fracker_liquid_consumer_row_state({"liquids": full_liquids}, true, water_id, 0.15, 1.0, 1.0, 1.0)
	var exact_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(exact_liquids, water_id, 0.15)
	var exact_row: Dictionary = fracker_build_state.source_fracker_liquid_consumer_row_state({"liquids": exact_liquids}, true, water_id, 0.15, 1.0, 1.0, 1.0)
	proof["row_caps_at_one_when_full"] = bool(full_row.get("has_liquid_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0) and is_equal_approx(float(exact_row.get("row", {}).get("result", -1.0)), 1.0) and is_equal_approx(float(fracker_build_state.SOURCE_FRACKER_CONSUME_LIQUID_AMOUNT), 0.15) and str(fracker_build_state.SOURCE_FRACKER_CONSUME_LIQUID) == "water"

	# Zero edelta zeroes the row: source_delta 0.0 (ed 0)
	# and time_scale 0.0 (ed 0) both read 0.0 even with a
	# full store, and efficiency_scale 0.0 does the same --
	# the ed <= 1e-8 guard (ConsumeLiquid.java:44).
	var zero_delta_row: Dictionary = fracker_build_state.source_fracker_liquid_consumer_row_state({"liquids": full_liquids}, true, water_id, 0.15, 0.0, 1.0, 1.0)
	var zero_scale_row: Dictionary = fracker_build_state.source_fracker_liquid_consumer_row_state({"liquids": full_liquids}, true, water_id, 0.15, 1.0, 0.0, 1.0)
	var zero_efficiency_scale_row: Dictionary = fracker_build_state.source_fracker_liquid_consumer_row_state({"liquids": full_liquids}, true, water_id, 0.15, 1.0, 1.0, 0.0)
	proof["row_zeroes_when_edelta_zero"] = is_equal_approx(float(zero_delta_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(zero_scale_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(zero_efficiency_scale_row.get("row", {}).get("result", -1.0)), 0.0)

	# No liquid zeroes the row: an empty store, a frame with
	# no liquids key at all, and an unknown liquid id (-1,
	# the catalog miss) all read 0.0 -- Java's liquids.get
	# returns 0.0 for a liquid never added.
	var empty_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	var empty_row: Dictionary = fracker_build_state.source_fracker_liquid_consumer_row_state({"liquids": empty_liquids}, true, water_id, 0.15, 1.0, 1.0, 1.0)
	var no_store_row: Dictionary = fracker_build_state.source_fracker_liquid_consumer_row_state({}, true, water_id, 0.15, 1.0, 1.0, 1.0)
	var unknown_id_row: Dictionary = fracker_build_state.source_fracker_liquid_consumer_row_state({"liquids": full_liquids}, true, -1, 0.15, 1.0, 1.0, 1.0)
	proof["row_zeroes_without_liquid"] = is_equal_approx(float(empty_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(no_store_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(unknown_id_row.get("row", {}).get("result", -1.0)), 0.0)

	# --- Live tick: two oil-extractors placed live; the tick
	# driver is called directly (as the N2153/N2207 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. Extractor A (0.075
	# water, full power) folds efficiency 0.5 on the liquid
	# row; extractor B (0.3 water, half power) folds 0.5 on
	# the power row while its liquid row reads 1.0. The
	# second pass then removes amount * folded edelta from
	# each store: A loses 0.15 * 0.5 = 0.075 (empty), B loses
	# 0.075 (0.3 -> 0.225). The water amounts are set on the
	# sprite liquids meta store (the live LiquidModule),
	# which the driver syncs into the frame each tick. One
	# tick call ticks both extractors; both live keys read
	# after that single call.
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var extractor_a_cell := Vector2i(28, 20)
	var extractor_a := Sprite2D.new()
	game.add_child(extractor_a)
	game.call("record_placed_block", extractor_a, blocks_by_id["oil-extractor"], extractor_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	fracker_build_state.source_fracker_bind_frame_state(extractor_a, blocks_by_id["oil-extractor"])
	var extractor_a_frame: Dictionary = extractor_a.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var extractor_a_liquids: Dictionary = extractor_a.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_a_liquids, water_id, 0.075)

	var extractor_b_cell := Vector2i(20, 10)
	var extractor_b := Sprite2D.new()
	game.add_child(extractor_b)
	game.call("record_placed_block", extractor_b, blocks_by_id["oil-extractor"], extractor_b_cell)
	fracker_build_state.source_fracker_bind_frame_state(extractor_b, blocks_by_id["oil-extractor"])
	var extractor_b_frame: Dictionary = extractor_b.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var extractor_b_liquids: Dictionary = extractor_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_b_liquids, water_id, 0.3)

	extractor_a_frame["power_status"] = 1.0
	extractor_b_frame["power_status"] = 0.5
	fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)
	extractor_a_frame = extractor_a.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	extractor_b_frame = extractor_b.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	proof["live_tick_folds_liquid_row"] = is_equal_approx(float(extractor_a_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(extractor_b_frame.get("efficiency", -1.0)), 0.5)
	var extractor_a_water: float = float(liquid_module_state.source_get_state(extractor_a_liquids, water_id).get("amount", -1.0))
	var extractor_b_water: float = float(liquid_module_state.source_get_state(extractor_b_liquids, water_id).get("amount", -1.0))
	proof["live_tick_removes_liquid_when_running"] = is_equal_approx(extractor_a_water, 0.0) and is_equal_approx(extractor_b_water, 0.225)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07FrackerLiquidRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
