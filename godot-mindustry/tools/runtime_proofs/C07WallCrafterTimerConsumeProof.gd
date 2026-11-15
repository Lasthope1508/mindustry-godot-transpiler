extends Node

const main_scene := preload("res://scenes/Main.tscn")
const wall_crafter_build_state := preload("res://src/game/SourceWallCrafterBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	# --- Pure timer (N2273): the frame-local Interval-
	# equivalent of TimerComp.timer (TimerComp.java:10-13,
	# `if(Float.isInfinite(time)) return false;` /
	# `return timer.get(index, time);`; Interval.get resets
	# times[id] = Time.time on fire, arc Interval.java:
	# 20-26; Time.time counts TICKS, arc Time.java:69-80):
	# threshold = duration / time_scale; a non-positive
	# time_scale is the infinite-time branch (fired false);
	# fired = elapsed >= threshold; elapsed_after RESETS
	# to 0.0 on fire (a reset, not a subtraction like the
	# Fracker accumulator). The Java gate is
	# `if(itemValid && eff * efficiency > 0 && timer(
	# timerUse, boostItemUseTime / timeScale)){`
	# (WallCrafter.java:207-209, `public float
	# boostItemUseTime = 120f;`, WallCrafter.java:45; the
	# large def overrides it to `boostItemUseTime = 60f /
	# 0.75f;` = 80f, Blocks.java:3032).
	var fires_at_threshold: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_use_state(120.0, 120.0, 1.0)
	var fires_above_threshold: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_use_state(121.0, 120.0, 1.0)
	var fires_scaled: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_use_state(60.0, 120.0, 2.0)
	var fires_large_def: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_use_state(80.0, 80.0, 1.0)
	proof["timer_fires_at_use_time"] = bool(fires_at_threshold.get("fired", false)) and is_equal_approx(float(fires_at_threshold.get("elapsed_after", -1.0)), 0.0) and is_equal_approx(float(fires_at_threshold.get("threshold", -1.0)), 120.0) and bool(fires_above_threshold.get("fired", false)) and bool(fires_scaled.get("fired", false)) and is_equal_approx(float(fires_scaled.get("threshold", -1.0)), 60.0) and bool(fires_large_def.get("fired", false)) and is_equal_approx(float(fires_large_def.get("threshold", -1.0)), 80.0)

	var below_threshold: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_use_state(119.9, 120.0, 1.0)
	var below_large_def: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_use_state(79.9, 80.0, 1.0)
	proof["timer_no_fire_below_threshold"] = bool(below_threshold.get("fired", true)) == false and is_equal_approx(float(below_threshold.get("elapsed_after", -1.0)), 119.9) and bool(below_large_def.get("fired", true)) == false and is_equal_approx(float(below_large_def.get("elapsed_after", -1.0)), 79.9)

	var zero_scale: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_use_state(120.0, 120.0, 0.0)
	var negative_scale: Dictionary = wall_crafter_build_state.source_wall_crafter_timer_use_state(120.0, 120.0, -1.0)
	proof["timer_no_fire_when_time_scale_zero"] = bool(zero_scale.get("fired", true)) == false and is_equal_approx(float(zero_scale.get("elapsed_after", -1.0)), 120.0) and is_inf(float(zero_scale.get("threshold", 0.0))) and bool(negative_scale.get("fired", true)) == false

	# --- Live tick: large-cliff-crushers and a cliff-crusher
	# placed live; the tick driver is called directly (as the
	# N2170/N2201/N2223/N2264 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The timer consume
	# runs after the N2223 advance (Java order is consume
	# :207-209 before lastEfficiency/offload :211-215, but
	# consume only removes 1 graphite -- it does not affect
	# the offload or this tick's eff, so the post-advance
	# check is order-equivalent): when item_valid holds and
	# eff * efficiency is positive and the timer fires at
	# the per-def boostItemUseTime (80f on the large def),
	# consume() removes 1 graphite (ConsumeItems.trigger,
	# ConsumeItems.java:44-48, clamped by ItemModule.
	# remove, ItemModule.java:258-263) and the elapsed
	# clock resets to 0.0. The hydrogen amounts are set on
	# the sprite liquids meta store (the live LiquidModule),
	# which the driver syncs into the frame each tick before
	# the fold (the Fracker proof precedent); the graphite
	# and efficiency_factor are seeded on the frame directly
	# (no live intake fills them yet, like the N2223 proof
	# seeds efficiency_factor).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var hydrogen_id: int = int(liquid_id_by_name.get("hydrogen", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# A: large crusher, hydrogen-full at full power, graphite
	# held, efficiency_factor 1.0, timer at the 80f
	# threshold: the tick accumulates one more tick (1.0/60.0s
	# = 1 tick), the timer fires, consume() removes 1 graphite
	# and the elapsed clock resets to 0.0.
	var fire_cell := Vector2i(28, 20)
	var fire_crusher := Sprite2D.new()
	game.add_child(fire_crusher)
	game.call("record_placed_block", fire_crusher, blocks_by_id["large-cliff-crusher"], fire_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# items on it).
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(fire_crusher, blocks_by_id["large-cliff-crusher"])
	var fire_frame: Dictionary = fire_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	var fire_store: Dictionary = fire_crusher.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(fire_store, hydrogen_id, 1.0)
	fire_frame["items"] = {"graphite": 2}
	fire_frame["power_status"] = 1.0
	fire_frame["efficiency_factor"] = 1.0
	fire_frame["timer_use_elapsed"] = 80.0

	# B: large crusher, hydrogen-full at full power, NO
	# graphite, timer at the threshold: item_valid stamps
	# false, so the gate is closed -- no removal and NO
	# elapsed reset (Java short-circuits before calling
	# timer(), so the Interval keeps its old stamp and fires
	# at once when the gate reopens).
	var no_graphite_cell := Vector2i(22, 20)
	var no_graphite_crusher := Sprite2D.new()
	game.add_child(no_graphite_crusher)
	game.call("record_placed_block", no_graphite_crusher, blocks_by_id["large-cliff-crusher"], no_graphite_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(no_graphite_crusher, blocks_by_id["large-cliff-crusher"])
	var no_graphite_frame: Dictionary = no_graphite_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	var no_graphite_store: Dictionary = no_graphite_crusher.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(no_graphite_store, hydrogen_id, 1.0)
	no_graphite_frame["items"] = {}
	no_graphite_frame["power_status"] = 1.0
	no_graphite_frame["efficiency_factor"] = 1.0
	no_graphite_frame["timer_use_elapsed"] = 80.0

	# C: large crusher, hydrogen-full at full power, graphite
	# held, timer at the threshold, but efficiency_factor 0.0
	# (the default -- the live getEfficiency fill is still
	# deferred): eff is 0, so eff * efficiency is not
	# positive and the gate is closed -- no removal and NO
	# elapsed reset.
	var zero_eff_cell := Vector2i(16, 20)
	var zero_eff_crusher := Sprite2D.new()
	game.add_child(zero_eff_crusher)
	game.call("record_placed_block", zero_eff_crusher, blocks_by_id["large-cliff-crusher"], zero_eff_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(zero_eff_crusher, blocks_by_id["large-cliff-crusher"])
	var zero_eff_frame: Dictionary = zero_eff_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	var zero_eff_store: Dictionary = zero_eff_crusher.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(zero_eff_store, hydrogen_id, 1.0)
	zero_eff_frame["items"] = {"graphite": 2}
	zero_eff_frame["power_status"] = 1.0
	zero_eff_frame["timer_use_elapsed"] = 80.0

	# D: cliff-crusher, graphite held (3), full power,
	# efficiency_factor 1.0, timer at the 120f class-default
	# threshold: it has no booster item, so item_valid stamps
	# false and the gate never opens -- no removal and NO
	# elapsed reset, even though the timer is past threshold.
	var cliff_cell := Vector2i(28, 14)
	var cliff_crusher := Sprite2D.new()
	game.add_child(cliff_crusher)
	game.call("record_placed_block", cliff_crusher, blocks_by_id["cliff-crusher"], cliff_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(cliff_crusher, blocks_by_id["cliff-crusher"])
	var cliff_frame: Dictionary = cliff_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	cliff_frame["items"] = {"graphite": 3}
	cliff_frame["power_status"] = 1.0
	cliff_frame["efficiency_factor"] = 1.0
	cliff_frame["timer_use_elapsed"] = 120.0

	wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)
	fire_frame = fire_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	no_graphite_frame = no_graphite_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	zero_eff_frame = zero_eff_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	cliff_frame = cliff_crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	proof["timer_consume_removes_graphite"] = int(fire_frame.get("items", {}).get("graphite", -1)) == 1 and is_equal_approx(float(fire_frame.get("timer_use_elapsed", -1.0)), 0.0) and is_equal_approx(float(fire_frame.get("efficiency", -1.0)), 1.0) and bool(fire_frame.get("item_valid", false))
	proof["timer_requires_item_valid_and_positive_eff"] = bool(no_graphite_frame.get("item_valid", true)) == false and float(no_graphite_frame.get("timer_use_elapsed", 0.0)) >= 80.0 and int(no_graphite_frame.get("items", {}).get("graphite", 0)) == 0 and int(zero_eff_frame.get("items", {}).get("graphite", -1)) == 2 and float(zero_eff_frame.get("timer_use_elapsed", 0.0)) >= 80.0 and is_equal_approx(float(zero_eff_frame.get("eff", -1.0)), 0.0)
	proof["timer_no_item_for_cliff_crusher"] = bool(cliff_frame.get("item_valid", true)) == false and int(cliff_frame.get("items", {}).get("graphite", -1)) == 3 and float(cliff_frame.get("timer_use_elapsed", 0.0)) >= 120.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WallCrafterTimerConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
