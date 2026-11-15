extends Node

const main_scene := preload("res://scenes/Main.tscn")
const fracker_build_state := preload("res://src/game/SourceFrackerBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
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

	# The liquid catalog resolves the oil id (the N2224
	# precedent: the advance proof needs it) and the water
	# id (the N2255 precedent: the live tick sets the water
	# store so the liquid row reads 1.0).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))
	var oil_id: int = int(liquid_catalog["liquid_id_by_name"].get("oil", -1))
	var content_liquid_ids: Array = liquid_catalog["content_liquid_ids"]

	# --- Pure item row (N2268): ConsumeItems.efficiency
	# (ConsumeItems.java:51-53, `return build.
	# consumeTriggerValid() || build.items.has(items,
	# multiplier.get(build)) ? 1f : 0f;`) is BINARY 1/0 --
	# 1 when the building is burning a trigger consumer or
	# its item module holds every stack, 0 otherwise.
	# consumeTriggerValid() is false at the base
	# (BuildingComp.java:764-766) and no Fracker build
	# overrides it, so the trigger term is always false
	# here. items.has (ItemModule.java:153-156) requires
	# EVERY stack to hold round(amount * multiplier). The
	# oil-extractor consumes one stack of sand 1
	# (`consumeItem(Items.sand);`, Blocks.java:2976;
	# consumeItem(item) returns consumeItem(item, 1),
	# Block.java:1167-1168), and the def sets no multiplier,
	# so the default 1f (Consume.java:18) applies. The
	# stacks arrive explicit from the driver (the catalog
	# consumeItem rows).

	# Binary: 1 sand reads 1.0, 5 sand also reads 1.0 (not
	# a ratio), with is_power false (so the shared fold
	# stops power draw when the row is <= 1e-7) -- and a
	# multiplier of 2.0 zeroes 1 sand (needs round(1 * 2)
	# = 2 held). A def with no item consumer contributes
	# no row.
	var sand_stacks: Array = [{"item": "sand", "amount": 1}]
	var one_sand_row: Dictionary = fracker_build_state.source_fracker_item_consumer_row_state({"items": {"sand": 1}}, true, sand_stacks)
	var five_sand_row: Dictionary = fracker_build_state.source_fracker_item_consumer_row_state({"items": {"sand": 5}}, true, sand_stacks)
	var doubled_row: Dictionary = fracker_build_state.source_fracker_item_consumer_row_state({"items": {"sand": 1}}, true, sand_stacks, 2.0)
	var no_consumer: Dictionary = fracker_build_state.source_fracker_item_consumer_row_state({"items": {"sand": 1}}, false, sand_stacks)
	proof["item_row_binary_sand"] = bool(one_sand_row.get("has_item_row", false)) and is_equal_approx(float(one_sand_row.get("row", {}).get("result", -1.0)), 1.0) and is_equal_approx(float(five_sand_row.get("row", {}).get("result", -1.0)), 1.0) and bool(one_sand_row.get("row", {}).get("is_power", true)) == false and is_equal_approx(float(doubled_row.get("row", {}).get("result", -1.0)), 0.0) and bool(no_consumer.get("has_item_row", true)) == false and str(fracker_build_state.SOURCE_FRACKER_CONSUME_ITEM) == "sand"

	# No sand zeroes the row: an empty store, a frame with
	# no items key at all, and a zero count all read 0.0 --
	# the shared inventory helper reads 0 for an item never
	# added, the same outcome as Java's id-out-of-range
	# branch (ItemModule.java:155).
	var empty_row: Dictionary = fracker_build_state.source_fracker_item_consumer_row_state({"items": {}}, true, sand_stacks)
	var no_store_row: Dictionary = fracker_build_state.source_fracker_item_consumer_row_state({}, true, sand_stacks)
	var zero_row: Dictionary = fracker_build_state.source_fracker_item_consumer_row_state({"items": {"sand": 0}}, true, sand_stacks)
	proof["item_row_zero_no_sand"] = is_equal_approx(float(empty_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(no_store_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(zero_row.get("row", {}).get("result", -1.0)), 0.0)

	# The row folds the REQUIRED min: the real row outputs
	# go into the shared non-optional pass (BuildingComp.
	# java:1969-1976) -- full power + a starved sand row
	# folds 0.0, half power + a fed sand row folds 0.5 on
	# the power row -- and the starved row stops power draw
	# (shouldConsumePower false, BuildingComp.java:1972-1973).
	var starved_fold: Dictionary = efficiency_state.update_consumption_non_optional_pass_state([{"result": 1.0, "is_power": true}, empty_row.get("row", {})])
	var fed_fold: Dictionary = efficiency_state.update_consumption_non_optional_pass_state([{"result": 0.5, "is_power": true}, one_sand_row.get("row", {})])
	proof["item_row_folds_required_min"] = is_equal_approx(float(starved_fold.get("min_efficiency", -1.0)), 0.0) and is_equal_approx(float(fed_fold.get("min_efficiency", -1.0)), 0.5) and bool(starved_fold.get("should_consume_power", true)) == false and bool(fed_fold.get("should_consume_power", false)) == true

	# --- The N2224 advance is untouched: consume() at
	# itemUseTime (Fracker.java:32-35) still removes one
	# sand (3 -> 2) and subtracts 60, then advances by
	# delta() * efficiency (1.0 * 1.0), landing at 1.0 --
	# the N2224 consume_at_item_use_time numbers, re-pinned
	# here so a row slice that broke the advance fails this
	# key. This slice adds NO removal of its own.
	var consume_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	var consumed: Dictionary = fracker_build_state.source_fracker_update_tile_advance_state({"efficiency": 1.0, "accumulator": 60.0, "warmup": 0.0, "pump_time": 0.0, "liquids": consume_liquids, "items": {"sand": 3}}, 1.0, 1.0, oil_id, 40.0, 0.25, 60.0)
	var consumed_items: Dictionary = consumed.get("items", {})
	proof["advance_removal_unchanged"] = int(consumed_items.get("sand", -1)) == 2 and is_equal_approx(float(consumed.get("accumulator", -1.0)), 1.0)

	# --- Live tick: two oil-extractors placed live; the tick
	# driver is called directly (as the N2153/N2207/N2255
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142.
	# Extractor A (2 sand, 10 water, full power) folds
	# efficiency 1.0 and keeps drawing power; extractor B
	# (no sand, 10 water, full power) folds 0.0 on the sand
	# row and stops drawing power (should_consume_power
	# false). The water store is set high so the liquid row
	# reads 1.0 for both; the sand is set on the frame items
	# dict (the tick preserves it -- no live intake fills it
	# yet). One tick call ticks both extractors; both live
	# keys read after that single call.
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var extractor_a_cell := Vector2i(28, 20)
	var extractor_a := Sprite2D.new()
	game.add_child(extractor_a)
	game.call("record_placed_block", extractor_a, blocks_by_id["oil-extractor"], extractor_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# items on it).
	fracker_build_state.source_fracker_bind_frame_state(extractor_a, blocks_by_id["oil-extractor"])
	var extractor_a_frame: Dictionary = extractor_a.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var extractor_a_liquids: Dictionary = extractor_a.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_a_liquids, water_id, 10.0)
	extractor_a_frame["items"] = {"sand": 2}

	var extractor_b_cell := Vector2i(20, 10)
	var extractor_b := Sprite2D.new()
	game.add_child(extractor_b)
	game.call("record_placed_block", extractor_b, blocks_by_id["oil-extractor"], extractor_b_cell)
	fracker_build_state.source_fracker_bind_frame_state(extractor_b, blocks_by_id["oil-extractor"])
	var extractor_b_frame: Dictionary = extractor_b.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var extractor_b_liquids: Dictionary = extractor_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_b_liquids, water_id, 10.0)
	extractor_b_frame["items"] = {}

	extractor_a_frame["power_status"] = 1.0
	extractor_b_frame["power_status"] = 1.0
	fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)
	extractor_a_frame = extractor_a.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	extractor_b_frame = extractor_b.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	proof["live_tick_folds_sand_row"] = is_equal_approx(float(extractor_a_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(extractor_b_frame.get("efficiency", -1.0)), 0.0)
	proof["sand_row_blocks_power_when_starved"] = bool(extractor_a_frame.get("should_consume_power", false)) == true and bool(extractor_b_frame.get("should_consume_power", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07FrackerItemRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
