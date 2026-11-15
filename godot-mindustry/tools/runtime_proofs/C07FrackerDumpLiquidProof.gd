extends Node

const main_scene := preload("res://scenes/Main.tscn")
const fracker_build_state := preload("res://src/game/SourceFrackerBuildState.gd")
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

	# The liquid catalog resolves the result liquid's id
	# (the N2207 precedent): the pure dump takes the catalog
	# id, the driver resolves it from liquid_id_by_name with
	# the def constant "oil" (Blocks.java:2966). The amounts
	# below are set through the shared liquid module helper
	# (SourceLiquidModuleState.source_set_state) over a fresh
	# module state, the same store the driver reads. The
	# capacity is the def constant 40f (Blocks.java:2971).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var oil_id: int = int(liquid_catalog["liquid_id_by_name"].get("oil", -1))
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))
	var content_liquid_ids: Array = liquid_catalog["content_liquid_ids"]

	# --- Pure dump (N2284): BOTH updateTile branches end in
	# dumpLiquid(result) -- the if-branch through
	# super.updateTile() (Fracker.java:37), whose
	# SolidPump.updateTile ends in dumpLiquid(result)
	# (SolidPump.java:140), and the else-branch directly
	# (Fracker.java:42). dumpLiquid(Liquid) is the 2f
	# overload (BuildingComp.java:877-878): each eligible
	# neighbour takes (fract - ofract) * block.liquidCapacity
	# / scaling (BuildingComp.java:905), gated on the
	# <= 0.0001f threshold (:889), the routing gate (:901)
	# and acceptLiquid (:917). The neighbour entries are
	# frame inputs (default []): each entry carries amount /
	# capacity / accepts / has_liquids / can_dump /
	# liquids_present / destination_present / relative_to.
	# An empty neighbour below is a building with no oil, a
	# 40f capacity, that accepts oil and passes every gate.
	var empty_neighbour: Dictionary = {"amount": 0.0, "capacity": 40.0, "accepts": true, "has_liquids": true, "can_dump": true, "liquids_present": true, "destination_present": true, "relative_to": 0}

	# Transfers to a neighbour: 20 oil in a 40f store
	# (fract 0.5) against an empty 40f neighbour (ofract 0)
	# transfers (0.5 - 0.0) * 40 / 2 = 10, so the store
	# drops to 10 and the cursor advances 0 -> 1 (one
	# proximity iteration, incrementDump every iteration).
	# The pure never mutates its inputs: the original store
	# still holds 20 after the call.
	var transfer_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(transfer_liquids, oil_id, 20.0)
	var transfer_frame: Dictionary = {"liquids": transfer_liquids, "cdump": 0}
	var transferred: Dictionary = fracker_build_state.source_fracker_dump_liquid_state(transfer_frame, oil_id, 40.0, [empty_neighbour])
	var transferred_liquids: Dictionary = transferred.get("liquids_after", {})
	var transferred_oil: float = float(liquid_module_state.source_get_state(transferred_liquids, oil_id).get("amount", -1.0))
	var input_oil: float = float(liquid_module_state.source_get_state(transfer_liquids, oil_id).get("amount", -1.0))
	proof["dump_transfers_to_neighbour"] = is_equal_approx(float(transferred.get("dumped_amount", -1.0)), 10.0) and is_equal_approx(transferred_oil, 10.0) and int(transferred.get("cursor_after", -1)) == 1 and is_equal_approx(input_oil, 20.0)

	# Scales by two: 30 oil (fract 0.75) against a neighbour
	# holding 10/40 (ofract 0.25) transfers (0.75 - 0.25) *
	# 40 / 2 = 10 -- HALF the fraction gap times the
	# capacity, the 2f overload default. With a 1f scaling
	# the transfer would be 20.
	var scaled_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(scaled_liquids, oil_id, 30.0)
	var scaled_neighbour: Dictionary = {"amount": 10.0, "capacity": 40.0, "accepts": true, "has_liquids": true, "can_dump": true, "liquids_present": true, "destination_present": true, "relative_to": 0}
	var scaled: Dictionary = fracker_build_state.source_fracker_dump_liquid_state({"liquids": scaled_liquids, "cdump": 0}, oil_id, 40.0, [scaled_neighbour])
	var scaled_liquids_after: Dictionary = scaled.get("liquids_after", {})
	var scaled_oil: float = float(liquid_module_state.source_get_state(scaled_liquids_after, oil_id).get("amount", -1.0))
	proof["dump_scales_by_two"] = is_equal_approx(float(scaled.get("dumped_amount", -1.0)), 10.0) and is_equal_approx(scaled_oil, 20.0) and int(scaled.get("cursor_after", -1)) == 1

	# No transfer when the neighbour is fuller: 20 oil
	# (fract 0.5) against a neighbour holding 30/40 (ofract
	# 0.75) transfers nothing (ofract < fract fails), the
	# store stays 20 -- but the cursor STILL advances 0 -> 1,
	# because incrementDump runs every iteration, before any
	# gate. A neighbour that refuses (accepts false) takes
	# nothing either, with the cursor advancing the same way.
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, oil_id, 20.0)
	var full_neighbour: Dictionary = {"amount": 30.0, "capacity": 40.0, "accepts": true, "has_liquids": true, "can_dump": true, "liquids_present": true, "destination_present": true, "relative_to": 0}
	var full: Dictionary = fracker_build_state.source_fracker_dump_liquid_state({"liquids": full_liquids, "cdump": 0}, oil_id, 40.0, [full_neighbour])
	var full_liquids_after: Dictionary = full.get("liquids_after", {})
	var full_oil: float = float(liquid_module_state.source_get_state(full_liquids_after, oil_id).get("amount", -1.0))
	var refusing_neighbour: Dictionary = {"amount": 0.0, "capacity": 40.0, "accepts": false, "has_liquids": true, "can_dump": true, "liquids_present": true, "destination_present": true, "relative_to": 0}
	var refused: Dictionary = fracker_build_state.source_fracker_dump_liquid_state({"liquids": full_liquids, "cdump": 0}, oil_id, 40.0, [refusing_neighbour])
	var refused_liquids_after: Dictionary = refused.get("liquids_after", {})
	var refused_oil: float = float(liquid_module_state.source_get_state(refused_liquids_after, oil_id).get("amount", -1.0))
	proof["dump_no_transfer_when_neighbour_full"] = is_equal_approx(float(full.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(full_oil, 20.0) and int(full.get("cursor_after", -1)) == 1 and is_equal_approx(float(refused.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(refused_oil, 20.0) and int(refused.get("cursor_after", -1)) == 1

	# No transfer below the threshold: 0.0001f oil hits the
	# early return (BuildingComp.java:889), so nothing dumps
	# and the cursor stays 0 -- the early return runs BEFORE
	# the loop. An empty store behaves the same, and with no
	# neighbours at all (default []) a full 20-oil store
	# keeps its oil with the cursor untouched (the Java
	# proximity.size == 0 outcome).
	var threshold_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(threshold_liquids, oil_id, 0.0001)
	var threshold: Dictionary = fracker_build_state.source_fracker_dump_liquid_state({"liquids": threshold_liquids, "cdump": 0}, oil_id, 40.0, [empty_neighbour])
	var threshold_liquids_after: Dictionary = threshold.get("liquids_after", {})
	var threshold_oil: float = float(liquid_module_state.source_get_state(threshold_liquids_after, oil_id).get("amount", -1.0))
	var empty_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	var emptied: Dictionary = fracker_build_state.source_fracker_dump_liquid_state({"liquids": empty_liquids, "cdump": 0}, oil_id, 40.0, [empty_neighbour])
	var alone_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(alone_liquids, oil_id, 20.0)
	var alone: Dictionary = fracker_build_state.source_fracker_dump_liquid_state({"liquids": alone_liquids, "cdump": 0}, oil_id, 40.0, [])
	var alone_liquids_after: Dictionary = alone.get("liquids_after", {})
	var alone_oil: float = float(liquid_module_state.source_get_state(alone_liquids_after, oil_id).get("amount", -1.0))
	proof["dump_no_transfer_below_threshold"] = is_equal_approx(float(threshold.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(threshold_oil, 0.0001) and int(threshold.get("cursor_after", -1)) == 0 and is_equal_approx(float(emptied.get("dumped_amount", -1.0)), 0.0) and int(emptied.get("cursor_after", -1)) == 0 and is_equal_approx(float(alone.get("dumped_amount", -1.0)), 0.0) and is_equal_approx(alone_oil, 20.0) and int(alone.get("cursor_after", -1)) == 0

	# --- Live tick: two oil-extractors placed live; the tick
	# driver is called directly (as the N2153/N2207 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. Extractor A runs
	# the if-branch (full power, water + sand seeded so the
	# folded efficiency is 1.0; the fraction inputs are 0,
	# so the pump adds nothing and the dump sees the seeded
	# 20 oil): the dump runs after the pump, 20 -> 10.
	# Extractor B runs the else-branch (no power, efficiency
	# 0.0): warmup decays, lastPump zeroes, and the dump
	# still runs, 20 -> 10. Both frames carry one empty
	# neighbour as a frame input, and both cursors advance
	# 0 -> 1. The dump replaces the liquids dict, so the
	# proof re-reads the sprite meta after the tick (the
	# pre-tick reference is stale once set_meta installs the
	# fresh dict). One tick call ticks both extractors; both
	# live keys read after that single call.
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var extractor_a_cell := Vector2i(28, 20)
	var extractor_a := Sprite2D.new()
	game.add_child(extractor_a)
	game.call("record_placed_block", extractor_a, blocks_by_id["oil-extractor"], extractor_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the dump inputs on it).
	fracker_build_state.source_fracker_bind_frame_state(extractor_a, blocks_by_id["oil-extractor"])
	var extractor_a_frame: Dictionary = extractor_a.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var extractor_a_liquids: Dictionary = extractor_a.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_a_liquids, oil_id, 20.0)
	liquid_module_state.source_set_state(extractor_a_liquids, water_id, 0.3)

	var extractor_b_cell := Vector2i(20, 10)
	var extractor_b := Sprite2D.new()
	game.add_child(extractor_b)
	game.call("record_placed_block", extractor_b, blocks_by_id["oil-extractor"], extractor_b_cell)
	fracker_build_state.source_fracker_bind_frame_state(extractor_b, blocks_by_id["oil-extractor"])
	var extractor_b_frame: Dictionary = extractor_b.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var extractor_b_liquids: Dictionary = extractor_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_b_liquids, oil_id, 20.0)

	# N2268: the required sand row folds 0.0 on an empty
	# frame, so seed 1 sand on extractor A before ticking --
	# otherwise its live efficiency reads 0 and it runs the
	# else-branch instead of the if-branch. Extractor B
	# needs no sand: it is meant to run at efficiency 0.
	extractor_a_frame["items"] = {"sand": 1}
	extractor_a_frame["dump_liquid_neighbours"] = [empty_neighbour]
	extractor_b_frame["dump_liquid_neighbours"] = [empty_neighbour]
	extractor_a_frame["power_status"] = 1.0
	extractor_b_frame["power_status"] = 0.0
	fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)
	extractor_a_frame = extractor_a.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	extractor_b_frame = extractor_b.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	extractor_a_liquids = extractor_a.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	extractor_b_liquids = extractor_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var extractor_a_oil: float = float(liquid_module_state.source_get_state(extractor_a_liquids, oil_id).get("amount", -1.0))
	var extractor_b_oil: float = float(liquid_module_state.source_get_state(extractor_b_liquids, oil_id).get("amount", -1.0))
	proof["live_tick_dumps_liquid"] = is_equal_approx(float(extractor_a_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(extractor_a_oil, 10.0) and int(extractor_a_frame.get("cdump", -1)) == 1
	proof["dump_runs_in_both_branches"] = is_equal_approx(extractor_a_oil, 10.0) and is_equal_approx(float(extractor_b_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(extractor_b_oil, 10.0) and int(extractor_b_frame.get("cdump", -1)) == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07FrackerDumpLiquidProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
