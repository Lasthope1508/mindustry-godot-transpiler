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

	# --- Pure flush (N2325): the mendMap flush
	# (RegenProjectorBuild.updateTile(),
	# RegenProjector.java:168-177) -- `if(lastUpdateFrame !=
	# state.updateId){` / `lastUpdateFrame = state.updateId;`
	# / `for(var entry : mendMap.entries()){` / `var build =
	# world.build(entry.key);` / `if(build != null){` /
	# `build.heal(entry.value);` / `build.recentlyHealed();`
	# / `mendMap.clear();` -- as the pure heal_applications
	# result {pos: amount}. The flush sits AFTER the heal
	# branch and OUTSIDE the efficiency gate, so it fires on
	# a zero-efficiency tick too -- but never on a suppressed
	# tick (the early return keeps the map). lastUpdateFrame
	# is the Java static `private static long lastUpdateFrame
	# = -1;` (RegenProjector.java:24) and updateId is `public
	# long updateId;` (GameState.java:23), incremented once
	# per logic update (`state.updateId ++;`,
	# Logic.java:512); both arrive as frame inputs with the
	# Java-faithful defaults -1 / 0, so a fresh frame flushes
	# once (on the first tick) and then waits for a live
	# updateId source. The LIVE application of the amounts to
	# the target buildings (world.build(pos) + build.heal +
	# recentlyHealed(), the timestamp write `lastHealTime =
	# Time.time;`, BuildingComp.java:491-493) waits for its
	# own slice. source_delta is Time.delta in ticks (1.0 =
	# one tick). The damaged target (pos 7, block health
	# 1000, health 500) accumulates 2/3 per tick at eff 1.0
	# with no booster (healAmount 4/60 * edelta 1.0 * 1000 /
	# 100, capped by the missing 500).
	var damaged_target: Dictionary = {"pos": 7, "block_health": 1000.0, "health": 500.0, "damaged": true, "heal_suppressed": false}

	# Flush on a new frame: a seeded map flushes its amounts
	# (the max of the seeded value and the fresh accumulation
	# -- Math.max, no stacking), a fresh accumulation flushes
	# in the same tick it was built, and explicit ids flush
	# when they differ. Every flush clears mend_map and
	# stamps last_update_frame = update_id.
	var flush_seeded: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.0, "targets": [damaged_target], "mend_map": {7: 2.0}}, 1.0, 1.0)
	var flush_seeded_apps: Dictionary = flush_seeded.get("heal_applications", {})
	var flush_seeded_map: Dictionary = flush_seeded.get("mend_map", {})
	var flush_fresh: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.0, "targets": [damaged_target]}, 1.0, 1.0)
	var flush_fresh_apps: Dictionary = flush_fresh.get("heal_applications", {})
	var flush_fresh_map: Dictionary = flush_fresh.get("mend_map", {})
	var flush_explicit: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 0.0, "targets": [], "mend_map": {7: 1.5}, "last_update_frame": 4, "update_id": 5}, 1.0, 1.0)
	var flush_explicit_apps: Dictionary = flush_explicit.get("heal_applications", {})
	var flush_explicit_map: Dictionary = flush_explicit.get("mend_map", {})
	proof["mend_map_flushes_on_new_frame"] = is_equal_approx(float(flush_seeded_apps.get(7, -1.0)), 2.0) and flush_seeded_map.is_empty() and int(flush_seeded.get("last_update_frame", -99)) == 0 and is_equal_approx(float(flush_fresh_apps.get(7, -1.0)), 2.0 / 3.0) and flush_fresh_map.is_empty() and int(flush_fresh.get("last_update_frame", -99)) == 0 and is_equal_approx(float(flush_explicit_apps.get(7, -1.0)), 1.5) and flush_explicit_map.is_empty() and int(flush_explicit.get("last_update_frame", -99)) == 5

	# No flush when the frame is unchanged: the map keeps
	# accumulating (Math.max against the seeded value) and
	# heal_applications stays empty -- both for explicit ids
	# and for the post-first-tick state (0 == 0).
	var no_flush: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.0, "targets": [damaged_target], "mend_map": {7: 1.0}, "last_update_frame": 5, "update_id": 5}, 1.0, 1.0)
	var no_flush_map: Dictionary = no_flush.get("mend_map", {})
	var no_flush_apps: Dictionary = no_flush.get("heal_applications", {})
	var no_flush_zero: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 0.0, "targets": [damaged_target], "mend_map": {7: 0.25}, "last_update_frame": 0, "update_id": 0}, 1.0, 1.0)
	var no_flush_zero_map: Dictionary = no_flush_zero.get("mend_map", {})
	var no_flush_zero_apps: Dictionary = no_flush_zero.get("heal_applications", {})
	proof["no_flush_when_frame_unchanged"] = is_equal_approx(float(no_flush_map.get(7, -1.0)), 1.0) and no_flush_apps.is_empty() and int(no_flush.get("last_update_frame", -99)) == 5 and is_equal_approx(float(no_flush_zero_map.get(7, -1.0)), 2.0 / 3.0) and no_flush_zero_apps.is_empty() and int(no_flush_zero.get("last_update_frame", -99)) == 0

	# The flush fires without efficiency: it sits outside the
	# `if(efficiency > 0){` gate (RegenProjector.java:141), so
	# a zero-efficiency tick still flushes the seeded map --
	# while healing nothing new (heal_amount 0.0, did_regen
	# false) and still folding any_targets over the damaged
	# target.
	var no_power: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 0.0, "targets": [damaged_target], "mend_map": {7: 1.5}}, 1.0, 1.0)
	var no_power_apps: Dictionary = no_power.get("heal_applications", {})
	var no_power_map: Dictionary = no_power.get("mend_map", {})
	proof["flush_fires_without_efficiency"] = is_equal_approx(float(no_power_apps.get(7, -1.0)), 1.5) and no_power_map.is_empty() and int(no_power.get("last_update_frame", -99)) == 0 and is_equal_approx(float(no_power.get("heal_amount", -1.0)), 0.0) and bool(no_power.get("did_regen", true)) == false and bool(no_power.get("any_targets", false))

	# Suppression blocks the flush: the early return
	# (RegenProjector.java:135-137) fires before the flush
	# block, so the seeded map is kept whole, no applications
	# are reported and last_update_frame stays -1 -- while
	# warmup/totalTime still advance (the N2228 key).
	var suppressed_tick: Dictionary = regen_projector_build_state.source_regen_projector_update_tile_advance_state({"efficiency": 1.0, "optional_efficiency": 1.0, "optional_timer": 100.0, "warmup": 0.5, "total_time": 10.0, "did_regen": true, "targets": [damaged_target], "mend_map": {7: 1.5}, "heal_suppressed": true}, 1.0, 1.0)
	var suppressed_map: Dictionary = suppressed_tick.get("mend_map", {})
	var suppressed_apps: Dictionary = suppressed_tick.get("heal_applications", {})
	proof["suppression_blocks_flush"] = is_equal_approx(float(suppressed_tick.get("warmup", -1.0)), 0.5 + 1.0 / 70.0) and is_equal_approx(float(suppressed_tick.get("total_time", -1.0)), 10.0 + 0.5 + 1.0 / 70.0) and is_equal_approx(float(suppressed_map.get(7, -1.0)), 1.5) and suppressed_apps.is_empty() and int(suppressed_tick.get("last_update_frame", -99)) == -1 and bool(suppressed_tick.get("did_regen", true)) == false and bool(suppressed_tick.get("any_targets", true)) == false and is_equal_approx(float(suppressed_tick.get("heal_amount", -1.0)), 0.0)

	# --- Live tick: a regen-projector placed live with a
	# damaged copper-wall neighbor two tiles away (the N2277
	# pattern -- the scan rebuilds targets from the placed
	# buildings on the first tick, so the seeded-targets
	# pattern the N2228 proof used no longer works). The tick
	# driver is called directly (as the N2228/N2277 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status. Hydrogen 1.0 is
	# seeded on the sprite liquids meta (the N2322 pattern)
	# and 1 phaseFabric on the frame items, so efficiency
	# folds the power min 0.5 and optional_efficiency 0.5
	# (the N2260 rows). One 1/60s tick is one source tick:
	# healAmount is lerp(1, 2, 0.5) * 4/60 = 0.1, and the
	# wall mend is 0.1 * 0.5 * wall_max_health / 100. Tick 1
	# flushes (last_update_frame -1 vs update_id 0): mend_map
	# ends empty and heal_applications carries the wall
	# amount. Tick 2 accumulates again with no flush
	# (update_id 0 == last_update_frame 0): mend_map holds
	# the wall amount and heal_applications is empty.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var hydrogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("hydrogen", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

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
	var tick2_apps: Dictionary = regen_frame.get("heal_applications", {})
	var tick2_ok: bool = is_equal_approx(float(regen_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(regen_frame.get("warmup", -1.0)), 1.0 / 70.0) and is_equal_approx(float(regen_frame.get("total_time", -1.0)), 1.0 / 70.0) and is_equal_approx(float(regen_frame.get("optional_timer", -1.0)), 0.5) and is_equal_approx(float(tick2_mend.get(wall_pos, -1.0)), expected_mend) and tick2_apps.is_empty() and int(regen_frame.get("last_update_frame", -99)) == 0 and bool(regen_frame.get("any_targets", false))
	proof["live_tick_flushes_mend_map"] = tick1_ok and tick2_ok

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RegenProjectorMendMapFlushProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
