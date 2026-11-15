extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_cargo_loader_build_state := preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")
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
	# (the Fracker precedent): the pure row takes the
	# catalog id, the driver resolves it from
	# liquid_id_by_name with the def constant "nitrogen".
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var nitrogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("nitrogen", -1))
	var content_liquid_ids: Array = liquid_catalog["content_liquid_ids"]
	var amount: float = unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_LIQUID_AMOUNT

	# --- Pure liquid row (N2249): ConsumeLiquid.efficiency
	# (ConsumeLiquid.java:42-47, `float ed = build.edelta()
	# * build.efficiencyScale();` / `if(ed <= 0.00000001f)
	# return 0f;` / `return Math.min(build.liquids.get(
	# liquid) / (amount * ed * multiplier.get(build)),
	# 1f);`). In the first pass efficiency is assumed 1f
	# (BuildingComp.java:1964), so edelta() = delta() =
	# source_delta * time_scale; source_delta 1.0 is one
	# tick. The def amount is 10f/60f per frame, so one tick
	# at full efficiency needs 1/6 nitrogen.
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, nitrogen_id, 0.05)
	var starved_row: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_liquid_consumer_row_state({"liquids": starved_liquids}, true, nitrogen_id, amount, 1.0, 1.0)
	var scaled_row: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_liquid_consumer_row_state({"liquids": starved_liquids}, true, nitrogen_id, amount, 1.0, 1.0, 0.5)
	var doubled_row: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_liquid_consumer_row_state({"liquids": starved_liquids}, true, nitrogen_id, amount, 1.0, 1.0, 1.0, 2.0)
	proof["row_folds_below_one_when_starved"] = bool(starved_row.get("has_liquid_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.3) and bool(starved_row.get("row", {}).get("is_power", true)) == false and is_equal_approx(float(scaled_row.get("row", {}).get("result", -1.0)), 0.6) and is_equal_approx(float(doubled_row.get("row", {}).get("result", -1.0)), 0.15)

	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, nitrogen_id, 1.0)
	var full_row: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_liquid_consumer_row_state({"liquids": full_liquids}, true, nitrogen_id, amount, 1.0, 1.0)
	var exact_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(exact_liquids, nitrogen_id, 1.0 / 6.0)
	var exact_row: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_liquid_consumer_row_state({"liquids": exact_liquids}, true, nitrogen_id, amount, 1.0, 1.0)
	proof["row_caps_at_one_when_full"] = bool(full_row.get("has_liquid_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0) and is_equal_approx(float(exact_row.get("row", {}).get("result", -1.0)), 1.0) and is_equal_approx(float(amount), 10.0 / 60.0) and str(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_CONSUMED_LIQUID) == "nitrogen"

	var zero_delta_row: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_liquid_consumer_row_state({"liquids": full_liquids}, true, nitrogen_id, amount, 0.0, 1.0)
	var zero_scale_row: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_liquid_consumer_row_state({"liquids": full_liquids}, true, nitrogen_id, amount, 1.0, 0.0)
	var zero_efficiency_scale_row: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_liquid_consumer_row_state({"liquids": full_liquids}, true, nitrogen_id, amount, 1.0, 1.0, 0.0)
	proof["row_zeroes_when_edelta_zero"] = is_equal_approx(float(zero_delta_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(zero_scale_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(zero_efficiency_scale_row.get("row", {}).get("result", -1.0)), 0.0)

	var no_frame_row: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_liquid_consumer_row_state({}, true, nitrogen_id, amount, 1.0, 1.0)
	var no_store_row: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_liquid_consumer_row_state({"liquids": {}}, true, nitrogen_id, amount, 1.0, 1.0)
	var out_of_range_row: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_liquid_consumer_row_state({"liquids": full_liquids}, true, 99999, amount, 1.0, 1.0)
	var negative_id_row: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_liquid_consumer_row_state({"liquids": full_liquids}, true, -1, amount, 1.0, 1.0)
	var no_consumer_row: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_liquid_consumer_row_state({"liquids": full_liquids}, false, nitrogen_id, amount, 1.0, 1.0)
	proof["row_zeroes_without_liquid"] = is_equal_approx(float(no_frame_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(no_store_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(out_of_range_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(negative_id_row.get("row", {}).get("result", -1.0)), 0.0) and bool(no_consumer_row.get("has_liquid_row", true)) == false

	# --- Live tick: two unit-cargo-loaders placed live; the
	# tick driver is called directly (as the N2165/N2211/
	# N2234 proofs do), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status --
	# the write-back itself is already proven by N2142.
	# Loader A (starved nitrogen 0.05, full power) folds
	# efficiency 0.3 -- the liquid min below the power row
	# -- and keeps drawing power (0.3 > 1e-7); its first
	# tick also removes exactly the held 0.05 (amount *
	# folded edelta = 1/6 * 0.3), so the second tick folds
	# efficiency 0 and stops power draw. Loader B (full
	# nitrogen 1.0, full power) folds efficiency 1.0 and
	# removes 1/6 per tick: 1.0 -> 5/6 -> 4/6. The nitrogen
	# amounts are set on the sprite liquids meta store (the
	# live LiquidModule), which the driver syncs into the
	# frame each tick before the fold. The INVERTED gate
	# stays open throughout (no unit held, build far from
	# complete), so both loaders keep consuming.
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var loader_a_cell := Vector2i(28, 20)
	var loader_a := Sprite2D.new()
	game.add_child(loader_a)
	game.call("record_placed_block", loader_a, blocks_by_id["unit-cargo-loader"], loader_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	unit_cargo_loader_build_state.source_unit_cargo_loader_bind_frame_state(loader_a, blocks_by_id["unit-cargo-loader"])
	var loader_a_frame: Dictionary = loader_a.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	var loader_a_liquids: Dictionary = loader_a.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(loader_a_liquids, nitrogen_id, 0.05)

	var loader_b_cell := Vector2i(20, 10)
	var loader_b := Sprite2D.new()
	game.add_child(loader_b)
	game.call("record_placed_block", loader_b, blocks_by_id["unit-cargo-loader"], loader_b_cell)
	unit_cargo_loader_build_state.source_unit_cargo_loader_bind_frame_state(loader_b, blocks_by_id["unit-cargo-loader"])
	var loader_b_frame: Dictionary = loader_b.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	var loader_b_liquids: Dictionary = loader_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(loader_b_liquids, nitrogen_id, 1.0)

	loader_a_frame["power_status"] = 1.0
	loader_b_frame["power_status"] = 1.0
	unit_cargo_loader_build_state.source_unit_cargo_loader_tick_buildings_state(game, 1.0 / 60.0)
	loader_a_frame = loader_a.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	loader_b_frame = loader_b.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	loader_a_liquids = loader_a.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	loader_b_liquids = loader_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var tick1_fold_ok: bool = is_equal_approx(float(loader_a_frame.get("efficiency", -1.0)), 0.3) and bool(loader_a_frame.get("should_consume_power", false)) and is_equal_approx(float(loader_b_frame.get("efficiency", -1.0)), 1.0)
	var tick1_remove_ok: bool = is_equal_approx(float(liquid_module_state.source_get_state(loader_a_liquids, nitrogen_id).get("amount", -1.0)), 0.0) and is_equal_approx(float(liquid_module_state.source_get_state(loader_b_liquids, nitrogen_id).get("amount", -1.0)), 5.0 / 6.0)

	loader_a_frame["power_status"] = 1.0
	loader_b_frame["power_status"] = 1.0
	unit_cargo_loader_build_state.source_unit_cargo_loader_tick_buildings_state(game, 1.0 / 60.0)
	loader_a_frame = loader_a.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	loader_b_frame = loader_b.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	loader_b_liquids = loader_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var tick2_fold_ok: bool = is_equal_approx(float(loader_a_frame.get("efficiency", -1.0)), 0.0) and bool(loader_a_frame.get("should_consume_power", true)) == false and is_equal_approx(float(loader_b_frame.get("efficiency", -1.0)), 1.0)
	var tick2_remove_ok: bool = is_equal_approx(float(liquid_module_state.source_get_state(loader_b_liquids, nitrogen_id).get("amount", -1.0)), 4.0 / 6.0)
	proof["live_tick_folds_liquid_row"] = tick1_fold_ok and tick2_fold_ok
	proof["live_tick_removes_liquid_when_running"] = tick1_remove_ok and tick2_remove_ok

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitCargoLoaderLiquidRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
