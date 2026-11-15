extends Node

const main_scene := preload("res://scenes/Main.tscn")
const constructor_build_state := preload("res://src/game/SourceConstructorBuildState.gd")
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

	# --- Pure dynamic stacks (N2265): the BlockProducer
	# dynamic consumer (BlockProducer.java:39, `consume(new
	# ConsumeItemDynamic((BlockProducerBuild e) -> {`) clones
	# the recipe block's requirements with each amount ceiled
	# against the build-cost multiplier (`clone[i].amount =
	# Mathf.ceil(block.requirements[i].amount *
	# state.rules.buildCostMultiplier);`, BlockProducer.java:49);
	# a null recipe yields ItemStack.empty (`return
	# ItemStack.empty;`, BlockProducer.java:53). The multiplier
	# default is 1f (Rules.java:115, `public float
	# buildCostMultiplier = 1f;`).
	var stacks: Array = constructor_build_state.source_constructor_dynamic_item_stacks_state([{"item": "copper", "amount": 3}, {"item": "lead", "amount": 2}], 1.5)
	proof["dynamic_stacks_ceil_cost_multiplier"] = stacks.size() == 2 and str(stacks[0].get("item", "")) == "copper" and int(stacks[0].get("amount", -1)) == 5 and str(stacks[1].get("item", "")) == "lead" and int(stacks[1].get("amount", -1)) == 3

	# --- Pure dynamic row (N2265): ConsumeItemDynamic.
	# efficiency (ConsumeItemDynamic.java:60-62, `return
	# build.consumeTriggerValid() || build.items.has(
	# items.get(build), multiplier.get(build)) ? 1f : 0f;`) is
	# BINARY 1/0 -- 1 when every stack is held at round(amount
	# * multiplier), 0 otherwise; an empty stacks array holds
	# trivially, so a null recipe folds 1.0.
	var full_row: Dictionary = constructor_build_state.source_constructor_dynamic_item_consumer_row_state({"items": {"copper": 5, "lead": 3}}, stacks, 1.0)
	proof["dynamic_row_binary_full_stacks"] = bool(full_row.get("has_item_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0) and bool(full_row.get("row", {}).get("is_power", true)) == false

	var missing_row: Dictionary = constructor_build_state.source_constructor_dynamic_item_consumer_row_state({"items": {"copper": 5, "lead": 2}}, stacks, 1.0)
	proof["dynamic_row_zero_missing_stack"] = bool(missing_row.get("has_item_row", false)) and is_equal_approx(float(missing_row.get("row", {}).get("result", -1.0)), 0.0) and bool(missing_row.get("row", {}).get("is_power", true)) == false

	var empty_stacks: Array = constructor_build_state.source_constructor_dynamic_item_stacks_state([], 1.0)
	var empty_row: Dictionary = constructor_build_state.source_constructor_dynamic_item_consumer_row_state({"items": {}}, empty_stacks, 1.0)
	proof["dynamic_row_one_empty_recipe"] = empty_stacks.is_empty() and bool(empty_row.get("has_item_row", false)) and is_equal_approx(float(empty_row.get("row", {}).get("result", -1.0)), 1.0) and bool(empty_row.get("row", {}).get("is_power", true)) == false

	# --- Pure trigger (N2265): ConsumeItemDynamic.trigger
	# (ConsumeItemDynamic.java:53-57, `build.items.remove(
	# stack.item, Math.round(stack.amount *
	# multiplier.get(build)));`) removes round(amount *
	# multiplier) per stack, clamped to the held count
	# (ItemModule.java:258-263, `amount = Math.min(amount,
	# items[item.id]);`). Tested pure, NOT wired live:
	# consume() only fires when the progress advance
	# completes (BlockProducer.java:115-116).
	var removed: Dictionary = constructor_build_state.source_constructor_dynamic_item_trigger_state({"copper": 5, "lead": 3}, stacks, 1.0)
	var clamped: Dictionary = constructor_build_state.source_constructor_dynamic_item_trigger_state({"copper": 2}, [{"item": "copper", "amount": 5}], 1.0)
	var rounded: Dictionary = constructor_build_state.source_constructor_dynamic_item_trigger_state({"copper": 5}, [{"item": "copper", "amount": 3}], 1.5)
	proof["trigger_removes_rounded_amounts"] = int(removed.get("copper", -1)) == 0 and int(removed.get("lead", -1)) == 0 and int(clamped.get("copper", -1)) == 0 and int(rounded.get("copper", -1)) == 0

	# --- Live tick: the constructor is a Constructor build
	# with a power consumer (consumePower 2.5f, large-constructor
	# 3f), placed live; the tick driver is called directly (as
	# the N2147/N2148/N2149/N2150/N2153/N2154/N2155/N2156/N2157/
	# N2158/N2159/N2160 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped power_status --
	# the write-back itself is already proven by N2142. The
	# recipe is the conveyor (catalog requirements: 1 copper),
	# so the dynamic row is 1.0 with 1 copper held and 0.0
	# without; the first pass folds the min of the power row
	# (1.0) and the dynamic row.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var constructor_cell := Vector2i(28, 20)
	var constructor := Sprite2D.new()
	game.add_child(constructor)
	game.call("record_placed_block", constructor, blocks_by_id["constructor"], constructor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	constructor_build_state.source_constructor_bind_frame_state(constructor, blocks_by_id["constructor"])
	var constructor_frame: Dictionary = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})

	# N2216: the shouldConsume gate (BlockProducer.java:103,
	# `return super.shouldConsume() && recipe() != null;`) closes
	# with no recipe, so the proof holds a recipe fixture (the
	# family dict fixture {"block": <id>}, the N2161/N2216
	# precedent) -- otherwise efficiency would read 0.
	constructor_frame["recipe"] = {"block": "conveyor"}

	# Full stacks: efficiency folds the dynamic row 1.0.
	constructor_frame["power_status"] = 1.0
	constructor_frame["items"] = {"copper": 1}
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_frame = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})
	var live_full: bool = is_equal_approx(float(constructor_frame.get("efficiency", -1.0)), 1.0)

	# Missing stack: efficiency folds the dynamic row 0.0.
	constructor_frame["items"] = {"copper": 0}
	constructor_build_state.source_constructor_tick_buildings_state(game, 1.0 / 60.0)
	constructor_frame = constructor.get_meta(constructor_build_state.SOURCE_CONSTRUCTOR_BUILDING_META_KEY, {})
	proof["live_tick_folds_dynamic_row"] = live_full and is_equal_approx(float(constructor_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ConstructorDynamicItemRowProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
