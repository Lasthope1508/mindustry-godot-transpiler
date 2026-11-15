extends Node

const main_scene := preload("res://scenes/Main.tscn")
const stack_router_build_state := preload("res://src/game/SourceStackRouterBuildState.gd")
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

	# --- Pure advance (N2240): StackRouterBuild.updateTile()
	# (StackRouter.java:28-70): the eff fold (eff = enabled ?
	# (efficiency + baseEfficiency) : 0f, :29 -- 0f when
	# disabled, NOT the conveyor's 1f), the cap (cap = speed,
	# :30), the charge branch (:32-41 -- progress += eff with
	# NO delta multiply, then unloading = true + progress %=
	# cap at the cap), the unload branch (:45-60 -- target =
	# target() + the while handoff loop + the out-of-items
	# clear), the current-pick branch (:62-63 -- current =
	# items.first(), content-id order) and the empty reset
	# (:66-68). The pure calls use the surge-router def values:
	# speed 6f (Blocks.java:2259), baseEfficiency 1f
	# (Blocks.java:2265), itemCapacity 10 (StackRouter.java:
	# 20). The targets list models the target() call sequence,
	# one entry per handoff (cdump rotation simulated by list
	# order); the item order is the content-id order
	# ItemModule.first() scans (ItemModule.java:182-189).
	# Progress charges by eff when the store is full with a
	# current item: half power folds eff 0.5 + 1.0 = 1.5; with
	# no power the base still charges at eff 1f; disabled
	# charges nothing (eff 0f); a store below capacity does not
	# charge; with no current item there is no charge (the
	# pick branch runs instead); while already unloading the
	# charge branch is skipped.
	var full_half: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": false, "current": "copper", "progress": 0.0, "items": {"copper": 10}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var no_power: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.0, "enabled": true, "unloading": false, "current": "copper", "progress": 0.0, "items": {"copper": 10}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var disabled: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 1.0, "enabled": false, "unloading": false, "current": "copper", "progress": 0.0, "items": {"copper": 10}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var not_full: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": false, "current": "copper", "progress": 0.0, "items": {"copper": 9}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var no_current: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": false, "current": null, "progress": 0.0, "items": {"copper": 10}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var already_unloading: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": true, "current": "copper", "progress": 0.0, "items": {"copper": 10}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	proof["progress_charges_when_full"] = is_equal_approx(float(full_half.get("progress", -1.0)), 1.5) and bool(full_half.get("unloading", true)) == false and is_equal_approx(float(no_power.get("progress", -1.0)), 1.0) and is_equal_approx(float(disabled.get("progress", -1.0)), 0.0) and is_equal_approx(float(not_full.get("progress", -1.0)), 0.0) and str(not_full.get("current", "")) == "copper" and is_equal_approx(float(no_current.get("progress", -1.0)), 0.0) and str(no_current.get("current", "")) == "copper" and is_equal_approx(float(already_unloading.get("progress", -1.0)), 0.0) and bool(already_unloading.get("unloading", false))

	# Unloading starts at the cap with progress %= cap: from
	# 5.0 with eff 1.5 the charge lands on 6.5, so unloading
	# starts and progress wraps to 0.5; from 4.5 the charge
	# lands exactly on 6.0, so unloading starts and progress
	# wraps to 0.0; from 6.0 already at the cap the first if is
	# skipped but the second still fires, so unloading starts
	# and progress wraps to 0.0; from 4.0 the charge lands on
	# 5.5, below the cap, so unloading does not start. With no
	# targets the unload branch drains nothing in the same
	# tick, so the store stays full and the current item stays.
	var over_cap: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": false, "current": "copper", "progress": 5.0, "items": {"copper": 10}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var over_cap_items: Dictionary = over_cap.get("items", {})
	var exact_cap: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": false, "current": "copper", "progress": 4.5, "items": {"copper": 10}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var at_cap: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": false, "current": "copper", "progress": 6.0, "items": {"copper": 10}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var below_cap: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": false, "current": "copper", "progress": 4.0, "items": {"copper": 10}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	proof["unloading_starts_at_cap"] = bool(over_cap.get("unloading", false)) and is_equal_approx(float(over_cap.get("progress", -1.0)), 0.5) and str(over_cap.get("current", "")) == "copper" and int(over_cap_items.get("copper", -1)) == 10 and bool(exact_cap.get("unloading", false)) and is_equal_approx(float(exact_cap.get("progress", -1.0)), 0.0) and bool(at_cap.get("unloading", false)) and is_equal_approx(float(at_cap.get("progress", -1.0)), 0.0) and bool(below_cap.get("unloading", true)) == false and is_equal_approx(float(below_cap.get("progress", -1.0)), 5.5)

	# The handoff drains the current item in list order: 3
	# copper to targets a/b/c hands off 3, reports the ids in
	# order, empties the copper, clears unloading, and re-picks
	# lead (the next held item in content-id order). When the
	# list runs out mid-drain the handoff stops with items
	# left, the current item kept, and unloading still true.
	# With no targets nothing is handed off. When the current
	# count is already zero the loop never runs, the out-of-
	# items clear still fires, and the pick branch re-picks
	# lead. Repeating one target entry models N items to the
	# same target (the cdump-rotation stand-in); draining the
	# last items empties the store, so current is null.
	var drain: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": true, "current": "copper", "progress": 0.5, "items": {"copper": 3, "lead": 7}}, 6.0, 1.0, 10, [{"id": "a"}, {"id": "b"}, {"id": "c"}], ["copper", "lead"])
	var drain_items: Dictionary = drain.get("items", {})
	var exhausted: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": true, "current": "copper", "progress": 0.5, "items": {"copper": 3}}, 6.0, 1.0, 10, [{"id": "a"}], ["copper", "lead"])
	var exhausted_items: Dictionary = exhausted.get("items", {})
	var no_targets: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": true, "current": "copper", "progress": 0.5, "items": {"copper": 3}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var no_targets_items: Dictionary = no_targets.get("items", {})
	var dry_current: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": true, "current": "copper", "progress": 0.5, "items": {"lead": 10}}, 6.0, 1.0, 10, [{"id": "a"}], ["copper", "lead"])
	var same_target: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": true, "current": "copper", "progress": 0.5, "items": {"copper": 2}}, 6.0, 1.0, 10, [{"id": "a"}, {"id": "a"}], ["copper", "lead"])
	var same_target_items: Dictionary = same_target.get("items", {})
	proof["handoff_drains_current_item"] = int(drain.get("handed_off", -1)) == 3 and Array(drain.get("handed_to", [])) == ["a", "b", "c"] and int(drain_items.get("copper", -1)) == 0 and int(drain_items.get("lead", -1)) == 7 and str(drain.get("current", "")) == "lead" and bool(drain.get("unloading", true)) == false and int(exhausted.get("handed_off", -1)) == 1 and Array(exhausted.get("handed_to", [])) == ["a"] and int(exhausted_items.get("copper", -1)) == 2 and str(exhausted.get("current", "")) == "copper" and bool(exhausted.get("unloading", false)) and int(no_targets.get("handed_off", -1)) == 0 and Array(no_targets.get("handed_to", ["x"])).is_empty() and int(no_targets_items.get("copper", -1)) == 3 and bool(no_targets.get("unloading", false)) and int(dry_current.get("handed_off", -1)) == 0 and str(dry_current.get("current", "")) == "lead" and bool(dry_current.get("unloading", true)) == false and int(same_target.get("handed_off", -1)) == 2 and Array(same_target.get("handed_to", [])) == ["a", "a"] and int(same_target_items.get("copper", -1)) == 0 and same_target.get("current", {}) == null and bool(same_target.get("unloading", true)) == false

	# Current picks the first held item in content-id order,
	# not dict order: with lead inserted before copper the
	# pick is still copper. A current item with a zero count
	# is re-picked. An empty store picks nothing. An empty
	# item order picks nothing (no content order is known).
	# A current item with a positive count is kept.
	var order_beats_dict: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": false, "current": null, "progress": 0.0, "items": {"lead": 2, "copper": 3}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var repick: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": false, "current": "copper", "progress": 0.0, "items": {"copper": 0, "lead": 2}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var empty_store: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": false, "current": null, "progress": 0.0, "items": {}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var no_order: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": false, "current": null, "progress": 0.0, "items": {"lead": 2}}, 6.0, 1.0, 10, [], [])
	var keep_current: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": false, "current": "lead", "progress": 0.0, "items": {"copper": 3, "lead": 2}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	proof["current_picks_first_item"] = str(order_beats_dict.get("current", "")) == "copper" and str(repick.get("current", "")) == "lead" and empty_store.get("current", {}) == null and no_order.get("current", {}) == null and str(keep_current.get("current", "")) == "lead"

	# Empty items reset unloading and current, and leave
	# progress untouched -- both for a truly empty dict and
	# for a dict holding only zero counts (empty is total ==
	# 0, ItemModule.java:170-172). A non-empty store keeps
	# unloading true when nothing is handed off.
	var empty_reset: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": true, "current": "copper", "progress": 3.0, "items": {}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var zero_counts: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": true, "current": "copper", "progress": 3.0, "items": {"copper": 0}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	var nonempty_keeps: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": true, "current": "copper", "progress": 3.0, "items": {"copper": 1}}, 6.0, 1.0, 10, [], ["copper", "lead"])
	proof["empty_resets_unloading"] = bool(empty_reset.get("unloading", true)) == false and empty_reset.get("current", {}) == null and is_equal_approx(float(empty_reset.get("progress", -1.0)), 3.0) and bool(zero_counts.get("unloading", true)) == false and zero_counts.get("current", {}) == null and is_equal_approx(float(zero_counts.get("progress", -1.0)), 3.0) and bool(nonempty_keeps.get("unloading", false)) and str(nonempty_keeps.get("current", "")) == "copper" and is_equal_approx(float(nonempty_keeps.get("progress", -1.0)), 3.0)

	# --- Live tick: a surge-router placed live at cell (28,
	# 21) with a seeded full store (10 copper, current copper,
	# progress 0). The tick driver is called directly (as the
	# N2181 proof does), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status --
	# the write-back itself is already proven by N2142. One
	# 1/60s tick is one source tick: efficiency folds the
	# power min 0.5, so eff is 0.5 + 1.0 = 1.5 and progress
	# charges to 1.5, unloading stays false, and no handoff
	# happens (the driver passes an empty targets list). A
	# second tick with progress seeded at 5.0 charges to 6.5,
	# so unloading starts and progress wraps to 0.5, the store
	# stays full, and the current item stays copper.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var stack_router_cell := Vector2i(28, 21)
	var stack_router := Sprite2D.new()
	game.add_child(stack_router)
	game.call("record_placed_block", stack_router, blocks_by_id["surge-router"], stack_router_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and seed
	# the store on it).
	stack_router_build_state.source_stack_router_bind_frame_state(stack_router, blocks_by_id["surge-router"])
	var stack_router_frame: Dictionary = stack_router.get_meta(stack_router_build_state.SOURCE_STACK_ROUTER_BUILDING_META_KEY, {})

	stack_router_frame["items"] = {"copper": 10}
	stack_router_frame["current"] = "copper"
	stack_router_frame["progress"] = 0.0
	stack_router_frame["power_status"] = 0.5
	stack_router_build_state.source_stack_router_tick_buildings_state(game, 1.0 / 60.0)
	stack_router_frame = stack_router.get_meta(stack_router_build_state.SOURCE_STACK_ROUTER_BUILDING_META_KEY, {})
	var live_first_items: Dictionary = stack_router_frame.get("items", {})
	var live_first: bool = is_equal_approx(float(stack_router_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(stack_router_frame.get("progress", -1.0)), 1.5) and bool(stack_router_frame.get("unloading", true)) == false and str(stack_router_frame.get("current", "")) == "copper" and int(live_first_items.get("copper", -1)) == 10 and int(stack_router_frame.get("handed_off", -1)) == 0 and Array(stack_router_frame.get("handed_to", ["x"])).is_empty()

	stack_router_frame["progress"] = 5.0
	stack_router_frame["power_status"] = 0.5
	stack_router_build_state.source_stack_router_tick_buildings_state(game, 1.0 / 60.0)
	stack_router_frame = stack_router.get_meta(stack_router_build_state.SOURCE_STACK_ROUTER_BUILDING_META_KEY, {})
	var live_second_items: Dictionary = stack_router_frame.get("items", {})
	proof["live_tick_writes_advance_frame_keys"] = live_first and is_equal_approx(float(stack_router_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(stack_router_frame.get("progress", -1.0)), 0.5) and bool(stack_router_frame.get("unloading", false)) and str(stack_router_frame.get("current", "")) == "copper" and int(live_second_items.get("copper", -1)) == 10 and int(stack_router_frame.get("handed_off", -1)) == 0 and Array(stack_router_frame.get("handed_to", ["x"])).is_empty()

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07StackRouterUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
