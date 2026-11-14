extends Node

const main_scene := preload("res://scenes/Main.tscn")
const impact_reactor_build_state := preload("res://src/game/SourceImpactReactorBuildState.gd")
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

	# --- Pure power row (N2182): ConsumePower.efficiency is
	# build.power.status (ConsumePower.java:39, `return build.
	# power.status;`), folded by the first pass
	# (BuildingComp.java:1969-1976) into the min efficiency; a
	# missing stamp folds to 1.0 before the first graph update,
	# the assembler fold (UnitAssembler.java:469, `float
	# powerStatus = !enabled ? 0f : power == null ? 1f :
	# power.status;`). Consume-vs-produce care: the reactor is a
	# GENERATOR (`outputsPower = consumesPower = true;`,
	# ImpactReactor.java:28) with powerProduction 130f
	# (Blocks.java:2636) against a 25f draw -- the row folded
	# here is the CONSUMER-side read, exactly like every
	# pure-consumer slice; the PRODUCER side
	# (getPowerProduction, PowerGenerator.java:156-158) waits
	# for its own slice.
	var half_row: Dictionary = impact_reactor_build_state.source_impact_reactor_power_status_row_state({"power_status": 0.5}, true)
	proof["power_row_half"] = bool(half_row.get("has_power_row", false)) and is_equal_approx(float(half_row.get("row", {}).get("result", -1.0)), 0.5) and bool(half_row.get("row", {}).get("is_power", false))

	var no_consumer: Dictionary = impact_reactor_build_state.source_impact_reactor_power_status_row_state({"power_status": 0.5}, false)
	proof["power_row_absent_without_consumer"] = bool(no_consumer.get("has_power_row", true)) == false

	var null_row: Dictionary = impact_reactor_build_state.source_impact_reactor_power_status_row_state({}, true)
	proof["power_row_null_folds_one"] = bool(null_row.get("has_power_row", false)) and is_equal_approx(float(null_row.get("row", {}).get("result", -1.0)), 1.0) and bool(null_row.get("row", {}).get("is_power", false))

	# --- Live tick: the impact reactor is an ImpactReactor build
	# with a static power consumer (impact-reactor,
	# consumePower 25f, Blocks.java:2642), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/
	# N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2170/N2171/
	# N2172/N2173/N2174/N2175/N2176/N2177/N2178/N2179/N2180/N2181
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. The impact
	# reactor tick models no other consumers, so with a power
	# consumer the first pass holds only the power row.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["impact_reactor_has_power_consumer"] = bool(blocks_by_id["impact-reactor"].properties.get("hasPower", false)) and bool(blocks_by_id["impact-reactor"].properties.get("consumesPower", false)) and is_equal_approx(float(blocks_by_id["impact-reactor"].properties.get("consumePower", -1.0)), 25.0)

	var impact_reactor_cell := Vector2i(30, 21)
	var impact_reactor := Sprite2D.new()
	game.add_child(impact_reactor)
	game.call("record_placed_block", impact_reactor, blocks_by_id["impact-reactor"], impact_reactor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	impact_reactor_build_state.source_impact_reactor_bind_frame_state(impact_reactor, blocks_by_id["impact-reactor"])
	var impact_reactor_frame: Dictionary = impact_reactor.get_meta(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, {})

	# Half power: efficiency folds the power min 0.5.
	impact_reactor_frame["power_status"] = 0.5
	impact_reactor_build_state.source_impact_reactor_tick_buildings_state(game, 1.0 / 60.0)
	impact_reactor_frame = impact_reactor.get_meta(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_min"] = is_equal_approx(float(impact_reactor_frame.get("efficiency", -1.0)), 0.5)

	# No power: efficiency 0. This proves the folded efficiency
	# is 0; it carries no warmup / production claim -- the
	# warmup advance (ImpactReactor.java:79-100) waits for its
	# own slice. Unlike the router's base-efficiency soft
	# coupling, the warmup gate is HARD: at efficiency 0 the
	# warmup decays to 0 and production is 0, with no
	# baseEfficiency-style floor.
	impact_reactor_frame["power_status"] = 0.0
	impact_reactor_build_state.source_impact_reactor_tick_buildings_state(game, 1.0 / 60.0)
	impact_reactor_frame = impact_reactor.get_meta(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, {})
	proof["efficiency_zero_at_no_power"] = is_equal_approx(float(impact_reactor_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ImpactReactorPowerStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
