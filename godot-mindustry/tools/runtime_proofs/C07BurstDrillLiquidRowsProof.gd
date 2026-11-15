extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
const drill_build_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# --- Pure liquid row (N2257): ConsumeLiquid.efficiency
	# (ConsumeLiquid.java:42-47, `float ed = build.edelta() *
	# build.efficiencyScale();` / `if(ed <= 0.00000001f) return
	# 0f;` / `return Math.min(build.liquids.get(liquid) /
	# (amount * ed * multiplier.get(build)), 1f);`), folded by
	# the first pass (BuildingComp.java:1969-1976) into the min
	# efficiency when required, or by the optional pass
	# (BuildingComp.java:1980-1981) when a booster row; the
	# optional efficiency is capped by the min
	# (BuildingComp.java:1986). In the first pass efficiency is
	# assumed 1f (BuildingComp.java:1965), so edelta is delta()
	# = source_delta * time_scale. One pure function serves
	# both row kinds -- the required/booster split is routing
	# (Block.java:1446-1447 selects on `optional`), not
	# formula. The amounts are per def (Blocks.java:3089-3090/
	# 3119-3120): impact-drill water 10f/60f REQUIRED + ozone
	# 3f/60f booster, eruption-drill hydrogen 4f/60f REQUIRED +
	# cyanogen 0.75f/60f booster.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var water_id: int = int(liquid_id_by_name.get("water", -1))
	var ozone_id: int = int(liquid_id_by_name.get("ozone", -1))
	var hydrogen_id: int = int(liquid_id_by_name.get("hydrogen", -1))
	var cyanogen_id: int = int(liquid_id_by_name.get("cyanogen", -1))
	var content_liquid_ids: Array = liquid_catalog.get("content_liquid_ids", [])
	var water_amount: float = 10.0 / 60.0
	var ozone_amount: float = 3.0 / 60.0
	var hydrogen_amount: float = 4.0 / 60.0
	var cyanogen_amount: float = 0.75 / 60.0

	# Required row starved: half the per-frame water demand ->
	# row 0.5, non-power (folds the min).
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, water_id, 0.5 * water_amount)
	var required_row: Dictionary = burst_drill_build_state.source_burst_drill_liquid_consumer_row_state({"liquids": starved_liquids}, true, water_id, water_amount, 1.0, 1.0, 1.0)
	proof["required_row_folds_min_when_starved"] = bool(required_row.get("has_liquid_row", false)) and is_equal_approx(float(required_row.get("row", {}).get("result", -1.0)), 0.5) and not bool(required_row.get("row", {}).get("is_power", true))

	# Booster row starved: half the per-frame ozone demand ->
	# row 0.5, non-power (folds the optional pass).
	var booster_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(booster_liquids, ozone_id, 0.5 * ozone_amount)
	var booster_row: Dictionary = burst_drill_build_state.source_burst_drill_liquid_consumer_row_state({"liquids": booster_liquids}, true, ozone_id, ozone_amount, 1.0, 1.0, 1.0)
	proof["booster_row_folds_optional_when_starved"] = bool(booster_row.get("has_liquid_row", false)) and is_equal_approx(float(booster_row.get("row", {}).get("result", -1.0)), 0.5) and not bool(booster_row.get("row", {}).get("is_power", true))

	# Full: plenty of hydrogen -> row caps at 1.
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, hydrogen_id, 10.0)
	var full_row: Dictionary = burst_drill_build_state.source_burst_drill_liquid_consumer_row_state({"liquids": full_liquids}, true, hydrogen_id, hydrogen_amount, 1.0, 1.0, 1.0)
	proof["row_caps_at_one_when_full"] = bool(full_row.get("has_liquid_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0) and not bool(full_row.get("row", {}).get("is_power", true))

	# --- Live tick: the burst drills are BurstDrill builds with
	# a power consumer plus a required liquid consumer and a
	# booster liquid consumer, placed live on copper ore; the
	# tick driver is called directly (as the N2147/N2148/N2149
	# proofs do), not simulate_factory, so the graph update does
	# not overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The liquid amounts are
	# set on the sprite liquids meta store (the live
	# LiquidModule), which the driver syncs into the frame each
	# tick before the fold (the Fracker proof precedent).
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")

	# Impact-drill 1: half the per-frame water and half the
	# per-frame ozone, full power: efficiency folds the
	# required min 0.5 and the optional efficiency folds the
	# booster 0.5. The second pass then removes amount *
	# folded edelta from both stores, which is exactly the held
	# liquid, so both stores empty -- the fold keys read
	# efficiency before that matters.
	var impact_cell := Vector2i(28, 20)
	var impact := Sprite2D.new()
	game.add_child(impact)
	for occupied in game.call("occupied_cells", impact_cell, blocks_by_id["impact-drill"]):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("ore-copper"), false)
	game.call("record_placed_block", impact, blocks_by_id["impact-drill"], impact_cell)
	drill_build_state.source_on_proximity_update_state(game, impact, blocks_by_id["impact-drill"])
	var impact_frame: Dictionary = impact.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	var impact_liquids: Dictionary = impact.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(impact_liquids, water_id, 0.5 * water_amount)
	liquid_module_state.source_set_state(impact_liquids, ozone_id, 0.5 * ozone_amount)
	impact_frame["power_status"] = 1.0
	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	impact_frame = impact.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	proof["live_tick_folds_both_rows"] = is_equal_approx(float(impact_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(impact_frame.get("optional_efficiency", -1.0)), 0.5)

	# Impact-drill 2: water and ozone full, half power: the
	# optional efficiency is capped by the min efficiency
	# (BuildingComp.java:1986), so it reads 0.5 even though the
	# booster row itself folds 1.0.
	var capped_cell := Vector2i(20, 10)
	var capped := Sprite2D.new()
	game.add_child(capped)
	for occupied in game.call("occupied_cells", capped_cell, blocks_by_id["impact-drill"]):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("ore-copper"), false)
	game.call("record_placed_block", capped, blocks_by_id["impact-drill"], capped_cell)
	drill_build_state.source_on_proximity_update_state(game, capped, blocks_by_id["impact-drill"])
	var capped_frame: Dictionary = capped.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	var capped_liquids: Dictionary = capped.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(capped_liquids, water_id, 1.0)
	liquid_module_state.source_set_state(capped_liquids, ozone_id, 1.0)
	capped_frame["power_status"] = 0.5
	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	capped_frame = capped.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	proof["optional_capped_by_min_efficiency"] = is_equal_approx(float(capped_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(capped_frame.get("optional_efficiency", -1.0)), 0.5)

	# Eruption-drill 3: hydrogen and cyanogen full at full
	# power: efficiency 1, so the second pass removes exactly
	# one frame's demand of each liquid (4/60 hydrogen,
	# 0.75/60 cyanogen) from the held 1.0 of each.
	var remover_cell := Vector2i(10, 28)
	var remover := Sprite2D.new()
	game.add_child(remover)
	for occupied in game.call("occupied_cells", remover_cell, blocks_by_id["eruption-drill"]):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("ore-copper"), false)
	game.call("record_placed_block", remover, blocks_by_id["eruption-drill"], remover_cell)
	drill_build_state.source_on_proximity_update_state(game, remover, blocks_by_id["eruption-drill"])
	var remover_frame: Dictionary = remover.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	var remover_liquids: Dictionary = remover.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(remover_liquids, hydrogen_id, 1.0)
	liquid_module_state.source_set_state(remover_liquids, cyanogen_id, 1.0)
	remover_frame["power_status"] = 1.0
	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	remover_liquids = remover.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	proof["live_tick_removes_liquid_when_running"] = is_equal_approx(float(liquid_module_state.source_get_state(remover_liquids, hydrogen_id).get("amount", -1.0)), 1.0 - hydrogen_amount) and is_equal_approx(float(liquid_module_state.source_get_state(remover_liquids, cyanogen_id).get("amount", -1.0)), 1.0 - cyanogen_amount)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillLiquidRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
