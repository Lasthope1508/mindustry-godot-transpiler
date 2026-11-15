extends Node

const main_scene := preload("res://scenes/Main.tscn")
const impact_reactor_build_state := preload("res://src/game/SourceImpactReactorBuildState.gd")
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
	# liquid_id_by_name with the def constant "cryofluid".
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var cryofluid_id: int = int(liquid_catalog["liquid_id_by_name"].get("cryofluid", -1))
	var content_liquid_ids: Array = liquid_catalog["content_liquid_ids"]

	# --- Pure liquid row (N2254): ConsumeLiquid.efficiency
	# (ConsumeLiquid.java:42-47, `float ed = build.edelta()
	# * build.efficiencyScale();` with `if(ed <=
	# 0.00000001f) return 0f;` and `return Math.min(build.
	# liquids.get(liquid) / (amount * ed * multiplier.
	# get(build)), 1f);`) folds into the same first-pass min
	# as the power row (BuildingComp.java:1969-1976). In the
	# first pass efficiency is assumed 1f
	# (BuildingComp.java:1964-1965), so edelta is delta() =
	# Time.delta * timeScale (BuildingComp.java:1922-1929)
	# and ed = source_delta * time_scale * efficiency_scale.
	# The single def consumes cryofluid 0.25f PER FRAME
	# (= 15/s), `consumeLiquid(Liquids.cryofluid, 0.25f);`
	# (Blocks.java:2644); the def sets no multiplier, so
	# the default `public Floatf<Building> multiplier = b ->
	# 1f;` (Consume.java:18) applies. The literal 0.25 pins
	# the def value independently of the driver's constant,
	# which is itself checked against the literal.
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, cryofluid_id, 0.1)
	var starved_row: Dictionary = impact_reactor_build_state.source_impact_reactor_liquid_consumer_row_state({"liquids": starved_liquids}, true, cryofluid_id, 0.25, 1.0, 1.0, 1.0)
	proof["row_folds_below_one_when_starved"] = bool(starved_row.get("has_liquid_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.4) and bool(starved_row.get("row", {}).get("is_power", true)) == false and is_equal_approx(float(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_LIQUID_AMOUNT), 0.25) and str(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_LIQUID) == "cryofluid"

	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, cryofluid_id, 10.0)
	var full_row: Dictionary = impact_reactor_build_state.source_impact_reactor_liquid_consumer_row_state({"liquids": full_liquids}, true, cryofluid_id, 0.25, 1.0, 1.0, 1.0)
	proof["row_caps_at_one_when_full"] = bool(full_row.get("has_liquid_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0) and bool(full_row.get("row", {}).get("is_power", true)) == false

	var zero_ed_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(zero_ed_liquids, cryofluid_id, 10.0)
	var zero_ed_row: Dictionary = impact_reactor_build_state.source_impact_reactor_liquid_consumer_row_state({"liquids": zero_ed_liquids}, true, cryofluid_id, 0.25, 0.0, 1.0, 1.0)
	proof["row_zeroes_when_edelta_zero"] = bool(zero_ed_row.get("has_liquid_row", false)) and is_equal_approx(float(zero_ed_row.get("row", {}).get("result", -1.0)), 0.0)

	var empty_row: Dictionary = impact_reactor_build_state.source_impact_reactor_liquid_consumer_row_state({}, true, cryofluid_id, 0.25, 1.0, 1.0, 1.0)
	proof["row_zeroes_without_liquid"] = bool(empty_row.get("has_liquid_row", false)) and is_equal_approx(float(empty_row.get("row", {}).get("result", -1.0)), 0.0)

	# --- Live tick: the impact reactor is an ImpactReactor
	# build with a static power consumer (impact-reactor,
	# consumePower 25f, Blocks.java:2642) and a required
	# liquid consumer (cryofluid 0.25f per frame,
	# Blocks.java:2644), placed live; the tick driver is
	# called directly (as the N2182/N2192 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The cryofluid
	# amounts are set on the sprite liquids meta store (the
	# live LiquidModule), which the driver syncs into the
	# frame each tick (the Fracker precedent).
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var impact_reactor_cell := Vector2i(30, 21)
	var impact_reactor := Sprite2D.new()
	game.add_child(impact_reactor)
	game.call("record_placed_block", impact_reactor, blocks_by_id["impact-reactor"], impact_reactor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	impact_reactor_build_state.source_impact_reactor_bind_frame_state(impact_reactor, blocks_by_id["impact-reactor"])
	var impact_reactor_frame: Dictionary = impact_reactor.get_meta(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, {})
	var impact_reactor_liquids: Dictionary = impact_reactor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})

	# Starved: 0.1 cryofluid against 0.25/frame at edelta 1
	# folds the liquid row 0.4 below the power row 1.0, so
	# the folded efficiency is 0.4. The same tick also
	# removes 0.25 * 0.4 = 0.1 through the second pass,
	# draining the store to 0 -- so the store is refilled
	# before the removal key below.
	# N2266: the required blast-compound row folds 0.0 on an
	# empty frame, so seed 1 blast-compound before ticking.
	# The timer needs 140 ticks to fire, so the single seed
	# survives both ticks below.
	impact_reactor_frame["items"] = {"blast-compound": 1}
	liquid_module_state.source_set_state(impact_reactor_liquids, cryofluid_id, 0.1)
	impact_reactor_frame["power_status"] = 1.0
	impact_reactor_build_state.source_impact_reactor_tick_buildings_state(game, 1.0 / 60.0)
	impact_reactor_frame = impact_reactor.get_meta(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, {})
	proof["live_tick_folds_liquid_row"] = is_equal_approx(float(impact_reactor_frame.get("efficiency", -1.0)), 0.4)

	# Running: 10.0 cryofluid folds the row to the 1.0 cap,
	# so efficiency is 1.0 and the second pass
	# (BuildingComp.java:1999, `if(update && efficiency >
	# 0){`) removes amount * edelta * multiplier = 0.25 *
	# 1.0 * 1.0 = 0.25 (ConsumeLiquid.java:38), leaving
	# 9.75 in the live store.
	liquid_module_state.source_set_state(impact_reactor_liquids, cryofluid_id, 10.0)
	impact_reactor_frame["power_status"] = 1.0
	impact_reactor_build_state.source_impact_reactor_tick_buildings_state(game, 1.0 / 60.0)
	impact_reactor_frame = impact_reactor.get_meta(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, {})
	impact_reactor_liquids = impact_reactor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	proof["live_tick_removes_liquid_when_running"] = is_equal_approx(float(impact_reactor_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(liquid_module_state.source_get_state(impact_reactor_liquids, cryofluid_id).get("amount", -1.0)), 9.75)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ImpactReactorLiquidRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
