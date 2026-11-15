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
	# (the Fracker precedent): the live-tick keys keep the
	# cryofluid store full so the liquid row folds 1.0 and
	# only the item row / timer gate under test moves the
	# folded efficiency.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var cryofluid_id: int = int(liquid_catalog["liquid_id_by_name"].get("cryofluid", -1))

	# --- Pure item row (N2266): ConsumeItems.efficiency
	# (ConsumeItems.java:51-53, `return build.
	# consumeTriggerValid() || build.items.has(items,
	# multiplier.get(build)) ? 1f : 0f;`) is BINARY 1/0:
	# 1 when the building holds every stack, 0 otherwise.
	# consumeTriggerValid() is false at the base
	# (BuildingComp.java:764-766) and no ImpactReactor
	# override exists, so the row turns on the held stacks
	# alone. The single def consumes one blast-compound,
	# `consumeItem(Items.blastCompound);`
	# (Blocks.java:2643; consumeItem(item) is
	# ItemStack(item, 1), Block.java:1167-1168), so the
	# stacks are one stack of 1 (the catalog consumeItem).
	# The literal "blast-compound" pins the def item
	# independently of the driver's constant, which is
	# itself checked against the literal.
	var blast_stacks: Array = [{"item": "blast-compound", "amount": 1}]
	var held_row: Dictionary = impact_reactor_build_state.source_impact_reactor_item_consumer_row_state({"items": {"blast-compound": 1}}, blast_stacks)
	var missing_row: Dictionary = impact_reactor_build_state.source_impact_reactor_item_consumer_row_state({"items": {}}, blast_stacks)
	var empty_row: Dictionary = impact_reactor_build_state.source_impact_reactor_item_consumer_row_state({"items": {}}, [])
	proof["item_row_binary_blast_compound"] = bool(held_row.get("has_item_row", false)) and is_equal_approx(float(held_row.get("row", {}).get("result", -1.0)), 1.0) and bool(held_row.get("row", {}).get("is_power", true)) == false and bool(missing_row.get("has_item_row", false)) and is_equal_approx(float(missing_row.get("row", {}).get("result", -1.0)), 0.0) and bool(empty_row.get("has_item_row", true)) == false and str(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_ITEM) == "blast-compound" and int(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_ITEM_AMOUNT) == 1

	# --- Pure timer (N2266): the frame-local
	# Interval-equivalent for `if(timer(timerUse,
	# itemDuration / timeScale)){` (ImpactReactor.java:91).
	# TimerComp.timer (TimerComp.java:10-13) returns false
	# for an infinite time; Interval.get (arc
	# Interval.java:20-26) fires when the elapsed time
	# reaches the threshold and RESETS on fire. The
	# threshold is duration / time_scale in ticks
	# (itemDuration 140f def, Blocks.java:2637, NOT the
	# class default 60f, ImpactReactor.java:20). The
	# literal 140.0 pins the def value independently of
	# the driver's constant, which is itself checked
	# against the literal.
	var fired_state: Dictionary = impact_reactor_build_state.source_impact_reactor_timer_use_state(140.0, 140.0, 1.0)
	var scaled_state: Dictionary = impact_reactor_build_state.source_impact_reactor_timer_use_state(70.0, 140.0, 2.0)
	proof["timer_fires_at_item_duration"] = bool(fired_state.get("fired", false)) and is_equal_approx(float(fired_state.get("elapsed_after", -1.0)), 0.0) and is_equal_approx(float(fired_state.get("threshold", -1.0)), 140.0) and bool(scaled_state.get("fired", false)) and is_equal_approx(float(scaled_state.get("threshold", -1.0)), 70.0) and is_equal_approx(float(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_ITEM_DURATION), 140.0)

	var below_state: Dictionary = impact_reactor_build_state.source_impact_reactor_timer_use_state(139.0, 140.0, 1.0)
	var zero_scale_state: Dictionary = impact_reactor_build_state.source_impact_reactor_timer_use_state(1000.0, 140.0, 0.0)
	var negative_scale_state: Dictionary = impact_reactor_build_state.source_impact_reactor_timer_use_state(1000.0, 140.0, -1.0)
	proof["timer_no_fire_below_threshold"] = bool(below_state.get("fired", true)) == false and is_equal_approx(float(below_state.get("elapsed_after", -1.0)), 139.0) and bool(zero_scale_state.get("fired", true)) == false and bool(negative_scale_state.get("fired", true)) == false

	# --- Live tick: the impact reactor is an ImpactReactor
	# build with a static power consumer (impact-reactor,
	# consumePower 25f, Blocks.java:2642), a required liquid
	# consumer (cryofluid 0.25f per frame, Blocks.java:2644)
	# and a required item consumer (1 blast-compound,
	# Blocks.java:2643), placed live; the tick driver is
	# called directly (as the N2182/N2192 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The cryofluid
	# amounts are set on the sprite liquids meta store (the
	# live LiquidModule), which the driver syncs into the
	# frame each tick (the Fracker precedent); the item
	# store and the timer clock are set on the bound frame
	# directly (no live intake fills frame["items"] yet).
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

	# Starved of items: no blast-compound in the frame
	# store folds the BINARY item row to 0, so the folded
	# efficiency is 0 even with power_status 1.0 and a
	# full cryofluid store (both rows 1.0).
	liquid_module_state.source_set_state(impact_reactor_liquids, cryofluid_id, 10.0)
	impact_reactor_frame["power_status"] = 1.0
	impact_reactor_frame["items"] = {}
	impact_reactor_build_state.source_impact_reactor_tick_buildings_state(game, 1.0 / 60.0)
	impact_reactor_frame = impact_reactor.get_meta(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, {})
	proof["item_row_folds_required_min"] = is_equal_approx(float(impact_reactor_frame.get("efficiency", -1.0)), 0.0)

	# Running with the timer due: 2 blast-compound held,
	# power_status 1.0 and a full cryofluid store fold
	# efficiency 1.0, so the warmup gate
	# (ImpactReactor.java:79) holds; the frame-local clock
	# sits at 139 ticks and one tick (source_delta 1.0)
	# reaches the 140-tick threshold, so the timer fires
	# and consume() removes exactly 1 blast-compound
	# (ConsumeItems.trigger, ConsumeItems.java:44-48),
	# resetting the clock to 0.
	liquid_module_state.source_set_state(impact_reactor_liquids, cryofluid_id, 10.0)
	impact_reactor_frame["power_status"] = 1.0
	impact_reactor_frame["items"] = {"blast-compound": 2}
	impact_reactor_frame["timer_use_elapsed"] = 139.0
	impact_reactor_build_state.source_impact_reactor_tick_buildings_state(game, 1.0 / 60.0)
	impact_reactor_frame = impact_reactor.get_meta(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, {})
	var items_after_consume: Dictionary = impact_reactor_frame.get("items", {})
	proof["timer_consume_removes_one"] = is_equal_approx(float(impact_reactor_frame.get("efficiency", -1.0)), 1.0) and int(items_after_consume.get("blast-compound", -1)) == 1 and is_equal_approx(float(impact_reactor_frame.get("timer_use_elapsed", -1.0)), 0.0)

	# Gate closed: power_status 0.5 folds efficiency 0.5,
	# so the warmup gate (ImpactReactor.java:79) fails even
	# though the timer clock reaches the 140-tick
	# threshold -- no consume(), no removal, and the clock
	# keeps its accumulated 140 (the Interval RESET only
	# happens on fire, arc Interval.java:24).
	liquid_module_state.source_set_state(impact_reactor_liquids, cryofluid_id, 10.0)
	impact_reactor_frame["power_status"] = 0.5
	impact_reactor_frame["items"] = {"blast-compound": 2}
	impact_reactor_frame["timer_use_elapsed"] = 139.0
	impact_reactor_build_state.source_impact_reactor_tick_buildings_state(game, 1.0 / 60.0)
	impact_reactor_frame = impact_reactor.get_meta(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, {})
	var items_after_closed_gate: Dictionary = impact_reactor_frame.get("items", {})
	proof["timer_no_fire_when_gate_closed"] = is_equal_approx(float(impact_reactor_frame.get("efficiency", -1.0)), 0.5) and int(items_after_closed_gate.get("blast-compound", -1)) == 2 and is_equal_approx(float(impact_reactor_frame.get("timer_use_elapsed", -1.0)), 140.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ImpactReactorItemRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
