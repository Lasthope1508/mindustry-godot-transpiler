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

	# --- Pure power row (N2177): ConsumePower.efficiency is
	# build.power.status (ConsumePower.java:39, `return build.
	# power.status;`), folded by the first pass
	# (BuildingComp.java:1969-1976) into the min efficiency; a
	# missing stamp folds to 1.0 before the first graph update,
	# the assembler fold (UnitAssembler.java:469, `float
	# powerStatus = !enabled ? 0f : power == null ? 1f :
	# power.status;`).
	var half_row: Dictionary = shockwave_tower_build_state.source_shockwave_tower_power_status_row_state({"power_status": 0.5}, true)
	proof["power_row_half"] = bool(half_row.get("has_power_row", false)) and is_equal_approx(float(half_row.get("row", {}).get("result", -1.0)), 0.5) and bool(half_row.get("row", {}).get("is_power", false))

	var no_consumer: Dictionary = shockwave_tower_build_state.source_shockwave_tower_power_status_row_state({"power_status": 0.5}, false)
	proof["power_row_absent_without_consumer"] = bool(no_consumer.get("has_power_row", true)) == false

	var null_row: Dictionary = shockwave_tower_build_state.source_shockwave_tower_power_status_row_state({}, true)
	proof["power_row_null_folds_one"] = bool(null_row.get("has_power_row", false)) and is_equal_approx(float(null_row.get("row", {}).get("result", -1.0)), 1.0) and bool(null_row.get("row", {}).get("is_power", false))

	# --- Live tick: the shockwave tower is a ShockwaveTower build
	# with a static power consumer (shockwave-tower,
	# consumePower 100f / 60f, Blocks.java:2042), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/
	# N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2170/N2171/
	# N2172/N2173/N2174/N2175/N2176 proofs do), not simulate_factory,
	# so the graph update does not overwrite the stamped
	# power_status -- the write-back itself is already proven
	# by N2142. The first pass also folds the required
	# cyanogen row since N2331 (ConsumeLiquids 1.5f / 60f,
	# Blocks.java:2041), so the tower is seeded with 1.0
	# cyanogen on the sprite liquids meta before the first
	# tick (the N2331 pattern, N2341 fix): PortGame never
	# binds that store for a shockwave tower (the catalog
	# carries no consumeLiquids property), so the proof
	# initializes it explicitly and the driver syncs it into
	# the frame each tick. Two ticks at eff 0.5 / 0.0 remove
	# 0.025 * 0.5 + 0 = 0.0125 cyanogen in total, so the
	# 1.0 seed is an 80x margin and the row stays capped at
	# 1.0 (it needs >= 0.025 at each first pass) -- the min
	# stays the stamped power.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var cyanogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("cyanogen", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["shockwave_tower_has_power_consumer"] = bool(blocks_by_id["shockwave-tower"].properties.get("hasPower", false)) and bool(blocks_by_id["shockwave-tower"].properties.get("consumesPower", false)) and is_equal_approx(float(blocks_by_id["shockwave-tower"].properties.get("consumePower", -1.0)), 100.0 / 60.0)

	var shockwave_tower_cell := Vector2i(28, 21)
	var shockwave_tower := Sprite2D.new()
	game.add_child(shockwave_tower)
	game.call("record_placed_block", shockwave_tower, blocks_by_id["shockwave-tower"], shockwave_tower_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(shockwave_tower, blocks_by_id["shockwave-tower"])
	var shockwave_tower_frame: Dictionary = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	# Seed cyanogen 1.0 on the sprite liquids meta (the
	# N2331 pattern, N2341 fix): the store is initialized
	# explicitly first -- PortGame never binds it for a
	# shockwave tower -- and the driver syncs this same
	# reference into the frame each tick, so the live liquid
	# row folds 1.0 and the min stays the stamped power.
	placed_block_state.source_initialize_building_liquids_state(shockwave_tower, true, catalog)
	var shockwave_tower_liquids: Dictionary = shockwave_tower.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(shockwave_tower_liquids, cyanogen_id, 1.0)

	# Half power: efficiency folds the power min 0.5.
	shockwave_tower_frame["power_status"] = 0.5
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_min"] = is_equal_approx(float(shockwave_tower_frame.get("efficiency", -1.0)), 0.5)

	# No power: efficiency 0.
	shockwave_tower_frame["power_status"] = 0.0
	shockwave_tower_build_state.source_shockwave_tower_tick_buildings_state(game, 1.0 / 60.0)
	shockwave_tower_frame = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	proof["efficiency_zero_at_no_power"] = is_equal_approx(float(shockwave_tower_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerPowerStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
