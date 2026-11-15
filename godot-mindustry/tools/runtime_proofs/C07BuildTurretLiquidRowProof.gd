extends Node

const main_scene := preload("res://scenes/Main.tscn")
const build_turret_build_state := preload("res://src/game/SourceBuildTurretBuildState.gd")
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
	# (the Fracker precedent): the pure row takes the catalog
	# id, the driver resolves it from liquid_id_by_name with
	# the def constant "nitrogen".
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var nitrogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("nitrogen", -1))
	var content_liquid_ids: Array = liquid_catalog["content_liquid_ids"]

	# --- Pure liquid row (N2251): ConsumeLiquid.efficiency
	# (ConsumeLiquid.java:42-47, `float ed = build.edelta() *
	# build.efficiencyScale();` / `if(ed <= 0.00000001f)
	# return 0f;` / `return Math.min(build.liquids.get(liquid)
	# / (amount * ed * multiplier.get(build)), 1f);`). In the
	# first pass efficiency is assumed 1f
	# (BuildingComp.java:1964), so edelta is source_delta *
	# time_scale; the amount is 3f/60f per frame
	# (Blocks.java:2006), so at edelta 1 the tower needs 0.05
	# nitrogen per tick. The multiplier is the 1f default
	# (Consume.java:18) -- the def sets none.
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, nitrogen_id, 0.025)
	var starved_row: Dictionary = build_turret_build_state.source_build_turret_liquid_consumer_row_state({"liquids": starved_liquids}, true, nitrogen_id, 3.0 / 60.0, 1.0, 1.0, 1.0)
	proof["row_folds_below_one_when_starved"] = bool(starved_row.get("has_liquid_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.5) and bool(starved_row.get("row", {}).get("is_power", true)) == false and str(build_turret_build_state.SOURCE_BUILD_TURRET_LIQUID) == "nitrogen" and is_equal_approx(float(build_turret_build_state.SOURCE_BUILD_TURRET_LIQUID_AMOUNT), 3.0 / 60.0)

	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, nitrogen_id, 10.0)
	var full_row: Dictionary = build_turret_build_state.source_build_turret_liquid_consumer_row_state({"liquids": full_liquids}, true, nitrogen_id, build_turret_build_state.SOURCE_BUILD_TURRET_LIQUID_AMOUNT, 1.0, 1.0, 1.0)
	proof["row_caps_at_one_when_full"] = bool(full_row.get("has_liquid_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0) and bool(full_row.get("row", {}).get("is_power", true)) == false

	var zero_delta_row: Dictionary = build_turret_build_state.source_build_turret_liquid_consumer_row_state({"liquids": full_liquids}, true, nitrogen_id, build_turret_build_state.SOURCE_BUILD_TURRET_LIQUID_AMOUNT, 0.0, 1.0, 1.0)
	var zero_scale_row: Dictionary = build_turret_build_state.source_build_turret_liquid_consumer_row_state({"liquids": full_liquids}, true, nitrogen_id, build_turret_build_state.SOURCE_BUILD_TURRET_LIQUID_AMOUNT, 1.0, 1.0, 0.0)
	proof["row_zeroes_when_edelta_zero"] = is_equal_approx(float(zero_delta_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(zero_scale_row.get("row", {}).get("result", -1.0)), 0.0)

	var empty_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	var empty_row: Dictionary = build_turret_build_state.source_build_turret_liquid_consumer_row_state({"liquids": empty_liquids}, true, nitrogen_id, build_turret_build_state.SOURCE_BUILD_TURRET_LIQUID_AMOUNT, 1.0, 1.0, 1.0)
	var missing_store_row: Dictionary = build_turret_build_state.source_build_turret_liquid_consumer_row_state({}, true, nitrogen_id, build_turret_build_state.SOURCE_BUILD_TURRET_LIQUID_AMOUNT, 1.0, 1.0, 1.0)
	proof["row_zeroes_without_liquid"] = is_equal_approx(float(empty_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(missing_store_row.get("row", {}).get("result", -1.0)), 0.0)

	# --- Live tick: the build tower is a BuildTurret build
	# with a static power consumer (build-tower,
	# consumePower 3f, Blocks.java:2005) and a required
	# liquid consumer (consumeLiquid nitrogen 3f/60f,
	# Blocks.java:2006), placed live; the tick driver is
	# called directly (as the N2184 proof does), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The nitrogen
	# amounts are set on the sprite liquids meta store (the
	# live LiquidModule), which the driver syncs into the
	# frame each tick. N2215: the shouldConsume gate
	# (BuildTurret.java:230, `return unit.plans().size > 0 &&
	# !isHealSuppressed();`) closes with no plans, so the
	# proof holds a plans fixture (only its size is read).
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var build_turret_cell := Vector2i(30, 21)
	var build_turret := Sprite2D.new()
	game.add_child(build_turret)
	game.call("record_placed_block", build_turret, blocks_by_id["build-tower"], build_turret_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	build_turret_build_state.source_build_turret_bind_frame_state(build_turret, blocks_by_id["build-tower"])
	var build_turret_frame: Dictionary = build_turret.get_meta(build_turret_build_state.SOURCE_BUILD_TURRET_BUILDING_META_KEY, {})
	var build_turret_liquids: Dictionary = build_turret.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	build_turret_frame["plans"] = [{"block": "conveyor", "x": 0, "y": 0}]

	# Starved nitrogen (0.025 of the 0.05 needed at edelta 1)
	# with full power: efficiency folds the liquid min 0.5.
	# The tick also removes 0.05 * 0.5 = 0.025 nitrogen (the
	# second pass), leaving the store empty -- the next tick
	# refills it first.
	build_turret_frame["power_status"] = 1.0
	liquid_module_state.source_set_state(build_turret_liquids, nitrogen_id, 0.025)
	build_turret_build_state.source_build_turret_tick_buildings_state(game, 1.0 / 60.0)
	build_turret_frame = build_turret.get_meta(build_turret_build_state.SOURCE_BUILD_TURRET_BUILDING_META_KEY, {})
	proof["live_tick_folds_liquid_row"] = is_equal_approx(float(build_turret_frame.get("efficiency", -1.0)), 0.5)

	# Full nitrogen (10.0) with full power: efficiency folds
	# 1.0 and the second pass removes 0.05 * 1.0 = 0.05
	# nitrogen, leaving 9.95.
	liquid_module_state.source_set_state(build_turret_liquids, nitrogen_id, 10.0)
	build_turret_build_state.source_build_turret_tick_buildings_state(game, 1.0 / 60.0)
	build_turret_frame = build_turret.get_meta(build_turret_build_state.SOURCE_BUILD_TURRET_BUILDING_META_KEY, {})
	var nitrogen_after: float = float(liquid_module_state.source_get_state(build_turret_liquids, nitrogen_id).get("amount", -1.0))
	proof["live_tick_removes_liquid_when_running"] = is_equal_approx(float(build_turret_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(nitrogen_after, 9.95)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretLiquidRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
