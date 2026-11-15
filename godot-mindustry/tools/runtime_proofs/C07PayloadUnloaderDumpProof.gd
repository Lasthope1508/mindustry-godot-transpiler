extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_unloader_build_state := preload("res://src/game/SourcePayloadUnloaderBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _liquid_module(amounts: Array, current: int) -> Dictionary:
	return {"liquids": amounts, "current": current, "flow": null}


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

	var liquid_catalog: Dictionary = content_registry_runtime_state.source_liquid_catalog_state(game.get("content_catalog"))
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))
	var item_order: Array = ["copper", "lead"]

	# --- Pure dump (N2293): the dump rows at the END of
	# updateTile (PayloadUnloader.java:105-108),
	# UNCONDITIONAL -- outside the payload-null check (:52-54)
	# and outside the shouldExport / moveInPayload if-else
	# (:57-103), so they run even when the unloader holds no
	# payload and even when efficiency is 0. ONE pure covers
	# both rows: dumpLiquid(liquids.current())
	# (BuildingComp.java:877-878) scales by 2f with any output
	# direction (-1, :881-882); the impl (:886-908)
	# early-returns at <= 0.0001f, unlocks the liquid on
	# campaign (:891), then scans proximity from the cdump
	# cursor, incrementDump once per iteration (:894), gating
	# on other.block.hasLiquids && canDumpLiquid &&
	# other.liquids != null (:901) and transferring (fract -
	# ofract) * block.liquidCapacity / scaling when ofract <
	# fract (:905); transferLiquid (:914-921) flows min
	# (neighbour free capacity, amount) only when
	# next.acceptLiquid(self(), liquid). The liquid capacity
	# is 100f (PayloadLoader.java:41, inherited) and the
	# current liquid defaults to liquid 0 (LiquidModule.java:
	# 24), never null. Then offloadSpeed (4) x
	# dumpAccumulate() (BuildingComp.java:1048-1061): each
	# call adds delta() and fires dump(null) while the
	# accumulator is >= 1f, so dumpAccum grows by 4*delta
	# each tick. dump(null) (BuildingComp.java:1072-1114)
	# scans neighbours outer / content items inner and hands
	# 1 item to the first accepting neighbour, advancing
	# cdump once per neighbour checked. The liquid scan is a
	# full cycle (N neighbours = N incrementDump calls), so
	# the cursor only moves in the item phase (the N2286
	# cursor invariant, Java-exact). The pure returns a
	# DUPLICATE store (the N2232 precedent -- it never
	# mutates its inputs), so the amounts below are read from
	# the returned liquids_after / items_after dicts, not
	# from the input frame.

	# Transfers liquid to a neighbour: self 50/100 (fract
	# 0.5) against an empty 100-capacity neighbour (ofract 0)
	# transfers (0.5 - 0) * 100 / 2 = 25, so the store drops
	# 50 -> 25 and the cursor ends where it started (a full
	# scan over 1 neighbour advances it once: (0 + 1) % 1 =
	# 0). The flow clamp binds when the neighbour can only
	# take 5: the same 25 transfer flows 5, so the store
	# drops 50 -> 45.
	var transfer: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": _liquid_module([50.0], 0), "items": {}, "cdump": 0, "dump_accum": 0.0}, 1.0, 1.0, item_order, [0.0], [100.0], [true], [true], [], [])
	var transfer_liquids: Dictionary = transfer.get("liquids_after", {})
	var transfer_amount: float = float(liquid_module_state.source_get_state(transfer_liquids, 0).get("amount", -1.0))
	var clamped: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": _liquid_module([50.0], 0), "items": {}, "cdump": 0, "dump_accum": 0.0}, 1.0, 1.0, item_order, [0.0], [5.0], [true], [true], [], [])
	var clamped_liquids: Dictionary = clamped.get("liquids_after", {})
	var clamped_amount: float = float(liquid_module_state.source_get_state(clamped_liquids, 0).get("amount", -1.0))
	proof["dump_transfers_liquid_to_neighbour"] = is_equal_approx(float(transfer.get("dumped_liquid", -1.0)), 25.0) and is_equal_approx(transfer_amount, 25.0) and int(transfer.get("cursor_after", -1)) == 0 and is_equal_approx(float(clamped.get("dumped_liquid", -1.0)), 5.0) and is_equal_approx(clamped_amount, 45.0)

	# Scales by two: self 50/100 (fract 0.5) against a
	# neighbour at 25/100 (ofract 0.25) transfers (0.5 - 0.25)
	# * 100 / 2 = 12.5 -- with scaling 1 it would be 25, so
	# the 12.5 pins the 2f. Self 80/100 (fract 0.8) against an
	# empty neighbour transfers 0.8 * 100 / 2 = 40, so the
	# store drops 80 -> 40.
	var scaled: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": _liquid_module([50.0], 0), "items": {}, "cdump": 0, "dump_accum": 0.0}, 1.0, 1.0, item_order, [25.0], [100.0], [true], [true], [], [])
	var scaled_liquids: Dictionary = scaled.get("liquids_after", {})
	var scaled_amount: float = float(liquid_module_state.source_get_state(scaled_liquids, 0).get("amount", -1.0))
	var scaled_empty: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": _liquid_module([80.0], 0), "items": {}, "cdump": 0, "dump_accum": 0.0}, 1.0, 1.0, item_order, [0.0], [100.0], [true], [true], [], [])
	var scaled_empty_liquids: Dictionary = scaled_empty.get("liquids_after", {})
	var scaled_empty_amount: float = float(liquid_module_state.source_get_state(scaled_empty_liquids, 0).get("amount", -1.0))
	proof["dump_scales_liquid_by_two"] = is_equal_approx(float(scaled.get("dumped_liquid", -1.0)), 12.5) and is_equal_approx(scaled_amount, 37.5) and is_equal_approx(float(scaled_empty.get("dumped_liquid", -1.0)), 40.0) and is_equal_approx(scaled_empty_amount, 40.0)

	# Dumps items through the accumulator: 5 copper + 2 lead
	# with delta 1.0 and an empty accumulator fires 4
	# dump(null) attempts (one per dumpAccumulate() call, 4
	# calls per tick), each handing 1 copper to the accepting
	# neighbour (copper first in content order), so copper
	# drops 5 -> 1, lead stays 2, dumped_items is 4, and the
	# accumulator ends at 0.0. A single attempt pins the
	# cursor move: delta 0.3 grows the accumulator 0.3 / 0.6
	# / 0.9 / 1.2 across the 4 calls, firing exactly once at
	# the fourth call (accumulator 0.2 after), and the one
	# dump moves the cursor 0 -> 1 across 2 accepting
	# neighbours (the liquid phase left it at 0 -- the
	# full-cycle invariant -- so the move is the item
	# phase's alone).
	var accumulated: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": {}, "items": {"copper": 5, "lead": 2}, "cdump": 0, "dump_accum": 0.0}, 1.0, 1.0, item_order, [], [], [], [], [true], [true])
	var accumulated_items: Dictionary = accumulated.get("items_after", {})
	var single: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": {}, "items": {"copper": 5}, "cdump": 0, "dump_accum": 0.0}, 0.3, 1.0, item_order, [], [], [], [], [true, true], [true, true])
	var single_items: Dictionary = single.get("items_after", {})
	proof["dump_items_via_accumulate"] = int(accumulated.get("dumped_items", -1)) == 4 and int(accumulated_items.get("copper", -1)) == 1 and int(accumulated_items.get("lead", -1)) == 2 and is_equal_approx(float(accumulated.get("dump_accum_after", -1.0)), 0.0) and int(single.get("dumped_items", -1)) == 1 and int(single_items.get("copper", -1)) == 4 and int(single.get("cursor_after", -1)) == 1 and is_equal_approx(float(single.get("dump_accum_after", -1.0)), 0.2)

	# The accumulator grows by four delta: delta 0.2 from an
	# empty accumulator reaches 0.8 after the 4 calls with no
	# attempt fired. From 0.9 the first call crosses 1.0
	# (1.1 -> 1 attempt, accumulator 0.1) and the remaining
	# calls reach 0.7; with no neighbours the attempt fails
	# and dumps nothing. A slowed tick folds timeScale into
	# delta: source_delta 1.0 at timeScale 0.5 is delta 0.5,
	# so the 4 calls fire twice (0.5 / 1.0 / 0.5 / 1.0) and
	# the accumulator ends at 0.0.
	var grows: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": {}, "items": {}, "cdump": 0, "dump_accum": 0.0}, 0.2, 1.0, item_order, [], [], [], [], [], [])
	var grows_crossed: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": {}, "items": {}, "cdump": 0, "dump_accum": 0.9}, 0.2, 1.0, item_order, [], [], [], [], [], [])
	var grows_slowed: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": {}, "items": {}, "cdump": 0, "dump_accum": 0.0}, 1.0, 0.5, item_order, [], [], [], [], [], [])
	proof["dump_accum_grows_by_four_delta"] = is_equal_approx(float(grows.get("dump_accum_after", -1.0)), 0.8) and int(grows.get("dumped_items", -1)) == 0 and is_equal_approx(float(grows_crossed.get("dump_accum_after", -1.0)), 0.7) and int(grows_crossed.get("dumped_items", -1)) == 0 and is_equal_approx(float(grows_slowed.get("dump_accum_after", -1.0)), 0.0) and int(grows_slowed.get("dumped_items", -1)) == 0

	# No transfer when the neighbour is full: liquid self
	# 10/100 (fract 0.1) against a neighbour at 20/100
	# (ofract 0.2) transfers nothing -- the guard is ofract <
	# fract. An EQUAL neighbour takes nothing either (the
	# guard is strict): self 20/100 against 20/100 dumps 0.
	# A neighbour that refuses acceptLiquid takes nothing
	# even when emptier (the transferLiquid gate,
	# BuildingComp.java:917), and a canDumpLiquid-blocked
	# neighbour is not eligible at all (BuildingComp.java:
	# 901). Items follow the same shape: a neighbour that
	# refuses acceptItem takes nothing even with 4 attempts
	# fired (delta 1.0 -- the attempts fire and fail, so the
	# accumulator still ends at 0.0), and with no neighbours
	# at all nothing dumps either.
	var fuller: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": _liquid_module([10.0], 0), "items": {}, "cdump": 0, "dump_accum": 0.0}, 1.0, 1.0, item_order, [20.0], [100.0], [true], [true], [], [])
	var fuller_liquids: Dictionary = fuller.get("liquids_after", {})
	var fuller_amount: float = float(liquid_module_state.source_get_state(fuller_liquids, 0).get("amount", -1.0))
	var equal: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": _liquid_module([20.0], 0), "items": {}, "cdump": 0, "dump_accum": 0.0}, 1.0, 1.0, item_order, [20.0], [100.0], [true], [true], [], [])
	var equal_liquids: Dictionary = equal.get("liquids_after", {})
	var equal_amount: float = float(liquid_module_state.source_get_state(equal_liquids, 0).get("amount", -1.0))
	var refused_liquid: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": _liquid_module([50.0], 0), "items": {}, "cdump": 0, "dump_accum": 0.0}, 1.0, 1.0, item_order, [0.0], [100.0], [false], [true], [], [])
	var refused_liquid_store: Dictionary = refused_liquid.get("liquids_after", {})
	var refused_liquid_amount: float = float(liquid_module_state.source_get_state(refused_liquid_store, 0).get("amount", -1.0))
	var blocked_liquid: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": _liquid_module([50.0], 0), "items": {}, "cdump": 0, "dump_accum": 0.0}, 1.0, 1.0, item_order, [0.0], [100.0], [true], [false], [], [])
	var blocked_liquid_store: Dictionary = blocked_liquid.get("liquids_after", {})
	var blocked_liquid_amount: float = float(liquid_module_state.source_get_state(blocked_liquid_store, 0).get("amount", -1.0))
	var refused_item: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": {}, "items": {"copper": 5}, "cdump": 0, "dump_accum": 0.0}, 1.0, 1.0, item_order, [], [], [], [], [false], [true])
	var refused_item_store: Dictionary = refused_item.get("items_after", {})
	var no_neighbour_item: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": {}, "items": {"copper": 5}, "cdump": 0, "dump_accum": 0.0}, 1.0, 1.0, item_order, [], [], [], [], [], [])
	var no_neighbour_item_store: Dictionary = no_neighbour_item.get("items_after", {})
	proof["dump_no_transfer_when_neighbour_full"] = is_equal_approx(float(fuller.get("dumped_liquid", -1.0)), 0.0) and is_equal_approx(fuller_amount, 10.0) and is_equal_approx(float(equal.get("dumped_liquid", -1.0)), 0.0) and is_equal_approx(equal_amount, 20.0) and is_equal_approx(float(refused_liquid.get("dumped_liquid", -1.0)), 0.0) and is_equal_approx(refused_liquid_amount, 50.0) and is_equal_approx(float(blocked_liquid.get("dumped_liquid", -1.0)), 0.0) and is_equal_approx(blocked_liquid_amount, 50.0) and int(refused_item.get("dumped_items", -1)) == 0 and int(refused_item_store.get("copper", -1)) == 5 and is_equal_approx(float(refused_item.get("dump_accum_after", -1.0)), 0.0) and int(no_neighbour_item.get("dumped_items", -1)) == 0 and int(no_neighbour_item_store.get("copper", -1)) == 5

	# --- Live tick: a payload-unloader placed live with NO
	# payload; the tick driver is called directly (as the
	# N2163/N2209/N2232/N2279 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is
	# one source tick: the shouldConsume gate is false (no
	# payload), so efficiency folds to 0.0 -- and the dump
	# STILL runs, because the dump rows are unconditional
	# (PayloadUnloader.java:105-108, outside the payload-null
	# check and the shouldExport / moveInPayload branches).
	# The advance moves nothing (no payload), then the dump
	# drains the store the frame already holds: 50 water
	# against an accepting empty 100-capacity neighbour dumps
	# 25 (50 -> 25), and 5 copper against an accepting
	# neighbour dumps 4 (5 -> 1, one per dumpAccumulate()
	# call at delta 1.0). The cursor ends at 0 (a full liquid
	# scan over 1 neighbour plus 4 item dumps over 1
	# neighbour, each (0 + 1) % 1 = 0) and the accumulator
	# ends at 0.0. The neighbour arrays are frame inputs
	# (default []), stamped here like the N2228 targets
	# precedent.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var unloader_cell := Vector2i(28, 20)
	var unloader := Sprite2D.new()
	game.add_child(unloader)
	game.call("record_placed_block", unloader, blocks_by_id["payload-unloader"], unloader_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the dump inputs on it).
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(unloader, blocks_by_id["payload-unloader"])
	var unloader_frame: Dictionary = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})

	# Initialize the liquids meta explicitly (record_placed_block
	# already does this for hasLiquids blocks, but the proof
	# re-initializes to a known-empty store), then set the
	# amount through the shared module helper. The driver
	# refreshes frame["liquids"] from this meta each tick.
	placed_block_state.source_initialize_building_liquids_state(unloader, true, game.get("content_catalog"))
	var unloader_liquids: Dictionary = unloader.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(unloader_liquids, water_id, 50.0)

	unloader_frame["power_status"] = 1.0
	unloader_frame["items"] = {"copper": 5}
	unloader_frame["dump_neighbour_liquid_amounts"] = [0.0]
	unloader_frame["dump_neighbour_liquid_capacities"] = [100.0]
	unloader_frame["dump_neighbour_accepts_liquid"] = [true]
	unloader_frame["dump_neighbour_can_dump_liquid"] = [true]
	unloader_frame["dump_neighbour_accepts_item"] = [true]
	unloader_frame["dump_neighbour_can_dump_item"] = [true]
	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var live_liquids: Dictionary = unloader.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var live_amount: float = float(liquid_module_state.source_get_state(live_liquids, water_id).get("amount", -1.0))
	var live_items: Dictionary = unloader_frame.get("items", {})
	proof["live_tick_dumps_both"] = is_equal_approx(float(unloader_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(live_amount, 25.0) and int(live_items.get("copper", -1)) == 1 and int(unloader_frame.get("cdump", -1)) == 0 and is_equal_approx(float(unloader_frame.get("dump_accum", -1.0)), 0.0) and is_equal_approx(float(unloader_frame.get("dumped_liquid", -1.0)), 25.0) and int(unloader_frame.get("dumped_items", -1)) == 4

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadUnloaderDumpProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
