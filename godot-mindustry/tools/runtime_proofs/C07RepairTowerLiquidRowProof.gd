extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_tower_build_state := preload("res://src/game/SourceRepairTowerBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")


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

	# --- Pure liquid row (N2250): ConsumeLiquid.efficiency
	# (ConsumeLiquid.java:42-47, `float ed = build.edelta() *
	# build.efficiencyScale();` / `if(ed <= 0.00000001f)
	# return 0f;` / `return Math.min(build.liquids.get(
	# liquid) / (amount * ed * multiplier.get(build)), 1f);`),
	# folded by the first pass (BuildingComp.java:1969-1976)
	# into the min efficiency beside the power row. In the
	# first pass efficiency is assumed 1f, so edelta is the
	# source delta times the time scale; the def amount is
	# 3f/60f = 0.05 ozone per frame (Blocks.java:6583,
	# `consumeLiquid(Liquids.ozone, 3f / 60f);`) and the
	# multiplier is the Consume default 1f (Consume.java:18).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var ozone_id: int = int(liquid_catalog["liquid_id_by_name"].get("ozone", -1))
	var content_liquid_ids: Array = liquid_catalog["content_liquid_ids"]
	var liquid_amount: float = repair_tower_build_state.SOURCE_REPAIR_TOWER_LIQUID_AMOUNT

	# Starved: 0.025 ozone against 0.05 per frame at edelta
	# 1.0 folds to 0.5, and the row is not power.
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, ozone_id, 0.025)
	var starved_row: Dictionary = repair_tower_build_state.source_repair_tower_liquid_consumer_row_state({"liquids": starved_liquids}, true, ozone_id, liquid_amount, 1.0, 1.0, 1.0, 1.0)
	proof["row_folds_below_one_when_starved"] = bool(starved_row.get("has_liquid_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.5) and bool(starved_row.get("row", {}).get("is_power", true)) == false

	# Full: 10.0 ozone caps at 1.0 (there can be more liquid
	# than necessary, ConsumeLiquid.java:45).
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, ozone_id, 10.0)
	var full_row: Dictionary = repair_tower_build_state.source_repair_tower_liquid_consumer_row_state({"liquids": full_liquids}, true, ozone_id, liquid_amount, 1.0, 1.0, 1.0, 1.0)
	proof["row_caps_at_one_when_full"] = bool(full_row.get("has_liquid_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0) and bool(full_row.get("row", {}).get("is_power", true)) == false

	# Zero edelta: ed <= 0.00000001f returns 0f even with a
	# full store.
	var zero_edelta_row: Dictionary = repair_tower_build_state.source_repair_tower_liquid_consumer_row_state({"liquids": full_liquids}, true, ozone_id, liquid_amount, 0.0, 1.0, 1.0, 1.0)
	proof["row_zeroes_when_edelta_zero"] = bool(zero_edelta_row.get("has_liquid_row", false)) and is_equal_approx(float(zero_edelta_row.get("row", {}).get("result", -1.0)), 0.0)

	# No liquid: an empty store (Java liquids.get returns
	# 0.0 for a liquid never added) folds to 0.0.
	var empty_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	var empty_row: Dictionary = repair_tower_build_state.source_repair_tower_liquid_consumer_row_state({"liquids": empty_liquids}, true, ozone_id, liquid_amount, 1.0, 1.0, 1.0, 1.0)
	proof["row_zeroes_without_liquid"] = bool(empty_row.get("has_liquid_row", false)) and is_equal_approx(float(empty_row.get("row", {}).get("result", -1.0)), 0.0)

	# --- Live tick: two repair towers placed live; the tick
	# driver is called directly (as the N2176 proof does),
	# not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. Tower A (starved
	# ozone 0.025, full power) folds efficiency 0.5 -- the
	# liquid row, not the power row, sets the min. Tower B
	# (ozone 0.1, full power) folds efficiency 1.0 and the
	# second pass removes amount * edelta * multiplier =
	# 0.05 * 1.0 * 1.0 = 0.05 ozone, leaving 0.05
	# (ConsumeLiquid.java:37-39, BuildingComp.java:1999-
	# 2003). The ozone amounts are set on the sprite liquids
	# meta store (the live LiquidModule), which the driver
	# syncs into the frame each tick.
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var tower_a_cell := Vector2i(28, 21)
	var tower_a := Sprite2D.new()
	game.add_child(tower_a)
	game.call("record_placed_block", tower_a, blocks_by_id["unit-repair-tower"], tower_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	repair_tower_build_state.source_repair_tower_bind_frame_state(tower_a, blocks_by_id["unit-repair-tower"])
	var tower_a_frame: Dictionary = tower_a.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	var tower_a_liquids: Dictionary = tower_a.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(tower_a_liquids, ozone_id, 0.025)

	var tower_b_cell := Vector2i(20, 10)
	var tower_b := Sprite2D.new()
	game.add_child(tower_b)
	game.call("record_placed_block", tower_b, blocks_by_id["unit-repair-tower"], tower_b_cell)
	repair_tower_build_state.source_repair_tower_bind_frame_state(tower_b, blocks_by_id["unit-repair-tower"])
	var tower_b_frame: Dictionary = tower_b.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	var tower_b_liquids: Dictionary = tower_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(tower_b_liquids, ozone_id, 0.1)

	# N2213: the shouldConsume gate (RepairTower.java:90,
	# `return targets.size > 0;`) closes with no targets, so
	# both towers hold a targets fixture (only its size is
	# read) -- otherwise efficiency would read 0.
	tower_a_frame["targets"] = [{"type": "dart"}]
	tower_b_frame["targets"] = [{"type": "dart"}]

	tower_a_frame["power_status"] = 1.0
	tower_b_frame["power_status"] = 1.0
	repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	tower_a_frame = tower_a.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	tower_b_frame = tower_b.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	proof["live_tick_folds_liquid_row"] = is_equal_approx(float(tower_a_frame.get("efficiency", -1.0)), 0.5)
	tower_b_liquids = tower_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	proof["live_tick_removes_liquid_when_running"] = is_equal_approx(float(tower_b_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(liquid_module_state.source_get_state(tower_b_liquids, ozone_id).get("amount", -1.0)), 0.05)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerLiquidRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
