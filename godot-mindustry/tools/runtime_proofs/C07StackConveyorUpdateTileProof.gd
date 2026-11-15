extends Node

const main_scene := preload("res://scenes/Main.tscn")
const stack_conveyor_build_state := preload("res://src/game/SourceStackConveyorBuildState.gd")
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

	# --- Pure advance (N2239): StackConveyorBuild.updateTile()
	# (StackConveyor.java:268-315): the eff fold (disabled
	# still reels at eff 1f, StackConveyor.java:270), the
	# cooldown reel with RAW delta() (StackConveyor.java:273),
	# the link == -1 and cooldown > 0 early returns
	# (StackConveyor.java:276/279), the lastItem pick
	# (StackConveyor.java:282-284, items.first() in content-id
	# order, ItemModule.java:182-188), the !enabled return
	# (StackConveyor.java:287), the unload branch
	# (StackConveyor.java:289-300, the precedence trap: `&&`
	# binds tighter than `?:`), and the transfer branch
	# (StackConveyor.java:301-314, the whole stack moves to
	# the front). source_delta is Time.delta in ticks (1.0 =
	# one tick); recharge is the class constant 2f and
	# itemCapacity 10 (StackConveyor.java:41/52). Positions
	# are Point2-packed (arc Point2.java:40-42): this tile
	# (3, 5), the linked-from tile (2, 5).
	var this_pos: int = (3 << 16) | 5
	var from_pos: int = (2 << 16) | 5
	var item_order: Array = ["copper", "lead"]
	var no_front: Dictionary = {}

	# The cooldown reels by speed * eff * delta()
	# (StackConveyor.java:273), with RAW delta() (not edelta):
	# a powered surge-conveyor (efficiency 1.0, baseEfficiency
	# 1f, speed 5f/60f) reels 1/6 per tick, a plastanium-
	# conveyor with NO efficiency stamp (the no-consumers
	# default 1f when enabled, BuildingComp.java:1944-1946;
	# baseEfficiency 0f, speed 4f/60f) reels 1/15 per tick,
	# timeScale 2.0 doubles the reel, the reel clamps at 0,
	# and the reel runs even with link == -1 (it precedes
	# the link gate).
	var surge_frame: Dictionary = {"efficiency": 1.0, "enabled": true, "state": 0, "link": from_pos, "cooldown": 1.0, "last_item": null, "items": {}}
	var reeled: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(surge_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, no_front, false, false, item_order)
	var plastanium_frame: Dictionary = {"enabled": true, "state": 0, "link": from_pos, "cooldown": 1.0, "last_item": null, "items": {}}
	var plastanium_reeled: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(plastanium_frame, 1.0, 1.0, 4.0 / 60.0, 0.0, true, 2.0, 10, this_pos, no_front, false, false, item_order)
	var scaled: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(surge_frame, 1.0, 2.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, no_front, false, false, item_order)
	var clamp_frame: Dictionary = {"efficiency": 1.0, "enabled": true, "state": 0, "link": from_pos, "cooldown": 0.01, "last_item": null, "items": {}}
	var clamped: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(clamp_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, no_front, false, false, item_order)
	var unlinked_reel_frame: Dictionary = {"efficiency": 1.0, "enabled": true, "state": 0, "link": -1, "cooldown": 1.0, "last_item": null, "items": {}}
	var unlinked_reeled: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(unlinked_reel_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, no_front, false, false, item_order)
	proof["cooldown_reels_with_speed_eff_delta"] = is_equal_approx(float(reeled.get("cooldown", -1.0)), 5.0 / 6.0) and is_equal_approx(float(plastanium_reeled.get("cooldown", -1.0)), 14.0 / 15.0) and is_equal_approx(float(scaled.get("cooldown", -1.0)), 2.0 / 3.0) and is_equal_approx(float(clamped.get("cooldown", -1.0)), 0.0) and is_equal_approx(float(unlinked_reeled.get("cooldown", -1.0)), 5.0 / 6.0)

	# The transfer moves the whole stack to the front
	# (StackConveyor.java:301-314): stateMove with a valid
	# front (same-team StackConveyorBuild, link == -1) moves
	# every item, sets the front lastItem / link / cooldown
	# (1), clears self, sets self link -1 and cooldown =
	# recharge 2f. stateLoad transfers only at capacity
	# (total >= getMaximumAccepted = itemCapacity 10). A
	# front that already has a link, is not a stack conveyor,
	# or is another team blocks the transfer.
	var front: Dictionary = {"is_stack_conveyor": true, "same_team": true, "link": -1, "items": {"lead": 1}, "last_item": "lead", "cooldown": 0.5}
	var transfer_frame: Dictionary = {"efficiency": 1.0, "enabled": true, "state": 0, "link": from_pos, "cooldown": 0.0, "last_item": "copper", "items": {"copper": 3, "lead": 2}}
	var moved: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(transfer_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, front, false, false, item_order)
	var moved_items: Dictionary = moved.get("items", {})
	var moved_front_items: Dictionary = moved.get("front_items", {})
	var loading_frame: Dictionary = {"efficiency": 1.0, "enabled": true, "state": 1, "link": from_pos, "cooldown": 0.0, "last_item": "copper", "items": {"copper": 5}}
	var loading: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(loading_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, front, false, false, item_order)
	var loading_items: Dictionary = loading.get("items", {})
	var full_frame: Dictionary = {"efficiency": 1.0, "enabled": true, "state": 1, "link": from_pos, "cooldown": 0.0, "last_item": "copper", "items": {"copper": 10}}
	var full: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(full_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, front, false, false, item_order)
	var linked_front: Dictionary = {"is_stack_conveyor": true, "same_team": true, "link": (4 << 16) | 5, "items": {}, "last_item": null, "cooldown": 0.0}
	var blocked_link: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(transfer_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, linked_front, false, false, item_order)
	var plain_front: Dictionary = {"is_stack_conveyor": false, "same_team": true, "link": -1, "items": {}, "last_item": null, "cooldown": 0.0}
	var blocked_type: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(transfer_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, plain_front, false, false, item_order)
	var enemy_front: Dictionary = {"is_stack_conveyor": true, "same_team": false, "link": -1, "items": {}, "last_item": null, "cooldown": 0.0}
	var blocked_team: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(transfer_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, enemy_front, false, false, item_order)
	proof["transfer_moves_all_items_to_front"] = bool(moved.get("transferred", false)) == true and moved_items.is_empty() and int(moved.get("link", 0)) == -1 and is_equal_approx(float(moved.get("cooldown", -1.0)), 2.0) and int(moved_front_items.get("copper", -1)) == 3 and int(moved_front_items.get("lead", -1)) == 3 and str(moved.get("front_last_item", "")) == "copper" and int(moved.get("front_link", -1)) == this_pos and is_equal_approx(float(moved.get("front_cooldown", -1.0)), 1.0) and bool(loading.get("transferred", true)) == false and int(loading_items.get("copper", -1)) == 5 and int(loading.get("link", -1)) == from_pos and bool(full.get("transferred", false)) == true and bool(blocked_link.get("transferred", true)) == false and bool(blocked_type.get("transferred", true)) == false and bool(blocked_team.get("transferred", true)) == false

	# The unload branch drains lastItem (StackConveyor.java:
	# 289-300): a surge-conveyor (outputRouter=false) drains
	# through moveForward, a plastanium-conveyor
	# (outputRouter=true) through dump -- both drain all 3
	# coppers, leave the lead, null lastItem, and poofOut
	# (link = -1). A neighbour that refuses (move_forward_ok
	# / dump_ok false) unloads nothing. With lastItem null
	# the pick runs first (items.first() in content-id order:
	# lead, since copper is absent).
	var unload_frame: Dictionary = {"efficiency": 1.0, "enabled": true, "state": 2, "link": from_pos, "cooldown": 0.0, "last_item": "copper", "items": {"copper": 3, "lead": 2}}
	var forwarded: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(unload_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, no_front, true, false, item_order)
	var forwarded_items: Dictionary = forwarded.get("items", {})
	var dumped: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(unload_frame, 1.0, 1.0, 4.0 / 60.0, 0.0, true, 2.0, 10, this_pos, no_front, false, true, item_order)
	var dumped_items: Dictionary = dumped.get("items", {})
	var refused_forward: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(unload_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, no_front, false, false, item_order)
	var refused_forward_items: Dictionary = refused_forward.get("items", {})
	var refused_dump: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(unload_frame, 1.0, 1.0, 4.0 / 60.0, 0.0, true, 2.0, 10, this_pos, no_front, false, false, item_order)
	var pick_frame: Dictionary = {"efficiency": 1.0, "enabled": true, "state": 2, "link": from_pos, "cooldown": 0.0, "last_item": null, "items": {"lead": 2}}
	var picked: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(pick_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, no_front, true, false, item_order)
	var picked_items: Dictionary = picked.get("items", {})
	proof["unload_drains_last_item"] = int(forwarded.get("unloaded", -1)) == 3 and int(forwarded_items.get("copper", -1)) == 0 and int(forwarded_items.get("lead", -1)) == 2 and forwarded.get("last_item", "copper") == null and int(forwarded.get("link", 0)) == -1 and int(dumped.get("unloaded", -1)) == 3 and int(dumped_items.get("copper", -1)) == 0 and int(dumped_items.get("lead", -1)) == 2 and dumped.get("last_item", "copper") == null and int(dumped.get("link", 0)) == -1 and int(refused_forward.get("unloaded", -1)) == 0 and int(refused_forward_items.get("copper", -1)) == 3 and str(refused_forward.get("last_item", "")) == "copper" and int(refused_forward.get("link", -1)) == from_pos and int(refused_dump.get("unloaded", -1)) == 0 and int(picked.get("unloaded", -1)) == 2 and int(picked_items.get("lead", -1)) == 0 and picked.get("last_item", "lead") == null

	# A disabled conveyor still reels but never transfers
	# (StackConveyor.java:270/287): eff is 1f when disabled,
	# so a surge-conveyor reels 5f/60f per tick (1.0 -> 11/12)
	# and the transfer / unload branches never run -- even
	# with cooldown 0 and a valid front. The lastItem pick
	# still runs before the !enabled return.
	var disabled_frame: Dictionary = {"efficiency": 0.0, "enabled": false, "state": 0, "link": from_pos, "cooldown": 1.0, "last_item": "copper", "items": {"copper": 2}}
	var disabled: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(disabled_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, front, false, false, item_order)
	var disabled_items: Dictionary = disabled.get("items", {})
	var disabled_ready_frame: Dictionary = {"efficiency": 0.0, "enabled": false, "state": 0, "link": from_pos, "cooldown": 0.0, "last_item": "copper", "items": {"copper": 2}}
	var disabled_ready: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(disabled_ready_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, front, false, false, item_order)
	var disabled_ready_items: Dictionary = disabled_ready.get("items", {})
	var disabled_unload_frame: Dictionary = {"efficiency": 0.0, "enabled": false, "state": 2, "link": from_pos, "cooldown": 0.0, "last_item": "copper", "items": {"copper": 2}}
	var disabled_unload: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(disabled_unload_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, no_front, true, false, item_order)
	var disabled_pick_frame: Dictionary = {"efficiency": 0.0, "enabled": false, "state": 0, "link": from_pos, "cooldown": 0.0, "last_item": null, "items": {"copper": 2}}
	var disabled_pick: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(disabled_pick_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, no_front, false, false, item_order)
	proof["disabled_still_reels_but_not_transfers"] = is_equal_approx(float(disabled.get("cooldown", -1.0)), 11.0 / 12.0) and bool(disabled.get("transferred", true)) == false and int(disabled_items.get("copper", -1)) == 2 and int(disabled.get("link", -1)) == from_pos and bool(disabled_ready.get("transferred", true)) == false and int(disabled_ready_items.get("copper", -1)) == 2 and int(disabled_ready.get("link", -1)) == from_pos and int(disabled_unload.get("unloaded", -1)) == 0 and str(disabled_pick.get("last_item", "")) == "copper"

	# No transfer without a link (StackConveyor.java:276):
	# link == -1 returns early -- the cooldown still reels
	# (the reel precedes the gate) but the items stay put,
	# the transfer never fires, and the lastItem pick never
	# runs (a stale lastItem stays stale). A nonzero cooldown
	# (StackConveyor.java:279) returns early the same way
	# after reeling.
	var no_link_frame: Dictionary = {"efficiency": 1.0, "enabled": true, "state": 0, "link": -1, "cooldown": 1.0, "last_item": "lead", "items": {"copper": 2}}
	var no_link: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(no_link_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, front, false, false, item_order)
	var no_link_items: Dictionary = no_link.get("items", {})
	var cooling_frame: Dictionary = {"efficiency": 1.0, "enabled": true, "state": 0, "link": from_pos, "cooldown": 1.0, "last_item": "lead", "items": {"copper": 2}}
	var cooling: Dictionary = stack_conveyor_build_state.source_stack_conveyor_update_tile_advance_state(cooling_frame, 1.0, 1.0, 5.0 / 60.0, 1.0, false, 2.0, 10, this_pos, front, false, false, item_order)
	var cooling_items: Dictionary = cooling.get("items", {})
	proof["no_transfer_without_link"] = is_equal_approx(float(no_link.get("cooldown", -1.0)), 5.0 / 6.0) and bool(no_link.get("transferred", true)) == false and int(no_link_items.get("copper", -1)) == 2 and str(no_link.get("last_item", "")) == "lead" and int(no_link.get("link", 0)) == -1 and is_equal_approx(float(cooling.get("cooldown", -1.0)), 5.0 / 6.0) and bool(cooling.get("transferred", true)) == false and int(cooling_items.get("copper", -1)) == 2 and str(cooling.get("last_item", "")) == "lead"

	# --- Live tick: the driver wires the advance into the
	# placed-stack-conveyor tick after the consumption fold
	# (BuildingComp.java:2274-2277), for both defs and even
	# when disabled. A placed surge-conveyor with a full
	# power stamp folds efficiency 1.0, so eff is 2f and one
	# tick (1/60s, source_delta 1.0) reels the cooldown
	# 1.0 -> 5/6; the frame keeps its state / link /
	# last_item / items keys (no front is gathered live, so
	# no transfer fires).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var stack_conveyor_cell := Vector2i(28, 21)
	var stack_conveyor := Sprite2D.new()
	game.add_child(stack_conveyor)
	game.call("record_placed_block", stack_conveyor, blocks_by_id["surge-conveyor"], stack_conveyor_cell)
	stack_conveyor_build_state.source_stack_conveyor_bind_frame_state(stack_conveyor, blocks_by_id["surge-conveyor"])
	var stack_conveyor_frame: Dictionary = stack_conveyor.get_meta(stack_conveyor_build_state.SOURCE_STACK_CONVEYOR_BUILDING_META_KEY, {})
	stack_conveyor_frame["state"] = 0
	stack_conveyor_frame["link"] = from_pos
	stack_conveyor_frame["cooldown"] = 1.0
	stack_conveyor_frame["last_item"] = "copper"
	stack_conveyor_frame["items"] = {"copper": 2}
	stack_conveyor_frame["power_status"] = 1.0
	stack_conveyor_build_state.source_stack_conveyor_tick_buildings_state(game, 1.0 / 60.0)
	stack_conveyor_frame = stack_conveyor.get_meta(stack_conveyor_build_state.SOURCE_STACK_CONVEYOR_BUILDING_META_KEY, {})
	var live_items: Dictionary = stack_conveyor_frame.get("items", {})
	proof["live_tick_writes_advance_frame_keys"] = stack_conveyor_frame.has("state") and stack_conveyor_frame.has("link") and stack_conveyor_frame.has("cooldown") and stack_conveyor_frame.has("last_item") and stack_conveyor_frame.has("items") and int(stack_conveyor_frame.get("state", -1)) == 0 and int(stack_conveyor_frame.get("link", -1)) == from_pos and is_equal_approx(float(stack_conveyor_frame.get("cooldown", -1.0)), 5.0 / 6.0) and str(stack_conveyor_frame.get("last_item", "")) == "copper" and int(live_items.get("copper", -1)) == 2 and is_equal_approx(float(stack_conveyor_frame.get("efficiency", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07StackConveyorUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
