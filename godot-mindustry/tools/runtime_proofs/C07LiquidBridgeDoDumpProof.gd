extends Node

const main_scene := preload("res://scenes/Main.tscn")
const liquid_bridge_build_state := preload("res://src/game/SourceLiquidBridgeBuildState.gd")
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

	# --- Pure dump (N2287): LiquidBridgeBuild.doDump()
	# (LiquidBridge.java:29-31, `dumpLiquid(liquids.current(),
	# 1f);`) -- the LiquidBridge OVERRIDE, called only from
	# the unlinked branch of the inherited ItemBridgeBuild.
	# updateTile() (ItemBridge.java:335-337, `if(!hadValidLink){
	# doDump(); warmup = 0f; }`); the base ItemBridge doDump
	# is dumpAccumulate() (ItemBridge.java:350-353, item dump),
	# a different slice. Scaling is 1f -- NOT the 2f default
	# (BuildingComp.java:877-878) -- and output_dir is -1
	# (any direction, BuildingComp.java:881-882). dumpLiquid
	# (BuildingComp.java:886-908): early return at or below
	# 0.0001f, the campaign unlock (BuildingComp.java:891,
	# deferred -- no unlock registry in the port), the
	# proximity scan from cdump with incrementDump EVERY
	# iteration (BuildingComp.java:893-894), the eligibility
	# gate (other.block.hasLiquids && canDumpLiquid &&
	# other.liquids != null, BuildingComp.java:901), and the
	# transfer when ofract < fract: (fract - ofract) *
	# block.liquidCapacity / scaling (BuildingComp.java:905),
	# with NO liquidPressure multiplier (unlike moveLiquid).
	# transferLiquid (BuildingComp.java:914-921): flow =
	# min(neighbour free capacity, amount), applied only
	# when next.acceptLiquid(self(), liquid). The dump runs
	# through the shared dump_liquid_state helper (the pump /
	# factory precedent); the neighbour arrays are frame
	# inputs (the N2276 precedent, default []) and the
	# dumped amount is NOT written into the neighbour frame
	# yet (the N2276 precedent). Liquid stores are module
	# states (amounts array by liquid id + current id,
	# LiquidModule.java:24/81-83): liquid 0 is the dumped
	# liquid. liquidCapacity is the def constant 100f
	# (Blocks.java:2395).
	var no_neighbours: Dictionary = {"amounts": [], "capacities": [], "accepts": []}

	# dumpLiquid transfers by the fraction difference at
	# scaling 1f: 50 vs 20 flows 30 ((0.5 - 0.2) * 100 / 1);
	# 80 vs 0 flows 80, capped by what the bridge holds; and
	# with two neighbours the scan is sequential -- 90 vs
	# [50, 0] flows 40 to the first, then the re-read fract
	# (0.5) flows the remaining 50 to the second, 90 total.
	# The self current is unchanged (remove goes through add
	# with the same liquid, LiquidModule.java:124-127).
	var frame_zero: Dictionary = {"cdump": 0}
	var one_neighbour: Dictionary = {"amounts": [20.0], "capacities": [100.0], "accepts": [true]}
	var transferred: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, one_neighbour)
	var transferred_amounts: Array = (transferred.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var emptied: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [80.0], "current": 0, "flow": null}, 100.0, {"amounts": [0.0], "capacities": [100.0], "accepts": [true]})
	var emptied_amounts: Array = (emptied.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var two_neighbours: Dictionary = {"amounts": [50.0, 0.0], "capacities": [100.0, 100.0], "accepts": [true, true]}
	var split: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [90.0], "current": 0, "flow": null}, 100.0, two_neighbours)
	var split_amounts: Array = (split.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var split_store: Dictionary = split.get("liquids_after", {})
	proof["dump_transfers_to_neighbour"] = is_equal_approx(float(transferred.get("dumped_amount", -1.0)), 30.0) and is_equal_approx(float(transferred_amounts[0]), 20.0) and is_equal_approx(float(emptied.get("dumped_amount", -1.0)), 80.0) and is_equal_approx(float(emptied_amounts[0]), 0.0) and is_equal_approx(float(split.get("dumped_amount", -1.0)), 90.0) and is_equal_approx(float(split_amounts[0]), 0.0) and int(split_store.get("current", -1)) == 0

	# Scaling is 1f, not the 2f default: 50 vs 20 dumps 30,
	# where scaling 2f would dump 15. The transfer is also
	# capped by the neighbour's free capacity (transferLiquid,
	# BuildingComp.java:915): 100 vs a 90/95 neighbour
	# computes (1.0 - 90/95) * 100 = 5.26 but flows only
	# the 5.0 of room; 90 vs 50 flows the full 40.
	var room_capped: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [100.0], "current": 0, "flow": null}, 100.0, {"amounts": [90.0], "capacities": [95.0], "accepts": [true]})
	var room_amounts: Array = (room_capped.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var full_fraction: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [90.0], "current": 0, "flow": null}, 100.0, {"amounts": [50.0], "capacities": [100.0], "accepts": [true]})
	var full_amounts: Array = (full_fraction.get("liquids_after", {}) as Dictionary).get("liquids", [])
	proof["dump_scales_by_one"] = is_equal_approx(float(transferred.get("dumped_amount", -1.0)), 30.0) and is_equal_approx(float(room_capped.get("dumped_amount", -1.0)), 5.0) and is_equal_approx(float(room_amounts[0]), 95.0) and is_equal_approx(float(full_fraction.get("dumped_amount", -1.0)), 40.0) and is_equal_approx(float(full_amounts[0]), 50.0)

	# No transfer when the neighbour cannot take it: a
	# fuller neighbour (ofract above fract), an equal
	# neighbour (strict less-than, ofract == fract does not
	# transfer), a neighbour that rejects the liquid
	# (acceptLiquid false), a neighbour without liquids, and
	# a neighbour that cannot be dumped to (canDumpLiquid
	# false) all dump 0 and leave the store untouched.
	var fuller: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, {"amounts": [80.0], "capacities": [100.0], "accepts": [true]})
	var fuller_amounts: Array = (fuller.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var equal: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, {"amounts": [50.0], "capacities": [100.0], "accepts": [true]})
	var rejected: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, {"amounts": [20.0], "capacities": [100.0], "accepts": [false]})
	var rejected_amounts: Array = (rejected.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var no_liquids: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, {"amounts": [20.0], "capacities": [100.0], "accepts": [true], "has_liquids": [false]})
	var no_dump: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, {"amounts": [20.0], "capacities": [100.0], "accepts": [true], "can_dump": [false]})
	proof["dump_no_transfer_when_neighbour_full"] = is_equal_approx(float(fuller.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(fuller_amounts[0]), 50.0) and is_equal_approx(float(equal.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(rejected.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(rejected_amounts[0]), 50.0) and is_equal_approx(float(no_liquids.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(no_dump.get("dumped_amount", -1.0)), 0.0)

	# doDump runs ONLY in the unlinked branch
	# (ItemBridge.java:335-337): linked, the same stores
	# dump nothing and the cursor is untouched even with a
	# stale cdump; unlinked, the same stores dump 30.
	var linked_frame: Dictionary = {"cdump": 2}
	var linked: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(linked_frame, true, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, one_neighbour)
	var linked_amounts: Array = (linked.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var unlinked_frame: Dictionary = {"cdump": 2}
	var unlinked: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(unlinked_frame, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, one_neighbour)
	proof["dump_only_when_unlinked"] = is_equal_approx(float(linked.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(linked_amounts[0]), 50.0) and int(linked.get("cursor_after", -1)) == 2 and is_equal_approx(float(unlinked.get("dumped_amount", -1.0)), 30.0) and int(unlinked.get("cursor_after", -1)) == 0

	# The early return (BuildingComp.java:889): at or below
	# 0.0001f nothing runs -- no transfer AND no cursor
	# advance (the routing never starts). Just above it,
	# 0.0002 vs an empty neighbour dumps 0.0002.
	var threshold_frame: Dictionary = {"cdump": 2}
	var threshold: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(threshold_frame, false, {"liquids": [0.0001], "current": 0, "flow": null}, 100.0, one_neighbour)
	var threshold_amounts: Array = (threshold.get("liquids_after", {}) as Dictionary).get("liquids", [])
	var dry: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(threshold_frame, false, {"liquids": [0.0], "current": 0, "flow": null}, 100.0, one_neighbour)
	var trace: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [0.0002], "current": 0, "flow": null}, 100.0, {"amounts": [0.0], "capacities": [100.0], "accepts": [true]})
	var trace_amounts: Array = (trace.get("liquids_after", {}) as Dictionary).get("liquids", [])
	proof["dump_no_transfer_below_threshold"] = is_equal_approx(float(threshold.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(threshold_amounts[0]), 0.0001) and int(threshold.get("cursor_after", -1)) == 2 and is_equal_approx(float(dry.get("dumped_amount", -1.0)), 0.0) and int(dry.get("cursor_after", -1)) == 2 and is_equal_approx(float(trace.get("dumped_amount", -1.0)), 0.0002) and is_equal_approx(float(trace_amounts[0]), 0.0)

	# incrementDump runs EVERY iteration (BuildingComp.java:
	# 894), so a complete scan advances the cursor
	# proximity.size times and returns it to its start: 2
	# neighbours from cdump 1 end at 1. A stale cursor
	# normalizes: cdump 5 over 3 neighbours ends at
	# (5 + 3) % 3 = 2, and the scan still starts at the
	# wrapped index. With no neighbours the proximity is
	# empty (incrementDump guards on prox != 0,
	# BuildingComp.java:1116-1121), so nothing dumps and
	# the cursor stays put.
	var rotated_frame: Dictionary = {"cdump": 1}
	var rotated: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(rotated_frame, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, two_neighbours)
	var stale_frame: Dictionary = {"cdump": 5}
	var stale: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(stale_frame, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, {"amounts": [0.0, 0.0, 0.0], "capacities": [100.0, 100.0, 100.0], "accepts": [true, true, true]})
	var lonely_frame: Dictionary = {"cdump": 3}
	var lonely: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(lonely_frame, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, no_neighbours)
	var lonely_amounts: Array = (lonely.get("liquids_after", {}) as Dictionary).get("liquids", [])
	proof["dump_cursor_advances"] = is_equal_approx(float(rotated.get("dumped_amount", -1.0)), 50.0) and int(rotated.get("cursor_after", -1)) == 1 and is_equal_approx(float(stale.get("dumped_amount", -1.0)), 50.0) and int(stale.get("cursor_after", -1)) == 2 and is_equal_approx(float(lonely.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(lonely_amounts[0]), 50.0) and int(lonely.get("cursor_after", -1)) == 3

	# --- Live tick: the phase-conduit is placed live and
	# unlinked (link -1, had_valid_link false), with 50
	# water in its liquids meta and one accepting neighbour
	# at 20/100 stamped as frame inputs (the N2276
	# precedent). The tick driver is called directly (as
	# the N2276 proof does), not simulate_factory, so the
	# graph update does not overwrite the stamped
	# power_status -- the write-back itself is already
	# proven by N2142. One 1/60s tick is one source tick:
	# the shouldConsume gate is closed while unlinked
	# (ItemBridge.java:495-496), so efficiency folds 0
	# (potential 0.5, the power min); warmup is 0f
	# (ItemBridge.java:337); and the unlinked branch dumps
	# 30 to the neighbour (50 -> 20) at scaling 1f, with
	# the cursor staying 0 over the single neighbour.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var liquid_bridge_cell := Vector2i(28, 21)
	var liquid_bridge := Sprite2D.new()
	game.add_child(liquid_bridge)
	game.call("record_placed_block", liquid_bridge, blocks_by_id["phase-conduit"], liquid_bridge_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the dump inputs on it).
	liquid_bridge_build_state.source_liquid_bridge_bind_frame_state(liquid_bridge, blocks_by_id["phase-conduit"])
	var liquid_bridge_frame: Dictionary = liquid_bridge.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})

	liquid_bridge_frame["power_status"] = 0.5
	liquid_bridge_frame["dump_neighbour_amounts"] = [20.0]
	liquid_bridge_frame["dump_neighbour_capacities"] = [100.0]
	liquid_bridge_frame["dump_neighbour_accepts"] = [true]
	liquid_bridge.set_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {"liquids": [50.0], "current": 0, "flow": null})
	liquid_bridge_build_state.source_liquid_bridge_tick_buildings_state(game, 1.0 / 60.0)
	liquid_bridge_frame = liquid_bridge.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
	var live_liquids: Dictionary = liquid_bridge.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var live_amounts: Array = live_liquids.get("liquids", [])
	proof["live_tick_dumps_liquid"] = is_equal_approx(float(liquid_bridge_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(liquid_bridge_frame.get("potential_efficiency", -1.0)), 0.5) and is_equal_approx(float(liquid_bridge_frame.get("warmup", -1.0)), 0.0) and bool(liquid_bridge_frame.get("had_valid_link", true)) == false and is_equal_approx(float(live_amounts[0]), 20.0) and int(liquid_bridge_frame.get("cdump", -1)) == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LiquidBridgeDoDumpProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
