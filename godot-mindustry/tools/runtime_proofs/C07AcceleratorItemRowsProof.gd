extends Node

const main_scene := preload("res://scenes/Main.tscn")
const accelerator_build_state := preload("res://src/game/SourceAcceleratorBuildState.gd")
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

	# --- Pure item row (N2267): ConsumeItems.efficiency is
	# BINARY 1/0 (ConsumeItems.java:51-53, `return build.
	# consumeTriggerValid() || build.items.has(items,
	# multiplier.get(build)) ? 1f : 0f;`), 1.0 exactly when
	# every stack is held (ItemModule.java:153-157); the
	# trigger-valid half is the base false (BuildingComp.
	# java:764-766) and the multiplier is the Consume default
	# 1f (Consume.java:18). The stacks are the core-nucleus
	# requirements -- copper 8000, lead 8000, silicon 5000,
	# thorium 4000 (Blocks.java:3154) -- registered as one
	# ConsumeItems by `consumeItems(launchBlock.requirements);`
	# (Accelerator.java:91).
	var stacks: Array = accelerator_build_state._accelerator_item_stacks_for_block("interplanetary-accelerator")
	var full_items: Dictionary = {"copper": 8000, "lead": 8000, "silicon": 5000, "thorium": 4000}
	var full_row: Dictionary = accelerator_build_state.source_accelerator_item_consumer_row_state({"items": full_items}, stacks)
	var empty_row: Dictionary = accelerator_build_state.source_accelerator_item_consumer_row_state({"items": {}}, stacks)
	var no_stacks: Dictionary = accelerator_build_state.source_accelerator_item_consumer_row_state({"items": full_items}, [])
	proof["item_row_binary_core_nucleus_stacks"] = bool(full_row.get("has_item_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0) and bool(full_row.get("row", {}).get("is_power", true)) == false and bool(empty_row.get("has_item_row", false)) and is_equal_approx(float(empty_row.get("row", {}).get("result", -1.0)), 0.0) and bool(no_stacks.get("has_item_row", true)) == false

	# One short on any stack zeroes the row: thorium 3999 of
	# 4000 with everything else full still folds 0.0.
	var short_items: Dictionary = {"copper": 8000, "lead": 8000, "silicon": 5000, "thorium": 3999}
	var short_row: Dictionary = accelerator_build_state.source_accelerator_item_consumer_row_state({"items": short_items}, stacks)
	proof["item_row_zero_missing_thorium"] = bool(short_row.get("has_item_row", false)) and is_equal_approx(float(short_row.get("row", {}).get("result", -1.0)), 0.0)

	# --- Capacities (N2267): init() (Accelerator.java:84-92)
	# fills capacities[item.id] = stack.amount for each
	# launch-block requirement stack and sums itemCapacity
	# (`itemCapacity = 0;` / `capacities = new int[content.
	# items().size];` / `capacities[stack.item.id] = stack.
	# amount;` / `itemCapacity += stack.amount;`); the class
	# default 8000 (Accelerator.java:76) is zeroed first, so
	# the sum is 8000 + 8000 + 5000 + 4000 = 25000 -- NOT the
	# catalog's itemCapacity 10, the stale Block default.
	var capacities_state: Dictionary = accelerator_build_state.source_accelerator_capacities_state()
	var capacities: Dictionary = capacities_state.get("capacities", {})
	proof["capacities_sum_item_capacity_25000"] = int(capacities.get("copper", -1)) == 8000 and int(capacities.get("lead", -1)) == 8000 and int(capacities.get("silicon", -1)) == 5000 and int(capacities.get("thorium", -1)) == 4000 and int(capacities_state.get("item_capacity", -1)) == 25000

	# --- Maximum accepted (N2267): getMaximumAccepted
	# (Accelerator.java:293-295, `return capacities[item.id] +
	# (isCoreBuilt() ? launchBlock.itemCapacity : 0);`) adds
	# the launch block's itemCapacity -- core-nucleus 13000
	# (Blocks.java:3158) -- only once the core is built
	# (isCoreBuilt, Accelerator.java:153-154). An item with no
	# requirement reads capacity 0, so its maximum is the core
	# bonus alone when built, 0 when not.
	var copper_unbuilt: Dictionary = accelerator_build_state.source_accelerator_get_maximum_accepted_state("copper", false)
	var copper_built: Dictionary = accelerator_build_state.source_accelerator_get_maximum_accepted_state("copper", true)
	var surge_unbuilt: Dictionary = accelerator_build_state.source_accelerator_get_maximum_accepted_state("surge-alloy", false)
	proof["max_accepted_adds_core_bonus_when_built"] = int(copper_unbuilt.get("maximum_accepted", -1)) == 8000 and int(copper_unbuilt.get("capacity", -1)) == 8000 and int(copper_unbuilt.get("core_bonus", -1)) == 0 and int(copper_built.get("maximum_accepted", -1)) == 21000 and int(copper_built.get("capacity", -1)) == 8000 and int(copper_built.get("core_bonus", -1)) == 13000 and int(surge_unbuilt.get("maximum_accepted", -1)) == 0 and int(surge_unbuilt.get("capacity", -1)) == 0

	# --- Accept item (N2267): acceptItem (Accelerator.java:
	# 297-299, `return items.get(item) < getMaximumAccepted(
	# item);`) is strictly less-than: held == maximum
	# rejects, both before and after the core is built.
	var accept_below: Dictionary = accelerator_build_state.source_accelerator_accept_item_state("copper", 7999, false)
	var accept_at_max: Dictionary = accelerator_build_state.source_accelerator_accept_item_state("copper", 8000, false)
	var accept_built_below: Dictionary = accelerator_build_state.source_accelerator_accept_item_state("copper", 20999, true)
	var accept_built_at_max: Dictionary = accelerator_build_state.source_accelerator_accept_item_state("copper", 21000, true)
	proof["accept_item_below_max_only"] = bool(accept_below.get("accept", false)) and int(accept_below.get("held", -1)) == 7999 and int(accept_below.get("maximum_accepted", -1)) == 8000 and bool(accept_at_max.get("accept", true)) == false and bool(accept_built_below.get("accept", false)) and int(accept_built_below.get("maximum_accepted", -1)) == 21000 and bool(accept_built_at_max.get("accept", true)) == false

	# --- Live tick: the accelerator is an Accelerator build
	# with a static power consumer (interplanetary-accelerator,
	# consumePower 10f, Blocks.java:6829), placed live; the
	# tick driver is called directly (as the N2147/N2148/
	# N2149/N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/
	# N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/N2168/
	# N2169/N2170/N2171/N2172/N2173/N2174/N2175/N2176/N2177/
	# N2178/N2179/N2180/N2181/N2182 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The item row folds into the
	# REQUIRED first pass (BuildingComp.java:1969-1976), so a
	# starved row zeroes efficiency even at full power, and
	# the progress advance (Accelerator.java:143) follows it.
	# No live intake fills frame["items"] yet, so the proof
	# seeds the frame items dict directly (the N2223 precedent).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var accelerator_cell := Vector2i(30, 21)
	var accelerator := Sprite2D.new()
	game.add_child(accelerator)
	game.call("record_placed_block", accelerator, blocks_by_id["interplanetary-accelerator"], accelerator_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# items on it).
	accelerator_build_state.source_accelerator_bind_frame_state(accelerator, blocks_by_id["interplanetary-accelerator"])
	var accelerator_frame: Dictionary = accelerator.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})

	# Full power, all four stacks held: efficiency folds 1.0.
	accelerator_frame["power_status"] = 1.0
	accelerator_frame["items"] = {"copper": 8000, "lead": 8000, "silicon": 5000, "thorium": 4000}
	accelerator_build_state.source_accelerator_tick_buildings_state(game, 1.0 / 60.0)
	accelerator_frame = accelerator.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	var live_full: bool = is_equal_approx(float(accelerator_frame.get("efficiency", -1.0)), 1.0)

	# Full power, thorium one short: the item row folds 0.0
	# and efficiency follows it -- the power row alone cannot
	# keep the accelerator charging.
	accelerator_frame["power_status"] = 1.0
	accelerator_frame["items"] = {"copper": 8000, "lead": 8000, "silicon": 5000, "thorium": 3999}
	accelerator_build_state.source_accelerator_tick_buildings_state(game, 1.0 / 60.0)
	accelerator_frame = accelerator.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	proof["live_tick_folds_item_row"] = live_full and is_equal_approx(float(accelerator_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07AcceleratorItemRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
