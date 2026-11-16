extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shockwave_tower_build_state := preload("res://src/game/SourceShockwaveTowerBuildState.gd")
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
	# liquid_id_by_name with the def constant "cyanogen".
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var cyanogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("cyanogen", -1))
	var content_liquid_ids: Array = liquid_catalog["content_liquid_ids"]

	# --- Pure cyanogen row (N2331): ConsumeLiquids.
	# efficiency (ConsumeLiquids.java:52-60, `float ed =
	# build.edelta() * build.efficiencyScale();` with `if(ed
	# <= 0.00000001f) return 0f;`, `float min = 1f;`, `min =
	# Math.min(build.liquids.get(stack.liquid) /
	# (stack.amount * ed * mult), min);` and `return min;`)
	# folds into the same first-pass min as the power row
	# (BuildingComp.java:1969-1976). ConsumeLiquids extends
	# Consume DIRECTLY (ConsumeLiquids.java:11) -- it is NOT
	# a ConsumeLiquidBase -- and the shockwave-tower def
	# carries exactly ONE stack (`consumeLiquids(LiquidStack.
	# with(Liquids.cyanogen, 1.5f / 60f));`, Blocks.
	# java:2041), so the min loop collapses to min(cyanogen
	# / (0.025 * ed * mult), 1f). In the first pass
	# efficiency is assumed 1f (BuildingComp.java:1964-1965),
	# so edelta is delta() = Time.delta * timeScale
	# (BuildingComp.java:1922-1929) and ed = source_delta *
	# time_scale * efficiency_scale. The def sets no
	# multiplier, so the default `public Floatf<Building>
	# multiplier = b -> 1f;` (Consume.java:18) applies. The
	# literal 1.5 / 60.0 pins the def value independently of
	# the driver's constant, which is itself checked against
	# the literal.
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, cyanogen_id, 0.01)
	var starved_row: Dictionary = shockwave_tower_build_state.source_shockwave_tower_liquid_consumer_row_state({"liquids": starved_liquids}, true, cyanogen_id, 1.5 / 60.0, 1.0, 1.0, 1.0)
	proof["row_folds_cyanogen_amount"] = bool(starved_row.get("has_liquid_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.4) and bool(starved_row.get("row", {}).get("is_power", true)) == false and is_equal_approx(float(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_CYANOGEN_AMOUNT), 1.5 / 60.0) and str(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_CYANOGEN_LIQUID) == "cyanogen"

	# Zero cyanogen zeroes the row (0.0 / demand), and a
	# zero edelta zeroes it too (the ed <= 1e-8 guard,
	# ConsumeLiquids.java:55) even with cyanogen held.
	var empty_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	var zero_row: Dictionary = shockwave_tower_build_state.source_shockwave_tower_liquid_consumer_row_state({"liquids": empty_liquids}, true, cyanogen_id, 1.5 / 60.0, 1.0, 1.0, 1.0)
	var zero_edelta_row: Dictionary = shockwave_tower_build_state.source_shockwave_tower_liquid_consumer_row_state({"liquids": starved_liquids}, true, cyanogen_id, 1.5 / 60.0, 0.0, 1.0, 1.0)
	var no_consumer_row: Dictionary = shockwave_tower_build_state.source_shockwave_tower_liquid_consumer_row_state({"liquids": starved_liquids}, false, cyanogen_id, 1.5 / 60.0, 1.0, 1.0, 1.0)
	proof["row_zero_when_starved"] = bool(zero_row.get("has_liquid_row", false)) and is_equal_approx(float(zero_row.get("row", {}).get("result", -1.0)), 0.0) and is_equal_approx(float(zero_edelta_row.get("row", {}).get("result", -1.0)), 0.0) and bool(no_consumer_row.get("has_liquid_row", true)) == false

	# Full cyanogen caps at 1.0 (there can be more liquid
	# than necessary -- the min starts at 1f).
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, cyanogen_id, 10.0)
	var full_row: Dictionary = shockwave_tower_build_state.source_shockwave_tower_liquid_consumer_row_state({"liquids": full_liquids}, true, cyanogen_id, 1.5 / 60.0, 1.0, 1.0, 1.0)
	proof["row_full_when_satisfied"] = bool(full_row.get("has_liquid_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0)

	# --- Pure power row (N2177), unchanged: ConsumePower.
	# efficiency is the live power.status (ConsumePower.
	# java:38-40, `return build.power.status;`); the
	# cyanogen row does not touch it.
	var power_row: Dictionary = shockwave_tower_build_state.source_shockwave_tower_power_status_row_state({"power_status": 0.5}, true)
	proof["power_row_unchanged"] = bool(power_row.get("has_power_row", false)) and is_equal_approx(float(power_row.get("row", {}).get("result", -1.0)), 0.5) and bool(power_row.get("row", {}).get("is_power", false)) == true

	# --- Live tick: the shockwave tower is a ShockwaveTower
	# build with a power consumer (shockwave-tower,
	# consumePower 100f/60f, Blocks.java:2042) and a required
	# liquid consumer (cyanogen 1.5f/60f, Blocks.java:2041),
	# placed live; the tick driver is called directly (as the
	# N2187/N2247/N2318/N2327 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The cyanogen
	# amounts are set on the sprite liquids meta store (the
	# live LiquidModule), which the driver syncs into the
	# frame each tick -- PortGame never initializes that
	# store for a shockwave tower (its record_placed_block
	# only binds liquid consumers for blocks with a catalog
	# consumeLiquid property, and the catalog carries no
	# consumeLiquids property), so the proof initializes it
	# explicitly before seeding (the LiquidBridge tick
	# precedent); the driver lazily initializes it too.
	# The shouldConsume gate (ShockwaveTower.java:121-122,
	# `return reloadCounter < reload;`) stays open with the
	# counter below reload (80f) on every tick below.
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var tower_cell := Vector2i(28, 21)
	var tower := Sprite2D.new()
	game.add_child(tower)
	game.call("record_placed_block", tower, blocks_by_id["shockwave-tower"], tower_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(tower, blocks_by_id["shockwave-tower"])
	var tower_frame: Dictionary = tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	placed_block_state.source_initialize_building_liquids_state(tower, true, catalog)
	var tower_liquids: Dictionary = tower.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})

	# Full power, full cyanogen: the first pass folds the
	# min 1.0 (power 1.0, cyanogen row capped at 1.0), the
	# counter charges by edelta() = 1.0 * 1.0 tick, and the
	# second pass (BuildingComp.java:1999, `if(update &&
	# efficiency > 0){`) removes amount * edelta *
	# multiplier = 0.025 * 1.0 * 1.0 = 0.025
	# (ConsumeLiquids.java:47), leaving 10.0 - 0.025 in the
	# live store.
	liquid_module_state.source_set_state(tower_liquids, cyanogen_id, 10.0)
	tower_frame["reload_counter"] = 0.0
	tower_frame["power_status"] = 1.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	tower_frame = tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	tower_liquids = tower.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var full_tick_efficiency: float = float(tower_frame.get("efficiency", -1.0))
	var full_tick_counter: float = float(tower_frame.get("reload_counter", -1.0))
	proof["second_pass_removes_cyanogen"] = is_equal_approx(float(liquid_module_state.source_get_state(tower_liquids, cyanogen_id).get("amount", -1.0)), 10.0 - 0.025)

	# Half power, full cyanogen: the first pass folds the
	# min 0.5 (power 0.5, cyanogen row still capped at 1.0),
	# and the counter charges by edelta() = 0.5 * 1.0.
	tower_frame["power_status"] = 0.5
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	tower_frame = tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	var half_tick_efficiency: float = float(tower_frame.get("efficiency", -1.0))
	var half_tick_counter: float = float(tower_frame.get("reload_counter", -1.0))

	# Full power, starved cyanogen: the first pass folds the
	# min 0.0 (power 1.0, cyanogen row 0.0), so the counter
	# does not charge at all.
	liquid_module_state.source_set_state(tower_liquids, cyanogen_id, 0.0)
	tower_frame["power_status"] = 1.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	tower_frame = tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["live_tick_folds_liquid_row"] = is_equal_approx(full_tick_efficiency, 1.0) and is_equal_approx(full_tick_counter, 1.0) and is_equal_approx(half_tick_efficiency, 0.5) and is_equal_approx(half_tick_counter, 1.5) and is_equal_approx(float(tower_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(tower_frame.get("reload_counter", -1.0)), 1.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerCyanogenRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
