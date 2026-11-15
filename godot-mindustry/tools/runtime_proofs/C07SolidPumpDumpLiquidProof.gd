extends Node

const main_scene := preload("res://scenes/Main.tscn")
const solid_pump_build_state := preload("res://src/game/SourceSolidPumpBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	var liquid_catalog: Dictionary = content_registry_runtime_state.source_liquid_catalog_state(game.get("content_catalog"))
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))

	# --- Pure dump (N2286): dumpLiquid(result)
	# (SolidPump.java:140, unconditional, after pumpTime +=
	# warmup * edelta() at :138). dumpLiquid(Liquid)
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
	# next.acceptLiquid(self(), liquid). The result liquid is
	# water and the capacity the def constant 40f
	# (Blocks.java:2922/2925). The amounts below are set
	# through the shared liquid module helper
	# (SourceLiquidModuleState.source_set_state) over a fresh
	# module state, the same store the driver reads; each
	# case gets a fresh module because the pure dump mutates
	# the store in place (the N2220 advance precedent).

	# Transfers to a neighbour: self 20/40 (fract 0.5)
	# against an empty 40-capacity neighbour (ofract 0)
	# transfers (0.5 - 0) * 40 / 2 = 10, so the store drops
	# 20 -> 10 and the cursor ends where it started (a full
	# scan over 1 neighbour advances it once: (0 + 1) % 1 =
	# 0). The flow clamp binds when the neighbour can only
	# take 5: the same 10 transfer flows 5, so the store
	# drops 20 -> 15.
	var transfer_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(transfer_liquids, water_id, 20.0)
	var transferred: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": transfer_liquids, "cdump": 0}, water_id, 40.0, [0.0], [40.0], [true], [true])
	var transferred_amount: float = float(liquid_module_state.source_get_state(transfer_liquids, water_id).get("amount", -1.0))
	var clamp_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(clamp_liquids, water_id, 20.0)
	var clamped: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": clamp_liquids, "cdump": 0}, water_id, 40.0, [0.0], [5.0], [true], [true])
	var clamped_amount: float = float(liquid_module_state.source_get_state(clamp_liquids, water_id).get("amount", -1.0))
	proof["dump_transfers_to_neighbour"] = is_equal_approx(float(transferred.get("dumped_amount", -1.0)), 10.0) and is_equal_approx(transferred_amount, 10.0) and int(transferred.get("cursor_after", -1)) == 0 and is_equal_approx(float(clamped.get("dumped_amount", -1.0)), 5.0) and is_equal_approx(clamped_amount, 15.0)

	# Scales by two: self 20/40 (fract 0.5) against a
	# neighbour at 10/40 (ofract 0.25) transfers (0.5 - 0.25)
	# * 40 / 2 = 5 -- with scaling 1 it would be 10, so the
	# 5 pins the 2f. Self 30/40 (fract 0.75) against an empty
	# neighbour transfers 0.75 * 40 / 2 = 15, so the store
	# drops 30 -> 15.
	var scale_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(scale_liquids, water_id, 20.0)
	var scaled: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": scale_liquids, "cdump": 0}, water_id, 40.0, [10.0], [40.0], [true], [true])
	var scaled_amount: float = float(liquid_module_state.source_get_state(scale_liquids, water_id).get("amount", -1.0))
	var scale_empty_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(scale_empty_liquids, water_id, 30.0)
	var scaled_empty: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": scale_empty_liquids, "cdump": 0}, water_id, 40.0, [0.0], [40.0], [true], [true])
	var scaled_empty_amount: float = float(liquid_module_state.source_get_state(scale_empty_liquids, water_id).get("amount", -1.0))
	proof["dump_scales_by_two"] = is_equal_approx(float(scaled.get("dumped_amount", -1.0)), 5.0) and is_equal_approx(scaled_amount, 15.0) and is_equal_approx(float(scaled_empty.get("dumped_amount", -1.0)), 15.0) and is_equal_approx(scaled_empty_amount, 15.0)

	# No transfer when the neighbour is fuller: self 10/40
	# (fract 0.25) against a neighbour at 20/40 (ofract 0.5)
	# transfers nothing -- the guard is ofract < fract. An
	# EQUAL neighbour takes nothing either (the guard is
	# strict): self 20/40 against 20/40 dumps 0. A neighbour
	# that refuses acceptLiquid takes nothing even when
	# emptier (the transferLiquid gate,
	# BuildingComp.java:917), and a canDumpLiquid-blocked
	# neighbour is not eligible at all (BuildingComp.java:901).
	var fuller_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(fuller_liquids, water_id, 10.0)
	var fuller: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": fuller_liquids, "cdump": 0}, water_id, 40.0, [20.0], [40.0], [true], [true])
	var fuller_amount: float = float(liquid_module_state.source_get_state(fuller_liquids, water_id).get("amount", -1.0))
	var equal_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(equal_liquids, water_id, 20.0)
	var equal: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": equal_liquids, "cdump": 0}, water_id, 40.0, [20.0], [40.0], [true], [true])
	var equal_amount: float = float(liquid_module_state.source_get_state(equal_liquids, water_id).get("amount", -1.0))
	var refused_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(refused_liquids, water_id, 20.0)
	var refused: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": refused_liquids, "cdump": 0}, water_id, 40.0, [0.0], [40.0], [false], [true])
	var refused_amount: float = float(liquid_module_state.source_get_state(refused_liquids, water_id).get("amount", -1.0))
	var blocked_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(blocked_liquids, water_id, 20.0)
	var blocked: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": blocked_liquids, "cdump": 0}, water_id, 40.0, [0.0], [40.0], [true], [false])
	var blocked_amount: float = float(liquid_module_state.source_get_state(blocked_liquids, water_id).get("amount", -1.0))
	proof["dump_no_transfer_when_neighbour_full"] = is_equal_approx(float(fuller.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(fuller_amount, 10.0) and is_equal_approx(float(equal.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(equal_amount, 20.0) and is_equal_approx(float(refused.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(refused_amount, 20.0) and is_equal_approx(float(blocked.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(blocked_amount, 20.0)

	# Runs when efficiency is zero: the dump is
	# unconditional (SolidPump.java:140, no efficiency gate),
	# so a frame at efficiency 0.0 dumps the same 10 as a
	# frame at efficiency 1.0 -- unlike the pump branch
	# (SolidPump.java:126), which gates on efficiency > 0.
	var zero_eff_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(zero_eff_liquids, water_id, 20.0)
	var zero_eff: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"efficiency": 0.0, "liquids": zero_eff_liquids, "cdump": 0}, water_id, 40.0, [0.0], [40.0], [true], [true])
	var zero_eff_amount: float = float(liquid_module_state.source_get_state(zero_eff_liquids, water_id).get("amount", -1.0))
	var full_eff_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(full_eff_liquids, water_id, 20.0)
	var full_eff: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"efficiency": 1.0, "liquids": full_eff_liquids, "cdump": 0}, water_id, 40.0, [0.0], [40.0], [true], [true])
	proof["dump_runs_when_efficiency_zero"] = is_equal_approx(float(zero_eff.get("dumped_amount", -1.0)), 10.0) and is_equal_approx(zero_eff_amount, 10.0) and is_equal_approx(float(full_eff.get("dumped_amount", -1.0)), 10.0)

	# No transfer below the threshold: at exactly 0.0001f the
	# early return fires (BuildingComp.java:889, <= 0.0001f),
	# so nothing dumps, the store keeps 0.0001, and the cursor
	# stays 2 -- the scan never runs. An empty store dumps
	# nothing the same way. Just above the threshold (0.0002)
	# the dump runs: fract 0.000005 transfers 0.0001, so the
	# store drops 0.0002 -> 0.0001.
	var threshold_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(threshold_liquids, water_id, 0.0001)
	var threshold: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": threshold_liquids, "cdump": 2}, water_id, 40.0, [0.0], [40.0], [true], [true])
	var threshold_amount: float = float(liquid_module_state.source_get_state(threshold_liquids, water_id).get("amount", -1.0))
	var empty_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	var emptied: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": empty_liquids, "cdump": 0}, water_id, 40.0, [0.0], [40.0], [true], [true])
	var above_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(above_liquids, water_id, 0.0002)
	var above: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": above_liquids, "cdump": 0}, water_id, 40.0, [0.0], [40.0], [true], [true])
	var above_amount: float = float(liquid_module_state.source_get_state(above_liquids, water_id).get("amount", -1.0))
	proof["dump_no_transfer_below_threshold"] = is_equal_approx(float(threshold.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(threshold_amount, 0.0001) and int(threshold.get("cursor_after", -1)) == 2 and is_equal_approx(float(emptied.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(float(above.get("dumped_amount", -1.0)), 0.0001) and is_equal_approx(above_amount, 0.0001)

	# --- Live tick: a water-extractor placed live; the tick
	# driver is called directly (as the N2150/N2206 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is one
	# source tick: efficiency folds the power min 0.5, the
	# advance pumps nothing (no fraction inputs, so maxPump
	# is 0), and the dump runs AFTER the advance (Java order:
	# SolidPump.java:140 after :138), so with 20 water and an
	# accepting empty neighbour the tick dumps 10 (20 -> 10)
	# and the cursor ends at 0. The neighbour arrays are frame
	# inputs (default []), stamped here like the N2228 targets
	# precedent.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var extractor_cell := Vector2i(28, 20)
	var extractor := Sprite2D.new()
	game.add_child(extractor)
	game.call("record_placed_block", extractor, blocks_by_id["water-extractor"], extractor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the dump inputs on it).
	solid_pump_build_state.source_solid_pump_bind_frame_state(extractor, blocks_by_id["water-extractor"])
	var extractor_frame: Dictionary = extractor.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})

	# Initialize the liquids meta explicitly (record_placed_block
	# already does this for hasLiquids blocks, but the proof
	# re-initializes to a known-empty store), then set the
	# amount through the shared module helper. The driver
	# refreshes frame["liquids"] from this meta each tick.
	placed_block_state.source_initialize_building_liquids_state(extractor, true, game.get("content_catalog"))
	var extractor_liquids: Dictionary = extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_liquids, water_id, 20.0)

	extractor_frame["power_status"] = 0.5
	extractor_frame["dump_neighbour_liquid_amounts"] = [0.0]
	extractor_frame["dump_neighbour_liquid_capacities"] = [40.0]
	extractor_frame["dump_neighbour_accepts_liquid"] = [true]
	extractor_frame["dump_neighbour_can_dump_liquid"] = [true]
	solid_pump_build_state.source_solid_pump_tick_buildings_state(game, 1.0 / 60.0)
	extractor_frame = extractor.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})
	var live_liquids: Dictionary = extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var live_amount: float = float(liquid_module_state.source_get_state(live_liquids, water_id).get("amount", -1.0))
	proof["live_tick_dumps_liquid"] = is_equal_approx(float(extractor_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(live_amount, 10.0) and int(extractor_frame.get("cdump", -1)) == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SolidPumpDumpLiquidProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
