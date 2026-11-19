extends Node

const main_scene := preload("res://scenes/Main.tscn")
const regen_projector_build_state := preload("res://src/game/SourceRegenProjectorBuildState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
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

	# --- Pure advance (N2228): RegenProjectorBuild.updateTile()
	# (RegenProjector.java:122-179): lastChange refresh on
	# tileChanges (RegenProjector.java:123-125), warmup
	# approachDelta toward (didRegen ? 1 : 0) at 1f/70f
	# (RegenProjector.java:129), totalTime += warmup *
	# Time.delta (RegenProjector.java:130), the didRegen /
	# anyTargets reset (RegenProjector.java:131-132), the
	# suppression early return (RegenProjector.java:135-137),
	# anyTargets = targets.contains(damaged)
	# (RegenProjector.java:139), the efficiency gate
	# (RegenProjector.java:141), the optionalTimer advance +
	# consume threshold + reset (RegenProjector.java:142-144),
	# the healAmount fold (RegenProjector.java:147) and the
	# mendMap accumulation (RegenProjector.java:150-158).
	# source_delta is Time.delta in ticks (1.0 = one tick).
	# The live updateTargets query has no fill yet, so the
	# pure advance takes targets as the frame input (each
	# entry: pos, block_health, health, damaged,
	# heal_suppressed); heal_suppressed (default false) and
	# tile_changes (default 1, World.java:35) are frame
	# inputs too. consume() is live since N2260 (the tick
	# removes 1 phaseFabric from the frame when the advance
	# reports `consumed`); the optionalTimer reset is modeled
	# and the tick where consume() fires is reported as
	# `consumed`.
	# The mendMap flush is live since N2325 as the pure
	# heal_applications result: a fresh frame (last_update_frame
	# -1, update_id 0) flushes, so the accumulation calls below
	# seed last_update_frame 0 / update_id 0 to hold the flush
	# and assert the accumulated map.
	var damaged_target: Dictionary = {"pos": 7, "block_health": 1000.0, "health": 500.0, "damaged": true, "heal_suppressed": false}
	var healthy_target: Dictionary = {"pos": 8, "block_health": 100.0, "health": 100.0, "damaged": false, "heal_suppressed": false}
	var with_damaged: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "targets": [damaged_target, healthy_target]}, 1.0, 1.0)
	var all_healthy: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "targets": [healthy_target]}, 1.0, 1.0)
	var no_targets: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "targets": []}, 1.0, 1.0)
	var refresh_unchanged: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"last_change": 3, "tile_changes": 3}, 1.0, 1.0)
	proof["any_targets_folds_damaged_targets"] = bool(with_damaged.get("any_targets", false)) and bool(with_damaged.get("did_regen", false)) and int(with_damaged.get("last_change", -99)) == 1 and bool(all_healthy.get("any_targets", true)) == false and bool(all_healthy.get("did_regen", true)) == false and bool(no_targets.get("any_targets", true)) == false and int(refresh_unchanged.get("last_change", -99)) == 3

	var mend_base: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.0, "targets": [damaged_target], "last_update_frame": 0, "update_id": 0}, 1.0, 1.0)
	var mend_base_map: Dictionary = mend_base.get("mend_map", {})
	var mend_again: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.0, "targets": [damaged_target], "mend_map": {7: 2.0 / 3.0}, "last_update_frame": 0, "update_id": 0}, 1.0, 1.0)
	var mend_again_map: Dictionary = mend_again.get("mend_map", {})
	var mend_boosted: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 1.0, "targets": [damaged_target], "last_update_frame": 0, "update_id": 0}, 1.0, 1.0)
	var mend_boosted_map: Dictionary = mend_boosted.get("mend_map", {})
	var capped_target: Dictionary = {"pos": 9, "block_health": 1000.0, "health": 999.5, "damaged": true, "heal_suppressed": false}
	var mend_capped: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.0, "targets": [capped_target], "last_update_frame": 0, "update_id": 0}, 1.0, 1.0)
	var mend_capped_map: Dictionary = mend_capped.get("mend_map", {})
	var suppressed_target: Dictionary = {"pos": 10, "block_health": 1000.0, "health": 500.0, "damaged": true, "heal_suppressed": true}
	var mend_suppressed: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.0, "targets": [suppressed_target], "last_update_frame": 0, "update_id": 0}, 1.0, 1.0)
	var mend_suppressed_map: Dictionary = mend_suppressed.get("mend_map", {})
	var mend_scaled: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.0, "targets": [damaged_target], "last_update_frame": 0, "update_id": 0}, 1.0, 2.0)
	var mend_scaled_map: Dictionary = mend_scaled.get("mend_map", {})
	var mend_no_power: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 0.0, "targets": [damaged_target], "last_update_frame": 0, "update_id": 0}, 1.0, 1.0)
	var mend_no_power_map: Dictionary = mend_no_power.get("mend_map", {})
	proof["mend_map_accumulates_heal_amount"] = is_equal_approx(float(mend_base.get("heal_amount", -1.0)), 4.0 / 60.0) and is_equal_approx(float(mend_base_map.get(7, -1.0)), 2.0 / 3.0) and is_equal_approx(float(mend_again_map.get(7, -1.0)), 2.0 / 3.0) and is_equal_approx(float(mend_boosted.get("heal_amount", -1.0)), 8.0 / 60.0) and is_equal_approx(float(mend_boosted_map.get(7, -1.0)), 4.0 / 3.0) and is_equal_approx(float(mend_capped_map.get(9, -1.0)), 0.5) and bool(mend_suppressed.get("any_targets", false)) and bool(mend_suppressed.get("did_regen", true)) == false and mend_suppressed_map.is_empty() and is_equal_approx(float(mend_scaled_map.get(7, -1.0)), 4.0 / 3.0) and mend_no_power_map.is_empty() and is_equal_approx(float(mend_no_power.get("heal_amount", -1.0)), 0.0)

	var warmup_frame: Dictionary = {"efficiency": 1.0, "warmup": 0.0, "total_time": 0.0, "did_regen": true}
	for iteration in range(70):
		var advanced: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state(warmup_frame, 1.0, 1.0)
		warmup_frame["warmup"] = advanced["warmup"]
		warmup_frame["total_time"] = advanced["total_time"]
		warmup_frame["did_regen"] = true
	var decay_frame: Dictionary = {"efficiency": 1.0, "warmup": 1.0, "total_time": 0.0, "did_regen": false}
	for iteration in range(70):
		var decayed: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state(decay_frame, 1.0, 1.0)
		decay_frame["warmup"] = decayed["warmup"]
		decay_frame["total_time"] = decayed["total_time"]
		decay_frame["did_regen"] = false
	var single_step: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"warmup": 0.5, "total_time": 10.0, "did_regen": true}, 1.0, 1.0)
	proof["warmup_approaches_one_when_regen"] = is_equal_approx(float(warmup_frame.get("warmup", -1.0)), 1.0) and is_equal_approx(float(warmup_frame.get("total_time", -1.0)), 35.5) and is_equal_approx(float(decay_frame.get("warmup", -1.0)), 0.0) and is_equal_approx(float(decay_frame.get("total_time", -1.0)), 34.5) and is_equal_approx(float(single_step.get("warmup", -1.0)), 0.5 + 1.0 / 70.0) and is_equal_approx(float(single_step.get("total_time", -1.0)), 10.0 + 0.5 + 1.0 / 70.0)

	var timer_base: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.5, "optional_timer": 100.0}, 1.0, 1.0)
	var timer_reset: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.5, "optional_timer": 479.75}, 1.0, 1.0)
	var timer_exact: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.5, "optional_timer": 479.5}, 1.0, 1.0)
	var timer_no_power: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 0.0, "optional_efficiency": 0.5, "optional_timer": 100.0}, 1.0, 1.0)
	var timer_no_booster: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.0, "optional_timer": 100.0}, 1.0, 1.0)
	var timer_scaled: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.5, "optional_timer": 0.0}, 1.0, 2.0)
	proof["optional_timer_advances_and_resets"] = is_equal_approx(float(timer_base.get("optional_timer", -1.0)), 100.5) and bool(timer_base.get("consumed", true)) == false and is_equal_approx(float(timer_reset.get("optional_timer", -1.0)), 0.0) and bool(timer_reset.get("consumed", false)) and is_equal_approx(float(timer_exact.get("optional_timer", -1.0)), 0.0) and bool(timer_exact.get("consumed", false)) and is_equal_approx(float(timer_no_power.get("optional_timer", -1.0)), 100.0) and bool(timer_no_power.get("consumed", true)) == false and is_equal_approx(float(timer_no_booster.get("optional_timer", -1.0)), 100.0) and is_equal_approx(float(timer_scaled.get("optional_timer", -1.0)), 1.0)

	var suppressed_tick: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 1.0, "optional_timer": 100.0, "warmup": 0.5, "total_time": 10.0, "did_regen": true, "targets": [damaged_target], "heal_suppressed": true}, 1.0, 1.0)
	var suppressed_map: Dictionary = suppressed_tick.get("mend_map", {})
	proof["no_heal_when_suppressed"] = is_equal_approx(float(suppressed_tick.get("warmup", -1.0)), 0.5 + 1.0 / 70.0) and is_equal_approx(float(suppressed_tick.get("total_time", -1.0)), 10.0 + 0.5 + 1.0 / 70.0) and int(suppressed_tick.get("last_change", -99)) == 1 and bool(suppressed_tick.get("did_regen", true)) == false and bool(suppressed_tick.get("any_targets", true)) == false and suppressed_map.is_empty() and is_equal_approx(float(suppressed_tick.get("optional_timer", -1.0)), 100.0) and is_equal_approx(float(suppressed_tick.get("heal_amount", -1.0)), 0.0) and bool(suppressed_tick.get("consumed", true)) == false

	# --- Live tick: a regen-projector placed live with a
	# damaged copper-wall neighbor two tiles away (the N2277
	# pattern -- the updateTargets scan rebuilds targets from
	# the placed buildings on the first tick, so a seeded
	# targets list no longer survives; the N2325 rewrite also
	# seeds the N2260 rows -- hydrogen 1.0 on the sprite
	# liquids meta, the N2322 pattern, and 1 phaseFabric on
	# the frame items -- so efficiency folds the power min
	# 0.5 and optional_efficiency 0.5). The tick driver is
	# called directly (as the N2160/N2214 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is
	# one source tick: efficiency folds the power min 0.5,
	# optional_efficiency equals the folded efficiency with
	# the booster held, warmup stays 0 (did_regen was false),
	# the optional timer rises 0.5 * 0.5 = 0.25, healAmount
	# is lerp(1, 2, 0.5) * 4/60 = 0.1, and the wall mend is
	# 0.1 * 0.5 * wall_max_health / 100. Tick 1 flushes it
	# (N2325: last_update_frame -1 vs update_id 0), so
	# mend_map ends empty and heal_applications carries the
	# wall amount. The second tick keeps consuming (the
	# advance set any_targets true), warmup rises 1/70, and
	# the mend accumulates again with no flush (update_id 0
	# == last_update_frame 0).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var hydrogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("hydrogen", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# Block.init health for copper-wall: Blocks.java 1704/1708 (80 * 4).
	# The extracted -1 sentinel cannot establish the damaged target scenario.
	blocks_by_id["copper-wall"].properties["health"] = 320

	var regen_cell := Vector2i(28, 20)
	var regen := Sprite2D.new()
	game.add_child(regen)
	game.call("record_placed_block", regen, blocks_by_id["regen-projector"], regen_cell)
	var wall_cell := Vector2i(30, 20)
	var wall := Sprite2D.new()
	game.add_child(wall)
	game.call("record_placed_block", wall, blocks_by_id["copper-wall"], wall_cell)
	var wall_max_health: float = float(wall.get_meta(placed_block_state.SOURCE_BLOCK_MAX_HEALTH_META_KEY, 0.0))
	placed_block_state.damage_sprite(wall, wall_max_health * 0.5)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status, seed
	# the phaseFabric and the any_targets gate on it).
	regen_projector_build_state.source_regen_projector_bind_frame_state(regen, blocks_by_id["regen-projector"])
	var regen_frame: Dictionary = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var regen_liquids: Dictionary = regen.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(regen_liquids, hydrogen_id, 1.0)

	# A freshly bound frame carries the updateTile state keys
	# with the Java build-field defaults (RegenProjector.java:
	# 109-113).
	var fresh_defaults: bool = regen_frame.has("warmup") and is_equal_approx(float(regen_frame["warmup"]), 0.0) and regen_frame.has("total_time") and is_equal_approx(float(regen_frame["total_time"]), 0.0) and regen_frame.has("optional_timer") and is_equal_approx(float(regen_frame["optional_timer"]), 0.0) and regen_frame.has("did_regen") and bool(regen_frame["did_regen"]) == false and regen_frame.has("targets") and (regen_frame["targets"] as Array).is_empty() and regen_frame.has("mend_map") and (regen_frame["mend_map"] as Dictionary).is_empty() and regen_frame.has("last_change") and int(regen_frame["last_change"]) == -2 and regen_frame.has("any_targets") and bool(regen_frame["any_targets"]) == false

	# The gate reads the frame any_targets BEFORE the advance
	# recomputes it, so the first tick needs the seeded true
	# (the N2214 proof pattern); the advance then keeps it true
	# from the scanned damaged wall.
	var wall_pos: int = block_geometry.tile_pos_state(wall_cell.x, wall_cell.y)
	var expected_mend: float = 0.1 * 0.5 * wall_max_health / 100.0
	regen_frame["any_targets"] = true
	regen_frame["power_status"] = 0.5
	regen_frame["items"] = {"phase-fabric": 1}
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var tick1_mend: Dictionary = regen_frame.get("mend_map", {})
	var tick1_apps: Dictionary = regen_frame.get("heal_applications", {})
	var tick1_ok: bool = is_equal_approx(float(regen_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(regen_frame.get("optional_efficiency", -1.0)), 0.5) and is_equal_approx(float(regen_frame.get("warmup", -1.0)), 0.0) and is_equal_approx(float(regen_frame.get("total_time", -1.0)), 0.0) and is_equal_approx(float(regen_frame.get("optional_timer", -1.0)), 0.25) and is_equal_approx(float(regen_frame.get("heal_amount", -1.0)), 0.1) and tick1_mend.is_empty() and is_equal_approx(float(tick1_apps.get(wall_pos, -1.0)), expected_mend) and int(regen_frame.get("last_update_frame", -99)) == 0 and bool(regen_frame.get("did_regen", false)) and bool(regen_frame.get("any_targets", false)) and int(regen_frame.get("last_change", -99)) == 1 and bool(regen_frame.get("consumed", true)) == false

	regen_frame["power_status"] = 0.5
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var tick2_mend: Dictionary = regen_frame.get("mend_map", {})
	var tick2_ok: bool = is_equal_approx(float(regen_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(regen_frame.get("warmup", -1.0)), 1.0 / 70.0) and is_equal_approx(float(regen_frame.get("total_time", -1.0)), 1.0 / 70.0) and is_equal_approx(float(regen_frame.get("optional_timer", -1.0)), 0.5) and is_equal_approx(float(tick2_mend.get(wall_pos, -1.0)), expected_mend) and bool(regen_frame.get("any_targets", false))
	proof["live_tick_advances_regen_frame"] = fresh_defaults and tick1_ok and tick2_ok

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RegenProjectorUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
