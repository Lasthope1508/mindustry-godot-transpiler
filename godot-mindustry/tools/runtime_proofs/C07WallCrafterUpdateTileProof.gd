extends Node

const main_scene := preload("res://scenes/Main.tscn")
const wall_crafter_build_state := preload("res://src/game/SourceWallCrafterBuildState.gd")
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

	# --- Pure advance (N2223): WallCrafterBuild.updateTile()
	# (WallCrafter.java:187-223): warmup approachDelta toward
	# num(efficiency > 0) at 1f/40f (WallCrafter.java:193), eff =
	# getEfficiency * lerp(1, 1.6, hasLiquidBooster ?
	# optionalEfficiency : 0) * (itemValid ? 1.6 : 1)
	# (WallCrafter.java:196-205), lastEfficiency = eff *
	# timeScale * efficiency (WallCrafter.java:211), time +=
	# edelta() * eff gated on cons with the offload + time %=
	# drillTime reset (WallCrafter.java:213-215), totalTime +=
	# edelta() * warmup * (eff <= 0 ? 0 : 1)
	# (WallCrafter.java:218). source_delta is Time.delta in
	# ticks (1.0 = one tick). The live getEfficiency scan has
	# no fill yet, so the pure advance takes the base
	# efficiency as the frame input efficiency_factor; the
	# drillTime / output / capacity arrive as parameters
	# (110f / sand / 10 for the cliff-crusher, 48f / sand / 20
	# for the large-cliff-crusher, Blocks.java:3006/:3020/
	# :3009/:3023/:3031).
	var warmup_frame: Dictionary = {"efficiency": 1.0, "warmup": 0.0, "time": 0.0, "total_time": 0.0, "items": {}}
	for iteration in range(40):
		var advanced: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state(warmup_frame, 1.0, 1.0, 110.0, "sand", 10)
		warmup_frame["warmup"] = advanced["warmup"]
		warmup_frame["time"] = advanced["time"]
		warmup_frame["total_time"] = advanced["total_time"]
		warmup_frame["items"] = advanced["items"]
	var decay_frame: Dictionary = {"efficiency": 0.0, "warmup": 1.0, "time": 0.0, "total_time": 0.0, "items": {}}
	for iteration in range(40):
		var decayed: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state(decay_frame, 1.0, 1.0, 110.0, "sand", 10)
		decay_frame["warmup"] = decayed["warmup"]
		decay_frame["time"] = decayed["time"]
		decay_frame["total_time"] = decayed["total_time"]
		decay_frame["items"] = decayed["items"]
	proof["warmup_approaches_one_when_efficient"] = is_equal_approx(float(warmup_frame.get("warmup", -1.0)), 1.0) and is_equal_approx(float(decay_frame.get("warmup", -1.0)), 0.0)

	var time_base: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 0.5, "efficiency_factor": 2.0, "time": 0.0, "items": {}}, 1.0, 1.0, 110.0, "sand", 10)
	var time_scaled: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 0.5, "efficiency_factor": 2.0, "time": 0.0, "items": {}}, 1.0, 2.0, 110.0, "sand", 10)
	var time_item_boost: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 0.5, "efficiency_factor": 2.0, "item_valid": true, "time": 0.0, "items": {}}, 1.0, 1.0, 110.0, "sand", 10)
	var time_liquid_boost: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 0.5, "efficiency_factor": 2.0, "has_liquid_booster": true, "optional_efficiency": 0.5, "time": 0.0, "items": {}}, 1.0, 1.0, 110.0, "sand", 10)
	var time_liquid_flag_off: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 0.5, "efficiency_factor": 2.0, "optional_efficiency": 1.0, "time": 0.0, "items": {}}, 1.0, 1.0, 110.0, "sand", 10)
	proof["time_advances_with_eff_and_edelta"] = is_equal_approx(float(time_base.get("time", -1.0)), 1.0) and is_equal_approx(float(time_base.get("eff", -1.0)), 2.0) and is_equal_approx(float(time_scaled.get("time", -1.0)), 2.0) and is_equal_approx(float(time_item_boost.get("time", -1.0)), 1.6) and is_equal_approx(float(time_item_boost.get("eff", -1.0)), 3.2) and is_equal_approx(float(time_liquid_boost.get("time", -1.0)), 1.3) and is_equal_approx(float(time_liquid_boost.get("eff", -1.0)), 2.6) and is_equal_approx(float(time_liquid_flag_off.get("time", -1.0)), 1.0) and is_equal_approx(float(time_liquid_flag_off.get("eff", -1.0)), 2.0)

	var offload_advanced: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 1.0, "efficiency_factor": 1.0, "time": 47.0, "items": {}}, 1.0, 1.0, 48.0, "sand", 20)
	var offloaded_items: Dictionary = offload_advanced.get("items", {})
	var before_advanced: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 1.0, "efficiency_factor": 1.0, "time": 10.0, "items": {}}, 1.0, 1.0, 48.0, "sand", 20)
	var before_items: Dictionary = before_advanced.get("items", {})
	var full_advanced: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 1.0, "efficiency_factor": 1.0, "time": 47.0, "items": {"sand": 20}}, 1.0, 1.0, 48.0, "sand", 20)
	var full_items: Dictionary = full_advanced.get("items", {})
	proof["offload_at_drill_time"] = is_equal_approx(float(offload_advanced.get("time", -1.0)), 0.0) and bool(offload_advanced.get("offloaded", false)) and int(offloaded_items.get("sand", -1)) == 1 and is_equal_approx(float(before_advanced.get("time", -1.0)), 11.0) and bool(before_advanced.get("offloaded", true)) == false and int(before_items.get("sand", 0)) == 0 and is_equal_approx(float(full_advanced.get("time", -1.0)), 47.0) and bool(full_advanced.get("offloaded", true)) == false and int(full_items.get("sand", -1)) == 20

	var last_full: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 0.5, "efficiency_factor": 2.0, "items": {}}, 1.0, 2.0, 110.0, "sand", 10)
	var last_no_power: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 0.0, "efficiency_factor": 2.0, "items": {}}, 1.0, 1.0, 110.0, "sand", 10)
	var last_no_eff: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 1.0, "efficiency_factor": 0.0, "items": {}}, 1.0, 1.0, 110.0, "sand", 10)
	proof["last_efficiency_folds_eff_timescale"] = is_equal_approx(float(last_full.get("last_efficiency", -1.0)), 2.0) and is_equal_approx(float(last_no_power.get("last_efficiency", -1.0)), 0.0) and is_equal_approx(float(last_no_eff.get("last_efficiency", -1.0)), 0.0)

	var total_full: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 1.0, "efficiency_factor": 1.0, "warmup": 1.0, "total_time": 0.0, "items": {}}, 1.0, 1.0, 110.0, "sand", 10)
	var total_no_eff: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 1.0, "efficiency_factor": 0.0, "warmup": 1.0, "total_time": 0.0, "items": {}}, 1.0, 1.0, 110.0, "sand", 10)
	var total_cold: Dictionary = wall_crafter_build_state.source_wall_crafter_update_tile_advance_state({"efficiency": 1.0, "efficiency_factor": 1.0, "warmup": 0.0, "total_time": 0.0, "items": {}}, 1.0, 1.0, 110.0, "sand", 10)
	proof["total_time_advances_with_warmup"] = is_equal_approx(float(total_full.get("total_time", -1.0)), 1.0) and is_equal_approx(float(total_no_eff.get("total_time", -1.0)), 0.0) and is_equal_approx(float(total_cold.get("total_time", -1.0)), 0.025)

	# --- Live tick: a cliff-crusher placed live; the tick driver
	# is called directly (as the N2170/N2201 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The tick stamps
	# efficiency_factor live since N2301 (from
	# frame["wall_edge_tiles"], WallCrafter.java:141-180),
	# so the proof seeds the edge tiles instead: two solid
	# tiles at 0.5 each (the size-2 cliff-crusher facing
	# edge, Blocks.java:3007) sum to 1.0, and seeding
	# efficiency_factor directly would be overwritten by
	# the stamp before the advance reads it. One 1/60s tick
	# is one source tick: efficiency
	# folds the power min 0.5, warmup rises 1/40 toward 1,
	# eff is 1.0 (no liquid/item booster live), time rises
	# 0.5 * 1.0 * 1.0 * 1.0 = 0.5, lastEfficiency is 0.5, and
	# totalTime rises 0.5 * 0.025 * 1 = 0.0125.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var crusher_cell := Vector2i(28, 21)
	var crusher := Sprite2D.new()
	game.add_child(crusher)
	game.call("record_placed_block", crusher, blocks_by_id["cliff-crusher"], crusher_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status,
	# the edge tiles and items on it).
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(crusher, blocks_by_id["cliff-crusher"])
	var crusher_frame: Dictionary = crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})

	crusher_frame["items"] = {}
	crusher_frame["power_status"] = 0.5
	crusher_frame["wall_edge_tiles"] = [
		{"solid": true, "attribute_value": 0.5},
		{"solid": true, "attribute_value": 0.5},
	]
	wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)
	crusher_frame = crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	proof["live_tick_advances_warmup_and_time"] = is_equal_approx(float(crusher_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(crusher_frame.get("warmup", -1.0)), 1.0 / 40.0) and is_equal_approx(float(crusher_frame.get("eff", -1.0)), 1.0) and is_equal_approx(float(crusher_frame.get("time", -1.0)), 0.5) and is_equal_approx(float(crusher_frame.get("last_efficiency", -1.0)), 0.5) and is_equal_approx(float(crusher_frame.get("total_time", -1.0)), 0.0125) and bool(crusher_frame.get("offloaded", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WallCrafterUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
