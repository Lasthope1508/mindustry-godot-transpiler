extends Node

const main_scene := preload("res://scenes/Main.tscn")
const item_bridge_build_state := preload("res://src/game/SourceItemBridgeBuildState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# --- Pure dump (N2288): ItemBridgeBuild.doDump()
	# (ItemBridge.java:350-353, `dumpAccumulate();`) -- the
	# base ItemBridge doDump (ITEM dump), called only from
	# the unlinked branch of updateTile()
	# (ItemBridge.java:335-337, `if(!hadValidLink){
	# doDump(); warmup = 0f; }`); the LiquidBridge override
	# (dumpLiquid(current, 1f), LiquidBridge.java:29-31) is
	# a different slice, N2287. dumpAccumulate
	# (BuildingComp.java:1048-1061): `dumpAccum +=
	# delta();`, then `while(dumpAccum >= 1f){ res |=
	# dump(item); dumpAccum -=1f; }` -- possibly MULTIPLE
	# dumps per frame ("allow dumping multiple times per
	# frame", ItemBridge.java:351). delta() is Time.delta
	# * timeScale (BuildingComp.java:1922-1924), NOT
	# edelta(), so the cadence ignores efficiency. There is
	# NO items.total() > 0 gate around the accumulator here
	# (unlike the PayloadDeconstructor,
	# PayloadDeconstructor.java:111) -- the accumulator
	# advances even with an empty store and the dumps
	# simply fail. dump(null) (BuildingComp.java:1072-1113)
	# runs through the shared dump_item_state routing:
	# neighbours outer, content items inner, the acceptItem
	# && canDump gate, handleItem + remove 1 +
	# incrementDump. The neighbour arrays are frame inputs
	# (the N2281 / N2276 precedent, default []) and the
	# dumped item is NOT written into the neighbour frame
	# yet (the N2276 precedent). Content items here are
	# ["copper", "lead"] in catalog order; the dump takes
	# the first held item in that order.
	var item_ids: Array = ["copper", "lead"]
	var one_accepting: Array = [true]
	var one_can_dump: Array = [true]
	var no_neighbours: Array = []

	# The accumulator fires when it reaches 1f: 0.5 +
	# 0.5 dumps 1 (copper 3 -> 2), the remainder is 0.0,
	# and the cursor over the single neighbour stays 0.
	# A fresh accumulator + a full tick (delta 1.0) also
	# fires once.
	var fired_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.5, "cdump": 0}
	var fired: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(fired_frame, false, 0.5, 1.0, item_ids, one_accepting, one_can_dump)
	var fired_items: Dictionary = fired.get("items_after", {})
	var fresh_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.0, "cdump": 0}
	var fresh: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(fresh_frame, false, 1.0, 1.0, item_ids, one_accepting, one_can_dump)
	var fresh_items: Dictionary = fresh.get("items_after", {})
	proof["dump_fires_when_accum_reaches_one"] = int(fired.get("dump_attempts", -1)) == 1 and bool(fired.get("dumped", false)) and is_equal_approx(float(fired.get("dump_accum_after", -1.0)), 0.0) and int(fired_items.get("copper", -1)) == 2 and int(fired.get("cursor_after", -1)) == 0 and int(fresh.get("dump_attempts", -1)) == 1 and bool(fresh.get("dumped", false)) and int(fresh_items.get("copper", -1)) == 2

	# Below the threshold nothing fires and nothing
	# leaves the store: 0.0 + 0.5 accumulates to 0.5 with
	# 0 attempts, and 0.9 + 0.05 accumulates to 0.95
	# with 0 attempts; the cursor is untouched in both.
	var below_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.0, "cdump": 0}
	var below: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(below_frame, false, 0.5, 1.0, item_ids, one_accepting, one_can_dump)
	var below_items: Dictionary = below.get("items_after", {})
	var near_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.9, "cdump": 0}
	var near: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(near_frame, false, 0.05, 1.0, item_ids, one_accepting, one_can_dump)
	var near_items: Dictionary = near.get("items_after", {})
	proof["dump_no_fire_below_threshold"] = int(below.get("dump_attempts", -1)) == 0 and not bool(below.get("dumped", true)) and is_equal_approx(float(below.get("dump_accum_after", -1.0)), 0.5) and int(below_items.get("copper", -1)) == 3 and int(below.get("cursor_after", -1)) == 0 and int(near.get("dump_attempts", -1)) == 0 and not bool(near.get("dumped", true)) and is_equal_approx(float(near.get("dump_accum_after", -1.0)), 0.95) and int(near_items.get("copper", -1)) == 3 and int(near.get("cursor_after", -1)) == 0

	# A large delta dumps multiple times per frame: 0.0
	# + 3.0 fires 3 attempts (copper 5 -> 2, remainder
	# 0.0), and 0.5 + 2.5 also fires 3 (copper 5 -> 2,
	# remainder 0.0). A partial remainder survives: 0.0 +
	# 2.5 fires 2 attempts (copper 5 -> 3, remainder 0.5).
	var multi_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var multi: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(multi_frame, false, 3.0, 1.0, item_ids, one_accepting, one_can_dump)
	var multi_items: Dictionary = multi.get("items_after", {})
	var multi_part_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.5, "cdump": 0}
	var multi_part: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(multi_part_frame, false, 2.5, 1.0, item_ids, one_accepting, one_can_dump)
	var multi_part_items: Dictionary = multi_part.get("items_after", {})
	var remainder_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var remainder: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(remainder_frame, false, 2.5, 1.0, item_ids, one_accepting, one_can_dump)
	var remainder_items: Dictionary = remainder.get("items_after", {})
	proof["dump_multiple_times_per_frame"] = int(multi.get("dump_attempts", -1)) == 3 and bool(multi.get("dumped", false)) and is_equal_approx(float(multi.get("dump_accum_after", -1.0)), 0.0) and int(multi_items.get("copper", -1)) == 2 and int(multi_part.get("dump_attempts", -1)) == 3 and int(multi_part_items.get("copper", -1)) == 2 and is_equal_approx(float(multi_part.get("dump_accum_after", -1.0)), 0.0) and int(remainder.get("dump_attempts", -1)) == 2 and int(remainder_items.get("copper", -1)) == 3 and is_equal_approx(float(remainder.get("dump_accum_after", -1.0)), 0.5)

	# doDump runs ONLY in the unlinked branch
	# (ItemBridge.java:335-337): linked, the same frame
	# dumps nothing -- 0 attempts, the accumulator stays
	# 0.5, the store is untouched, and the cursor stays at
	# its stale 2. Unlinked, the same frame fires once
	# (copper 3 -> 2, remainder 0.5) and the cursor wraps
	# to 0 over the single neighbour.
	var linked_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.5, "cdump": 2}
	var linked: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(linked_frame, true, 1.0, 1.0, item_ids, one_accepting, one_can_dump)
	var linked_items: Dictionary = linked.get("items_after", {})
	var unlinked_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.5, "cdump": 2}
	var unlinked: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(unlinked_frame, false, 1.0, 1.0, item_ids, one_accepting, one_can_dump)
	var unlinked_items: Dictionary = unlinked.get("items_after", {})
	proof["dump_only_when_unlinked"] = int(linked.get("dump_attempts", -1)) == 0 and not bool(linked.get("dumped", true)) and is_equal_approx(float(linked.get("dump_accum_after", -1.0)), 0.5) and int(linked_items.get("copper", -1)) == 3 and int(linked.get("cursor_after", -1)) == 2 and int(unlinked.get("dump_attempts", -1)) == 1 and bool(unlinked.get("dumped", false)) and is_equal_approx(float(unlinked.get("dump_accum_after", -1.0)), 0.5) and int(unlinked_items.get("copper", -1)) == 2 and int(unlinked.get("cursor_after", -1)) == 0

	# The dump removes 1 item from the store, in content
	# order: copper goes first (copper 3 -> 2, lead
	# untouched at 2). A rejecting neighbour dumps nothing
	# (1 attempt, dumped false, store untouched, cursor
	# 0 after the full-circle failed scan). With no
	# neighbours the guard fails (dumped false, store
	# untouched, cursor untouched) but the attempt still
	# counts and the accumulator still spends its 1f. An
	# empty store is the same: the accumulator advances
	# (0.0 + 1.0 -> 0.0 after the attempt) but nothing
	# dumps.
	var ordered_frame: Dictionary = {"items": {"copper": 3, "lead": 2}, "dump_accum": 0.0, "cdump": 0}
	var ordered: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(ordered_frame, false, 1.0, 1.0, item_ids, one_accepting, one_can_dump)
	var ordered_items: Dictionary = ordered.get("items_after", {})
	var rejected_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.0, "cdump": 0}
	var rejected: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(rejected_frame, false, 1.0, 1.0, item_ids, [false], one_can_dump)
	var rejected_items: Dictionary = rejected.get("items_after", {})
	var lonely_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.0, "cdump": 0}
	var lonely: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(lonely_frame, false, 1.0, 1.0, item_ids, no_neighbours, no_neighbours)
	var lonely_items: Dictionary = lonely.get("items_after", {})
	var empty_frame: Dictionary = {"items": {}, "dump_accum": 0.0, "cdump": 0}
	var empty: Dictionary = item_bridge_build_state.source_item_bridge_do_dump_state(empty_frame, false, 1.0, 1.0, item_ids, one_accepting, one_can_dump)
	proof["dump_removes_item_from_store"] = int(ordered_items.get("copper", -1)) == 2 and int(ordered_items.get("lead", -1)) == 2 and bool(ordered.get("dumped", false)) and int(rejected.get("dump_attempts", -1)) == 1 and not bool(rejected.get("dumped", true)) and int(rejected_items.get("copper", -1)) == 3 and int(rejected.get("cursor_after", -1)) == 0 and int(lonely.get("dump_attempts", -1)) == 1 and not bool(lonely.get("dumped", true)) and int(lonely_items.get("copper", -1)) == 3 and int(lonely.get("cursor_after", -1)) == 0 and is_equal_approx(float(lonely.get("dump_accum_after", -1.0)), 0.0) and int(empty.get("dump_attempts", -1)) == 1 and not bool(empty.get("dumped", true)) and is_equal_approx(float(empty.get("dump_accum_after", -1.0)), 0.0)

	# --- Live tick: the phase-conveyor is placed live and
	# unlinked (link -1, had_valid_link false), with 3
	# copper in its frame items and one accepting
	# neighbour stamped as frame inputs (the N2281 / N2276
	# precedent). The tick driver is called directly (as
	# the N2287 proof does), not simulate_factory, so the
	# graph update does not overwrite the stamped
	# power_status -- the write-back itself is already
	# proven by N2142. One 1/60s tick is one source tick:
	# the shouldConsume gate is closed while unlinked
	# (ItemBridge.java:495-496), so efficiency folds 0
	# (potential 0.5, the power min); warmup is 0f
	# (ItemBridge.java:337); and the unlinked branch dumps
	# 1 copper to the neighbour (3 -> 2), spending the
	# accumulator (0.0 + 1.0 -> 0.0) with the cursor
	# staying 0 over the single neighbour.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var item_bridge_cell := Vector2i(28, 21)
	var item_bridge := Sprite2D.new()
	game.add_child(item_bridge)
	game.call("record_placed_block", item_bridge, blocks_by_id["phase-conveyor"], item_bridge_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the dump inputs on it).
	item_bridge_build_state.source_item_bridge_bind_frame_state(item_bridge, blocks_by_id["phase-conveyor"])
	var item_bridge_frame: Dictionary = item_bridge.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})

	item_bridge_frame["power_status"] = 0.5
	item_bridge_frame["items"] = {"copper": 3}
	item_bridge_frame["dump_neighbour_accepts"] = [true]
	item_bridge_frame["dump_neighbour_can_dump"] = [true]
	item_bridge_build_state.source_item_bridge_tick_buildings_state(game, 1.0 / 60.0)
	item_bridge_frame = item_bridge.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	var live_items: Dictionary = item_bridge_frame.get("items", {})
	proof["live_tick_dumps_item"] = is_equal_approx(float(item_bridge_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(item_bridge_frame.get("potential_efficiency", -1.0)), 0.5) and is_equal_approx(float(item_bridge_frame.get("warmup", -1.0)), 0.0) and bool(item_bridge_frame.get("had_valid_link", true)) == false and int(live_items.get("copper", -1)) == 2 and is_equal_approx(float(item_bridge_frame.get("dump_accum", -1.0)), 0.0) and int(item_bridge_frame.get("cdump", -1)) == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemBridgeDoDumpProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
