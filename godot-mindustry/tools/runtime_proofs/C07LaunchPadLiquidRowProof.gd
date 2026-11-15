extends Node

const main_scene := preload("res://scenes/Main.tscn")
const launch_pad_build_state := preload("res://src/game/SourceLaunchPadBuildState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
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

	# --- Catalog: ONLY advanced-launch-pad has the oil row
	# (consumeLiquid oil 9f/60f, Blocks.java:6808); the plain
	# launch-pad has no liquid consumer (Blocks.java:6790-6797).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var oil_id: int = int(liquid_id_by_name.get("oil", -1))
	var advanced_rows: Array = blocks_by_id["advanced-launch-pad"].properties.get("consumeLiquid", [])
	proof["advanced_pad_has_oil_consumer"] = oil_id >= 0 and advanced_rows.size() == 1 and str(advanced_rows[0].get("liquid", "")) == "oil" and is_equal_approx(float(advanced_rows[0].get("amount", -1.0)), 0.15) and not blocks_by_id["launch-pad"].properties.has("consumeLiquid")

	# --- Pure liquid row (N2253): ConsumeLiquid.efficiency
	# (ConsumeLiquid.java:42-47): ed = edelta *
	# efficiencyScale; ed <= 1e-8 zeroes it; else min(held /
	# (amount * ed * multiplier), 1f). In the first pass
	# efficiency is assumed 1f (BuildingComp.java:1964-1965),
	# so edelta = source_delta * time_scale. Amount 0.15 =
	# 9f/60f per frame; source_delta 1.0 = one tick.
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog.get("content_liquid_ids", []))
	starved_liquids["liquids"][oil_id] = 0.075
	var starved_row: Dictionary = launch_pad_build_state.source_launch_pad_liquid_consumer_row_state({"liquids": starved_liquids}, true, oil_id, 0.15, 1.0, 1.0, 1.0, 1.0)
	proof["row_folds_below_one_when_starved"] = bool(starved_row.get("has_liquid_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.5) and bool(starved_row.get("row", {}).get("is_power", true)) == false

	var full_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog.get("content_liquid_ids", []))
	full_liquids["liquids"][oil_id] = 40.0
	var full_row: Dictionary = launch_pad_build_state.source_launch_pad_liquid_consumer_row_state({"liquids": full_liquids}, true, oil_id, 0.15, 1.0, 1.0, 1.0, 1.0)
	proof["row_caps_at_one_when_full"] = bool(full_row.get("has_liquid_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0) and bool(full_row.get("row", {}).get("is_power", true)) == false

	var zero_edelta_row: Dictionary = launch_pad_build_state.source_launch_pad_liquid_consumer_row_state({"liquids": full_liquids}, true, oil_id, 0.15, 0.0, 1.0, 1.0, 1.0)
	proof["row_zeroes_when_edelta_zero"] = bool(zero_edelta_row.get("has_liquid_row", false)) and is_equal_approx(float(zero_edelta_row.get("row", {}).get("result", -1.0)), 0.0)

	var no_liquid_row: Dictionary = launch_pad_build_state.source_launch_pad_liquid_consumer_row_state({}, true, oil_id, 0.15, 1.0, 1.0, 1.0, 1.0)
	proof["row_zeroes_without_liquid"] = bool(no_liquid_row.get("has_liquid_row", false)) and is_equal_approx(float(no_liquid_row.get("row", {}).get("result", -1.0)), 0.0)

	var absent_row: Dictionary = launch_pad_build_state.source_launch_pad_liquid_consumer_row_state({"liquids": full_liquids}, false, oil_id, 0.15, 1.0, 1.0, 1.0, 1.0)
	proof["row_absent_for_plain_launch_pad"] = bool(absent_row.get("has_liquid_row", true)) == false

	# --- Live tick: an advanced-launch-pad is a LaunchPad build
	# with a power consumer (consumePower 8f) and the oil row,
	# placed live; the tick driver is called directly (as the
	# N2147/N2148/N2149/N2150/N2153/N2154/N2155/N2156/N2157/
	# N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/
	# N2167/N2168/N2169/N2170/N2171/N2172 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. record_placed_block binds the
	# consumeLiquid row and initializes the liquids store for
	# the advanced def (PortGame.gd); the proof falls back to
	# building the store itself if the meta is somehow absent.
	var launch_pad_cell := Vector2i(28, 21)
	var launch_pad := Sprite2D.new()
	game.add_child(launch_pad)
	game.call("record_placed_block", launch_pad, blocks_by_id["advanced-launch-pad"], launch_pad_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	launch_pad_build_state.source_launch_pad_bind_frame_state(launch_pad, blocks_by_id["advanced-launch-pad"])
	var launch_pad_frame: Dictionary = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	var liquids_store: Dictionary = launch_pad.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	if liquids_store.is_empty():
		liquids_store = liquid_module_state.source_initial_state(liquid_catalog.get("content_liquid_ids", []))
		launch_pad.set_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, liquids_store)

	# Starved oil (0.075 held, 0.15 required per tick) with full
	# power: efficiency folds the liquid min 0.5.
	liquids_store["liquids"][oil_id] = 0.075
	launch_pad_frame["power_status"] = 1.0
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	launch_pad_frame = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	proof["live_tick_folds_liquid_row"] = is_equal_approx(float(launch_pad_frame.get("efficiency", -1.0)), 0.5)

	# Full oil (10.0 held) with full power: efficiency folds 1.0
	# and the second pass removes amount * edelta * multiplier
	# = 0.15 * 1.0 * 1.0 = 0.15, leaving 9.85.
	liquids_store = launch_pad.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquids_store["liquids"][oil_id] = 10.0
	launch_pad_frame["power_status"] = 1.0
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	liquids_store = launch_pad.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	proof["live_tick_removes_liquid_when_running"] = is_equal_approx(float(liquids_store["liquids"][oil_id]), 9.85)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadLiquidRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
