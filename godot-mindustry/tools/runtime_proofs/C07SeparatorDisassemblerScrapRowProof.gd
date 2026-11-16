extends Node

const main_scene := preload("res://scenes/Main.tscn")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
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

	# The liquid catalog resolves the slag id (the N2252
	# precedent: the live tick sets the slag store so the
	# liquid row reads 1.0 for both disassemblers).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var slag_id: int = int(liquid_catalog["liquid_id_by_name"].get("slag", -1))

	# --- Pure item row (N2349): ConsumeItems.efficiency
	# (ConsumeItems.java:51-53, `return build.
	# consumeTriggerValid() || build.items.has(items,
	# multiplier.get(build)) ? 1f : 0f;`) is BINARY 1/0 --
	# 1 when the building is burning a trigger consumer or
	# its item module holds every stack, 0 otherwise.
	# consumeTriggerValid() is false at the base
	# (BuildingComp.java:764-766) and no Separator build
	# overrides it, so the trigger term is always false
	# here. items.has (ItemModule.java:153-156) requires
	# EVERY stack to hold round(amount * multiplier). The
	# disassembler consumes one stack of scrap 1
	# (`consumeItem(Items.scrap);`, Blocks.java:1263;
	# consumeItem(item) returns consumeItem(item, 1),
	# Block.java:1167-1168), and the def sets no multiplier,
	# so the default 1f (Consume.java:18) applies. The
	# stacks arrive explicit from the driver (the catalog
	# consumeItem rows); the separator def has no
	# consumeItem (Blocks.java:1231-1246), so it
	# contributes no row.

	# Binary: 1 scrap reads 1.0, 5 scrap also reads 1.0 (not
	# a ratio), with is_power false (so the shared fold
	# stops power draw when the row is <= 1e-7) -- and a
	# multiplier of 2.0 zeroes 1 scrap (needs round(1 * 2)
	# = 2 held). A def with no item consumer contributes
	# no row.
	var scrap_stacks: Array = [{"item": "scrap", "amount": 1}]
	var one_scrap_row: Dictionary = separator_build_state.source_separator_disassembler_scrap_row_state({"items": {"scrap": 1}}, true, scrap_stacks)
	var five_scrap_row: Dictionary = separator_build_state.source_separator_disassembler_scrap_row_state({"items": {"scrap": 5}}, true, scrap_stacks)
	var doubled_row: Dictionary = separator_build_state.source_separator_disassembler_scrap_row_state({"items": {"scrap": 1}}, true, scrap_stacks, 2.0)
	var no_consumer: Dictionary = separator_build_state.source_separator_disassembler_scrap_row_state({"items": {"scrap": 1}}, false, scrap_stacks)
	proof["item_row_binary_scrap"] = bool(one_scrap_row.get("has_item_row", false)) and is_equal_approx(float(one_scrap_row.get("row", {}).get("result", -1.0)), 1.0) and is_equal_approx(float(five_scrap_row.get("row", {}).get("result", -1.0)), 1.0) and bool(one_scrap_row.get("row", {}).get("is_power", true)) == false and is_equal_approx(float(doubled_row.get("row", {}).get("result", -1.0)), 0.0) and bool(no_consumer.get("has_item_row", true)) == false

	# No scrap zeroes the row: an empty store, a frame with
	# no items key at all, and a zero count all read 0.0 --
	# the shared inventory helper reads 0 for an item never
	# added, the same outcome as Java's id-out-of-range
	# branch (ItemModule.java:155).
	var empty_row: Dictionary = separator_build_state.source_separator_disassembler_scrap_row_state({"items": {}}, true, scrap_stacks)
	var no_store_row: Dictionary = separator_build_state.source_separator_disassembler_scrap_row_state({}, true, scrap_stacks)
	var zero_row: Dictionary = separator_build_state.source_separator_disassembler_scrap_row_state({"items": {"scrap": 0}}, true, scrap_stacks)
	proof["item_row_zero_no_scrap"] = is_equal_approx(float(empty_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(no_store_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(zero_row.get("row", {}).get("result", -1.0)), 0.0)

	# The row folds the REQUIRED min: the real row outputs
	# go into the shared non-optional pass (BuildingComp.
	# java:1969-1976) -- full power + a starved scrap row
	# folds 0.0, half power + a fed scrap row folds 0.5 on
	# the power row -- and the starved row stops power draw
	# (shouldConsumePower false, BuildingComp.java:1972-1973).
	var starved_fold: Dictionary = efficiency_state.update_consumption_non_optional_pass_state([{"result": 1.0, "is_power": true}, empty_row.get("row", {})])
	var fed_fold: Dictionary = efficiency_state.update_consumption_non_optional_pass_state([{"result": 0.5, "is_power": true}, one_scrap_row.get("row", {})])
	proof["item_row_folds_required_min"] = is_equal_approx(float(starved_fold.get("min_efficiency", -1.0)), 0.0) and is_equal_approx(float(fed_fold.get("min_efficiency", -1.0)), 0.5) and bool(starved_fold.get("should_consume_power", true)) == false and bool(fed_fold.get("should_consume_power", false)) == true

	# --- The N2222 advance is untouched: consume() at craft
	# completion (Separator.java:158) still removes one
	# scrap (3 -> 2) -- the N2222 disassembler numbers,
	# re-pinned here so a row slice that broke the advance
	# fails this key. This slice adds NO removal of its own.
	# progress 0.99 + (1/15) * 1.0 * 1.0 crosses 1.0, so the
	# craft completes; the picked result is not pinned (the
	# N2222 proof pins the exact pick).
	var disassembler_results: Array = [{"item": "sand", "amount": 2}, {"item": "graphite", "amount": 1}, {"item": "titanium", "amount": 1}, {"item": "thorium", "amount": 1}]
	var crafted: Dictionary = separator_build_state.source_separator_update_tile_advance_state({"efficiency": 1.0, "progress": 0.99, "warmup": 0.0, "total_progress": 0.0, "seed": 0, "items": {"scrap": 3}}, 1.0, 1.0, 15.0, disassembler_results, [{"item": "scrap", "amount": 1}], 20)
	var crafted_items: Dictionary = crafted.get("items", {})
	proof["advance_removal_unchanged"] = bool(crafted.get("crafted", false)) == true and int(crafted_items.get("scrap", -1)) == 2

	# --- Live tick: two disassemblers placed live; the tick
	# driver is called directly (as the N2252/N2281/N2343
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142.
	# Disassembler A (2 scrap, 1.0 slag, full power) folds
	# efficiency 1.0 and keeps drawing power; disassembler B
	# (no scrap, 1.0 slag, full power) folds 0.0 on the
	# scrap row and stops drawing power (should_consume_power
	# false). The slag store is set to 1.0 so the liquid row
	# reads 1.0 for both (demand 0.12 per frame, one tick of
	# edelta); the scrap is set on the frame items dict (the
	# tick preserves it -- no live intake fills it yet). One
	# tick call ticks both disassemblers; both live keys read
	# after that single call.
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var disassembler_a_cell := Vector2i(28, 20)
	var disassembler_a := Sprite2D.new()
	game.add_child(disassembler_a)
	game.call("record_placed_block", disassembler_a, blocks_by_id["disassembler"], disassembler_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# items on it).
	separator_build_state.source_separator_bind_frame_state(disassembler_a, blocks_by_id["disassembler"])
	var disassembler_a_frame: Dictionary = disassembler_a.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var disassembler_a_liquids: Dictionary = disassembler_a.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(disassembler_a_liquids, slag_id, 1.0)
	disassembler_a_frame["items"] = {"scrap": 2}

	var disassembler_b_cell := Vector2i(20, 10)
	var disassembler_b := Sprite2D.new()
	game.add_child(disassembler_b)
	game.call("record_placed_block", disassembler_b, blocks_by_id["disassembler"], disassembler_b_cell)
	separator_build_state.source_separator_bind_frame_state(disassembler_b, blocks_by_id["disassembler"])
	var disassembler_b_frame: Dictionary = disassembler_b.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var disassembler_b_liquids: Dictionary = disassembler_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(disassembler_b_liquids, slag_id, 1.0)
	disassembler_b_frame["items"] = {}

	disassembler_a_frame["power_status"] = 1.0
	disassembler_b_frame["power_status"] = 1.0
	separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)
	disassembler_a_frame = disassembler_a.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	disassembler_b_frame = disassembler_b.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	proof["live_tick_folds_scrap_row"] = is_equal_approx(float(disassembler_a_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(disassembler_b_frame.get("efficiency", -1.0)), 0.0)
	proof["scrap_row_blocks_power_when_starved"] = bool(disassembler_a_frame.get("should_consume_power", false)) == true and bool(disassembler_b_frame.get("should_consume_power", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SeparatorDisassemblerScrapRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
